/**
 * Offloading GVL-free calls to a Fiber scheduler.
 *
 * Copyright (c) 2009 -      RMagick contributors
 *
 * @file     rmagick_gvl.cpp
 */

#include "rmagick.h"
#include "ruby/ractor.h"
#if defined(RMAGICK_OFFLOAD_SAFE)
#include <atomic>
#endif


/*
 * rb_thread_call_without_gvl releases the GVL but keeps the calling thread busy
 * until the ImageMagick function returns. Under a Fiber scheduler that has a
 * worker pool (Async with IO::Event::WorkerPool), that stalls every fiber on
 * the thread for the whole operation. Ruby 4.0 lets rb_nogvl hand a call to
 * the scheduler instead (RB_NOGVL_OFFLOAD_SAFE, Feature #20876): the call runs
 * on a worker thread while the calling fiber is suspended.
 *
 * Two things change for the caller when that happens, and rm_gvl_call deals
 * with both:
 *
 * 1. The scheduler can raise into the waiting fiber, for example when the
 *    task is stopped or times out. The scheduler waits for the worker to
 *    finish first, or cancels the call before a worker starts it, but the
 *    exception unwinds through the caller and skips the code after the call.
 *    The caller registers what it would have released, and it is released
 *    before re-raising. IO::Event::WorkerPool can also cancel a call that no
 *    worker has started without raising, when the fiber wakes up early right
 *    after a task is stopped, and Ruby then returns as if the call had run.
 *    rm_gvl_call offloads such a call once more and otherwise runs it on the
 *    calling thread.
 *
 * 2. Other fibers on the same thread run while the call is in flight. While a
 *    call reads an object, changing or destroying it raises. While a call
 *    changes an image, any use of it raises. Nothing waits, so no fiber is
 *    suspended while it holds a pointer that another fiber could free.
 *
 * ImageMagick reads some images through a working area of the pixel cache
 * that every thread outside OpenMP shares, so while an offloaded call uses an
 * image, no other call can use the image or its pixel cache, which clones of
 * the image share. A call that stays on its thread does not mark the image,
 * so an image must not be used by two threads without a scheduler at once.
 * RMagick itself reads and writes pixels through a cache view of its own.
 *
 * Without a scheduler that offloads, or on Ruby before 4.0, rm_gvl_call runs
 * the function with rb_thread_call_without_gvl. An interrupt that arrives
 * during the function, such as Thread#raise or Timeout, is raised after the
 * function returns, so what the caller registered is released then too.
 * Interrupts are deferred until then because a GC that xmalloc starts in the
 * function (Magick::MANAGED_MEMORY) takes the GVL back and would raise them
 * through ImageMagick. An exception raised by a trap handler there is not
 * deferred.
 */

typedef enum
{
    OffloadRead,
    OffloadUpdate
} OffloadMode;

typedef struct
{
    gvl_function_t *fp;
    void *args;
    void *result;
    bool started;
    bool done;
} offload_call_t;

// Stores the result here rather than relying on the return value of rb_nogvl
// or rb_thread_call_without_gvl, which is lost when an exception is raised
// into the calling fiber after the function returns.
static void *
offload_run(void *arg)
{
    offload_call_t *call = (offload_call_t *)arg;

    call->started = true;
    call->result = call->fp(call->args);
    call->done = true;
    return call->result;
}

static VALUE
call_without_gvl(VALUE arg)
{
    rb_thread_call_without_gvl(offload_run, (void *)arg, RUBY_UBF_PROCESS, NULL);
    return Qnil;
}

static VALUE interrupt_mask = Qnil;
static ID id_handle_interrupt;

static VALUE
call_without_gvl_block(RB_BLOCK_CALL_FUNC_ARGLIST(yielded_arg, arg))
{
    return call_without_gvl(arg);
}

static VALUE
check_interrupts(VALUE unused)
{
    rb_thread_check_ints();
    return Qnil;
}

static VALUE
call_deferring_interrupts(VALUE arg)
{
    return rb_block_call(rb_cThread, id_handle_interrupt, 1, &interrupt_mask, call_without_gvl_block, arg);
}

#if defined(RMAGICK_OFFLOAD_SAFE)

// Value in the table of an object that a call is changing
#define OFFLOAD_UPDATING ((st_data_t)-1)

static void raise_in_use(void) ATTRIBUTE_NORETURN;

static rb_ractor_local_key_t offloaded_key;

// Calls in flight in all Ractors, to skip the table when there are none
static std::atomic<unsigned int> offloads_in_flight(0);

static void
offloaded_free(void *table)
{
    st_free_table((st_table *)table);
}

static const struct rb_ractor_local_storage_type offloaded_type = { NULL, offloaded_free };

// Data pointer of an Image, its pixel cache, an Info or a KernelInfo => number
// of calls in flight that read it, or OFFLOAD_UPDATING. Ruby objects that can
// be changed never cross Ractors, so each Ractor has its own table.
static st_table *
offloaded(void)
{
    st_table *table = (st_table *)rb_ractor_local_storage_ptr(offloaded_key);

    if (!table)
    {
        table = st_init_numtable();
        rb_ractor_local_storage_ptr_set(offloaded_key, table);
    }
    return table;
}

static st_data_t
offload_state(const void *ptr)
{
    st_data_t state = 0;

    if (offloads_in_flight.load(std::memory_order_relaxed) == 0)
    {
        return 0;
    }
    st_lookup(offloaded(), (st_data_t)ptr, &state);
    return state;
}

static void
offload_begin(const void *ptr, OffloadMode mode)
{
    st_data_t state = offload_state(ptr);

    st_insert(offloaded(), (st_data_t)ptr, mode == OffloadUpdate ? OFFLOAD_UPDATING : state + 1);
    offloads_in_flight.fetch_add(1, std::memory_order_relaxed);
}

static void
offload_end(const void *ptr)
{
    st_data_t key = (st_data_t)ptr;
    st_data_t state = offload_state(ptr);

    if (state == OFFLOAD_UPDATING || state <= 1)
    {
        st_delete(offloaded(), &key, NULL);
    }
    else
    {
        st_insert(offloaded(), key, state - 1);
    }
    offloads_in_flight.fetch_sub(1, std::memory_order_relaxed);
}

static void
raise_in_use(void)
{
    rb_raise(rb_eRuntimeError, "object is in use by another fiber");
}

// The data pointer that identifies obj in the table, or NULL for an object
// that is not tracked, such as the String of Image.from_blob.
static void *
offload_key(VALUE obj)
{
    if (RB_SPECIAL_CONST_P(obj) || !RB_TYPE_P(obj, T_DATA))
    {
        return NULL;
    }
    return DATA_PTR(obj);
}

static VALUE
offload_call(VALUE arg)
{
    rb_nogvl(offload_run, (void *)arg, RUBY_UBF_PROCESS, NULL, RB_NOGVL_OFFLOAD_SAFE);
    return Qnil;
}

static int
offload_p(void)
{
    static ID id_blocking_operation_wait = 0;
    VALUE scheduler = rb_fiber_scheduler_current();

    if (scheduler == Qnil)
    {
        return 0;
    }
    if (!id_blocking_operation_wait)
    {
        id_blocking_operation_wait = rb_intern("blocking_operation_wait");
    }
    return rb_respond_to(scheduler, id_blocking_operation_wait);
}
#endif


/**
 * Set up rm_gvl_call. Called once, when the extension is loaded.
 *
 * No Ruby usage (internal function)
 */
void
rm_gvl_init(void)
{
    rb_gc_register_address(&interrupt_mask);
    interrupt_mask = rb_hash_new();
    rb_funcall(interrupt_mask, rb_intern("compare_by_identity"), 0);
    rb_hash_aset(interrupt_mask, rb_cObject, ID2SYM(rb_intern("never")));
    rb_ractor_make_shareable(interrupt_mask);
    id_handle_interrupt = rb_intern("handle_interrupt");

#if defined(RMAGICK_OFFLOAD_SAFE)
    offloaded_key = rb_ractor_local_storage_ptr_newkey(&offloaded_type);
#endif
}


/**
 * Raise if an offloaded call is changing the object.
 *
 * No Ruby usage (internal function)
 *
 * @param ptr the data pointer of an Image, Info or KernelInfo
 */
void
rm_gvl_check_readable(const void *ptr)
{
#if defined(RMAGICK_OFFLOAD_SAFE)
    if (offload_state(ptr) == OFFLOAD_UPDATING)
    {
        raise_in_use();
    }
#endif
}


/**
 * Whether an offloaded call is using the object.
 *
 * No Ruby usage (internal function)
 *
 * @param ptr the data pointer of an Image, Info or KernelInfo
 * @return true if a call reads or changes the object
 */
bool
rm_gvl_in_use(const void *ptr)
{
#if defined(RMAGICK_OFFLOAD_SAFE)
    return offload_state(ptr) != 0;
#else
    return false;
#endif
}


/**
 * Raise if an offloaded call is using the object.
 *
 * No Ruby usage (internal function)
 *
 * @param ptr the data pointer of an Image, Info or KernelInfo
 */
void
rm_gvl_check_writable(const void *ptr)
{
#if defined(RMAGICK_OFFLOAD_SAFE)
    if (rm_gvl_in_use(ptr))
    {
        raise_in_use();
    }
#endif
}


#if defined(RMAGICK_OFFLOAD_SAFE)
typedef struct
{
    void *key;
    OffloadMode mode;
    bool image;
} offload_mark_t;

static bool
marked(const offload_mark_t *marks, long count, const void *key)
{
    for (long i = 0; i < count; i++)
    {
        if (marks[i].key == key)
        {
            return true;
        }
    }
    return false;
}

// The data pointer of an object registered with read() or update(), or of the
// jth element of an array registered with read_each() or update_each(), and
// whether the object is an Image
static void *
object_key(VALUE obj, const void *ptr, bool each, long j, bool *image)
{
    if (ptr)
    {
        *image = true;
        return (void *)ptr;
    }
    obj = each ? rb_ary_entry(obj, j) : obj;
    *image = rb_typeddata_is_kind_of(obj, &rm_image_data_type);
    return offload_key(obj);
}

static void
add_mark(offload_mark_t *marks, long *nmarks, void *key, OffloadMode mode, bool image)
{
    if (!key || marked(marks, *nmarks, key))
    {
        return;
    }
    marks[*nmarks].key = key;
    marks[*nmarks].mode = mode;
    marks[*nmarks].image = image;
    (*nmarks)++;
}

static bool
mark_in_use(const offload_mark_t *mark)
{
    st_data_t state = offload_state(mark->key);

    if (mark->image)
    {
        return state != 0;
    }
    return state == OFFLOAD_UPDATING || (mark->mode == OffloadUpdate && state != 0);
}
#endif

static void
release_exception(void *ptr, intptr_t arg ATTRIBUTE_UNUSED)
{
    DestroyExceptionInfo((ExceptionInfo *)ptr);
}

static void
destroy_info(void *ptr, intptr_t arg ATTRIBUTE_UNUSED)
{
    DestroyImageInfo((ImageInfo *)ptr);
}

static void
destroy_draw_info(void *ptr, intptr_t arg ATTRIBUTE_UNUSED)
{
    DestroyDrawInfo((DrawInfo *)ptr);
}

static void
destroy_kernel(void *ptr, intptr_t arg ATTRIBUTE_UNUSED)
{
    DestroyKernelInfo((KernelInfo *)ptr);
}

static void
free_ruby_memory(void *ptr, intptr_t arg ATTRIBUTE_UNUSED)
{
    xfree(ptr);
}

static void
free_magick_memory(void *ptr, intptr_t arg ATTRIBUTE_UNUSED)
{
    magick_free(ptr);
}

static void
destroy_image(void *ptr, intptr_t arg ATTRIBUTE_UNUSED)
{
    DestroyImageList((Image *)ptr);
}

static void
split_images(void *ptr, intptr_t arg ATTRIBUTE_UNUSED)
{
    rm_split((Image *)ptr);
}

#if defined(IMAGEMAGICK_7)
static void
restore_channel_mask(void *ptr, intptr_t arg)
{
    SetPixelChannelMask((Image *)ptr, (ChannelType)arg);
}
#endif


/**
 * Prepare a call of fp(args).
 *
 * No Ruby usage (internal function)
 *
 * @param fp the function
 * @param args its argument struct, on the caller's stack
 */
rm_gvl_call::rm_gvl_call(gvl_function_t *fp, void *args)
    : fp(fp), args(args), nobjects(0), ncleanups(0), result_type(ResultIgnored), keep(false)
{
}


rm_gvl_call &
rm_gvl_call::add_object(VALUE obj, const void *ptr, bool update, bool each)
{
    if (nobjects == MaxObjects)
    {
        rb_bug("too many objects for an offloaded call");
    }
    objects[nobjects].obj = obj;
    objects[nobjects].ptr = ptr;
    objects[nobjects].update = update;
    objects[nobjects].each = each;
    nobjects++;
    return *this;
}


/**
 * Call release(ptr, arg) if the call is refused or unwound. Nothing is
 * registered when ptr is NULL.
 *
 * @param release the function
 * @param ptr its first argument
 * @param arg its second argument
 * @return self
 */
rm_gvl_call &
rm_gvl_call::cleanup(void (*release)(void *, intptr_t), void *ptr, intptr_t arg)
{
    if (!ptr)
    {
        return *this;
    }
    if (ncleanups == MaxCleanups)
    {
        rb_bug("too many cleanups for an offloaded call");
    }
    cleanups[ncleanups].release = release;
    cleanups[ncleanups].ptr = ptr;
    cleanups[ncleanups].arg = arg;
    ncleanups++;
    return *this;
}


/**
 * The call reads the data of obj. Other fibers can still read it, but cannot
 * change or destroy it while the call is in flight. Another call cannot use
 * an image that the call reads.
 *
 * @param obj an Image, Info or KernelInfo
 * @return self
 */
rm_gvl_call &
rm_gvl_call::read(VALUE obj)
{
    return add_object(obj, NULL, false, false);
}


/**
 * Like read(VALUE), for the data pointer of an Image that the caller has
 * fetched.
 *
 * @param ptr the data pointer
 * @return self
 */
rm_gvl_call &
rm_gvl_call::read(const void *ptr)
{
    return add_object(Qundef, ptr, false, false);
}


/**
 * The call changes the data of obj, or the caller replaces it with the result.
 * Other fibers cannot use it while the call is in flight.
 *
 * @param obj an Image, Info or KernelInfo
 * @return self
 */
rm_gvl_call &
rm_gvl_call::update(VALUE obj)
{
    return add_object(obj, NULL, true, false);
}


/**
 * Like update(VALUE), for the data pointer of an Image.
 *
 * @param ptr the data pointer
 * @return self
 */
rm_gvl_call &
rm_gvl_call::update(const void *ptr)
{
    return add_object(Qundef, ptr, true, false);
}


/**
 * The call reads every object in the array, such as the images of an ImageList.
 * A copy of the array keeps the objects alive while the call is in flight,
 * even if another fiber removes them from the array.
 *
 * @param ary the array
 * @return self
 */
rm_gvl_call &
rm_gvl_call::read_each(VALUE ary)
{
    return add_object(rb_ary_dup(ary), NULL, false, true);
}


/**
 * The call changes every object in the array, such as the images of an
 * ImageList. Like read_each(), a copy of the array keeps the objects alive.
 *
 * @param ary the array
 * @return self
 */
rm_gvl_call &
rm_gvl_call::update_each(VALUE ary)
{
    return add_object(rb_ary_dup(ary), NULL, true, true);
}


/**
 * Destroy the exception if the call is refused or unwound.
 *
 * @param exception the ExceptionInfo, may be NULL
 * @return self
 */
rm_gvl_call &
rm_gvl_call::release(ExceptionInfo *exception)
{
    return cleanup(release_exception, exception, 0);
}


/**
 * Destroy the ImageInfo if the call is refused or unwound.
 *
 * @param info the ImageInfo, may be NULL
 * @return self
 */
rm_gvl_call &
rm_gvl_call::release(ImageInfo *info)
{
    return cleanup(destroy_info, info, 0);
}


/**
 * Destroy the DrawInfo if the call is refused or unwound.
 *
 * @param draw_info the DrawInfo, may be NULL
 * @return self
 */
rm_gvl_call &
rm_gvl_call::release(DrawInfo *draw_info)
{
    return cleanup(destroy_draw_info, draw_info, 0);
}


/**
 * Destroy the KernelInfo if the call is refused or unwound.
 *
 * @param kernel the KernelInfo, may be NULL
 * @return self
 */
rm_gvl_call &
rm_gvl_call::release(KernelInfo *kernel)
{
    return cleanup(destroy_kernel, kernel, 0);
}


/**
 * Free the buffer, allocated with ALLOC_N, if the call is refused or unwound.
 *
 * @param buffer the buffer, may be NULL
 * @return self
 */
rm_gvl_call &
rm_gvl_call::free_buffer(void *buffer)
{
    return cleanup(free_ruby_memory, buffer, 0);
}


/**
 * Free the memory, allocated by ImageMagick, if the call is refused or unwound.
 *
 * @param memory the memory, may be NULL
 * @return self
 */
rm_gvl_call &
rm_gvl_call::relinquish(void *memory)
{
    return cleanup(free_magick_memory, memory, 0);
}


/**
 * Destroy the image if the call is refused or unwound.
 *
 * @param image the image, may be NULL
 * @return self
 */
rm_gvl_call &
rm_gvl_call::destroy(Image *image)
{
    return cleanup(destroy_image, image, 0);
}


/**
 * Split the linked images if the call is refused or unwound.
 *
 * @param images the first image of the list
 * @return self
 */
rm_gvl_call &
rm_gvl_call::split(Image *images)
{
    return cleanup(split_images, images, 0);
}


#if defined(IMAGEMAGICK_7)
/**
 * Restore the channel mask of the image if the call is refused or unwound.
 *
 * @param image the image whose channel mask was changed
 * @param channel_mask its channel mask before the change
 * @return self
 */
rm_gvl_call &
rm_gvl_call::restore_mask(Image *image, ChannelType channel_mask)
{
    return cleanup(restore_channel_mask, image, (intptr_t)channel_mask);
}
#endif


/**
 * The result is memory that the caller frees with magick_free. It is freed if
 * the call is unwound.
 *
 * @return self
 */
rm_gvl_call &
rm_gvl_call::free_result()
{
    result_type = ResultMemory;
    return *this;
}


/**
 * Run the call on the calling thread even under a Fiber scheduler, for
 * example because it uses a FILE * that another fiber could close.
 *
 * @param keep whether to keep the call on the calling thread
 * @return self
 */
rm_gvl_call &
rm_gvl_call::keep_thread(bool keep)
{
    this->keep = keep;
    return *this;
}


void
rm_gvl_call::unwind(ResultType type, void *result)
{
    if (result)
    {
        if (type == ResultImage)
        {
            DestroyImageList((Image *)result);
        }
        else if (type == ResultMemory)
        {
            magick_free(result);
        }
    }
    for (int i = 0; i < ncleanups; i++)
    {
        cleanups[i].release(cleanups[i].ptr, cleanups[i].arg);
    }
}


void *
rm_gvl_call::call(ResultType type)
{
#if defined(RMAGICK_OFFLOAD_SAFE)
    bool offload = !keep && offload_p();

    if (offload || offloads_in_flight.load(std::memory_order_relaxed) != 0)
    {
        offload_call_t call = { fp, args, NULL, false, false };
        offload_mark_t *marks;
        VALUE marks_buffer;
        long count = 0, nmarks = 0;
        int tag;

        for (int i = 0; i < nobjects; i++)
        {
            count += objects[i].each ? RARRAY_LEN(objects[i].obj) : 1;
        }
        marks = ALLOCV_N(offload_mark_t, marks_buffer, 2 * count);

        // An object that the call both reads and changes is marked as changed.
        for (int pass = 0; pass < 2; pass++)
        {
            for (int i = 0; i < nobjects; i++)
            {
                long len = objects[i].each ? RARRAY_LEN(objects[i].obj) : 1;
                OffloadMode mode = objects[i].update ? OffloadUpdate : OffloadRead;

                if (objects[i].update != (pass == 0))
                {
                    continue;
                }
                for (long j = 0; j < len; j++)
                {
                    bool image;
                    void *key = object_key(objects[i].obj, objects[i].ptr, objects[i].each, j, &image);

                    add_mark(marks, &nmarks, key, mode, image);
                    if (key && image)
                    {
                        add_mark(marks, &nmarks, ((Image *)key)->cache, mode, true);
                    }
                }
            }
        }

        for (long i = 0; i < nmarks; i++)
        {
            if ((offload || marks[i].image) && mark_in_use(&marks[i]))
            {
                ALLOCV_END(marks_buffer);
                unwind(type, NULL);
                raise_in_use();
            }
        }
        if (!offload)
        {
            ALLOCV_END(marks_buffer);
            return call_here(type);
        }

        for (long i = 0; i < nmarks; i++)
        {
            offload_begin(marks[i].key, marks[i].mode);
        }

        rb_protect(offload_call, (VALUE)&call, &tag);
        if (!tag && !call.started)
        {
            rb_protect(offload_call, (VALUE)&call, &tag);
        }

        for (long i = 0; i < nmarks; i++)
        {
            offload_end(marks[i].key);
        }
        ALLOCV_END(marks_buffer);
        if (tag)
        {
            // The scheduler raised into this fiber after the worker finished.
            unwind(type, call.result);
            rb_jump_tag(tag);
        }
        if (!call.started)
        {
            return call_here(type);
        }

        return call.result;
    }
#endif

    return call_here(type);
}


void *
rm_gvl_call::call_here(ResultType type)
{
    offload_call_t call = { fp, args, NULL, false, false };
    int tag;

    rb_protect(check_interrupts, Qnil, &tag);
    if (tag)
    {
        unwind(type, NULL);
        rb_jump_tag(tag);
    }

    rb_protect(call_deferring_interrupts, (VALUE)&call, &tag);
    if (tag)
    {
        if (call.done)
        {
            unwind(type, call.result);
        }
        rb_jump_tag(tag);
    }
    return call.result;
}


/**
 * Run the call, letting a Fiber scheduler offload it.
 *
 * No Ruby usage (internal function)
 *
 * @return the result of the call, cast to T
 */
template <>
Image *
rm_gvl_call::run<Image *>()
{
    return (Image *)call(ResultImage);
}


template <>
void
rm_gvl_call::run<void>()
{
    call(ResultIgnored);
}

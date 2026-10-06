/**
 * Offloading GVL-free calls to a Fiber scheduler.
 *
 * Copyright (c) 2009 -      RMagick contributors
 *
 * @file     rmagick_gvl.cpp
 */

#include "rmagick.h"
#if defined(RMAGICK_OFFLOAD_SAFE)
#include "ruby/ractor.h"
#include <atomic>
#endif


/*
 * CALL_FUNC_WITHOUT_GVL releases the GVL but keeps the calling thread busy
 * until the ImageMagick function returns. Under a Fiber scheduler that has a
 * worker pool (Async with IO::Event::WorkerPool), that stalls every fiber on
 * the thread for the whole operation. Ruby 4.0 lets rb_nogvl hand a call to
 * the scheduler instead (RB_NOGVL_OFFLOAD_SAFE, Feature #20876): the call runs
 * on a worker thread while the calling fiber is suspended.
 *
 * Two things change for the caller when that happens, and the rm_gvl_offload_*
 * functions below deal with both:
 *
 * 1. The scheduler can raise into the waiting fiber, for example when the
 *    task is stopped or times out. The scheduler waits for the worker to
 *    finish first, so the call has completed, but the exception unwinds
 *    through the caller and skips the code after the call. The caller passes
 *    what it would have released, and it is released before re-raising.
 *
 * 2. Other fibers on the same thread run while the call is in flight. While a
 *    call reads an object, changing or destroying it raises. While a call
 *    changes an image, any use of it raises. Nothing waits, so no fiber is
 *    suspended while it holds a pointer that another fiber could free.
 *
 * Without a scheduler that offloads, or on Ruby before 4.0, these functions
 * are CALL_FUNC_WITHOUT_GVL.
 */

typedef enum
{
    OffloadRead,
    OffloadUpdate
} OffloadMode;

typedef enum
{
    OffloadResultIgnored,
    OffloadResultImage,
    OffloadResultMemory
} OffloadResultType;

// What the caller releases after the call. It is released here instead when
// the call is refused or unwound.
typedef struct
{
    OffloadResultType result_type;
    ExceptionInfo *exception;
    Image *image;
    Image *masked_image;
    ChannelType channel_mask;
} offload_cleanup_t;


#if defined(RMAGICK_OFFLOAD_SAFE)

// Value in the table of an object that a call is changing
#define OFFLOAD_UPDATING ((st_data_t)-1)

typedef struct
{
    gvl_function_t *fp;
    void *args;
    void *result;
} offload_call_t;

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

// Data pointer of an Image, Info or KernelInfo => number of calls in flight
// that read it, or OFFLOAD_UPDATING. Ruby objects that can be changed never
// cross Ractors, so each Ractor has its own table.
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

static int
offload_begin(const void *ptr, OffloadMode mode)
{
    st_data_t state = offload_state(ptr);

    if (state == OFFLOAD_UPDATING || (mode == OffloadUpdate && state != 0))
    {
        return 0;
    }
    st_insert(offloaded(), (st_data_t)ptr, mode == OffloadUpdate ? OFFLOAD_UPDATING : state + 1);
    offloads_in_flight.fetch_add(1, std::memory_order_relaxed);
    return 1;
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

// Runs on the worker thread. Stores the result here rather than relying on
// the return value of rb_nogvl, which is lost when the scheduler raises into
// the waiting fiber.
static void *
offload_run(void *arg)
{
    offload_call_t *call = (offload_call_t *)arg;

    call->result = call->fp(call->args);
    return call->result;
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

static void
offload_release(const offload_cleanup_t *cleanup, void *result)
{
    if (result)
    {
        switch (cleanup->result_type)
        {
            case OffloadResultImage:
                DestroyImageList((Image *)result);
                break;
            case OffloadResultMemory:
                magick_free(result);
                break;
            case OffloadResultIgnored:
                break;
        }
    }
    if (cleanup->image)
    {
        DestroyImageList(cleanup->image);
    }
#if defined(IMAGEMAGICK_7)
    if (cleanup->masked_image)
    {
        SetPixelChannelMask(cleanup->masked_image, cleanup->channel_mask);
    }
#endif
    if (cleanup->exception)
    {
        DestroyExceptionInfo(cleanup->exception);
    }
}
#endif


/**
 * Run fp(args) without the GVL, letting a Fiber scheduler offload it.
 *
 * No Ruby usage (internal function)
 *
 * @param fp the function
 * @param args its argument struct, on the caller's stack
 * @param obj the Ruby object whose data the call uses
 * @param mode whether the call reads or changes the data of obj
 * @param cleanup what to release if the call is refused or unwound
 * @param dependency another Ruby object that the call reads, or nil
 * @return the result of fp
 */
static void *
offload(gvl_function_t *fp, void *args, VALUE obj, OffloadMode mode, const offload_cleanup_t *cleanup,
        VALUE dependency)
{
#if defined(RMAGICK_OFFLOAD_SAFE)
    if (offload_p())
    {
        offload_call_t call = { fp, args, NULL };
        void *key = offload_key(obj);
        void *dependency_key = offload_key(dependency);
        int tag;

        if (key && !offload_begin(key, mode))
        {
            offload_release(cleanup, NULL);
            raise_in_use();
        }
        if (dependency_key && !offload_begin(dependency_key, OffloadRead))
        {
            if (key)
            {
                offload_end(key);
            }
            offload_release(cleanup, NULL);
            raise_in_use();
        }

        rb_protect(offload_call, (VALUE)&call, &tag);

        if (dependency_key)
        {
            offload_end(dependency_key);
        }
        if (key)
        {
            offload_end(key);
        }
        if (tag)
        {
            // The scheduler raised into this fiber after the worker finished.
            offload_release(cleanup, call.result);
            rb_jump_tag(tag);
        }

        return call.result;
    }
#endif

    return CALL_FUNC_WITHOUT_GVL(fp, args);
}


/**
 * Set up the offload bookkeeping. Called once, when the extension is loaded.
 *
 * No Ruby usage (internal function)
 */
void
rm_gvl_init_offload(void)
{
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
    if (offload_state(ptr) != 0)
    {
        raise_in_use();
    }
#endif
}


/**
 * Run an ImageMagick function that reads the image of obj and returns a new
 * image, letting a Fiber scheduler offload it. If the call is unwound, the
 * new image and exception are released.
 *
 * No Ruby usage (internal function)
 *
 * @param fp the function
 * @param args its argument struct
 * @param obj the Ruby object whose image the call uses
 * @param exception the ExceptionInfo passed to the call, may be NULL
 * @param dependency another Ruby object that the call reads, or nil
 * @return the new image
 */
Image *
rm_gvl_offload_image(gvl_function_t *fp, void *args, VALUE obj, ExceptionInfo *exception, VALUE dependency)
{
    offload_cleanup_t cleanup = { OffloadResultImage, exception, NULL, NULL, UndefinedChannel };

    return (Image *)offload(fp, args, obj, OffloadRead, &cleanup, dependency);
}


/**
 * Like rm_gvl_offload_image, for a method that may replace the image of obj
 * with the new image.
 *
 * No Ruby usage (internal function)
 *
 * @param fp the function
 * @param args its argument struct
 * @param obj the Ruby object whose image the call uses
 * @param exception the ExceptionInfo passed to the call, may be NULL
 * @param replace true if the new image replaces the image of obj
 * @return the new image
 */
Image *
rm_gvl_offload_image_replacing(gvl_function_t *fp, void *args, VALUE obj, ExceptionInfo *exception, bool replace)
{
    offload_cleanup_t cleanup = { OffloadResultImage, exception, NULL, NULL, UndefinedChannel };

    return (Image *)offload(fp, args, obj, replace ? OffloadUpdate : OffloadRead, &cleanup, Qnil);
}


/**
 * Like rm_gvl_offload_image_replacing, for a call that reads a scratch image
 * the caller destroys afterwards. If the call is unwound, the scratch image is
 * destroyed as well.
 *
 * No Ruby usage (internal function)
 *
 * @param fp the function
 * @param args its argument struct
 * @param obj the Ruby object whose image the call uses
 * @param exception the ExceptionInfo passed to the call, may be NULL
 * @param scratch the scratch image, may be NULL
 * @param replace true if the new image replaces the image of obj
 * @return the new image
 */
Image *
rm_gvl_offload_image_and_destroy(gvl_function_t *fp, void *args, VALUE obj, ExceptionInfo *exception,
                                 Image *scratch, bool replace)
{
    offload_cleanup_t cleanup = { OffloadResultImage, exception, scratch, NULL, UndefinedChannel };

    return (Image *)offload(fp, args, obj, replace ? OffloadUpdate : OffloadRead, &cleanup, Qnil);
}


/**
 * Run an ImageMagick function that reads the image of obj and changes a copy
 * of it, letting a Fiber scheduler offload it. If the call is unwound, the
 * copy and exception are released.
 *
 * No Ruby usage (internal function)
 *
 * @param fp the function
 * @param args its argument struct
 * @param obj the Ruby object whose image the call uses
 * @param exception the ExceptionInfo passed to the call, may be NULL
 * @param image the copy
 * @return the result of the call
 */
void *
rm_gvl_offload_call(gvl_function_t *fp, void *args, VALUE obj, ExceptionInfo *exception, Image *image)
{
    offload_cleanup_t cleanup = { OffloadResultIgnored, exception, image, NULL, UndefinedChannel };

    return offload(fp, args, obj, OffloadRead, &cleanup, Qnil);
}


/**
 * Run an ImageMagick function that changes the image of obj, letting a Fiber
 * scheduler offload it. If the call is unwound, the exception is released.
 *
 * No Ruby usage (internal function)
 *
 * @param fp the function
 * @param args its argument struct
 * @param obj the Ruby object whose image the call changes
 * @param exception the ExceptionInfo passed to the call, may be NULL
 * @param dependency another Ruby object that the call reads, or nil
 * @return the result of the call
 */
void *
rm_gvl_offload_update(gvl_function_t *fp, void *args, VALUE obj, ExceptionInfo *exception, VALUE dependency)
{
    offload_cleanup_t cleanup = { OffloadResultIgnored, exception, NULL, NULL, UndefinedChannel };

    return offload(fp, args, obj, OffloadUpdate, &cleanup, dependency);
}


/**
 * Run ImageToBlob or a similar function that returns memory the caller frees
 * with magick_free, letting a Fiber scheduler offload it. The call changes the
 * image of obj. If the call is unwound, the memory and exception are released.
 *
 * No Ruby usage (internal function)
 *
 * @param fp the function
 * @param args its argument struct
 * @param obj the Ruby object whose image the call uses
 * @param exception the ExceptionInfo passed to the call, may be NULL
 * @param dependency another Ruby object that the call reads, or nil
 * @return the result of the call
 */
void *
rm_gvl_offload_blob(gvl_function_t *fp, void *args, VALUE obj, ExceptionInfo *exception, VALUE dependency)
{
    offload_cleanup_t cleanup = { OffloadResultMemory, exception, NULL, NULL, UndefinedChannel };

    return offload(fp, args, obj, OffloadUpdate, &cleanup, dependency);
}


#if defined(IMAGEMAGICK_7)
/**
 * Like rm_gvl_offload_image, for a call made while the channel mask of the
 * image of obj is changed. If the call is unwound, the channel mask is
 * restored as well.
 *
 * No Ruby usage (internal function)
 *
 * @param fp the function
 * @param args its argument struct
 * @param obj the Ruby object whose image the call uses
 * @param exception the ExceptionInfo passed to the call, may be NULL
 * @param masked_image the image whose channel mask was changed
 * @param channel_mask its channel mask before the change
 * @param dependency another Ruby object that the call reads, or nil
 * @return the new image
 */
Image *
rm_gvl_offload_masked_image(gvl_function_t *fp, void *args, VALUE obj, ExceptionInfo *exception,
                            Image *masked_image, ChannelType channel_mask, VALUE dependency)
{
    offload_cleanup_t cleanup = { OffloadResultImage, exception, NULL, masked_image, channel_mask };

    return (Image *)offload(fp, args, obj, OffloadUpdate, &cleanup, dependency);
}
#endif


#if defined(RMAGICK_OFFLOAD_SAFE)
typedef struct
{
    void *key;
    OffloadMode mode;
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
#endif

static void
release_exception(void *ptr, intptr_t arg ATTRIBUTE_UNUSED)
{
    DestroyExceptionInfo((ExceptionInfo *)ptr);
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
    : fp(fp), args(args), nobjects(0), ncleanups(0), result_type(ResultIgnored)
{
}


rm_gvl_call &
rm_gvl_call::add_object(VALUE obj, bool update, bool each)
{
    if (nobjects == MaxObjects)
    {
        rb_bug("too many objects for an offloaded call");
    }
    objects[nobjects].obj = obj;
    objects[nobjects].update = update;
    objects[nobjects].each = each;
    nobjects++;
    return *this;
}


rm_gvl_call &
rm_gvl_call::add_cleanup(void (*release)(void *, intptr_t), void *ptr, intptr_t arg)
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
 * change or destroy it while the call is in flight.
 *
 * @param obj an Image, Info or KernelInfo
 * @return self
 */
rm_gvl_call &
rm_gvl_call::read(VALUE obj)
{
    return add_object(obj, false, false);
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
    return add_object(obj, true, false);
}


/**
 * The call reads every object in the array, such as the images of an ImageList.
 *
 * @param ary the array
 * @return self
 */
rm_gvl_call &
rm_gvl_call::read_each(VALUE ary)
{
    return add_object(ary, false, true);
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
    return add_cleanup(release_exception, exception, 0);
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
    return add_cleanup(destroy_image, image, 0);
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
    return add_cleanup(split_images, images, 0);
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
    return add_cleanup(restore_channel_mask, image, (intptr_t)channel_mask);
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
    if (offload_p())
    {
        offload_call_t call = { fp, args, NULL };
        offload_mark_t *marks;
        VALUE marks_buffer;
        long count = 0, nmarks = 0, nupdates;
        int tag;

        for (int i = 0; i < nobjects; i++)
        {
            count += objects[i].each ? RARRAY_LEN(objects[i].obj) : 1;
        }
        marks = ALLOCV_N(offload_mark_t, marks_buffer, count);

        // An object that the call both reads and changes is marked as changed.
        for (int i = 0; i < nobjects; i++)
        {
            void *key = objects[i].update ? offload_key(objects[i].obj) : NULL;
            if (key && !marked(marks, nmarks, key))
            {
                marks[nmarks].key = key;
                marks[nmarks].mode = OffloadUpdate;
                nmarks++;
            }
        }
        nupdates = nmarks;
        for (int i = 0; i < nobjects; i++)
        {
            long len = objects[i].each ? RARRAY_LEN(objects[i].obj) : 1;

            if (objects[i].update)
            {
                continue;
            }
            for (long j = 0; j < len; j++)
            {
                void *key = offload_key(objects[i].each ? rb_ary_entry(objects[i].obj, j) : objects[i].obj);
                if (key && !marked(marks, nupdates, key))
                {
                    marks[nmarks].key = key;
                    marks[nmarks].mode = OffloadRead;
                    nmarks++;
                }
            }
        }

        for (long i = 0; i < nmarks; i++)
        {
            st_data_t state = offload_state(marks[i].key);
            if (state == OFFLOAD_UPDATING || (marks[i].mode == OffloadUpdate && state != 0))
            {
                ALLOCV_END(marks_buffer);
                unwind(type, NULL);
                raise_in_use();
            }
        }
        for (long i = 0; i < nmarks; i++)
        {
            offload_begin(marks[i].key, marks[i].mode);
        }

        rb_protect(offload_call, (VALUE)&call, &tag);

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

        return call.result;
    }
#endif

    return CALL_FUNC_WITHOUT_GVL(fp, args);
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

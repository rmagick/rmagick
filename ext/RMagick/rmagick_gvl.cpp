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
#include <cstddef>
#if defined(HAVE_WORKING_FORK)
#include <pthread.h>
#endif
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
 *    suspended while it holds a pointer that another fiber could free. An
 *    Image, Info, KernelInfo, Draw or Montage keeps this state itself, so a
 *    call in another Ractor that shares a frozen object sees it too.
 *
 * ImageMagick reads some images through a working area of the pixel cache
 * that every thread outside OpenMP shares, so while an offloaded call uses an
 * image, no other call can use the image. No two Image objects share a pixel
 * cache: an Image object takes one of its own, and a copy that RMagick makes
 * for one call shares it only with the image that the call marks. A call that
 * stays on its thread does not mark the image, so an image must not be used
 * by two threads without a scheduler at once. RMagick itself reads and writes
 * pixels through a cache view of its own.
 *
 * The child of a fork keeps none of the workers of the parent, so it drops
 * the marks of every fiber but the one that forked, whose calls go on in the
 * child, and changes back what the dropped calls changed for themselves, such
 * as a channel mask or the links of a list. A dropped call that is resumed
 * there raises instead of running. An image that a call was changing at the
 * fork is in an undefined state in the child. The state of an object holds
 * the fork generation it was taken in, so the child ignores the marks of the
 * calls in other Ractors without finding them. Those calls change only
 * objects that are not shareable, which the child cannot reach.
 *
 * Some cases are not handled. A scheduler must resume a fiber that waits in a
 * call: a fiber collected while it waits leaves its marks behind, and the next
 * fork changes back objects that may be gone. A worker that holds a lock of
 * ImageMagick at the fork can leave the cleanup of a dropped call in the child
 * waiting for good.
 *
 * Without a scheduler that offloads, or on Ruby before 4.0, rm_gvl_call runs
 * the function with rb_thread_call_without_gvl. An interrupt that arrives
 * during the function, such as Thread#raise or Timeout, is raised after the
 * function returns, so what the caller registered is released then too.
 * Interrupts are deferred until then because, where ImageMagick allocates
 * with xmalloc (Magick::MANAGED_MEMORY without malloc_usable_size or a similar
 * function), a GC that xmalloc starts in the function takes the GVL back and
 * would raise them through ImageMagick. An exception raised by a trap handler
 * there is not deferred.
 */

typedef enum
{
    OffloadRead,
    OffloadUpdate
} OffloadMode;

struct offload_frame;

typedef struct
{
    gvl_function_t *fp;
    void *args;
    void *result;
    struct offload_frame *frame;
    bool started;
    bool done;
} offload_call_t;

#if defined(RMAGICK_OFFLOAD_SAFE)
static bool frame_dropped(const struct offload_frame *frame);
#endif

// Stores the result here rather than relying on the return value of rb_nogvl
// or rb_thread_call_without_gvl, which is lost when an exception is raised
// into the calling fiber after the function returns.
static void *
offload_run(void *arg)
{
    offload_call_t *call = (offload_call_t *)arg;

#if defined(RMAGICK_OFFLOAD_SAFE)
    // The fiber of a call that a fork dropped in the child resumed there
    if (call->frame && frame_dropped(call->frame))
    {
        return NULL;
    }
#endif
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

static void raise_in_use(void) ATTRIBUTE_NORETURN;

static rb_ractor_local_key_t offloaded_key;

// Marks of the calls in flight in all Ractors, so that a call that stays on
// its thread checks its images only when there are some
static std::atomic<unsigned int> offloads_in_flight(0);

// Forks seen by this process; a state from an earlier fork is free
static unsigned int fork_generation;

// The state of an object holds the fork generation above the number of calls
// that read it, or STATE_UPDATING
#define STATE_UPDATING UINT_MAX

// A mark on the offload state of an object
typedef struct
{
    rm_offload_state_t *state;
    OffloadMode mode;
    bool image;
} offload_mark_t;

// A release that changes back an object that the caller passed in
typedef struct
{
    void (*release)(void *, intptr_t);
    void *ptr;
    intptr_t arg;
} offload_restore_t;

#define OFFLOAD_MAX_RESTORES 4

static size_t
frame_align(size_t size)
{
    const size_t align = alignof(std::max_align_t);

    return (size + align - 1) / align * align;
}

// A call that has marked its objects, with the marks behind it
typedef struct offload_frame
{
    offload_mark_t *marks;
    long nmarks;
    offload_restore_t restores[OFFLOAD_MAX_RESTORES];
    int nrestores;
    VALUE thread;
    VALUE fiber;
    bool linked;
    struct offload_frame *prev;
    struct offload_frame *next;
} offload_frame_t;

// The calls in flight in a Ractor
typedef struct offloaded
{
    offload_frame_t *frames;
} offloaded_t;

// The entry of the main Ractor, the only one that can fork
static offloaded_t *main_entry;

static void
offloaded_free(void *ptr)
{
    xfree(ptr);
}

static const struct rb_ractor_local_storage_type offloaded_type = { NULL, offloaded_free };

// The number of calls that read an object, or STATE_UPDATING
static unsigned int
state_count(uint64_t value)
{
    if ((unsigned int)(value >> 32) != fork_generation)
    {
        return 0;
    }
    return (unsigned int)value;
}

static uint64_t
state_value(unsigned int count)
{
    return ((uint64_t)fork_generation << 32) | count;
}

// Take a state for a call: a call reads an object that other calls only read,
// and changes one that no call uses. A call that uses an image is the only one.
static bool
state_acquire(rm_offload_state_t *state, OffloadMode mode, bool image)
{
    uint64_t value = state->load(std::memory_order_relaxed);

    while (true)
    {
        unsigned int count = state_count(value);

        if (count == STATE_UPDATING || ((mode == OffloadUpdate || image) && count != 0))
        {
            return false;
        }
        if (state->compare_exchange_weak(value, state_value(mode == OffloadUpdate ? STATE_UPDATING : count + 1), std::memory_order_acq_rel))
        {
            return true;
        }
    }
}

static void
state_release(rm_offload_state_t *state, OffloadMode mode)
{
    if (mode == OffloadUpdate)
    {
        state->store(0, std::memory_order_release);
    }
    else
    {
        state->fetch_sub(1, std::memory_order_release);
    }
}

static offloaded_t *
offloaded_entry(void)
{
    offloaded_t *entry = (offloaded_t *)rb_ractor_local_storage_ptr(offloaded_key);

    if (!entry)
    {
        entry = ALLOC(offloaded_t);
        entry->frames = NULL;
        rb_ractor_local_storage_ptr_set(offloaded_key, entry);
    }
    return entry;
}

static void
frame_push(offloaded_t *entry, offload_frame_t *frame)
{
    frame->prev = NULL;
    frame->next = entry->frames;
    if (entry->frames)
    {
        entry->frames->prev = frame;
    }
    entry->frames = frame;
    frame->linked = true;
}

static bool
frame_dropped(const offload_frame_t *frame)
{
    return !frame->linked;
}

static void
frame_remove(offloaded_t *entry, offload_frame_t *frame)
{
    if (frame->prev)
    {
        frame->prev->next = frame->next;
    }
    else
    {
        entry->frames = frame->next;
    }
    if (frame->next)
    {
        frame->next->prev = frame->prev;
    }
    frame->linked = false;
}

#if defined(HAVE_WORKING_FORK)
// The fiber that forks, noted before the fork, and whether it holds the GVL
static thread_local VALUE fork_fiber;
static thread_local bool fork_with_gvl;

// rb_fiber_current allocates the object of a root fiber on its first call,
// which a frame on the thread rules out.
static void
atfork_prepare(void)
{
    VALUE thread;

    fork_fiber = 0;
    fork_with_gvl = ruby_thread_has_gvl_p() && rb_ractor_local_storage_ptr(offloaded_key) == main_entry;
    if (!fork_with_gvl)
    {
        return;
    }
    thread = rb_thread_current();
    for (offload_frame_t *frame = main_entry->frames; frame; frame = frame->next)
    {
        if (frame->thread == thread)
        {
            fork_fiber = rb_fiber_current();
            break;
        }
    }
}

// Runs in the child before Ruby does. A thread without the GVL, such as a delegate of ImageMagick, forks to exec,
// and the list may be changing under it. The calls of the other fibers never
// run in the child, so the objects they changed for the call are changed back
// while nothing in the child can have destroyed them yet. The new generation
// frees every state, and the calls that go on take theirs again.
static void
atfork_child(void)
{
    unsigned int count = 0;
    offload_frame_t *next;

    if (!fork_with_gvl)
    {
        return;
    }
    fork_generation++;
    for (offload_frame_t *frame = main_entry->frames; frame; frame = next)
    {
        next = frame->next;
        if (frame->fiber == fork_fiber)
        {
            for (long i = 0; i < frame->nmarks; i++)
            {
                state_acquire(frame->marks[i].state, frame->marks[i].mode, false);
            }
            count += (unsigned int)frame->nmarks;
            continue;
        }
        for (int i = 0; i < frame->nrestores; i++)
        {
            frame->restores[i].release(frame->restores[i].ptr, frame->restores[i].arg);
        }
        frame_remove(main_entry, frame);
    }
    offloads_in_flight.store(count, std::memory_order_relaxed);
}
#endif

static void
raise_in_use(void)
{
    rb_raise(rb_eRuntimeError, "object is in use by another fiber");
}

// The offload state of an Image, Info, KernelInfo, Draw or Montage, or NULL for
// another object, which is not tracked
static rm_offload_state_t *
object_state(VALUE obj)
{
    const rb_data_type_t *type;

    if (RB_SPECIAL_CONST_P(obj) || !RB_TYPE_P(obj, T_DATA) || !RTYPEDDATA_P(obj))
    {
        return NULL;
    }
    type = RTYPEDDATA_TYPE(obj);
    if (type == &rm_image_data_type)
    {
        return &((MagickImage *)RTYPEDDATA_DATA(obj))->offload;
    }
    if (type == &rm_info_data_type)
    {
        return &((MagickImageInfo *)RTYPEDDATA_DATA(obj))->offload;
    }
    if (type == &rm_kernel_info_data_type)
    {
        return &((MagickKernelInfo *)RTYPEDDATA_DATA(obj))->offload;
    }
    if (type == &rm_draw_data_type)
    {
        return &((MagickDraw *)RTYPEDDATA_DATA(obj))->offload;
    }
    if (type == &rm_montage_data_type)
    {
        return &((MagickMontage *)RTYPEDDATA_DATA(obj))->offload;
    }
    return NULL;
}

// Number of calls in flight that read obj, or STATE_UPDATING
static unsigned int
object_offload_state(VALUE obj)
{
    rm_offload_state_t *state = object_state(obj);

    return state ? state_count(state->load(std::memory_order_acquire)) : 0;
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
    main_entry = offloaded_entry();
#if defined(HAVE_WORKING_FORK)
    int err = pthread_atfork(atfork_prepare, NULL, atfork_child);

    if (err)
    {
        rb_syserr_fail(err, "pthread_atfork");
    }
#endif
#endif
}


/**
 * Raise if an offloaded call is changing the object.
 *
 * No Ruby usage (internal function)
 *
 * @param obj an Image, Info, KernelInfo, Draw or Montage
 */
void
rm_gvl_check_readable(VALUE obj)
{
#if defined(RMAGICK_OFFLOAD_SAFE)
    if (object_offload_state(obj) == STATE_UPDATING)
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
 * @param obj an Image, Info, KernelInfo, Draw or Montage
 * @return true if a call reads or changes the object
 */
bool
rm_gvl_in_use(VALUE obj)
{
#if defined(RMAGICK_OFFLOAD_SAFE)
    return object_offload_state(obj) != 0;
#else
    return false;
#endif
}


/**
 * Raise if an offloaded call is using the object.
 *
 * No Ruby usage (internal function)
 *
 * @param obj an Image, Info, KernelInfo, Draw or Montage
 */
void
rm_gvl_check_writable(VALUE obj)
{
#if defined(RMAGICK_OFFLOAD_SAFE)
    if (rm_gvl_in_use(obj))
    {
        raise_in_use();
    }
#endif
}


#if defined(RMAGICK_OFFLOAD_SAFE)
// Mark an object registered with read() or update(), once for each call
static void
add_object_mark(offload_mark_t *marks, long *nmarks, VALUE obj, OffloadMode mode)
{
    rm_offload_state_t *state = object_state(obj);

    if (!state)
    {
        return;
    }
    for (long i = 0; i < *nmarks; i++)
    {
        if (marks[i].state == state)
        {
            return;
        }
    }
    marks[*nmarks].state = state;
    marks[*nmarks].mode = mode;
    marks[*nmarks].image = RTYPEDDATA_TYPE(obj) == &rm_image_data_type;
    (*nmarks)++;
}

static bool
mark_in_use(const offload_mark_t *mark)
{
    unsigned int count = state_count(mark->state->load(std::memory_order_acquire));

    if (mark->image)
    {
        return count != 0;
    }
    return count == STATE_UPDATING || (mark->mode == OffloadUpdate && count != 0);
}

// Take the marks of a frame and link it, or take none and return false if
// another call holds an object
static bool
frame_acquire(offloaded_t *entry, offload_frame_t *frame)
{
    for (long i = 0; i < frame->nmarks; i++)
    {
        if (!state_acquire(frame->marks[i].state, frame->marks[i].mode, frame->marks[i].image))
        {
            while (i-- > 0)
            {
                state_release(frame->marks[i].state, frame->marks[i].mode);
            }
            return false;
        }
    }
    frame_push(entry, frame);
    return true;
}

// Release the marks of a frame and unlink it, or return false if a fork
// dropped it in the child
static bool
frame_release(offloaded_t *entry, offload_frame_t *frame)
{
    if (!frame->linked)
    {
        return false;
    }
    for (long i = 0; i < frame->nmarks; i++)
    {
        state_release(frame->marks[i].state, frame->marks[i].mode);
    }
    frame_remove(entry, frame);
    return true;
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
    return add_cleanup(release, ptr, arg, false);
}


rm_gvl_call &
rm_gvl_call::add_cleanup(void (*release)(void *, intptr_t), void *ptr, intptr_t arg, bool restore)
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
    cleanups[ncleanups].restore = restore;
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
 * A copy of the array keeps the objects alive while the call is in flight,
 * even if another fiber removes them from the array.
 *
 * @param ary the array
 * @return self
 */
rm_gvl_call &
rm_gvl_call::read_each(VALUE ary)
{
    return add_object(rb_ary_dup(ary), false, true);
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
    return add_object(rb_ary_dup(ary), true, true);
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
    return add_cleanup(split_images, images, 0, true);
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
    return add_cleanup(restore_channel_mask, image, (intptr_t)channel_mask, true);
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


/**
 * Release what the caller registered, and the result.
 *
 * No Ruby usage (internal function)
 *
 * @param type how to free the result
 * @param result the result, or NULL
 * @param abandoned whether the child of a fork dropped the call, which
 *   changed back the objects that the caller passed in at the fork
 */
void
rm_gvl_call::unwind(ResultType type, void *result, bool abandoned)
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
        if (cleanups[i].restore && abandoned)
        {
            continue;
        }
        cleanups[i].release(cleanups[i].ptr, cleanups[i].arg);
    }
}


void *
rm_gvl_call::call(ResultType type)
{
    void *result;

    result = call_body(type);
    rm_gc_continue();
    return result;
}

void *
rm_gvl_call::call_body(ResultType type)
{
#if defined(RMAGICK_OFFLOAD_SAFE)
    bool offload = !keep && offload_p();

    if (offload || offloads_in_flight.load(std::memory_order_relaxed) != 0)
    {
        offload_call_t call = { fp, args, NULL, NULL, false, false };
        VALUE fiber = offload ? rb_fiber_current() : 0;
        offload_frame_t *frame = NULL;
        offloaded_t *entry;
        offload_mark_t *marks;
        VALUE marks_buffer = 0;
        long count = 0, nmarks = 0;
        bool dropped;
        int tag;

        for (int i = 0; i < nobjects; i++)
        {
            count += objects[i].each ? RARRAY_LEN(objects[i].obj) : 1;
        }
        if (offload)
        {
            frame = (offload_frame_t *)xmalloc(frame_align(sizeof(offload_frame_t)) + count * sizeof(offload_mark_t));
            marks = (offload_mark_t *)((char *)frame + frame_align(sizeof(offload_frame_t)));
        }
        else
        {
            marks = ALLOCV_N(offload_mark_t, marks_buffer, count);
        }

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
                    add_object_mark(marks, &nmarks, objects[i].each ? rb_ary_entry(objects[i].obj, j) : objects[i].obj, mode);
                }
            }
        }

        for (long i = 0; i < nmarks; i++)
        {
            if ((offload || marks[i].image) && mark_in_use(&marks[i]))
            {
                if (frame)
                {
                    xfree(frame);
                }
                else
                {
                    ALLOCV_END(marks_buffer);
                }
                unwind(type, NULL);
                raise_in_use();
            }
        }
        if (!offload)
        {
            ALLOCV_END(marks_buffer);
            return call_here(type);
        }

        static_assert(MaxCleanups <= OFFLOAD_MAX_RESTORES, "a frame holds every cleanup that restores");

        frame->marks = marks;
        frame->nmarks = nmarks;
        frame->nrestores = 0;
        for (int i = 0; i < ncleanups; i++)
        {
            if (cleanups[i].restore)
            {
                offload_restore_t restore = { cleanups[i].release, cleanups[i].ptr, cleanups[i].arg };

                frame->restores[frame->nrestores++] = restore;
            }
        }
        frame->thread = rb_thread_current();
        frame->fiber = fiber;
        call.frame = frame;

        // A call in another Ractor can take an object between the check above
        // and here, so the marks are taken one by one.
        entry = offloaded_entry();
        offloads_in_flight.fetch_add((unsigned int)nmarks, std::memory_order_relaxed);
        if (!frame_acquire(entry, frame))
        {
            offloads_in_flight.fetch_sub((unsigned int)nmarks, std::memory_order_relaxed);
            xfree(frame);
            unwind(type, NULL);
            raise_in_use();
        }

        rb_protect(offload_call, (VALUE)&call, &tag);
        if (!tag && !call.started && frame->linked)
        {
            rb_protect(offload_call, (VALUE)&call, &tag);
        }

        dropped = !frame_release(offloaded_entry(), frame);
        if (!dropped)
        {
            offloads_in_flight.fetch_sub((unsigned int)nmarks, std::memory_order_relaxed);
        }
        xfree(frame);
        if (dropped)
        {
            // The worker may have finished before the fork
            unwind(type, call.done ? call.result : NULL, true);
            if (tag)
            {
                rb_jump_tag(tag);
            }
            rb_raise(rb_eRuntimeError, "call abandoned in the child of a fork");
        }
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
    offload_call_t call = { fp, args, NULL, NULL, false, false };
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

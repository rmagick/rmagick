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
 * 2. Other fibers on the same thread run while the call is in flight. They
 *    could destroy, replace or modify the image the worker is using. While a
 *    call is in flight on an image, every method called on that image waits
 *    for it at entry, in rm_check_destroyed, before it fetches the Image
 *    pointer; so do Image#destroy!, #marshal_load and #dup. Draw and ImageList
 *    entry points wait for their inputs before fetching any Image pointers.
 *    Mutable Info and KernelInfo inputs share the operation's lock. A wait is a
 *    point where other fibers run, so it is never done later than that: an
 *    image fetched as a second argument (composite, clut)
 *    does not wait, and offload() itself does not wait either. If a call is
 *    already in flight on the object when offload() is reached, which needs
 *    a suspension point between entry and the call, such as a Ruby block,
 *    the call runs on the calling thread instead.
 *
 * The bookkeeping is per Ractor. Ruby objects never cross Ractors, so a call
 * in flight in one Ractor never has to be waited for in another.
 *
 * Without a scheduler that offloads, or on Ruby before 4.0, these functions
 * are CALL_FUNC_WITHOUT_GVL.
 */

#if defined(RMAGICK_OFFLOAD_SAFE)
typedef struct
{
    st_table *locks;   // object => [Mutex, scheduler waiters, owner thread]
    int count;
} offload_state_t;

static rb_ractor_local_key_t offload_state_key;

static void
offload_state_free(void *ptr)
{
    offload_state_t *state = (offload_state_t *)ptr;

    if (state->locks)
    {
        st_free_table(state->locks);
    }
    xfree(state);
}

static const struct rb_ractor_local_storage_type offload_state_type = { NULL, offload_state_free };

static offload_state_t *
offload_state(int create)
{
    offload_state_t *state = (offload_state_t *)rb_ractor_local_storage_ptr(offload_state_key);

    if (!state && create)
    {
        state = ZALLOC(offload_state_t);
        state->locks = st_init_numtable();
        rb_ractor_local_storage_ptr_set(offload_state_key, state);
    }
    return state;
}

typedef struct
{
    gvl_function_t *fp;
    void *args;
    void *result;
} offload_call_t;

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

typedef struct
{
    VALUE lock;
    VALUE waiter;
} offload_wait_t;

static VALUE
offload_wait(VALUE arg)
{
    offload_wait_t *wait = (offload_wait_t *)arg;
    VALUE scheduler = rb_ary_entry(wait->waiter, 0);

    rb_ary_push(rb_ary_entry(wait->lock, 1), wait->waiter);
    return rb_fiber_scheduler_block(scheduler, wait->lock, Qnil);
}

static VALUE
offload_wait_ensure(VALUE arg)
{
    offload_wait_t *wait = (offload_wait_t *)arg;
    VALUE waiters = rb_ary_entry(wait->lock, 1);

    for (long i = 0; i < RARRAY_LEN(waiters); i++)
    {
        if (rb_ary_entry(waiters, i) == wait->waiter)
        {
            rb_ary_delete_at(waiters, i);
            break;
        }
    }
    return Qnil;
}
#endif


/**
 * Set up the offload bookkeeping. Called once, when the extension is loaded.
 *
 * No Ruby usage (internal function)
 */
void
rm_gvl_init_offload(void)
{
#if defined(RMAGICK_OFFLOAD_SAFE)
    offload_state_key = rb_ractor_local_storage_ptr_newkey(&offload_state_type);
#endif
}


/**
 * Wait until no other fiber has an offloaded call in flight on the object.
 * Other fibers run while this waits, so call it before fetching any Image
 * pointer the caller relies on.
 *
 * No Ruby usage (internal function)
 *
 * @param obj the object, usually an Image
 * @return whether the wait let other fibers run
 */
int
rm_gvl_wait_for_offload(VALUE obj)
{
    int waited = 0;
#if defined(RMAGICK_OFFLOAD_SAFE)
    offload_state_t *state = offload_state(0);
    st_data_t entry;

    while (state && state->count > 0 && st_lookup(state->locks, (st_data_t)obj, &entry))
    {
        VALUE lock = (VALUE)entry;
        VALUE scheduler = rb_fiber_scheduler_get();

        waited = 1;
        if (!NIL_P(scheduler) && NIL_P(rb_fiber_scheduler_current())
            && rb_ary_entry(lock, 2) == rb_thread_current())
        {
            // A blocking fiber cannot lock a mutex owned by a suspended fiber
            // on the same thread. Explicitly yield to its scheduler so the
            // owner can finish all of its native pointer bookkeeping first.
            offload_wait_t wait = { lock, rb_ary_new_from_args(2, scheduler, rb_fiber_current()) };
            rb_ensure(offload_wait, (VALUE)&wait, offload_wait_ensure, (VALUE)&wait);
        }
        else
        {
            VALUE mutex = rb_ary_entry(lock, 0);
            rb_mutex_lock(mutex);
            rb_mutex_unlock(mutex);
        }
        RB_GC_GUARD(lock);
    }
#else
    (void)obj;
#endif
    return waited;
}


typedef enum
{
    OffloadResultIgnored,
    OffloadResultImage,
    OffloadResultMemory
} OffloadResultType;


#if defined(RMAGICK_OFFLOAD_SAFE)
// Release what the caller would have released after the call.
static void
offload_release(OffloadResultType result_type, void *result, ExceptionInfo *exception, Image *image
#if defined(IMAGEMAGICK_7)
                , Image *masked_image, ChannelType channel_mask
#endif
                )
{
    switch (result_type)
    {
        case OffloadResultImage:
            if (result)
            {
                DestroyImageList((Image *)result);
            }
            break;
        case OffloadResultMemory:
            if (result)
            {
                magick_free(result);
            }
            break;
        case OffloadResultIgnored:
            break;
    }
    if (image)
    {
        DestroyImageList(image);
    }
#if defined(IMAGEMAGICK_7)
    if (masked_image)
    {
        SetPixelChannelMask(masked_image, channel_mask);
    }
#endif
    if (exception)
    {
        DestroyExceptionInfo(exception);
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
 * @param obj the Ruby object whose image the call uses
 * @param result_type what to do with the result if the call is unwound
 * @param exception released if the call is unwound, may be NULL
 * @param image destroyed if the call is unwound, may be NULL
 * @param masked_image image whose channel mask is restored if the call is unwound (ImageMagick 7)
 * @param channel_mask the channel mask to restore
 * @param dependency another Ruby object used by the call, or nil
 * @return the result of fp
 */
static void *
offload(gvl_function_t *fp, void *args, VALUE obj, OffloadResultType result_type,
        ExceptionInfo *exception, Image *image
#if defined(IMAGEMAGICK_7)
        , Image *masked_image, ChannelType channel_mask
#endif
        , VALUE dependency = Qnil
        )
{
#if defined(RMAGICK_OFFLOAD_SAFE)
    if (offload_p())
    {
        offload_call_t call = { fp, args, NULL };
        offload_state_t *state;
        VALUE mutex, lock, waiters;
        st_data_t key = (st_data_t)obj;
        st_data_t dependency_key = (st_data_t)dependency;
        int tag;

        state = offload_state(1);
        if (st_lookup(state->locks, key, NULL)
            || (!NIL_P(dependency) && st_lookup(state->locks, dependency_key, NULL)))
        {
            // Another fiber has a call in flight on this object, and the
            // caller has already fetched its Image pointer, so waiting here
            // is not safe. Keep the thread instead.
            return CALL_FUNC_WITHOUT_GVL(fp, args);
        }

        mutex = rb_mutex_new();
        waiters = rb_ary_new();
        lock = rb_ary_new_from_args(3, mutex, waiters, rb_thread_current());
        rb_mutex_lock(mutex);
        st_insert(state->locks, key, (st_data_t)lock);
        if (!NIL_P(dependency))
        {
            st_insert(state->locks, dependency_key, (st_data_t)lock);
        }
        state->count++;

        rb_protect(offload_call, (VALUE)&call, &tag);

        st_delete(state->locks, &key, NULL);
        if (!NIL_P(dependency))
        {
            st_delete(state->locks, &dependency_key, NULL);
        }
        state->count--;
        rb_mutex_unlock(mutex);
        while (RARRAY_LEN(waiters) > 0)
        {
            VALUE waiter = rb_ary_pop(waiters);
            rb_fiber_scheduler_unblock(rb_ary_entry(waiter, 0), lock, rb_ary_entry(waiter, 1));
        }
        RB_GC_GUARD(lock);

        if (tag)
        {
            // The scheduler raised into this fiber after the worker finished.
            offload_release(result_type, call.result, exception, image
#if defined(IMAGEMAGICK_7)
                            , masked_image, channel_mask
#endif
                            );
            rb_jump_tag(tag);
        }

        return call.result;
    }
#else
    (void)obj;
    (void)result_type;
    (void)exception;
    (void)image;
    (void)dependency;
#if defined(IMAGEMAGICK_7)
    (void)masked_image;
    (void)channel_mask;
#endif
#endif

    return CALL_FUNC_WITHOUT_GVL(fp, args);
}


/**
 * Run an ImageMagick function that returns a new image, letting a Fiber
 * scheduler offload it. If the call is unwound, the new image and exception
 * are released.
 *
 * No Ruby usage (internal function)
 *
 * @param fp the function
 * @param args its argument struct
 * @param obj the Ruby object whose image the call uses
 * @param exception the ExceptionInfo passed to the call, may be NULL
 * @param dependency another Ruby object used by the call, or nil
 * @return the new image
 */
Image *
rm_gvl_offload_image(gvl_function_t *fp, void *args, VALUE obj, ExceptionInfo *exception, VALUE dependency)
{
    return (Image *)offload(fp, args, obj, OffloadResultImage, exception, NULL
#if defined(IMAGEMAGICK_7)
                            , NULL, UndefinedChannel
#endif
                            , dependency
                            );
}


/**
 * Like rm_gvl_offload_image, for a call that reads a scratch image the caller
 * destroys afterwards. If the call is unwound, the scratch image is destroyed
 * as well.
 *
 * No Ruby usage (internal function)
 *
 * @param fp the function
 * @param args its argument struct
 * @param obj the Ruby object whose image the call uses
 * @param exception the ExceptionInfo passed to the call, may be NULL
 * @param scratch the scratch image, may be NULL
 * @return the new image
 */
Image *
rm_gvl_offload_image_and_destroy(gvl_function_t *fp, void *args, VALUE obj, ExceptionInfo *exception, Image *scratch)
{
    return (Image *)offload(fp, args, obj, OffloadResultImage, exception, scratch
#if defined(IMAGEMAGICK_7)
                            , NULL, UndefinedChannel
#endif
                            );
}


/**
 * Run an ImageMagick function whose result needs no release, letting a Fiber
 * scheduler offload it. If the call is unwound, the image and exception are
 * released.
 *
 * No Ruby usage (internal function)
 *
 * @param fp the function
 * @param args its argument struct
 * @param obj the Ruby object whose image the call uses
 * @param exception the ExceptionInfo passed to the call, may be NULL
 * @param image an image the caller would destroy on error, may be NULL
 * @param dependency another Ruby object used by the call, or nil
 * @return the result of the call
 */
void *
rm_gvl_offload_call(gvl_function_t *fp, void *args, VALUE obj, ExceptionInfo *exception, Image *image, VALUE dependency)
{
    return offload(fp, args, obj, OffloadResultIgnored, exception, image
#if defined(IMAGEMAGICK_7)
                   , NULL, UndefinedChannel
#endif
                   , dependency
                   );
}


/**
 * Run an ImageMagick function that returns memory the caller frees with
 * magick_free, letting a Fiber scheduler offload it. If the call is unwound,
 * the memory and exception are released.
 *
 * No Ruby usage (internal function)
 *
 * @param fp the function
 * @param args its argument struct
 * @param obj the Ruby object whose image the call uses
 * @param exception the ExceptionInfo passed to the call, may be NULL
 * @param dependency another Ruby object used by the call, or nil
 * @return the result of the call
 */
void *
rm_gvl_offload_blob(gvl_function_t *fp, void *args, VALUE obj, ExceptionInfo *exception, VALUE dependency)
{
    return offload(fp, args, obj, OffloadResultMemory, exception, NULL
#if defined(IMAGEMAGICK_7)
                   , NULL, UndefinedChannel
#endif
                   , dependency
                   );
}


#if defined(IMAGEMAGICK_7)
/**
 * Like rm_gvl_offload_image, for a call made while the channel mask of an image
 * is changed. If the call is unwound, the channel mask is restored as well.
 *
 * No Ruby usage (internal function)
 *
 * @param fp the function
 * @param args its argument struct
 * @param obj the Ruby object whose image the call uses
 * @param exception the ExceptionInfo passed to the call, may be NULL
 * @param masked_image the image whose channel mask was changed
 * @param channel_mask its channel mask before the change
 * @param dependency another Ruby object used by the call, or nil
 * @return the new image
 */
Image *
rm_gvl_offload_masked_image(gvl_function_t *fp, void *args, VALUE obj, ExceptionInfo *exception,
                            Image *masked_image, ChannelType channel_mask, VALUE dependency)
{
    return (Image *)offload(fp, args, obj, OffloadResultImage, exception, NULL, masked_image, channel_mask, dependency);
}
#endif

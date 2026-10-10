/**
 * Offloading GVL-free calls to a Fiber scheduler.
 *
 * Copyright (c) 2009 -      RMagick contributors
 *
 * @file     rmagick_gvl.cpp
 */

#include <mutex>
#include <new>

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
 * image, no other call can use the image or its pixel cache, which clones of
 * the image share. A call that stays on its thread does not mark the image,
 * so an image must not be used by two threads without a scheduler at once.
 * RMagick itself reads and writes pixels through a cache view of its own.
 *
 * The child of a fork keeps none of the workers of the parent, so it drops
 * the marks of every fiber but the one that forked, whose calls go on in the
 * child, and changes back what the dropped calls changed for themselves, such
 * as a channel mask or the links of a list. A dropped call that is resumed
 * there raises instead of running. An image that a call was changing at the
 * fork is in an undefined state in the child.
 *
 * Some cases are not handled. A scheduler must resume a fiber that waits in a
 * call: a fiber collected while it waits leaves its marks behind, and the next
 * fork changes back objects that may be gone. A worker that holds a lock of
 * ImageMagick at the fork can leave the cleanup of a dropped call in the child
 * waiting for good. Draw#annotate changes its text and affine outside
 * rm_gvl_call, so they are changed back only when the call returns.
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

// Value in the table of an object that a call is changing
#define OFFLOAD_UPDATING ((st_data_t)-1)

static void raise_in_use(void) ATTRIBUTE_NORETURN;

static rb_ractor_local_key_t offloaded_key;

// Marks of the calls in flight in all Ractors, to skip the table when there are none
static std::atomic<unsigned int> offloads_in_flight(0);

// Forks seen by this process; a table from an earlier fork is restored before use
static unsigned int fork_generation;

// A mark on the offload state of an object, or on a key in the table
typedef struct
{
    void *key;
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

// Pixel cache of an Image, or data pointer of an object without an offload
// state => number of calls in flight that read it, or OFFLOAD_UPDATING. Each
// Ractor has its own table, so a pixel cache is marked only in the Ractor that
// uses it.
typedef struct offloaded
{
    st_table *table;
    unsigned int generation;
    offload_frame_t *frames;
    // Guards the frames and the marks they hold, so that a fork sees them whole
    std::mutex lock;
    struct offloaded *prev;
    struct offloaded *next;
} offloaded_t;

// The entries of all Ractors
static std::mutex entries_lock;
static offloaded_t *entries;

// The entry of the main Ractor, the only one that can fork
static offloaded_t *main_entry;

static void
offloaded_free(void *ptr)
{
    offloaded_t *entry = (offloaded_t *)ptr;

    {
        std::lock_guard<std::mutex> guard(entries_lock);

        if (entry->prev)
        {
            entry->prev->next = entry->next;
        }
        else
        {
            entries = entry->next;
        }
        if (entry->next)
        {
            entry->next->prev = entry->prev;
        }
    }
    st_free_table(entry->table);
    entry->~offloaded_t();
    xfree(entry);
}

static const struct rb_ractor_local_storage_type offloaded_type = { NULL, offloaded_free };

static void
mark_insert(st_table *table, const void *ptr, OffloadMode mode)
{
    st_data_t state = 0;

    st_lookup(table, (st_data_t)ptr, &state);
    st_insert(table, (st_data_t)ptr, mode == OffloadUpdate ? OFFLOAD_UPDATING : state + 1);
}

static void
mark_remove(st_table *table, const void *ptr)
{
    st_data_t key = (st_data_t)ptr;
    st_data_t state = 0;

    st_lookup(table, key, &state);
    if (state == OFFLOAD_UPDATING || state <= 1)
    {
        st_delete(table, &key, NULL);
    }
    else
    {
        st_insert(table, key, state - 1);
    }
}

// Take a state for a call: a call reads an object that other calls only read,
// and changes one that no call uses. A call that uses an image is the only one.
static bool
state_acquire(rm_offload_state_t *state, OffloadMode mode, bool image)
{
    unsigned int current = state->load(std::memory_order_relaxed);

    while (true)
    {
        if (current == RM_OFFLOAD_UPDATING || ((mode == OffloadUpdate || image) && current != 0))
        {
            return false;
        }
        if (state->compare_exchange_weak(current, mode == OffloadUpdate ? RM_OFFLOAD_UPDATING : current + 1, std::memory_order_acq_rel))
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
        entry = new (xmalloc(sizeof(offloaded_t))) offloaded_t();
        entry->table = st_init_numtable();
        entry->generation = fork_generation;
        entry->frames = NULL;
        rb_ractor_local_storage_ptr_set(offloaded_key, entry);
        {
            std::lock_guard<std::mutex> guard(entries_lock);

            entry->prev = NULL;
            entry->next = entries;
            if (entries)
            {
                entries->prev = entry;
            }
            entries = entry;
        }
    }
    else if (entry->generation != fork_generation)
    {
        st_clear(entry->table);
        entry->generation = fork_generation;
        for (offload_frame_t *frame = entry->frames; frame; frame = frame->next)
        {
            for (long i = 0; i < frame->nmarks; i++)
            {
                if (!frame->marks[i].state)
                {
                    mark_insert(entry->table, frame->marks[i].key, frame->marks[i].mode);
                }
            }
        }
    }
    return entry;
}

static st_table *
offloaded(void)
{
    return offloaded_entry()->table;
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
    entries_lock.lock();
    for (offloaded_t *entry = entries; entry; entry = entry->next)
    {
        entry->lock.lock();
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

static void
unlock_entries(void)
{
    for (offloaded_t *entry = entries; entry; entry = entry->next)
    {
        entry->lock.unlock();
    }
    entries_lock.unlock();
}

static void
atfork_parent(void)
{
    if (fork_with_gvl)
    {
        unlock_entries();
    }
}

// Runs in the child before Ruby does, so it leaves the table to offloaded_entry.
// A thread without the GVL, such as a delegate of ImageMagick, forks to exec,
// and the list may be changing under it. The calls of the other fibers and of
// the other Ractors never run in the child, so the objects they changed for
// the call are changed back while nothing in the child can have destroyed them
// yet.
static void
atfork_child(void)
{
    unsigned int count = 0;
    offload_frame_t *next;

    if (!fork_with_gvl)
    {
        return;
    }
    for (offloaded_t *entry = entries; entry; entry = entry->next)
    {
        for (offload_frame_t *frame = entry->frames; frame; frame = next)
        {
            next = frame->next;
            if (entry == main_entry && frame->fiber == fork_fiber)
            {
                count += (unsigned int)frame->nmarks;
                continue;
            }
            for (int i = 0; i < frame->nrestores; i++)
            {
                frame->restores[i].release(frame->restores[i].ptr, frame->restores[i].arg);
            }
            for (long i = 0; i < frame->nmarks; i++)
            {
                if (frame->marks[i].state)
                {
                    state_release(frame->marks[i].state, frame->marks[i].mode);
                }
            }
            frame_remove(entry, frame);
        }
    }
    offloads_in_flight.store(count, std::memory_order_relaxed);
    fork_generation++;
    unlock_entries();
}
#endif

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

// The offload state of an Image, Info, KernelInfo, Draw or Montage, or NULL for
// another object, which is tracked in the table by its data pointer
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

// Number of calls in flight that read obj, or RM_OFFLOAD_UPDATING
static unsigned int
object_offload_state(VALUE obj)
{
    rm_offload_state_t *state = object_state(obj);

    return state ? state->load(std::memory_order_acquire) : 0;
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
    int err = pthread_atfork(atfork_prepare, atfork_parent, atfork_child);

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
    if (object_offload_state(obj) == RM_OFFLOAD_UPDATING)
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
static bool
marked(const offload_mark_t *marks, long count, const void *key, const rm_offload_state_t *state)
{
    for (long i = 0; i < count; i++)
    {
        if (marks[i].key == key && marks[i].state == state)
        {
            return true;
        }
    }
    return false;
}

static void
add_mark(offload_mark_t *marks, long *nmarks, void *key, rm_offload_state_t *state, OffloadMode mode, bool image)
{
    if ((!key && !state) || marked(marks, *nmarks, key, state))
    {
        return;
    }
    marks[*nmarks].key = key;
    marks[*nmarks].state = state;
    marks[*nmarks].mode = mode;
    marks[*nmarks].image = image;
    (*nmarks)++;
}

// Mark an object registered with read() or update(), and the pixel cache of an
// Image
static void
add_object_marks(offload_mark_t *marks, long *nmarks, VALUE obj, OffloadMode mode)
{
    rm_offload_state_t *state = object_state(obj);
    bool image = state && RTYPEDDATA_TYPE(obj) == &rm_image_data_type;

    add_mark(marks, nmarks, state ? NULL : offload_key(obj), state, mode, image);
    if (image)
    {
        Image *ptr = rm_image_get(obj);

        if (ptr)
        {
            add_mark(marks, nmarks, ptr->cache, NULL, mode, true);
        }
    }
}

static bool
mark_in_use(const offload_mark_t *mark)
{
    unsigned int state;

    if (mark->state)
    {
        state = mark->state->load(std::memory_order_acquire);
    }
    else
    {
        st_data_t table_state = offload_state(mark->key);

        state = table_state == OFFLOAD_UPDATING ? RM_OFFLOAD_UPDATING : (unsigned int)table_state;
    }
    if (mark->image)
    {
        return state != 0;
    }
    return state == RM_OFFLOAD_UPDATING || (mark->mode == OffloadUpdate && state != 0);
}

// Take a mark for a call, or return false if another call holds the object
static bool
mark_acquire(st_table *table, const offload_mark_t *mark)
{
    if (mark->state)
    {
        return state_acquire(mark->state, mark->mode, mark->image);
    }
    if (mark_in_use(mark))
    {
        return false;
    }
    mark_insert(table, mark->key, mark->mode);
    return true;
}

static void
mark_release(st_table *table, const offload_mark_t *mark)
{
    if (mark->state)
    {
        state_release(mark->state, mark->mode);
    }
    else
    {
        mark_remove(table, mark->key);
    }
}

// Take the marks of a frame and link it, or take none and return false if
// another call holds an object. Growing the table can start a GC that waits
// for a fork that waits for the lock, so the table is changed outside it. Only
// this Ractor uses its table, and the child of a fork rebuilds it.
static bool
frame_acquire(offloaded_t *entry, offload_frame_t *frame)
{
    long i, j;

    for (i = 0; i < frame->nmarks; i++)
    {
        if (!frame->marks[i].state && !mark_acquire(entry->table, &frame->marks[i]))
        {
            break;
        }
    }
    if (i == frame->nmarks)
    {
        entry->lock.lock();
        for (j = 0; j < frame->nmarks; j++)
        {
            if (frame->marks[j].state && !mark_acquire(entry->table, &frame->marks[j]))
            {
                break;
            }
        }
        if (j == frame->nmarks)
        {
            frame_push(entry, frame);
            entry->lock.unlock();
            return true;
        }
        while (j-- > 0)
        {
            if (frame->marks[j].state)
            {
                mark_release(entry->table, &frame->marks[j]);
            }
        }
        entry->lock.unlock();
    }
    while (i-- > 0)
    {
        if (!frame->marks[i].state)
        {
            mark_release(entry->table, &frame->marks[i]);
        }
    }
    return false;
}

// Release the marks of a frame and unlink it, or return false if a fork
// dropped it in the child
static bool
frame_release(offloaded_t *entry, offload_frame_t *frame)
{
    entry->lock.lock();
    if (!frame->linked)
    {
        entry->lock.unlock();
        return false;
    }
    for (long i = 0; i < frame->nmarks; i++)
    {
        if (frame->marks[i].state)
        {
            mark_release(entry->table, &frame->marks[i]);
        }
    }
    frame_remove(entry, frame);
    entry->lock.unlock();
    for (long i = 0; i < frame->nmarks; i++)
    {
        if (!frame->marks[i].state)
        {
            mark_release(entry->table, &frame->marks[i]);
        }
    }
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
    return add_cleanup(release, ptr, arg, 0, false);
}


/**
 * Like cleanup, for a release that changes an object the caller passed in
 * back, rather than freeing what the call made.
 *
 * @param release the function
 * @param ptr its first argument
 * @param arg its second argument
 * @param size if not 0, arg points to a value of this size, which an
 *   offloaded call keeps a copy of
 * @return self
 */
rm_gvl_call &
rm_gvl_call::restore(void (*release)(void *, intptr_t), void *ptr, intptr_t arg, size_t size)
{
    return add_cleanup(release, ptr, arg, size, true);
}


rm_gvl_call &
rm_gvl_call::add_cleanup(void (*release)(void *, intptr_t), void *ptr, intptr_t arg, size_t size, bool restore)
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
    cleanups[ncleanups].size = size;
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
    return restore(split_images, images, 0);
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
    return restore(restore_channel_mask, image, (intptr_t)channel_mask);
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
        size_t marks_size, values_size = 0;
        bool dropped;
        int tag;

        for (int i = 0; i < nobjects; i++)
        {
            count += objects[i].each ? RARRAY_LEN(objects[i].obj) : 1;
        }
        marks_size = frame_align(2 * count * sizeof(offload_mark_t));
        if (offload)
        {
            for (int i = 0; i < ncleanups; i++)
            {
                values_size += frame_align(cleanups[i].size);
            }
            frame = (offload_frame_t *)xmalloc(frame_align(sizeof(offload_frame_t)) + marks_size + values_size);
            marks = (offload_mark_t *)((char *)frame + frame_align(sizeof(offload_frame_t)));
        }
        else
        {
            marks = ALLOCV_N(offload_mark_t, marks_buffer, 2 * count);
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
                    add_object_marks(marks, &nmarks, objects[i].each ? rb_ary_entry(objects[i].obj, j) : objects[i].obj, mode);
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

        // The frame keeps a copy of the values to change back, which can be on
        // the stack of a fiber that is gone by the next fork.
        static_assert(MaxCleanups <= OFFLOAD_MAX_RESTORES, "a frame holds every cleanup that restores");
        char *values = (char *)marks + marks_size;

        frame->marks = marks;
        frame->nmarks = nmarks;
        frame->nrestores = 0;
        for (int i = 0; i < ncleanups; i++)
        {
            if (cleanups[i].restore)
            {
                offload_restore_t restore = { cleanups[i].release, cleanups[i].ptr, cleanups[i].arg };

                if (cleanups[i].size)
                {
                    memcpy(values, (const void *)cleanups[i].arg, cleanups[i].size);
                    restore.arg = (intptr_t)values;
                    values += frame_align(cleanups[i].size);
                }
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

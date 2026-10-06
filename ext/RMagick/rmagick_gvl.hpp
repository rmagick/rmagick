#ifndef _RMAGICK_GVL_HPP_
#define _RMAGICK_GVL_HPP_

extern void   rm_gvl_init_offload(void);
extern void   rm_gvl_check_readable(const void *);
extern void   rm_gvl_check_writable(const void *);

/**
 * A call to an ImageMagick function without the GVL, which a Fiber scheduler
 * with a worker pool may run on a worker thread. Register the Ruby objects the
 * call uses and what the caller releases after it, then call run().
 */
class rm_gvl_call
{
public:
    rm_gvl_call(gvl_function_t *fp, void *args);

    rm_gvl_call &read(VALUE obj);
    rm_gvl_call &read(const void *ptr);
    rm_gvl_call &update(VALUE obj);
    rm_gvl_call &update(const void *ptr);
    rm_gvl_call &read_each(VALUE ary);
    rm_gvl_call &release(ExceptionInfo *exception);
    rm_gvl_call &release(ImageInfo *info);
    rm_gvl_call &destroy(Image *image);
    rm_gvl_call &split(Image *images);
#if defined(IMAGEMAGICK_7)
    rm_gvl_call &restore_mask(Image *image, ChannelType channel_mask);
#endif
    rm_gvl_call &free_result();
    rm_gvl_call &cleanup(void (*release)(void *, intptr_t), void *ptr, intptr_t arg = 0);

    template <typename T> T run();

private:
    enum ResultType { ResultIgnored, ResultImage, ResultMemory };
    enum { MaxObjects = 4, MaxCleanups = 4 };

    typedef struct
    {
        VALUE obj;
        const void *ptr;
        bool update;
        bool each;
    } object_t;

    typedef struct
    {
        void (*release)(void *, intptr_t);
        void *ptr;
        intptr_t arg;
    } cleanup_t;

    gvl_function_t *fp;
    void *args;
    object_t objects[MaxObjects];
    int nobjects;
    cleanup_t cleanups[MaxCleanups];
    int ncleanups;
    ResultType result_type;

    rm_gvl_call &add_object(VALUE obj, const void *ptr, bool update, bool each);
    void *call(ResultType type);
    void unwind(ResultType type, void *result);
};

template <typename T>
T
rm_gvl_call::run()
{
    return (T)(uintptr_t)call(result_type);
}

template <> Image *rm_gvl_call::run<Image *>();
template <> void rm_gvl_call::run<void>();

//! declare the arguments of the GVL stub of name and an rm_gvl_call named var that calls it
#define DECLARE_GVL_CALL(var, name, ...) \
    GVL_STRUCT_TYPE(name) var##_args = { __VA_ARGS__ }; \
    rm_gvl_call var(GVL_FUNC(name), &var##_args)

//! declare the arguments of type and an rm_gvl_call named var that calls fp with them
#define DECLARE_GVL_CALL_FP(var, type, fp, ...) \
    GVL_STRUCT_TYPE(type) var##_args = { __VA_ARGS__ }; \
    rm_gvl_call var(fp, &var##_args)

#endif

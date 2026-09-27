/**
 * KernelInfo class methods.
 *
 * Copyright (c) 2002 - 2009 Timothy P. Hunter
 * Copyright (c) 2009 -      Benjamin Thomas and Omer Bar-or
 * Copyright (c) 2009 -      RMagick contributors
 *
 * @file     rmkinfo.cpp
 * @author   Tim Hunter
 */

#include "rmagick.h"

static void rm_kernel_info_destroy(void *kernel);
static size_t rm_kernel_info_memsize(const void *ptr);

const rb_data_type_t rm_kernel_info_data_type = {
    "Magick::KernelInfo",
    { NULL, rm_kernel_info_destroy, rm_kernel_info_memsize, },
    0, 0,
    RUBY_TYPED_FROZEN_SHAREABLE,
};

DEFINE_GVL_VOID_STUB2(UnityAddKernelInfo, KernelInfo *, const double);
DEFINE_GVL_VOID_STUB3(ScaleKernelInfo, KernelInfo *, const double, const GeometryFlags);
DEFINE_GVL_VOID_STUB2(ScaleGeometryKernelInfo, KernelInfo *, const char *);


/**
 * If there's a kernel info, delete it before destroying the KernelInfo
 *
 * No Ruby usage (internal function)
 *
 * @param kernel pointer to the KernelInfo object associated with instance
 */

static void
rm_kernel_info_destroy(void *kernel)
{
    if (kernel)
      DestroyKernelInfo((KernelInfo*)kernel);
}

/**
  * Get KernelInfo object size.
  *
  * No Ruby usage (internal function)
  *
  * @param ptr pointer to the KernelInfo object
  */
static size_t
rm_kernel_info_memsize(const void *ptr)
{
    const KernelInfo *kernel = (const KernelInfo *)ptr;
    size_t size = 0;

    // A KernelInfo may be a linked list of kernels, each owning a values array.
    while (kernel)
    {
        size += sizeof(KernelInfo);
        if (kernel->values)
        {
            size += kernel->width * kernel->height * sizeof(*kernel->values);
        }
        kernel = kernel->next;
    }

    return size;
}

/**
 * Create a KernelInfo object.
 *
 * @return [Magick::KernelInfo] a new KernelInfo object
 */
VALUE
KernelInfo_alloc(VALUE klass)
{
    return TypedData_Wrap_Struct(klass, &rm_kernel_info_data_type, NULL);
}

/**
 * KernelInfo object constructor
 *
 * - Calling it again on an initialized object replaces its kernel and destroys the old one.
 * - A kernel string whose first non-blank character is '@' is rejected: ImageMagick would read the
 *   kernel from the file it names. A string that contains a %[fx:@...], %[hex:@...] or
 *   %[pixel:@...] escape is rejected as well, by the same check as the other options that name files.
 *
 * @param kernel_string [String] kernel info string representation to be parsed
 * @return [Magick::KernelInfo] self
 * @raise [FrozenError] if the object is frozen
 * @raise [ArgumentError] if the kernel string names a file with '@'
 */
VALUE
KernelInfo_initialize(VALUE self, VALUE kernel_string)
{
    KernelInfo *kernel, *old_kernel;
    char *string;

    rb_check_frozen(self);
    string = StringValueCStr(kernel_string);
    if (rm_has_file_reference(string))
    {
        rb_raise(rb_eArgError, "the kernel must not name a file with '@'");
    }

#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;

    exception = AcquireExceptionInfo();
    kernel = AcquireKernelInfo(string, exception);
    if (rm_should_raise_exception(exception, DestroyExceptionRetention))
    {
        if (kernel != (KernelInfo *) NULL)
        {
            DestroyKernelInfo(kernel);
        }
        rm_raise_exception(exception);
    }
#else
    kernel = AcquireKernelInfo(string);
#endif

    if (!kernel)
    {
        rb_raise(rb_eRuntimeError, "failed to parse kernel string");
    }

    old_kernel = (KernelInfo *)DATA_PTR(self);
    DATA_PTR(self) = kernel;
    if (old_kernel)
    {
        DestroyKernelInfo(old_kernel);
    }

    return self;
}


/**
 * Return the KernelInfo struct associated with the object, raising an
 * exception if the object has not been initialized (for example, when it was
 * created with KernelInfo.allocate or a previous initialize failed). Without
 * this guard a NULL pointer would be handed to ImageMagick, causing a crash.
 *
 * No Ruby usage (internal function)
 *
 * @param self the KernelInfo object
 * @return the KernelInfo struct
 * @throw RuntimeError if the kernel has not been initialized
 */
static KernelInfo *
get_kernel_info(VALUE self)
{
    KernelInfo *kernel;

    TypedData_Get_Struct(self, KernelInfo, &rm_kernel_info_data_type, kernel);
    if (!kernel)
    {
        rb_raise(rb_eRuntimeError, "KernelInfo has not been initialized");
    }
    return kernel;
}


/**
 * Return the KernelInfo struct of an object that is about to be changed,
 * raising FrozenError if the object is frozen.
 *
 * No Ruby usage (internal function)
 *
 * @param self the KernelInfo object
 * @return the KernelInfo struct
 * @throw FrozenError if the object is frozen
 */
static KernelInfo *
get_unfrozen_kernel_info(VALUE self)
{
    rb_check_frozen(self);
    return get_kernel_info(self);
}


/**
 * Adds a given amount of the 'Unity' Convolution Kernel to the given pre-scaled and normalized Kernel.
 *
 * @param scale [Numeric] scale to add
 */
VALUE
KernelInfo_unity_add(VALUE self, VALUE scale)
{
    GVL_STRUCT_TYPE(UnityAddKernelInfo) args = { get_unfrozen_kernel_info(self), NUM2DBL(scale) };
    CALL_FUNC_WITHOUT_GVL(GVL_FUNC(UnityAddKernelInfo), &args);
    return Qnil;
}


/**
 * Scales the given kernel list by the given amount, with or without normalization
 * of the sum of the kernel values (as per given flags).
 *
 * @param scale [Numeric] scale to use
 * @param flags [Magick::GeometryFlags] Magick::NoValue, Magick::NormalizeValue or
 *   Magick::CorrelateNormalizeValue. ScaleKernelInfo ignores the other values, including
 *   Magick::PercentValue; use {KernelInfo#scale_geometry} for a percentage.
 * @return [nil]
 */
VALUE
KernelInfo_scale(VALUE self, VALUE scale, VALUE flags)
{
    GeometryFlags geoflags;

    VALUE_TO_ENUM(flags, geoflags, GeometryFlags);

    GVL_STRUCT_TYPE(ScaleKernelInfo) args = { get_unfrozen_kernel_info(self), NUM2DBL(scale), geoflags };
    CALL_FUNC_WITHOUT_GVL(GVL_FUNC(ScaleKernelInfo), &args);
    return Qnil;
}

/**
 * Takes a geometry argument string, typically provided as a +-set option:convolve:scale {geometry}+ user setting,
 * and modifies the kernel according to the parsed arguments of that setting.
 *
 * @param geometry [String] geometry string to parse and apply
 */
VALUE
KernelInfo_scale_geometry(VALUE self, VALUE geometry)
{
    char *geom = StringValueCStr(geometry);

    GVL_STRUCT_TYPE(ScaleGeometryKernelInfo) args = { get_unfrozen_kernel_info(self), geom };
    CALL_FUNC_WITHOUT_GVL(GVL_FUNC(ScaleGeometryKernelInfo), &args);

    RB_GC_GUARD(geometry);

    return Qnil;
}

/**
 * Initialize a copy made by clone or dup with a copy of the kernel of the original.
 *
 * @param orig the original object
 * @return [Magick::KernelInfo] self
 * @raise [FrozenError] if the object is frozen
 */
VALUE
KernelInfo_init_copy(VALUE self, VALUE orig)
{
    KernelInfo *kernel, *old_kernel;

    rb_check_frozen(self);
    kernel = CloneKernelInfo(get_kernel_info(orig));
    if (!kernel)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }

    old_kernel = (KernelInfo *)DATA_PTR(self);
    DATA_PTR(self) = kernel;
    if (old_kernel)
    {
        DestroyKernelInfo(old_kernel);
    }

    return self;
}

/**
 * Create new instance of KernelInfo with one of the 'named' built-in types of
 * kernels used for special purposes such as gaussian blurring, skeleton
 * pruning, and edge distance determination.
 *
 * - The kernel is parsed from "name:geometry" as KernelInfo.new does, so the
 *   arguments that are left out get ImageMagick's defaults.
 *
 * @param what [Magick::KernelInfoType] kernel one of Magick::KernelInfoType enums
 * @param geometry [String] geometry to pass to default kernel
 * @return [Magick::KernelInfo] a new KernelInfo object
 */
VALUE
KernelInfo_builtin(VALUE self, VALUE what, VALUE geometry)
{
    KernelInfo *kernel;
    KernelInfoType kernel_type;
    GeometryInfo info;
    const char *geom_str, *name;
    char kernel_string[MaxTextExtent];
    int length;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    VALUE_TO_ENUM(what, kernel_type, KernelInfoType);
    geom_str = StringValueCStr(geometry);
    // AcquireKernelInfo() reads a list of kernels separated by ';'. ParseGeometry() rejects such a
    // string today, but builtin makes one built-in kernel, so reject ';' explicitly as well.
    if ((ParseGeometry(geom_str, &info) == NoValue && *geom_str) || strchr(geom_str, ';'))
    {
        rb_raise(rb_eArgError, "invalid geometry string");
    }

    name = CommandOptionToMnemonic(MagickKernelOptions, kernel_type);
    length = snprintf(kernel_string, sizeof(kernel_string), "%s:%s", name, geom_str);
    if (length < 0 || (size_t)length >= sizeof(kernel_string))
    {
        rb_raise(rb_eArgError, "geometry string too long");
    }

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    kernel = AcquireKernelInfo(kernel_string, exception);
    if (rm_should_raise_exception(exception, DestroyExceptionRetention))
    {
        if (kernel != (KernelInfo *) NULL)
        {
            DestroyKernelInfo(kernel);
        }
        rm_raise_exception(exception);
    }
#else
    kernel = AcquireKernelInfo(kernel_string);
#endif

    RB_GC_GUARD(geometry);

    if (!kernel)
    {
        rb_raise(rb_eRuntimeError, "failed to acquire builtin kernel");
    }

    return TypedData_Wrap_Struct(self, &rm_kernel_info_data_type, kernel);
}

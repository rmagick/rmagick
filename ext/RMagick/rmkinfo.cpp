/************************************************************************//**
 * KernelInfo class definitions for RMagick.
 *
 * Copyright &copy; RMagick Project
 *
 * @file rmkinfo.cpp
 * @version $Id: rmkinfo.cpp,v 1.0 2011/11/29 15:33:14 naquad Exp $
 * @author Naquad
 ****************************************************************************/

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
    return sizeof(KernelInfo);
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
 * @param kernel_string [String] kernel info string representation to be parsed
 * @return [Magick::KernelInfo] self
 */
VALUE
KernelInfo_initialize(VALUE self, VALUE kernel_string)
{
    KernelInfo *kernel;
    char *string = StringValueCStr(kernel_string);

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

    DATA_PTR(self) = kernel;

    return self;
}


/**
 * Adds a given amount of the 'Unity' Convolution Kernel to the given pre-scaled and normalized Kernel.
 *
 * @param scale [Numeric] scale to add
 */
VALUE
KernelInfo_unity_add(VALUE self, VALUE scale)
{
    GVL_STRUCT_TYPE(UnityAddKernelInfo) args = { (KernelInfo*)DATA_PTR(self), NUM2DBL(scale) };
    CALL_FUNC_WITHOUT_GVL(GVL_FUNC(UnityAddKernelInfo), &args);
    return Qnil;
}


/**
 * Scales the given kernel list by the given amount, with or without normalization
 * of the sum of the kernel values (as per given flags).
 *
 * @param scale [Numeric] scale to use
 * @param flags [Magick::GeometryFlags] one of Magick::NormalizeValue, Magick::CorrelateNormalizeValue,
 *   and/or Magick::PercentValue
 */
VALUE
KernelInfo_scale(VALUE self, VALUE scale, VALUE flags)
{
    GeometryFlags geoflags;

    VALUE_TO_ENUM(flags, geoflags, GeometryFlags);

    GVL_STRUCT_TYPE(ScaleKernelInfo) args = { (KernelInfo*)DATA_PTR(self), NUM2DBL(scale), geoflags };
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
    GVL_STRUCT_TYPE(ScaleGeometryKernelInfo) args = { (KernelInfo*)DATA_PTR(self), StringValueCStr(geometry) };
    CALL_FUNC_WITHOUT_GVL(GVL_FUNC(ScaleGeometryKernelInfo), &args);
    return Qnil;
}

/**
 * Creates a new clone of the object so that its can be modified without effecting the original.
 *
 * @return [Magick::KernelInfo] new KernelInfo object
 */
VALUE
KernelInfo_clone(VALUE self)
{
    KernelInfo *kernel = CloneKernelInfo((KernelInfo*)DATA_PTR(self));
    return TypedData_Wrap_Struct(Class_KernelInfo, &rm_kernel_info_data_type, kernel);
}

/**
 * Create new instance of KernelInfo with one of the 'named' built-in types of
 * kernels used for special purposes such as gaussian blurring, skeleton
 * pruning, and edge distance determination.
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
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    VALUE_TO_ENUM(what, kernel_type, KernelInfoType);
    ParseGeometry(StringValueCStr(geometry), &info);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    kernel = AcquireKernelBuiltIn(kernel_type, &info, exception);
    if (rm_should_raise_exception(exception, DestroyExceptionRetention))
    {
        if (kernel != (KernelInfo *) NULL)
        {
            DestroyKernelInfo(kernel);
        }
        rm_raise_exception(exception);
    }
#else
    kernel = AcquireKernelBuiltIn(kernel_type, &info);
#endif

    if (!kernel)
    {
        rb_raise(rb_eRuntimeError, "failed to acquire builtin kernel");
    }

    return TypedData_Wrap_Struct(self, &rm_kernel_info_data_type, kernel);
}

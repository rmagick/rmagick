/************************************************************************//**
 * KernelInfo class definitions for RMagick.
 *
 * Copyright &copy; RMagick Project
 *
 * @file rmkinfo.c
 * @version $Id: rmkinfo.c,v 1.0 2011/11/29 15:33:14 naquad Exp $
 * @author Naquad
 ****************************************************************************/

#include "rmagick.h"

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
 * Create a KernelInfo object.
 *
 * @return [Magick::KernelInfo] a new KernelInfo object
 */
VALUE
KernelInfo_alloc(VALUE class)
{
    return Data_Wrap_Struct(class, NULL, rm_kernel_info_destroy, NULL);
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
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    Check_Type(kernel_string, T_STRING);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    kernel = AcquireKernelInfo(StringValueCStr(kernel_string), exception);
    if (rm_should_raise_exception(exception, DestroyExceptionRetention))
    {
        if (kernel != (KernelInfo *) NULL)
        {
            DestroyKernelInfo(kernel);
        }
        rm_raise_exception(exception);
    }
#else
    kernel = AcquireKernelInfo(StringValueCStr(kernel_string));
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
    if (!FIXNUM_P(scale))
        Check_Type(scale, T_FLOAT);

    /* UnityAddKernelInfo() was private function until IM 6.9 */
    MagickExport void UnityAddKernelInfo(KernelInfo *kernel, const double scale);

    UnityAddKernelInfo((KernelInfo*)DATA_PTR(self), NUM2DBL(scale));
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

    if (!FIXNUM_P(scale))
        Check_Type(scale, T_FLOAT);

    if (rb_obj_is_instance_of(flags, Class_GeometryFlags))
        VALUE_TO_ENUM(flags, geoflags, GeometryFlags);
    else
        rb_raise(rb_eArgError, "expected Integer or Magick::GeometryFlags to specify flags");

    /* ScaleKernelInfo() was private function until IM 6.9 */
    MagickExport void ScaleKernelInfo(KernelInfo *kernel, const double scaling_factor, const GeometryFlags normalize_flags);

    ScaleKernelInfo((KernelInfo*)DATA_PTR(self), NUM2DBL(scale), geoflags);
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
    Check_Type(geometry, T_STRING);
    ScaleGeometryKernelInfo((KernelInfo*)DATA_PTR(self), StringValueCStr(geometry));
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
    return Data_Wrap_Struct(Class_KernelInfo, NULL, rm_kernel_info_destroy, kernel);
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

    Check_Type(geometry, T_STRING);
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

    return Data_Wrap_Struct(self, NULL, rm_kernel_info_destroy, kernel);
}

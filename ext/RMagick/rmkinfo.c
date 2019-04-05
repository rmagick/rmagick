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
 * No Ruby usage (internal function)
 *
 * @param class the Ruby class to use
 * @return a new KernelInfo object
 */
VALUE
KernelInfo_alloc(VALUE class)
{
    return Data_Wrap_Struct(class, NULL, rm_kernel_info_destroy, NULL);
}

/**
 * KernelInfo object constructor
 *
 * Ruby usage:
 *   - @verbatim KernelInfo#initialize @endverbatim
 *
 * @param self this object
 * @param kernel_string kernel info string representation to be parsed
 * @return self
 */
VALUE
KernelInfo_initialize(VALUE self, VALUE kernel_string)
{
    KernelInfo *kernel;

    Check_Type(kernel_string, T_STRING);

    kernel = AcquireKernelInfo(StringValueCStr(kernel_string));

    if (kernel == NULL)
        rb_raise(rb_eRuntimeError, "failed to parse kernel string");

    DATA_PTR(self) = kernel;

    return self;
}

/**
 * Zero kerne NaNs.
 *
 * Ruby usage:
 *   - @verbatim KernelInfo#zero_nans @endverbatim
 *
 * @param self this object
 * @deprecated This method has been deprecated.
 */
VALUE
KernelInfo_zero_nans(VALUE self)
{
    rb_warning("KernelInfo#zero_nans is deprecated");
    ZeroKernelNans((KernelInfo*)DATA_PTR(self));
    return Qnil;
}

/**
 * Adds a given amount of the 'Unity' Convolution Kernel to the given pre-scaled and normalized Kernel.
 *
 * Ruby usage:
 *   - @verbatim KernelInfo#unity_add(scale) @endverbatim
 *
 * @param self this object
 * @param scale scale to add
 */
VALUE
KernelInfo_unity_add(VALUE self, VALUE scale)
{
    if (!FIXNUM_P(scale))
        Check_Type(scale, T_FLOAT);

    UnityAddKernelInfo((KernelInfo*)DATA_PTR(self), NUM2DBL(scale));
    return Qnil;
}

/**
 * Dumps KernelInfo object to stderr
 *
 * Ruby usage:
 *   - @verbatim KernelInfo#show @endverbatim
 *
 * @param self this object
 * @deprecated This method has been deprecated.
 */
VALUE
KernelInfo_show(VALUE self)
{
    rb_warning("KernelInfo#show is deprecated");
    ShowKernelInfo((KernelInfo*)DATA_PTR(self));
    return Qnil;
}

/**
 * Scales the given kernel list by the given amount, with or without normalization
 * of the sum of the kernel values (as per given flags).
 *
 * Ruby usage:
 *   - @verbatim KernelInfo#scale(scale, flags) @endverbatim
 *
 * @param scale scale to use
 * @param flags one of Magick::NormalizeValue, Magick::CorrelateNormalizeValue,
 *                     and/or Magick::PercentValue
 * @param self this object
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

    ScaleKernelInfo((KernelInfo*)DATA_PTR(self), NUM2DBL(scale), geoflags);
    return Qnil;
}

/**
 * Takes a geometry argument string, typically provided as a "-set option:convolve:scale {geometry}" user setting,
 * and modifies the kernel according to the parsed arguments of that setting.
 *
 * Ruby usage:
 *   - @verbatim KernelInfo#scale_geometry(geometry) @endverbatim
 *
 * @param geometry geometry string to parse and apply
 * @param self this object
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
 * Ruby usage:
 *   - @verbatim KernelInfo#clone @endverbatim
 *
 * @param self this object
 * @return new KernelInfo instance
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
 * Ruby usage:
 *   - @verbatim KernelInfo.builtin(kernel, geometry = nil) @endverbatim
 *
 * @parms kernel one of Magick::KernelInfoType enums:
 *                      Magick::UndefinedKernel
 *                      Magick::UnityKernel
 *                      Magick::GaussianKernel
 *                      Magick::DoGKernel
 *                      Magick::LoGKernel
 *                      Magick::BlurKernel
 *                      Magick::CometKernel
 *                      Magick::LaplacianKernel
 *                      Magick::SobelKernel
 *                      Magick::FreiChenKernel
 *                      Magick::RobertsKernel
 *                      Magick::PrewittKernel
 *                      Magick::CompassKernel
 *                      Magick::KirschKernel
 *                      Magick::DiamondKernel
 *                      Magick::SquareKernel
 *                      Magick::RectangleKernel
 *                      Magick::OctagonKernel
 *                      Magick::DiskKernel
 *                      Magick::PlusKernel
 *                      Magick::CrossKernel
 *                      Magick::RingKernel
 *                      Magick::PeaksKernel
 *                      Magick::EdgesKernel
 *                      Magick::CornersKernel
 *                      Magick::DiagonalsKernel
 *                      Magick::LineEndsKernel
 *                      Magick::LineJunctionsKernel
 *                      Magick::RidgesKernel
 *                      Magick::ConvexHullKernel
 *                      Magick::ThinSEKernel
 *                      Magick::SkeletonKernel
 *                      Magick::ChebyshevKernel
 *                      Magick::ManhattanKernel
 *                      Magick::OctagonalKernel
 *                      Magick::EuclideanKernel
 *                      Magick::UserDefinedKernel
 *                      Magick::BinomialKernel
 * @param geometry geometry to pass to default kernel
 * @return KernelInfo instance
 */
VALUE
KernelInfo_builtin(VALUE self, VALUE what, VALUE geometry)
{
    KernelInfo *kernel;
    KernelInfoType kernel_type;
    GeometryInfo info;

    Check_Type(geometry, T_STRING);
    VALUE_TO_ENUM(what, kernel_type, KernelInfoType);
    ParseGeometry(StringValueCStr(geometry), &info);

    kernel = AcquireKernelBuiltIn(kernel_type, &info);

    if (!kernel)
        rb_raise(rb_eRuntimeError, "failed to acquire builtin kernel");

    return Data_Wrap_Struct(self, NULL, rm_kernel_info_destroy, kernel);
}

#include "rmagick.h"

static void
rm_kernel_info_destroy(void *kernel)
{
  if (kernel)
    DestroyKernelInfo((KernelInfo*)kernel);
}

VALUE
KernelInfo_alloc(VALUE class)
{
  return Data_Wrap_Struct(class, NULL, rm_kernel_info_destroy, NULL);
}

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

VALUE
KernelInfo_zero_nans(VALUE self)
{
  ZeroKernelNans((KernelInfo*)DATA_PTR(self));
  return Qnil;
}

VALUE
KernelInfo_unity_add(VALUE self, VALUE scale)
{
  if (!FIXNUM_P(scale))
    Check_Type(scale, T_FLOAT);

  UnityAddKernelInfo((KernelInfo*)DATA_PTR(self), NUM2DBL(scale));
  return Qnil;
}

VALUE
KernelInfo_show(VALUE self)
{
  ShowKernelInfo((KernelInfo*)DATA_PTR(self));
  return Qnil;
}

VALUE
KernelInfo_scale(VALUE self, VALUE scale, VALUE flags)
{
  GeometryFlags geoflags;

  if (!FIXNUM_P(scale))
    Check_Type(scale, T_FLOAT);

  if (FIXNUM_P(flags))
    geoflags = flags;
  else if (rb_obj_is_instance_of(flags, Class_GeometryFlags))
    VALUE_TO_ENUM(flags, geoflags, GeometryFlags);
  else
    rb_raise(rb_eArgError, "expected Fixnum or Magick::GeometryFlags to specify flags");

  ScaleKernelInfo((KernelInfo*)DATA_PTR(self), NUM2DBL(scale), geoflags);
  return Qnil;
}

VALUE
KernelInfo_scale_geometry(VALUE self, VALUE geometry)
{
  Check_Type(geometry, T_STRING);
  ScaleGeometryKernelInfo((KernelInfo*)DATA_PTR(self), StringValueCStr(geometry));
  return Qnil;
}

VALUE
KernelInfo_clone(VALUE self)
{
  KernelInfo *kernel = CloneKernelInfo((KernelInfo*)DATA_PTR(self));
  return Data_Wrap_Struct(Class_KernelInfo, NULL, rm_kernel_info_destroy, kernel);
}

VALUE
KernelInfo_builtin(VALUE self, VALUE what, VALUE geometry)
{
  GeometryInfo info;
  KernelInfo *kernel;
  KernelInfoType kernel_type;

  Check_Type(geometry, T_STRING);
  VALUE_TO_ENUM(what, kernel_type, KernelInfoType);

  ParseGeometry(StringValueCStr(geometry), &info);
  kernel = AcquireKernelBuiltIn(kernel_type, &info);

  if (!kernel)
    rb_raise(rb_eRuntimeError, "failed to acquire builtin kernel");

  return Data_Wrap_Struct(Class_KernelInfo, NULL, rm_kernel_info_destroy, kernel);
}

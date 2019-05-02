/**************************************************************************//**
 * Enumeration methods.
 *
 * Copyright &copy; 2002 - 2009 by Timothy P. Hunter
 *
 * Changes since Nov. 2009 copyright &copy; by Benjamin Thomas and Omer Bar-or
 *
 * @file     rmenum.c
 * @version  $Id: rmenum.c,v 1.9 2009/12/20 02:33:33 baror Exp $
 * @author   Tim Hunter
 ******************************************************************************/

#include "rmagick.h"


#define ENUMERATORS_CLASS_VAR "@@enumerators"
#define ENUM_TO_NAME(_enum) case _enum: return #_enum;
#define ENUM_SET_NAME(_enum) case _enum: name = #_enum; break;


static VALUE Enum_type_values(VALUE);
static VALUE Enum_type_inspect(VALUE);





/**
 * Set up a subclass of Enum.
 *
 * No Ruby usage (internal function)
 *
 * @param tag the name of the subclass
 * @return the subclass
 */
VALUE
rm_define_enum_type(const char *tag)
{
    VALUE class;

    class = rb_define_class_under(Module_Magick, tag, Class_Enum);\

    rb_define_singleton_method(class, "values", Enum_type_values, 0);
    rb_define_method(class, "initialize", Enum_type_initialize, 2);
    rb_define_method(class, "inspect", Enum_type_inspect, 0);
    return class;
}


/**
 * Construct a new Enum subclass instance.
 *
 * No Ruby usage (internal function)
 *
 * @param class the subclass
 * @param sym the symbol
 * @param val the value for the symbol
 * @return a new instance of class
 */
VALUE
rm_enum_new(VALUE class, VALUE sym, VALUE val)
{
    VALUE argv[2];

    argv[0] = sym;
    argv[1] = val;
    return rb_obj_freeze(rb_class_new_instance(2, argv, class));
}


/**
 * Enum class alloc function.
 *
 * No Ruby usage (internal function)
 *
 * @param class the Ruby class to use
 * @return a new enumerator
 */
VALUE
Enum_alloc(VALUE class)
{
   MagickEnum *magick_enum;
   VALUE enumr;

   enumr = Data_Make_Struct(class, MagickEnum, NULL, NULL, magick_enum);
   rb_obj_freeze(enumr);

   RB_GC_GUARD(enumr);

   return enumr;
}


/**
 * "Case equal" operator for Enum.
 *
 * Ruby usage:
 *   - @verbatim Enum#=== @endverbatim
 *
 * Notes:
 *   - Yes, I know "case equal" is a misnomer.
 *
 * @param self this object
 * @param other the other object
 * @return true or false
 */
VALUE
Enum_case_eq(VALUE self, VALUE other)
{
    MagickEnum *this, *that;

    if (CLASS_OF(self) == CLASS_OF(other))
    {
        Data_Get_Struct(self, MagickEnum, this);
        Data_Get_Struct(other, MagickEnum, that);
        return this->val == that->val ? Qtrue : Qfalse;
    }

    return Qfalse;
}


/**
 * Initialize a new Enum instance.
 *
 * Ruby usage:
 *   - @verbatim Enum#initialize(sym,val) @endverbatim
 *
 * @param self this object
 * @param sym the symbol
 * @param val the value for the symbol
 * @return self
 */
VALUE
Enum_initialize(VALUE self, VALUE sym, VALUE val)
{
   MagickEnum *magick_enum;

   Data_Get_Struct(self, MagickEnum, magick_enum);
   magick_enum->id = rb_to_id(sym); /* convert symbol to ID */
   magick_enum->val = NUM2INT(val);

   return self;
}


/**
 * Return the value of an enum.
 *
 * Ruby usage:
 *   - @verbatim Enum#to_i @endverbatim
 *
 * @param self this object
 * @return this object's value
 */
VALUE
Enum_to_i(VALUE self)
{
   MagickEnum *magick_enum;

   Data_Get_Struct(self, MagickEnum, magick_enum);
   return INT2NUM(magick_enum->val);
}


/**
 * Support Comparable module in Enum.
 *
 * Ruby usage:
 *   - @verbatim Enum#<=> @endverbatim
 *
 * Notes:
 *   - Enums must be instances of the same class to be equal.
 *
 * @param self this object
 * @param other the other object
 * @return -1, 0, 1, or nil
 */
VALUE
Enum_spaceship(VALUE self, VALUE other)
{
    MagickEnum *this, *that;

    if(CLASS_OF(self) != CLASS_OF(other)) {
        return Qnil;
    }

    Data_Get_Struct(self, MagickEnum, this);
    Data_Get_Struct(other, MagickEnum, that);

    if (this->val > that->val)
    {
        return INT2FIX(1);
    }
    else if (this->val < that->val)
    {
        return INT2FIX(-1);
    }

    return INT2FIX(0);
}

/**
 * Bitwise OR for enums
 * 
 * Ruby usage:
 *   - @verbatim Enum1 | Enum2 @endverbatim
 * 
 * Notes:
 *   - Enums must be instances of the same class.
 *
 * @param Enum1 this object
 * @param Enum2 another enum
 * @return new Enum instance
 */
VALUE
Enum_bitwise_or(VALUE self, VALUE another)
{
  VALUE new_enum, cls;
  MagickEnum *this, *that, *new_enum_data;

  cls = CLASS_OF(self);
  if (CLASS_OF(another) != cls)
  {
    rb_raise(rb_eArgError, "Expected class %s but got %s", rb_class2name(cls), rb_class2name(CLASS_OF(another)));
  }

  new_enum = Enum_alloc(cls);

  Data_Get_Struct(self, MagickEnum, this);
  Data_Get_Struct(another, MagickEnum, that);
  Data_Get_Struct(new_enum, MagickEnum, new_enum_data);

  new_enum_data->id = rb_to_id(rb_sprintf("%s|%s", rb_id2name(this->id), rb_id2name(that->id)));
  new_enum_data->val = this->val | that->val;

  return new_enum;
}

/**
 * Return the name of an enum.
 *
 * Ruby usage:
 *   - @verbatim Enum#to_s @endverbatim
 *
 * @param self this object
 * @return the name
 */
VALUE
Enum_to_s(VALUE self)
{
   MagickEnum *magick_enum;

   Data_Get_Struct(self, MagickEnum, magick_enum);
   return rb_str_new2(rb_id2name(magick_enum->id));
}


/**
 * Initialize method for all Enum subclasses.
 *
 * Ruby usage:
 *   - @verbatim xxx#initialize(sym,val) @endverbatim
 *
 * @param self this object
 * @param sym the symbol
 * @param val the value of the symbol
 * @return self
 */
VALUE
Enum_type_initialize(VALUE self, VALUE sym, VALUE val)
{
    VALUE super_argv[2];
    VALUE enumerators;

    super_argv[0] = sym;
    super_argv[1] = val;
    (void) rb_call_super(2, (const VALUE *)super_argv);

    if (rb_cvar_defined(CLASS_OF(self), rb_intern(ENUMERATORS_CLASS_VAR)) != Qtrue)
    {
        rb_cv_set(CLASS_OF(self), ENUMERATORS_CLASS_VAR, rb_ary_new());
    }

    enumerators = rb_cv_get(CLASS_OF(self), ENUMERATORS_CLASS_VAR);
    (void) rb_ary_push(enumerators, self);

    RB_GC_GUARD(enumerators);

    return self;
}


/**
 * Enum subclass #inspect.
 *
 * Ruby usage:
 *   - @verbatim xxx#inspect @endverbatim
 *
 * @param self this object
 * @return string representation of self
 */
static VALUE
Enum_type_inspect(VALUE self)
{
    char str[100];
    MagickEnum *magick_enum;

    Data_Get_Struct(self, MagickEnum, magick_enum);
    sprintf(str, "%.48s=%d", rb_id2name(magick_enum->id), magick_enum->val);

    return rb_str_new2(str);
}


/**
 * Behaves like #each if a block is present, otherwise like #to_a.
 *
 * Ruby usage:
 *   - @verbatim xxx.values @endverbatim
 *   - @verbatim xxx.values {|v| } @endverbatim
 *
 * Notes:
 *   - Defined for each Enum subclass
 *
 * @param class the subclass
 * @return iterator over values if given block, a copy of the values otherwise
 */
static VALUE
Enum_type_values(VALUE class)
{
    VALUE enumerators, copy;
    VALUE rv;
    int x;

    enumerators = rb_cv_get(class, ENUMERATORS_CLASS_VAR);

    if (rb_block_given_p())
    {
        for (x = 0; x < RARRAY_LEN(enumerators); x++)
        {
            (void) rb_yield(rb_ary_entry(enumerators, x));
        }
        rv = class;
    }
    else
    {
        copy = rb_ary_new2(RARRAY_LEN(enumerators));
        for (x = 0; x < RARRAY_LEN(enumerators); x++)
        {
            (void) rb_ary_push(copy, rb_ary_entry(enumerators, x));
        }
        rb_obj_freeze(copy);
        rv = copy;
    }

    RB_GC_GUARD(enumerators);
    RB_GC_GUARD(copy);
    RB_GC_GUARD(rv);

    return rv;
}

/**
 * Find enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param class the class type
 * @param value the value for enum
 * @return a enumerator
 */

VALUE
Enum_find(VALUE class, int val)
{
    VALUE enumerators;
    MagickEnum *magick_enum;
    int x;

    enumerators = rb_cv_get(class, ENUMERATORS_CLASS_VAR);
    enumerators = rm_check_ary_type(enumerators);

    for (x = 0; x < RARRAY_LEN(enumerators); x++)
    {
       VALUE enumerator = rb_ary_entry(enumerators, x);
       Data_Get_Struct(enumerator, MagickEnum, magick_enum);
       if (magick_enum->val == val)
       {
           return enumerator;
       }
    }

    return Qnil;
}


/**
 * Returns a ClassType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param cls the class type
 * @return a new enumerator
 */
VALUE
ClassType_find(ClassType cls)
{
    return Enum_find(Class_ClassType, cls);
}


/**
 * Returns a ColorspaceType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param cs the ColorspaceType
 * @return a new ColorspaceType enumerator
 */
VALUE
ColorspaceType_find(ColorspaceType cs)
{
    return Enum_find(Class_ColorspaceType, cs);
}


/**
 * Return the string representation of a ComplianceType value.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - xMagick will OR multiple compliance types so we have to arbitrarily pick
 *     one name.
 *   - Set the compliance argument to the selected value.
 *
 * @param c the ComplianceType value
 * @return the string
 */
const char *
ComplianceType_name(ComplianceType *c)
{
    if ((*c & (SVGCompliance|X11Compliance|XPMCompliance))
        == (SVGCompliance|X11Compliance|XPMCompliance))
    {
        return "AllCompliance";
    }
    else if (*c & SVGCompliance)
    {
        *c = SVGCompliance;
        return "SVGCompliance";
    }
    else if (*c & X11Compliance)
    {
        *c = X11Compliance;
        return "X11Compliance";
    }
    else if (*c & XPMCompliance)
    {
        *c = XPMCompliance;
        return "XPMCompliance";
    }
    else if (*c == NoCompliance)
    {
        *c = NoCompliance;
        return "NoCompliance";
    }
    else
    {
        *c = UndefinedCompliance;
        return "UndefinedCompliance";
    }
}


/**
 * Returns a ComplianceType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param compliance the C ComplianceType value
 * @return the Ruby ComplianceType enum object
 */
VALUE
ComplianceType_find(ComplianceType compliance)
{
    return Enum_find(Class_ComplianceType, compliance);
}


/**
 * Returns a CompositeOperator enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param op the CompositeOperator
 * @return a new CompositeOperator enumerator
 */
VALUE
CompositeOperator_find(CompositeOperator op)
{
    return Enum_find(Class_CompositeOperator, op);
}


/**
 * Returns a CompressionType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param ct the CompressionType
 * @return a new CompressionType enumerator
 */
VALUE
CompressionType_find(CompressionType ct)
{
    return Enum_find(Class_CompressionType, ct);
}


/**
 * Returns a DisposeType enum object for the specified value..new.
 *
 * No Ruby usage (internal function)
 *
 * @param type the DisposeType
 * @return a new DisposeType enumerator
 */
VALUE
DisposeType_find(DisposeType type)
{
    return Enum_find(Class_DisposeType, type);
}


/**
 * Returns an EndianType enum object.
 *
 * No Ruby usage (internal function)
 *
 * @param type the EndianType
 * @return a new EndianType enumerator
 */
VALUE
EndianType_find(EndianType type)
{
    return Enum_find(Class_EndianType, type);
}


/**
 * Returns a FilterType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param type the FilterType
 * @return a new FilterType enumerator
 */
VALUE
FilterType_find(FilterType type)
{
    return Enum_find(Class_FilterType, type);
}


/**
 * Returns a GravityType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param type the GravityType
 * @return a new GravityType enumerator
 */
VALUE
GravityType_find(GravityType type)
{
    return Enum_find(Class_GravityType, type);
}


/**
 * Returns an ImageType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param type the ImageType
 * @return a new ImageType enumerator
 */
VALUE
ImageType_find(ImageType type)
{
    return Enum_find(Class_ImageType, type);
}


/**
 * Return the name of a InterlaceType enum as a string.
 *
 * No Ruby usage (internal function)
 *
 * @param interlace the InterlaceType
 * @return the name
 */
static const char *
InterlaceType_name(InterlaceType interlace)
{
    switch(interlace)
    {
        ENUM_TO_NAME(GIFInterlace)
        ENUM_TO_NAME(JPEGInterlace)
        ENUM_TO_NAME(PNGInterlace)
        ENUM_TO_NAME(NoInterlace)
        ENUM_TO_NAME(LineInterlace)
        ENUM_TO_NAME(PlaneInterlace)
        ENUM_TO_NAME(PartitionInterlace)
        default:
        ENUM_TO_NAME(UndefinedInterlace)
    }
}


/**
 * Construct an InterlaceType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param interlace the InterlaceType
 * @return a new InterlaceType enumerator
 */
VALUE
InterlaceType_new(InterlaceType interlace)
{
    const char *name = InterlaceType_name(interlace);
    return rm_enum_new(Class_InterlaceType, ID2SYM(rb_intern(name)), INT2FIX(interlace));
}


/**
 * Return the name of a OrientationType enum as a string.
 *
 * No Ruby usage (internal function)
 *
 * @param type the OreintationType
 * @return the name
 */
static const char *
OrientationType_name(OrientationType type)
{
    switch(type)
    {
        ENUM_TO_NAME(TopLeftOrientation)
        ENUM_TO_NAME(TopRightOrientation)
        ENUM_TO_NAME(BottomRightOrientation)
        ENUM_TO_NAME(BottomLeftOrientation)
        ENUM_TO_NAME(LeftTopOrientation)
        ENUM_TO_NAME(RightTopOrientation)
        ENUM_TO_NAME(RightBottomOrientation)
        ENUM_TO_NAME(LeftBottomOrientation)
        default:
        ENUM_TO_NAME(UndefinedOrientation)
    }
}


/**
 * Construct an OrientationType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param type the OrientationType
 * @return a new OrientationType enumerator
 */
VALUE
OrientationType_new(OrientationType type)
{
    const char *name = OrientationType_name(type);
    return rm_enum_new(Class_OrientationType, ID2SYM(rb_intern(name)), INT2FIX(type));
}


/**
 * Returns a PixelInterpolateMethod enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param interpolate the PixelInterpolateMethod
 * @return a new PixelInterpolateMethod enumerator
 */
VALUE
PixelInterpolateMethod_find(PixelInterpolateMethod interpolate)
{
    return Enum_find(Class_PixelInterpolateMethod, interpolate);
}


/**
 * Return the name of a RenderingIntent enum as a string.
 *
 * No Ruby usage (internal function)
 *
 * @param intent the RenderingIntent
 * @return the name
 */
static const char *
RenderingIntent_name(RenderingIntent intent)
{
    switch(intent)
    {
        ENUM_TO_NAME(SaturationIntent)
        ENUM_TO_NAME(PerceptualIntent)
        ENUM_TO_NAME(AbsoluteIntent)
        ENUM_TO_NAME(RelativeIntent)
        default:
        ENUM_TO_NAME(UndefinedIntent)
    }
}


/**
 * Construct an RenderingIntent enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param intent the RenderingIntent
 * @return a new RenderingIntent enumerator
 */
VALUE
RenderingIntent_new(RenderingIntent intent)
{
    const char *name = RenderingIntent_name(intent);
    return rm_enum_new(Class_RenderingIntent, ID2SYM(rb_intern(name)), INT2FIX(intent));
}


/**
 * Return the name of a ResolutionType enum as a string.
 *
 * No Ruby usage (internal function)
 *
 * @param type the ResolutionType
 * @return the name
 */
static const char *
ResolutionType_name(ResolutionType type)
{
    switch(type)
    {
        ENUM_TO_NAME(PixelsPerInchResolution)
        ENUM_TO_NAME(PixelsPerCentimeterResolution)
        default:
        ENUM_TO_NAME(UndefinedResolution)
    }
}


/**
 * Construct an ResolutionType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param type the ResolutionType
 * @return a new ResolutionType enumerator
 */
VALUE
ResolutionType_new(ResolutionType type)
{
    const char *name = ResolutionType_name(type);
    return rm_enum_new(Class_ResolutionType, ID2SYM(rb_intern(name)), INT2FIX(type));
}


/**
 * Return the string representation of a StorageType value.
 *
 * No Ruby usage (internal function)
 *
 * @param type the StorageType
 * @return the name
 */
const char *
StorageType_name(StorageType type)
{
    switch (type)
    {
        ENUM_TO_NAME(CharPixel)
        ENUM_TO_NAME(DoublePixel)
        ENUM_TO_NAME(FloatPixel)
        ENUM_TO_NAME(IntegerPixel)
        ENUM_TO_NAME(LongPixel)
        ENUM_TO_NAME(QuantumPixel)
        ENUM_TO_NAME(ShortPixel)
        default:
        ENUM_TO_NAME(UndefinedPixel)
    }
}


/**
 * Return the string representation of a StretchType value.
 *
 * No Ruby usage (internal function)
 *
 * @param stretch the StretchType value
 * @return the string
 */
const char *
StretchType_name(StretchType stretch)
{
    switch (stretch)
    {
        ENUM_TO_NAME(NormalStretch)
        ENUM_TO_NAME(UltraCondensedStretch)
        ENUM_TO_NAME(ExtraCondensedStretch)
        ENUM_TO_NAME(CondensedStretch)
        ENUM_TO_NAME(SemiCondensedStretch)
        ENUM_TO_NAME(SemiExpandedStretch)
        ENUM_TO_NAME(ExpandedStretch)
        ENUM_TO_NAME(ExtraExpandedStretch)
        ENUM_TO_NAME(UltraExpandedStretch)
        ENUM_TO_NAME(AnyStretch)
        default:
        ENUM_TO_NAME(UndefinedStretch)
    }
}


/**
 * Construct a StretchType enum for a specified StretchType value.
 *
 * No Ruby usage (internal function)
 *
 * @param stretch the C StretchType value
 * @return a Ruby StretchType enum
 */
VALUE
StretchType_new(StretchType stretch)
{
    const char *name = StretchType_name(stretch);
    return rm_enum_new(Class_StretchType, ID2SYM(rb_intern(name)), INT2FIX(stretch));
}


/**
 * Return the string representation of a StyleType value.
 *
 * No Ruby usage (internal function)
 *
 * @param style the StyleType value
 * @return the string
 */
const char *
StyleType_name(StyleType style)
{
    switch (style)
    {
        ENUM_TO_NAME(NormalStyle)
        ENUM_TO_NAME(ItalicStyle)
        ENUM_TO_NAME(ObliqueStyle)
        ENUM_TO_NAME(AnyStyle)
        default:
        ENUM_TO_NAME(UndefinedStyle)
    }
}


/**
 * Construct a StyleType enum for a specified StyleType value.
 *
 * No Ruby usage (internal function)
 *
 * @param style the C StyleType value
 * @return a Ruby StyleType enum
 */
VALUE
StyleType_new(StyleType style)
{
    const char *name = StyleType_name(style);
    return rm_enum_new(Class_StyleType, ID2SYM(rb_intern(name)), INT2FIX(style));
}


/**
 * Returns a VirtualPixelMethod enum for a specified VirtualPixelMethod value.
 *
 * No Ruby usage (internal function)
 *
 * @param style theVirtualPixelMethod
 * @return a new VirtualPixelMethod enumerator
 */
VALUE
VirtualPixelMethod_find(VirtualPixelMethod style)
{
    return Enum_find(Class_VirtualPixelMethod, style);
}

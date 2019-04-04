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
 * Construct a ClassType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param cls the class type
 * @return a new enumerator
 */
VALUE
ClassType_new(ClassType cls)
{
    const char *name;

    switch(cls)
    {
        ENUM_SET_NAME(DirectClass)
        ENUM_SET_NAME(PseudoClass)
        default:
        ENUM_SET_NAME(UndefinedClass)
    }

    return rm_enum_new(Class_ClassType, ID2SYM(rb_intern(name)), INT2FIX(cls));
}


/**
 * Construct a ColorspaceType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param cs the ColorspaceType
 * @return a new ColorspaceType enumerator
 */
VALUE
ColorspaceType_new(ColorspaceType cs)
{
    const char *name;

    switch(cs)
    {
        ENUM_SET_NAME(RGBColorspace)
        ENUM_SET_NAME(GRAYColorspace)
        ENUM_SET_NAME(TransparentColorspace)
        ENUM_SET_NAME(OHTAColorspace)
        ENUM_SET_NAME(XYZColorspace)
        ENUM_SET_NAME(YCbCrColorspace)
        ENUM_SET_NAME(YCCColorspace)
        ENUM_SET_NAME(YIQColorspace)
        ENUM_SET_NAME(YPbPrColorspace)
        ENUM_SET_NAME(YUVColorspace)
        ENUM_SET_NAME(CMYKColorspace)
        ENUM_SET_NAME(sRGBColorspace)
        ENUM_SET_NAME(Rec601YCbCrColorspace)
        ENUM_SET_NAME(Rec601LumaColorspace)
        ENUM_SET_NAME(Rec709LumaColorspace)
        ENUM_SET_NAME(Rec709YCbCrColorspace)
        ENUM_SET_NAME(CMYColorspace)
#if defined(IMAGEMAGICK_GREATER_THAN_EQUAL_6_8_9)
        ENUM_SET_NAME(LuvColorspace)
        ENUM_SET_NAME(HCLColorspace)
        ENUM_SET_NAME(LCHColorspace)
        ENUM_SET_NAME(LMSColorspace)
        ENUM_SET_NAME(LCHabColorspace)
        ENUM_SET_NAME(LCHuvColorspace)
        ENUM_SET_NAME(scRGBColorspace)
        ENUM_SET_NAME(HSIColorspace)
        ENUM_SET_NAME(HSVColorspace)
        ENUM_SET_NAME(HCLpColorspace)
        ENUM_SET_NAME(YDbDrColorspace)
        ENUM_SET_NAME(xyYColorspace)
#endif
        default:
        ENUM_SET_NAME(UndefinedColorspace)
    }

    return rm_enum_new(Class_ColorspaceType, ID2SYM(rb_intern(name)), INT2FIX(cs));

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
 * Construct a ComplianceType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param compliance the C ComplianceType value
 * @return the Ruby ComplianceType enum object
 */
VALUE
ComplianceType_new(ComplianceType compliance)
{
    const char *name;

    // Turn off undefined bits
    compliance &= (SVGCompliance|X11Compliance|XPMCompliance);
    name = ComplianceType_name(&compliance);
    return rm_enum_new(Class_ComplianceType, ID2SYM(rb_intern(name)), INT2FIX(compliance));
}



/**
 * Return the name of a CompositeOperator enum as a string.
 *
 * No Ruby usage (internal function)
 *
 * @param op the CompositeOperator
 * @return the name
 */
static const char *
CompositeOperator_name(CompositeOperator op)
{
    switch (op)
    {
        ENUM_TO_NAME(AddCompositeOp)
        ENUM_TO_NAME(AtopCompositeOp)
        ENUM_TO_NAME(BlendCompositeOp)
        ENUM_TO_NAME(BlurCompositeOp)
        ENUM_TO_NAME(BumpmapCompositeOp)
        ENUM_TO_NAME(ChangeMaskCompositeOp)
        ENUM_TO_NAME(ClearCompositeOp)
        ENUM_TO_NAME(ColorBurnCompositeOp)
        ENUM_TO_NAME(ColorDodgeCompositeOp)
        ENUM_TO_NAME(ColorizeCompositeOp)
        ENUM_TO_NAME(CopyBlueCompositeOp)
        ENUM_TO_NAME(CopyCompositeOp)
        ENUM_TO_NAME(CopyCyanCompositeOp)
        ENUM_TO_NAME(CopyMagentaCompositeOp)
        ENUM_TO_NAME(CopyYellowCompositeOp)
        ENUM_TO_NAME(CopyBlackCompositeOp)
        ENUM_TO_NAME(CopyGreenCompositeOp)
        ENUM_TO_NAME(CopyOpacityCompositeOp)
        ENUM_TO_NAME(CopyRedCompositeOp)
        ENUM_TO_NAME(DarkenCompositeOp)
        ENUM_TO_NAME(DarkenIntensityCompositeOp)
        ENUM_TO_NAME(DistortCompositeOp)
        ENUM_TO_NAME(DivideCompositeOp)
        ENUM_TO_NAME(DivideSrcCompositeOp)
        ENUM_TO_NAME(DstAtopCompositeOp)
        ENUM_TO_NAME(DstCompositeOp)
        ENUM_TO_NAME(DstInCompositeOp)
        ENUM_TO_NAME(DstOutCompositeOp)
        ENUM_TO_NAME(DstOverCompositeOp)
        ENUM_TO_NAME(DifferenceCompositeOp)
        ENUM_TO_NAME(DisplaceCompositeOp)
        ENUM_TO_NAME(DissolveCompositeOp)
        ENUM_TO_NAME(ExclusionCompositeOp)
        ENUM_TO_NAME(HardLightCompositeOp)
#if defined(IMAGEMAGICK_GREATER_THAN_EQUAL_6_8_9)
        ENUM_TO_NAME(HardMixCompositeOp)
#endif
        ENUM_TO_NAME(HueCompositeOp)
        ENUM_TO_NAME(InCompositeOp)
        ENUM_TO_NAME(LightenCompositeOp)
        ENUM_TO_NAME(LightenIntensityCompositeOp)
        ENUM_TO_NAME(LinearBurnCompositeOp)
        ENUM_TO_NAME(LinearDodgeCompositeOp)
        ENUM_TO_NAME(LinearLightCompositeOp)
        ENUM_TO_NAME(LuminizeCompositeOp)
        ENUM_TO_NAME(MathematicsCompositeOp)
        ENUM_TO_NAME(MinusCompositeOp)
        ENUM_TO_NAME(MinusSrcCompositeOp)
        ENUM_TO_NAME(ModulateCompositeOp)
        ENUM_TO_NAME(MultiplyCompositeOp)
        ENUM_TO_NAME(NoCompositeOp)
        ENUM_TO_NAME(OutCompositeOp)
        ENUM_TO_NAME(OverCompositeOp)
        ENUM_TO_NAME(OverlayCompositeOp)
        ENUM_TO_NAME(PegtopLightCompositeOp)
        ENUM_TO_NAME(PinLightCompositeOp)
        ENUM_TO_NAME(PlusCompositeOp)
        ENUM_TO_NAME(ReplaceCompositeOp)
        ENUM_TO_NAME(SaturateCompositeOp)
        ENUM_TO_NAME(ScreenCompositeOp)
        ENUM_TO_NAME(SoftLightCompositeOp)
        ENUM_TO_NAME(SrcAtopCompositeOp)
        ENUM_TO_NAME(SrcCompositeOp)
        ENUM_TO_NAME(SrcInCompositeOp)
        ENUM_TO_NAME(SrcOutCompositeOp)
        ENUM_TO_NAME(SrcOverCompositeOp)
        ENUM_TO_NAME(SubtractCompositeOp)
        ENUM_TO_NAME(ThresholdCompositeOp)
        ENUM_TO_NAME(VividLightCompositeOp)
        ENUM_TO_NAME(XorCompositeOp)
        default:
        ENUM_TO_NAME(UndefinedCompositeOp)
    }
}


/**
 * Construct a CompositeOperator enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param op the CompositeOperator
 * @return a new CompositeOperator enumerator
 */
VALUE
CompositeOperator_new(CompositeOperator op)
{
    const char *name = CompositeOperator_name(op);
    return rm_enum_new(Class_CompositeOperator, ID2SYM(rb_intern(name)), INT2FIX(op));
}


/**
 * Return the name of a CompressionType enum as a string.
 *
 * No Ruby usage (internal function)
 *
 * @param ct the CompressionType
 * @return the name
 */
static const char *
CompressionType_name(CompressionType ct)
{
    switch (ct)
    {
        ENUM_TO_NAME(NoCompression)
        ENUM_TO_NAME(B44Compression)
        ENUM_TO_NAME(B44ACompression)
        ENUM_TO_NAME(BZipCompression)
        ENUM_TO_NAME(DXT1Compression)
        ENUM_TO_NAME(DXT3Compression)
        ENUM_TO_NAME(DXT5Compression)
        ENUM_TO_NAME(FaxCompression)
        ENUM_TO_NAME(Group4Compression)
        ENUM_TO_NAME(JPEGCompression)
        ENUM_TO_NAME(JPEG2000Compression)
        ENUM_TO_NAME(LosslessJPEGCompression)
        ENUM_TO_NAME(LZWCompression)
        ENUM_TO_NAME(PizCompression)
        ENUM_TO_NAME(Pxr24Compression)
        ENUM_TO_NAME(RLECompression)
        ENUM_TO_NAME(ZipCompression)
        ENUM_TO_NAME(ZipSCompression)
        ENUM_TO_NAME(LZMACompression)
        ENUM_TO_NAME(JBIG1Compression)
        ENUM_TO_NAME(JBIG2Compression)
        default:
        ENUM_TO_NAME(UndefinedCompression)
    }
}


/**
 * Construct a CompressionType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param ct the CompressionType
 * @return a new CompressionType enumerator
 */
VALUE
CompressionType_new(CompressionType ct)
{
    const char *name = CompressionType_name(ct);
    return rm_enum_new(Class_CompressionType, ID2SYM(rb_intern(name)), INT2FIX(ct));
}


/**
 * Return the name of a DisposeType enum as a string.
 *
 * No Ruby usage (internal function)
 *
 * @param type the DisposeType
 * @return the name
 */
static const char *
DisposeType_name(DisposeType type)
{
    switch(type)
    {
        ENUM_TO_NAME(BackgroundDispose)
        ENUM_TO_NAME(NoneDispose)
        ENUM_TO_NAME(PreviousDispose)
        default:
        ENUM_TO_NAME(UndefinedDispose)
    }
}


/**
 * Construct a DisposeType enum object for the specified value..new.
 *
 * No Ruby usage (internal function)
 *
 * @param type the DisposeType
 * @return a new DisposeType enumerator
 */
VALUE
DisposeType_new(DisposeType type)
{
    const char *name = DisposeType_name(type);
    return rm_enum_new(Class_DisposeType, ID2SYM(rb_intern(name)), INT2FIX(type));
}


/**
 * Return the name of a EndianType enum as a string.
 *
 * No Ruby usage (internal function)
 *
 * @param type the EndianType
 * @return the name
 */
static const char *
EndianType_name(EndianType type)
{
    switch(type)
    {
        ENUM_TO_NAME(LSBEndian)
        ENUM_TO_NAME(MSBEndian)
        default:
        ENUM_TO_NAME(UndefinedEndian)
    }
}


/**
 * Construct an EndianType enum object.
 *
 * No Ruby usage (internal function)
 *
 * @param type the EndianType
 * @return a new EndianType enumerator
 */
VALUE
EndianType_new(EndianType type)
{
    const char *name = EndianType_name(type);
    return rm_enum_new(Class_EndianType, ID2SYM(rb_intern(name)), INT2FIX(type));
}


/**
 * Return the name of a FilterTypes enum as a string.
 *
 * No Ruby usage (internal function)
 *
 * @param type the FilterTypes
 * @return the name
 */
static const char *
FilterTypes_name(FilterTypes type)
{
    switch(type)
    {
        ENUM_TO_NAME(PointFilter)
        ENUM_TO_NAME(BoxFilter)
        ENUM_TO_NAME(TriangleFilter)
        ENUM_TO_NAME(HermiteFilter)
        ENUM_TO_NAME(HanningFilter)
        ENUM_TO_NAME(HammingFilter)
        ENUM_TO_NAME(BlackmanFilter)
        ENUM_TO_NAME(GaussianFilter)
        ENUM_TO_NAME(QuadraticFilter)
        ENUM_TO_NAME(CubicFilter)
        ENUM_TO_NAME(CatromFilter)
        ENUM_TO_NAME(MitchellFilter)
        ENUM_TO_NAME(LanczosFilter)
        ENUM_TO_NAME(BesselFilter)
        ENUM_TO_NAME(SincFilter)
        ENUM_TO_NAME(KaiserFilter)
        ENUM_TO_NAME(WelshFilter)
        ENUM_TO_NAME(ParzenFilter)
        ENUM_TO_NAME(LagrangeFilter)
        ENUM_TO_NAME(BohmanFilter)
        ENUM_TO_NAME(BartlettFilter)
        // ENUM_TO_NAME(JincFilter) is alias of BesselFilter
        ENUM_TO_NAME(SincFastFilter)
        ENUM_TO_NAME(LanczosSharpFilter)
        ENUM_TO_NAME(Lanczos2Filter)
        ENUM_TO_NAME(Lanczos2SharpFilter)
        ENUM_TO_NAME(RobidouxFilter)
        ENUM_TO_NAME(RobidouxSharpFilter)
        ENUM_TO_NAME(CosineFilter)
        ENUM_TO_NAME(SplineFilter)
#if defined(IMAGEMAGICK_GREATER_THAN_EQUAL_6_8_9)
        ENUM_TO_NAME(LanczosRadiusFilter)
#endif
        default:
        ENUM_TO_NAME(UndefinedFilter)
    }
}


/**
 * Construct an FilterTypes enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param type the FilterTypes
 * @return a new FilterTypes enumerator
 */
VALUE
FilterTypes_new(FilterTypes type)
{
    const char *name = FilterTypes_name(type);
    return rm_enum_new(Class_FilterTypes, ID2SYM(rb_intern(name)), INT2FIX(type));
}


/**
 * Return the name of a GravityType enum as a string.
 *
 * No Ruby usage (internal function)
 *
 * @param type the GravityType
 * @return the name
 */
static const char *
GravityType_name(GravityType type)
{
    switch(type)
    {
        ENUM_TO_NAME(NorthWestGravity)
        ENUM_TO_NAME(NorthGravity)
        ENUM_TO_NAME(NorthEastGravity)
        ENUM_TO_NAME(WestGravity)
        ENUM_TO_NAME(CenterGravity)
        ENUM_TO_NAME(EastGravity)
        ENUM_TO_NAME(SouthWestGravity)
        ENUM_TO_NAME(SouthGravity)
        ENUM_TO_NAME(SouthEastGravity)
        ENUM_TO_NAME(StaticGravity)
        default:
        ENUM_TO_NAME(UndefinedGravity)
    }
}


/**
 * Construct an GravityType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param type the GravityType
 * @return a new GravityType enumerator
 */
VALUE
GravityType_new(GravityType type)
{
    const char *name = GravityType_name(type);
    return rm_enum_new(Class_GravityType, ID2SYM(rb_intern(name)), INT2FIX(type));
}


/**
 * Return the name of a ImageLayerMethod enum as a string.
 *
 * No Ruby usage (internal function)
 *
 * @param method the ImageLayerMethod
 * @return the name
 */
static const char *
ImageLayerMethod_name(ImageLayerMethod method)
{
    switch(method)
    {
        ENUM_TO_NAME(CompareAnyLayer)
        ENUM_TO_NAME(CompareClearLayer)
        ENUM_TO_NAME(CompareOverlayLayer)
        ENUM_TO_NAME(OptimizeLayer)
        ENUM_TO_NAME(OptimizePlusLayer)
        ENUM_TO_NAME(CoalesceLayer)
        ENUM_TO_NAME(DisposeLayer)
        ENUM_TO_NAME(OptimizeTransLayer)
        ENUM_TO_NAME(OptimizeImageLayer)
        ENUM_TO_NAME(RemoveDupsLayer)
        ENUM_TO_NAME(RemoveZeroLayer)
        ENUM_TO_NAME(CompositeLayer)
        ENUM_TO_NAME(MergeLayer)
        ENUM_TO_NAME(MosaicLayer)
        ENUM_TO_NAME(FlattenLayer)
        ENUM_TO_NAME(TrimBoundsLayer)
        default:
        ENUM_TO_NAME(UndefinedLayer)
    }
}


/**
 * Construct an ImageLayerMethod enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param method the ImageLayerMethod
 * @return a new ImageLayerMethod enumerator
 */
VALUE
ImageLayerMethod_new(ImageLayerMethod method)
{
    const char *name = ImageLayerMethod_name(method);
    return rm_enum_new(Class_ImageLayerMethod, ID2SYM(rb_intern(name)), INT2FIX(method));
}


/**
 * Return the name of a ImageType enum as a string.
 *
 * No Ruby usage (internal function)
 *
 * @param type the ImageType
 * @return the name
 */
static const char *
ImageType_name(ImageType type)
{
    switch(type)
    {
        ENUM_TO_NAME(BilevelType)
        ENUM_TO_NAME(GrayscaleType)
        ENUM_TO_NAME(GrayscaleMatteType)
        ENUM_TO_NAME(PaletteType)
        ENUM_TO_NAME(PaletteMatteType)
        ENUM_TO_NAME(TrueColorType)
        ENUM_TO_NAME(TrueColorMatteType)
        ENUM_TO_NAME(ColorSeparationType)
        ENUM_TO_NAME(ColorSeparationMatteType)
        ENUM_TO_NAME(OptimizeType)
        ENUM_TO_NAME(PaletteBilevelMatteType)
        default:
        ENUM_TO_NAME(UndefinedType)
    }
}


/**
 * Construct an ImageType enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param type the ImageType
 * @return a new ImageType enumerator
 */
VALUE
ImageType_new(ImageType type)
{
    const char *name = ImageType_name(type);
    return rm_enum_new(Class_ImageType, ID2SYM(rb_intern(name)), INT2FIX(type));
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
 * Return the name of a InterpolatePixelMethod enum as a string.
 *
 * No Ruby usage (internal function)
 *
 * @param interpolate the InterpolatePixelMethod
 * @return the name
 */
static const char *
InterpolatePixelMethod_name(InterpolatePixelMethod interpolate)
{
    switch(interpolate)
    {
        ENUM_TO_NAME(AverageInterpolatePixel)
        ENUM_TO_NAME(BicubicInterpolatePixel)
        ENUM_TO_NAME(BilinearInterpolatePixel)
        ENUM_TO_NAME(FilterInterpolatePixel)
        ENUM_TO_NAME(IntegerInterpolatePixel)
        ENUM_TO_NAME(MeshInterpolatePixel)
        ENUM_TO_NAME(NearestNeighborInterpolatePixel)
        ENUM_TO_NAME(SplineInterpolatePixel)
        ENUM_TO_NAME(Average9InterpolatePixel)
        ENUM_TO_NAME(Average16InterpolatePixel)
        ENUM_TO_NAME(BlendInterpolatePixel)
        ENUM_TO_NAME(BackgroundInterpolatePixel)
        ENUM_TO_NAME(CatromInterpolatePixel)
        default:
        ENUM_TO_NAME(UndefinedInterpolatePixel)
    }
}


/**
 * Construct an InterpolatePixelMethod enum object for the specified value.
 *
 * No Ruby usage (internal function)
 *
 * @param interpolate the InterpolatePixelMethod
 * @return a new InterpolatePixelMethod enumerator
 */
VALUE
InterpolatePixelMethod_new(InterpolatePixelMethod interpolate)
{
    const char *name = InterpolatePixelMethod_name(interpolate);
    return rm_enum_new(Class_InterpolatePixelMethod, ID2SYM(rb_intern(name)), INT2FIX(interpolate));
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
 * Return the string representation of a VirtualPixelMethod value.
 *
 * No Ruby usage (internal function)
 *
 * @param method the VirtualPixelMethod
 * @return the name
 */
static const char *
VirtualPixelMethod_name(VirtualPixelMethod method)
{
    switch (method)
    {
        ENUM_TO_NAME(EdgeVirtualPixelMethod)
        ENUM_TO_NAME(MirrorVirtualPixelMethod)
        ENUM_TO_NAME(TileVirtualPixelMethod)
        ENUM_TO_NAME(TransparentVirtualPixelMethod)
        ENUM_TO_NAME(BackgroundVirtualPixelMethod)
        ENUM_TO_NAME(DitherVirtualPixelMethod)
        ENUM_TO_NAME(RandomVirtualPixelMethod)
        ENUM_TO_NAME(ConstantVirtualPixelMethod)
        ENUM_TO_NAME(MaskVirtualPixelMethod)
        ENUM_TO_NAME(BlackVirtualPixelMethod)
        ENUM_TO_NAME(GrayVirtualPixelMethod)
        ENUM_TO_NAME(WhiteVirtualPixelMethod)
        ENUM_TO_NAME(HorizontalTileVirtualPixelMethod)
        ENUM_TO_NAME(VerticalTileVirtualPixelMethod)
        ENUM_TO_NAME(HorizontalTileEdgeVirtualPixelMethod)
        ENUM_TO_NAME(VerticalTileEdgeVirtualPixelMethod)
        ENUM_TO_NAME(CheckerTileVirtualPixelMethod)
        default:
        ENUM_TO_NAME(UndefinedVirtualPixelMethod)
    }
}


/**
 * Construct a VirtualPixelMethod enum for a specified VirtualPixelMethod value.
 *
 * No Ruby usage (internal function)
 *
 * @param style theVirtualPixelMethod
 * @return a new VirtualPixelMethod enumerator
 */
VALUE
VirtualPixelMethod_new(VirtualPixelMethod style)
{
    const char *name = VirtualPixelMethod_name(style);
    return rm_enum_new(Class_VirtualPixelMethod, ID2SYM(rb_intern(name)), INT2FIX(style));
}

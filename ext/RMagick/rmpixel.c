/**************************************************************************//**
 * Contains Pixel class methods.
 *
 * Copyright &copy; 2002 - 2009 by Timothy P. Hunter
 *
 * Changes since Nov. 2009 copyright &copy; by Benjamin Thomas and Omer Bar-or
 *
 * @file     rmpixel.c
 * @version  $Id: rmpixel.c,v 1.7 2009/12/21 10:34:58 baror Exp $
 * @author   Tim Hunter
 ******************************************************************************/

#include "rmagick.h"

#if defined(IMAGEMAGICK_6)
    #define QueryColorname QueryMagickColorname
#endif


static VALUE color_arg_rescue(VALUE, VALUE ATTRIBUTE_UNUSED) ATTRIBUTE_NORETURN;
static void Color_Name_to_PixelColor(PixelColor *, VALUE);


/**
 * Free the storage associated with a Pixel object.
 *
 * No Ruby usage (internal function)
 *
 * @param pixel the Pixel object to destroy
 */
void
destroy_Pixel(Pixel *pixel)
{
    xfree(pixel);
}


/**
 * Get Pixel red value.
 *
 * @return [Numeric] the red value
 */
VALUE
Pixel_red(VALUE self)
{
    IMPLEMENT_ATTR_READER(Pixel, red, int);
}

/**
 * Get Pixel green value.
 *
 * @return [Numeric] the green value
 */
VALUE
Pixel_green(VALUE self)
{
    IMPLEMENT_ATTR_READER(Pixel, green, int);
}

/**
 * Get Pixel blue value.
 *
 * @return [Numeric] the blue value
 */
VALUE
Pixel_blue(VALUE self)
{
    IMPLEMENT_ATTR_READER(Pixel, blue, int);
}

/**
 * Get Pixel alpha value.
 *
 * @return [Numeric] the alpha value
 */
VALUE
Pixel_alpha(VALUE self)
{
    Pixel *pixel;
    Data_Get_Struct(self, Pixel, pixel);
#if defined(IMAGEMAGICK_7)
    return C_int_to_R_int(pixel->alpha);
#else
    return C_int_to_R_int(QuantumRange - pixel->opacity);
#endif
}

/**
 * Set Pixel red value.
 *
 * - Pixel is Observable. Setters call {Magick::Pixel#changed},
 *   {Magick::Pixel#notify_observers}
 * - Setters return their argument values for backward compatibility to when
 *   Pixel was a Struct class.
 *
 * @param v [Numeric] the red value
 * @return [Numeric] the given red value
 */
VALUE
Pixel_red_eq(VALUE self, VALUE v)
{
    Pixel *pixel;

    rb_check_frozen(self);
    Data_Get_Struct(self, Pixel, pixel);
    pixel->red = APP2QUANTUM(v);
    rb_funcall(self, rm_ID_changed, 0);
    rb_funcall(self, rm_ID_notify_observers, 1, self);
    return QUANTUM2NUM((pixel->red));
}

/**
 * Set Pixel green value.
 *
 * - Pixel is Observable. Setters call {Magick::Pixel#changed},
 *   {Magick::Pixel#notify_observers}
 * - Setters return their argument values for backward compatibility to when
 *   Pixel was a Struct class.
 *
 * @param v [Numeric] the green value
 * @return [Numeric] the given green value
 */
VALUE
Pixel_green_eq(VALUE self, VALUE v)
{
    Pixel *pixel;

    rb_check_frozen(self);
    Data_Get_Struct(self, Pixel, pixel);
    pixel->green = APP2QUANTUM(v);
    rb_funcall(self, rm_ID_changed, 0);
    rb_funcall(self, rm_ID_notify_observers, 1, self);
    return QUANTUM2NUM((pixel->green));
}

/**
 * Set Pixel blue value.
 *
 * - Pixel is Observable. Setters call {Magick::Pixel#changed},
 *   {Magick::Pixel#notify_observers}
 * - Setters return their argument values for backward compatibility to when
 *   Pixel was a Struct class.
 *
 * @param v [Numeric] the blue value
 * @return [Numeric] the given blue value
 */
VALUE
Pixel_blue_eq(VALUE self, VALUE v)
{
    Pixel *pixel;

    rb_check_frozen(self);
    Data_Get_Struct(self, Pixel, pixel);
    pixel->blue = APP2QUANTUM(v);
    rb_funcall(self, rm_ID_changed, 0);
    rb_funcall(self, rm_ID_notify_observers, 1, self);
    return QUANTUM2NUM((pixel->blue));
}

/**
 * Set Pixel alpha value.
 *
 * - Pixel is Observable. Setters call {Magick::Pixel#changed},
 *   {Magick::Pixel#notify_observers}
 * - Setters return their argument values for backward compatibility to when
 *   Pixel was a Struct class.
 *
 * @param v [Numeric] the alpha value
 * @return [Numeric] the given alpha value
 */
VALUE
Pixel_alpha_eq(VALUE self, VALUE v)
{
    Pixel *pixel;

    rb_check_frozen(self);
    Data_Get_Struct(self, Pixel, pixel);
#if defined(IMAGEMAGICK_7)
    pixel->alpha = APP2QUANTUM(v);
    rb_funcall(self, rm_ID_changed, 0);
    rb_funcall(self, rm_ID_notify_observers, 1, self);
    return QUANTUM2NUM(pixel->alpha);
#else
    pixel->opacity = QuantumRange - APP2QUANTUM(v);
    rb_funcall(self, rm_ID_changed, 0);
    rb_funcall(self, rm_ID_notify_observers, 1, self);
    return QUANTUM2NUM(QuantumRange - pixel->opacity);
#endif
}

/**
 * Get Pixel cyan value.
 *
 * @return [Numeric] the cyan value
 */
VALUE
Pixel_cyan(VALUE self)
{
    Pixel *pixel;

    Data_Get_Struct(self, Pixel, pixel);
    return INT2NUM(pixel->red);
}

/**
 * Set Pixel cyan value.
 *
 * - Pixel is Observable. Setters call {Magick::Pixel#changed},
 *   {Magick::Pixel#notify_observers}
 * - Setters return their argument values for backward compatibility to when
 *   Pixel was a Struct class.
 *
 * @param v [Numeric] the cyan value
 * @return [Numeric] the given cyan value
 */
VALUE
Pixel_cyan_eq(VALUE self, VALUE v)
{
    Pixel *pixel;

    rb_check_frozen(self);
    Data_Get_Struct(self, Pixel, pixel);
    pixel->red = APP2QUANTUM(v);
    rb_funcall(self, rm_ID_changed, 0);
    rb_funcall(self, rm_ID_notify_observers, 1, self);
    return QUANTUM2NUM(pixel->red);
}

/**
 * Get Pixel magenta value.
 *
 * @return [Numeric] the magenta value
 */
VALUE
Pixel_magenta(VALUE self)
{
    Pixel *pixel;

    Data_Get_Struct(self, Pixel, pixel);
    return INT2NUM(pixel->green);
}

/**
 * Set Pixel magenta value.
 *
 * - Pixel is Observable. Setters call {Magick::Pixel#changed},
 *   {Magick::Pixel#notify_observers}
 * - Setters return their argument values for backward compatibility to when
 *   Pixel was a Struct class.
 *
 * @param v [Numeric] the magenta value
 * @return [Numeric] the given magenta value
 */
VALUE
Pixel_magenta_eq(VALUE self, VALUE v)
{
    Pixel *pixel;

    rb_check_frozen(self);
    Data_Get_Struct(self, Pixel, pixel);
    pixel->green = APP2QUANTUM(v);
    rb_funcall(self, rm_ID_changed, 0);
    rb_funcall(self, rm_ID_notify_observers, 1, self);
    return QUANTUM2NUM(pixel->green);
}

/**
 * Get Pixel yellow value.
 *
 * @return [Numeric] the yellow value
 */
VALUE
Pixel_yellow(VALUE self)
{
    Pixel *pixel;

    Data_Get_Struct(self, Pixel, pixel);
    return INT2NUM(pixel->blue);
}

/**
 * Set Pixel yellow value.
 *
 * - Pixel is Observable. Setters call {Magick::Pixel#changed},
 *   {Magick::Pixel#notify_observers}
 * - Setters return their argument values for backward compatibility to when
 *   Pixel was a Struct class.
 *
 * @param v [Numeric] the yellow value
 * @return [Numeric] the given yellow value
 */
VALUE
Pixel_yellow_eq(VALUE self, VALUE v)
{
    Pixel *pixel;

    rb_check_frozen(self);
    Data_Get_Struct(self, Pixel, pixel);
    pixel->blue = APP2QUANTUM(v);
    rb_funcall(self, rm_ID_changed, 0);
    rb_funcall(self, rm_ID_notify_observers, 1, self);
    return QUANTUM2NUM(pixel->blue);
}

/**
 * Get Pixel black value.
 *
 * @return [Numeric] the black value
 */
VALUE
Pixel_black(VALUE self)
{
    Pixel *pixel;

    Data_Get_Struct(self, Pixel, pixel);
    return INT2NUM(pixel->black);
}

/**
 * Set Pixel black value.
 *
 * - Pixel is Observable. Setters call {Magick::Pixel#changed},
 *   {Magick::Pixel#notify_observers}
 * - Setters return their argument values for backward compatibility to when
 *   Pixel was a Struct class.
 *
 * @param v [Numeric] the black value
 * @return [Numeric] the given black value
 */
VALUE
Pixel_black_eq(VALUE self, VALUE v)
{
    Pixel *pixel;

    rb_check_frozen(self);
    Data_Get_Struct(self, Pixel, pixel);
    pixel->black = APP2QUANTUM(v);
    rb_funcall(self, rm_ID_changed, 0);
    rb_funcall(self, rm_ID_notify_observers, 1, self);
    return QUANTUM2NUM(pixel->black);
}


/**
 * Raise ArgumentError if the color name cannot be converted to a string via
 * rb_str_to_str.
 *
 * No Ruby usage (internal function)
 *
 * @param arg the argument to convert
 * @return 0
 * @throw ArgumentError
 */
static VALUE
color_arg_rescue(VALUE arg, VALUE raised_exc ATTRIBUTE_UNUSED)
{
    rb_raise(rb_eTypeError, "argument must be color name or pixel (%s given)",
            rb_class2name(CLASS_OF(arg)));
}


/**
 * Convert either a String color name or a Magick::Pixel to a PixelColor.
 *
 * No Ruby usage (internal function)
 *
 * @param pp the PixelColor to modify
 * @param color the color name or Magick::Pixel
 */
void
Color_to_PixelColor(PixelColor *pp, VALUE color)
{
    Pixel *pixel;

    // Allow color name or Pixel
    if (CLASS_OF(color) == Class_Pixel)
    {
        memset(pp, 0, sizeof(*pp));
        Data_Get_Struct(color, Pixel, pixel);
        pp->red     = pixel->red;
        pp->green   = pixel->green;
        pp->blue    = pixel->blue;
#if defined(IMAGEMAGICK_7)
        pp->black   = pixel->black;
        rm_set_pixelinfo_alpha(pp, pixel->alpha);
#else
        pp->opacity = pixel->opacity;
#endif
    }
    else
    {
        // require 'to_str' here instead of just 'to_s'.
        color = rb_rescue(rb_str_to_str, color, color_arg_rescue, color);
        Color_Name_to_PixelColor(pp, color);
    }
}


/**
 * Convert either a String color name or a {Magick::Pixel} to a Pixel.
 *
 * No Ruby usage (internal function)
 *
 * @param pp the Pixel to modify
 * @param color the color name or Magick::Pixel
 */
void
Color_to_Pixel(Pixel *pp, VALUE color)
{
    PixelColor pixel_color;

    memset(pp, 0, sizeof(*pp));
    // Allow color name or Pixel
    if (CLASS_OF(color) == Class_Pixel)
    {
        Pixel *pixel;

        Data_Get_Struct(color, Pixel, pixel);
        memcpy(pp, pixel, sizeof(Pixel));
    }
    else
    {
        Color_to_PixelColor(&pixel_color, color);
        pp->red   = pixel_color.red;
        pp->green = pixel_color.green;
        pp->blue  = pixel_color.blue;
#if defined(IMAGEMAGICK_7)
        pp->alpha = pixel_color.alpha;
        pp->black = pixel_color.black;
#else
        pp->opacity = pixel_color.opacity;
#endif
    }
}


/**
 * Convert a color name to a PixelColor
 *
 * No Ruby usage (internal function)
 *
 * @param color the PixelColor to modify
 * @param name_arg the coor name
 * @throw ArgumentError
 */
static void
Color_Name_to_PixelColor(PixelColor *color, VALUE name_arg)
{
    MagickBooleanType okay;
    char *name;
    ExceptionInfo *exception;

    exception = AcquireExceptionInfo();
    name = StringValueCStr(name_arg);
    okay = QueryColorCompliance(name, AllCompliance, color, exception);
    DestroyExceptionInfo(exception);
    if (!okay)
    {
        rb_raise(rb_eArgError, "invalid color name %s", name);
    }
}



/**
 * Allocate a Pixel object.
 *
 * @return [Magick::Pixel] a new Magick::Pixel object
 */
VALUE
Pixel_alloc(VALUE class)
{
    Pixel *pixel;

    pixel = ALLOC(Pixel);
    memset(pixel, '\0', sizeof(Pixel));
    return Data_Wrap_Struct(class, NULL, destroy_Pixel, pixel);
}


/**
 * "Case equal" operator for Pixel.
 *
 * @param other [Object] the other object
 * @return [Boolean] true or false
 */

VALUE
Pixel_case_eq(VALUE self, VALUE other)
{
    if (CLASS_OF(self) == CLASS_OF(other))
    {
        Pixel *this, *that;

        Data_Get_Struct(self, Pixel, this);
        Data_Get_Struct(other, Pixel, that);
        return (this->red == that->red
            && this->blue == that->blue
            && this->green == that->green
#if defined(IMAGEMAGICK_7)
            && this->alpha == that->alpha) ? Qtrue : Qfalse;
#else
            && this->opacity == that->opacity) ? Qtrue : Qfalse;
#endif
    }

    return Qfalse;
}


/**
 * Clone a Pixel.
 *
 * @return [Magick::Pixel] a clone object
 * @see #dup
 * @see #initialize_copy
 */
VALUE
Pixel_clone(VALUE self)
{
    VALUE clone;

    clone = Pixel_dup(self);
    if (OBJ_FROZEN(self))
    {
        OBJ_FREEZE(clone);
    }

    RB_GC_GUARD(clone);

    return clone;
}


/**
 * Duplicate a Pixel.
 *
 * @return [Magick::Pixel] a duplicated object
 * @see #clone
 * @see #initialize_copy
 */
VALUE
Pixel_dup(VALUE self)
{
    Pixel *pixel;
    VALUE dup;

    pixel = ALLOC(Pixel);
    memset(pixel, '\0', sizeof(Pixel));
    dup = Data_Wrap_Struct(CLASS_OF(self), NULL, destroy_Pixel, pixel);
    RB_GC_GUARD(dup);

    return rb_funcall(dup, rm_ID_initialize_copy, 1, self);
}


/**
 * Equality. Returns true only if receiver and other are the same object.
 *
 * @param other [Object] the other object
 * @return [Boolean] true if other is the same value, otherwise false
 */
VALUE
Pixel_eql_q(VALUE self, VALUE other)
{
    return NUM2INT(Pixel_spaceship(self, other)) == 0 ? Qtrue : Qfalse;
}


/**
 * Compare pixel values for equality.
 *
 * @overload fcmp(other, fuzz = 0.0, colorspace = Magick::RGBColorspace)
 *   @param other [Magick::Pixel] The pixel to which the receiver is compared
 *   @param fuzz [Float] The amount of fuzz to allow before the colors are considered to be different
 *   @param colorspace [Magick::ColorspaceType] The colorspace
 *   @return [Boolean] true if equal, otherwise false
 */
VALUE
Pixel_fcmp(int argc, VALUE *argv, VALUE self)
{
    double fuzz = 0.0;
    unsigned int equal;
    ColorspaceType colorspace = RGBColorspace;
    PixelColor this, that;
#if defined(IMAGEMAGICK_6)
    Image *image;
    Info *info;
#endif

    switch (argc)
    {
        case 3:
            VALUE_TO_ENUM(argv[2], colorspace, ColorspaceType);
        case 2:
            fuzz = NUM2DBL(argv[1]);
        case 1:
            // Allow 1 argument
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 to 3)", argc);
            break;
    }

    Color_to_PixelColor(&this, self);
    Color_to_PixelColor(&that, argv[0]);

#if defined(IMAGEMAGICK_7)
    this.fuzz = fuzz;
    this.colorspace = colorspace;
    that.fuzz = fuzz;
    that.colorspace = colorspace;
    equal = IsFuzzyEquivalencePixelInfo(&this, &that);
#else
    // The IsColorSimilar function expects to get the
    // colorspace and fuzz parameters from an Image structure.

    info = CloneImageInfo(NULL);
    if (!info)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }

    image = rm_acquire_image(info);

    // Delete Info now in case we have to raise an exception
    DestroyImageInfo(info);

    if (!image)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }

    image->colorspace = colorspace;
    image->fuzz = fuzz;

    equal = IsColorSimilar(image, &this, &that);
    DestroyImage(image);
#endif

    return equal ? Qtrue : Qfalse;
}


/**
 * Construct an {Magick::Pixel} corresponding to the given color name.
 *
 * - The "inverse" is {Image#to_color}, b/c the conversion of a pixel to a
 *   color name requires both a color depth and if the opacity value has
 *   meaning.
 *
 * @param name [String] the color name
 * @return [Magick::Pixel] a new Magic::Pixel object
 * @see Magick::Image#to_color
 * @see Magick::Pixel#to_color
 */
VALUE
Pixel_from_color(VALUE class ATTRIBUTE_UNUSED, VALUE name)
{
    PixelColor pp;
    ExceptionInfo *exception;
    MagickBooleanType okay;

    exception = AcquireExceptionInfo();
    okay = QueryColorCompliance(StringValueCStr(name), AllCompliance, &pp, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);

    if (!okay)
    {
        rb_raise(rb_eArgError, "invalid color name: %s", StringValueCStr(name));
    }

    return Pixel_from_PixelColor(&pp);
}


/**
 * Construct an RGB pixel.
 *
 * - 0 <= +hue+ < 360 OR "0%" <= +hue+ < "100%"
 * - 0 <= +saturation+ <= 255 OR "0%" <= +saturation+ <= "100%"
 * - 0 <= +lightness+ <= 255 OR "0%" <= +lightness+ <= "100%"
 * - 0 <= +alpha+ <= 1 (0 is transparent, 1 is opaque) OR "0%" <= +alpha+ <= "100%"
 *
 * @overload from_hsla(hue, saturation, lightness, alpha = 1.0)
 *   @param hue [Numeric, String] A value in the range.
 *   @param saturation [Numeric, String] A value in the range.
 *   @param lightness [Numeric, String] A value in the range.
 *   @param alpha [Numeric] The alpha value.
 *   @return [Magick::Pixel] a new Magick::Pixel object
 */
VALUE
Pixel_from_hsla(int argc, VALUE *argv, VALUE class ATTRIBUTE_UNUSED)
{
    double h, s, l, a = 1.0;
    MagickPixel pp;
    ExceptionInfo *exception;
    char name[50];
    MagickBooleanType alpha = MagickFalse;

    switch (argc)
    {
        case 4:
            a = rm_percentage(argv[3], 1.0);
            alpha = MagickTrue;
        case 3:
            // saturation and lightness are out of 255 in new ImageMagicks and
            // out of 100 in old ImageMagicks. Compromise: always use %.
            l = rm_percentage(argv[2], 255.0);
            s = rm_percentage(argv[1], 255.0);
            h = rm_percentage(argv[0], 360.0);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 3 or 4)", argc);
            break;
    }

    if (alpha && (a < 0.0 || a > 1.0))
    {
        rb_raise(rb_eRangeError, "alpha %g out of range [0.0, 1.0]", a);
    }
    if (l < 0.0 || l > 255.0)
    {
        rb_raise(rb_eRangeError, "lightness %g out of range [0.0, 255.0]", l);
    }
    if (s < 0.0 || s > 255.0)
    {
        rb_raise(rb_eRangeError, "saturation %g out of range [0.0, 255.0]", s);
    }
    if (h < 0.0 || h >= 360.0)
    {
        rb_raise(rb_eRangeError, "hue %g out of range [0.0, 360.0)", h);
    }

    memset(name, 0, sizeof(name));
    if (alpha)
    {
        snprintf(name, sizeof(name), "hsla(%-2.1f,%-2.1f,%-2.1f,%-2.1f)", h, s, l, a);
    }
    else
    {
        snprintf(name, sizeof(name), "hsl(%-2.1f,%-2.1f,%-2.1f)", h, s, l);
    }

    exception = AcquireExceptionInfo();

#if defined(IMAGEMAGICK_7)
    QueryColorCompliance(name, AllCompliance, &pp, exception);
#else
    QueryMagickColor(name, &pp, exception);
#endif
    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    return Pixel_from_MagickPixel(&pp);
}


/**
 * Create a Magick::Pixel object from a MagickPixel structure.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Bypasses normal Pixel.new, Pixel#initialize methods
 *
 * @param pp the MagickPixel
 * @return a new Magick::Pixel object
 */
VALUE
Pixel_from_MagickPixel(const MagickPixel *pp)
{
    Pixel *pixel;

    pixel          = ALLOC(Pixel);
    pixel->red     = pp->red;
    pixel->green   = pp->green;
    pixel->blue    = pp->blue;
#if defined(IMAGEMAGICK_7)
    pixel->alpha   = pp->alpha;
#else
    pixel->opacity = pp->opacity;
#endif
    pixel->black   = pp->index;

    return Data_Wrap_Struct(Class_Pixel, NULL, destroy_Pixel, pixel);
}


/**
 * Create a Magick::Pixel object from a PixelPacket structure.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Bypasses normal Pixel.new, Pixel#initialize methods
 *
 * @param pp the PixelPacket
 * @return a new Magick::Pixel object
 */
VALUE
Pixel_from_PixelPacket(const PixelPacket *pp)
{
    Pixel *pixel;

    pixel          = ALLOC(Pixel);
    pixel->red     = pp->red;
    pixel->green   = pp->green;
    pixel->blue    = pp->blue;
#if defined(IMAGEMAGICK_7)
    pixel->alpha   = pp->alpha;
    pixel->black   = pp->black;
#else
    pixel->opacity = pp->opacity;
    pixel->black   = 0;
#endif

    return Data_Wrap_Struct(Class_Pixel, NULL, destroy_Pixel, pixel);
}


/**
 * Create a Magick::Pixel object from a PixelColor structure.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Bypasses normal Pixel.new, Pixel#initialize methods
 *
 * @param pp the PixelColor
 * @return a new Magick::Pixel object
 */
VALUE
Pixel_from_PixelColor(const PixelColor *pp)
{
    Pixel *pixel;

    pixel          = ALLOC(Pixel);
    pixel->red     = pp->red;
    pixel->green   = pp->green;
    pixel->blue    = pp->blue;
#if defined(IMAGEMAGICK_7)
    pixel->alpha   = pp->alpha;
    pixel->black   = pp->black;
#else
    pixel->opacity = pp->opacity;
    pixel->black   = 0;
#endif

    return Data_Wrap_Struct(Class_Pixel, NULL, destroy_Pixel, pixel);
}


/**
 * Compute a hash-code.
 *
 * @return [Numeric] the hash of self
 */
VALUE
Pixel_hash(VALUE self)
{
    Pixel *pixel;
    unsigned int hash;

    Data_Get_Struct(self, Pixel, pixel);

    hash  = ScaleQuantumToChar(pixel->red)   << 24;
    hash += ScaleQuantumToChar(pixel->green) << 16;
    hash += ScaleQuantumToChar(pixel->blue)  << 8;
#if defined(IMAGEMAGICK_7)
    hash += ScaleQuantumToChar(pixel->alpha);
#else
    hash += ScaleQuantumToChar(QuantumRange - pixel->opacity);
#endif

    return UINT2NUM(hash >> 1);
}


/**
 * Initialize clone, dup methods.
 *
 * @param orig [Magick::Pixel] the original Pixel
 * @return [Magick::Pixel] self
 * @see #clone
 * @see #dup
 */
VALUE
Pixel_init_copy(VALUE self, VALUE orig)
{
    Pixel *copy, *original;

    Data_Get_Struct(orig, Pixel, original);
    Data_Get_Struct(self, Pixel, copy);

    *copy = *original;

    return self;
}


/**
 * Initialize Pixel object.
 *
 * @overload initialize(red = 0, green = 0, blue = 0, opacity = 0)
 *   @param red [Numeric] The red value
 *   @param green [Numeric] The green value
 *   @param blue [Numeric] The blue value
 *   @param opacity [Numeric] The opacity value
 *   @return [Magick::Pixel] self
 */
VALUE
Pixel_initialize(int argc, VALUE *argv, VALUE self)
{
    Pixel *pixel;

    Data_Get_Struct(self, Pixel, pixel);

#if defined(IMAGEMAGICK_7)
    pixel->alpha = OpaqueAlpha;
#endif

    switch(argc)
    {
        case 4:
#if defined(IMAGEMAGICK_7)
            if (argv[3] != Qnil)
            {
                pixel->alpha = APP2QUANTUM(argv[3]);
            }
#else
            if (argv[3] != Qnil)
            {
                pixel->opacity = APP2QUANTUM(argv[3]);
            }
#endif
        case 3:
            if (argv[2] != Qnil)
            {
                pixel->blue = APP2QUANTUM(argv[2]);
            }
        case 2:
            if (argv[1] != Qnil)
            {
                pixel->green = APP2QUANTUM(argv[1]);
            }
        case 1:
            if (argv[0] != Qnil)
            {
                pixel->red = APP2QUANTUM(argv[0]);
            }
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 4)", argc);
    }

    return self;
}


/**
 * Return the "intensity" of a pixel.
 *
 * @return [Numeric] the intensity
 */
VALUE
Pixel_intensity(VALUE self)
{
    Pixel *pixel;
    Quantum intensity;

    Data_Get_Struct(self, Pixel, pixel);

    intensity = ROUND_TO_QUANTUM((0.299*pixel->red)
                                + (0.587*pixel->green)
                                + (0.114*pixel->blue));

    return QUANTUM2NUM((unsigned long) intensity);
}


/**
 * Support Marshal.dump.
 *
 * @return [Hash] a representing the dumped pixel
 */
VALUE
Pixel_marshal_dump(VALUE self)
{
    Pixel *pixel;
    VALUE dpixel;

    Data_Get_Struct(self, Pixel, pixel);
    dpixel = rb_hash_new();
    rb_hash_aset(dpixel, CSTR2SYM("red"), QUANTUM2NUM(pixel->red));
    rb_hash_aset(dpixel, CSTR2SYM("green"), QUANTUM2NUM(pixel->green));
    rb_hash_aset(dpixel, CSTR2SYM("blue"), QUANTUM2NUM(pixel->blue));
#if defined(IMAGEMAGICK_7)
    rb_hash_aset(dpixel, CSTR2SYM("alpha"), QUANTUM2NUM(pixel->alpha));
#else
    rb_hash_aset(dpixel, CSTR2SYM("opacity"), QUANTUM2NUM(pixel->opacity));
#endif

    RB_GC_GUARD(dpixel);

    return dpixel;
}


/**
 * Support Marshal.load.
 *
 * @param dpixel [Hash] the dumped pixel
 * @return self
 */
VALUE
Pixel_marshal_load(VALUE self, VALUE dpixel)
{
    Pixel *pixel;

    Data_Get_Struct(self, Pixel, pixel);
    pixel->red = NUM2QUANTUM(rb_hash_aref(dpixel, CSTR2SYM("red")));
    pixel->green = NUM2QUANTUM(rb_hash_aref(dpixel, CSTR2SYM("green")));
    pixel->blue = NUM2QUANTUM(rb_hash_aref(dpixel, CSTR2SYM("blue")));
#if defined(IMAGEMAGICK_7)
    pixel->alpha = NUM2QUANTUM(rb_hash_aref(dpixel, CSTR2SYM("alpha")));
#else
    pixel->opacity = NUM2QUANTUM(rb_hash_aref(dpixel, CSTR2SYM("opacity")));
#endif
    return self;
}


/**
 * Support Comparable mixin.
 *
 * @param other [Object] the other Pixel
 * @return [-1, 0, 1, nil] the result of compare
 */
VALUE
Pixel_spaceship(VALUE self, VALUE other)
{
    Pixel *this, *that;

    Data_Get_Struct(self, Pixel, this);
    Data_Get_Struct(other, Pixel, that);

    if (this->red != that->red)
    {
        return INT2NUM((this->red - that->red)/abs((int)(this->red - that->red)));
    }
    else if(this->green != that->green)
    {
        return INT2NUM((this->green - that->green)/abs((int)(this->green - that->green)));
    }
    else if(this->blue != that->blue)
    {
        return INT2NUM((this->blue - that->blue)/abs((int)(this->blue - that->blue)));
    }
#if defined(IMAGEMAGICK_7)
    else if(this->alpha != that->alpha)
    {
        return INT2NUM((this->alpha - that->alpha)/abs((int)(this->alpha - that->alpha)));
    }
#else
    else if(this->opacity != that->opacity)
    {
        return INT2NUM(((QuantumRange - this->opacity) - (QuantumRange - that->opacity))/abs((int)((QuantumRange - this->opacity) - (QuantumRange - that->opacity))));
    }
#endif

    // Values are equal, check class.

    return rb_funcall(CLASS_OF(self), rb_intern("<=>"), 1, CLASS_OF(other));

}


/**
 * Return [+hue+, +saturation+, +lightness+, +alpha+] in the same ranges as
 * {Magick::Pixel.from_hsla}.
 *
 * @return [Array<Float>] an array with hsla data
 * @see Pixel.from_hsla
 */
VALUE
Pixel_to_hsla(VALUE self)
{
    double hue, sat, lum, alpha;
    Pixel *pixel;
    VALUE hsla;

    Data_Get_Struct(self, Pixel, pixel);

    ConvertRGBToHSL(pixel->red, pixel->green, pixel->blue, &hue, &sat, &lum);
    hue *= 360.0;
    sat *= 255.0;
    lum *= 255.0;

#if defined(IMAGEMAGICK_7)
    if (pixel->alpha == OpaqueAlpha)
    {
        alpha = 1.0;
    }
    else if (pixel->alpha == TransparentAlpha)
    {
        alpha = 0.0;
    }
    else
    {
        alpha = (double)(pixel->alpha) / (double)QuantumRange;
    }
#else
    if (pixel->opacity == OpaqueOpacity)
    {
        alpha = 1.0;
    }
    else if (pixel->opacity == TransparentOpacity)
    {
        alpha = 0.0;
    }
    else
    {
        alpha = (double)(QuantumRange - pixel->opacity) / (double)QuantumRange;
    }
#endif

    hsla = rb_ary_new3(4, rb_float_new(hue), rb_float_new(sat), rb_float_new(lum), rb_float_new(alpha));

    RB_GC_GUARD(hsla);

    return hsla;
}


/**
 * Convert a Pixel to a MagickPixel.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Same code as the private function SetMagickPixelPacket in ImageMagick.
 *
 * @param pixel the pixel
 * @param pp the MagickPixel to be modified
 */
static void
rm_set_magick_pixel_packet(Pixel *pixel, MagickPixel *pp)
{
    pp->red     = (MagickRealType) pixel->red;
    pp->green   = (MagickRealType) pixel->green;
    pp->blue    = (MagickRealType) pixel->blue;
#if defined(IMAGEMAGICK_7)
    pp->alpha   = (MagickRealType) pixel->alpha;
#else
    pp->opacity = (MagickRealType) pixel->opacity;
#endif
    pp->index   = (MagickRealType) 0.0;
}


/**
 * Return the color name corresponding to the pixel values.
 *
 * @overload to_color(compliance = Magick::AllCompliance, alpha = false, depth = Magick::MAGICKCORE_QUANTUM_DEPTH, hex = false)
 *   @param compliance [Magick::ComplianceType] A ComplianceType constant
 *   @param alpha [Boolean] If false, the pixel's alpha attribute is ignored
 *   @param depth [Numeric] An image depth
 *   @param hex [Boolean] If true, represent the color name in hex format
 *   @return [String] the color name as a String
 */
VALUE
Pixel_to_color(int argc, VALUE *argv, VALUE self)
{
    Info *info;
    Image *image;
    Pixel *pixel;
    MagickPixel mpp;
    MagickBooleanType hex = MagickFalse;
    char name[MaxTextExtent];
    ExceptionInfo *exception;
    ComplianceType compliance = AllCompliance;
    unsigned int alpha = MagickFalse;
    unsigned int depth = MAGICKCORE_QUANTUM_DEPTH;

    switch (argc)
    {
        case 4:
            hex = RTEST(argv[3]);
        case 3:
            depth = NUM2UINT(argv[2]);

            // Ensure depth is appropriate for the way xMagick was compiled.
            switch (depth)
            {
                case 8:
#if MAGICKCORE_QUANTUM_DEPTH == 16 || MAGICKCORE_QUANTUM_DEPTH == 32
                case 16:
#endif
#if MAGICKCORE_QUANTUM_DEPTH == 32
                case 32:
#endif
                    break;
                default:
                    rb_raise(rb_eArgError, "invalid depth (%d)", depth);
                    break;
            }
       case 2:
            alpha = RTEST(argv[1]);
        case 1:
            VALUE_TO_ENUM(argv[0], compliance, ComplianceType);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 2)", argc);
    }

    Data_Get_Struct(self, Pixel, pixel);

    info = CloneImageInfo(NULL);
    image = rm_acquire_image(info);
    DestroyImageInfo(info);

    if (!image)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue.");
    }

    exception = AcquireExceptionInfo();

    image->depth = depth;
#if defined(IMAGEMAGICK_7)
    if (alpha)
    {
        image->alpha_trait = BlendPixelTrait;
    }
#else
    image->matte = alpha;
#endif

    rm_init_magickpixel(image, &mpp);
    rm_set_magick_pixel_packet(pixel, &mpp);

    // Support for hex-format color names moved out of QueryMagickColorname
    // in 6.4.1-9. The 'hex' argument was removed as well.
    if (hex)
    {
        if (compliance == XPMCompliance)
        {
#if defined(IMAGEMAGICK_7)
            mpp.alpha_trait = UndefinedPixelTrait;
#else
            mpp.matte = MagickFalse;
#endif
            mpp.depth = (unsigned long) min(1.0 * image->depth, 16.0);
        }
        GetColorTuple(&mpp, MagickTrue, name);
    }
    else
    {
        QueryColorname(image, &mpp, compliance, name, exception);
    }

    DestroyImage(image);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);

    // Always return a string, even if it's ""
    return rb_str_new2(name);
}


/**
 * Return a string representation of a {Magick::Pixel} object.
 *
 * @return [String] the string
 */
VALUE
Pixel_to_s(VALUE self)
{
    Pixel *pixel;
    char buff[100];

    Data_Get_Struct(self, Pixel, pixel);
    snprintf(buff, sizeof(buff), "red=" QuantumFormat ", green=" QuantumFormat ", blue=" QuantumFormat ", alpha=" QuantumFormat,
            pixel->red, pixel->green, pixel->blue,
#if defined(IMAGEMAGICK_7)
            pixel->alpha);
#else
            (QuantumRange - pixel->opacity));
#endif
    return rb_str_new2(buff);
}


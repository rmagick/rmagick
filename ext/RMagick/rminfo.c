/**************************************************************************//**
 * Info class method definitions for RMagick.
 *
 * Copyright &copy; 2002 - 2009 by Timothy P. Hunter
 *
 * Changes since Nov. 2009 copyright &copy; by Benjamin Thomas and Omer Bar-or
 *
 * @file     rminfo.c
 * @version  $Id: rminfo.c,v 1.79 2009/12/20 02:33:33 baror Exp $
 * @author   Tim Hunter
 ******************************************************************************/

#include "rmagick.h"


/**
 * Return the value of the specified option.
 *
 * No Ruby usage (internal function)
 *
 * @param self this object
 * @param key the option key
 * @return the value of key
 */
static VALUE
get_option(VALUE self, const char *key)
{
    Info *info;
    const char *value;

    Data_Get_Struct(self, Info, info);

    value = GetImageOption(info, key);
    if (value)
    {
        return rb_str_new2(value);
    }
    return Qnil;
}

/**
 * Set the specified option to this value. If the value is nil just unset any
 * current value.
 *
 * No Ruby usage (internal function)
 *
 * @param self this object
 * @param key the option key
 * @param string the value
 * @return string
 */
static VALUE
set_option(VALUE self, const char *key, VALUE string)
{
    Info *info;

    Data_Get_Struct(self, Info, info);

    if (NIL_P(string))
    {
        DeleteImageOption(info, key);
    }
    else
    {
        char *value;

        value = StringValueCStr(string);
        SetImageOption(info, key, value);
    }
    return string;
}


/**
 * Set a color name as the value of the specified option
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Call QueryColorCompliance to validate color name.
 *
 * @param self this object
 * @param option the option
 * @param color the color name
 * @return color
 */
static VALUE set_color_option(VALUE self, const char *option, VALUE color)
{
    Info *info;
    PixelColor pp;
    MagickBooleanType okay;

    Data_Get_Struct(self, Info, info);

    if (NIL_P(color))
    {
        DeleteImageOption(info, option);
    }
    else
    {
        char *name;
        ExceptionInfo *exception;

        name = StringValueCStr(color);
        exception = AcquireExceptionInfo();
        okay = QueryColorCompliance(name, AllCompliance, &pp, exception);
        DestroyExceptionInfo(exception);
        if (!okay)
        {
            rb_raise(rb_eArgError, "invalid color name `%s'", name);
        }

        SetImageOption(info, option, name);
    }

    return color;
}


/**
 * Get an Image::Info option floating-point value.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Convert the string value to a float
 *
 * @param self this object
 * @param option the option name
 * @return the Image::Info option
 */
static VALUE get_dbl_option(VALUE self, const char *option)
{
    Info *info;
    const char *value;
    double d;
    long n;

    Data_Get_Struct(self, Info, info);

    value = GetImageOption(info, option);
    if (!value)
    {
        return Qnil;
    }

    d = atof(value);
    n = (long) floor(d);
    return d == (double)n ? LONG2NUM(n) : rb_float_new(d);
}


/**
 * Set an Image::Info option to a floating-point value.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - SetImageOption expects the value to be a string.
 *
 * @param self this object
 * @param option the option name
 * @param value the value
 * @return value
 */
static VALUE set_dbl_option(VALUE self, const char *option, VALUE value)
{
    Info *info;

    Data_Get_Struct(self, Info, info);

    if (NIL_P(value))
    {
        DeleteImageOption(info, option);
    }
    else
    {
        char buff[50];
        double d;
        int len;
        long n;

        d = NUM2DBL(value);
        n = floor(d);
        if (d == n)
        {
            len = snprintf(buff, sizeof(buff), "%-10ld", n);
        }
        else
        {
            len = snprintf(buff, sizeof(buff), "%-10.2f", d);
        }
        memset(buff+len, '\0', sizeof(buff)-len);
        SetImageOption(info, option, buff);
    }

    return value;
}


/**
 * Get antialias value
 *
 * @return [Boolean] true if antialias is enabled
 */
VALUE
Info_antialias(VALUE self)
{
    IMPLEMENT_ATTR_READER(Info, antialias, boolean);
}

/**
 * Set antialias value
 *
 * @param val [Boolean] true or false
 * @return [Boolean] the given value
 */
VALUE
Info_antialias_eq(VALUE self, VALUE val)
{
    IMPLEMENT_ATTR_WRITER(Info, antialias, boolean);
}

/** Maximum length of a format (@see Info_aref) */
#define MAX_FORMAT_LEN 60

/**
 * Get the value of the specified option for the specified format.
 *
 * - The 2 argument form is the original form. Added support for a single
 *   argument after ImageMagick started using Set/GetImageOption for options
 *   that aren't represented by fields in the ImageInfo structure.
 *
 * @overload [](format, key)
 *   @param format [String] An image format name such as "ps" or "tiff".
 *   @param key [String] A string that identifies the option.
 *
 * @overload [](key)
 *   @param key [String] A string that identifies the option.
 *
 * @return [String] The value of the option.
 */
VALUE
Info_aref(int argc, VALUE *argv, VALUE self)
{
    Info *info;
    char *format_p, *key_p;
    long format_l, key_l;
    const char *value;
    char fkey[MaxTextExtent];

    switch (argc)
    {
        case 2:
            format_p = rm_str2cstr(argv[0], &format_l);
            key_p = rm_str2cstr(argv[1], &key_l);
            if (format_l > MAX_FORMAT_LEN || format_l + key_l > MaxTextExtent-1)
            {
                rb_raise(rb_eArgError, "can't reference %.60s:%.1024s - too long", format_p, key_p);
            }

            snprintf(fkey, sizeof(fkey), "%.60s:%.*s", format_p, (int)(MaxTextExtent-61), key_p);
            break;

        case 1:
            strlcpy(fkey, StringValueCStr(argv[0]), sizeof(fkey));
            break;

        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or 2)", argc);
            break;

    }

    Data_Get_Struct(self, Info, info);
    value = GetImageOption(info, fkey);
    if (!value)
    {
        return Qnil;
    }

    return rb_str_new2(value);
}


/**
 * Define an option. An alternative to {Info#define}.
 * Use this method to set options for reading or writing certain image formats.
 *
 * - Essentially the same function as {Info#define} but paired with {Info#[]}
 * - If the value is nil it is equivalent to {Info#undefine}.
 *
 * @overload []=(format, key)
 *   @param format [String] An image format name such as "ps" or "tiff".
 *   @param key [String] A string that identifies the option.
 *
 * @overload []=(key)
 *   @param key [String] A string that identifies the option.
 *
 * @return [Magick::Image::Info] self
 * @see #[]
 * @see #define
 * @see #undefine
 */
VALUE
Info_aset(int argc, VALUE *argv, VALUE self)
{
    Info *info;
    VALUE value;
    char *format_p, *key_p, *value_p = NULL;
    long format_l, key_l;
    char ckey[MaxTextExtent];

    Data_Get_Struct(self, Info, info);

    switch (argc)
    {
        case 3:
            format_p = rm_str2cstr(argv[0], &format_l);
            key_p = rm_str2cstr(argv[1], &key_l);

            if (format_l > MAX_FORMAT_LEN || format_l+key_l > MaxTextExtent-1)
            {
                rb_raise(rb_eArgError, "%.60s:%.1024s not defined - too long", format_p, key_p);
            }

            snprintf(ckey, sizeof(ckey), "%.60s:%.*s", format_p, (int)(sizeof(ckey)-MAX_FORMAT_LEN), key_p);

            value = argv[2];
            break;

        case 2:
            strlcpy(ckey, StringValueCStr(argv[0]), sizeof(ckey));

            value = argv[1];
            break;

        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 or 3)", argc);
            break;
    }

    if (NIL_P(value))
    {
        DeleteImageOption(info, ckey);
    }
    else
    {
        unsigned int okay;

        /* Allow any argument that supports to_s */
        value = rb_String(value);
        value_p = StringValueCStr(value);

        okay = SetImageOption(info, ckey, value_p);
        if (!okay)
        {
            rb_warn("`%s' not defined - SetImageOption failed.", ckey);
            return Qnil;
        }
    }

    RB_GC_GUARD(value);

    return self;
}


/**
 * Get the attenuate value.
 *
 * @return [Float] the attenuate
 */
VALUE
Info_attenuate(VALUE self)
{
    return get_dbl_option(self, "attenuate");
}


/**
 * Set the attenuate value.
 *
 * @param value [Float] the attenuate
 * @return [Float] the attenuate
 */
VALUE
Info_attenuate_eq(VALUE self, VALUE value)
{
    return set_dbl_option(self, "attenuate", value);
}


/**
 * Get the authenticate value.
 *
 * @return [String] the authenticate
 */
VALUE
Info_authenticate(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
#if defined(IMAGEMAGICK_7)
    return C_str_to_R_str(GetImageOption(info, "authenticate"));
#else
    return C_str_to_R_str(info->authenticate);
#endif
}


/**
 * Set the authenticate value.
 *
 * @param passwd_arg [String] the authenticating password
 * @return [String] the given value
 */
VALUE
Info_authenticate_eq(VALUE self, VALUE passwd_arg)
{
    Info *info;
    char *passwd = NULL;

    Data_Get_Struct(self, Info, info);

    if (!NIL_P(passwd_arg))
    {
        passwd = StringValueCStr(passwd_arg);
    }

#if defined(IMAGEMAGICK_7)
    if (passwd)
    {
        SetImageOption(info, "authenticate", passwd);
    }
    else
    {
        RemoveImageOption(info, "authenticate");
    }
#else
    if (info->authenticate)
    {
        magick_free(info->authenticate);
        info->authenticate = NULL;
    }
    if (passwd)
    {
        magick_clone_string(&info->authenticate, passwd);
    }
#endif

    return passwd_arg;
}


/**
 * Return the name of the background color as a String
 *
 * @return [String] the name of the background color
 * @see Image#background_color
 */
VALUE
Info_background_color(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    return rm_pixelcolor_to_color_name_info(info, &info->background_color);
}


/**
 * Set the background color.
 *
 * @param bc_arg [Magick::Pixel, String] the background color
 * @return [Magick::Pixel, String] the given color
 */
VALUE
Info_background_color_eq(VALUE self, VALUE bc_arg)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    Color_to_PixelColor(&info->background_color, bc_arg);

    return bc_arg;
}

/**
 * Return the name of the border color as a String.
 *
 * @return [String] the border color name
 * @see Image#border_color
 */
VALUE
Info_border_color(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    return rm_pixelcolor_to_color_name_info(info, &info->border_color);
}

/**
 * set the border color
 *
 * @param bc_arg [Magick::Pixel, String] the border color
 * @return [Magick::Pixel, String] the given color
 */
VALUE
Info_border_color_eq(VALUE self, VALUE bc_arg)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    Color_to_PixelColor(&info->border_color, bc_arg);

    return bc_arg;
}



/**
 * Get a caption of image
 *
 * @return [String] the caption
 */
VALUE
Info_caption(VALUE self)
{
    return get_option(self, "caption");
}



/**
 * Assigns a caption to an image.
 *
 * @param caption [String] the caption
 * @return [String] the given value
 */
VALUE
Info_caption_eq(VALUE self, VALUE caption)
{
    return set_option(self, "caption", caption);
}


/**
 * Set the channels
 *
 * @overload channel(channel = Magick::AllChannels)
 *   @param channel [Magick::ChannelType] the channel
 *
 * @overload channel(*channels)
 *   @param channels [Magick::ChannelType] the multiple arguments of channel
 *
 * @return [Magick::Image::Info] self
 */
VALUE
Info_channel(int argc, VALUE *argv, VALUE self)
{
    Info *info;
    ChannelType channels;

    channels = extract_channels(&argc, argv);

    // Ensure all arguments consumed.
    if (argc > 0)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    Data_Get_Struct(self, Info, info);

    info->channel = channels;
    return self;
}


/**
 * Get the colorspace type.
 *
 * @return [Magick::ColorspaceType] the colorspace type
 */
VALUE
Info_colorspace(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    return ColorspaceType_find(info->colorspace);
}

/**
 * Set the colorspace type
 *
 * @param colorspace [Magick::ColorspaceType] the colorspace type
 * @return [Magick::ColorspaceType] the given colorspace
 */
VALUE
Info_colorspace_eq(VALUE self, VALUE colorspace)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    VALUE_TO_ENUM(colorspace, info->colorspace, ColorspaceType);
    return colorspace;
}

/**
 * Get the comment.
 *
 * @return [String] the comment
 */
VALUE Info_comment(VALUE self)
{
    return get_option(self, "Comment");
}

/**
 * Set the comment
 *
 * @param string [String] the comment
 * @return [String] the given comment
 */
VALUE Info_comment_eq(VALUE self, VALUE string)
{
    return set_option(self, "Comment", string);
}

/**
 * Get the compression type.
 *
 * @return [Magick::CompressionType] the compression type
 */
VALUE
Info_compression(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    return CompressionType_find(info->compression);
}

/**
 * Set the compression type
 *
 * @param type [Magick::CompressionType] the compression type
 * @return [Magick::CompressionType] the given type
 */
VALUE
Info_compression_eq(VALUE self, VALUE type)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    VALUE_TO_ENUM(type, info->compression, CompressionType);
    return type;
}

/**
 * Define an option.
 *
 * @overload Info#define(format, key, value = "")
 *   @param format [String] An image format name such as "ps" or "tiff".
 *   @param key [String] A string that identifies the option.
 *   @param value [String] A value of option
 *
 * @return [Magick::Image::Info] self
 */
VALUE
Info_define(int argc, VALUE *argv, VALUE self)
{
    Info *info;
    char *format, *key;
    const char *value = "";
    long format_l, key_l;
    char ckey[100];
    unsigned int okay;
    VALUE fmt_arg;

    Data_Get_Struct(self, Info, info);

    switch (argc)
    {
        case 3:
            /* Allow any argument that supports to_s */
            fmt_arg = rb_String(argv[2]);
            value = (const char *)StringValueCStr(fmt_arg);
        case 2:
            key = rm_str2cstr(argv[1], &key_l);
            format = rm_str2cstr(argv[0], &format_l);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 or 3)", argc);
    }

    if (2 + format_l + key_l > (long)sizeof(ckey))
    {
        rb_raise(rb_eArgError, "%.20s:%.20s not defined - format or key too long", format, key);
    }
    snprintf(ckey, sizeof(ckey), "%s:%s", format, key);

    DeleteImageOption(info, ckey);
    okay = SetImageOption(info, ckey, value);
    if (!okay)
    {
        rb_warn("%.20s=\"%.78s\" not defined - SetImageOption failed.", ckey, value);
        return Qnil;
    }

    RB_GC_GUARD(fmt_arg);

    return self;
}

/**
 * Get the delay value.
 *
 * @return [Numeric, nil] the delay
 */
VALUE
Info_delay(VALUE self)
{
    Info *info;
    const char *delay;
    char *p;

    Data_Get_Struct(self, Info, info);

    delay = GetImageOption(info, "delay");
    if (delay)
    {
        long d;

        d = strtol(delay, &p, 10);
        if (*p != '\0')
        {
            rb_raise(rb_eRangeError, "failed to convert %s to Numeric", delay);
        }
        return LONG2NUM(d);
    }
    return Qnil;
}

/**
 * Will raise an exception if `arg' can't be converted to an int.
 *
 * No Ruby usage (internal function)
 *
 * @param arg the argument
 * @return arg
 */
static VALUE
arg_is_integer(VALUE arg)
{
    return INT2NUM(NUM2INT(arg));
}

/**
 * Set the delay value.
 *
 * @param string [String] the delay
 * @return [String] the given value
 */
VALUE
Info_delay_eq(VALUE self, VALUE string)
{
    Info *info;
    int not_num;

    Data_Get_Struct(self, Info, info);

    if (NIL_P(string))
    {
        DeleteImageOption(info, "delay");
    }
    else
    {
        char dstr[20];
        int delay;

        not_num = 0;
        rb_protect(arg_is_integer, string, &not_num);
        if (not_num)
        {
            rb_raise(rb_eTypeError, "failed to convert %s into Integer", rb_class2name(CLASS_OF(string)));
        }
        delay = NUM2INT(string);
        snprintf(dstr, sizeof(dstr), "%d", delay);
        SetImageOption(info, "delay", dstr);
    }
    return string;
}

/**
 * Get the density value
 *
 * @return [String] the density
 */
VALUE
Info_density(VALUE self)
{
    IMPLEMENT_ATTR_READER(Info, density, str);
}

/**
 * Set the text rendering density geometry
 *
 * @param density_arg [String] the density
 * @return [String] the given value
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Info_density_eq(VALUE self, VALUE density_arg)
{
    Info *info;
    VALUE density;
    char *dens;

    Data_Get_Struct(self, Info, info);

    if (NIL_P(density_arg))
    {
        magick_free(info->density);
        info->density = NULL;
        return self;
    }

    density = rb_String(density_arg);
    dens = StringValueCStr(density);
    if (!IsGeometry(dens))
    {
        rb_raise(rb_eArgError, "invalid density geometry: %s", dens);
    }

    magick_clone_string(&info->density, dens);

    RB_GC_GUARD(density);

    return density_arg;
}

/**
 * Get the depth value
 *
 * @return [Numeric] the depth
 */
VALUE
Info_depth(VALUE self)
{
    IMPLEMENT_ATTR_READER(Info, depth, int);
}

/**
 * Set the depth (8, 16, 32, 64).
 *
 * @param depth [Numeric] the depth
 * @return [Numeric] the given depth
 */
VALUE
Info_depth_eq(VALUE self, VALUE depth)
{
    Info *info;
    unsigned long d;

    Data_Get_Struct(self, Info, info);
    d = NUM2ULONG(depth);
    switch (d)
    {
        case 8:                     // always okay
#if MAGICKCORE_QUANTUM_DEPTH == 16 || MAGICKCORE_QUANTUM_DEPTH == 32 || MAGICKCORE_QUANTUM_DEPTH == 64
        case 16:
#if MAGICKCORE_QUANTUM_DEPTH == 32 || MAGICKCORE_QUANTUM_DEPTH == 64
        case 32:
#if MAGICKCORE_QUANTUM_DEPTH == 64
        case 64:
#endif
#endif
#endif
            break;
        default:
            rb_raise(rb_eArgError, "invalid depth (%lu)", d);
            break;
    }

    info->depth = d;
    return depth;
}

/** A dispose option */
static struct
{
    const char *string; /**< the argument given by the user */
    const char *enum_name; /**< the enumerator name */
    DisposeType enumerator; /**< the enumerator itself */
} Dispose_Option[] = {
    { "Background", "BackgroundDispose", BackgroundDispose},
    { "None",       "NoneDispose",       NoneDispose},
    { "Previous",   "PreviousDispose",   PreviousDispose},
    { "Undefined",  "UndefinedDispose",  UndefinedDispose},
    { "0",          "UndefinedDispose",  UndefinedDispose},
    { "1",          "NoneDispose",       NoneDispose},
    { "2",          "BackgroundDispose", BackgroundDispose},
    { "3",          "PreviousDispose",   PreviousDispose},
};

/** Number of dispose options */
#define N_DISPOSE_OPTIONS (int)(sizeof(Dispose_Option)/sizeof(Dispose_Option[0]))


/**
 * Retrieve a dispose option string and convert it to a DisposeType enumerator.
 *
 * No Ruby usage (internal function)
 *
 * @param name the dispose string
 * @return the DisposeType enumerator
 */
DisposeType rm_dispose_to_enum(const char *name)
{
    DisposeType dispose = UndefinedDispose;
    int x;

    for (x = 0; x < N_DISPOSE_OPTIONS; x++)
    {
        if (strcmp(Dispose_Option[x].string, name) == 0)
        {
            dispose = Dispose_Option[x].enumerator;
            break;
        }
    }

    return dispose;
}


/**
 * Retrieve the dispose option string and convert it to a DisposeType
 * enumerator.
 *
 * @return [Magick::DisposeType] a DisposeType enumerator
 */
VALUE
Info_dispose(VALUE self)
{
    Info *info;
    ID dispose_id;
    const char *dispose;

    Data_Get_Struct(self, Info, info);

    dispose_id = rb_intern("UndefinedDispose");

    // Map the dispose option string to a DisposeType enumerator.
    dispose = GetImageOption(info, "dispose");
    if (dispose)
    {
        for (int x = 0; x < N_DISPOSE_OPTIONS; x++)
        {
            if (strcmp(dispose, Dispose_Option[x].string) == 0)
            {
                dispose_id = rb_intern(Dispose_Option[x].enum_name);
                break;
            }
        }
    }

    return rb_const_get(Module_Magick, dispose_id);
}

/**
 * Convert a DisposeType enumerator into the equivalent dispose option string.
 *
 * @param disp [Magic::DisposeType] the DisposeType enumerator
 * @return [Magic::DisposeType] the given value
 */
VALUE
Info_dispose_eq(VALUE self, VALUE disp)
{
    Info *info;
    DisposeType dispose;
    const char *option;
    int x;

    Data_Get_Struct(self, Info, info);

    if (NIL_P(disp))
    {
        DeleteImageOption(info, "dispose");
        return self;
    }

    VALUE_TO_ENUM(disp, dispose, DisposeType);
    option = "Undefined";

    for (x = 0; x < N_DISPOSE_OPTIONS; x++)
    {
        if (dispose == Dispose_Option[x].enumerator)
        {
            option = Dispose_Option[x].string;
            break;
        }
    }

    SetImageOption(info, "dispose", option);
    return disp;
}

/**
 * Get dither value
 *
 * @return [Boolean] true if dither is enabled
 */
VALUE
Info_dither(VALUE self)
{
    IMPLEMENT_ATTR_READER(Info, dither, boolean);
}

/**
 * Set dither value
 *
 * @param val [Boolean] true if dither will be enabled
 * @return [Boolean] true if dither is enabled
 */
VALUE
Info_dither_eq(VALUE self, VALUE val)
{
    IMPLEMENT_ATTR_WRITER(Info, dither, boolean);
}


/**
 * Get the endian value.
 *
 * @return [Magick::EndianType] the endian
 */
VALUE
Info_endian(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    return EndianType_find(info->endian);
}


/**
 * Set the endian value.
 *
 * @param endian [Magick::EndianType] the endian
 * @return [Magick::EndianType] the given endian
 */
VALUE
Info_endian_eq(VALUE self, VALUE endian)
{
    Info *info;
    EndianType type = UndefinedEndian;

    if (endian != Qnil)
    {
        VALUE_TO_ENUM(endian, type, EndianType);
    }

    Data_Get_Struct(self, Info, info);
    info->endian = type;
    return endian;
}


/**
 * Get the extract geometry, e.g. "200x200+100+100"
 *
 * @return [String] the extract string
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Info_extract(VALUE self)
{
    IMPLEMENT_ATTR_READER(Info, extract, str);
}

/**
 * Set the extract geometry.
 *
 * @param extract_arg [String] the extract string
 * @return [String] the given value
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Info_extract_eq(VALUE self, VALUE extract_arg)
{
    Info *info;
    char *extr;
    VALUE extract;

    Data_Get_Struct(self, Info, info);

    if (NIL_P(extract_arg))
    {
        magick_free(info->extract);
        info->extract = NULL;
        return self;
    }

    extract = rb_String(extract_arg);
    extr = StringValueCStr(extract);
    if (!IsGeometry(extr))
    {
        rb_raise(rb_eArgError, "invalid extract geometry: %s", extr);
    }

    magick_clone_string(&info->extract, extr);

    RB_GC_GUARD(extract);

    return extract_arg;
}


/**
 * Get the "filename" value.
 *
 * @return [String] the file name ("" if filename not set)
 * @note Only used for Image#capture
 * @see Image#capture
 */
VALUE
Info_filename(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    return rb_str_new2(info->filename);
}

/**
 * Set the "filename" value.
 *
 * @param filename [String] the file name
 * @return [String] the given file name
 * @note Only used for Image#capture
 * @see Image#capture
 */
VALUE
Info_filename_eq(VALUE self, VALUE filename)
{
    Info *info;

    Data_Get_Struct(self, Info, info);

    // Allow "nil" - remove current filename
    if (NIL_P(filename) || StringValueCStr(filename) == NULL)
    {
        info->filename[0] = '\0';
    }
    else
    {
        char *fname;

        // Otherwise copy in filename
        fname = StringValueCStr(filename);
        strlcpy(info->filename, fname, sizeof(info->filename));
    }
    return filename;
}


/**
 * Return the fill color as a String.
 *
 * @return [String] the fill color
 */
VALUE
Info_fill(VALUE self)
{
    return get_option(self, "fill");
}

/**
 * Set the fill color
 *
 * @param color [String] the fill color
 * @return [String] the given value
 */
VALUE
Info_fill_eq(VALUE self, VALUE color)
{
    return set_color_option(self, "fill", color);
}


/**
 * Get the text font.
 *
 * @return [String] the font
 */
VALUE
Info_font(VALUE self)
{
    IMPLEMENT_ATTR_READER(Info, font, str);
}

/**
 * Set the text font.
 *
 * @param font_arg [String] the font
 * @return [String] the given font
 */
VALUE
Info_font_eq(VALUE self, VALUE font_arg)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    if (NIL_P(font_arg) || StringValueCStr(font_arg) == NULL)
    {
        magick_free(info->font);
        info->font = NULL;
    }
    else
    {
        char *font;

        font = StringValueCStr(font_arg);
        magick_clone_string(&info->font, font);
    }
    return font_arg;
}

/**
 * Return the image encoding format.
 *
 * @return [String, nil] the encoding format
 */
VALUE Info_format(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    if (*info->magick)
    {
        const MagickInfo *magick_info;
        ExceptionInfo *exception;

        exception = AcquireExceptionInfo();
        magick_info = GetMagickInfo(info->magick, exception);
        DestroyExceptionInfo(exception);

        return magick_info ? rb_str_new2(magick_info->name) : Qnil;
    }

    return Qnil;
}

/**
 * Set the image encoding format.
 *
 * @param magick [String] the encoding format
 * @return [String] the given format
 */
VALUE
Info_format_eq(VALUE self, VALUE magick)
{
    Info *info;
    const MagickInfo *m;
    char *mgk;
    ExceptionInfo *exception;

    Data_Get_Struct(self, Info, info);

    mgk = StringValueCStr(magick);

    exception = AcquireExceptionInfo();
    m = GetMagickInfo(mgk, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);

    if (!m)
    {
        rb_raise(rb_eArgError, "unknown format: %s", mgk);
    }

    strlcpy(info->magick, m->name, sizeof(info->magick));
    return magick;
}

/**
 * Get the fuzz.
 *
 * @return [Float] the fuzz
 * @see Image#fuzz
 */
VALUE
Info_fuzz(VALUE self)
{
    IMPLEMENT_ATTR_READER(Info, fuzz, dbl);
}

/**
 * Set the fuzz.
 *
 * @param fuzz [Float, String] the fuzz with Float or
 *   percent format "xx%" with String
 * @return [Float, String] the given value
 * @see Image#fuzz=
 */
VALUE
Info_fuzz_eq(VALUE self, VALUE fuzz)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    info->fuzz = rm_fuzz_to_dbl(fuzz);
    return fuzz;
}

/** A gravity option */
static struct
{
    const char *string; /**< the argument given by the user */
    const char *enum_name; /**< the enumerator name */
    GravityType enumerator; /**< the enumerator itself */
} Gravity_Option[] = {
    { "Undefined",  "UndefinedGravity", UndefinedGravity},
    { "None",       "UndefinedGravity", UndefinedGravity},
    { "Center",     "CenterGravity",    CenterGravity},
    { "East",       "EastGravity",      EastGravity},
    { "Forget",     "ForgetGravity",    ForgetGravity},
    { "NorthEast",  "NorthEastGravity", NorthEastGravity},
    { "North",      "NorthGravity",     NorthGravity},
    { "NorthWest",  "NorthWestGravity", NorthWestGravity},
    { "SouthEast",  "SouthEastGravity", SouthEastGravity},
    { "South",      "SouthGravity",     SouthGravity},
    { "SouthWest",  "SouthWestGravity", SouthWestGravity},
    { "West",       "WestGravity",      WestGravity}
};

/** Number of gravity options */
#define N_GRAVITY_OPTIONS (int)(sizeof(Gravity_Option)/sizeof(Gravity_Option[0]))


/**
 * Return the value of the gravity option as a GravityType enumerator.
 *
 * No Ruby usage (internal function)
 *
 * @param name the name of the gravity option
 * @return the enumerator for name
 */
GravityType rm_gravity_to_enum(const char *name)
{
    GravityType gravity = UndefinedGravity;
    int x;

    for (x = 0; x < N_GRAVITY_OPTIONS; x++)
    {
        if (strcmp(name, Gravity_Option[x].string) == 0)
        {
            gravity = Gravity_Option[x].enumerator;
            break;
        }
    }

    return gravity;
}


/**
 * Return the value of the gravity option as a GravityType enumerator.
 *
 * @return [Magick::GravityType] the gravity enumerator
 */
VALUE Info_gravity(VALUE self)
{
    Info *info;
    const char *gravity;
    ID gravity_id;

    Data_Get_Struct(self, Info, info);

    gravity_id = rb_intern("UndefinedGravity");

    // Map the gravity option string to a GravityType enumerator.
    gravity = GetImageOption(info, "gravity");
    if (gravity)
    {
        for (int x = 0; x < N_GRAVITY_OPTIONS; x++)
        {
            if (strcmp(gravity, Gravity_Option[x].string) == 0)
            {
                gravity_id = rb_intern(Gravity_Option[x].enum_name);
                break;
            }
        }
    }

    return rb_const_get(Module_Magick, gravity_id);
}

/**
 * Convert a GravityType enum to a gravity option name and store in the Info
 * structure.
 *
 * @param grav [Magick::GravityType] the gravity enumerator
 * @return [Magick::GravityType] the given gravity
 */
VALUE
Info_gravity_eq(VALUE self, VALUE grav)
{
    Info *info;
    GravityType gravity;
    const char *option;
    int x;

    Data_Get_Struct(self, Info, info);

    if (NIL_P(grav))
    {
        DeleteImageOption(info, "gravity");
        return self;
    }

    VALUE_TO_ENUM(grav, gravity, GravityType);
    option = "Undefined";

    for (x = 0; x < N_GRAVITY_OPTIONS; x++)
    {
        if (gravity == Gravity_Option[x].enumerator)
        {
            option = Gravity_Option[x].string;
            break;
        }
    }

    SetImageOption(info, "gravity", option);
    return grav;
}


/**
 * Get the classification type.
 *
 * @return [Magick::ImageType] the classification type
 */
VALUE
Info_image_type(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    return ImageType_find(info->type);
}

/**
 * Set the classification type.
 *
 * @param type [Magick::ImageType] the classification type
 * @return [Magick::ImageType] the given type
 */
VALUE
Info_image_type_eq(VALUE self, VALUE type)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    VALUE_TO_ENUM(type, info->type, ImageType);
    return type;
}

/**
 * Get the interlace type.
 *
 * @return [Magick::InterlaceType] the interlace type
 */
VALUE
Info_interlace(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    return InterlaceType_find(info->interlace);
}

/**
 * Set the interlace type
 *
 * @param inter [Magick::InterlaceType] the interlace type
 * @return [Magick::InterlaceType] the given interlace
 */
VALUE
Info_interlace_eq(VALUE self, VALUE inter)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    VALUE_TO_ENUM(inter, info->interlace, InterlaceType);
    return inter;
}

/**
 * Get the label.
 *
 * @return [String] the label
 */
VALUE Info_label(VALUE self)
{
    return get_option(self, "Label");
}

/**
 * Set the label.
 *
 * @param string [String] the label
 * @return [String] the given label
 */
VALUE Info_label_eq(VALUE self, VALUE string)
{
    return set_option(self, "Label", string);
}

/**
 * Return the name of the matte color as a String.
 *
 * @return [String] the name of the matte color
 * @see Image#matte_color
 */
VALUE
Info_matte_color(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    return rm_pixelcolor_to_color_name_info(info, &info->matte_color);
}

/**
 * Set the matte color.
 *
 * @param matte_arg [Magick::Pixel, String] the name of the matte as a String
 * @return [Magick::Pixel, String] the given value
 */
VALUE
Info_matte_color_eq(VALUE self, VALUE matte_arg)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    Color_to_PixelColor(&info->matte_color, matte_arg);

    return matte_arg;
}

/**
 * Establish a progress monitor.
 *
 * @param monitor [Proc] the monitor
 * @return [Proc] monitor
 * @see Image#monitor=
 */
VALUE
Info_monitor_eq(VALUE self, VALUE monitor)
{
    Info *info;

    Data_Get_Struct(self, Info, info);

    if (NIL_P(monitor))
    {
        info->progress_monitor = NULL;
    }
    else
    {
        SetImageInfoProgressMonitor(info, rm_progress_monitor, (void *)monitor);
    }

    return monitor;
}

/**
 * Get the monochrome value.
 *
 * @return [Boolean] true or false
 */
VALUE
Info_monochrome(VALUE self)
{
    IMPLEMENT_ATTR_READER(Info, monochrome, boolean);
}

/**
 * Set the monochrome value.
 *
 * @param val [Boolean] true or false
 * @return [Boolean] the given value
 */
VALUE
Info_monochrome_eq(VALUE self, VALUE val)
{
    IMPLEMENT_ATTR_WRITER(Info, monochrome, boolean);
}

/**
 * Get the scene number of an image or the first image in a sequence.
 *
 * @return [Numeric] the scene number
 */
VALUE
Info_number_scenes(VALUE self)
{
    IMPLEMENT_ATTR_READER(Info, number_scenes, ulong);
}

/**
 * Set the scene number of an image or the first image in a sequence.
 *
 * @param val [Numeric] the scene number
 * @return [Numeric] the given value
 */
VALUE
Info_number_scenes_eq(VALUE self, VALUE val)
{
    IMPLEMENT_ATTR_WRITER(Info, number_scenes, ulong);
}

/**
 * Return the orientation attribute as an OrientationType enum value.
 *
 * @return [Magick::OrientationType] the orientation
 */
VALUE
Info_orientation(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    return OrientationType_find(info->orientation);
}


/**
 * Set the Orientation type.
 *
 * @param inter [Magick::OrientationType] the orientation type as an OrientationType enum value
 * @return [Magick::OrientationType] the given value
 */
VALUE
Info_orientation_eq(VALUE self, VALUE inter)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    VALUE_TO_ENUM(inter, info->orientation, OrientationType);
    return inter;
}


/**
 * Return origin geometry.
 *
 * @return [String] the origin geometry
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Info_origin(VALUE self)
{
    Info *info;
    const char *origin;

    Data_Get_Struct(self, Info, info);

    origin = GetImageOption(info, "origin");
    return origin ? rb_str_new2(origin) : Qnil;
}


/**
 * Set origin geometry. Argument may be a Geometry object as well as a geometry
 * string.
 *
 * The geometry format is
 *     +-x+-y
 *
 * @param origin_arg [String] the origin geometry
 * @return [String] the given value
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Info_origin_eq(VALUE self, VALUE origin_arg)
{
    Info *info;
    VALUE origin_str;
    char *origin;

    Data_Get_Struct(self, Info, info);

    if (NIL_P(origin_arg))
    {
        DeleteImageOption(info, "origin");
        return self;
    }

    origin_str = rb_String(origin_arg);
    origin = GetPageGeometry(StringValueCStr(origin_str));

    if (IsGeometry(origin) == MagickFalse)
    {
        magick_free(origin);
        rb_raise(rb_eArgError, "invalid origin geometry");
    }

    SetImageOption(info, "origin", origin);
    magick_free(origin);

    RB_GC_GUARD(origin_str);

    return origin_arg;
}


/**
 * Get the Postscript page geometry.
 *
 * @return [String] the page geometry
 */
VALUE
Info_page(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    return info->page ? rb_str_new2(info->page) : Qnil;

}

/**
 * Store the Postscript page geometry. Argument may be a Geometry object as well
 * as a geometry string.
 *
 * @param page_arg [String] the geometry
 * @return [String] the given value
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Info_page_eq(VALUE self, VALUE page_arg)
{
    Info *info;
    VALUE geom_str;
    char *geometry;

    Data_Get_Struct(self, Info, info);
    if (NIL_P(page_arg))
    {
        magick_free(info->page);
        info->page = NULL;
        return self;
    }
    geom_str = rb_String(page_arg);
    geometry = GetPageGeometry(StringValueCStr(geom_str));
    if (*geometry == '\0')
    {
        magick_free(info->page);
        info->page = NULL;
        return self;
    }
    info->page = geometry;

    RB_GC_GUARD(geom_str);

    return page_arg;
}

/**
 * Get the point size.
 *
 * @return [Float] the point size
 */
VALUE
Info_pointsize(VALUE self)
{
    IMPLEMENT_ATTR_READER(Info, pointsize, dbl);
}

/**
 * Set the point size.
 *
 * @param val [Float] the point size
 * @return [Float] the given value
 */
VALUE
Info_pointsize_eq(VALUE self, VALUE val)
{
    IMPLEMENT_ATTR_WRITER(Info, pointsize, dbl);
}

/**
 * Get the compression level for JPEG, etc.
 *
 * @return [Numeric] the compression level
 */
VALUE
Info_quality(VALUE self)
{
    IMPLEMENT_ATTR_READER(Info, quality, ulong);
}

/**
 * Get the compression level for JPEG, etc.
 *
 * @param val [Numeric] the compression level
 * @return [Numeric] the given value
 */
VALUE
Info_quality_eq(VALUE self, VALUE val)
{
    IMPLEMENT_ATTR_WRITER(Info, quality, ulong);
}

/**
 * Get sampling factors used by JPEG or MPEG-2 encoder and YUV decoder/encoder.
 *
 * @return [String, nil] the sampling factors
 */
VALUE
Info_sampling_factor(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    if (info->sampling_factor)
    {
        return rb_str_new2(info->sampling_factor);
    }
    else
    {
        return Qnil;
    }
}

/**
 * Set sampling factors used by JPEG or MPEG-2 encoder and YUV decoder/encoder.
 *
 * @param sampling_factor [String] the sampling factors
 * @return [String] the given value
 */
VALUE
Info_sampling_factor_eq(VALUE self, VALUE sampling_factor)
{
    Info *info;
    char *sampling_factor_p = NULL;
    long sampling_factor_len = 0;

    Data_Get_Struct(self, Info, info);

    if (!NIL_P(sampling_factor))
    {
        sampling_factor_p = rm_str2cstr(sampling_factor, &sampling_factor_len);
    }

    if (info->sampling_factor)
    {
        magick_free(info->sampling_factor);
        info->sampling_factor = NULL;
    }
    if (sampling_factor_len > 0)
    {
        magick_clone_string(&info->sampling_factor, sampling_factor_p);
    }

    return sampling_factor;
}


/**
 * Get the scene number.
 *
 * @return [Numeric] the scene number
 */
VALUE
Info_scene(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    return  ULONG2NUM(info->scene);
}


/**
 * Set the scene number.
 *
 * @param scene [Numeric] the scene number
 * @return [Numeric] the given value
 */
VALUE
Info_scene_eq(VALUE self, VALUE scene)
{
    Info *info;
    char buf[25];

    Data_Get_Struct(self, Info, info);
    info->scene = NUM2ULONG(scene);

    snprintf(buf, sizeof(buf), "%"RMIuSIZE"", info->scene);
    SetImageOption(info, "scene", buf);

    return scene;
}


/**
 * Get the server name.
 *
 * @return [String] the server name
 */
VALUE
Info_server_name(VALUE self)
{
    IMPLEMENT_ATTR_READER(Info, server_name, str);
}


/**
 * Set the server name.
 *
 * @param server_arg [String] the server name
 * @return [String] the given value
 */
VALUE
Info_server_name_eq(VALUE self, VALUE server_arg)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    if (NIL_P(server_arg) || StringValueCStr(server_arg) == NULL)
    {
        magick_free(info->server_name);
        info->server_name = NULL;
    }
    else
    {
        char *server;

        server = StringValueCStr(server_arg);
        magick_clone_string(&info->server_name, server);
    }
    return server_arg;
}

/**
 * Get ths size
 *
 * @return [String] the size as a Geometry object
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Info_size(VALUE self)
{
    IMPLEMENT_ATTR_READER(Info, size, str);
}

/**
 * Set the size (either as a Geometry object or a Geometry string
 *
 * @param size_arg [String] the size
 * @return [String] the given value
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Info_size_eq(VALUE self, VALUE size_arg)
{
    Info *info;
    VALUE size;
    char *sz;

    Data_Get_Struct(self, Info, info);

    if (NIL_P(size_arg))
    {
        magick_free(info->size);
        info->size = NULL;
        return self;
    }

    size = rb_String(size_arg);
    sz = StringValueCStr(size);
    if (!IsGeometry(sz))
    {
        rb_raise(rb_eArgError, "invalid size geometry: %s", sz);
    }

    magick_clone_string(&info->size, sz);

    RB_GC_GUARD(size);

    return size_arg;
}


/**
 * Return the stroke color as a String.
 *
 * @return [String] the stroke color
 */
VALUE
Info_stroke(VALUE self)
{
    return get_option(self, "stroke");
}

/**
 * Set the stroke color
 *
 * @param color [String] the stroke color
 * @return [String] the given value
 */
VALUE
Info_stroke_eq(VALUE self, VALUE color)
{
    return set_color_option(self, "stroke", color);
}


/**
 * Get stroke width.
 *
 * @return [Float] the stroke width
 */
VALUE
Info_stroke_width(VALUE self)
{
    return get_dbl_option(self, "strokewidth");
}


/**
 * Set stroke width.
 *
 * @param stroke_width [Float] the stroke width
 * @return [Float] the given value
 */
VALUE
Info_stroke_width_eq(VALUE self, VALUE stroke_width)
{
    return set_dbl_option(self, "strokewidth", stroke_width);
}


/**
 * Set name of texture to tile onto the image background.
 *
 * @param texture [Magick::Image] the texture image
 * @return [Magick::Image] the given image
 */
VALUE
Info_texture_eq(VALUE self, VALUE texture)
{
    Info *info;
    Image *image;
    char name[MaxTextExtent];

    Data_Get_Struct(self, Info, info);

    // Delete any existing texture file
    if (info->texture)
    {
        rm_delete_temp_image(info->texture);
        magick_free(info->texture);
        info->texture = NULL;
    }

    // If argument is nil we're done
    if (texture == Qnil)
    {
        return texture;
    }

    // Create a temp copy of the texture and store its name in the texture field
    image = rm_check_destroyed(texture);
    rm_write_temp_image(image, name, sizeof(name));

    magick_clone_string(&info->texture, name);

    return texture;
}


/**
 * Return tile_offset geometry.
 *
 * @return [String, nil] the tile offset
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Info_tile_offset(VALUE self)
{
    Info *info;
    const char *tile_offset;

    Data_Get_Struct(self, Info, info);

    tile_offset = GetImageOption(info, "tile-offset");

    if (!tile_offset)
    {
        return Qnil;
    }

    return rb_str_new2(tile_offset);
}


/**
 * Set tile offset geometry.
 *
 * @param offset [String] the offset geometry
 * @return [String] the given value
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Info_tile_offset_eq(VALUE self, VALUE offset)
{
    Info *info;
    VALUE offset_str;
    char *tile_offset;

    offset_str = rb_String(offset);
    tile_offset = StringValueCStr(offset_str);
    if (!IsGeometry(tile_offset))
    {
        rb_raise(rb_eArgError, "invalid tile offset geometry: %s", tile_offset);
    }

    Data_Get_Struct(self, Info, info);

    DeleteImageOption(info, "tile-offset");
    SetImageOption(info, "tile-offset", tile_offset);

    RB_GC_GUARD(offset_str);

    return offset;
}


/**
 * Return the name of the transparent color.
 *
 * @return [String] the name of the transparent color
 * @see Image#transparent_color
 */
VALUE
Info_transparent_color(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    return rm_pixelcolor_to_color_name_info(info, &info->transparent_color);
}


/**
 * Set the transparent color.
 *
 * @param tc_arg [String] the transparent color
 * @return [Magick::Pixel, String] the given value
 */
VALUE
Info_transparent_color_eq(VALUE self, VALUE tc_arg)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    Color_to_PixelColor(&info->transparent_color, tc_arg);

    return tc_arg;
}


/**
 * Undefine image option.
 *
 * @param format [String] the format
 * @param key [String] the key
 * @return [Magick::Info] self
 */
VALUE
Info_undefine(VALUE self, VALUE format, VALUE key)
{
    Info *info;
    char *format_p, *key_p;
    long format_l, key_l;
    char fkey[MaxTextExtent];

    format_p = rm_str2cstr(format, &format_l);
    key_p = rm_str2cstr(key, &key_l);

    if (format_l > MAX_FORMAT_LEN || format_l + key_l > MaxTextExtent)
    {
        rb_raise(rb_eArgError, "can't undefine %.60s:%.1024s - too long", format_p, key_p);
    }

    snprintf(fkey, sizeof(fkey), "%.60s:%.*s", format_p, (int)(MaxTextExtent-61), key_p);

    Data_Get_Struct(self, Info, info);
    DeleteImageOption(info, fkey);

    return self;
}


/**
 * Return the undercolor color.
 *
 * @return [String] the undercolor
 */
VALUE
Info_undercolor(VALUE self)
{
    return get_option(self, "undercolor");
}

/**
 * Set the undercolor color.
 *
 * @param color [String] the undercolor color
 * @return [String] the given value
 */
VALUE
Info_undercolor_eq(VALUE self, VALUE color)
{
    return set_color_option(self, "undercolor", color);
}

/**
 * Get the resolution type.
 *
 * @return [Magick::ResolutionType] the resolution type
 */
VALUE
Info_units(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    return ResolutionType_find(info->units);
}

/**
 * Set the resolution type
 *
 * @param units [Magick::ResolutionType] the resolution type
 * @return [Magick::ResolutionType] the given value
 */
VALUE
Info_units_eq(VALUE self, VALUE units)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
    VALUE_TO_ENUM(units, info->units, ResolutionType);
    return units;
}

/**
 * Get FlashPix viewing parameters.
 *
 * @return [String] the viewing parameters
 */
VALUE
Info_view(VALUE self)
{
    Info *info;

    Data_Get_Struct(self, Info, info);
#if defined(IMAGEMAGICK_7)
    return C_str_to_R_str(GetImageOption(info, "fpx:view"));
#else
    return C_str_to_R_str(info->view);
#endif
}

/**
 * Set FlashPix viewing parameters.
 *
 * @param view_arg [String] the viewing parameters
 * @return [String] the given value
 */
VALUE
Info_view_eq(VALUE self, VALUE view_arg)
{
    Info *info;
    char *view = NULL;

    Data_Get_Struct(self, Info, info);

    if (!NIL_P(view_arg))
    {
        view = StringValueCStr(view_arg);
    }

#if defined(IMAGEMAGICK_7)
    if (view)
    {
        SetImageOption(info, "fpx:view", view);
    }
    else
    {
        RemoveImageOption(info, "fpx:view");
    }
#else
    if (info->view)
    {
        magick_free(info->view);
        info->view = NULL;
    }
    if (view)
    {
        magick_clone_string(&info->view, view);
    }
#endif
    return view_arg;
}


/**
 * If there is a texture image, delete it before destroying the Image::Info
 * structure.
 *
 * No Ruby usage (internal function)
 *
 * @param infoptr pointer to the Info object
 */
static void
destroy_Info(void *infoptr)
{
    Info *info = (Info *)infoptr;

    if (info->texture)
    {
        rm_delete_temp_image(info->texture);
        magick_free(info->texture);
        info->texture = NULL;
    }

    DestroyImageInfo(info);
}


/**
 * Create an Image::Info object.
 *
 * No Ruby usage (internal function)
 *
 * @param class the Ruby class to use
 * @return a new ImageInfo object
 */
VALUE
Info_alloc(VALUE class)
{
    Info *info;
    VALUE info_obj;

    info = CloneImageInfo(NULL);
    if (!info)
    {
        rb_raise(rb_eNoMemError, "not enough memory to initialize Info object");
    }
    info_obj = Data_Wrap_Struct(class, NULL, destroy_Info, info);

    RB_GC_GUARD(info_obj);

    return info_obj;
}


/**
 * Provide a Info.new method for internal use.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Takes no parameters, but runs the parm block if present
 *
 * @return a new ImageInfo object
 */
VALUE
rm_info_new(void)
{
    VALUE info_obj;

    info_obj = Info_alloc(Class_Info);

    RB_GC_GUARD(info_obj);

    return Info_initialize(info_obj);
}


/**
 * If an initializer block is present, run it.
 *
 * @overload initialize
 *
 * @overload initialize
 *   @yield [Magick::Image::Info]
 *
 * @return self
 */
VALUE
Info_initialize(VALUE self)
{
    if (rb_block_given_p())
    {
        if (rb_proc_arity(rb_block_proc()) == 0)
        {
            // Run the block in self's context
            rb_warn("passing a block without an image argument is deprecated");
            rb_obj_instance_eval(0, NULL, self);
        }
        else
        {
            rb_yield(self);
        }
    }
    return self;
}


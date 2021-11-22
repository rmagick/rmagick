/**************************************************************************//**
 * Image class method definitions for RMagick.
 *
 * Copyright &copy; 2002 - 2009 by Timothy P. Hunter
 *
 * Changes since Nov. 2009 copyright &copy; by Benjamin Thomas and Omer Bar-or
 *
 * @file     rmimage.c
 * @version  $Id: rmimage.c,v 1.361 2010/05/03 03:34:48 baror Exp $
 * @author   Tim Hunter
 ******************************************************************************/

#include "rmagick.h"
#include <signal.h>

#define BEGIN_CHANNEL_MASK(image, channels) \
  { \
    ChannelType channel_mask = SetPixelChannelMask(image, (ChannelType)channels);

#define END_CHANNEL_MASK(image) \
    SetPixelChannelMask(image, channel_mask); \
  }

#define CHANGE_RESULT_CHANNEL_MASK(result) \
    if (result != (Image *)NULL) \
      SetPixelChannelMask(result, channel_mask);

#ifndef magick_module
    #define magick_module module
#endif

/** Method that effects an image */
typedef Image *(effector_t)(const Image *, const double, const double, ExceptionInfo *);
/** Method that flips an image */
typedef Image *(flipper_t)(const Image *, ExceptionInfo *);
/** Method that magnifies an image */
typedef Image *(magnifier_t)(const Image *, ExceptionInfo *);
/** Method that reads an image */
typedef Image *(reader_t)(const Info *, ExceptionInfo *);
/** Method that scales an image */
typedef Image *(scaler_t)(const Image *, const size_t, const size_t, ExceptionInfo *);
/** Method that computes threshold on an image */
#if defined(IMAGEMAGICK_7)
    typedef MagickBooleanType (auto_channel_t)(Image *, ExceptionInfo *exception);
    typedef Image *(channel_method_t)(const Image *, const double, const double, ExceptionInfo *);
    typedef MagickBooleanType (thresholder_t)(Image *, const char *, ExceptionInfo *);
#else
    typedef MagickBooleanType (auto_channel_t)(Image *, const ChannelType);
    typedef Image *(channel_method_t)(const Image *, const ChannelType, const double, const double, ExceptionInfo *);
    typedef MagickBooleanType (thresholder_t)(Image *, const char *);
    #define IsEquivalentImage IsImageSimilar
    #define OrderedDitherImage OrderedPosterizeImage
#endif
/** Method that transforms an image */
typedef Image *(xformer_t)(const Image *, const RectangleInfo *, ExceptionInfo *);

static VALUE cropper(int, int, VALUE *, VALUE);
static VALUE effect_image(VALUE, int, VALUE *, effector_t);
static VALUE flipflop(int, VALUE, flipper_t);
static VALUE rd_image(VALUE, VALUE, reader_t);
static VALUE rotate(int, int, VALUE *, VALUE);
static VALUE scale(int, int, VALUE *, VALUE, scaler_t);
static VALUE threshold_image(int, VALUE *, VALUE, thresholder_t);
static VALUE xform_image(int, VALUE, VALUE, VALUE, VALUE, VALUE, xformer_t);
static VALUE array_from_images(Image *);
static void call_trace_proc(Image *, const char *);
static VALUE file_arg_rescue(VALUE, VALUE ATTRIBUTE_UNUSED) ATTRIBUTE_NORETURN;
static VALUE rm_trace_creation_handle_exception(VALUE, VALUE) ATTRIBUTE_NORETURN;

static const char *BlackPointCompensationKey = "PROFILE:black-point-compensation";


/**
 * Returns the alpha value from the hash.
 *
 * No Ruby usage (internal function)
 *
 * @hash the hash
 */
static Quantum
get_named_alpha_value(VALUE hash)
{
    if (TYPE(hash) != T_HASH)
    {
        rb_raise(rb_eArgError, "missing keyword: alpha");
    }

    if (FIX2ULONG(rb_hash_size(hash)) != 1)
    {
        rb_raise(rb_eArgError, "wrong number of arguments");
    }

    VALUE alpha = rb_hash_aref(hash, ID2SYM(rb_intern("alpha")));
    if (NIL_P(alpha))
    {
        rb_raise(rb_eArgError, "missing keyword: alpha");
    }

    return APP2QUANTUM(alpha);
}


/**
 * Call Adaptive(Blur|Sharpen)Image.
 *
 * No Ruby usage (internal function)
 *
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @param fp pointer to the function to call
 * @return a new image
 */
static VALUE
adaptive_method(int argc, VALUE *argv, VALUE self,
                Image *fp(const Image *, const double, const double, ExceptionInfo *))
{
    Image *image, *new_image;
    double radius = 0.0;
    double sigma = 1.0;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 2:
            sigma = NUM2DBL(argv[1]);
        case 1:
            radius = NUM2DBL(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 2)", argc);
            break;
    }

    exception = AcquireExceptionInfo();

    new_image = (fp)(image, radius, sigma, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}



/**
 * Call Adaptive(Blur|Sharpen)ImageChannel.
 *
 * No Ruby usage (internal function)
 *
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @param fp pointer to the function to call
 * @return a new image
 */
static VALUE
adaptive_channel_method(int argc, VALUE *argv, VALUE self, channel_method_t fp)
{
    Image *image, *new_image;
    double radius = 0.0;
    double sigma = 1.0;
    ExceptionInfo *exception;
    ChannelType channels;

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);

    switch (argc)
    {
        case 2:
            sigma = NUM2DBL(argv[1]);
        case 1:
            radius = NUM2DBL(argv[0]);
        case 0:
            break;
        default:
            raise_ChannelType_error(argv[argc-1]);
            break;
    }

    exception = AcquireExceptionInfo();

#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    new_image = (fp)(image, radius, sigma, exception);
    CHANGE_RESULT_CHANNEL_MASK(new_image);
    END_CHANNEL_MASK(image);
#else
    new_image = (fp)(image, channels, radius, sigma, exception);
#endif

    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Adaptively blurs the image by blurring more intensely near image edges and less intensely far
 * from edges. The {Magick::Image#adaptive_blur} method blurs the image with a Gaussian operator of
 * the given radius and standard deviation (sigma). For reasonable results, radius should be larger
 * than sigma. Use a radius of 0 and adaptive_blur selects a suitable radius for you.
 *
 * @overload adaptive_blur(radius = 0.0, sigma = 1.0)
 *   @param radius [Float] The radius of the Gaussian in pixels, not counting the center pixel.
 *   @param sigma [Float] The standard deviation of the Laplacian, in pixels.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_adaptive_blur(int argc, VALUE *argv, VALUE self)
{
    return adaptive_method(argc, argv, self, AdaptiveBlurImage);
}



/**
 * The same as {Magick::Image#adaptive_blur} except only the specified channels are blurred.
 *
 * @overload adaptive_blur_channel(radius = 0.0, sigma = 1.0, channel = Magick::AllChannels)
 *   @param radius [Float] The radius of the Gaussian in pixels, not counting the center pixel.
 *   @param sigma [Float] The standard deviation of the Laplacian, in pixels.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload adaptive_blur_channel(radius = 0.0, sigma = 1.0, *channels)
 *   @param radius [Float] The radius of the Gaussian in pixels, not counting the center pixel.
 *   @param sigma [Float] The standard deviation of the Laplacian, in pixels.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_adaptive_blur_channel(int argc, VALUE *argv, VALUE self)
{
#if defined(IMAGEMAGICK_7)
    return adaptive_channel_method(argc, argv, self, AdaptiveBlurImage);
#else
    return adaptive_channel_method(argc, argv, self, AdaptiveBlurImageChannel);
#endif
}


/**
 * Resizes the image with data dependent triangulation.
 *
 * @overload adaptive_resize(scale_val)
 *   @param scale_val [Float] You can use this argument instead of specifying the desired width and
 *     height. The percentage size change. For example, 1.25 makes the new image 125% of the size of
 *     the receiver.
 *
 * @overload adaptive_resize(cols, rows)
 *   @param cols [Numeric] The desired column size
 *   @param rows [Numeric] The desired row size.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_adaptive_resize(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    unsigned long rows, columns;
    double scale_val, drows, dcols;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 2:
            rows = NUM2ULONG(argv[1]);
            columns = NUM2ULONG(argv[0]);
            break;
        case 1:
            scale_val = NUM2DBL(argv[0]);
            if (scale_val < 0.0)
            {
                rb_raise(rb_eArgError, "invalid scale_val value (%g given)", scale_val);
            }
            drows = scale_val * image->rows + 0.5;
            dcols = scale_val * image->columns + 0.5;
            if (drows > (double)ULONG_MAX || dcols > (double)ULONG_MAX)
            {
                rb_raise(rb_eRangeError, "resized image too big");
            }
            rows = (unsigned long) drows;
            columns = (unsigned long) dcols;
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or 2)", argc);
            break;
    }

    exception = AcquireExceptionInfo();
    new_image = AdaptiveResizeImage(image, columns, rows, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}



/**
 * Adaptively sharpens the image by sharpening more intensely near image edges and less intensely
 * far from edges.
 *
 * The {Magick::Image#adaptive_sharpen} method sharpens the image with a Gaussian operator of the
 * given radius and standard deviation (sigma).
 *
 * For reasonable results, radius should be larger than sigma.
 * Use a radius of 0 and adaptive_sharpen selects a suitable radius for you.
 *
 * @overload adaptive_sharpen(radius = 0.0, sigma = 1.0)
 *   @param radius [Float] The radius of the Gaussian in pixels, not counting the center pixel.
 *   @param sigma [Float] The standard deviation of the Laplacian, in pixels.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_adaptive_sharpen(int argc, VALUE *argv, VALUE self)
{
    return adaptive_method(argc, argv, self, AdaptiveSharpenImage);
}



/**
 * The same as {Magick::Image#adaptive_sharpen} except only the specified channels are sharpened.
 *
 * @overload adaptive_sharpen_channel(radius = 0.0, sigma = 1.0, channel = Magick::AllChannels)
 *   @param radius [Float] The radius of the Gaussian in pixels, not counting the center pixel.
 *   @param sigma [Float] The standard deviation of the Laplacian, in pixels.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload adaptive_sharpen_channel(radius = 0.0, sigma = 1.0, *channels)
 *   @param radius [Float] The radius of the Gaussian in pixels, not counting the center pixel.
 *   @param sigma [Float] The standard deviation of the Laplacian, in pixels.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_adaptive_sharpen_channel(int argc, VALUE *argv, VALUE self)
{
#if defined(IMAGEMAGICK_7)
    return adaptive_channel_method(argc, argv, self, AdaptiveSharpenImage);
#else
    return adaptive_channel_method(argc, argv, self, AdaptiveSharpenImageChannel);
#endif
}



/**
 * Selects an individual threshold for each pixel based on the range of intensity values in its
 * local neighborhood. This allows for thresholding of an image whose global intensity histogram
 * doesn't contain distinctive peaks.
 *
 * @overload adaptive_threshold(width = 3, height = 3, offset = 0)
 *   @param width [Numeric] the width of the local neighborhood.
 *   @param height [Numeric] the height of the local neighborhood.
 *   @param offset [Numeric] the mean offset
 *   @return [Magick::Image] a new image
 */
VALUE
Image_adaptive_threshold(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    unsigned long width = 3, height = 3;
    long offset = 0;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 3:
            offset = NUM2LONG(argv[2]);
        case 2:
            height = NUM2ULONG(argv[1]);
        case 1:
            width  = NUM2ULONG(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 3)", argc);
    }

    exception = AcquireExceptionInfo();
    new_image = AdaptiveThresholdImage(image, width, height, offset, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Associates a mask with an image that will be used as the destination image in a
 * {Magick::Image#composite} operation.
 *
 * The areas of the destination image that are masked by white pixels will be modified by the
 * {Magick::Image#composite} method, while areas masked by black pixels are unchanged.
 *
 * @param mask [Magick::Image] the composite mask
 * @see Image#mask
 * @see Image#delete_compose_mask
 */
VALUE
Image_add_compose_mask(VALUE self, VALUE mask)
{
    Image *image, *mask_image = NULL;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
    Image *clip_mask = NULL;
#endif

    image = rm_check_frozen(self);
    mask_image = rm_check_destroyed(mask);
    if (image->columns != mask_image->columns || image->rows != mask_image->rows)
    {
        rb_raise(rb_eArgError, "mask must be the same size as image");
    }

#if defined(IMAGEMAGICK_7)
    clip_mask = rm_clone_image(mask_image);

    exception = AcquireExceptionInfo();
    NegateImage(clip_mask, MagickFalse, exception);
    rm_check_exception(exception, clip_mask, DestroyOnError);
    SetImageMask(image, CompositePixelMask, clip_mask, exception);
    DestroyImage(clip_mask);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    // Delete any previously-existing mask image.
    // Store a clone of the new mask image.
    SetImageMask(image, mask_image);
    NegateImage(image->mask, MagickFalse);

    // Since both Set and GetImageMask clone the mask image I don't see any
    // way to negate the mask without referencing it directly. Sigh.
#endif

    return self;
}


/**
 * Adds random noise to the image.
 *
 * @param noise [Magick::NoiseType] the noise
 * @return [Magick::Image] a new image
 */
VALUE
Image_add_noise(VALUE self, VALUE noise)
{
    Image *image, *new_image;
    NoiseType noise_type;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    VALUE_TO_ENUM(noise, noise_type, NoiseType);

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    new_image = AddNoiseImage(image, noise_type, 1.0, exception);
#else
    new_image = AddNoiseImage(image, noise_type, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}

/**
 * Adds random noise to the specified channel or channels in the image.
 *
 * @overload add_noise_channel(noise_type, channel = Magick::AllChannels)
 *   @param noise [Magick::NoiseType] the noise
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload add_noise_channel(noise_type, *channels)
 *   @param noise [Magick::NoiseType] the noise
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_add_noise_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    NoiseType noise_type;
    ExceptionInfo *exception;
    ChannelType channels;

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);

    // There must be 1 remaining argument.
    if (argc == 0)
    {
        rb_raise(rb_eArgError, "missing noise type argument");
    }
    else if (argc > 1)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    VALUE_TO_ENUM(argv[0], noise_type, NoiseType);
    channels &= ~OpacityChannel;

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    new_image = AddNoiseImage(image, noise_type, 1.0, exception);
    END_CHANNEL_MASK(new_image);
#else
    new_image = AddNoiseImageChannel(image, channels, noise_type, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Adds an ICC (a.k.a. ICM), IPTC, or generic profile. If the file contains more than one profile
 * all the profiles are added.
 *
 * @param name [String] The filename of a file containing the profile.
 * @return [Magick::Image] self
 */
VALUE
Image_add_profile(VALUE self, VALUE name)
{
    // ImageMagick code based on the code for the "-profile" option in mogrify.c
    Image *image, *profile_image;
    ImageInfo *info;
    ExceptionInfo *exception;
    char *profile_name;
    char *profile_filename = NULL;
    const StringInfo *profile;

    image = rm_check_frozen(self);

    // ProfileImage issues a warning if something goes wrong.
    profile_filename = StringValueCStr(name);

    info = CloneImageInfo(NULL);
    if (!info)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }
    profile = GetImageProfile(image, "iptc");
    if (profile)
    {
        info->profile = (void *)CloneStringInfo(profile);
    }
    strlcpy(info->filename, profile_filename, sizeof(info->filename));

    exception = AcquireExceptionInfo();
    profile_image = ReadImage(info, exception);
    DestroyImageInfo(info);
    rm_check_exception(exception, profile_image, DestroyOnError);
    rm_ensure_result(profile_image);

    ResetImageProfileIterator(profile_image);
    profile_name = GetNextImageProfile(profile_image);
    while (profile_name)
    {
        profile = GetImageProfile(profile_image, profile_name);
        if (profile)
        {
#if defined(IMAGEMAGICK_7)
            ProfileImage(image, profile_name, GetStringInfoDatum(profile), GetStringInfoLength(profile), exception);
            if (rm_should_raise_exception(exception, RetainExceptionRetention))
#else
            ProfileImage(image, profile_name, GetStringInfoDatum(profile), GetStringInfoLength(profile), MagickFalse);
            if (rm_should_raise_exception(&image->exception, RetainExceptionRetention))
#endif
            {
                break;
            }
        }
        profile_name = GetNextImageProfile(profile_image);
    }

    DestroyImage(profile_image);
#if defined(IMAGEMAGICK_7)
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    DestroyExceptionInfo(exception);
    rm_check_image_exception(image, RetainOnError);
#endif

    return self;
}



/**
 * Get/Set alpha channel.
 *
 * @overload alpha()
 *   Returns true if the alpha channel will be used, false otherwise.
 *   This calling is same as {Magick::Image#alpha?}.
 *   @return [Boolean] true or false
 *   @see Image#alpha?
 *
 * @overload alpha(value)
 *   Activates, deactivates, resets, or sets the alpha channel.
 *   @param value [Magick::AlphaChannelOption] An AlphaChannelOption value
 *   @return [Magick::AlphaChannelOption] the given value
 *
 * - Replaces {Magick::Image#matte=}, {Magick::Image#alpha=}
 * - Originally there was an alpha attribute getter and setter. These are replaced with alpha? and
 *   alpha(type). We still define (but don't document) alpha=. For backward compatibility, if this
 *   method is called without an argument, make it act like the old alpha getter and return true if
 *   the matte channel is active, false otherwise.
 *
 */
VALUE
Image_alpha(int argc, VALUE *argv, VALUE self)
{
    Image *image;
    AlphaChannelOption alpha;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif


    // For backward compatibility, make alpha() act like alpha?
    if (argc == 0)
    {
        return Image_alpha_q(self);
    }
    else if (argc > 1)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 1)", argc);
    }


    image = rm_check_frozen(self);
    VALUE_TO_ENUM(argv[0], alpha, AlphaChannelOption);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    SetImageAlphaChannel(image, alpha, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    SetImageAlphaChannel(image, alpha);
    rm_check_image_exception(image, RetainOnError);
#endif

    return argv[0];
}



/**
 * Determine whether the image's alpha channel is activated.
 *
 * @return [Boolean] true if the image's alpha channel is activated
 */
VALUE
Image_alpha_q(VALUE self)
{
    Image *image = rm_check_destroyed(self);
#if defined(IMAGEMAGICK_7)
    return image->alpha_trait == BlendPixelTrait ? Qtrue : Qfalse;
#else
    return GetImageAlphaChannel(image) ? Qtrue : Qfalse;
#endif
}


/**
 * Transform an image as dictated by the affine matrix argument.
 *
 * @param affine [Magick::AffineMatrix] the affine matrix
 * @return [Magick::Image] a new image
 */
VALUE
Image_affine_transform(VALUE self, VALUE affine)
{
    Image *image, *new_image;
    ExceptionInfo *exception;
    AffineMatrix matrix;

    image = rm_check_destroyed(self);

    // Convert Magick::AffineMatrix to AffineMatrix structure.
    Export_AffineMatrix(&matrix, affine);

    exception = AcquireExceptionInfo();
    new_image = AffineTransformImage(image, &matrix, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}

/**
 * Returns the value of the image property identified by key. An image may have any number of
 * properties.
 *
 * Each property is identified by a string (or symbol) key.
 * The property value is a string. ImageMagick predefines some properties, including "Label",
 * "Comment", "Signature", and in some cases "EXIF".
 *
 * @param key_arg [String, Symbol] the key to get
 * @return [String] property value or nil if key doesn't exist
 * @see Image#[]=
 * @see Image#properties
 */
VALUE
Image_aref(VALUE self, VALUE key_arg)
{
    Image *image;
    const char *key;
    const char *attr;

    image = rm_check_destroyed(self);

    switch (TYPE(key_arg))
    {
        case T_NIL:
            return Qnil;

        case T_SYMBOL:
            key = rb_id2name((ID)SYM2ID(key_arg));
            break;

        default:
            key = StringValueCStr(key_arg);
            if (*key == '\0')
            {
                return Qnil;
            }
            break;
    }


    if (rm_strcasecmp(key, "EXIF:*") == 0)
    {
        return rm_exif_by_entry(image);
    }
    else if (rm_strcasecmp(key, "EXIF:!") == 0)
    {
        return rm_exif_by_number(image);
    }

    attr = rm_get_property(image, key);
    return attr ? rb_str_new2(attr) : Qnil;
}

/**
 * Sets the value of an image property. An image may have any number of properties.
 *
 * - Specify attr=nil to remove the key from the list.
 * - SetImageProperty normally APPENDS the new value to any existing value. Since this usage is
 *   tremendously counter-intuitive, this function always deletes the existing value before setting
 *   the new value.
 * - There's no use checking the return value since SetImageProperty returns "False" for many
 *   reasons, some legitimate.
 *
 * @param key_arg [String, Symbol] the key to set
 * @param attr_arg [String] the value to which to set it
 * @return [Magick::Image] self
 */
VALUE
Image_aset(VALUE self, VALUE key_arg, VALUE attr_arg)
{
    Image *image;
    const char *key;
    char *attr;
    unsigned int okay;

    image = rm_check_frozen(self);

    attr = attr_arg == Qnil ? NULL : StringValueCStr(attr_arg);

    switch (TYPE(key_arg))
    {
        case T_NIL:
            return self;

        case T_SYMBOL:
            key = rb_id2name((ID)SYM2ID(key_arg));
            break;

        default:
            key = StringValueCStr(key_arg);
            if (*key == '\0')
            {
                return self;
            }
            break;
    }


    // Delete existing value. SetImageProperty returns False if
    // the attribute doesn't exist - we don't care.
    rm_set_property(image, key, NULL);
    // Set new value
    if (attr)
    {
        okay = rm_set_property(image, key, attr);
        if (!okay)
        {
            rb_warning("SetImageProperty failed (probably out of memory)");
        }
    }
    return self;
}


/**
 * Handle #transverse, #transform methods.
 *
 * No Ruby usage (internal function)
 *
 * @param bang whether the bang (!) version of the method was called
 * @param self this object
 * @param fp the transverse/transform method to call
 * @return self if bang, otherwise a new image
 */
static VALUE
crisscross(int bang, VALUE self, Image *fp(const Image *, ExceptionInfo *))
{
    Image *image, *new_image;
    ExceptionInfo *exception;

    Data_Get_Struct(self, Image, image);
    exception = AcquireExceptionInfo();

    new_image = (fp)(image, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    if (bang)
    {
        rm_ensure_result(new_image);
        UPDATE_DATA_PTR(self, new_image);
        rm_image_destroy(image);
        return self;
    }

    return rm_image_new(new_image);

}



/**
 * Handle #auto_gamma_channel, #auto_level_channel methods.
 *
 * No Ruby usage (internal function)
 *
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @param fp the channel method to call
 * @return a new image
 */
static VALUE
auto_channel(int argc, VALUE *argv, VALUE self, auto_channel_t fp)
{
    Image *image, *new_image;
    ChannelType channels;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);

    if (argc > 0)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BEGIN_CHANNEL_MASK(new_image, channels);
    (fp)(new_image, exception);
    END_CHANNEL_MASK(new_image);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    (fp)(new_image, channels);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * "Automagically" adjust the gamma level of an image.
 *
 * @overload auto_gamma_channel(channel = Magick::AllChannels)
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload auto_gamma_channel(*channels)
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_auto_gamma_channel(int argc, VALUE *argv, VALUE self)
{
#if defined(IMAGEMAGICK_7)
    return auto_channel(argc, argv, self, AutoGammaImage);
#else
    return auto_channel(argc, argv, self, AutoGammaImageChannel);
#endif
}


/**
 * "Automagically" adjust the color levels of an image.
 *
 * @overload auto_level_channel(channel = Magick::AllChannels)
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload auto_level_channel(*channels)
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_auto_level_channel(int argc, VALUE *argv, VALUE self)
{
#if defined(IMAGEMAGICK_7)
    return auto_channel(argc, argv, self, AutoLevelImage);
#else
    return auto_channel(argc, argv, self, AutoLevelImageChannel);
#endif
}


/**
 * Implement mogrify's -auto_orient option automatically orient image based on
 * EXIF orientation value.
 *
 * No Ruby usage (internal function)
 *
 * @param bang whether the bang (!) version of the method was called
 * @param self this object
 * @return self if bang, otherwise a new image
 * @see mogrify.c (in ImageMagick 6.2.8)
 */
static VALUE
auto_orient(int bang, VALUE self)
{
    Image *image;
    VALUE new_image;
    VALUE degrees[1];

    Data_Get_Struct(self, Image, image);

    switch (image->orientation)
    {
        case TopRightOrientation:
            new_image = flipflop(bang, self, FlopImage);
            break;

        case BottomRightOrientation:
            degrees[0] = rb_float_new(180.0);
            new_image = rotate(bang, 1, degrees, self);
            break;

        case BottomLeftOrientation:
            new_image = flipflop(bang, self, FlipImage);
            break;

        case LeftTopOrientation:
            new_image = crisscross(bang, self, TransposeImage);
            break;

        case RightTopOrientation:
            degrees[0] = rb_float_new(90.0);
            new_image = rotate(bang, 1, degrees, self);
            break;

        case RightBottomOrientation:
            new_image = crisscross(bang, self, TransverseImage);
            break;

        case LeftBottomOrientation:
            degrees[0] = rb_float_new(270.0);
            new_image = rotate(bang, 1, degrees, self);
            break;

        default:                // Return IMMEDIATELY
            return bang ? Qnil : Image_copy(self);
            break;
    }


    Data_Get_Struct(new_image, Image, image);
    image->orientation = TopLeftOrientation;

    RB_GC_GUARD(new_image);

    return new_image;
}


/**
 * Rotates or flips the image based on the image's EXIF orientation tag.
 *
 * Note that only some models of modern digital cameras can tag an image with the orientation.
 * If the image does not have an orientation tag, or the image is already properly oriented, then
 * {Magick::Image#auto_orient} returns an exact copy of the image.
 *
 * @return [Magick::Image] a new image
 * @see Image#auto_orient!
 */
VALUE
Image_auto_orient(VALUE self)
{
    rm_check_destroyed(self);
    return auto_orient(False, self);
}


/**
 * Rotates or flips the image based on the image's EXIF orientation tag.
 * Note that only some models of modern digital cameras can tag an image with the orientation.
 * If the image does not have an orientation tag, or the image is already properly oriented, then
 * {Magick::Image#auto_orient!} returns nil.
 *
 * @return [Magick::Image, nil] nil if the image is already properly oriented, otherwise self
 * @see Image#auto_orient
*/
VALUE
Image_auto_orient_bang(VALUE self)
{
    rm_check_frozen(self);
    return auto_orient(True, self);
}


/**
 * Return the name of the background color as a String.
 *
 * @return [String] the background color
 */
VALUE
Image_background_color(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return rm_pixelcolor_to_color_name(image, &image->background_color);
}


/**
 * Set the the background color to the specified color spec.
 *
 * @param color [Magick::Pixel, String] the color
 * @return [Magick::Pixel, String] the given color
 */
VALUE
Image_background_color_eq(VALUE self, VALUE color)
{
    Image *image = rm_check_frozen(self);
    Color_to_PixelColor(&image->background_color, color);
    return color;
}


/**
 * Return the number of rows (before transformations).
 *
 * @return [Numeric] the number of rows
 */
VALUE
Image_base_columns(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return INT2FIX(image->magick_columns);
}

/**
 * Return the image filename (before transformations).
 *
 * @return [String] the base image filename (or the current filename if there is no base)
 */
VALUE
Image_base_filename(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    if (*image->magick_filename)
    {
        return rb_str_new2(image->magick_filename);
    }
    else
    {
        return rb_str_new2(image->filename);
    }
}

/**
 * Return the number of rows (before transformations).
 *
 * @return [Numeric] the number of rows
 */
VALUE
Image_base_rows(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return INT2FIX(image->magick_rows);
}


/**
 * Get image bias (used when convolving an image).
 *
 * @return [Float] the image bias
 */
VALUE
Image_bias(VALUE self)
{
    Image *image;
    double bias = 0.0;

    image = rm_check_destroyed(self);
#if defined(IMAGEMAGICK_7)
    {
        const char *artifact = GetImageArtifact(image, "convolve:bias");
        if (artifact != (const char *) NULL)
        {
            char *q;

            bias = InterpretLocaleValue(artifact, &q);
            if (*q == '%')
            {
                bias *= ((double) QuantumRange + 1.0) / 100.0;
            }
        }
    }
#else
    bias = image->bias;
#endif
    return rb_float_new(bias);
}


/**
 * Set image bias (used when convolving an image).
 *
 * @param pct [Float, String] Either a number between 0.0 and 1.0 or a string in the form "NN%"
 * @return [Float, String] the given value
 */
VALUE
Image_bias_eq(VALUE self, VALUE pct)
{
    Image *image;
    double bias;

    image = rm_check_frozen(self);
    bias = rm_percentage(pct, 1.0) * QuantumRange;

#if defined(IMAGEMAGICK_7)
    {
        char artifact[21];

        snprintf(artifact, sizeof(artifact), "%.20g", bias);
        SetImageArtifact(image, "convolve:bias", artifact);
    }
#else
    image->bias = bias;
#endif

    return pct;
}

/**
 * Changes the value of individual pixels based on the intensity of each pixel channel. The result
 * is a high-contrast image.
 *
 * @overload bilevel_channel(threshold, channel = Magick::AllChannels)
 *   @param threshold [Float] The threshold value, a number between 0 and QuantumRange.
 *
 * @overload bilevel_channel(threshold, *channels)
 *   @param threshold [Float] The threshold value, a number between 0 and QuantumRange.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_bilevel_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    ChannelType channels;
    double threshold;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);

    if (argc > 1)
    {
        raise_ChannelType_error(argv[argc-1]);
    }
    if (argc == 0)
    {
        rb_raise(rb_eArgError, "no threshold specified");
    }

    threshold = NUM2DBL(argv[0]);
    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BEGIN_CHANNEL_MASK(new_image, channels);
    BilevelImage(new_image, threshold, exception);
    END_CHANNEL_MASK(new_image);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    BilevelImageChannel(new_image, channels, threshold);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Return current black point compensation attribute.
 *
 * @return [Boolean] true or false
 */
VALUE
Image_black_point_compensation(VALUE self)
{
    Image *image;
    const char *attr;
    VALUE value;

    image = rm_check_destroyed(self);

    attr = rm_get_property(image, BlackPointCompensationKey);
    if (attr && rm_strcasecmp(attr, "true") == 0)
    {
        value = Qtrue;
    }
    else
    {
        value = Qfalse;
    }

    RB_GC_GUARD(value);

    return value;
}


/**
 * Set black point compensation attribute.
 *
 * @param arg [Boolean] true or false
 * @return [Boolean] the given value
 */
VALUE
Image_black_point_compensation_eq(VALUE self, VALUE arg)
{
    Image *image;
    const char *value;

    image = rm_check_frozen(self);
    rm_set_property(image, BlackPointCompensationKey, NULL);
    value = RTEST(arg) ? "true" : "false";
    rm_set_property(image, BlackPointCompensationKey, value);

    return arg;
}


/**
 * Forces all pixels below the threshold into black while leaving all pixels above the threshold
 * unchanged.
 *
 * @overload black_threshold(red)
 *   @param red [Numeric] the number for red channel
 *
 * @overload black_threshold(red, green)
 *   @param red [Numeric] the number for red channel
 *   @param green [Numeric] the number for green channel
 *
 * @overload black_threshold(red, green, blue)
 *   @param red [Numeric] the number for red channel
 *   @param green [Numeric] the number for green channel
 *   @param blue [Numeric] the number for blue channel
 *
 * @overload black_threshold(red, green, blue, alpha:)
 *   @param red [Numeric] the number for red channel
 *   @param green [Numeric] the number for green channel
 *   @param blue [Numeric] the number for blue channel
 *   @param alpha [Numeric] the number for alpha channel
 *
 * @return [Numeric] a new image
 * @see Image#white_threshold
 */
VALUE
Image_black_threshold(int argc, VALUE *argv, VALUE self)
{
    return threshold_image(argc, argv, self, BlackThresholdImage);
}


/**
 * Compute offsets using the gravity to determine what the offsets are relative
 * to.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - No return value: modifies x_offset and y_offset directly.
 *
 * @param grav the gravity
 * @param image the destination image
 * @param mark the source image
 * @param x_offset pointer to x offset
 * @param y_offset pointer to y offset
 */
static void
get_relative_offsets(VALUE grav, Image *image, Image *mark, long *x_offset, long *y_offset)
{
    GravityType gravity;

    VALUE_TO_ENUM(grav, gravity, GravityType);

    switch (gravity)
    {
        case NorthEastGravity:
        case EastGravity:
        case SouthEastGravity:
            *x_offset = (long)(image->columns) - (long)(mark->columns) - *x_offset;
            break;
        case NorthGravity:
        case SouthGravity:
        case CenterGravity:
            *x_offset += (long)(image->columns/2) - (long)(mark->columns/2);
            break;
        default:
            break;
    }
    switch (gravity)
    {
        case SouthWestGravity:
        case SouthGravity:
        case SouthEastGravity:
            *y_offset = (long)(image->rows) - (long)(mark->rows) - *y_offset;
            break;
        case EastGravity:
        case WestGravity:
        case CenterGravity:
            *y_offset += (long)(image->rows/2) - (long)(mark->rows/2);
            break;
        case NorthEastGravity:
        case NorthGravity:
        default:
            break;
    }

}


/**
 * Compute watermark offsets from gravity type.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - No return value: modifies x_offset and y_offset directly.
 *
 * @param grav the gravity
 * @param image the destination image
 * @param mark the source image
 * @param x_offset pointer to x offset
 * @param y_offset pointer to y offset
 */
static void
get_offsets_from_gravity(GravityType gravity, Image *image, Image *mark,
                         long *x_offset, long *y_offset)
{

    switch (gravity)
    {
        case ForgetGravity:
        case NorthWestGravity:
            *x_offset = 0;
            *y_offset = 0;
            break;
        case NorthGravity:
            *x_offset = ((long)(image->columns) - (long)(mark->columns)) / 2;
            *y_offset = 0;
            break;
        case NorthEastGravity:
            *x_offset = (long)(image->columns) - (long)(mark->columns);
            *y_offset = 0;
            break;
        case WestGravity:
            *x_offset = 0;
            *y_offset = ((long)(image->rows) - (long)(mark->rows)) / 2;
            break;
        case CenterGravity:
        default:
            *x_offset = ((long)(image->columns) - (long)(mark->columns)) / 2;
            *y_offset = ((long)(image->rows) - (long)(mark->rows)) / 2;
            break;
        case EastGravity:
            *x_offset = (long)(image->columns) - (long)(mark->columns);
            *y_offset = ((long)(image->rows) - (long)(mark->rows)) / 2;
            break;
        case SouthWestGravity:
            *x_offset = 0;
            *y_offset = (long)(image->rows) - (long)(mark->rows);
            break;
        case SouthGravity:
            *x_offset = ((long)(image->columns) - (long)(mark->columns)) / 2;
            *y_offset = (long)(image->rows) - (long)(mark->rows);
            break;
        case SouthEastGravity:
            *x_offset = (long)(image->columns) - (long)(mark->columns);
            *y_offset = (long)(image->rows) - (long)(mark->rows);
            break;
    }
}


/**
 * Called from rb_protect, returns the number if obj is really a numeric value.
 *
 * No Ruby usage (internal function)
 *
 * @param obj the value
 * @return numeric value of obj
 * @todo Make sure that we are really returning the obj here
 */
static VALUE
check_for_long_value(VALUE obj)
{
    return LONG2NUM(NUM2LONG(obj));
}


/**
 * Compute x- and y-offset of source image for a compositing method.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - No return value: modifies x_offset and y_offset directly.
 *
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param dest the destination image
 * @param src the source image
 * @param x_offset pointer to x offset
 * @param y_offset pointer to y offset
 */
static void
get_composite_offsets(int argc, VALUE *argv, Image *dest, Image *src,
                      long *x_offset, long *y_offset)
{
    GravityType gravity;
    int exc = 0;

    if (CLASS_OF(argv[0]) == Class_GravityType)
    {
        VALUE_TO_ENUM(argv[0], gravity, GravityType);

        switch (argc)
        {
            // Gravity + offset(s). Offsets are relative to the image edges
            // as specified by the gravity.
            case 3:
                *y_offset = NUM2LONG(argv[2]);
            case 2:
                *x_offset = NUM2LONG(argv[1]);
                get_relative_offsets(argv[0], dest, src, x_offset, y_offset);
                break;
            case 1:
                // No offsets specified. Compute offset based on the gravity alone.
                get_offsets_from_gravity(gravity, dest, src, x_offset, y_offset);
                break;
        }
    }
    // Gravity not specified at all. Offsets are measured from the
    // NorthWest corner. The arguments must be numbers.
    else
    {
        rb_protect(check_for_long_value, argv[0], &exc);
        if (exc)
        {
            rb_raise(rb_eTypeError, "expected GravityType, got %s",
                     rb_class2name(CLASS_OF(argv[0])));
        }
        *x_offset = NUM2LONG(argv[0]);
        if (argc > 1)
        {
            *y_offset = NUM2LONG(argv[1]);
        }
    }

}


/**
 * Convert 2 doubles to a blend or dissolve geometry string.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - the geometry buffer needs to be at least 16 characters long.
 *   - For safety's sake this function asserts that it is at least 20 characters
 *     long.
 *   - The percentages must be in the range -1000 < n < 1000. This is far in
 *     excess of what xMagick will allow.
 *
 * @param geometry the geometry
 * @param geometry_l length of geometry
 * @param src_percent source percentage
 * @param dst_percent destination percentage
 */
static void
blend_geometry(char *geometry, size_t geometry_l, double src_percent, double dst_percent)
{
    size_t sz = 0;
    int fw, prec;

    if (fabs(src_percent) >= 1000.0 || fabs(dst_percent) >= 1000.0)
    {
        if (fabs(src_percent) < 1000.0)
        {
            src_percent = dst_percent;
        }
        rb_raise(rb_eArgError, "%g is out of range +/-999.99", src_percent);
    }

    assert(geometry_l >= 20);
    memset(geometry, 0xdf, geometry_l);

    fw = 4;
    prec = 0;
    if (src_percent != floor(src_percent))
    {
        prec = 2;
        fw += 3;
    }

    sz = (size_t)snprintf(geometry, geometry_l, "%*.*f", -fw, prec, src_percent);
    assert(sz < geometry_l);

    sz = strcspn(geometry, " ");

    // if dst_percent was nil don't add to the geometry
    if (dst_percent != -1.0)
    {
        fw = 4;
        prec = 0;
        if (dst_percent != floor(dst_percent))
        {
            prec = 2;
            fw += 3;
        }


        sz += (size_t)snprintf(geometry+sz, geometry_l-sz, "x%*.*f", -fw, prec, dst_percent);
        assert(sz < geometry_l);
        sz = strcspn(geometry, " ");
    }

    if (sz < geometry_l)
    {
        memset(geometry+sz, 0x00, geometry_l-sz);
    }

}


/**
 * Create a composite of an image and an overlay (for blending, dissolving, etc.).
 *
 * No Ruby usage (internal function)
 *
 * @param image the original image
 * @param overlay the overlay
 * @param image_pct image percentage
 * @param overlay_pct overlay percentage
 * @param x_off the x offset
 * @param y_off the y offset
 * @param op the composite operator to use
 * @return a new image
 */
static VALUE
special_composite(Image *image, Image *overlay, double image_pct, double overlay_pct,
                  long x_off, long y_off, CompositeOperator op)
{
    Image *new_image;
    char geometry[20];
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    blend_geometry(geometry, sizeof(geometry), image_pct, overlay_pct);
    CloneString(&overlay->geometry, geometry);
    SetImageArtifact(overlay, "compose:args", geometry);

    new_image = rm_clone_image(image);
    SetImageArtifact(new_image, "compose:args", geometry); // 6.9 appears to get this info from canvas (dest) image


#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    CompositeImage(new_image, overlay, op, MagickTrue, x_off, y_off, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    CompositeImage(new_image, op, overlay, x_off, y_off);

    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Adds the overlay image to the target image according to src_percent and dst_percent.
 *
 * - The default value for dst_percent is 100%-src_percent
 *
 * @overload blend(overlay, src_percent, dst_percent, gravity = Magick::NorthWestGravity, x_offset = 0, y_offset = 0)
 *   @param overlay [Magick::Image, Magick::ImageList] The source image for the composite operation.
 *     Either an imagelist or an image. If an imagelist, uses the current image.
 *   @param src_percent [Float, String] Either a non-negative number a string in the form "NN%".
 *     If src_percentage is a number it is interpreted as a percentage.
 *     Both 0.25 and "25%" mean 25%. This argument is required.
 *   @param dst_percent [Float, String] Either a non-negative number a string in the form "NN%".
 *     If src_percentage is a number it is interpreted as a percentage.
 *     Both 0.25 and "25%" mean 25%. This argument may omitted if no other arguments follow it.
 *     In this case the default is 100%-src_percentage.
 *   @param gravity [Magick::GravityType] the gravity for offset. the offsets are measured from the NorthWest corner by default.
 *   @param x_offset [Numeric] The offset that measured from the left-hand side of the target image.
 *   @param y_offset [Numeric] The offset that measured from the top of the target image.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_blend(int argc, VALUE *argv, VALUE self)
{
    VALUE ovly;
    Image *image, *overlay;
    double src_percent, dst_percent;
    long x_offset = 0L, y_offset = 0L;

    image = rm_check_destroyed(self);

    if (argc < 1)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 to 6)", argc);
    }

    ovly = rm_cur_image(argv[0]);
    overlay = rm_check_destroyed(ovly);

    if (argc > 3)
    {
        get_composite_offsets(argc-3, &argv[3], image, overlay, &x_offset, &y_offset);
        // There must be 3 arguments left
        argc = 3;
    }

    switch (argc)
    {
        case 3:
            dst_percent = rm_percentage(argv[2], 1.0) * 100.0;
            src_percent = rm_percentage(argv[1], 1.0) * 100.0;
            break;
        case 2:
            src_percent = rm_percentage(argv[1], 1.0) * 100.0;
            dst_percent = FMAX(100.0 - src_percent, 0);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 to 6)", argc);
            break;
    }

    RB_GC_GUARD(ovly);

    return special_composite(image, overlay, src_percent, dst_percent,
                             x_offset, y_offset, BlendCompositeOp);

}



/**
 * Simulate a scene at nighttime in the moonlight.
 *
 * @overload blue_shift(factor = 1.5)
 *   @param factor [Float] Larger values increase the effect.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_blue_shift(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double factor = 1.5;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 1:
            factor = NUM2DBL(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
            break;
    }


    exception = AcquireExceptionInfo();
    new_image = BlueShiftImage(image, factor, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Blurs the specified channel.
 * Convolves the image with a Gaussian operator of the given radius and standard deviation (sigma).
 *
 * @overload blur_channel(radius = 0.0, sigma = 1.0, channel = Magick::AllChannels)
 *   @param radius [Float] the radius value
 *   @param sigma [Float] the sigma value
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload blur_channel(radius = 0.0, sigma = 1.0, *channels)
 *   @param radius [Float] the radius value
 *   @param sigma [Float] the sigma value
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_blur_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    ExceptionInfo *exception;
    ChannelType channels;
    double radius = 0.0, sigma = 1.0;

    image = rm_check_destroyed(self);

    channels = extract_channels(&argc, argv);

    // There can be 0, 1, or 2 remaining arguments.
    switch (argc)
    {
        case 2:
            sigma = NUM2DBL(argv[1]);
        case 1:
            radius = NUM2DBL(argv[0]);
        case 0:
            break;
        default:
            raise_ChannelType_error(argv[argc-1]);
    }

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    new_image = BlurImage(image, radius, sigma, exception);
    CHANGE_RESULT_CHANNEL_MASK(new_image);
    END_CHANNEL_MASK(image);
#else
    new_image = BlurImageChannel(image, channels, radius, sigma, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Blur the image.
 *
 * @overload blur_image(radius = 0.0, sigma = 1.0)
 *   @param radius [Float] the radius value
 *   @param sigma [Float] the sigma value
 *   @return [Magick::Image] a new image
 */
VALUE
Image_blur_image(int argc, VALUE *argv, VALUE self)
{
    return effect_image(self, argc, argv, BlurImage);
}


/**
 * Surrounds the image with a border of the specified width, height, and named
 * color.
 *
 * No Ruby usage (internal function)
 *
 * @param bang whether the bang (!) version of the method was called
 * @param self this object
 * @param width the width of the border
 * @param height the height of the border
 * @param color the color of the border
 * @return self if bang, otherwise a new image
 * @see Image_border
 * @see Image_border_bang
 */
static VALUE
border(int bang, VALUE self, VALUE width, VALUE height, VALUE color)
{
    Image *image, *new_image;
    PixelColor old_border;
    ExceptionInfo *exception;
    RectangleInfo rect;

    Data_Get_Struct(self, Image, image);

    memset(&rect, 0, sizeof(rect));
    rect.width = NUM2UINT(width);
    rect.height = NUM2UINT(height);

    // Save current border color - we'll want to restore it afterwards.
    old_border = image->border_color;
    Color_to_PixelColor(&image->border_color, color);

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    new_image = BorderImage(image, &rect, image->compose, exception);
#else
    new_image = BorderImage(image, &rect, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    if (bang)
    {
        rm_ensure_result(new_image);
        new_image->border_color = old_border;
        UPDATE_DATA_PTR(self, new_image);
        rm_image_destroy(image);
        return self;
    }

    image->border_color = old_border;
    return rm_image_new(new_image);
}

/**
 * Surrounds the image with a border of the specified width, height, and named color.
 * In-place form of {Image#border}.
 *
 * @param width [Numeric] the width of the border
 * @param height [Numeric] the height of the border
 * @param color [Magick::Pixel, String] the color of the border
 */
VALUE
Image_border_bang(VALUE self, VALUE width, VALUE height, VALUE color)
{
    rm_check_frozen(self);
    return border(True, self, width, height, color);
}


/**
 * Surrounds the image with a border of the specified width, height, and named color.
 *
 * @param width [Numeric] the width of the border
 * @param height [Numeric] the height of the border
 * @param color [Magick::Pixel, String] the color of the border
 * @return [Magick::Image] a new image
 */
VALUE
Image_border(VALUE self, VALUE width, VALUE height, VALUE color)
{
    rm_check_destroyed(self);
    return border(False, self, width, height, color);
}


/**
 * Return the name of the border color as a String.
 *
 * @return [String] the name of the border color
 */
VALUE
Image_border_color(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return rm_pixelcolor_to_color_name(image, &image->border_color);
}


/**
 * Set the the border color.
 *
 * @param [Magick::Pixel, String] color the color
 * @return [Magick::Pixel, String] the given color
 */
VALUE
Image_border_color_eq(VALUE self, VALUE color)
{
    Image *image = rm_check_frozen(self);
    Color_to_PixelColor(&image->border_color, color);
    return color;
}


/**
 * Returns the bounding box of an image canvas.
 *
 * @return [Magick::Rectangle] the bounding box
 */
VALUE
Image_bounding_box(VALUE self)
{
    Image *image;
    RectangleInfo box;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    exception = AcquireExceptionInfo();
    box = GetImageBoundingBox(image, exception);
    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    return Import_RectangleInfo(&box);
}


/**
 * Reads an image from an X window.
 * Unless you identify a window to capture via the optional arguments block, when capture is invoked
 * the cursor will turn into a cross. Click the cursor on the window to be captured.
 *
 * @overload capture(silent = false, frame = false, descend = false, screen = false, borders = false)
 *   @param silent [Boolean] If true, suppress the beeps that signal the start and finish of the
 *     capture process.
 *   @param frame [Boolean] If true, include the window frame.
 *   @param descend [Boolean] If true, obtain image by descending window hierarchy.
 *   @param screen [Boolean] If true, specifies that the GetImage request used to obtain the image
 *     should be done on the root window, rather than directly on the specified window. In this way,
 *     you can obtain pieces of other windows that overlap the specified window, and more
 *     importantly, you can capture menus or other popups that are independent windows but appear
 *     over the specified window.
 *   @param borders [Boolean] If true, include the border in the image.
 *
 * @overload capture(silent = false, frame = false, descend = false, screen = false, borders = false)
 *   This yields {Magick::Image::Info} to block with its object's scope.
 *   @param silent [Boolean] If true, suppress the beeps that signal the start and finish of the
 *     capture process.
 *   @param frame [Boolean] If true, include the window frame.
 *   @param descend [Boolean] If true, obtain image by descending window hierarchy.
 *   @param screen [Boolean] If true, specifies that the GetImage request used to obtain the image
 *     should be done on the root window, rather than directly on the specified window. In this way,
 *     you can obtain pieces of other windows that overlap the specified window, and more
 *     importantly, you can capture menus or other popups that are independent windows but appear
 *     over the specified window.
 *   @param borders [Boolean] If true, include the border in the image.
 *   @yield [Magick::Image::Info]
 *
 * @return [Magick::Image] a new image
 * @example
 *   img = Image.capture { |options|
 *     options.filename = "root"
 *   }
 */
VALUE
Image_capture(int argc, VALUE *argv, VALUE self ATTRIBUTE_UNUSED)
{
    Image *new_image;
    ImageInfo *image_info;
    VALUE info_obj;
    XImportInfo ximage_info;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    XGetImportInfo(&ximage_info);
    switch (argc)
    {
        case 5:
            ximage_info.borders = (MagickBooleanType)RTEST(argv[4]);
        case 4:
            ximage_info.screen  = (MagickBooleanType)RTEST(argv[3]);
        case 3:
            ximage_info.descend = (MagickBooleanType)RTEST(argv[2]);
        case 2:
            ximage_info.frame   = (MagickBooleanType)RTEST(argv[1]);
        case 1:
            ximage_info.silent  = (MagickBooleanType)RTEST(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 5)", argc);
            break;
    }

    // Get optional parms.
    // Set info->filename = "root", window ID number or window name,
    //  or nothing to do an interactive capture
    // Set info->server_name to the server name
    // Also info->colorspace, depth, dither, interlace, type
    info_obj = rm_info_new();
    Data_Get_Struct(info_obj, Info, image_info);

    // If an error occurs, IM will call our error handler and we raise an exception.
#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    new_image = XImportImage(image_info, &ximage_info, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    new_image = XImportImage(image_info, &ximage_info);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    rm_ensure_result(new_image);

    rm_set_user_artifact(new_image, image_info);

    RB_GC_GUARD(info_obj);

    return rm_image_new(new_image);
}


/**
 * This method supports resizing a method by specifying constraints.
 * For example, you can specify that the image should be resized such that the aspect ratio should
 * be retained but the resulting image should be no larger than 640 pixels wide and 480 pixels tall.
 *
 * @param geom_arg [String] the geometry string
 * @yield [column, row, image]
 * @yieldparam column [Numeric] The desired column size
 * @yieldparam row [Numeric] The desired row size
 * @yieldparam image [Magick::Image] self
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 * @example
 *   image.change_geometry!('320x240') { |cols, rows, img|
 *     img.resize!(cols, rows)
 *   }
 * @note {Magick::Image#change_geometry!} is an alias for {Magick::Image#change_geometry}.
 */
VALUE
Image_change_geometry(VALUE self, VALUE geom_arg)
{
    Image *image;
    RectangleInfo rect;
    VALUE geom_str;
    char *geometry;
    unsigned int flags;
    VALUE ary;

    image = rm_check_destroyed(self);
    geom_str = rb_String(geom_arg);
    geometry = StringValueCStr(geom_str);

    memset(&rect, 0, sizeof(rect));

    SetGeometry(image, &rect);
    flags = ParseMetaGeometry(geometry, &rect.x, &rect.y, &rect.width, &rect.height);
    if (flags == NoValue)
    {
        rb_raise(rb_eArgError, "invalid geometry string `%s'", geometry);
    }

    ary = rb_ary_new2(3);
    rb_ary_store(ary, 0, ULONG2NUM(rect.width));
    rb_ary_store(ary, 1, ULONG2NUM(rect.height));
    rb_ary_store(ary, 2, self);

    RB_GC_GUARD(geom_str);
    RB_GC_GUARD(ary);

    return rb_yield(ary);
}


/**
 * Return true if any pixel in the image has been altered since the image was constituted.
 *
 * @return [Boolean] true if altered, false otherwise
 */
VALUE
Image_changed_q(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    VALUE okay = IsTaintImage(image) ? Qtrue : Qfalse;
    return okay;
}


/**
 * Extract a channel from the image. A channel is a particular color component of each pixel in the
 * image.
 *
 * @param channel_arg [Magick::ChannelType] the type of the channel to extract
 * @return [Magick::Image] a new image
 */
VALUE
Image_channel(VALUE self, VALUE channel_arg)
{
    Image *image, *new_image;
    ChannelType channel;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

    VALUE_TO_ENUM(channel_arg, channel, ChannelType);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    new_image = SeparateImage(image, channel, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    new_image = rm_clone_image(image);
    SeparateImageChannel(new_image, channel);

    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Returns the maximum depth for the specified channel or channels.
 *
 * @overload channel_depth(channel = Magick::AllChannels)
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload channel_depth(*channels)
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Numeric] the channel depth
 */
VALUE
Image_channel_depth(int argc, VALUE *argv, VALUE self)
{
    Image *image;
    ChannelType channels;
    unsigned long channel_depth;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);

    // Ensure all arguments consumed.
    if (argc > 0)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    exception = AcquireExceptionInfo();

#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    channel_depth = GetImageDepth(image, exception);
    END_CHANNEL_MASK(image);
#else
    channel_depth = GetImageChannelDepth(image, channels, exception);
#endif
    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    return ULONG2NUM(channel_depth);
}


/**
 * Returns the minimum and maximum intensity values for the specified channel or channels.
 *
 * @overload channel_extrema(channel = Magick::AllChannels)
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload channel_extrema(*channels)
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Array<Numeric>] The first element in the array is the minimum value. The second element is the
 *   maximum value.
 */
VALUE
Image_channel_extrema(int argc, VALUE *argv, VALUE self)
{
    Image *image;
    ChannelType channels;
    ExceptionInfo *exception;
    size_t min, max;
    VALUE ary;

    image = rm_check_destroyed(self);

    channels = extract_channels(&argc, argv);

    // Ensure all arguments consumed.
    if (argc > 0)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    GetImageExtrema(image, &min, &max, exception);
    END_CHANNEL_MASK(image);
#else
    GetImageChannelExtrema(image, channels, &min, &max, exception);
#endif
    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    ary = rb_ary_new2(2);
    rb_ary_store(ary, 0, ULONG2NUM(min));
    rb_ary_store(ary, 1, ULONG2NUM(max));

    RB_GC_GUARD(ary);

    return ary;
}


/**
 * Returns the mean and standard deviation values for the specified channel or channels.
 *
 * @overload channel_mean(channel = Magick::AllChannels)
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload channel_mean(*channels)
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Array<Float>] The first element in the array is the mean value. The second element is the
 *   standard deviation.
 */
VALUE
Image_channel_mean(int argc, VALUE *argv, VALUE self)
{
    Image *image;
    ChannelType channels;
    ExceptionInfo *exception;
    double mean, stddev;
    VALUE ary;

    image = rm_check_destroyed(self);

    channels = extract_channels(&argc, argv);

    // Ensure all arguments consumed.
    if (argc > 0)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    GetImageMean(image, &mean, &stddev, exception);
    END_CHANNEL_MASK(image);
#else
    GetImageChannelMean(image, channels, &mean, &stddev, exception);
#endif
    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    ary = rb_ary_new2(2);
    rb_ary_store(ary, 0, rb_float_new(mean));
    rb_ary_store(ary, 1, rb_float_new(stddev));

    RB_GC_GUARD(ary);

    return ary;
}

/**
 * Return an array of the entropy for the channel.
 *
 * @overload channel_entropy(channel = Magick::AllChannels)
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload channel_entropy(*channels)
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Array<Float>] The first element in the array is the average entropy of the selected channels.
 */
#if defined(HAVE_GETIMAGECHANNELENTROPY) || defined(IMAGEMAGICK_7)
VALUE
Image_channel_entropy(int argc, VALUE *argv, VALUE self)
{
    Image *image;
    ChannelType channels;
    ExceptionInfo *exception;
    double entropy;
    VALUE ary;

    image = rm_check_destroyed(self);

    channels = extract_channels(&argc, argv);

    // Ensure all arguments consumed.
    if (argc > 0)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    GetImageEntropy(image, &entropy, exception);
    END_CHANNEL_MASK(image);
#else
    GetImageChannelEntropy(image, channels, &entropy, exception);
#endif
    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    ary = rb_ary_new2(1);
    rb_ary_store(ary, 0, rb_float_new(entropy));

    RB_GC_GUARD(ary);

    return ary;
}
#else
VALUE
Image_channel_entropy(int argc ATTRIBUTE_UNUSED, VALUE *argv ATTRIBUTE_UNUSED, VALUE self ATTRIBUTE_UNUSED)
{
    rm_not_implemented();
}
#endif

/**
 * Return a new image that is a copy of the input image with the edges highlighted.
 *
 * @overload charcoal(radius = 0.0, sigma = 1.0)
 *   @param radius [Float] The radius of the pixel neighborhood.
 *   @param sigma [Float] The standard deviation of the Gaussian, in pixels.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_charcoal(int argc, VALUE *argv, VALUE self)
{
    return effect_image(self, argc, argv, CharcoalImage);
}


/**
 * Raises {Magick::DestroyedImageError} if the image has been destroyed. Returns nil otherwise.
 *
 * @return [nil] nil
 * @raise [Magick::DestroyedImageError] raise if the image has been destroyed
 */
VALUE
Image_check_destroyed(VALUE self)
{
    rm_check_destroyed(self);
    return Qnil;
}


/**
 * Remove a region of an image and collapses the image to occupy the removed portion.
 *
 * @param x [Numeric] x position of start of region
 * @param y [Numeric] y position of start of region
 * @param width [Numeric] width of region
 * @param height [Numeric] height of region
 * @return [Magick::Image] a new image
 */
VALUE
Image_chop(VALUE self, VALUE x, VALUE y, VALUE width, VALUE height)
{
    rm_check_destroyed(self);
    return xform_image(False, self, x, y, width, height, ChopImage);
}


/**
 * Return the red, green, blue, and white-point chromaticity values as a {Magick::Chromaticity}.
 *
 * @return [Magick::Chromaticity] the chromaticity values
 */
VALUE
Image_chromaticity(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return ChromaticityInfo_new(&image->chromaticity);
}


/**
 * Set the red, green, blue, and white-point chromaticity values from a {Magick::Chromaticity}.
 *
 * @param [Magick::Chromaticity] chroma the chromaticity
 * @return [Magick::Chromaticity] the given value
 */
VALUE
Image_chromaticity_eq(VALUE self, VALUE chroma)
{
    Image *image = rm_check_frozen(self);
    Export_ChromaticityInfo(&image->chromaticity, chroma);
    return chroma;
}


/**
 * Same as {Magick::Image#dup} except the frozen state of the original is propagated to the new
 * copy.
 *
 * @return [Magick::Image] a clone of this object
 */
VALUE
Image_clone(VALUE self)
{
    VALUE clone;

    clone = Image_dup(self);
    if (OBJ_FROZEN(self))
    {
        OBJ_FREEZE(clone);
    }

    RB_GC_GUARD(clone);

    return clone;
}


/**
 * Replace the channel values in the target image with a lookup of its replacement value in an LUT
 * gradient image.
 *
 * The LUT image should be either a single row or column image of replacement colors.
 * The lookup is controlled by the -interpolate setting, especially for an LUT which is not the full
 * length needed by the IM installed Quality (Q) level.  Good settings for this is the default
 * 'bilinear' or 'bicubic' interpolation setting for a smooth color gradient, or 'integer' for a
 * direct unsmoothed lookup of color values.
 *
 * This method is especially suited to replacing a grayscale image with specific color gradient from
 * the CLUT image.
 *
 * @overload clut_channel(clut_image, channel = Magick::AllChannels)
 *   @param clut_image [Magick::Image] The LUT gradient image.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload clut_channel(clut_image, *channels)
 *   @param clut_image [Magick::Image] The LUT gradient image.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] self
 */
VALUE
Image_clut_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *clut;
    ChannelType channels;
    MagickBooleanType okay;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_frozen(self);

    // check_destroyed before confirming the arguments
    if (argc >= 1)
    {
        rm_check_destroyed(argv[0]);
        channels = extract_channels(&argc, argv);
        if (argc != 1)
        {
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or more)", argc);
        }
    }
    else
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or more)", argc);
    }

    Data_Get_Struct(argv[0], Image, clut);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BEGIN_CHANNEL_MASK(image, channels);
    okay = ClutImage(image, clut, image->interpolate, exception);
    END_CHANNEL_MASK(image);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    okay = ClutImageChannel(image, channels, clut);
    rm_check_image_exception(image, RetainOnError);
    rm_check_image_exception(clut, RetainOnError);
#endif
    if (!okay)
    {
        rb_raise(rb_eRuntimeError, "ClutImageChannel failed.");
    }

    return self;
}


/**
 * Computes the number of times each unique color appears in the image.
 *
 * @return [Hash] Each key in the hash is a pixel representing a color that appears in the image.
 *   The value associated with the key is the number of times that color appears in the image.
 */
VALUE
Image_color_histogram(VALUE self)
{
    Image *image, *dc_copy = NULL;
    VALUE hash, pixel;
    size_t x, colors;
    ExceptionInfo *exception;
#if defined(IMAGEMAGICK_7)
    PixelInfo *histogram;
#else
    ColorPacket *histogram;
#endif

    image = rm_check_destroyed(self);

    exception = AcquireExceptionInfo();

    // If image not DirectClass make a DirectClass copy.
    if (image->storage_class != DirectClass)
    {
        dc_copy = rm_clone_image(image);
#if defined(IMAGEMAGICK_7)
        SetImageStorageClass(dc_copy, DirectClass, exception);
#else
        SetImageStorageClass(dc_copy, DirectClass);
#endif
        image = dc_copy;
    }

    histogram = GetImageHistogram(image, &colors, exception);

    if (histogram == NULL)
    {
        if (dc_copy)
        {
            DestroyImage(dc_copy);
        }
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }
    if (rm_should_raise_exception(exception, DestroyExceptionRetention))
    {
        RelinquishMagickMemory(histogram);
        if (dc_copy)
        {
            DestroyImage(dc_copy);
        }

        rm_raise_exception(exception);
    }

    hash = rb_hash_new();
    for (x = 0; x < colors; x++)
    {
#if defined(IMAGEMAGICK_7)
        pixel = Pixel_from_PixelColor(&histogram[x]);
#else
        pixel = Pixel_from_PixelColor(&histogram[x].pixel);
#endif
        rb_hash_aset(hash, pixel, ULONG2NUM((unsigned long)histogram[x].count));
    }

    /*
        Christy evidently didn't agree with Bob's memory management.
    */
    RelinquishMagickMemory(histogram);

    if (dc_copy)
    {
        // Do not trace destruction
        DestroyImage(dc_copy);
    }

    RB_GC_GUARD(hash);
    RB_GC_GUARD(pixel);

    return hash;
}


/**
 * Store all the profiles in the profile in the target image. Called from
 * Image_color_profile_eq and Image_iptc_profile_eq.
 *
 * No Ruby usage (internal function)
 *
 * @param self this object
 * @param name profile name
 * @param profile an IPTC or ICC profile
 * @return self
 */
static VALUE
set_profile(VALUE self, const char *name, VALUE profile)
{
    Image *image, *profile_image;
    ImageInfo *info;
    const MagickInfo *m;
    ExceptionInfo *exception;
    char *profile_name;
    char *profile_blob;
    long profile_length;
    const StringInfo *profile_data;

    image = rm_check_frozen(self);

    profile_blob = rm_str2cstr(profile, &profile_length);

    exception = AcquireExceptionInfo();
    m = GetMagickInfo(name, exception);
    CHECK_EXCEPTION();
    if (!m)
    {
        DestroyExceptionInfo(exception);
        rb_raise(rb_eArgError, "unknown name: %s", name);
    }

    info = CloneImageInfo(NULL);
    if (!info)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }

    strlcpy(info->magick, m->name, sizeof(info->magick));

    profile_image = BlobToImage(info, profile_blob, (size_t)profile_length, exception);
    DestroyImageInfo(info);
    CHECK_EXCEPTION();

    ResetImageProfileIterator(profile_image);
    profile_name = GetNextImageProfile(profile_image);
    while (profile_name)
    {
        /* Hack for versions of ImageMagick where the meta coder would change the iptc profile into an 8bim profile */
        if (rm_strcasecmp("8bim", profile_name) == 0 && rm_strcasecmp("iptc", name) == 0)
        {
#if defined(IMAGEMAGICK_7)
            ProfileImage(image, name, profile_blob, profile_length, exception);
            if (rm_should_raise_exception(exception, RetainExceptionRetention))
#else
            ProfileImage(image, name, profile_blob, profile_length, MagickFalse);
            if (rm_should_raise_exception(&image->exception, RetainExceptionRetention))
#endif
            {
                break;
            }
        }
        else if (rm_strcasecmp(profile_name, name) == 0)
        {
            profile_data = GetImageProfile(profile_image, profile_name);
            if (profile_data)
            {
#if defined(IMAGEMAGICK_7)
                ProfileImage(image, name, GetStringInfoDatum(profile_data), GetStringInfoLength(profile_data), exception);
                if (rm_should_raise_exception(exception, RetainExceptionRetention))
#else
                ProfileImage(image, name, GetStringInfoDatum(profile_data), GetStringInfoLength(profile_data), MagickFalse);
                if (rm_should_raise_exception(&image->exception, RetainExceptionRetention))
#endif
                {
                    break;
                }
            }
        }
        profile_name = GetNextImageProfile(profile_image);
    }

    DestroyImage(profile_image);

#if defined(IMAGEMAGICK_7)
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    DestroyExceptionInfo(exception);
    rm_check_image_exception(image, RetainOnError);
#endif

    return self;
}


/**
 * Return the ICC color profile as a String.
 *
 * - If there is no profile, returns ""
 * - This method has no real use but is retained for compatibility with earlier releases of RMagick,
 *   where it had no real use either.
 *
 * @return [String, nil] the ICC color profile
 */
VALUE
Image_color_profile(VALUE self)
{
    Image *image;
    const StringInfo *profile;

    image = rm_check_destroyed(self);
    profile = GetImageProfile(image, "icc");
    if (!profile)
    {
        return Qnil;
    }

    return rb_str_new((char *)profile->datum, (long)profile->length);

}


/**
 * Set the ICC color profile.
 *
 * - Pass nil to remove any existing profile.
 * - Removes any existing profile before adding the new one.
 *
 * @param profile [String] the profile to set
 * @return [String] the given profile
 */
VALUE
Image_color_profile_eq(VALUE self, VALUE profile)
{
    Image_delete_profile(self, rb_str_new2("ICC"));
    if (profile != Qnil)
    {
        set_profile(self, "ICC", profile);
    }
    return profile;
}


/**
 * Change the color value of any pixel that matches target_color and is an immediate neighbor.
 *
 * @param target_color [Magick::Pixel, String] the target color
 * @param fill_color [Magick::Pixel, String] the color to fill
 * @param xv [Numeric] the x position
 * @param yv [Numeric] the y position
 * @param method [Magick::PaintMethod] the method to call
 * @return [Magick::Image] a new image
 * @see Image#opaque
 */
VALUE
Image_color_flood_fill(VALUE self, VALUE target_color, VALUE fill_color,
                       VALUE xv, VALUE yv, VALUE method)
{
    Image *image, *new_image;
    PixelColor target;
    DrawInfo *draw_info;
    PixelColor fill;
    long x, y;
    int fill_method;
    MagickPixel target_mpp;
    MagickBooleanType invert;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

    // The target and fill args can be either a color name or
    // a Magick::Pixel.
    Color_to_PixelColor(&target, target_color);
    Color_to_PixelColor(&fill, fill_color);

    x = NUM2LONG(xv);
    y = NUM2LONG(yv);
    if ((unsigned long)x > image->columns || (unsigned long)y > image->rows)
    {
        rb_raise(rb_eArgError, "target out of range. %lux%lu given, image is %"RMIuSIZE"x%"RMIuSIZE"",
                 x, y, image->columns, image->rows);
    }

    VALUE_TO_ENUM(method, fill_method, PaintMethod);
    if (!(fill_method == FloodfillMethod || fill_method == FillToBorderMethod))
    {
        rb_raise(rb_eArgError, "paint method must be FloodfillMethod or "
                 "FillToBorderMethod (%d given)", fill_method);
    }

    draw_info = CloneDrawInfo(NULL, NULL);
    if (!draw_info)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }
    draw_info->fill = fill;

    new_image = rm_clone_image(image);

    rm_init_magickpixel(new_image, &target_mpp);
    if (fill_method == FillToBorderMethod)
    {
        invert = MagickTrue;
        target_mpp.red   = (MagickRealType) image->border_color.red;
        target_mpp.green = (MagickRealType) image->border_color.green;
        target_mpp.blue  = (MagickRealType) image->border_color.blue;
    }
    else
    {
        invert = MagickFalse;
        target_mpp.red   = (MagickRealType) target.red;
        target_mpp.green = (MagickRealType) target.green;
        target_mpp.blue  = (MagickRealType) target.blue;
    }

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    FloodfillPaintImage(new_image, draw_info, &target_mpp, x, y, invert, exception);
    DestroyDrawInfo(draw_info);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    FloodfillPaintImage(new_image, DefaultChannels, draw_info, &target_mpp, x, y, invert);

    DestroyDrawInfo(draw_info);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Blend the fill color specified by "target" with each pixel in the image. Specify the percentage
 * blend for each r, g, b component.
 *
 * @overload colorize(red, green, blue, target)
 *   @param red [Float] The percentage of the fill color red
 *   @param green [Float] The percentage of the fill color green
 *   @param blue [Float] The percentage of the fill color blue
 *   @param target [Magick::Pixel, String] the color name
 *
 * @overload colorize(red, green, blue, matte, target)
 *   @param red [Float] The percentage of the fill color red
 *   @param green [Float] The percentage of the fill color green
 *   @param blue [Float] The percentage of the fill color blue
 *   @param matte [Float] The percentage of the fill color transparency
 *   @param target [Magick::Pixel, String] the color name
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_colorize(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double red, green, blue, matte;
    char opacity[50];
    PixelColor target;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    if (argc == 4)
    {
        red   = floor(100*NUM2DBL(argv[0])+0.5);
        green = floor(100*NUM2DBL(argv[1])+0.5);
        blue  = floor(100*NUM2DBL(argv[2])+0.5);
        Color_to_PixelColor(&target, argv[3]);
        snprintf(opacity, sizeof(opacity), "%f/%f/%f", red, green, blue);
    }
    else if (argc == 5)
    {
        red   = floor(100*NUM2DBL(argv[0])+0.5);
        green = floor(100*NUM2DBL(argv[1])+0.5);
        blue  = floor(100*NUM2DBL(argv[2])+0.5);
        matte = floor(100*NUM2DBL(argv[3])+0.5);
        Color_to_PixelColor(&target, argv[4]);
        snprintf(opacity, sizeof(opacity), "%f/%f/%f/%f", red, green, blue, matte);
    }
    else
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 4 or 5)", argc);
    }

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    new_image = ColorizeImage(image, opacity, &target, exception);
#else
    new_image = ColorizeImage(image, opacity, target, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Return the color in the colormap at the specified index. If a new color is specified, replaces
 * the color at the index with the new color.
 *
 * @overload colormap(index)
 *   @param index [Numeric] A number between 0 and the number of colors in the color map. If the
 *     value is out of range, colormap raises an IndexError.  You can get the number of colors in
 *     the color map from the colors attribute.
 *
 * @overload colormap(index, new_color)
 *   @param index [Numeric] A number between 0 and the number of colors in the color map. If the
 *     value is out of range, colormap raises an IndexError.  You can get the number of colors in
 *     the color map from the colors attribute.
 *   @param new_color [Magick::Pixel, String] the color name
 *
 * @return [String] the name of the color at the specified location in the color map
 */
VALUE
Image_colormap(int argc, VALUE *argv, VALUE self)
{
    Image *image;
    unsigned long idx;
    PixelColor color, new_color;

    image = rm_check_destroyed(self);

    // We can handle either 1 or 2 arguments. Nothing else.
    if (argc == 0 || argc > 2)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or 2)", argc);
    }

    idx = NUM2ULONG(argv[0]);
    if (idx > QuantumRange)
    {
        rb_raise(rb_eIndexError, "index out of range");
    }

    // If this is a simple "get" operation, ensure the image has a colormap.
    if (argc == 1)
    {
        if (!image->colormap)
        {
            rb_raise(rb_eIndexError, "image does not contain a colormap");
        }
        // Validate the index

        if (idx > image->colors-1)
        {
            rb_raise(rb_eIndexError, "index out of range");
        }
        return rm_pixelcolor_to_color_name(image, &image->colormap[idx]);
    }

    // This is a "set" operation. Things are different.

    rb_check_frozen(self);

    // Replace with new color? The arg can be either a color name or
    // a Magick::Pixel.
    Color_to_PixelColor(&new_color, argv[1]);

    // Handle no colormap or current colormap too small.
    if (!image->colormap || idx > image->colors-1)
    {
        PixelColor black;
        unsigned long i;

        memset(&black, 0, sizeof(black));

        if (!image->colormap)
        {
            image->colormap = (PixelColor *)magick_safe_malloc((idx+1), sizeof(PixelColor));
            image->colors = 0;
        }
        else
        {
            image->colormap = (PixelColor *)magick_safe_realloc(image->colormap, (idx+1), sizeof(PixelColor));
        }

        for (i = image->colors; i < idx; i++)
        {
            image->colormap[i] = black;
        }
        image->colors = idx+1;
    }

    // Save the current color so we can return it. Set the new color.
    color = image->colormap[idx];
    image->colormap[idx] = new_color;

    return rm_pixelcolor_to_color_name(image, &color);
}

/**
 * Get the number of colors in the colormap.
 *
 * @return [Numeric] the number of colors
 */
VALUE
Image_colors(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, colors, ulong);
}

/**
 * Return the Image pixel interpretation. If the colorspace is RGB the pixels are red, green,
 * blue. If matte is true, then red, green, blue, and index. If it is CMYK, the pixels are cyan,
 * yellow, magenta, black. Otherwise the colorspace is ignored.
 *
 * @return [Magick::ColorspaceType] the colorspace
 */
VALUE
Image_colorspace(VALUE self)
{
    Image *image;

    image = rm_check_destroyed(self);
    return ColorspaceType_find(image->colorspace);
}


/**
 * Set the image's colorspace.
 *
 * @param colorspace [Magick::ColorspaceType] the colorspace
 * @return [Magick::ColorspaceType] the given colorspace
 */
VALUE
Image_colorspace_eq(VALUE self, VALUE colorspace)
{
    Image *image;
    ColorspaceType new_cs;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_frozen(self);
    VALUE_TO_ENUM(colorspace, new_cs, ColorspaceType);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    TransformImageColorspace(image, new_cs, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    TransformImageColorspace(image, new_cs);
    rm_check_image_exception(image, RetainOnError);
#endif

    return colorspace;
}


/**
 * Get image columns.
 *
 * @return [Numeric] the columns
 */
VALUE
Image_columns(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, columns, int);
}


/**
 * Compare one or more channels in two images and returns the specified distortion metric and a
 * comparison image.
 *
 * @overload compare_channel(image, metric, channel = Magick::AllChannels)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param metric [Magick::MetricType] The desired distortion metric.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload compare_channel(image, metric, channel = Magick::AllChannels)
 *   When a block is given, compare_channel yields with a block argument you can optionally use to
 *   set attributes.
 *   - options.highlight_color = color
 *     - Emphasize pixel differences with this color. The default is partially transparent red.
 *   - options.lowlight_color = color
 *     - Demphasize pixel differences with this color. The default is partially transparent white.
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param metric [Magick::MetricType] The desired distortion metric.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *   @yield [Magick::OptionalMethodArguments]
 *
 * @overload compare_channel(image, metric, *channels)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param metric [Magick::MetricType] The desired distortion metric.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @overload compare_channel(image, metric, *channels)
 *   When a block is given, compare_channel yields with a block argument you can optionally use to
 *   set attributes.
 *   - options.highlight_color = color
 *     - Emphasize pixel differences with this color. The default is partially transparent red.
 *   - options.lowlight_color = color
 *     - Demphasize pixel differences with this color. The default is partially transparent white.
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param metric [Magick::MetricType] The desired distortion metric.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *   @yield [Magick::OptionalMethodArguments]
 *
 * @return [Array] The first element is a difference image, the second is a the value of the
 *   computed distortion represented as a Float.
 */
VALUE
Image_compare_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *r_image, *difference_image;
    double distortion;
    VALUE ary, ref;
    MetricType metric_type;
    ChannelType channels;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    channels = extract_channels(&argc, argv);

    if (argc > 2)
    {
        raise_ChannelType_error(argv[argc-1]);
    }
    if (argc != 2)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 or more)", argc);
    }

    rm_get_optional_arguments(self);

    ref = rm_cur_image(argv[0]);
    r_image = rm_check_destroyed(ref);

    VALUE_TO_ENUM(argv[1], metric_type, MetricType);

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    difference_image = CompareImages(image, r_image, metric_type, &distortion, exception);
    END_CHANNEL_MASK(image);
#else
    difference_image = CompareImageChannels(image, r_image, channels, metric_type, &distortion, exception);
#endif
    rm_check_exception(exception, difference_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    ary = rb_ary_new2(2);
    rb_ary_store(ary, 0, rm_image_new(difference_image));
    rb_ary_store(ary, 1, rb_float_new(distortion));

    RB_GC_GUARD(ary);
    RB_GC_GUARD(ref);

    return ary;
}


/**
 * Return the composite operator attribute.
 *
 * @return [Magick::CompositeOperator] the composite operator
 */
VALUE
Image_compose(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return CompositeOperator_find(image->compose);
}


/**
 * Set the composite operator attribute.
 *
 * @param compose_arg [Magick::CompositeOperator] the composite operator
 * @return [Magick::CompositeOperator] the given value
 */
VALUE
Image_compose_eq(VALUE self, VALUE compose_arg)
{
    Image *image = rm_check_frozen(self);
    VALUE_TO_ENUM(compose_arg, image->compose, CompositeOperator);
    return compose_arg;
}

/**
 * Call CompositeImage.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - The other image can be either an Image or an Image.
 *   - The use of the GravityType to position the composited image is based on
 *     Magick++.
 *   - The `gravity' argument has the same effect as the -gravity option does in
 *     the `composite' utility.
 *
 * @param bang whether the bang (!) version of the method was called
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @param channels
 * @return self if bang, otherwise new composited image
 * @see Image_composite
 * @see Image_composite_bang
 */
static VALUE
composite(int bang, int argc, VALUE *argv, VALUE self, ChannelType channels)
{
    Image *image, *new_image;
    Image *comp_image;
    CompositeOperator operator = UndefinedCompositeOp;
    GravityType gravity;
    VALUE comp;
    signed long x_offset = 0;
    signed long y_offset = 0;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

    if (bang)
    {
        rb_check_frozen(self);
    }
    if (argc < 3 || argc > 5)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 3, 4, or 5)", argc);
    }


    comp = rm_cur_image(argv[0]);
    comp_image = rm_check_destroyed(comp);
    RB_GC_GUARD(comp);

    switch (argc)
    {
        case 3:                 // argv[1] is gravity, argv[2] is composite_op
            VALUE_TO_ENUM(argv[1], gravity, GravityType);
            VALUE_TO_ENUM(argv[2], operator, CompositeOperator);

            // convert gravity to x, y offsets
            switch (gravity)
            {
                case ForgetGravity:
                case NorthWestGravity:
                    x_offset = 0;
                    y_offset = 0;
                    break;
                case NorthGravity:
                    x_offset = ((long)(image->columns) - (long)(comp_image->columns)) / 2;
                    y_offset = 0;
                    break;
                case NorthEastGravity:
                    x_offset = (long)(image->columns) - (long)(comp_image->columns);
                    y_offset = 0;
                    break;
                case WestGravity:
                    x_offset = 0;
                    y_offset = ((long)(image->rows) - (long)(comp_image->rows)) / 2;
                    break;
                case CenterGravity:
                default:
                    x_offset = ((long)(image->columns) - (long)(comp_image->columns)) / 2;
                    y_offset = ((long)(image->rows) - (long)(comp_image->rows)) / 2;
                    break;
                case EastGravity:
                    x_offset = (long)(image->columns) - (long)(comp_image->columns);
                    y_offset = ((long)(image->rows) - (long)(comp_image->rows)) / 2;
                    break;
                case SouthWestGravity:
                    x_offset = 0;
                    y_offset = (long)(image->rows) - (long)(comp_image->rows);
                    break;
                case SouthGravity:
                    x_offset = ((long)(image->columns) - (long)(comp_image->columns)) / 2;
                    y_offset = (long)(image->rows) - (long)(comp_image->rows);
                    break;
                case SouthEastGravity:
                    x_offset = (long)(image->columns) - (long)(comp_image->columns);
                    y_offset = (long)(image->rows) - (long)(comp_image->rows);
                    break;
            }
            break;

        case 4:                 // argv[1], argv[2] is x_off, y_off,
            // argv[3] is composite_op
            x_offset = NUM2LONG(argv[1]);
            y_offset = NUM2LONG(argv[2]);
            VALUE_TO_ENUM(argv[3], operator, CompositeOperator);
            break;

        case 5:
            VALUE_TO_ENUM(argv[1], gravity, GravityType);
            x_offset = NUM2LONG(argv[2]);
            y_offset = NUM2LONG(argv[3]);
            VALUE_TO_ENUM(argv[4], operator, CompositeOperator);

            switch (gravity)
            {
                case NorthEastGravity:
                case EastGravity:
                case SouthEastGravity:
                    x_offset = ((long)(image->columns) - (long)(comp_image->columns)) - x_offset;
                    break;
                case NorthGravity:
                case SouthGravity:
                case CenterGravity:
                    x_offset += (long)(image->columns/2) - (long)(comp_image->columns/2);
                    break;
                default:
                    break;
            }
            switch (gravity)
            {
                case SouthWestGravity:
                case SouthGravity:
                case SouthEastGravity:
                    y_offset = ((long)(image->rows) - (long)(comp_image->rows)) - y_offset;
                    break;
                case EastGravity:
                case WestGravity:
                case CenterGravity:
                    y_offset += (long)(image->rows/2) - (long)(comp_image->rows/2);
                    break;
                case NorthEastGravity:
                case NorthGravity:
                default:
                    break;
            }
            break;

    }

    if (bang)
    {
#if defined(IMAGEMAGICK_7)
        exception = AcquireExceptionInfo();
        BEGIN_CHANNEL_MASK(image, channels);
        CompositeImage(image, comp_image, operator, MagickTrue, x_offset, y_offset, exception);
        END_CHANNEL_MASK(image);
        CHECK_EXCEPTION();
        DestroyExceptionInfo(exception);
#else
        CompositeImageChannel(image, channels, operator, comp_image, x_offset, y_offset);
        rm_check_image_exception(image, RetainOnError);
#endif

        return self;
    }
    else
    {
        new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
        exception = AcquireExceptionInfo();
        BEGIN_CHANNEL_MASK(new_image, channels);
        CompositeImage(new_image, comp_image, operator, MagickTrue, x_offset, y_offset, exception);
        END_CHANNEL_MASK(new_image);
        rm_check_exception(exception, new_image, DestroyOnError);
        DestroyExceptionInfo(exception);
#else
        CompositeImageChannel(new_image, channels, operator, comp_image, x_offset, y_offset);
        rm_check_image_exception(new_image, DestroyOnError);
#endif

        return rm_image_new(new_image);
    }
}


/**
 * Composites src onto dest using the specified composite operator.
 * In-place form of {Magick::Image#composite}.
 *
 * @overload composite!(image, x_off, y_off, composite_op)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param x_off [Numeric] the x-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param y_off [Numeric] the y-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *
 * @overload composite!(image, gravity, composite_op)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param gravity [Magick::GravityType] A GravityType value that specifies the location of img on
 *     image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *
 * @overload composite!(image, gravity, x_off, y_off, composite_op)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param gravity [Magick::GravityType] A GravityType value that specifies the location of img on
 *     image.
 *   @param x_off [Numeric] the x-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param y_off [Numeric] the y-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator.
 *
 * @return [Magick::Image] a new image
 * @see Image#composite
 */
VALUE
Image_composite_bang(int argc, VALUE *argv, VALUE self)
{
    return composite(True, argc, argv, self, DefaultChannels);
}


/**
 * Composites src onto dest using the specified composite operator.
 *
 * @overload composite(image, x_off, y_off, composite_op)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param x_off [Numeric] the x-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param y_off [Numeric] the y-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *
 * @overload composite(image, gravity, composite_op)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param gravity [Magick::GravityType] A GravityType value that specifies the location of img on
 *     image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *
 * @overload composite(image, gravity, x_off, y_off, composite_op)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param gravity [Magick::GravityType] A GravityType value that specifies the location of img on
 *     image.
 *   @param x_off [Numeric] the x-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param y_off [Numeric] the y-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator.
 *
 * @return [Magick::Image] a new image
 * @see Image#composite!
 */
VALUE
Image_composite(int argc, VALUE *argv, VALUE self)
{
    return composite(False, argc, argv, self, DefaultChannels);
}


/**
 * Composite the source over the destination image as dictated by the affine transform.
 *
 * @param source [Magick::Image] the source image
 * @param affine_matrix [Magick::AffineMatrix] affine transform matrix
 * @return [Magick::Image] a new image
 */
VALUE
Image_composite_affine(VALUE self, VALUE source, VALUE affine_matrix)
{
    Image *image, *composite_image, *new_image;
    AffineMatrix affine;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    composite_image = rm_check_destroyed(source);

    Export_AffineMatrix(&affine, affine_matrix);
    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    DrawAffineImage(new_image, composite_image, &affine, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    DrawAffineImage(new_image, composite_image, &affine);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Call CompositeImageChannel.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Default channel is AllChannels
 *
 * @param bang whether the bang (!) version of the method was called
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @return self if bang, otherwise a new image
 * @see Image_composite_channel
 * @see Image_composite_channel_bang
 */
static VALUE
composite_channel(int bang, int argc, VALUE *argv, VALUE self)
{
    ChannelType channels;

    // Check destroyed before validating the arguments
    rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);

    // There must be 3, 4, or 5 remaining arguments.
    if (argc < 3)
    {
        rb_raise(rb_eArgError, "composite operator not specified");
    }
    else if (argc > 5)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    return composite(bang, argc, argv, self, channels);
}


/**
 * Composite the source over the destination image channel as dictated by the affine transform.
 *
 * @overload composite_channel(image, x_off, y_off, composite_op, channel = Magick::AllChannels)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param x_off [Numeric] the x-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param y_off [Numeric] the y-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload composite_channel(image, x_off, y_off, composite_op, *channels)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param x_off [Numeric] the x-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param y_off [Numeric] the y-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @overload composite_channel(image, gravity, composite_op, channel = Magick::AllChannels)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param gravity [Magick::GravityType] A GravityType value that specifies the location of img on
 *     image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload composite_channel(image, gravity, composite_op, *channels)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param gravity [Magick::GravityType] A GravityType value that specifies the location of img on
 *     image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @overload composite_channel(image, gravity, x_off, y_off, composite_op, channel = Magick::AllChannels)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param gravity [Magick::GravityType] A GravityType value that specifies the location of img on
 *     image.
 *   @param x_off [Numeric] the x-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param y_off [Numeric] the y-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload composite_channel(image, gravity, x_off, y_off, composite_op, *channels)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param gravity [Magick::GravityType] A GravityType value that specifies the location of img on
 *     image.
 *   @param x_off [Numeric] the x-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param y_off [Numeric] the y-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 * @see Image#composite
 */
VALUE
Image_composite_channel(int argc, VALUE *argv, VALUE self)
{
    return composite_channel(False, argc, argv, self);
}


/**
 * Composite the source over the destination image channel as dictated by the affine transform.
 * In-place form of {Image#composite_channel}.
 *
 * @overload composite_channel!(image, x_off, y_off, composite_op, channel = Magick::AllChannels)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param x_off [Numeric] the x-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param y_off [Numeric] the y-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload composite_channel!(image, x_off, y_off, composite_op, *channels)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param x_off [Numeric] the x-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param y_off [Numeric] the y-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @overload composite_channel!(image, gravity, composite_op, channel = Magick::AllChannels)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param gravity [Magick::GravityType] A GravityType value that specifies the location of img on
 *     image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload composite_channel!(image, gravity, composite_op, *channels)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param gravity [Magick::GravityType] A GravityType value that specifies the location of img on
 *     image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @overload composite_channel!(image, gravity, x_off, y_off, composite_op, channel = Magick::AllChannels)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param gravity [Magick::GravityType] A GravityType value that specifies the location of img on
 *     image.
 *   @param x_off [Numeric] the x-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param y_off [Numeric] the y-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload composite_channel!(image, gravity, x_off, y_off, composite_op, *channels)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param gravity [Magick::GravityType] A GravityType value that specifies the location of img on
 *     image.
 *   @param x_off [Numeric] the x-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param y_off [Numeric] the y-offset of the composited image, measured from the upper-left
 *     corner of the image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 * @see Image#composite_channel
 * @see Image#composite!
 */
VALUE
Image_composite_channel_bang(int argc, VALUE *argv, VALUE self)
{
    return composite_channel(True, argc, argv, self);
}


/**
 * Merge the source and destination images according to the formula
 *   a*Sc*Dc + b*Sc + c*Dc + d
 * where Sc is the source pixel and Dc is the destination pixel.
 *
 * @overload composite_mathematics(image, a, b, c, d, gravity)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param a [Float] See the description.
 *   @param b [Float] See the description.
 *   @param c [Float] See the description.
 *   @param d [Float] See the description.
 *   @param gravity [Magick::GravityType] the gravity type
 *
 * @overload composite_mathematics(image, a, b, c, d, x_off, y_off)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param a [Float] See the description.
 *   @param b [Float] See the description.
 *   @param c [Float] See the description.
 *   @param d [Float] See the description.
 *   @param x_off [Numeric] The x-offset of the composited image, measured relative to the gravity
 *     argument.
 *   @param y_off [Numeric] The y-offset of the composited image, measured relative to the gravity
 *     argument.
 *
 * @overload composite_mathematics(image, a, b, c, d, gravity, x_off, y_off)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param a [Float] See the description.
 *   @param b [Float] See the description.
 *   @param c [Float] See the description.
 *   @param d [Float] See the description.
 *   @param gravity [Magick::GravityType] the gravity type
 *   @param x_off [Numeric] The x-offset of the composited image, measured relative to the gravity
 *     argument.
 *   @param y_off [Numeric] The y-offset of the composited image, measured relative to the gravity
 *     argument.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_composite_mathematics(int argc, VALUE *argv, VALUE self)
{
    Image *composite_image;
    VALUE args[5];
    signed long x_off = 0L;
    signed long y_off = 0L;
    GravityType gravity = NorthWestGravity;
    char compose_args[200];

    rm_check_destroyed(self);

    switch (argc)
    {
        case 8:
            VALUE_TO_ENUM(argv[5], gravity, GravityType);
            x_off = NUM2LONG(argv[6]);
            y_off = NUM2LONG(argv[7]);
            break;
        case 7:
            x_off = NUM2LONG(argv[5]);
            y_off = NUM2LONG(argv[6]);
            break;
        case 6:
            VALUE_TO_ENUM(argv[5], gravity, GravityType);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (got %d, expected 6 to 8)", argc);
            break;
    }

    composite_image = rm_check_destroyed(rm_cur_image(argv[0]));

    snprintf(compose_args, sizeof(compose_args), "%-.16g,%-.16g,%-.16g,%-.16g", NUM2DBL(argv[1]), NUM2DBL(argv[2]), NUM2DBL(argv[3]), NUM2DBL(argv[4]));
    SetImageArtifact(composite_image, "compose:args", compose_args);

    // Call composite(False, gravity, x_off, y_off, MathematicsCompositeOp, DefaultChannels)
    args[0] = argv[0];
    args[1] = GravityType_find(gravity);
    args[2] = LONG2FIX(x_off);
    args[3] = LONG2FIX(y_off);
    args[4] = CompositeOperator_find(MathematicsCompositeOp);

    return composite(False, 5, args, self, DefaultChannels);
}


/**
 * Emulate the -tile option to the composite command.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Default composite_op is Magick::OverCompositeOp
 *   - Default channel is AllChannels
 *
 * @param bang whether the bang (!) version of the method was called
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @return self if bang, otherwise a new image
 * @see Image_composite_tiled
 * @see Image_composite_tiled_bang
 * @see wand/composite.c in ImageMagick (6.2.4)
 */
static VALUE
composite_tiled(int bang, int argc, VALUE *argv, VALUE self)
{
    Image *image;
    Image *comp_image;
    CompositeOperator operator = OverCompositeOp;
    long x, y;
    unsigned long columns;
    ChannelType channels;
    MagickStatusType status;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    // Ensure image and composite_image aren't destroyed.
    if (bang)
    {
        image = rm_check_frozen(self);
    }
    else
    {
        image = rm_check_destroyed(self);
    }

    channels = extract_channels(&argc, argv);

    switch (argc)
    {
        case 2:
            VALUE_TO_ENUM(argv[1], operator, CompositeOperator);
        case 1:
            break;
        case 0:
            rb_raise(rb_eArgError, "wrong number of arguments (0 for 1 or more)");
            break;
        default:
            raise_ChannelType_error(argv[argc-1]);
            break;
    }

    comp_image = rm_check_destroyed(rm_cur_image(argv[0]));

    if (!bang)
    {
        image = rm_clone_image(image);
    }

    SetImageArtifact(comp_image, "modify-outside-overlay", "false");

    status = MagickTrue;
    columns = comp_image->columns;

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
#endif

    // Tile
    for (y = 0; y < (long) image->rows; y += comp_image->rows)
    {
        for (x = 0; status == MagickTrue && x < (long) image->columns; x += columns)
        {
#if defined(IMAGEMAGICK_7)
            BEGIN_CHANNEL_MASK(image, channels);
            status = CompositeImage(image, comp_image, operator, MagickTrue, x, y, exception);
            END_CHANNEL_MASK(image);
            rm_check_exception(exception, image, bang ? RetainOnError: DestroyOnError);
#else
            status = CompositeImageChannel(image, channels, operator, comp_image, x, y);
            rm_check_image_exception(image, bang ? RetainOnError: DestroyOnError);
#endif
        }
    }

#if defined(IMAGEMAGICK_7)
    DestroyExceptionInfo(exception);
#endif

    return bang ? self : rm_image_new(image);
}


/**
 * Composites multiple copies of the source image across and down the image,
 * producing the same results as ImageMagick's composite command with the -tile option.
 *
 * @overload composite_tiled(src, composite_op = Magick::OverCompositeOp, channel = Magick::AllChannels)
 *   @param src [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload composite_tiled(src, composite_op = Magick::OverCompositeOp, *channels)
 *   @param src [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 * @see Image#composite_tiled!
 */
VALUE
Image_composite_tiled(int argc, VALUE *argv, VALUE self)
{
    return composite_tiled(False, argc, argv, self);
}


/**
 * Composites multiple copies of the source image across and down the image, producing the same
 * results as ImageMagick's composite command with the -tile option.
 * In-place form of {Magick::Image#composite_tiled}.
 *
 * @overload composite_tiled!(src, composite_op = Magick::OverCompositeOp, channel = Magick::AllChannels)
 *   @param src [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload composite_tiled!(src, composite_op = Magick::OverCompositeOp, *channels)
 *   @param src [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param composite_op [Magick::CompositeOperator] the composite operator
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 * @see Image#composite_tiled
 */
VALUE
Image_composite_tiled_bang(int argc, VALUE *argv, VALUE self)
{
    return composite_tiled(True, argc, argv, self);
}


/**
 * Get the compression attribute.
 *
 * @return [Magick::CompressionType] the compression
 */
VALUE
Image_compression(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return CompressionType_find(image->compression);
}

/**
 * Set the compression attribute.
 *
 * @param compression [Magick::CompressionType] the compression
 * @return [Magick::CompressionType] the given compression
 */
VALUE
Image_compression_eq(VALUE self, VALUE compression)
{
    Image *image = rm_check_frozen(self);
    VALUE_TO_ENUM(compression, image->compression, CompressionType);
    return compression;
}

/**
 * Removes duplicate or unused entries in the colormap.
 * Only PseudoClass images have a colormap.
 * If the image is DirectClass then compress_colormap! converts it to PseudoClass.
 *
 * @return [Magick::Image] self
 */
VALUE
Image_compress_colormap_bang(VALUE self)
{
    Image *image;
    MagickBooleanType okay;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_frozen(self);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    okay = CompressImageColormap(image, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    okay = CompressImageColormap(image);
    rm_check_image_exception(image, RetainOnError);
#endif
    if (!okay)
    {
        rb_warning("CompressImageColormap failed (probably DirectClass image)");
    }

    return self;
}

/**
 * Creates an Image from the supplied pixel data. The pixel data must be in scanline order,
 * top-to-bottom. The pixel data is an array of either all Fixed or all Float elements. If Fixed,
 * the elements must be in the range [0..QuantumRange]. If Float, the elements must be normalized
 * [0..1]. The "map" argument reflects the expected ordering of the pixel array. It can be any
 * combination or order of R = red, G = green, B = blue, A = alpha, C = cyan, Y = yellow, M =
 * magenta, K = black, or I = intensity (for grayscale).
 *
 * The pixel array must have width X height X strlen(map) elements.
 *
 * @param width_arg [Numeric] The number of columns in the image
 * @param height_arg [Numeric] The number of rows in the image
 * @param map_arg [String] A string describing the expected ordering of the pixel array.
 *   It can be any combination or order of R = red, G = green, B = blue, A = alpha, C = cyan, Y =
 *   yellow, M = magenta, K = black, or I = intensity (for grayscale).
 * @param pixels_arg [Array<Magick::Pixel>] The pixel data in the array must be stored in scanline order,
 *   left-to-right and top-to-bottom. The elements in the array must be either all Integers or all
 *   Floats. If the elements are Integers, the Integers must be in the range [0..QuantumRange]. If
 *   the elements are Floats, they must be in the range [0..1].
 * @return [Magick::Image] a new image
 */
VALUE
Image_constitute(VALUE class ATTRIBUTE_UNUSED, VALUE width_arg, VALUE height_arg,
                 VALUE map_arg, VALUE pixels_arg)
{
    Image *new_image;
    VALUE pixel, pixel0;
    long width, height, x, npixels, map_l;
    char *map;
    volatile union
    {
        double *f;
        Quantum *i;
        void *v;
    } pixels;
    VALUE pixel_class;
    StorageType stg_type;
    ExceptionInfo *exception;

    // rb_Array converts objects that are not Arrays to Arrays if possible,
    // and raises TypeError if it can't.
    pixels_arg = rb_Array(pixels_arg);

    width = NUM2LONG(width_arg);
    height = NUM2LONG(height_arg);

    if (width <= 0 || height <= 0)
    {
        rb_raise(rb_eArgError, "width and height must be greater than zero");
    }

    map = rm_str2cstr(map_arg, &map_l);

    npixels = width * height * map_l;
    if (RARRAY_LEN(pixels_arg) != npixels)
    {
        rb_raise(rb_eArgError, "wrong number of array elements (%ld for %ld)",
                 RARRAY_LEN(pixels_arg), npixels);
    }

    // Inspect the first element in the pixels array to determine the expected
    // type of all the elements. Allocate the pixel buffer.
    pixel0 = rb_ary_entry(pixels_arg, 0);
    if (rb_obj_is_kind_of(pixel0, rb_cFloat) == Qtrue)
    {
        pixels.f = ALLOC_N(double, npixels);
        stg_type = DoublePixel;
        pixel_class = rb_cFloat;
    }
    else if (rb_obj_is_kind_of(pixel0, rb_cInteger) == Qtrue)
    {
        pixels.i = ALLOC_N(Quantum, npixels);
        stg_type = QuantumPixel;
        pixel_class = rb_cInteger;
    }
    else
    {
        rb_raise(rb_eTypeError, "element 0 in pixel array is %s, must be numeric",
                 rb_class2name(CLASS_OF(pixel0)));
    }



    // Convert the array elements to the appropriate C type, store in pixel
    // buffer.
    for (x = 0; x < npixels; x++)
    {
        pixel = rb_ary_entry(pixels_arg, x);
        if (rb_obj_is_kind_of(pixel, pixel_class) != Qtrue)
        {
            xfree(pixels.v);
            rb_raise(rb_eTypeError, "element %ld in pixel array is %s, expected %s",
                     x, rb_class2name(CLASS_OF(pixel)), rb_class2name(CLASS_OF(pixel0)));
        }
        if (pixel_class == rb_cFloat)
        {
            pixels.f[x] = (float) NUM2DBL(pixel);
            if (pixels.f[x] < 0.0 || pixels.f[x] > 1.0)
            {
                xfree(pixels.v);
                rb_raise(rb_eArgError, "element %ld is out of range [0..1]: %f", x, pixels.f[x]);
            }
        }
        else
        {
            pixels.i[x] = NUM2QUANTUM(pixel);
        }
    }

    // This is based on ConstituteImage in IM 5.5.7
    new_image = rm_acquire_image((ImageInfo *) NULL);
    if (!new_image)
    {
        xfree(pixels.v);
        rb_raise(rb_eNoMemError, "not enough memory to continue.");
    }

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    SetImageExtent(new_image, width, height, exception);
#else
    SetImageExtent(new_image, width, height);
    exception = &new_image->exception;
#endif

    if (rm_should_raise_exception(exception, RetainExceptionRetention))
    {
        xfree(pixels.v);
#if defined(IMAGEMAGICK_7)
        DestroyImage(new_image);
        rm_raise_exception(exception);
#else
        rm_check_image_exception(new_image, DestroyOnError);
#endif
    }

#if defined(IMAGEMAGICK_7)
    SetImageBackgroundColor(new_image, exception);
#else
    SetImageBackgroundColor(new_image);
    exception = &new_image->exception;
#endif

    if (rm_should_raise_exception(exception, RetainExceptionRetention))
    {
        xfree(pixels.v);
#if defined(IMAGEMAGICK_7)
        DestroyImage(new_image);
        rm_raise_exception(exception);
#else
        rm_check_image_exception(new_image, DestroyOnError);
#endif
    }

#if defined(IMAGEMAGICK_7)
    ImportImagePixels(new_image, 0, 0, width, height, map, stg_type, (const void *)pixels.v, exception);
    xfree(pixels.v);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    ImportImagePixels(new_image, 0, 0, width, height, map, stg_type, (const void *)pixels.v);
    xfree(pixels.v);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    RB_GC_GUARD(pixel);
    RB_GC_GUARD(pixel0);
    RB_GC_GUARD(pixel_class);

    return rm_image_new(new_image);
}

/**
 * Enhance the intensity differences between the lighter and darker elements of the image.
 *
 * @overload contrast(sharpen = false)
 *   @param sharpen [Boolean] If sharpen is true, the contrast is increased, otherwise it is
 *     reduced.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_contrast(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    unsigned int sharpen = 0;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    if (argc > 1)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
    }
    else if (argc == 1)
    {
        sharpen = RTEST(argv[0]);
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    ContrastImage(new_image, sharpen, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    ContrastImage(new_image, sharpen);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Convert percentages to #pixels. If the white-point (2nd) argument is not
 * supplied set it to #pixels - black-point.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - No return value: modifies black_point and white_point directly.
 *
 * @param image the image
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param black_point pointer to the black point
 * @param white_point pointer to the white point
 */
static void
get_black_white_point(Image *image, int argc, VALUE *argv, double *black_point, double *white_point)
{
    double pixels;

    pixels = (double) (image->columns * image->rows);

    switch (argc)
    {
        case 2:
            if (rm_check_num2dbl(argv[0]))
            {
                *black_point = NUM2DBL(argv[0]);
            }
            else
            {
                *black_point = pixels * rm_str_to_pct(argv[0]);
            }
            if (rm_check_num2dbl(argv[1]))
            {
                *white_point = NUM2DBL(argv[1]);
            }
            else
            {
                *white_point = pixels * rm_str_to_pct(argv[1]);
            }
            break;

        case 1:
            if (rm_check_num2dbl(argv[0]))
            {
                *black_point = NUM2DBL(argv[0]);
            }
            else
            {
                *black_point = pixels * rm_str_to_pct(argv[0]);
            }
            *white_point = pixels - *black_point;
            break;

        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or 2)", argc);
            break;
    }

    return;
}


/**
 * This method is a simple image enhancement technique that attempts to improve the contrast in an
 * image by `stretching' the range of intensity values it contains to span a desired range of
 * values.  It differs from the more sophisticated histogram equalization in that it can only apply
 * a linear scaling function to the image pixel values.
 *
 * @overload contrast_stretch_channel(black_point, white_point = pixels - black_point, channel = Magick::AllChannels)
 *   @param black_point [Float, String] black out at most this many pixels. Specify an absolute
 *     number of pixels as a numeric value, or a percentage as a string in the form 'NN%'.
 *   @param white_point [Float, String] burn at most this many pixels. Specify an absolute number
 *     of pixels as a numeric value, or a percentage as a string in the form 'NN%'. This argument
 *     is optional. If not specified the default is `(columns * rows) - black_point`.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload contrast_stretch_channel(black_point, white_point = pixels - black_point, *channels)
 *   @param black_point [Float, String] black out at most this many pixels. Specify an absolute
 *     number of pixels as a numeric value, or a percentage as a string in the form 'NN%'.
 *   @param white_point [Float, String] burn at most this many pixels. Specify an absolute number of
 *     pixels as a numeric value, or a percentage as a string in the form 'NN%'. This argument is
 *     optional. If not specified the default is all pixels - black_point pixels.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_contrast_stretch_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    ChannelType channels;
    double black_point, white_point;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);
    if (argc > 2)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    get_black_white_point(image, argc, argv, &black_point, &white_point);

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BEGIN_CHANNEL_MASK(new_image, channels);
    ContrastStretchImage(new_image, black_point, white_point, exception);
    END_CHANNEL_MASK(new_image);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    ContrastStretchImageChannel(new_image, channels, black_point, white_point);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}

/**
 * Apply a user supplied kernel to the image according to the given mophology method.
 *
 * @param method_v [Magick::MorphologyMethod] the morphology method
 * @param iterations [Numeric] apply the operation this many times (or no change).
 *   A value of -1 means loop until no change found.
 *   How this is applied may depend on the morphology method.
 *   Typically this is a value of 1.
 * @param kernel_v [Magick::KernelInfo] morphology kernel to apply
 * @return [Magick::Image] a new image
 */

VALUE
Image_morphology(VALUE self, VALUE method_v, VALUE iterations, VALUE kernel_v)
{
    static VALUE default_channels_const = 0;

    if(!default_channels_const)
    {
        default_channels_const = rb_const_get(Module_Magick, rb_intern("DefaultChannels"));
    }

    return Image_morphology_channel(self, default_channels_const, method_v, iterations, kernel_v);
}

/**
 * Apply a user supplied kernel to the image channel according to the given mophology method.
 *
 * @param channel_v [Magick::ChannelType] a channel type
 * @param method_v [Magick::MorphologyMethod] the morphology method
 * @param iterations [Numeric] apply the operation this many times (or no change).
 *   A value of -1 means loop until no change found.
 *   How this is applied may depend on the morphology method.
 *   Typically this is a value of 1.
 * @param kernel_v [Magick::KernelInfo] morphology kernel to apply
 * @return [Magick::Image] a new image
 */

VALUE
Image_morphology_channel(VALUE self, VALUE channel_v, VALUE method_v, VALUE iterations, VALUE kernel_v)
{
    Image *image, *new_image;
    ExceptionInfo *exception;
    MorphologyMethod method;
    ChannelType channel;
    KernelInfo *kernel;

    image = rm_check_destroyed(self);

    VALUE_TO_ENUM(method_v, method, MorphologyMethod);
    VALUE_TO_ENUM(channel_v, channel, ChannelType);
    Check_Type(iterations, T_FIXNUM);

    if (TYPE(kernel_v) == T_STRING)
    {
        kernel_v = rb_class_new_instance(1, &kernel_v, Class_KernelInfo);
    }

    if (!rb_obj_is_kind_of(kernel_v, Class_KernelInfo))
    {
        rb_raise(rb_eArgError, "expected String or Magick::KernelInfo");
    }

    Data_Get_Struct(kernel_v, KernelInfo, kernel);

    exception = AcquireExceptionInfo();

#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channel);
    new_image = MorphologyImage(image, method, NUM2LONG(iterations), kernel, exception);
    CHANGE_RESULT_CHANNEL_MASK(new_image);
    END_CHANNEL_MASK(image);
#else
    new_image = MorphologyImageChannel(image, channel, method, NUM2LONG(iterations), kernel, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}

#if defined(IMAGEMAGICK_7)
// TODO: Move this to KernelInfo class as a constructor?
KernelInfo*
convolve_create_kernel_info(unsigned int order, VALUE kernel_arg)
{
    unsigned int x;
    KernelInfo *kernel;
    ExceptionInfo *exception;

    exception = AcquireExceptionInfo();
    kernel = AcquireKernelInfo((const char *) NULL, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
    if (!kernel)
    {
        rb_raise(rb_eNoMemError, "not enough memory to initialize KernelInfo");
    }

    kernel->width = order;
    kernel->height = order;
    kernel->x = (ssize_t)(order - 1) / 2;
    kernel->y = (ssize_t)(order - 1) / 2;
    kernel->values = (MagickRealType *) AcquireAlignedMemory(order, order*sizeof(*kernel->values));
    if (!kernel->values)
    {
        DestroyKernelInfo(kernel);
        rb_raise(rb_eNoMemError, "not enough memory to initialize KernelInfo values");
    }

    for (x = 0; x < order*order; x++)
    {
        VALUE element = rb_ary_entry(kernel_arg, (long)x);
        if (rm_check_num2dbl(element))
        {
            kernel->values[x] = NUM2DBL(element);
        }
        else
        {
            DestroyKernelInfo(kernel);
            rb_raise(rb_eTypeError, "type mismatch: %s given", rb_class2name(CLASS_OF(element)));
        }
    }

    return kernel;
}
#endif

/**
 * Apply a custom convolution kernel to the image.
 *
 * @param order_arg [Numeric] the number of rows and columns in the kernel
 * @param kernel_arg [Array<Float>] An `order*order` matrix of {Float} values.
 * @return [Magick::Image] a new image
 */
VALUE
Image_convolve(VALUE self, VALUE order_arg, VALUE kernel_arg)
{
    Image *image, *new_image;
    int order;
    ExceptionInfo *exception;
#if defined(IMAGEMAGICK_7)
    KernelInfo *kernel;
#else
    double *kernel;
    unsigned int x;
#endif

    image = rm_check_destroyed(self);

    order = NUM2INT(order_arg);

    if (order <= 0)
    {
        rb_raise(rb_eArgError, "order must be non-zero and positive");
    }

    kernel_arg = rb_Array(kernel_arg);
    rm_check_ary_len(kernel_arg, (long)(order*order));

#if defined(IMAGEMAGICK_7)
    kernel = convolve_create_kernel_info(order, kernel_arg);
#else
    // Convert the kernel array argument to an array of doubles

    kernel = (double *)ALLOC_N(double, order*order);
    for (x = 0; x < (unsigned)(order * order); x++)
    {
        VALUE element = rb_ary_entry(kernel_arg, (long)x);
        if (rm_check_num2dbl(element))
        {
            kernel[x] = NUM2DBL(element);
        }
        else
        {
            xfree((void *)kernel);
            rb_raise(rb_eTypeError, "type mismatch: %s given", rb_class2name(CLASS_OF(element)));
        }
    }
#endif

    exception = AcquireExceptionInfo();

#if defined(IMAGEMAGICK_7)
    new_image = ConvolveImage(image, kernel, exception);
    DestroyKernelInfo(kernel);
#else
    new_image = ConvolveImage(image, order, kernel, exception);
    xfree((void *)kernel);
#endif

    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Applies a custom convolution kernel to the specified channel or channels in the image.
 *
 * @overload convolve_channel(order, kernel, channel = Magick::AllChannels)
 *   @param order_arg [Numeric] the number of rows and columns in the kernel
 *   @param kernel_arg [Array<Float>] An `order*order` matrix of {Float} values.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload convolve_channel(order, kernel, *channels)
 *   @param order_arg [Numeric] the number of rows and columns in the kernel
 *   @param kernel_arg [Array<Float>] An `order*order` matrix of {Float} values.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_convolve_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    VALUE ary;
    int order;
    ChannelType channels;
    ExceptionInfo *exception;
#if defined(IMAGEMAGICK_7)
    KernelInfo *kernel;
#else
    double *kernel;
    unsigned int x;
#endif

    image = rm_check_destroyed(self);

    channels = extract_channels(&argc, argv);

    // There are 2 required arguments.
    if (argc > 2)
    {
        raise_ChannelType_error(argv[argc-1]);
    }
    if (argc != 2)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 or more)", argc);
    }

    order = NUM2INT(argv[0]);
    if (order <= 0)
    {
        rb_raise(rb_eArgError, "order must be non-zero and positive");
    }

    ary = rb_Array(argv[1]);
    rm_check_ary_len(ary, (long)(order*order));

#if defined(IMAGEMAGICK_7)
    kernel = convolve_create_kernel_info(order, ary);
#else
    kernel = ALLOC_N(double, (long)(order*order));

    // Convert the kernel array argument to an array of doubles
    for (x = 0; x < (unsigned)(order * order); x++)
    {
        VALUE element = rb_ary_entry(ary, (long)x);
        if (rm_check_num2dbl(element))
        {
            kernel[x] = NUM2DBL(element);
        }
        else
        {
            xfree((void *)kernel);
            rb_raise(rb_eTypeError, "type mismatch: %s given", rb_class2name(CLASS_OF(element)));
        }
    }
#endif

    exception = AcquireExceptionInfo();

#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    new_image = ConvolveImage(image, kernel, exception);
    CHANGE_RESULT_CHANNEL_MASK(new_image);
    END_CHANNEL_MASK(image);
    DestroyKernelInfo(kernel);
#else
    new_image = ConvolveImageChannel(image, channels, order, kernel, exception);
    xfree((void *)kernel);
#endif

    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    RB_GC_GUARD(ary);

    return rm_image_new(new_image);
}



/**
 * Alias for {Magick::Image#dup}.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_copy(VALUE self)
{
    return rb_funcall(self, rm_ID_dup, 0);
}

/**
 * Initialize copy, clone, dup.
 *
 * @param orig [Magick::Image] the source image
 * @return [Magick::Image] self
 * @see Image#copy
 * @see Image#clone
 * @see Image#dup
 */
VALUE
Image_init_copy(VALUE copy, VALUE orig)
{
    Image *image, *new_image;

    image = rm_check_destroyed(orig);
    new_image = rm_clone_image(image);
    UPDATE_DATA_PTR(copy, new_image);

    return copy;
}


/**
 * Extract a region of the image defined by width, height, x, y.
 *
 * @overload crop(x, y, width, height, reset = false)
 *   @param x [Numeric] x position of start of region
 *   @param y [Numeric] y position of start of region
 *   @param width [Numeric] width of region
 *   @param height [Numeric] height of region
 *   @param reset [Boolean] true if reset the cropped image page canvas and position
 *
 * @overload crop(gravity, width, height, reset = false)
 *   @param gravity [Magick::GravityType] the gravity type
 *   @param width [Numeric] width of region
 *   @param height [Numeric] height of region
 *   @param reset [Boolean] true if reset the cropped image page canvas and position

 * @overload crop(gravity, x, y, width, height, reset = false)
 *   @param gravity [Magick::GravityType] the gravity type
 *   @param x [Numeric] x position of start of region
 *   @param y [Numeric] y position of start of region
 *   @param width [Numeric] width of region
 *   @param height [Numeric] height of region
 *   @param reset [Boolean] true if reset the cropped image page canvas and position
 *
 * @return [Magick::Image] a new image
 * @see Image#crop!
 */
VALUE
Image_crop(int argc, VALUE *argv, VALUE self)
{
    rm_check_destroyed(self);
    return cropper(False, argc, argv, self);
}


/**
 * Extract a region of the image defined by width, height, x, y.
 * In-place form of {Image#crop}.
 *
 * @overload crop!(reset = false, x, y, width, height)
 *   @param reset [Boolean] true if reset the cropped image page canvas and position
 *   @param x [Numeric] x position of start of region
 *   @param y [Numeric] y position of start of region
 *   @param width [Numeric] width of region
 *   @param height [Numeric] height of region
 *
 * @overload crop!(reset = false, gravity, width, height)
 *   @param reset [Boolean] true if reset the cropped image page canvas and position
 *   @param gravity [Magick::GravityType] the gravity type
 *   @param width [Numeric] width of region
 *   @param height [Numeric] height of region

 * @overload crop!(reset = false, gravity, x, y, width, height)
 *   @param reset [Boolean] true if reset the cropped image page canvas and position
 *   @param gravity [Magick::GravityType] the gravity type
 *   @param x [Numeric] x position of start of region
 *   @param y [Numeric] y position of start of region
 *   @param width [Numeric] width of region
 *   @param height [Numeric] height of region
 *
 * @return [Magick::Image] a new image
 * @see Image#crop!
 */
VALUE
Image_crop_bang(int argc, VALUE *argv, VALUE self)
{
    rm_check_frozen(self);
    return cropper(True, argc, argv, self);
}


/**
 * Displaces the colormap by a given number of positions.
 * If you cycle the colormap a number of times you can produce a psychedelic effect.
 *
 * The returned image is always a PseudoClass image, regardless of the type of the original image.
 *
 * @param amount [Numeric] amount to cycle the colormap
 * @return [Magick::Image] a new image
 */
VALUE
Image_cycle_colormap(VALUE self, VALUE amount)
{
    Image *image, *new_image;
    int amt;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    amt = NUM2INT(amount);

    image = rm_check_destroyed(self);
    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    CycleColormapImage(new_image, amt, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    CycleColormapImage(new_image, amt);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Get the vertical and horizontal resolution in pixels of the image.
 * The default is "72x72".
 *
 * @return [String] a string of geometry in the form "XresxYres"
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Image_density(VALUE self)
{
    Image *image;
    char density[128];

    image = rm_check_destroyed(self);

#if defined(IMAGEMAGICK_7)
    snprintf(density, sizeof(density), "%gx%g", image->resolution.x, image->resolution.y);
#else
    snprintf(density, sizeof(density), "%gx%g", image->x_resolution, image->y_resolution);
#endif
    return rb_str_new2(density);
}


/**
 * Set the vertical and horizontal resolution in pixels of the image.
 *
 * - The density is a string of the form "XresxYres" or simply "Xres".
 * - If the y resolution is not specified, set it equal to the x resolution.
 * - This is equivalent to PerlMagick's handling of density.
 * - The density can also be a Geometry object. The width attribute is used for the x
 *   resolution. The height attribute is used for the y resolution.  If the height attribute is
 *   missing, the width attribute is used for both.
 *
 * @param density_arg [String, Magick::Geometry] The density String or Geometry
 * @return [String, Magick::Geometry] the given value
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Image_density_eq(VALUE self, VALUE density_arg)
{
    Image *image;
    char *density;
    VALUE x_val, y_val;
    int count;
    double x_res, y_res;

    image = rm_check_frozen(self);

    // Get the Class ID for the Geometry class.
    if (!Class_Geometry)
    {
        Class_Geometry = rb_const_get(Module_Magick, rm_ID_Geometry);
    }

    // Geometry object. Width and height attributes are always positive.
    if (CLASS_OF(density_arg) == Class_Geometry)
    {
        x_val = rb_funcall(density_arg, rm_ID_width, 0);
        x_res = NUM2DBL(x_val);
        y_val = rb_funcall(density_arg, rm_ID_height, 0);
        y_res = NUM2DBL(y_val);
        if (x_res == 0.0)
        {
            rb_raise(rb_eArgError, "invalid x resolution: %f", x_res);
        }
#if defined(IMAGEMAGICK_7)
        image->resolution.y = y_res != 0.0 ? y_res : x_res;
        image->resolution.x = x_res;
#else
        image->y_resolution = y_res != 0.0 ? y_res : x_res;
        image->x_resolution = x_res;
#endif
    }

    // Convert the argument to a string
    else
    {
        density = StringValueCStr(density_arg);
        if (!IsGeometry(density))
        {
            rb_raise(rb_eArgError, "invalid density geometry %s", density);
        }

#if defined(IMAGEMAGICK_7)
        count = sscanf(density, "%lfx%lf", &image->resolution.x, &image->resolution.y);
#else
        count = sscanf(density, "%lfx%lf", &image->x_resolution, &image->y_resolution);
#endif
        if (count < 2)
        {
#if defined(IMAGEMAGICK_7)
            image->resolution.y = image->resolution.x;
#else
            image->y_resolution = image->x_resolution;
#endif
        }

    }

    RB_GC_GUARD(x_val);
    RB_GC_GUARD(y_val);

    return density_arg;
}


/**
 * Decipher an enciphered image.
 *
 * @param passphrase [String] The passphrase used to encipher the image.
 * @return [Magick::Image] a new deciphered image
 */
VALUE
Image_decipher(VALUE self, VALUE passphrase)
{
    Image *image, *new_image;
    char *pf;
    ExceptionInfo *exception;
    MagickBooleanType okay;

    image = rm_check_destroyed(self);
    pf = StringValueCStr(passphrase);      // ensure passphrase is a string
    exception = AcquireExceptionInfo();

    new_image = rm_clone_image(image);

    okay = DecipherImage(new_image, pf, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    if (!okay)
    {
        DestroyImage(new_image);
        rb_raise(rb_eRuntimeError, "DecipherImage failed for unknown reason.");
    }

    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Associates makes a copy of the given string arguments and
 * inserts it into the artifact tree.
 *
 * - Normally a script should never call this method. Any calls to
 *   SetImageArtifact will be part of the methods in which they're needed, or
 *   be called via the OptionalMethodArguments class.
 * - If value is nil, the artifact will be removed
 *
 * @param artifact [String] the artifact to set
 * @param value [String] the value to which to set the artifact
 * @return [String] the given `value`
 */
VALUE
Image_define(VALUE self, VALUE artifact, VALUE value)
{
    Image *image;
    char *key, *val;
    MagickBooleanType status;

    image = rm_check_frozen(self);
    artifact = rb_String(artifact);
    key = StringValueCStr(artifact);

    if (value == Qnil)
    {
        DeleteImageArtifact(image, key);
    }
    else
    {
        value = rb_String(value);
        val = StringValueCStr(value);
        status = SetImageArtifact(image, key, val);
        if (!status)
        {
            rb_raise(rb_eNoMemError, "not enough memory to continue");
        }
    }

    return value;
}


/**
 * Get the Number of ticks which must expire before displaying the next image in an animated
 * sequence. The default number of ticks is 0. By default there are 100 ticks per second but this
 * number can be changed via the ticks_per_second attribute.
 *
 * @return [Numeric] The current delay value.
 */
VALUE
Image_delay(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, delay, ulong);
}

/**
 * Set the Number of ticks which must expire before displaying the next image in an animated
 * sequence.
 *
 * @param val [Numeric] the delay value
 * @return [Numeric] the given value
 */
VALUE
Image_delay_eq(VALUE self, VALUE val)
{
    IMPLEMENT_ATTR_WRITER(Image, delay, ulong);
}


/**
 * Delete the image composite mask.
 *
 * @return [Magick::Image] self
 * @see Image#add_compose_mask
 */
VALUE
Image_delete_compose_mask(VALUE self)
{
    Image *image;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_frozen(self);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    SetImageMask(image, CompositePixelMask, NULL, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    SetImageMask(image, NULL);
    rm_check_image_exception(image, RetainOnError);
#endif

    return self;
}


/**
 * Deletes the specified profile.
 *
 * @param name [String] The profile name, "IPTC" or "ICC" for example.
 *   Specify "*" to delete all the profiles in the image.
 * @return [Magick::Image] self
 * @see Image#add_profile
 */
VALUE
Image_delete_profile(VALUE self, VALUE name)
{
    Image *image = rm_check_frozen(self);
    DeleteImageProfile(image, StringValueCStr(name));

    return self;
}


/**
 * Return the image depth (8, 16 or 32).
 *
 * - If all pixels have lower-order bytes equal to higher-order bytes, the depth will be reported as
 *   8 even if the depth field in the Image structure says 16.
 *
 * @return [Numeric] the depth
 */
VALUE
Image_depth(VALUE self)
{
    Image *image;
    unsigned long depth = 0;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    exception = AcquireExceptionInfo();

    depth = GetImageDepth(image, exception);
    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    return INT2FIX(depth);
}


/**
 * Straightens an image. A threshold of 40% works for most images.
 *
 * @overload deskew(threshold = 0.40, auto_crop_width = nil)
 *   @param threshold [Float] A percentage of QuantumRange. Either a Float between 0 and 1.0,
 *     inclusive, or a string in the form "NN%" where NN is between 0 and 100.
 *   @param auto_crop_width [Float] Specify a value for this argument to cause the deskewed image to
 *     be auto-cropped. The argument is the pixel width of the image background (e.g. 40).
 *   @return [Magick::Image] a new image
 */
VALUE
Image_deskew(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double threshold = 40.0 * QuantumRange / 100.0;
    unsigned long width;
    char auto_crop_width[20];
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 2:
            width = NUM2ULONG(argv[1]);
            memset(auto_crop_width, 0, sizeof(auto_crop_width));
            snprintf(auto_crop_width, sizeof(auto_crop_width), "%lu", width);
            SetImageArtifact(image, "deskew:auto-crop", auto_crop_width);
        case 1:
            threshold = rm_percentage(argv[0], 1.0) * QuantumRange;
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or 2)", argc);
            break;
    }

    exception = AcquireExceptionInfo();
    new_image = DeskewImage(image, threshold, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Reduce the speckle noise in an image while preserving the edges of the original image.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_despeckle(VALUE self)
{
    Image *image, *new_image;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    exception = AcquireExceptionInfo();

    new_image = DespeckleImage(image, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Free all the memory associated with an image.
 *
 * @return [Magick::Image] self
 */
VALUE
Image_destroy_bang(VALUE self)
{
    Image *image;

    rb_check_frozen(self);
    Data_Get_Struct(self, Image, image);
    rm_image_destroy(image);
    DATA_PTR(self) = NULL;
    return self;
}


/**
 * Return true if the image has been destroyed, false otherwise.
 *
 * @return [Boolean] true if destroyed, false otherwise
 */
VALUE
Image_destroyed_q(VALUE self)
{
    Image *image;

    Data_Get_Struct(self, Image, image);
    return image ? Qfalse : Qtrue;
}


/**
 * Compares two images and computes statistics about their difference.
 *
 * @param other [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an imagelist,
 *   uses the current image.
 * @return [Array<Float>] An array of three {Float} values:
 *   - mean error per pixel
 *     - The mean error for any single pixel in the image.
 *   - normalized mean error
 *     - The normalized mean quantization error for any single pixel in the image. This distance measure
 *       is normalized to a range between 0 and 1. It is independent of the range of red, green, and
 *       blue values in the image.
 *   - normalized maximum error
 *     - The normalized maximum quantization error for any single pixel in the image. This distance
 *       measure is normalized to a range between 0 and 1. It is independent of the range of red,
 *       green, and blue values in your image.
 */
VALUE
Image_difference(VALUE self, VALUE other)
{
    Image *image;
    Image *image2;
    VALUE mean, nmean, nmax;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    other = rm_cur_image(other);
    image2 = rm_check_destroyed(other);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    IsImagesEqual(image, image2, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    IsImagesEqual(image, image2);
    rm_check_image_exception(image, RetainOnError);
#endif

    mean  = rb_float_new(image->error.mean_error_per_pixel);
    nmean = rb_float_new(image->error.normalized_mean_error);
    nmax  = rb_float_new(image->error.normalized_maximum_error);

    RB_GC_GUARD(mean);
    RB_GC_GUARD(nmean);
    RB_GC_GUARD(nmax);

    return rb_ary_new3(3, mean, nmean, nmax);
}


/**
 * Get image directory.
 *
 * @return [String] the directory
 */
VALUE
Image_directory(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, directory, str);
}


/**
 * Uses displacement_map to move color from img to the output image.
 * This method corresponds to the -displace option of ImageMagick's composite command.
 *
 * @overload displace(displacement_map, x_amp, y_amp = x_amp, gravity = Magick::NorthWestGravity, x_offset = 0, y_offset = 0)
 *   @param displacement_map [Magick::Image, Magick::ImageList] The source image for the composite
 *     operation. Either an imagelist or an image. If an imagelist, uses the current image.
 *   @param x_amp [Float] The maximum displacement on the x-axis.
 *   @param y_amp [Float] The maximum displacement on the y-axis.
 *   @param gravity [Magick::GravityType] the gravity for offset. the offsets are measured from the
 *   NorthWest corner by default.
 *   @param x_offset [Numeric] The offset that measured from the left-hand side of the target image.
 *   @param y_offset [Numeric] The offset that measured from the top of the target image.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_displace(int argc, VALUE *argv, VALUE self)
{
    Image *image, *displacement_map;
    VALUE dmap;
    double x_amplitude = 0.0, y_amplitude = 0.0;
    long x_offset = 0L, y_offset = 0L;

    image = rm_check_destroyed(self);

    if (argc < 2)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 to 6)", argc);
    }

    dmap = rm_cur_image(argv[0]);
    displacement_map = rm_check_destroyed(dmap);

    if (argc > 3)
    {
        get_composite_offsets(argc-3, &argv[3], image, displacement_map, &x_offset, &y_offset);
        // There must be 3 arguments left
        argc = 3;
    }

    switch (argc)
    {
        case 3:
            y_amplitude = NUM2DBL(argv[2]);
            x_amplitude = NUM2DBL(argv[1]);
            break;
        case 2:
            x_amplitude = NUM2DBL(argv[1]);
            y_amplitude = x_amplitude;
            break;
    }

    RB_GC_GUARD(dmap);

    return special_composite(image, displacement_map, x_amplitude, y_amplitude,
                             x_offset, y_offset, DisplaceCompositeOp);
}


/**
 * Extract pixel data from the image and returns it as an array of pixels. The "x", "y", "width" and
 * "height" parameters specify the rectangle to be extracted. The "map" parameter reflects the
 * expected ordering of the pixel array. It can be any combination or order of R = red, G = green,
 * B = blue, A = alpha, C = cyan, Y = yellow, M = magenta, K = black, or I = intensity (for
 * grayscale). If the "float" parameter is specified and true, the pixel data is returned as
 * floating-point numbers in the range [0..1]. By default the pixel data is returned as integers in
 * the range [0..QuantumRange].
 *
 * @overload dispatch(x, y, columns, rows, map, float = false)
 *   @param x [Numeric] The offset of the rectangle from the upper-left corner of the image.
 *   @param y [Numeric] The offset of the rectangle from the upper-left corner of the image.
 *   @param columns [Numeric] The width of the rectangle.
 *   @param rows [Numeric] The height of the rectangle.
 *   @param map [String]
 *   @param float [Boolean]
 *   @return [Array<Numeric>] an Array of pixel data
 */
VALUE
Image_dispatch(int argc, VALUE *argv, VALUE self)
{
    Image *image;
    long x, y;
    unsigned long columns, rows, n, npixels;
    VALUE pixels_ary;
    StorageType stg_type = QuantumPixel;
    char *map;
    long mapL;
    MagickBooleanType okay;
    ExceptionInfo *exception;
    volatile union
    {
        Quantum *i;
        double *f;
        void *v;
    } pixels;

    rm_check_destroyed(self);

    if (argc < 5 || argc > 6)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 5 or 6)", argc);
    }

    x       = NUM2LONG(argv[0]);
    y       = NUM2LONG(argv[1]);
    columns = NUM2ULONG(argv[2]);
    rows    = NUM2ULONG(argv[3]);
    map     = rm_str2cstr(argv[4], &mapL);
    if (argc == 6)
    {
        stg_type = RTEST(argv[5]) ? DoublePixel : QuantumPixel;
    }

    // Compute the size of the pixel array and allocate the memory.
    npixels = columns * rows * mapL;
    pixels.v = stg_type == QuantumPixel ? (void *) ALLOC_N(Quantum, npixels)
               : (void *) ALLOC_N(double, npixels);

    // Create the Ruby array for the pixels. Return this even if ExportImagePixels fails.
    pixels_ary = rb_ary_new();

    Data_Get_Struct(self, Image, image);

    exception = AcquireExceptionInfo();
    okay = ExportImagePixels(image, x, y, columns, rows, map, stg_type, (void *)pixels.v, exception);

    if (!okay)
    {
        goto exit;
    }

    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    // Convert the pixel data to the appropriate Ruby type
    if (stg_type == QuantumPixel)
    {
        for (n = 0; n < npixels; n++)
        {
            rb_ary_push(pixels_ary, QUANTUM2NUM(pixels.i[n]));
        }
    }
    else
    {
        for (n = 0; n < npixels; n++)
        {
            rb_ary_push(pixels_ary, rb_float_new(pixels.f[n]));
        }
    }

    exit:
    xfree((void *)pixels.v);

    RB_GC_GUARD(pixels_ary);

    return pixels_ary;
}


/**
 * Display the image to an X window screen.
 *
 * @return [Magick::Image] self
 */
VALUE
Image_display(VALUE self)
{
    Image *image;
    Info *info;
    VALUE info_obj;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

    if (image->rows == 0 || image->columns == 0)
    {
        rb_raise(rb_eArgError, "invalid image geometry (%"RMIuSIZE"x%"RMIuSIZE")", image->rows, image->columns);
    }

    info_obj = rm_info_new();
    Data_Get_Struct(info_obj, Info, info);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    DisplayImages(info, image, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    DisplayImages(info, image);
    rm_check_image_exception(image, RetainOnError);
#endif

    RB_GC_GUARD(info_obj);

    return self;
}


/**
 * Return the dispose attribute as a DisposeType enum.
 *
 * @return [Magick::DisposeType] the dispose
 */
VALUE
Image_dispose(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return DisposeType_find(image->dispose);
}


/**
 * Set the dispose attribute.
 *
 * @param dispose [Magick::DisposeType] the dispose
 * @return [Magick::DisposeType] the given dispose
 */
VALUE
Image_dispose_eq(VALUE self, VALUE dispose)
{
    Image *image = rm_check_frozen(self);
    VALUE_TO_ENUM(dispose, image->dispose, DisposeType);
    return dispose;
}


/**
 * Composites the overlay image into the target image.
 * The opacity of img is multiplied by dst_percentage and opacity of overlay is multiplied by
 * src_percentage.
 *
 * This method corresponds to the -dissolve option of ImageMagick's composite command.
 *
 * @overload dissolve(overlay, src_percent, dst_percent = -1.0, gravity = Magick::NorthWestGravity, x_offset = 0, y_offset = 0)
 *   @param overlay [Magick::Image, Magick::ImageList] The source image for the composite operation.
 *     Either an imagelist or an image. If an imagelist, uses the current image.
 *   @param src_percent [Float, String] Either a non-negative number a string in the form "NN%".
 *     If src_percentage is a number it is interpreted as a percentage.
 *     Both 0.25 and "25%" mean 25%. This argument is required.
 *   @param dst_percent [Float, String] Either a non-negative number a string in the form "NN%".
 *     If src_percentage is a number it is interpreted as a percentage.
 *     Both 0.25 and "25%" mean 25%. This argument may omitted if no other arguments follow it.
 *     In this case the default is 100%-src_percentage.
 *   @param gravity [Magick::GravityType] the gravity for offset. the offsets are measured from the
 *     NorthWest corner by default.
 *   @param x_offset [Numeric] The offset that measured from the left-hand side of the target image.
 *   @param y_offset [Numeric] The offset that measured from the top of the target image.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_dissolve(int argc, VALUE *argv, VALUE self)
{
    Image *image, *overlay;
    double src_percent, dst_percent = -1.0;
    long x_offset = 0L, y_offset = 0L;
    VALUE composite_image, ovly;

    image = rm_check_destroyed(self);

    if (argc < 1)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 to 6)", argc);
    }

    ovly = rm_cur_image(argv[0]);
    overlay = rm_check_destroyed(ovly);

    if (argc > 3)
    {
        get_composite_offsets(argc-3, &argv[3], image, overlay, &x_offset, &y_offset);
        // There must be 3 arguments left
        argc = 3;
    }

    switch (argc)
    {
        case 3:
            dst_percent = rm_percentage(argv[2], 1.0) * 100.0;
        case 2:
            src_percent = rm_percentage(argv[1], 1.0) * 100.0;
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 to 6)", argc);
            break;
    }

    composite_image =  special_composite(image, overlay, src_percent, dst_percent,
                                         x_offset, y_offset, DissolveCompositeOp);

    RB_GC_GUARD(composite_image);
    RB_GC_GUARD(ovly);

    return composite_image;
}


/**
 * Distort an image using the specified distortion type and its required arguments.
 * This method is equivalent to ImageMagick's -distort option.
 *
 * @overload distort(type, points, bestfit = false)
 *   @param type [Magick::DistortMethod] a DistortMethod value
 *   @param points [Array<Numeric>] an Array of Numeric values. The size of the array depends on the
 *     distortion type.
 *   @param bestfit [Boolean] If bestfit is enabled, and the distortion allows it, the destination
 *     image is adjusted to ensure the whole source image will just fit within the final destination
 *     image, which will be sized and offset accordingly.  Also in many cases the virtual offset of
 *     the source image will be taken into account in the mapping.
 *
 * @overload distort(type, points, bestfit = false)
 *   When a block is given, distort yields with a block argument you can optionally use to set attributes.
 *   - options.define("distort:viewport", "WxH+X+Y")
 *     - Specify the size and offset of the generated viewport image of the distorted image space. W and
 *       H are the width and height, and X and Y are the offset.
 *   - options.define("distort:scale", N)
 *     - N is an integer factor. Scale the output image (viewport or otherwise) by that factor without
 *       changing the viewed contents of the distorted image. This can be used either for
 *       'super-sampling' the image for a higher quality result, or for panning and zooming around
 *       the image (with appropriate viewport changes, or post-distort cropping and resizing).
 *   - options.verbose(true)
 *     - Attempt to output the internal coefficients, and the -fx equivalent to the distortion, for
         expert study, and debugging purposes. This many not be available for all distorts.
 *   @param type [Magick::DistortMethod] a DistortMethod value
 *   @param points [Array<Numeric>] an Array of Numeric values. The size of the array depends on the distortion type.
 *   @param bestfit [Boolean] If bestfit is enabled, and the distortion allows it, the destination
 *     image is adjusted to ensure the whole source image will just fit within the final destination
 *     image, which will be sized and offset accordingly.  Also in many cases the virtual offset of
 *     the source image will be taken into account in the mapping.
 *   @yield [Magick::OptionalMethodArguments]
 *
 * @return [Magick::Image] a new image
 * @example
 *   img.distort(Magick::ScaleRotateTranslateDistortion, [0]) do |options|
 *     options.define "distort:viewport", "44x44+15+0"
 *     options.define "distort:scale", 2
 *   end
 */
VALUE
Image_distort(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    VALUE pts;
    unsigned long n, npoints;
    DistortMethod distortion_method;
    double *points;
    MagickBooleanType bestfit = MagickFalse;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    rm_get_optional_arguments(self);

    switch (argc)
    {
        case 3:
            bestfit = RTEST(argv[2]);
        case 2:
            // Ensure pts is an array
            pts = rb_Array(argv[1]);
            VALUE_TO_ENUM(argv[0], distortion_method, DistortMethod);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (expected 2 or 3, got %d)", argc);
            break;
    }

    npoints = RARRAY_LEN(pts);
    points = ALLOC_N(double, npoints);

    for (n = 0; n < npoints; n++)
    {
        VALUE element = rb_ary_entry(pts, n);
        if (rm_check_num2dbl(element))
        {
            points[n] = NUM2DBL(element);
        }
        else
        {
            xfree(points);
            rb_raise(rb_eTypeError, "type mismatch: %s given", rb_class2name(CLASS_OF(element)));
        }
    }

    exception = AcquireExceptionInfo();
    new_image = DistortImage(image, distortion_method, npoints, points, bestfit, exception);
    xfree(points);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    RB_GC_GUARD(pts);

    return rm_image_new(new_image);
}


/**
 * Compares one or more image channels of an image to a reconstructed image and returns the
 * specified distortion metric.
 *
 * @overload distortion_channel(reconstructed_image, metric, channel = Magick::AllChannels)
 *   @param reconstructed_image [Magick::Image, Magick::ImageList] Either an imagelist or an
 *     image. If an imagelist, uses the current image.
 *   @param metric [Magick::MetricType] The desired distortion metric.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload distortion_channel(reconstructed_image, metric, *channels)
 *   @param reconstructed_image [Magick::Image, Magick::ImageList] Either an imagelist or an
 *     image. If an imagelist, uses the current image.
 *   @param metric [Magick::MetricType] The desired distortion metric.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Float] the image channel distortion
 */
VALUE
Image_distortion_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *reconstruct;
    ChannelType channels;
    ExceptionInfo *exception;
    MetricType metric;
    VALUE rec;
    double distortion;
#if defined(IMAGEMAGICK_7)
    Image *difference_image;
#endif

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);
    if (argc > 2)
    {
        raise_ChannelType_error(argv[argc-1]);
    }
    if (argc < 2)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 or more)", argc);
    }

    rec = rm_cur_image(argv[0]);
    reconstruct = rm_check_destroyed(rec);
    VALUE_TO_ENUM(argv[1], metric, MetricType);
    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    difference_image = CompareImages(image, reconstruct, metric, &distortion, exception);
    END_CHANNEL_MASK(image);
    DestroyImage(difference_image);
#else
    GetImageChannelDistortion(image, reconstruct, channels, metric, &distortion, exception);
#endif

    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    RB_GC_GUARD(rec);

    return rb_float_new(distortion);
}


/**
 * Implement marshalling.
 *
 * @param depth [Object] unused
 * @return [String] a string representing the dumped image
 */
VALUE
Image__dump(VALUE self, VALUE depth ATTRIBUTE_UNUSED)
{
    Image *image;
    ImageInfo *info;
    void *blob;
    size_t length;
    DumpedImage mi;
    VALUE str;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    info = CloneImageInfo(NULL);
    if (!info)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }
    strlcpy(info->magick, image->magick, sizeof(info->magick));

    exception = AcquireExceptionInfo();
    blob = ImageToBlob(info, image, &length, exception);

    // Free ImageInfo first - error handling may raise an exception
    DestroyImageInfo(info);

    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    if (!blob)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }

    // Create a header for the blob: ID and version
    // numbers, followed by the length of the magick
    // string stored as a byte, followed by the
    // magick string itself.
    mi.id = DUMPED_IMAGE_ID;
    mi.mj = DUMPED_IMAGE_MAJOR_VERS;
    mi.mi = DUMPED_IMAGE_MINOR_VERS;
    strlcpy(mi.magick, image->magick, sizeof(mi.magick));
    mi.len = (unsigned char) min((size_t)UCHAR_MAX, rm_strnlen_s(mi.magick, sizeof(mi.magick)));

    // Concatenate the blob onto the header & return the result
    str = rb_str_new((char *)&mi, (long)(mi.len+offsetof(DumpedImage, magick)));
    str = rb_str_buf_cat(str, (char *)blob, (long)length);
    magick_free((void*)blob);

    RB_GC_GUARD(str);

    return str;
}


/**
 * Duplicates a image.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_dup(VALUE self)
{
    VALUE dup;

    rm_check_destroyed(self);
    dup = Data_Wrap_Struct(CLASS_OF(self), NULL, rm_image_destroy, NULL);
    RB_GC_GUARD(dup);

    return rb_funcall(dup, rm_ID_initialize_copy, 1, self);
}


/**
 * Calls block once for each profile in the image, passing the profile name and value as parameters.
 *
 * @yield [name, val]
 * @yieldparam name [String] the profile name
 * @yieldparam val [String] the profile value
 * @return [Object] the last value returned by the block
 */
VALUE
Image_each_profile(VALUE self)
{
    Image *image;
    VALUE ary;
    VALUE val = Qnil;
    char *name;
    const StringInfo *profile;

    image = rm_check_destroyed(self);
    ResetImageProfileIterator(image);

    ary = rb_ary_new2(2);

    name = GetNextImageProfile(image);
    while (name)
    {
        rb_ary_store(ary, 0, rb_str_new2(name));

        profile = GetImageProfile(image, name);
        if (!profile)
        {
            rb_ary_store(ary, 1, Qnil);
        }
        else
        {
            rb_ary_store(ary, 1, rb_str_new((char *)profile->datum, (long)profile->length));
        }
        val = rb_yield(ary);
        name = GetNextImageProfile(image);
    }

    RB_GC_GUARD(ary);
    RB_GC_GUARD(val);

    return val;
}


/**
 * Find edges in an image. "radius" defines the radius of the convolution filter.
 *
 * @overload edge(radius = 0.0)
 *   @param radius [Float] The radius of the convolution filter.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_edge(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double radius = 0.0;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 1:
            radius = NUM2DBL(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
            break;
    }

    exception = AcquireExceptionInfo();

    new_image = EdgeImage(image, radius, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Call one of the effects methods.
 *
 * No Ruby usage (internal function)
 *
 * @param self this object
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param effector the effector to call
 * @return a new image
 */
static VALUE
effect_image(VALUE self, int argc, VALUE *argv, effector_t effector)
{
    Image *image, *new_image;
    ExceptionInfo *exception;
    double radius = 0.0, sigma = 1.0;

    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 2:
            sigma = NUM2DBL(argv[1]);
        case 1:
            radius = NUM2DBL(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 2)", argc);
            break;
    }

    if (sigma == 0.0)
    {
        rb_raise(rb_eArgError, "sigma must be != 0.0");
    }

    exception = AcquireExceptionInfo();
    new_image = (effector)(image, radius, sigma, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Adds a 3-dimensional effect.
 *
 * @overload emboss(radius = 0.0, sigma = 1.0)
 *   @param radius [Float] The radius of the Gaussian operator.
 *   @param sigma [Float] The sigma (standard deviation) of the Gaussian operator.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_emboss(int argc, VALUE *argv, VALUE self)
{
    return effect_image(self, argc, argv, EmbossImage);
}


/**
 * Encipher an image.
 *
 * @param passphrase [String] the passphrase with which to encipher
 * @return [Magick::Image] a new image
 * @example
 *   enciphered_img = img.encipher("magic word")
 */
VALUE
Image_encipher(VALUE self, VALUE passphrase)
{
    Image *image, *new_image;
    char *pf;
    ExceptionInfo *exception;
    MagickBooleanType okay;

    image = rm_check_destroyed(self);
    pf = StringValueCStr(passphrase);      // ensure passphrase is a string
    exception = AcquireExceptionInfo();

    new_image = rm_clone_image(image);

    okay = EncipherImage(new_image, pf, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    if (!okay)
    {
        DestroyImage(new_image);
        rb_raise(rb_eRuntimeError, "EncipherImage failed for unknown reason.");
    }

    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}



/**
 * Return endian option for images that support it.
 *
 * @return [Magick::EndianType] the endian option
 */
VALUE
Image_endian(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return EndianType_find(image->endian);
}


/**
 * Set endian option for images that support it.
 *
 * @param type [Magick::EndianType] the endian type
 * @return [Magick::EndianType] the given type
 */
VALUE
Image_endian_eq(VALUE self, VALUE type)
{
    Image *image = rm_check_frozen(self);
    VALUE_TO_ENUM(type, image->endian, EndianType);
    return type;
}

/**
 * Apply a digital filter that improves the quality of a noisy image.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_enhance(VALUE self)
{
    Image *image, *new_image;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    exception = AcquireExceptionInfo();

    new_image = EnhanceImage(image, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Apply a histogram equalization to the image.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_equalize(VALUE self)
{
    Image *image, *new_image;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    EqualizeImage(new_image, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    EqualizeImage(new_image);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Applies a histogram equalization to the image. Only the specified channels are equalized.
 *
 * @overload equalize_channel(channel = Magick::AllChannels)
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload equalize_channel(*channels)
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_equalize_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif
    ChannelType channels;

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);
    if (argc > 0)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BEGIN_CHANNEL_MASK(new_image, channels);
    EqualizeImage(new_image, exception);
    END_CHANNEL_MASK(new_image);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    EqualizeImageChannel(new_image, channels);

    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Reset the image to the background color.
 *
 * @return [Magick::Image] self
 */
VALUE
Image_erase_bang(VALUE self)
{
    Image *image;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_frozen(self);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    SetImageBackgroundColor(image, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    SetImageBackgroundColor(image);
    rm_check_image_exception(image, RetainOnError);
#endif

    return self;
}


/**
 * Lightweight crop.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - christy says "does not respect the virtual page offset (-page) and does
 *     not update the page offset and its more efficient than cropping."
 *
 * @param bang whether the bang (!) version of the method was called
 * @param self this object
 * @param x the x position for the start of the rectangle
 * @param y the y position for the start of the rectangle
 * @param width the width of the rectancle
 * @param height the height of the rectangle
 * @return self if bang, otherwise a new image
 * @see Image_excerpt
 * @see Image_excerpt_bang
 * @see Image_crop
 * @see Image_crop_bang
 */
static VALUE
excerpt(int bang, VALUE self, VALUE x, VALUE y, VALUE width, VALUE height)
{
    Image *image, *new_image;
    RectangleInfo rect;
    ExceptionInfo *exception;

    memset(&rect, '\0', sizeof(rect));
    rect.x = NUM2LONG(x);
    rect.y = NUM2LONG(y);
    rect.width = NUM2ULONG(width);
    rect.height = NUM2ULONG(height);

    Data_Get_Struct(self, Image, image);

    exception = AcquireExceptionInfo();
    new_image = ExcerptImage(image, &rect, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    if (bang)
    {
        rm_ensure_result(new_image);
        UPDATE_DATA_PTR(self, new_image);
        rm_image_destroy(image);
        return self;
    }

    return rm_image_new(new_image);
}


/**
 * This method is very similar to crop.
 * It extracts the rectangle specified by its arguments from the image and returns it as a new
 * image. However, excerpt does not respect the virtual page offset and does not update the page
 * offset and is more efficient than cropping.
 *
 * @param x [Numeric] the x position for the start of the rectangle
 * @param y [Numeric] the y position for the start of the rectangle
 * @param width [Numeric] the width of the rectancle
 * @param height [Numeric] the height of the rectangle
 * @return [Magick::Image] a new image
 * @see Image#excerpt!
 * @see Image#crop
 * @see Image#crop!
 */
VALUE
Image_excerpt(VALUE self, VALUE x, VALUE y, VALUE width, VALUE height)
{
    rm_check_destroyed(self);
    return excerpt(False, self, x, y, width, height);
}


/**
 * In-place form of {Magick::Image#excerpt}.
 *
 * This method is very similar to crop.
 * It extracts the rectangle specified by its arguments from the image and returns it as a new
 * image.  However, excerpt does not respect the virtual page offset and does not update the page
 * offset and is more efficient than cropping.
 *
 * @param x [Numeric] the x position for the start of the rectangle
 * @param y [Numeric] the y position for the start of the rectangle
 * @param width [Numeric] the width of the rectancle
 * @param height [Numeric] the height of the rectangle
 * @return [Magick::Image] self
 * @see Image#excerpt
 * @see Image#crop
 * @see Image#crop!
 */
VALUE
Image_excerpt_bang(VALUE self, VALUE x, VALUE y, VALUE width, VALUE height)
{
    rm_check_frozen(self);
    return excerpt(True, self, x, y, width, height);
}


/**
 * Extracts the pixel data from the specified rectangle and returns it as an array of Integer
 * values. The array returned by {Magick::Image#export_pixels} is suitable for use as an argument
 * to {Magick::Image#import_pixels}.
 *
 * @overload export_pixels(x = 0, y = 0, cols = self.columns, rows = self.rows, map = "RGB")
 *   @param x [Numeric] The offset of the rectangle from the upper-left corner of the image.
 *   @param y [Numeric] The offset of the rectangle from the upper-left corner of the image.
 *   @param cols [Numeric] The width of the rectangle.
 *   @param rows [Numeric] The height of the rectangle.

 *   @param map [String] A string that describes which pixel channel data is desired and the order
 *     in which it should be stored. It can be any combination or order of R = red, G = green, B =
 *     blue, A = alpha, C = cyan, Y = yellow, M = magenta, K = black, I = intensity (for grayscale),
 *     or P = pad.
 *   @return [Array<Numeric>] array of pixels
 */
VALUE
Image_export_pixels(int argc, VALUE *argv, VALUE self)
{
    Image *image;
    long x_off = 0L, y_off = 0L;
    unsigned long cols, rows;
    long n, npixels;
    unsigned int okay;
    const char *map = "RGB";
    Quantum *pixels;
    VALUE ary;
    ExceptionInfo *exception;


    image = rm_check_destroyed(self);
    cols = image->columns;
    rows = image->rows;

    switch (argc)
    {
        case 5:
            map   = StringValueCStr(argv[4]);
        case 4:
            rows  = NUM2ULONG(argv[3]);
        case 3:
            cols  = NUM2ULONG(argv[2]);
        case 2:
            y_off = NUM2LONG(argv[1]);
        case 1:
            x_off = NUM2LONG(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 5)", argc);
            break;
    }

    if (   x_off < 0 || (unsigned long)x_off > image->columns
           || y_off < 0 || (unsigned long)y_off > image->rows
           || cols == 0 || rows == 0)
    {
        rb_raise(rb_eArgError, "invalid extract geometry");
    }


    npixels = (long)(cols * rows * strlen(map));
    pixels = ALLOC_N(Quantum, npixels);
    if (!pixels)    // app recovered from exception
    {
        return rb_ary_new2(0L);
    }

    exception = AcquireExceptionInfo();

    okay = ExportImagePixels(image, x_off, y_off, cols, rows, map, QuantumPixel, (void *)pixels, exception);
    if (!okay)
    {
        xfree((void *)pixels);
        CHECK_EXCEPTION();

        // Should never get here...
        rm_magick_error("ExportImagePixels failed with no explanation.");
    }

    DestroyExceptionInfo(exception);

    ary = rb_ary_new2(npixels);
    for (n = 0; n < npixels; n++)
    {
        rb_ary_push(ary, QUANTUM2NUM(pixels[n]));
    }

    xfree((void *)pixels);

    RB_GC_GUARD(ary);

    return ary;
}


/**
 * If width or height is greater than the target image's width or height, extends the width and
 * height of the target image to the specified values.  The new pixels are set to the background
 * color. If width or height is less than the target image's width or height, crops the target
 * image.
 *
 * @overload extent(width, height, x = 0, y = 0)
 *   @param width [Numeric] The width of the new image
 *   @param height [Numeric] The height of the new image
 *   @param x [Numeric] The upper-left corner of the new image is positioned
 *   @param y [Numeric] The upper-left corner of the new image is positioned
 *   @return [Magick::Image] a new image
 */
VALUE
Image_extent(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    RectangleInfo geometry;
    long height, width;
    ExceptionInfo *exception;

    rm_check_destroyed(self);

    if (argc < 2 || argc > 4)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (expected 2 to 4, got %d)", argc);
    }

    geometry.y = geometry.x = 0L;
    switch (argc)
    {
        case 4:
            geometry.y = NUM2LONG(argv[3]);
        case 3:
            geometry.x = NUM2LONG(argv[2]);
        default:
            geometry.height = height = NUM2LONG(argv[1]);
            geometry.width = width = NUM2LONG(argv[0]);
            break;
    }

    // Use the signed versions of these two values to test for < 0
    if (height <= 0L || width <= 0L)
    {
        if (geometry.x == 0 && geometry.y == 0)
        {
            rb_raise(rb_eArgError, "invalid extent geometry %ldx%ld", width, height);
        }
        else
        {
            rb_raise(rb_eArgError, "invalid extent geometry %ldx%ld+%"RMIdSIZE"+%"RMIdSIZE"",
                     width, height, geometry.x, geometry.y);
        }
    }


    Data_Get_Struct(self, Image, image);
    exception = AcquireExceptionInfo();

    new_image = ExtentImage(image, &geometry, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Extracts the pixel data from the specified rectangle and returns it as a string.
 *
 * @overload export_pixels_to_str(x = 0, y = 0, cols = self.columns, rows = self.rows, map = "RGB", type = Magick::CharPixel)
 *   @param x [Numeric] The offset of the rectangle from the upper-left corner of the image.
 *   @param y [Numeric] The offset of the rectangle from the upper-left corner of the image.
 *   @param cols [Numeric] The width of the rectangle.
 *   @param rows [Numeric] The height of the rectangle.
 *   @param map [String] A string that describes which pixel channel data is desired and the order
 *     in which it should be stored. It can be any combination or order of R = red, G = green, B =
 *     blue, A = alpha, C = cyan, Y = yellow, M = magenta, K = black, I = intensity (for grayscale),
 *     or P = pad.
 *   @param type [Magick::StorageType] A StorageType value that specifies the C datatype to which
 *     the pixel data will be converted.
 *   @return [String] the pixel data
 */
VALUE
Image_export_pixels_to_str(int argc, VALUE *argv, VALUE self)
{
    Image *image;
    long x_off = 0L, y_off = 0L;
    unsigned long cols, rows;
    unsigned long npixels;
    size_t sz;
    unsigned int okay;
    const char *map = "RGB";
    StorageType type = CharPixel;
    VALUE string;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    cols = image->columns;
    rows = image->rows;

    switch (argc)
    {
        case 6:
            VALUE_TO_ENUM(argv[5], type, StorageType);
        case 5:
            map   = StringValueCStr(argv[4]);
        case 4:
            rows  = NUM2ULONG(argv[3]);
        case 3:
            cols  = NUM2ULONG(argv[2]);
        case 2:
            y_off = NUM2LONG(argv[1]);
        case 1:
            x_off = NUM2LONG(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 to 6)", argc);
            break;
    }

    if (   x_off < 0 || (unsigned long)x_off > image->columns
           || y_off < 0 || (unsigned long)y_off > image->rows
           || cols == 0 || rows == 0)
    {
        rb_raise(rb_eArgError, "invalid extract geometry");
    }


    npixels = cols * rows * strlen(map);
    switch (type)
    {
        case CharPixel:
            sz = sizeof(unsigned char);
            break;
        case ShortPixel:
            sz = sizeof(unsigned short);
            break;
        case DoublePixel:
            sz = sizeof(double);
            break;
        case FloatPixel:
            sz = sizeof(float);
            break;
        case LongPixel:
            sz = sizeof(unsigned long);
            break;
        case QuantumPixel:
            sz = sizeof(Quantum);
            break;
        case UndefinedPixel:
        default:
            rb_raise(rb_eArgError, "undefined storage type");
            break;
    }

    // Allocate a string long enough to hold the exported pixel data.
    // Get a pointer to the buffer.
    string = rb_str_new2("");
    rb_str_resize(string, (long)(sz * npixels));

    exception = AcquireExceptionInfo();

    okay = ExportImagePixels(image, x_off, y_off, cols, rows, map, type, (void *)RSTRING_PTR(string), exception);
    if (!okay)
    {
        // Let GC have the string buffer.
        rb_str_resize(string, 0);
        CHECK_EXCEPTION();

        // Should never get here...
        rm_magick_error("ExportImagePixels failed with no explanation.");
    }

    DestroyExceptionInfo(exception);

    RB_GC_GUARD(string);

    return string;
}


/**
 * The extract_info attribute reader.
 *
 * @return [Magick::Rectangle] the Rectangle object
 */
VALUE
Image_extract_info(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return Import_RectangleInfo(&image->extract_info);
}


/**
 * Set the extract_info attribute.
 *
 * @param rect [Magick::Rectangle] the Rectangle object
 * @return [Magick::Rectangle] the given value
 */
VALUE
Image_extract_info_eq(VALUE self, VALUE rect)
{
    Image *image = rm_check_frozen(self);
    Export_RectangleInfo(&image->extract_info, rect);
    return rect;
}


/**
 * Get image filename.
 *
 * @return [String] the filename
 */
VALUE
Image_filename(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, filename, str);
}


/**
 * Return the image file size.
 *
 * @return [Numeric] the file size
 */
VALUE Image_filesize(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return INT2FIX(GetBlobSize(image));
}


/**
 * Get filter type.
 *
 * @return [Magick::FilterType] the filter
 */
VALUE
Image_filter(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return FilterType_find(image->filter);
}


/**
 * Set filter type.
 *
 * @param filter [Magick::FilterType] the filter
 * @return [Magick::FilterType] the given filter
 */
VALUE
Image_filter_eq(VALUE self, VALUE filter)
{
    Image *image = rm_check_frozen(self);
    VALUE_TO_ENUM(filter, image->filter, FilterType);
    return filter;
}


/**
 * This interesting method searches for a rectangle in the image that is similar to the target.
 * For the rectangle to be similar each pixel in the rectangle must match the corresponding pixel in
 * the target image within the range specified by the fuzz attributes of the image and the target
 * image.
 *
 * @overload find_similar_region(target, x = 0, y = 0)
 *   @param target [Magick::Image, Magick::ImageList] An image that forms the target of the
 *     search. This image can be any size. Either an imagelist or an image. If an imagelist, uses
 *     the current image.
 *   @param x [Numeric] The starting x-offsets for the search.
 *   @param y [Numeric] The starting y-offsets for the search.
 *   @return [Array<Numeric>, nil] If the search succeeds, the return value is an array with 2 elements.
 *     These elements are the x- and y-offsets of the matching rectangle.
 *     If the search fails the return value is nil.
 */
VALUE
Image_find_similar_region(int argc, VALUE *argv, VALUE self)
{
    Image *image, *target;
    VALUE region, targ;
    ssize_t x = 0L, y = 0L;
    ExceptionInfo *exception;
    unsigned int okay;

    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 3:
            y = NUM2LONG(argv[2]);
        case 2:
            x = NUM2LONG(argv[1]);
        case 1:
            targ = rm_cur_image(argv[0]);
            target = rm_check_destroyed(targ);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 to 3)", argc);
            break;
    }

    exception = AcquireExceptionInfo();
    okay = IsEquivalentImage(image, target, &x, &y, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);

    if (!okay)
    {
        return Qnil;
    }

    region = rb_ary_new2(2);
    rb_ary_store(region, 0L, LONG2NUM(x));
    rb_ary_store(region, 1L, LONG2NUM(y));

    RB_GC_GUARD(region);
    RB_GC_GUARD(targ);

    return region;
}


/**
 * Call a flipflopper (a function that either flips or flops the image).
 *
 * No Ruby usage (internal function)
 *
 * @param bang whether the bang (!) version of the method was called
 * @param self this object
 * @param flipflopper the flip/flop method to call
 * @return self if bang, otherwise a new image
 * @see Image_flip
 * @see Image_flip_bang
 * @see Image_flop
 * @see Image_flop_bang
 */
static VALUE
flipflop(int bang, VALUE self, flipper_t flipflopper)
{
    Image *image, *new_image;
    ExceptionInfo *exception;

    Data_Get_Struct(self, Image, image);
    exception = AcquireExceptionInfo();

    new_image = (flipflopper)(image, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    if (bang)
    {
        rm_ensure_result(new_image);
        UPDATE_DATA_PTR(self, new_image);
        rm_image_destroy(image);
        return self;
    }

    return rm_image_new(new_image);
}


/**
 * Create a vertical mirror image by reflecting the pixels around the central x-axis.
 *
 * @return [Magick::Image] a new image
 * @see Image#flip!
 * @see Image#flop
 * @see Image#flop!
 */
VALUE
Image_flip(VALUE self)
{
    rm_check_destroyed(self);
    return flipflop(False, self, FlipImage);
}


/**
 * Create a vertical mirror image by reflecting the pixels around the central x-axis.
 * In-place form of {Image#flip}.
 *
 * @return [Magick::Image] a new image
 * @see Image#flip
 * @see Image#flop
 * @see Image#flop!
 */
VALUE
Image_flip_bang(VALUE self)
{
    rm_check_frozen(self);
    return flipflop(True, self, FlipImage);
}


/**
 * Create a horizonal mirror image by reflecting the pixels around the central y-axis.
 *
 * @return [Magick::Image] a new image
 * @see Image#flop!
 * @see Image#flip
 * @see Image#flip!
 */
VALUE
Image_flop(VALUE self)
{
    rm_check_destroyed(self);
    return flipflop(False, self, FlopImage);
}


/**
 * Create a horizonal mirror image by reflecting the pixels around the central y-axis.
 * In-place form of {Image#flop}.
 *
 * @return [Magick::Image] a new image
 * @see Image#flop
 * @see Image#flip
 * @see Image#flip!
 */
VALUE
Image_flop_bang(VALUE self)
{
    rm_check_frozen(self);
    return flipflop(True, self, FlopImage);
}


/**
 * Return the image encoding format. For example, "GIF" or "PNG".
 *
 * @return [String, nil] the encoding format
 */
VALUE
Image_format(VALUE self)
{
    Image *image;
    const MagickInfo *magick_info;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    if (*image->magick)
    {
        // Deliberately ignore the exception info!
        exception = AcquireExceptionInfo();
        magick_info = GetMagickInfo(image->magick, exception);
        DestroyExceptionInfo(exception);
        return magick_info ? rb_str_new2(magick_info->name) : Qnil;
    }

    return Qnil;
}


/**
 * Set the image encoding format. For example, "GIF" or "PNG".
 *
 * @param magick [String] the encoding format
 * @return [String] the given value
 */
VALUE
Image_format_eq(VALUE self, VALUE magick)
{
    Image *image;
    const MagickInfo *m;
    char *mgk;
    ExceptionInfo *exception;

    image = rm_check_frozen(self);

    mgk = StringValueCStr(magick);

    exception = AcquireExceptionInfo();
    m = GetMagickInfo(mgk, exception);
    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    if (!m)
    {
        rb_raise(rb_eArgError, "unknown format: %s", mgk);
    }


    strlcpy(image->magick, m->name, sizeof(image->magick));
    return magick;
}


/**
 * Add a simulated three-dimensional border around the image.
 *
 * @overload frame(width = self.columns+25*2, height = self.rows+25*2, x = 25, y = 25, inner_bevel = 6, outer_bevel = 6, color = self.matte_color)
 *   @param width [Numeric] The width of the left and right sides.
 *   @param height [Numeric] The height of the top and bottom sides.
 *   @param x [Numeric] The offset of the image from the upper-left outside corner of the border.
 *   @param y [Numeric] The offset of the image from the upper-left outside corner of the border.
 *   @param inner_bevel [Numeric] The width of the inner shadows of the border.
 *   @param outer_bevel [Numeric] The width of the outer shadows of the border.
 *   @param color [Magick::Pixel, String] The border color.
 *   @return [Magick::Image] a new image.
 */
VALUE
Image_frame(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    ExceptionInfo *exception;
    FrameInfo frame_info;

    image = rm_check_destroyed(self);

    frame_info.width = image->columns + 50;
    frame_info.height = image->rows + 50;
    frame_info.x = 25;
    frame_info.y = 25;
    frame_info.inner_bevel = 6;
    frame_info.outer_bevel = 6;

    switch (argc)
    {
        case 7:
            Color_to_PixelColor(&image->matte_color, argv[6]);
        case 6:
            frame_info.outer_bevel = NUM2LONG(argv[5]);
        case 5:
            frame_info.inner_bevel = NUM2LONG(argv[4]);
        case 4:
            frame_info.y = NUM2LONG(argv[3]);
        case 3:
            frame_info.x = NUM2LONG(argv[2]);
        case 2:
            frame_info.height = image->rows + 2*NUM2LONG(argv[1]);
        case 1:
            frame_info.width = image->columns + 2*NUM2LONG(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 7)", argc);
            break;
    }

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    new_image = FrameImage(image, &frame_info, image->compose, exception);
#else
    new_image = FrameImage(image, &frame_info, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Convert direct to memory image formats from string data.
 *
 * @overload from_blob(blob)
 *   @param blob [String] the blob data
 *
 * @overload from_blob(blob)
 *   This yields {Magick::Image::Info} to block with its object's scope.
 *   @param blob [String] the blob data
 *   @yield [Magick::Image::Info]
 *
 * @return [Array<Magick::Image>] an array of new images
 * @see Image#to_blob
 */
VALUE
Image_from_blob(VALUE class ATTRIBUTE_UNUSED, VALUE blob_arg)
{
    Image *images;
    Info *info;
    VALUE info_obj;
    ExceptionInfo *exception;
    void *blob;
    long length;

    blob = (void *) rm_str2cstr(blob_arg, &length);

    // Get a new Info object - run the parm block if supplied
    info_obj = rm_info_new();
    Data_Get_Struct(info_obj, Info, info);

    exception = AcquireExceptionInfo();
    images = BlobToImage(info,  blob, (size_t)length, exception);
    rm_check_exception(exception, images, DestroyOnError);

    DestroyExceptionInfo(exception);

    rm_ensure_result(images);
    rm_set_user_artifact(images, info);

    RB_GC_GUARD(info_obj);

    return array_from_images(images);
}


/**
 * Set the function on a channel.
 *
 * @overload function_channel(function, *args, channel = Magick::AllChannels)
 *   @param function [Magick::MagickFunction] the function
 *   @param *args [Float] One or more floating-point numbers.
 *     The number of parameters depends on the function. See the ImageMagick documentation for
 *     details.

 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload function_channel(function, *args, *channels)
 *   @param function [Magick::MagickFunction] the function
 *   @param *args [Float] One or more floating-point numbers.
 *     The number of parameters depends on the function. See the ImageMagick documentation for
 *     details.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 * @see https://www.imagemagick.org/script/command-line-options.php#function
 */
VALUE
Image_function_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    MagickFunction function;
    unsigned long n, nparms;
    double *parms;
    ChannelType channels;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);

    // The number of parameters depends on the function.
    if (argc == 0)
    {
        rb_raise(rb_eArgError, "no function specified");
    }

    VALUE_TO_ENUM(argv[0], function, MagickFunction);
    argc -= 1;
    argv += 1;

    switch (function)
    {
        case PolynomialFunction:
            if (argc == 0)
            {
                rb_raise(rb_eArgError, "PolynomialFunction requires at least one argument.");
            }
            break;
        case SinusoidFunction:
        case ArcsinFunction:
        case ArctanFunction:
           if (argc < 1 || argc > 4)
           {
               rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 to 4)", argc);
           }
           break;
        default:
            rb_raise(rb_eArgError, "undefined function");
            break;
    }

    nparms = argc;
    parms = ALLOC_N(double, nparms);

    for (n = 0; n < nparms; n++)
    {
        VALUE element = argv[n];
        if (rm_check_num2dbl(element))
        {
            parms[n] = NUM2DBL(element);
        }
        else
        {
            xfree(parms);
            rb_raise(rb_eTypeError, "type mismatch: %s given", rb_class2name(CLASS_OF(element)));
        }
    }

    exception = AcquireExceptionInfo();
    new_image = rm_clone_image(image);
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(new_image, channels);
    FunctionImage(new_image, function, nparms, parms, exception);
    END_CHANNEL_MASK(new_image);
#else
    FunctionImageChannel(new_image, channels, function, nparms, parms, exception);
#endif
    xfree(parms);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Get the number of algorithms search for a target color.
 * By default the color must be exact.
 * Use this attribute to match colors that are close to the target color in RGB space.
 *
 * @return [Float] the fuzz
 * @see Info#fuzz
 */
VALUE
Image_fuzz(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, fuzz, dbl);
}


/**
 * Set the number of algorithms search for a target color.
 *
 * @param fuzz [String, Float] The argument may be a floating-point numeric value or a string in the
 *   form "NN%".
 * @return [String, Float] the given value
 * @see Info#fuzz=
 */
VALUE
Image_fuzz_eq(VALUE self, VALUE fuzz)
{
    Image *image = rm_check_frozen(self);
    image->fuzz = rm_fuzz_to_dbl(fuzz);
    return fuzz;
}


/**
 * Apply fx on the image.
 *
 * @overload fx(expression, channel = Magick::AllChannels)
 *   @param expression [String] A mathematical expression
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload fx(expression, *channels)
 *   @param expression [String] A mathematical expression
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_fx(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    char *expression;
    ChannelType channels;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);

    // There must be exactly 1 remaining argument.
    if (argc == 0)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (0 for 1 or more)");
    }
    else if (argc > 1)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    expression = StringValueCStr(argv[0]);

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    new_image = FxImage(image, expression, exception);
    CHANGE_RESULT_CHANNEL_MASK(new_image);
    END_CHANNEL_MASK(image);
#else
    new_image = FxImageChannel(image, channels, expression, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}

/**
 * Get the gamma level of the image.
 *
 * @return [Float] the gamma level
 */
VALUE
Image_gamma(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, gamma, dbl);
}

/**
 * Set the gamma level of the image.
 *
 * @param val [Float] the gamma level
 * @return [Float] the gamma level
 */
VALUE
Image_gamma_eq(VALUE self, VALUE val)
{
    IMPLEMENT_ATTR_WRITER(Image, gamma, dbl);
}


/**
 * Apply gamma to a channel.
 *
 * @overload gamma_channel(gamma, channel = Magick::AllChannels)
 *   @param Values gamma [Float] typically range from 0.8 to 2.3. You can also reduce the influence
 *     of a particular channel with a gamma value of 0.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload gamma_channel(gamma, *channels)
 *   @param Values gamma [Float] typically range from 0.8 to 2.3. You can also reduce the influence
 *     of a particular channel with a gamma value of 0.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_gamma_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    ChannelType channels;
    double gamma;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);

    // There must be exactly one remaining argument.
    if (argc == 0)
    {
        rb_raise(rb_eArgError, "missing gamma argument");
    }
    else if (argc > 1)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    gamma = NUM2DBL(argv[0]);
    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BEGIN_CHANNEL_MASK(new_image, channels);
    GammaImage(new_image, gamma, exception);
    END_CHANNEL_MASK(new_image);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    GammaImageChannel(new_image, channels, gamma);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * gamma-correct an image.
 *
 * @overload gamma_correct(red_gamma, green_gamma = red_gamma, blue_gamma = green_gamma)
 *   @return [Magick::Image] a new image
 */
VALUE
Image_gamma_correct(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double red_gamma, green_gamma, blue_gamma;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 1:
            red_gamma   = NUM2DBL(argv[0]);
            green_gamma = blue_gamma = red_gamma;
            break;
        case 2:
            red_gamma   = NUM2DBL(argv[0]);
            green_gamma = NUM2DBL(argv[1]);
            blue_gamma  = green_gamma;
            break;
        case 3:
        case 4:
            red_gamma     = NUM2DBL(argv[0]);
            green_gamma   = NUM2DBL(argv[1]);
            blue_gamma    = NUM2DBL(argv[2]);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 to 3)", argc);
            break;
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
#endif

    if ((red_gamma == green_gamma) && (green_gamma == blue_gamma))
    {
#if defined(IMAGEMAGICK_7)
        BEGIN_CHANNEL_MASK(new_image, (ChannelType) (RedChannel | GreenChannel | BlueChannel));
        GammaImage(new_image, red_gamma, exception);
        END_CHANNEL_MASK(new_image);
#else
        GammaImageChannel(new_image, (ChannelType) (RedChannel | GreenChannel | BlueChannel), red_gamma);
#endif
    }
    else
    {
#if defined(IMAGEMAGICK_7)
        BEGIN_CHANNEL_MASK(new_image, RedChannel);
        GammaImage(new_image, red_gamma, exception);
        END_CHANNEL_MASK(new_image);

        BEGIN_CHANNEL_MASK(new_image, GreenChannel);
        GammaImage(new_image, green_gamma, exception);
        END_CHANNEL_MASK(new_image);

        BEGIN_CHANNEL_MASK(new_image, BlueChannel);
        GammaImage(new_image, blue_gamma, exception);
        END_CHANNEL_MASK(new_image);
#else
        GammaImageChannel(new_image, RedChannel, red_gamma);
        GammaImageChannel(new_image, GreenChannel, green_gamma);
        GammaImageChannel(new_image, BlueChannel, blue_gamma);
#endif
    }

#if defined(IMAGEMAGICK_7)
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Blur the image.
 *
 * @overload gaussian_blur(radius = 0.0, sigma = 1.0)
 *   @param radius [Float] The radius of the Gaussian operator.
 *   @param sigma [Float] The sigma (standard deviation) of the Gaussian operator.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_gaussian_blur(int argc, VALUE *argv, VALUE self)
{
    return effect_image(self, argc, argv, GaussianBlurImage);
}


/**
 * Blur the image on a channel.
 *
 * @overload gaussian_blur_channel(radius = 0.0, sigma = 1.0, channel = Magick::AllChannels)
 *   @param radius [Float] The radius of the Gaussian operator.
 *   @param sigma [Float] The sigma (standard deviation) of the Gaussian operator.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload gaussian_blur_channel(radius = 0.0, sigma = 1.0, *channels)
 *   @param radius [Float] The radius of the Gaussian operator.
 *   @param sigma [Float] The sigma (standard deviation) of the Gaussian operator.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_gaussian_blur_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    ChannelType channels;
    ExceptionInfo *exception;
    double radius = 0.0, sigma = 1.0;

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);

    // There can be 0, 1, or 2 remaining arguments.
    switch (argc)
    {
        case 2:
            sigma = NUM2DBL(argv[1]);
            /* Fall thru */
        case 1:
            radius = NUM2DBL(argv[0]);
            /* Fall thru */
        case 0:
            break;
        default:
            raise_ChannelType_error(argv[argc-1]);
    }

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    new_image = GaussianBlurImage(image, radius, sigma, exception);
    CHANGE_RESULT_CHANNEL_MASK(new_image);
    END_CHANNEL_MASK(image);
    rm_check_exception(exception, new_image, DestroyOnError);
#else
    new_image = GaussianBlurImageChannel(image, channels, radius, sigma, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
#endif

    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Get the preferred size of the image when encoding.
 *
 * @return [String] the geometry
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Image_geometry(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, geometry, str);
}


/**
 * Set the preferred size of the image when encoding.
 *
 * @param geometry [String] the geometry
 * @return [String] the given geometry
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Image_geometry_eq(VALUE self, VALUE geometry)
{
    Image *image;
    VALUE geom_str;
    char *geom;

    image = rm_check_frozen(self);

    if (geometry == Qnil)
    {
        magick_free(image->geometry);
        image->geometry = NULL;
        return self;
    }


    geom_str = rb_String(geometry);
    geom = StringValueCStr(geom_str);
    if (!IsGeometry(geom))
    {
        rb_raise(rb_eTypeError, "invalid geometry: %s", geom);
    }
    magick_clone_string(&image->geometry, geom);

    RB_GC_GUARD(geom_str);

    return geometry;
}


/**
 * Gets the pixels from the specified rectangle within the image.
 *
 * @param x_arg [Numeric] x position of start of region
 * @param y_arg [Numeric] y position of start of region
 * @param cols_arg [Numeric] width of region
 * @param rows_arg [Numeric] height of region
 * @return [Array<Magick::Pixel>] An array of Magick::Pixel objects corresponding to the pixels in the rectangle
 *   defined by the geometry parameters.
 * @see Image#store_pixels
 */
VALUE
Image_get_pixels(VALUE self, VALUE x_arg, VALUE y_arg, VALUE cols_arg, VALUE rows_arg)
{
    Image *image;
    ExceptionInfo *exception;
    long x, y;
    unsigned long columns, rows;
    long size, n;
    VALUE pixel_ary;
#if defined(IMAGEMAGICK_7)
    const Quantum *pixels;
#else
    const PixelPacket *pixels;
    const IndexPacket *indexes;
#endif

    image = rm_check_destroyed(self);
    x       = NUM2LONG(x_arg);
    y       = NUM2LONG(y_arg);
    columns = NUM2ULONG(cols_arg);
    rows    = NUM2ULONG(rows_arg);

    if ((x+columns) > image->columns || (y+rows) > image->rows)
    {
        rb_raise(rb_eRangeError, "geometry (%lux%lu%+ld%+ld) exceeds image bounds",
                 columns, rows, x, y);
    }

    // Cast AcquireImagePixels to get rid of the const qualifier. We're not going
    // to change the pixels but I don't want to make "pixels" const.
    exception = AcquireExceptionInfo();
    pixels = GetVirtualPixels(image, x, y, columns, rows, exception);
    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    // If the function failed, return a 0-length array.
    if (!pixels)
    {
        return rb_ary_new();
    }

    // Allocate an array big enough to contain the PixelPackets.
    size = (long)(columns * rows);
    pixel_ary = rb_ary_new2(size);

#if defined(IMAGEMAGICK_6)
    indexes = GetVirtualIndexQueue(image);
#endif

    // Convert the PixelPackets to Magick::Pixel objects
    for (n = 0; n < size; n++)
    {
#if defined(IMAGEMAGICK_7)
        PixelPacket color;
        memset(&color, 0, sizeof(color));
        color.red   = GetPixelRed(image, pixels);
        color.green = GetPixelGreen(image, pixels);
        color.blue  = GetPixelBlue(image, pixels);
        color.alpha = GetPixelAlpha(image, pixels);
        color.black = GetPixelBlack(image, pixels);
        rb_ary_store(pixel_ary, n, Pixel_from_PixelPacket(&color));

        pixels += GetPixelChannels(image);
#else
        MagickPixel mpp;
        mpp.red = GetPixelRed(pixels);
        mpp.green = GetPixelGreen(pixels);
        mpp.blue = GetPixelBlue(pixels);
        mpp.opacity = GetPixelOpacity(pixels);
        if (indexes)
        {
            mpp.index = GetPixelIndex(indexes + n);
        }
        rb_ary_store(pixel_ary, n, Pixel_from_MagickPixel(&mpp));
        pixels++;
#endif
    }

    return pixel_ary;
}


/**
 * Run a function testing whether this image has an attribute.
 *
 * No Ruby usage (internal function)
 *
 * @param self this object
 * @param attr_test the attribute testing function
 * @return the result of attr_test.
 */
static VALUE
has_attribute(VALUE self, MagickBooleanType (attr_test)(const Image *, ExceptionInfo *))
{
    Image *image;
    ExceptionInfo *exception;
    MagickBooleanType r;

    image = rm_check_destroyed(self);
    exception = AcquireExceptionInfo();

    r = (attr_test)(image, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);

    return r ? Qtrue : Qfalse;
}


#if defined(IMAGEMAGICK_7)
/**
 * Run a function testing whether this image has an attribute.
 *
 * No Ruby usage (internal function)
 *
 * @param self this object
 * @param attr_test the attribute testing function
 * @return the result of attr_test.
 */
static VALUE
has_image_attribute(VALUE self, MagickBooleanType (attr_test)(const Image *))
{
    Image *image;
    MagickBooleanType r;

    image = rm_check_destroyed(self);
    r = (attr_test)(image);

    return r ? Qtrue : Qfalse;
}
#endif


/**
 * Return true if all the pixels in the image have the same red, green, and blue intensities.
 *
 * @return [Boolean] true if image is gray, false otherwise
 */
VALUE
Image_gray_q(VALUE self)
{
#if defined(HAVE_SETIMAGEGRAY)
    return has_attribute(self, (MagickBooleanType (*)(const Image *, ExceptionInfo *))SetImageGray);
#else
#if defined(IMAGEMAGICK_GREATER_THAN_EQUAL_6_8_9)
    return has_attribute(self, IsGrayImage);
#else
    // For ImageMagick 6.7
    Image *image;
    ColorspaceType colorspace;
    VALUE ret;

    image = rm_check_destroyed(self);
    colorspace = image->colorspace;
    if (image->colorspace == sRGBColorspace || image->colorspace == TransparentColorspace) {
        // Workaround
        //   If image colorspace has non-RGBColorspace, IsGrayImage() always return false.
        image->colorspace = RGBColorspace;
    }

    ret = has_attribute(self, IsGrayImage);
    image->colorspace = colorspace;
    return ret;
#endif
#endif
}


/**
 * Return true if has 1024 unique colors or less.
 *
 * @return [Boolean] true if image has <= 1024 unique colors
 */
VALUE
Image_histogram_q(VALUE self)
{
    return has_attribute(self, IsHistogramImage);
}


/**
 * Implode the image by the specified percentage.
 *
 * @overload implode(amount = 0.50)
 *   @return [Magick::Image] a new image
 */
VALUE
Image_implode(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double amount = 0.50;
    ExceptionInfo *exception;

    switch (argc)
    {
        case 1:
            amount = NUM2DBL(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
    }

    image = rm_check_destroyed(self);
    exception = AcquireExceptionInfo();

#if defined(IMAGEMAGICK_7)
    new_image = ImplodeImage(image, amount, image->interpolate, exception);
#else
    new_image = ImplodeImage(image, amount, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Store image pixel data from an array.
 *
 * @overload store_pixels(x, y, columns, rows, map, pixels, type = Magick::CharPixel)
 *   @param x [Numeric] The x-offset of the rectangle to be replaced.
 *   @param y [Numeric] The y-offset of the rectangle to be replaced.
 *   @param columns [Numeric] The number of columns in the rectangle.
 *   @param rows [Numeric] The number of rows in the rectangle.
 *   @param map [String] his string reflects the expected ordering of the pixel array.
 *   @param pixels [Array] An array of pixels.
 *     The number of pixels in the array must be the same as the number
 *     of pixels in the rectangle, that is, rows*columns.
 *   @param type [Magick::StorageType] A StorageType value that specifies the C datatype to which
 *     the pixel data will be converted.
 *   @return [Magick::Image] self
 *   @see Image#export_pixels
 */
VALUE
Image_import_pixels(int argc, VALUE *argv, VALUE self)
{
    Image *image;
    long x_off, y_off;
    unsigned long cols, rows;
    unsigned long n, npixels;
    long buffer_l;
    char *map;
    VALUE pixel_arg, pixel_ary;
    StorageType stg_type = CharPixel;
    size_t type_sz, map_l;
    Quantum *pixels = NULL;
    double *fpixels = NULL;
    void *buffer;
    unsigned int okay;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_frozen(self);

    switch (argc)
    {
        case 7:
            VALUE_TO_ENUM(argv[6], stg_type, StorageType);
        case 6:
            x_off = NUM2LONG(argv[0]);
            y_off = NUM2LONG(argv[1]);
            cols = NUM2ULONG(argv[2]);
            rows = NUM2ULONG(argv[3]);
            map = StringValueCStr(argv[4]);
            pixel_arg = argv[5];
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 6 or 7)", argc);
            break;
    }

    if (x_off < 0 || y_off < 0 || cols <= 0 || rows <= 0)
    {
        rb_raise(rb_eArgError, "invalid import geometry");
    }

    map_l = rm_strnlen_s(map, MaxTextExtent);
    npixels = cols * rows * map_l;

    // Assume that any object that responds to :to_str is a string buffer containing
    // binary pixel data.
    if (rb_respond_to(pixel_arg, rb_intern("to_str")))
    {
        buffer = (void *)rm_str2cstr(pixel_arg, &buffer_l);
        switch (stg_type)
        {
            case CharPixel:
                type_sz = 1;
                break;
            case ShortPixel:
                type_sz = sizeof(unsigned short);
                break;
            case LongPixel:
                type_sz = sizeof(unsigned long);
                break;
            case DoublePixel:
                type_sz = sizeof(double);
                break;
            case FloatPixel:
                type_sz = sizeof(float);
                break;
            case QuantumPixel:
                type_sz = sizeof(Quantum);
                break;
            default:
                rb_raise(rb_eArgError, "unsupported storage type %s", StorageType_name(stg_type));
                break;
        }

        if (buffer_l % type_sz != 0)
        {
            rb_raise(rb_eArgError, "pixel buffer must be an exact multiple of the storage type size");
        }
        if ((buffer_l / type_sz) % map_l != 0)
        {
            rb_raise(rb_eArgError, "pixel buffer must contain an exact multiple of the map length");
        }
        if ((unsigned long)(buffer_l / type_sz) < npixels)
        {
            rb_raise(rb_eArgError, "pixel buffer too small (need %lu channel values, got %"RMIuSIZE")",
                     npixels, buffer_l/type_sz);
        }
    }
    // Otherwise convert the argument to an array and convert the array elements
    // to binary pixel data.
    else
    {
        // rb_Array converts an object that is not an array to an array if possible,
        // and raises TypeError if it can't. It usually is possible.
        pixel_ary = rb_Array(pixel_arg);

        if (RARRAY_LEN(pixel_ary) % map_l != 0)
        {
            rb_raise(rb_eArgError, "pixel array must contain an exact multiple of the map length");
        }
        if ((unsigned long)RARRAY_LEN(pixel_ary) < npixels)
        {
            rb_raise(rb_eArgError, "pixel array too small (need %lu elements, got %ld)",
                     npixels, RARRAY_LEN(pixel_ary));
        }

        if (stg_type == DoublePixel || stg_type == FloatPixel)
        {
            fpixels = ALLOC_N(double, npixels);
            for (n = 0; n < npixels; n++)
            {
                VALUE element = rb_ary_entry(pixel_ary, n);
                if (rm_check_num2dbl(element))
                {
                    fpixels[n] = NUM2DBL(element);
                }
                else
                {
                    xfree(fpixels);
                    rb_raise(rb_eTypeError, "type mismatch: %s given", rb_class2name(CLASS_OF(element)));
                }
            }
            buffer = (void *) fpixels;
            stg_type = DoublePixel;
        }
        else
        {
            pixels = ALLOC_N(Quantum, npixels);
            for (n = 0; n < npixels; n++)
            {
                VALUE element = rb_ary_entry(pixel_ary, n);
                if (rm_check_num2dbl(element))
                {
                    pixels[n] = NUM2DBL(element);
                }
                else
                {
                    xfree(pixels);
                    rb_raise(rb_eTypeError, "type mismatch: %s given", rb_class2name(CLASS_OF(element)));
                }
            }
            buffer = (void *) pixels;
            stg_type = QuantumPixel;
        }
    }


#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    okay = ImportImagePixels(image, x_off, y_off, cols, rows, map, stg_type, buffer, exception);
#else
    okay = ImportImagePixels(image, x_off, y_off, cols, rows, map, stg_type, buffer);
#endif

    // Free pixel array before checking for errors.
    if (pixels)
    {
        xfree((void *)pixels);
    }
    if (fpixels)
    {
        xfree((void *)fpixels);
    }

    if (!okay)
    {
#if defined(IMAGEMAGICK_7)
        CHECK_EXCEPTION();
        DestroyExceptionInfo(exception);
#else
        rm_check_image_exception(image, RetainOnError);
#endif
        // Shouldn't get here...
        rm_magick_error("ImportImagePixels failed with no explanation.");
    }
#if defined(IMAGEMAGICK_7)
    DestroyExceptionInfo(exception);
#endif

    RB_GC_GUARD(pixel_arg);
    RB_GC_GUARD(pixel_ary);

    return self;
}


/**
 * Override Object#inspect - return a string description of the image.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - This is essentially the IdentifyImage except the description is built in
 *     a char buffer instead of being written to a file.
 *
 * @param image the image to inspect
 * @param buffer buffer for the output string
 * @param len length of buffer
 * @see Image_inspect
 */
static void
build_inspect_string(Image *image, char *buffer, size_t len)
{
    unsigned long quantum_depth;
    int x = 0;                  // # bytes used in buffer

    // Print magick filename if different from current filename.
    if (*image->magick_filename != '\0' && strcmp(image->magick_filename, image->filename) != 0)
    {
        x += snprintf(buffer+x, len-x, "%.1024s=>", image->magick_filename);
    }
    // Print current filename.
    x += snprintf(buffer+x, len-x, "%.1024s", image->filename);
    // Print scene number.
    if ((GetPreviousImageInList(image) != NULL) && (GetNextImageInList(image) != NULL) && image->scene > 0)
    {
        x += snprintf(buffer+x, len-x, "[%"RMIuSIZE"]", image->scene);
    }
    // Print format
    x += snprintf(buffer+x, len-x, " %s ", image->magick);

    // Print magick columnsXrows if different from current.
    if (image->magick_columns != 0 || image->magick_rows != 0)
    {
        if (image->magick_columns != image->columns || image->magick_rows != image->rows)
        {
            x += snprintf(buffer+x, len-x, "%"RMIuSIZE"x%"RMIuSIZE"=>", image->magick_columns, image->magick_rows);
        }
    }

    x += snprintf(buffer+x, len-x, "%"RMIuSIZE"x%"RMIuSIZE" ", image->columns, image->rows);

    // Print current columnsXrows
    if (   image->page.width != 0 || image->page.height != 0
           || image->page.x != 0     || image->page.y != 0)
    {
        x += snprintf(buffer+x, len-x, "%"RMIuSIZE"x%"RMIuSIZE"+%"RMIdSIZE"+%"RMIdSIZE" ",
                      image->page.width, image->page.height,
                      image->page.x, image->page.y);
    }

    if (image->storage_class == DirectClass)
    {
        x += snprintf(buffer+x, len-x, "DirectClass ");
        if (image->total_colors != 0)
        {
            if (image->total_colors >= (unsigned long)(1 << 24))
            {
                x += snprintf(buffer+x, len-x, "%"RMIuSIZE"mc ", image->total_colors/1024/1024);
            }
            else
            {
                if (image->total_colors >= (unsigned long)(1 << 16))
                {
                    x += snprintf(buffer+x, len-x, "%"RMIuSIZE"kc ", image->total_colors/1024);
                }
                else
                {
                    x += snprintf(buffer+x, len-x, "%"RMIuSIZE"c ", image->total_colors);
                }
            }
        }
    }
    else
    {
        // Cast `image->colors' to long to suppress gcc warnings when
        // building with GM. GM defines that field as an unsigned int.
        if (image->total_colors <= image->colors)
        {
            x += snprintf(buffer+x, len-x, "PseudoClass %ldc ", (long) image->colors);
        }
        else
        {
            x += snprintf(buffer+x, len-x, "PseudoClass %"RMIuSIZE"=>%"RMIuSIZE"c ", image->total_colors, image->colors);
            if (image->error.mean_error_per_pixel != 0.0)
            {
                x += snprintf(buffer+x, len-x, "%ld/%.6f/%.6fdb ",
                              (long) (image->error.mean_error_per_pixel+0.5),
                              image->error.normalized_mean_error,
                              image->error.normalized_maximum_error);
            }
        }
    }

    // Print bit depth
    quantum_depth = GetImageQuantumDepth(image, MagickTrue);
    x += snprintf(buffer+x, len-x, "%lu-bit", quantum_depth);

    // Print blob info if appropriate.
    if (GetBlobSize(image) != 0)
    {
        if (GetBlobSize(image) >= (1 << 24))
        {
            x += snprintf(buffer+x, len-x, " %lumb", (unsigned long) (GetBlobSize(image)/1024/1024));
        }
        else if (GetBlobSize(image) >= 1024)
        {
            x += snprintf(buffer+x, len-x, " %lukb", (unsigned long) (GetBlobSize(image)/1024));
        }
        else
        {
            x += snprintf(buffer+x, len-x, " %lub", (unsigned long) GetBlobSize(image));
        }
    }


    if (len-1-x > 6)
    {
        size_t value_l;
        const char *value = GetImageArtifact(image, "user");
        if (value)
        {
            strcpy(buffer+x, " user:");
            x += 6;
            value_l = len - x - 1;
            value_l = min(rm_strnlen_s(value, MaxTextExtent), value_l);
            memcpy(buffer+x, value, value_l);
            x += value_l;
        }
    }

    assert(x < (int)(len-1));
    buffer[x] = '\0';

    return;
}


/**
 * Override {Object#inspect} - return a string description of the image.
 *
 * @return [String] the string
 */
VALUE
Image_inspect(VALUE self)
{
    Image *image;
    char buffer[MaxTextExtent];          // image description buffer

    Data_Get_Struct(self, Image, image);
    if (!image)
    {
        return rb_str_new2("#<Magick::Image: (destroyed)>");
    }
    build_inspect_string(image, buffer, sizeof(buffer));
    return rb_str_new2(buffer);
}


/**
 * Get the type of interlacing scheme (default NoInterlace).
 * This option is used to specify the type of interlacing scheme for raw image formats such as RGB
 * or YUV.
 * NoInterlace means do not interlace, LineInterlace uses scanline interlacing, and PlaneInterlace
 * uses plane interlacing. PartitionInterlace is like PlaneInterlace except the different planes are
 * saved to individual files (e.g. image.R, image.G, and image.B).
 *
 * @return [Magick::InterlaceType] the interlace
 */
VALUE
Image_interlace(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return InterlaceType_find(image->interlace);
}


/**
 * Set the type of interlacing scheme.
 *
 * @param interlace [Magick::InterlaceType] the interlace
 * @return [Magick::InterlaceType] the given value
 */
VALUE
Image_interlace_eq(VALUE self, VALUE interlace)
{
    Image *image = rm_check_frozen(self);
    VALUE_TO_ENUM(interlace, image->interlace, InterlaceType);
    return interlace;
}


/**
 * Return the IPTC profile as a String.
 *
 * @return [String, nil] the IPTC profile if it exists, otherwise nil
 */
VALUE
Image_iptc_profile(VALUE self)
{
    Image *image;
    const StringInfo *profile;

    image = rm_check_destroyed(self);
    profile = GetImageProfile(image, "iptc");
    if (!profile)
    {
        return Qnil;
    }

    return rb_str_new((char *)profile->datum, (long)profile->length);

}



/**
 * Set the IPTC profile. The argument is a string.
 *
 * @param profile [String] the IPTC profile
 * @return [String] the given profile
 */
VALUE
Image_iptc_profile_eq(VALUE self, VALUE profile)
{
    Image_delete_profile(self, rb_str_new2("iptc"));
    if (profile != Qnil)
    {
        set_profile(self, "iptc", profile);
    }
    return profile;
}


/*
 *  These are undocumented methods. The writer is
 *  called only by Image#iterations=.
 *  The reader is only used by the unit tests!
 */
VALUE
Image_iterations(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, iterations, int);
}
VALUE
Image_iterations_eq(VALUE self, VALUE val)
{
    IMPLEMENT_ATTR_WRITER(Image, iterations, int);
}

/**
 * Adjusts the levels of an image by scaling the colors falling between specified white and black
 * points to the full available quantum range.
 *
 * @overload level2(black_point = 0.0, white_point = Magick::QuantumRange, gamma = 1.0)
 *   @param black_point [Float] A black point level in the range 0 - QuantumRange.
 *   @param white_point [Float] A white point level in the range 0..QuantumRange.
 *   @param gamma [Float] A gamma correction in the range 0.0 - 10.0.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_level2(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double black_point = 0.0, gamma_val = 1.0, white_point = (double)QuantumRange;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#else
    char level[50];
#endif

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 0:             // take all the defaults
            break;
        case 1:
            black_point = NUM2DBL(argv[0]);
            white_point = QuantumRange - black_point;
            break;
        case 2:
            black_point = NUM2DBL(argv[0]);
            white_point = NUM2DBL(argv[1]);
            break;
        case 3:
            black_point = NUM2DBL(argv[0]);
            white_point = NUM2DBL(argv[1]);
            gamma_val   = NUM2DBL(argv[2]);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 3)", argc);
            break;
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    LevelImage(new_image, black_point, white_point, gamma_val, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    snprintf(level, sizeof(level), "%gx%g+%g", black_point, white_point, gamma_val);
    LevelImage(new_image, level);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Similar to {Image#level2} but applies to a single channel only.
 *
 * @overload level_channel(aChannelType, black = 0.0, white = 1.0, gamma = Magick::QuantumRange)
 *   @param aChannelType [Magick::ChannelType] A ChannelType value.
 *   @param black [Float] A black point level in the range 0..QuantumRange.
 *   @param white [Float] A white point level in the range 0..QuantumRange.
 *   @param gamma [Float] A gamma correction in the range 0.0 - 10.0.
 *   @return [Magick::Image] a new image
 *   @see Image#level2
 */
VALUE
Image_level_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double black_point = 0.0, gamma_val = 1.0, white_point = (double)QuantumRange;
    ChannelType channel;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 1:             // take all the defaults
            break;
        case 2:
            black_point = NUM2DBL(argv[1]);
            white_point = QuantumRange - black_point;
            break;
        case 3:
            black_point = NUM2DBL(argv[1]);
            white_point = NUM2DBL(argv[2]);
            break;
        case 4:
            black_point = NUM2DBL(argv[1]);
            white_point = NUM2DBL(argv[2]);
            gamma_val   = NUM2DBL(argv[3]);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 to 4)", argc);
            break;
    }

    VALUE_TO_ENUM(argv[0], channel, ChannelType);

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BEGIN_CHANNEL_MASK(new_image, channel);
    LevelImage(new_image, black_point, white_point, gamma_val, exception);
    END_CHANNEL_MASK(new_image);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    LevelImageChannel(new_image, channel, black_point, white_point, gamma_val);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * When invert is true, black and white will be mapped to the black_color and white_color colors,
 * compressing all other colors linearly. When invert is false, black and white will be mapped to
 * the black_color and white_color colors, stretching all other colors linearly.
 *
 * @overload level_colors(black_color = "black", white_color = "white", invert = true, channel = Magick::AllChannels)
 *   @param black_color [Magick::Pixel, String] The color to be mapped to black
 *   @param white_color [Magick::Pixel, String] The color to be mapped to white
 *   @param invert See the description above
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload level_colors(black_color = "black", white_color = "white", invert = true, *channels)
 *   @param black_color [Magick::Pixel, String] The color to be mapped to black
 *   @param white_color [Magick::Pixel, String] The color to be mapped to white
 *   @param invert See the description above
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_level_colors(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    MagickPixel black_color, white_color;
    ChannelType channels;
    MagickBooleanType invert = MagickTrue;
    MagickBooleanType status;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

    channels = extract_channels(&argc, argv);

    rm_init_magickpixel(image, &white_color);
    rm_init_magickpixel(image, &black_color);

    switch (argc)
    {
        case 3:
            invert = RTEST(argv[2]);

        case 2:
            Color_to_MagickPixel(image, &white_color, argv[1]);
            Color_to_MagickPixel(image, &black_color, argv[0]);
            break;

        case 1:
            rm_set_magickpixel(&white_color, "white");
            Color_to_MagickPixel(image, &black_color, argv[0]);
            break;

        case 0:
            rm_set_magickpixel(&white_color, "white");
            rm_set_magickpixel(&black_color, "black");
            break;

        default:
            raise_ChannelType_error(argv[argc-1]);
            break;
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BEGIN_CHANNEL_MASK(new_image, channels);
    status = LevelImageColors(new_image, &black_color, &white_color, invert, exception);
    END_CHANNEL_MASK(new_image);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    status = LevelColorsImageChannel(new_image, channels, &black_color, &white_color, invert);
    rm_check_image_exception(new_image, DestroyOnError);
#endif
    if (!status)
    {
        rb_raise(rb_eRuntimeError, "LevelImageColors failed for unknown reason.");
    }

    return rm_image_new(new_image);
}



/**
 * Maps black and white to the specified points. The reverse of {Image#level_channel}.
 *
 * @overload levelize_channel(black_point, white_point = Magick::QuantumRange - black_point, gamma = 1.0, channel = Magick::AllChannels)
 *   @param black [Float] A black point level in the range 0..QuantumRange.
 *   @param white [Float] A white point level in the range 0..QuantumRange.
 *   @param gamma [Float] A gamma correction in the range 0.0 - 10.0.
 *
 * @overload levelize_channel(black_point, white_point = Magick::QuantumRange - black_point, gamma = 1.0, *channels)
 *   @param black [Float] A black point level in the range 0..QuantumRange.
 *   @param white [Float] A white point level in the range 0..QuantumRange.
 *   @param gamma [Float] A gamma correction in the range 0.0 - 10.0.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_levelize_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    ChannelType channels;
    double black_point, white_point;
    double gamma = 1.0;
    MagickBooleanType status;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);
    if (argc > 3)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    switch (argc)
    {
        case 3:
            gamma = NUM2DBL(argv[2]);
        case 2:
            white_point = NUM2DBL(argv[1]);
            black_point = NUM2DBL(argv[0]);
            break;
        case 1:
            black_point = NUM2DBL(argv[0]);
            white_point = QuantumRange - black_point;
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or more)", argc);
            break;
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BEGIN_CHANNEL_MASK(new_image, channels);
    status = LevelizeImage(new_image, black_point, white_point, gamma, exception);
    END_CHANNEL_MASK(new_image);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    status = LevelizeImageChannel(new_image, channels, black_point, white_point, gamma);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    if (!status)
    {
        rb_raise(rb_eRuntimeError, "LevelizeImageChannel failed for unknown reason.");
    }
    return rm_image_new(new_image);
}


/**
 * Linear with saturation stretch.
 *
 * @overload linear_stretch(black_point, white_point = pixels - black_point)
 *   @param black_point [Float, String] black out at most this many pixels.
 *     Specify an absolute number of pixels as a numeric value, or a percentage as a string in the
 *     form 'NN%'.
 *   @param white_point [Float, String] burn at most this many pixels.
 *     Specify an absolute number of pixels as a numeric value, or a percentage as a string in the
 *     form 'NN%'.
 *     This argument is optional. If not specified the default is `(columns * rows) - black_point`.
 *   @return [Magick::Image] a new image
 *   @see Image#contrast_stretch_channel
 */
VALUE
Image_linear_stretch(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double black_point, white_point;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    get_black_white_point(image, argc, argv, &black_point, &white_point);
    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    LinearStretchImage(new_image, black_point, white_point, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    LinearStretchImage(new_image, black_point, white_point);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Rescale image with seam carving.
 *
 * @overload liquid_rescale(columns, rows, delta_x = 0.0, rigidity = 0.0)
 *   @param columns [Numeric] The desired width height. Should not exceed 200% of the original
 *     dimension.
 *   @param rows [Numeric] The desired height. Should not exceed 200% of the original dimension.
 *   @param delta_x [Float] Maximum seam transversal step (0 means straight seams).
 *   @param rigidity [Float] Introduce a bias for non-straight seams (typically 0).
 *   @return [Magick::Image] a new image
 */
VALUE
Image_liquid_rescale(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    unsigned long cols, rows;
    double delta_x = 0.0;
    double rigidity = 0.0;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 4:
            rigidity = NUM2DBL(argv[3]);
        case 3:
            delta_x = NUM2DBL(argv[2]);
        case 2:
            rows = NUM2ULONG(argv[1]);
            cols = NUM2ULONG(argv[0]);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 to 4)", argc);
            break;
    }

    exception = AcquireExceptionInfo();
    new_image = LiquidRescaleImage(image, cols, rows, delta_x, rigidity, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Implement marshalling.
 *
 * @param str [String] the marshalled string
 * @return [Magic::Image] a new image
 * @see Image#_dump
 */
VALUE
Image__load(VALUE class ATTRIBUTE_UNUSED, VALUE str)
{
    Image *image;
    ImageInfo *info;
    DumpedImage mi;
    ExceptionInfo *exception;
    char *blob;
    long length;

    blob = rm_str2cstr(str, &length);

    // Must be as least as big as the 1st 4 fields in DumpedImage
    if (length <= (long)(sizeof(DumpedImage)-MaxTextExtent))
    {
        rb_raise(rb_eTypeError, "image is invalid or corrupted (too short)");
    }

    // Retrieve & validate the image format from the header portion
    mi.id = ((DumpedImage *)blob)->id;
    if (mi.id != DUMPED_IMAGE_ID)
    {
        rb_raise(rb_eTypeError, "image is invalid or corrupted (invalid header)");
    }

    mi.mj = ((DumpedImage *)blob)->mj;
    mi.mi = ((DumpedImage *)blob)->mi;
    if (   mi.mj != DUMPED_IMAGE_MAJOR_VERS
           || mi.mi > DUMPED_IMAGE_MINOR_VERS)
    {
        rb_raise(rb_eTypeError, "incompatible image format (can't be read)\n"
                 "\tformat version %d.%d required; %d.%d given",
                 DUMPED_IMAGE_MAJOR_VERS, DUMPED_IMAGE_MINOR_VERS,
                 mi.mj, mi.mi);
    }

    mi.len = ((DumpedImage *)blob)->len;

    // Must be bigger than the header
    if (length <= (long)(mi.len+sizeof(DumpedImage)-MaxTextExtent))
    {
        rb_raise(rb_eTypeError, "image is invalid or corrupted (too short)");
    }

    info = CloneImageInfo(NULL);

    memcpy(info->magick, ((DumpedImage *)blob)->magick, mi.len);
    info->magick[mi.len] = '\0';

    exception = AcquireExceptionInfo();

    blob += offsetof(DumpedImage, magick) + mi.len;
    length -= offsetof(DumpedImage, magick) + mi.len;
    image = BlobToImage(info, blob, (size_t) length, exception);
    DestroyImageInfo(info);

    rm_check_exception(exception, image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(image);
}


/**
 * Scale an image proportionally to twice its size.
 *
 * No Ruby usage (internal function)
 *
 * @param bang whether the bang (!) version of the method was called
 * @param self this object
 * @param magnifier function to use for magnification
 * @return self if bang, otherwise a new image
 */
static VALUE
magnify(int bang, VALUE self, magnifier_t magnifier)
{
    Image *image;
    Image *new_image;
    ExceptionInfo *exception;

    Data_Get_Struct(self, Image, image);
    exception = AcquireExceptionInfo();

    new_image = (magnifier)(image, exception);
    rm_check_exception(exception, new_image, DestroyOnError);

    DestroyExceptionInfo(exception);

    if (bang)
    {
        rm_ensure_result(new_image);
        UPDATE_DATA_PTR(self, new_image);
        rm_image_destroy(image);
        return self;
    }

    return rm_image_new(new_image);
}


/**
 * Scale an image proportionally to twice its size.
 *
 * @return [Magick::Image] a new image
 * @see Image#magnify!
 */
VALUE
Image_magnify(VALUE self)
{
    rm_check_destroyed(self);
    return magnify(False, self, MagnifyImage);
}


/**
 * Scale an image proportionally to twice its size.
 * In-place form of {Image#magnify}.
 *
 * @return [Magick::Image] self
 * @see Image#magnify
 */
VALUE
Image_magnify_bang(VALUE self)
{
    rm_check_frozen(self);
    return magnify(True, self, MagnifyImage);
}


/**
 * Support Marshal.dump.
 *
 * @return [Array<String>] The first element in the array is the file name. The second element is the string
 *   of blob.
 */
VALUE
Image_marshal_dump(VALUE self)
{
    Image *image;
    Info *info;
    unsigned char *blob;
    size_t length;
    VALUE ary;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    info = CloneImageInfo(NULL);
    if (!info)
    {
        rb_raise(rb_eNoMemError, "not enough memory to initialize Info object");
    }

    ary = rb_ary_new2(2);
    rb_ary_store(ary, 0, rb_str_new2(image->filename));

    exception = AcquireExceptionInfo();
    blob = ImageToBlob(info, image, &length, exception);

    // Destroy info before raising an exception
    DestroyImageInfo(info);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);

    rb_ary_store(ary, 1, rb_str_new((char *)blob, (long)length));
    magick_free((void*)blob);

    return ary;
}


/**
 * Support Marshal.load.
 *
 * @param ary [Array<String>] the array returned from {Image#marshal_dump}
 * @return self
 */
VALUE
Image_marshal_load(VALUE self, VALUE ary)
{
    VALUE blob, filename;
    Info *info;
    Image *image;
    ExceptionInfo *exception;

    info = CloneImageInfo(NULL);
    if (!info)
    {
        rb_raise(rb_eNoMemError, "not enough memory to initialize Info object");
    }

    filename = rb_ary_shift(ary);
    blob = rb_ary_shift(ary);

    filename = StringValue(filename);
    blob = StringValue(blob);

    exception = AcquireExceptionInfo();
    if (filename != Qnil)
    {
        strlcpy(info->filename, RSTRING_PTR(filename), sizeof(info->filename));
    }
    image = BlobToImage(info, RSTRING_PTR(blob), RSTRING_LEN(blob), exception);

    // Destroy info before raising an exception
    DestroyImageInfo(info);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);

    UPDATE_DATA_PTR(self, image);

    return self;
}

/**
 * Return the image's clip mask, or nil if it doesn't have a clip mask.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Distinguish from Image#clip_mask
 *
 * @param image the image
 * @return copy of the current clip-mask or nil
 */
static VALUE
get_image_mask(Image *image)
{
    Image *mask;
    ExceptionInfo *exception;

    exception = AcquireExceptionInfo();

    // The returned clip mask is a clone, ours to keep.
#if defined(IMAGEMAGICK_7)
    mask = GetImageMask(image, WritePixelMask, exception);
#else
    mask = GetImageClipMask(image, exception);
#endif
    rm_check_exception(exception, mask, DestroyOnError);

    DestroyExceptionInfo(exception);

    return mask ? rm_image_new(mask) : Qnil;
}

/**
 * Associate a mask with the image.
 *
 * No Ruby usage (internal function)
 *
 * @param image the image
 * @param mask the mask
 * @return copy of the current clip-mask or nil
 * @see get_image_mask
 */
#if defined(IMAGEMAGICK_7)
static VALUE
set_image_mask(Image *image, VALUE mask)
{
    Image *mask_image, *resized_image;
    Image *clip_mask;
    ExceptionInfo *exception;

    exception = AcquireExceptionInfo();

    if (mask != Qnil)
    {
        mask = rm_cur_image(mask);
        mask_image = rm_check_destroyed(mask);
        clip_mask = rm_clone_image(mask_image);

        // Resize if necessary
        if (clip_mask->columns != image->columns || clip_mask->rows != image->rows)
        {
            resized_image = ResizeImage(clip_mask, image->columns, image->rows, image->filter, exception);
            DestroyImage(clip_mask);
            rm_check_exception(exception, resized_image, DestroyOnError);
            rm_ensure_result(resized_image);
            clip_mask = resized_image;
        }

        SetImageMask(image, WritePixelMask, clip_mask, exception);
        DestroyImage(clip_mask);
    }
    else
    {
        SetImageMask(image, WritePixelMask, NULL, exception);
    }
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);

    // Always return a copy of the mask!
    return get_image_mask(image);
}
#else
static VALUE
set_image_mask(Image *image, VALUE mask)
{
    Image *mask_image, *resized_image;
    Image *clip_mask;
    long x, y;
    PixelPacket *q;
    ExceptionInfo *exception;

    if (mask != Qnil)
    {
        mask = rm_cur_image(mask);
        mask_image = rm_check_destroyed(mask);
        clip_mask = rm_clone_image(mask_image);

        // Resize if necessary
        if (clip_mask->columns != image->columns || clip_mask->rows != image->rows)
        {
            exception = AcquireExceptionInfo();
            resized_image = ResizeImage(clip_mask, image->columns, image->rows,
                                        UndefinedFilter, 0.0, exception);
            rm_check_exception(exception, resized_image, DestroyOnError);
            DestroyExceptionInfo(exception);
            rm_ensure_result(resized_image);
            DestroyImage(clip_mask);
            clip_mask = resized_image;
        }

        // The following section is copied from mogrify.c (6.2.8-8)
        exception = AcquireExceptionInfo();

        for (y = 0; y < (long) clip_mask->rows; y++)
        {
            q = GetAuthenticPixels(clip_mask, 0, y, clip_mask->columns, 1, exception);
            rm_check_exception(exception, clip_mask, DestroyOnError);

            if (!q)
            {
                break;
            }
            for (x = 0; x < (long) clip_mask->columns; x++)
            {
                if (clip_mask->matte == MagickFalse)
                {
                    q->opacity = PIXEL_INTENSITY(q);
                }
                q->red = q->opacity;
                q->green = q->opacity;
                q->blue = q->opacity;
                q += 1;
            }

            SyncAuthenticPixels(clip_mask, exception);
            rm_check_exception(exception, clip_mask, DestroyOnError);
        }
        DestroyExceptionInfo(exception);

        SetImageStorageClass(clip_mask, DirectClass);
        rm_check_image_exception(clip_mask, DestroyOnError);

        clip_mask->matte = MagickTrue;

        // SetImageClipMask clones the clip_mask image. We can
        // destroy our copy after SetImageClipMask is done with it.

        SetImageClipMask(image, clip_mask);
        DestroyImage(clip_mask);
    }
    else
    {
        SetImageClipMask(image, NULL);
    }

    RB_GC_GUARD(mask);

    // Always return a copy of the mask!
    return get_image_mask(image);
}
#endif


/**
 * Get/Sets an image clip mask created from the specified mask image.
 * The mask image must have the same dimensions as the image being masked.
 * If not, the mask image is resized to match. If the mask image has an alpha channel the opacity of
 * each pixel is used to define the mask. Otherwise, the intensity (gray level) of each pixel is
 * used.
 *
 * In general, if the mask image does not have an alpha channel, a white pixel in the mask prevents
 * changes to the corresponding pixel in the image being masked, while a black pixel allows changes.
 * A pixel that is neither black nor white will allow partial changes depending on its intensity.
 *
 * @overload mask()
 *   Get an image clip mask.
 *
 * @overload mask(image)
 *   Set an image clip mask.
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *
 * @return [Magick::Image] the mask image
 */
VALUE
Image_mask(int argc, VALUE *argv, VALUE self)
{
    VALUE mask;
    Image *image;

    image = rm_check_destroyed(self);
    if (argc == 0)
    {
        return get_image_mask(image);
    }
    if (argc > 1)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (expected 0 or 1, got %d)", argc);
    }

    rb_check_frozen(self);
    mask = argv[0];
    return set_image_mask(image, mask);
}


/**
 * Return the matte color.
 *
 * @return [String] the matte color
 */
VALUE
Image_matte_color(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return rm_pixelcolor_to_color_name(image, &image->matte_color);
}

/**
 * Set the matte color.
 *
 * @param color [Magick::Pixel, String] the matte color
 * @return [Magick::Pixel, String] the given color
 */
VALUE
Image_matte_color_eq(VALUE self, VALUE color)
{
    Image *image = rm_check_frozen(self);
    Color_to_PixelColor(&image->matte_color, color);
    return color;
}


/**
 * Makes transparent all the pixels that are the same color as the pixel at x, y, and are neighbors.
 *
 * @overload Image#matte_flood_fill(color, x, y, method_obj, alpha:)
 *   @param color [Magick::Pixel, String] the color name
 *   @param x_obj [Numeric] x position
 *   @param y_obj [Numeric] y position
 *   @param method_obj [Magick::PaintMethod] which method to call: FloodfillMethod or FillToBorderMethod
 *   @param alpha [Numeric] the alpha
 *   @return [Magick::Image] a new image
 */
VALUE
Image_matte_flood_fill(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    PixelColor target;
    Quantum alpha;
    long x, y;
    PaintMethod method;
    DrawInfo *draw_info;
    MagickPixel target_mpp;
    MagickBooleanType invert;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

    if (argc != 5)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 5)", argc);
    }

    alpha = get_named_alpha_value(argv[4]);

    Color_to_PixelColor(&target, argv[0]);
    VALUE_TO_ENUM(argv[3], method, PaintMethod);
    if (!(method == FloodfillMethod || method == FillToBorderMethod))
    {
        rb_raise(rb_eArgError, "paint method_obj must be FloodfillMethod or "
                 "FillToBorderMethod (%d given)", method);
    }
    x = NUM2LONG(argv[1]);
    y = NUM2LONG(argv[2]);
    if ((unsigned long)x > image->columns || (unsigned long)y > image->rows)
    {
        rb_raise(rb_eArgError, "target out of range. %ldx%ld given, image is %"RMIuSIZE"x%"RMIuSIZE"",
                 x, y, image->columns, image->rows);
    }


    new_image = rm_clone_image(image);

    // FloodfillPaintImage looks for the opacity in the DrawInfo.fill field.
    draw_info = CloneDrawInfo(NULL, NULL);
    if (!draw_info)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }
#if defined(IMAGEMAGICK_7)
    rm_set_pixelinfo_alpha(&draw_info->fill, alpha);
#else
    draw_info->fill.opacity = QuantumRange - alpha;
#endif

    if (method == FillToBorderMethod)
    {
        invert = MagickTrue;
        target_mpp.red   = (MagickRealType) image->border_color.red;
        target_mpp.green = (MagickRealType) image->border_color.green;
        target_mpp.blue  = (MagickRealType) image->border_color.blue;
#if defined(IMAGEMAGICK_7)
        rm_set_pixelinfo_alpha(&target_mpp, (MagickRealType) image->border_color.alpha);
#else
        target_mpp.opacity = (MagickRealType) image->border_color.opacity;
#endif
    }
    else
    {
        invert = MagickFalse;
        target_mpp.red   = (MagickRealType) target.red;
        target_mpp.green = (MagickRealType) target.green;
        target_mpp.blue  = (MagickRealType) target.blue;
#if defined(IMAGEMAGICK_7)
        rm_set_pixelinfo_alpha(&target_mpp, (MagickRealType) target.alpha);
#else
        target_mpp.opacity = (MagickRealType) target.opacity;
#endif
    }

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BEGIN_CHANNEL_MASK(new_image, OpacityChannel);
    FloodfillPaintImage(new_image, draw_info, &target_mpp, x, y, invert, exception);
    END_CHANNEL_MASK(new_image);
    DestroyDrawInfo(draw_info);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    FloodfillPaintImage(new_image, OpacityChannel, draw_info, &target_mpp, x, y, invert);
    DestroyDrawInfo(draw_info);

    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Apply a digital filter that improves the quality of a noisy image. Each pixel is replaced by the
 * median in a set of neighboring pixels as defined by radius.
 *
 * @overload median_filter(radius = 0.0)
 *   @param radius [Numeric] The filter radius.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_median_filter(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double radius = 0.0;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 1:
            radius = NUM2DBL(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
            break;
    }

    exception = AcquireExceptionInfo();
    new_image = StatisticImage(image, MedianStatistic, (size_t)radius, (size_t)radius, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Get the mean error per pixel computed when a image is color reduced.
 *
 * @return [Float] the mean error per pixel
 */
VALUE
Image_mean_error_per_pixel(VALUE self)
{
    IMPLEMENT_ATTR_READERF(Image, mean_error_per_pixel, error.mean_error_per_pixel, dbl);
}


/**
 * Return the officially registered (or de facto) MIME media-type corresponding to the image format.
 *
 * @return [String, nil] the mime type
 */
VALUE
Image_mime_type(VALUE self)
{
    Image *image;
    char *type;
    VALUE mime_type;

    image = rm_check_destroyed(self);
    type = MagickToMime(image->magick);
    if (!type)
    {
        return Qnil;
    }
    mime_type = rb_str_new2(type);

    // The returned string must be deallocated by the user.
    magick_free(type);

    RB_GC_GUARD(mime_type);

    return mime_type;
}


/**
 * Scale an image proportionally to half its size.
 *
 * @return [Magick::Image] a new image
 * @see Image#minify!
 */
VALUE
Image_minify(VALUE self)
{
    rm_check_destroyed(self);
    return magnify(False, self, MinifyImage);
}


/**
 * Scale an image proportionally to half its size.  In-place form of {Image#minify}.
 *
 * @return [Magick::Image] self
 * @see Image#minify
 */
VALUE
Image_minify_bang(VALUE self)
{
    rm_check_frozen(self);
    return magnify(True, self, MinifyImage);
}


/**
 * Changes the brightness, saturation, and hue.
 *
 * @overload modulate(brightness = 1.0, saturation = 1.0, hue = 1.0)
 *   @param brightness [Float] The percent change in the brightness
 *   @param saturation [Float] The percent change in the saturation
 *   @param hue [Float] The percent change in the hue
 *   @return [Magick::Image] a new image
 */
VALUE
Image_modulate(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double pct_brightness = 100.0,
    pct_saturation = 100.0,
    pct_hue        = 100.0;
    char modulate[100];
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 3:
            pct_hue        = 100*NUM2DBL(argv[2]);
        case 2:
            pct_saturation = 100*NUM2DBL(argv[1]);
        case 1:
            pct_brightness = 100*NUM2DBL(argv[0]);
            break;
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 3)", argc);
            break;
    }

    if (pct_brightness <= 0.0)
    {
        rb_raise(rb_eArgError, "brightness is %g%%, must be positive", pct_brightness);
    }
    snprintf(modulate, sizeof(modulate), "%f%%,%f%%,%f%%", pct_brightness, pct_saturation, pct_hue);

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    ModulateImage(new_image, modulate, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    ModulateImage(new_image, modulate);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Establish a progress monitor.
 *
 * - A progress monitor is a callable object. Save the monitor proc as the client_data and establish
 *   `progress_monitor' as the monitor exit. When `progress_monitor' is called, retrieve the proc
 *   and call it.
 *
 * @param monitor [Proc] the progress monitor
 * @return [Proc] the given value
 * @example
 *   img.monitor = Proc.new do |method, offset, span|
 *     print "%s is %3.0f%% complete.\n", method, (offset.to_f/span)*100)
 *     true
 *   end
 */
VALUE
Image_monitor_eq(VALUE self, VALUE monitor)
{
    Image *image = rm_check_frozen(self);

    if (NIL_P(monitor))
    {
        image->progress_monitor = NULL;
    }
    else
    {
        SetImageProgressMonitor(image, rm_progress_monitor, (void *)monitor);
    }

    return monitor;
}


/**
 * Return true if all the pixels in the image have the same red, green, and blue intensities and the
 * intensity is either 0 or {Magick::QuantumRange}.
 *
 * @return [Boolean] true if monochrome, false otherwise
 */
VALUE
Image_monochrome_q(VALUE self)
{
#if defined(IMAGEMAGICK_7)
    return has_image_attribute(self, IsImageMonochrome);
#else
    return has_attribute(self, IsMonochromeImage);
#endif
}


/**
 * Tile size and offset within an image montage. Only valid for montage images.
 *
 * @return [String] the tile size and offset
 */
VALUE
Image_montage(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, montage, str);
}


/**
 * Called from Image_motion_blur and Image_sketch.
 *
 * No Ruby usage (internal function)
 *
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @param fp the blur function to call
 * @return a new image
 * @see Image_motion_blur
 * @see Image_sketch
 */
static VALUE
motion_blur(int argc, VALUE *argv, VALUE self,
            Image *fp(const Image *, const double, const double, const double, ExceptionInfo *))
{
    Image *image, *new_image;
    double radius = 0.0;
    double sigma = 1.0;
    double angle = 0.0;
    ExceptionInfo *exception;

    switch (argc)
    {
        case 3:
            angle = NUM2DBL(argv[2]);
        case 2:
            sigma = NUM2DBL(argv[1]);
        case 1:
            radius = NUM2DBL(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 to 3)", argc);
            break;
    }

    if (sigma == 0.0)
    {
        rb_raise(rb_eArgError, "sigma must be != 0.0");
    }

    Data_Get_Struct(self, Image, image);

    exception = AcquireExceptionInfo();
    new_image = (fp)(image, radius, sigma, angle, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Simulate motion blur. Convolve the image with a Gaussian operator of the given radius and
 * standard deviation (sigma). For reasonable results, radius should be larger than sigma. Use a
 * radius of 0 and motion_blur selects a suitable radius for you. Angle gives the angle of the
 * blurring motion.
 *
 * @overload motion_blur(radius = 0.0, sigma = 1.0, angle = 0.0)
 *   @param radius [Float] The radius
 *   @param sigma [Float] The standard deviation
 *   @param angle [Float] The angle (in degrees)
 *   @return [Magick::Image] a new image
 */
VALUE
Image_motion_blur(int argc, VALUE *argv, VALUE self)
{
    rm_check_destroyed(self);
    return motion_blur(argc, argv, self, MotionBlurImage);
}


/**
 * Negate the colors in the reference image. The grayscale option means that only grayscale values
 * within the image are negated.
 *
 * @overload negate(grayscale = false)
 *   @param grayscale [Boolean] If the grayscale argument is true, only the grayscale values are negated.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_negate(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    unsigned int grayscale = MagickFalse;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    if (argc == 1)
    {
        grayscale = RTEST(argv[0]);
    }
    else if (argc > 1)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    NegateImage(new_image, grayscale, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    NegateImage(new_image, grayscale);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Negate the colors on a particular channel. The grayscale option means that
 * only grayscale values within the image are negated.
 *
 * @overload negate_channel(grayscale = false, channel = Magick::AllChannels)
 *   @param grayscale [Boolean] If the grayscale argument is true, only the grayscale values are
 *     negated.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload negate_channel(grayscale = false, *channels)
 *   @param grayscale [Boolean] If the grayscale argument is true, only the grayscale values are
 *     negated.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_negate_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    ChannelType channels;
    unsigned int grayscale = MagickFalse;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);

    // There can be at most 1 remaining argument.
    if (argc > 1)
    {
        raise_ChannelType_error(argv[argc-1]);
    }
    else if (argc == 1)
    {
        grayscale = RTEST(argv[0]);
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BEGIN_CHANNEL_MASK(new_image, channels);
    NegateImage(new_image, grayscale, exception);
    END_CHANNEL_MASK(new_image);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    NegateImageChannel(new_image, channels, grayscale);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * "Allocate" a new Image object
 *
 * @return [Magick::Image] a newly allocated image
 */
VALUE
Image_alloc(VALUE class)
{
    VALUE image_obj;

    image_obj = Data_Wrap_Struct(class, NULL, rm_image_destroy, NULL);

    RB_GC_GUARD(image_obj);

    return image_obj;
}

/**
 * Initialize a new Image object If the fill argument is omitted, fill with background color.
 *
 * @overload initialize(cols, rows, fill = nil)
 *   @param cols [Numeric] the image width
 *   @param rows [Numeric] the image height
 *   @param fill [Magick::HatchFill, Magick::SolidFill] if object is given as fill argument,
 *     background color will be filled using it.
 *   @return [Magick::Image] self
 */
VALUE
Image_initialize(int argc, VALUE *argv, VALUE self)
{
    VALUE fill = Qnil;
    Info *info;
    VALUE info_obj;
    Image *image;
    unsigned long cols, rows;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    switch (argc)
    {
        case 3:
            fill = argv[2];
        case 2:
            rows = NUM2ULONG(argv[1]);
            cols = NUM2ULONG(argv[0]);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 or 3)", argc);
            break;
    }

    // Create a new Info object to use when creating this image.
    info_obj = rm_info_new();
    Data_Get_Struct(info_obj, Info, info);

    image = rm_acquire_image(info);
    if (!image)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }

    rm_set_user_artifact(image, info);

    // NOW store a real image in the image object.
    UPDATE_DATA_PTR(self, image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    SetImageExtent(image, cols, rows, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    SetImageExtent(image, cols, rows);
#endif

    // If the caller did not supply a fill argument, call SetImageBackgroundColor
    // to fill the image using the background color. The background color can
    // be set by specifying it when creating the Info parm block.
    if (NIL_P(fill))
    {
#if defined(IMAGEMAGICK_7)
        exception = AcquireExceptionInfo();
        SetImageBackgroundColor(image, exception);
        CHECK_EXCEPTION();
        DestroyExceptionInfo(exception);
#else
        SetImageBackgroundColor(image);
#endif
    }
    // fillobj.fill(self)
    else
    {
        rb_funcall(fill, rm_ID_fill, 1, self);
    }

    RB_GC_GUARD(fill);
    RB_GC_GUARD(info_obj);

    return self;
}


/**
 * Create a new Image object from an Image structure.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Since the Image is already created we don't need to call Image_alloc or
 *     Image_initialize.
 *
 * @param image the Image structure
 * @return a new image
 */
VALUE
rm_image_new(Image *image)
{
    rm_ensure_result(image);

    rm_trace_creation(image);

    return Data_Wrap_Struct(Class_Image, NULL, rm_image_destroy, image);
}


/**
 * Enhance the contrast of a color image by adjusting the pixels color to span the entire range of
 * colors available.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_normalize(VALUE self)
{
    Image *image, *new_image;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    NormalizeImage(new_image, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    NormalizeImage(new_image);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Enhances the contrast of a color image by adjusting the pixel color to span the entire range of
 * colors available. Only the specified channels are normalized.
 *
 * @overload normalize_channel(channel = Magick::AllChannels)
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_normalize_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    ChannelType channels;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);
    // Ensure all arguments consumed.
    if (argc > 0)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BEGIN_CHANNEL_MASK(new_image, channels);
    NormalizeImage(new_image, exception);
    END_CHANNEL_MASK(new_image);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    NormalizeImageChannel(new_image, channels);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Get the normalized mean error per pixel computed when an image is color reduced.
 *
 * @return [Float] the normalized mean error
 */
VALUE
Image_normalized_mean_error(VALUE self)
{
    IMPLEMENT_ATTR_READERF(Image, normalized_mean_error, error.normalized_mean_error, dbl);
}

/**
 * Get The normalized maximum error per pixel computed when an image is color reduced.
 *
 * @return [Float] the normalized maximum error
 */
VALUE
Image_normalized_maximum_error(VALUE self)
{
    IMPLEMENT_ATTR_READERF(Image, normalized_maximum_error, error.normalized_maximum_error, dbl);
}


/**
 * Return the number of unique colors in the image.
 *
 * @return [Numeric] number of unique colors
 */
VALUE
Image_number_colors(VALUE self)
{
    Image *image;
    ExceptionInfo *exception;
    unsigned long n = 0;

    image = rm_check_destroyed(self);
    exception = AcquireExceptionInfo();

    n = (unsigned long) GetNumberColors(image, NULL, exception);
    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    return ULONG2NUM(n);
}


/**
 * Get the number of bytes to skip over when reading raw image.
 *
 * @return [Number] the offset
 */
VALUE
Image_offset(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, offset, long);
}

/**
 * Set the number of bytes to skip over when reading raw image.
 *
 * @param val [Number] the offset
 * @return [Number] the given offset
 */
VALUE
Image_offset_eq(VALUE self, VALUE val)
{
    IMPLEMENT_ATTR_WRITER(Image, offset, long);
}


/**
 * Apply a special effect filter that simulates an oil painting.
 *
 * @overload oil_paint(radius = 3.0)
 *   @param radius [Float] The radius of the Gaussian in pixels.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_oil_paint(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double radius = 3.0;
    ExceptionInfo *exception;
#if defined(IMAGEMAGICK_7)
    double sigma = 1.0;
#endif

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 1:
            radius = NUM2DBL(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
            break;
    }

    exception = AcquireExceptionInfo();

#if defined(IMAGEMAGICK_7)
    new_image = OilPaintImage(image, radius, sigma, exception);
#else
    new_image = OilPaintImage(image, radius, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Change any pixel that matches target with the color defined by fill.
 *
 *  - By default a pixel must match the specified target color exactly.
 *  - Use {Image#fuzz=} to set the amount of tolerance acceptable to consider two colors as the
 *    same.
 *
 * @param target [Magick::Pixel, String] the color name
 * @param fill [Magick::Pixel, String] the color for filling
 * @return [Magick::Image] a new image
 * @see Image#fuzz=
 */
VALUE
Image_opaque(VALUE self, VALUE target, VALUE fill)
{
    Image *image, *new_image;
    MagickPixel target_pp;
    MagickPixel fill_pp;
    MagickBooleanType okay;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

    // Allow color name or Pixel
    Color_to_MagickPixel(image, &target_pp, target);
    Color_to_MagickPixel(image, &fill_pp, fill);

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    okay = OpaquePaintImage(new_image, &target_pp, &fill_pp, MagickFalse, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    okay = OpaquePaintImageChannel(new_image, DefaultChannels, &target_pp, &fill_pp, MagickFalse);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    if (!okay)
    {
        // Force exception
        DestroyImage(new_image);
        rm_ensure_result(NULL);
    }

    return rm_image_new(new_image);
}


/**
 * Changes all pixels having the target color to the fill color.
 * If invert is true, changes all the pixels that are not the target color to the fill color.
 *
 * @overload opaque_channel(target, fill, invert = false, fuzz = self.fuzz, channel = Magick::AllChannels)
 *   @param target [Magick::Pixel, String] the color name
 *   @param fill [Magick::Pixel, String] the color for filling
 *   @param invert [Boolean] If true, the target pixels are all the pixels that are not the target
 *     color. The default is the value of the target image's fuzz attribute
 *   @param fuzz [Float] Colors within this distance are considered equal to the target color.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload opaque_channel(target, fill, invert, fuzz, *channels)
 *   @param target [Magick::Pixel, String] the color name
 *   @param fill [Magick::Pixel, String] the color for filling
 *   @param invert [Boolean] If true, the target pixels are all the pixels that are not the target
 *     color. The default is the value of the target image's fuzz attribute
 *   @param fuzz [Float] Colors within this distance are considered equal to the target color.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_opaque_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    MagickPixel target_pp, fill_pp;
    ChannelType channels;
    double keep, fuzz;
    MagickBooleanType okay, invert = MagickFalse;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);
    if (argc > 4)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    // Default fuzz value is image's fuzz attribute.
    fuzz = image->fuzz;

    switch (argc)
    {
        case 4:
            fuzz = NUM2DBL(argv[3]);
            if (fuzz < 0.0)
            {
                rb_raise(rb_eArgError, "fuzz must be >= 0.0 (%g given)", fuzz);
            }
        case 3:
            invert = RTEST(argv[2]);
        case 2:
            // Allow color name or Pixel
            Color_to_MagickPixel(image, &fill_pp, argv[1]);
            Color_to_MagickPixel(image, &target_pp, argv[0]);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (got %d, expected 2 or more)", argc);
            break;
    }

    new_image = rm_clone_image(image);
    keep = new_image->fuzz;
    new_image->fuzz = fuzz;

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BEGIN_CHANNEL_MASK(new_image, channels);
    okay = OpaquePaintImage(new_image, &target_pp, &fill_pp, invert, exception);
    END_CHANNEL_MASK(new_image);
    new_image->fuzz = keep;
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    okay = OpaquePaintImageChannel(new_image, channels, &target_pp, &fill_pp, invert);

    new_image->fuzz = keep;
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    if (!okay)
    {
        // Force exception
        DestroyImage(new_image);
        rm_ensure_result(NULL);
    }

    return rm_image_new(new_image);
}


/**
 * Returns true if all of the pixels in the receiver have an opacity value of OpaqueOpacity.
 *
 * @return [Boolean] true if opaque, false otherwise
 */
VALUE
Image_opaque_q(VALUE self)
{
#if defined(IMAGEMAGICK_7)
    return has_attribute(self, IsImageOpaque);
#else
    return has_attribute(self, IsOpaqueImage);
#endif
}


/**
 * Dithers the image to a predefined pattern. The threshold_map argument defines the pattern to use.
 *
 * - Default threshold_map is '2x2'
 * - Order of threshold_map must be 2, 3, or 4.
 *
 * @overload ordered_dither(threshold_map = '2x2')
 *   @param threshold_map [String, Numeric] the threshold
 *   @return [Magick::Image] a new image
 */
VALUE
Image_ordered_dither(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    int order;
    const char *threshold_map = "2x2";
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    if (argc > 1)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
    }
    if (argc == 1)
    {
        if (TYPE(argv[0]) == T_STRING)
        {
            threshold_map = StringValueCStr(argv[0]);
        }
        else
        {
            order = NUM2INT(argv[0]);
            if (order == 3)
            {
                threshold_map = "3x3";
            }
            else if (order == 4)
            {
                threshold_map = "4x4";
            }
            else if (order != 2)
            {
                rb_raise(rb_eArgError, "order must be 2, 3, or 4 (%d given)", order);
            }
        }
    }

    new_image = rm_clone_image(image);

    exception = AcquireExceptionInfo();

    OrderedDitherImage(new_image, threshold_map, exception);
    rm_check_exception(exception, new_image, DestroyOnError);

    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Get the value of the Exif Orientation Tag.
 *
 * @return [Magick::OrientationType] the orientation
 */
VALUE
Image_orientation(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return OrientationType_find(image->orientation);
}


/**
 * Set the orientation attribute.
 *
 * @param orientation [Magick::OrientationType] the orientation
 * @return [Magick::OrientationType] the given value
 */
VALUE
Image_orientation_eq(VALUE self, VALUE orientation)
{
    Image *image = rm_check_frozen(self);
    VALUE_TO_ENUM(orientation, image->orientation, OrientationType);
    return orientation;
}


/**
 * The page attribute getter.
 *
 * @return [Magick::Rectang] the page rectangle
 */
VALUE
Image_page(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return Import_RectangleInfo(&image->page);
}


/**
 * The page attribute setter.
 *
 * @param rect [Magick::Rectang] the page rectangle
 * @return [Magick::Rectang] the given value
 */
VALUE
Image_page_eq(VALUE self, VALUE rect)
{
    Image *image = rm_check_frozen(self);
    Export_RectangleInfo(&image->page, rect);
    return rect;
}


/**
 * Changes the opacity value of all the pixels that match color to the value specified by opacity.
 * If invert is true, changes the pixels that don't match color.
 *
 * @overload paint_transparent(target, invert, fuzz, alpha: Magick::TransparentAlpha)
 *   @param target [Magick::Pixel, String] the color name
 *   @param invert [Boolean] If true, the target pixels are all the pixels that are not the target
 *     color.
 *   @param fuzz [Float] By default the pixel must match exactly, but you can specify a tolerance
 *     level by passing a positive value.
 *   @param alpha [Numeric] The new alpha value, either an alpha value or a number between 0 and
 *     QuantumRange. The default is TransparentAlpha.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_paint_transparent(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    MagickPixel color;
    Quantum alpha = TransparentAlpha;
    double keep, fuzz;
    MagickBooleanType okay, invert;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

    // Default fuzz value is image's fuzz attribute.
    fuzz = image->fuzz;
    invert = MagickFalse;

    switch (argc)
    {
        case 4:
            if (TYPE(argv[argc - 1]) == T_HASH)
            {
                fuzz = NUM2DBL(argv[2]);
            }
            else
            {
                fuzz = NUM2DBL(argv[3]);
            }
        case 3:
            if (TYPE(argv[argc - 1]) == T_HASH)
            {
                invert = RTEST(argv[1]);
            }
            else
            {
                invert = RTEST(argv[2]);
            }
        case 2:
            alpha = get_named_alpha_value(argv[argc - 1]);
        case 1:
            Color_to_MagickPixel(image, &color, argv[0]);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 to 4)", argc);
            break;
    }

    new_image = rm_clone_image(image);

    // Use fuzz value from caller
    keep = new_image->fuzz;
    new_image->fuzz = fuzz;

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    okay = TransparentPaintImage(new_image, (const MagickPixel *)&color, alpha, invert, exception);
    new_image->fuzz = keep;
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    okay = TransparentPaintImage(new_image, (const MagickPixel *)&color, QuantumRange - alpha, invert);
    new_image->fuzz = keep;

    // Is it possible for TransparentPaintImage to silently fail?
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    if (!okay)
    {
        // Force exception
        DestroyImage(new_image);
        rm_ensure_result(NULL);
    }

    return rm_image_new(new_image);
}


/**
 * Return true if the image is PseudoClass and has 256 unique colors or less.
 *
 * @return [Boolean] true if palette, otherwise false
 */
VALUE
Image_palette_q(VALUE self)
{
#if defined(IMAGEMAGICK_7)
    return has_image_attribute(self, IsPaletteImage);
#else
    return has_attribute(self, IsPaletteImage);
#endif
}


/**
 * Returns all the properties of an image or image sequence except for the pixels.
 *
 * @return [Array<Magick::Image>] an array of 1 or more new image objects (without pixel data)
 * @see Image#read
 */
VALUE
Image_ping(VALUE class, VALUE file_arg)
{
    return rd_image(class, file_arg, PingImage);
}


/**
 * Get/set the color of the pixel at x, y.
 *
 * @overload pixel_color(x, y)
 *   Get the color
 *   @param x [Numeric] The x-coordinates of the pixel.
 *   @param y [Numeric] The y-coordinates of the pixel.
 *   @return [Magick::Pixel] the pixel at x, y.
 *
 * @overload pixel_color(x, y, color)
 *   Set the color
 *   @param x [Numeric] The x-coordinates of the pixel.
 *   @param y [Numeric] The y-coordinates of the pixel.
 *   @param color [Magick::Pixel, String] the color
 *   @return [Magick::Pixel] the old color at x, y.
 */
VALUE
Image_pixel_color(int argc, VALUE *argv, VALUE self)
{
    Image *image;
    Pixel new_color;
    PixelPacket old_color;
    ExceptionInfo *exception;
    long x, y;
    unsigned int set = False;
    MagickBooleanType okay;
#if defined(IMAGEMAGICK_7)
    Quantum *pixel;
    const Quantum *old_pixel;
#else
    PixelPacket *pixel;
    const PixelPacket *old_pixel;
    MagickPixel mpp;
    IndexPacket *indexes;
#endif

    memset(&old_color, 0, sizeof(old_color));

    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 3:
            rb_check_frozen(self);
            set = True;
            // Replace with new color? The arg can be either a color name or
            // a Magick::Pixel.
            Color_to_Pixel(&new_color, argv[2]);
        case 2:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 or 3)", argc);
            break;
    }

    x = NUM2LONG(argv[0]);
    y = NUM2LONG(argv[1]);

    // Get the color of a pixel
    if (!set)
    {
        exception = AcquireExceptionInfo();
        old_pixel = GetVirtualPixels(image, x, y, 1, 1, exception);
        CHECK_EXCEPTION();

        DestroyExceptionInfo(exception);

#if defined(IMAGEMAGICK_7)
        old_color.red   = GetPixelRed(image, old_pixel);
        old_color.green = GetPixelGreen(image, old_pixel);
        old_color.blue  = GetPixelBlue(image, old_pixel);
        old_color.alpha = GetPixelAlpha(image, old_pixel);
        old_color.black = GetPixelBlack(image, old_pixel);
        return Pixel_from_PixelPacket(&old_color);
#else
        old_color = *old_pixel;
        indexes = GetAuthenticIndexQueue(image);
        // PseudoClass
        if (image->storage_class == PseudoClass)
        {
            old_color = image->colormap[(unsigned long)*indexes];
        }
        if (!image->matte)
        {
            old_color.opacity = OpaqueOpacity;
        }

        rm_init_magickpixel(image, &mpp);
        mpp.red = GetPixelRed(&old_color);
        mpp.green = GetPixelGreen(&old_color);
        mpp.blue = GetPixelBlue(&old_color);
        mpp.opacity = GetPixelOpacity(&old_color);
        if (indexes)
        {
            mpp.index = GetPixelIndex(indexes);
        }
        return Pixel_from_MagickPixel(&mpp);
#endif
    }

    // ImageMagick segfaults if the pixel location is out of bounds.
    // Do what IM does and return the background color.
    if (x < 0 || y < 0 || (unsigned long)x >= image->columns || (unsigned long)y >= image->rows)
    {
        return Pixel_from_PixelColor(&image->background_color);
    }

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
#endif

    if (image->storage_class == PseudoClass)
    {
#if defined(IMAGEMAGICK_7)
        okay = SetImageStorageClass(image, DirectClass, exception);
        CHECK_EXCEPTION();
        if (!okay)
        {
            DestroyExceptionInfo(exception);
            rb_raise(Class_ImageMagickError, "SetImageStorageClass failed. Can't set pixel color.");
        }
#else
        okay = SetImageStorageClass(image, DirectClass);
        rm_check_image_exception(image, RetainOnError);
        if (!okay)
        {
            rb_raise(Class_ImageMagickError, "SetImageStorageClass failed. Can't set pixel color.");
        }
#endif
    }

#if defined(IMAGEMAGICK_6)
    exception = AcquireExceptionInfo();
#endif

    pixel = GetAuthenticPixels(image, x, y, 1, 1, exception);
    CHECK_EXCEPTION();

    if (pixel)
    {
#if defined(IMAGEMAGICK_7)
        old_color.red   = GetPixelRed(image, pixel);
        old_color.green = GetPixelGreen(image, pixel);
        old_color.blue  = GetPixelBlue(image, pixel);
        old_color.alpha = GetPixelAlpha(image, pixel);
        old_color.black = GetPixelBlack(image, pixel);

        SetPixelRed(image,   new_color.red,   pixel);
        SetPixelGreen(image, new_color.green, pixel);
        SetPixelBlue(image,  new_color.blue,  pixel);
        SetPixelAlpha(image, new_color.alpha, pixel);
        SetPixelBlack(image, new_color.black, pixel);
#else
        old_color = *pixel;
        indexes = GetAuthenticIndexQueue(image);
        if (!image->matte)
        {
            old_color.opacity = OpaqueOpacity;
        }

        SetPixelRed(pixel,     new_color.red);
        SetPixelGreen(pixel,   new_color.green);
        SetPixelBlue(pixel,    new_color.blue);
        SetPixelOpacity(pixel, new_color.opacity);
        if (indexes)
        {
            SetPixelIndex(indexes, new_color.black);
        }
#endif

        SyncAuthenticPixels(image, exception);
        CHECK_EXCEPTION();
    }

    DestroyExceptionInfo(exception);

    return Pixel_from_PixelPacket(&old_color);
}


/**
 * Get the "interpolate" field.
 *
 * @return [Magick::PixelInterpolateMethod] the interpolate field
 * @see Image#pixel_interpolation_method=
 */
VALUE
Image_pixel_interpolation_method(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return PixelInterpolateMethod_find(image->interpolate);
}


/**
 * Set the "interpolate" field.
 *
 * @param method [Magick::PixelInterpolateMethod] the interpolate field
 * @return [Magick::PixelInterpolateMethod] the given method
 * @see Image#pixel_interpolation_method
 */
VALUE
Image_pixel_interpolation_method_eq(VALUE self, VALUE method)
{
    Image *image = rm_check_frozen(self);
    VALUE_TO_ENUM(method, image->interpolate, PixelInterpolateMethod);
    return method;
}


/**
 * Produce an image that looks like a Polaroid instant picture. If the image has a "Caption"
 * property, the value is used as a caption.
 *
 * The following annotate attributes control the label rendering:
 * align, decorate, density, encoding, fill, font, font_family, font_stretch, font_style,
 * font_weight, gravity, pointsize, stroke, stroke_width, text_antialias, undercolor.
 *
 * @overload polaroid(angle = -5.0)
 *   @param angle [Float] The resulting image is rotated by this amount, measured in degrees.
 *
 * @overload polaroid(angle = -5.0)
 *   If present a block, optional arguments may be specified in a block associated with the method.
 *   These arguments control the shadow color and how the label is rendered.
 *   By default the shadow color is gray75. To specify a different shadow color,
 *   use options.shadow_color.
 *   To specify a different border color (that is, the color of the image border) use options.border_color.
 *   Both of these methods accept either a color name or a Pixel argument.
 *   @param angle [Float] The resulting image is rotated by this amount, measured in degrees.
 *   @yield [Magick::Image::Info]
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_polaroid(int argc, VALUE *argv, VALUE self)
{
    Image *image, *clone, *new_image;
    VALUE options;
    double angle = -5.0;
    Draw *draw;
    ExceptionInfo *exception;
#if defined(IMAGEMAGICK_7)
    const char *caption;
#endif

    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 1:
            angle = NUM2DBL(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
            break;
    }

    options = rm_polaroid_new();
    Data_Get_Struct(options, Draw, draw);

    clone = rm_clone_image(image);
    clone->background_color = draw->shadow_color;
    clone->border_color = draw->info->border_color;

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    caption = GetImageProperty(clone, "Caption", exception);
    new_image = PolaroidImage(clone, draw->info, caption, angle, image->interpolate, exception);
#else
    new_image = PolaroidImage(clone, draw->info, angle, exception);
#endif
    rm_check_exception(exception, clone, DestroyOnError);

    DestroyImage(clone);
    DestroyExceptionInfo(exception);

    RB_GC_GUARD(options);

    return rm_image_new(new_image);
}


/**
 * Reduces the image to a limited number of colors for a "poster" effect.
 *
 * @overload posterize(levels = 4, dither = false)
 *   @param levels [Numeric] number of input arguments
 *   @param dither [Boolean] array of input arguments
 *   @return a new image
 */
VALUE
Image_posterize(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    MagickBooleanType dither = MagickFalse;
    unsigned long levels = 4;
#if defined(IMAGEMAGICK_7)
    DitherMethod dither_method;
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 2:
            dither = (MagickBooleanType) RTEST(argv[1]);
            /* fall through */
        case 1:
            levels = NUM2ULONG(argv[0]);
            /* fall through */
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 2)", argc);
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    dither_method = dither ? RiemersmaDitherMethod : NoDitherMethod;
    PosterizeImage(new_image, levels, dither_method, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    PosterizeImage(new_image, levels, dither);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Creates an image that contains 9 small versions of the receiver image. The center image is the
 * unchanged receiver. The other 8 images are variations created by transforming the receiver
 * according to the specified preview type with varying parameters.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_preview(VALUE self, VALUE preview)
{
    Image *image, *new_image;
    PreviewType preview_type;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    VALUE_TO_ENUM(preview, preview_type, PreviewType);

    exception = AcquireExceptionInfo();
    new_image = PreviewImage(image, preview_type, exception);
    rm_check_exception(exception, new_image, DestroyOnError);

    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Set the image profile. If "profile" is nil, deletes the profile. Otherwise "profile" must be a
 * string containing the specified profile.
 *
 * @param name [String] The profile name, or "*" to represent all the profiles in the image.
 * @param profile [String] The profile value, or nil to cause the profile to be removed.
 * @return [Magick::Image] self
 */
VALUE
Image_profile_bang(VALUE self, VALUE name, VALUE profile)
{

    if (profile == Qnil)
    {
        return Image_delete_profile(self, name);
    }
    else
    {
        return set_profile(self, StringValueCStr(name), profile);
    }

}


/**
 * Get image quality.
 *
 * @return [Numeric] the quality
 */
VALUE
Image_quality(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, quality, ulong);
}


/**
 * Return the image depth to the nearest Quantum (8, 16, or 32).
 *
 * @return [Numeric] image depth
 */
VALUE
Image_quantum_depth(VALUE self)
{
    Image *image;
    unsigned long quantum_depth;

    image = rm_check_destroyed(self);
    quantum_depth = GetImageQuantumDepth(image, MagickFalse);

    return ULONG2NUM(quantum_depth);
}


/**
 * Performs the requested integer arithmetic operation on the selected channel of the image.
 * This method allows simple arithmetic operations on the component values of all pixels in an
 * image.
 * Of course, you could also do this in Ruby using get_pixels and store_pixels, or view, but
 * quantum_operator will be faster, especially for large numbers of pixels, since it does not need
 * to convert the pixels from C to Ruby.
 *
 * @overload quantum_operator(operator, rvalue, channel = Magick::AllChannels)
 *   @param operator [Magick::QuantumExpressionOperator] the operator
 *   @param rvalue [Float] the operation rvalue.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload quantum_operator(operator, rvalue, *channels)
 *   @param operator [Magick::QuantumExpressionOperator] the operator
 *   @param rvalue [Float] the operation rvalue.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] self
 */
VALUE
Image_quantum_operator(int argc, VALUE *argv, VALUE self)
{
    Image *image;
    QuantumExpressionOperator operator;
    MagickEvaluateOperator qop;
    double rvalue;
    ChannelType channel;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    // The default channel is AllChannels
    channel = AllChannels;

    /*
        If there are 3 arguments, argument 2 is a ChannelType argument.
        Arguments 1 and 0 are required and are the rvalue and operator,
        respectively.
    */
    switch (argc)
    {
        case 3:
            VALUE_TO_ENUM(argv[2], channel, ChannelType);
            /* Fall through */
        case 2:
            rvalue = NUM2DBL(argv[1]);
            VALUE_TO_ENUM(argv[0], operator, QuantumExpressionOperator);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 or 3)", argc);
            break;
    }

    // Map QuantumExpressionOperator to MagickEvaluateOperator
    switch (operator)
    {
        default:
        case UndefinedQuantumOperator:
            qop = UndefinedEvaluateOperator;
            break;
        case AddQuantumOperator:
            qop = AddEvaluateOperator;
            break;
        case AndQuantumOperator:
            qop = AndEvaluateOperator;
            break;
        case DivideQuantumOperator:
            qop = DivideEvaluateOperator;
            break;
        case LShiftQuantumOperator:
            qop = LeftShiftEvaluateOperator;
            break;
        case MaxQuantumOperator:
            qop = MaxEvaluateOperator;
            break;
        case MinQuantumOperator:
            qop = MinEvaluateOperator;
            break;
        case MultiplyQuantumOperator:
            qop = MultiplyEvaluateOperator;
            break;
        case OrQuantumOperator:
            qop = OrEvaluateOperator;
            break;
        case RShiftQuantumOperator:
            qop = RightShiftEvaluateOperator;
            break;
        case SubtractQuantumOperator:
            qop = SubtractEvaluateOperator;
            break;
        case XorQuantumOperator:
            qop = XorEvaluateOperator;
            break;
        case PowQuantumOperator:
            qop = PowEvaluateOperator;
            break;
        case LogQuantumOperator:
            qop = LogEvaluateOperator;
            break;
        case ThresholdQuantumOperator:
            qop = ThresholdEvaluateOperator;
            break;
        case ThresholdBlackQuantumOperator:
            qop = ThresholdBlackEvaluateOperator;
            break;
        case ThresholdWhiteQuantumOperator:
            qop = ThresholdWhiteEvaluateOperator;
            break;
        case GaussianNoiseQuantumOperator:
            qop = GaussianNoiseEvaluateOperator;
            break;
        case ImpulseNoiseQuantumOperator:
            qop = ImpulseNoiseEvaluateOperator;
            break;
        case LaplacianNoiseQuantumOperator:
            qop = LaplacianNoiseEvaluateOperator;
            break;
        case MultiplicativeNoiseQuantumOperator:
            qop = MultiplicativeNoiseEvaluateOperator;
            break;
        case PoissonNoiseQuantumOperator:
            qop = PoissonNoiseEvaluateOperator;
            break;
        case UniformNoiseQuantumOperator:
            qop = UniformNoiseEvaluateOperator;
            break;
        case CosineQuantumOperator:
            qop = CosineEvaluateOperator;
            break;
        case SetQuantumOperator:
            qop = SetEvaluateOperator;
            break;
        case SineQuantumOperator:
            qop = SineEvaluateOperator;
            break;
        case AddModulusQuantumOperator:
            qop = AddModulusEvaluateOperator;
            break;
        case MeanQuantumOperator:
            qop = MeanEvaluateOperator;
            break;
        case AbsQuantumOperator:
            qop = AbsEvaluateOperator;
            break;
        case ExponentialQuantumOperator:
            qop = ExponentialEvaluateOperator;
            break;
        case MedianQuantumOperator:
            qop = MedianEvaluateOperator;
            break;
        case SumQuantumOperator:
            qop = SumEvaluateOperator;
            break;
#if defined(IMAGEMAGICK_GREATER_THAN_EQUAL_6_8_9)
        case RootMeanSquareQuantumOperator:
            qop = RootMeanSquareEvaluateOperator;
            break;
#endif
    }

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channel);
    EvaluateImage(image, qop, rvalue, exception);
    END_CHANNEL_MASK(image);
#else
    EvaluateImageChannel(image, channel, qop, rvalue, exception);
#endif
    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    return self;
}


/**
 * Analyzes the colors within a reference image and chooses a fixed number of colors to represent
 * the image. The goal of the algorithm is to minimize the difference between the input and output
 * image while minimizing the processing time.
 *
 * @overload quantize(number_colors = 256, colorspace = Magick::RGBColorspace, dither = true, tree_depth = 0, measure_error = false)
 *   @param number_colors [Numeric] The maximum number of colors in the result image.
 *   @param colorspace [Magick::ColorspaceType] The colorspace to quantize in.
 *   @param dither [Boolean] If true, Magick::RiemersmaDitherMethod will be used as
 *     DitherMethod. otherwise NoDitherMethod.
 *   @param tree_depth [Numeric] The tree depth to use while quantizing. The values 0 and 1 support
 *     automatic tree depth determination. The tree depth may be forced via values ranging from 2 to
 *     8. The ideal tree depth depends on the characteristics of the input image, and may be
 *     determined through experimentation.
 *   @param measure_error [Boolean] Set to true to calculate quantization errors when quantizing the
 *     image.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_quantize(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    QuantizeInfo quantize_info;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    GetQuantizeInfo(&quantize_info);

    switch (argc)
    {
        case 5:
            quantize_info.measure_error = (MagickBooleanType) RTEST(argv[4]);
        case 4:
            quantize_info.tree_depth = NUM2UINT(argv[3]);
        case 3:
            if (rb_obj_is_kind_of(argv[2], Class_DitherMethod))
            {
                VALUE_TO_ENUM(argv[2], quantize_info.dither_method, DitherMethod);
#if defined(IMAGEMAGICK_6)
                quantize_info.dither = quantize_info.dither_method != NoDitherMethod;
#endif
            }
            else
            {
#if defined(IMAGEMAGICK_7)
                quantize_info.dither_method = RTEST(argv[2]) ? RiemersmaDitherMethod : NoDitherMethod;
#else
                quantize_info.dither = (MagickBooleanType) RTEST(argv[2]);
#endif
            }
        case 2:
            VALUE_TO_ENUM(argv[1], quantize_info.colorspace, ColorspaceType);
        case 1:
            quantize_info.number_colors = NUM2UINT(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 5)", argc);
            break;
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    QuantizeImage(&quantize_info, new_image, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    QuantizeImage(&quantize_info, new_image);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Applies a radial blur to the image.
 *
 * @param angle_obj [Float] the angle (in degrees)
 * @return [Magick::Image] a new image
 */
VALUE
Image_radial_blur(VALUE self, VALUE angle_obj)
{
    Image *image, *new_image;
    ExceptionInfo *exception;
    double angle = NUM2DBL(angle_obj);

    image = rm_check_destroyed(self);
    exception = AcquireExceptionInfo();

#if defined(IMAGEMAGICK_GREATER_THAN_EQUAL_6_8_9)
    new_image = RotationalBlurImage(image, angle, exception);
#else
    new_image = RadialBlurImage(image, angle, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Applies a radial blur to the selected image channels.
 *
 * @overload radial_blur_channel(angle, channel = Magick::AllChannels)
 *   @param angle [Float] the angle (in degrees)
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload radial_blur_channel(angle, *channels)
 *   @param angle [Float] the angle (in degrees)
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_radial_blur_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    ExceptionInfo *exception;
    ChannelType channels;
    double angle;

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);

    // There must be 1 remaining argument.
    if (argc == 0)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (0 for 1 or more)");
    }
    else if (argc > 1)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    angle = NUM2DBL(argv[0]);
    exception = AcquireExceptionInfo();

#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    new_image = RotationalBlurImage(image, angle, exception);
    CHANGE_RESULT_CHANNEL_MASK(new_image);
    END_CHANNEL_MASK(image);
#elif defined(IMAGEMAGICK_GREATER_THAN_EQUAL_6_8_9)
    new_image = RotationalBlurImageChannel(image, channels, angle, exception);
#else
    new_image = RadialBlurImageChannel(image, channels, angle, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Changes the value of individual pixels based on the intensity of each pixel compared to a random
 * threshold. The result is a low-contrast, two color image.
 *
 * @overload random_threshold_channel(geometry_str, channel = Magick::AllChannels)
 *   @param geometry_str [String] A geometry string containing LOWxHIGH thresholds.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload random_threshold_channel(geometry_str, *channels)
 *   @param geometry_str [String] A geometry string containing LOWxHIGH thresholds.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Image_random_threshold_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    ChannelType channels;
    char *thresholds;
    VALUE geom_str;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    channels = extract_channels(&argc, argv);

    // There must be 1 remaining argument.
    if (argc == 0)
    {
        rb_raise(rb_eArgError, "missing threshold argument");
    }
    else if (argc > 1)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    // Accept any argument that has a to_s method.
    geom_str = rb_String(argv[0]);
    thresholds = StringValueCStr(geom_str);

    new_image = rm_clone_image(image);

    exception = AcquireExceptionInfo();

#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(new_image, channels);
    {
        GeometryInfo geometry_info;

        ParseGeometry(thresholds, &geometry_info);
        RandomThresholdImage(new_image, geometry_info.rho, geometry_info.sigma, exception);
    }
    END_CHANNEL_MASK(new_image);
#else
    RandomThresholdImageChannel(new_image, channels, thresholds, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);

    DestroyExceptionInfo(exception);

    RB_GC_GUARD(geom_str);

    return rm_image_new(new_image);
}


/**
 * Create a simulated three-dimensional button-like effect by lightening and darkening the edges of
 * the image. The "width" and "height" arguments define the width of the vertical and horizontal
 * edge of the effect. If "raised" is true, creates a raised effect, otherwise a lowered effect.
 *
 * @overload raise(width = 6, height = 6, raised = true)
 *   @param width [Numeric] The width of the raised edge in pixels.
 *   @param height [Numeric] The height of the raised edge in pixels.
 *   @param raised [Boolean] If true, the image is raised, otherwise lowered.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_raise(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    RectangleInfo rect;
    int raised = MagickTrue;      // default
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    memset(&rect, 0, sizeof(rect));
    rect.width = 6;         // default
    rect.height = 6;        // default

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 3:
            raised = RTEST(argv[2]);
        case 2:
            rect.height = NUM2ULONG(argv[1]);
        case 1:
            rect.width = NUM2ULONG(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 3)", argc);
            break;
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    RaiseImage(new_image, &rect, raised, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    RaiseImage(new_image, &rect, raised);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Call ReadImage.
 *
 * @param file_arg [File, String] the file containing image data or file name
 * @return [Array<Magick::Image>] an array of 1 or more new image objects
 */
VALUE
Image_read(VALUE class, VALUE file_arg)
{
    return rd_image(class, file_arg, ReadImage);
}


/**
 * Called when `rm_obj_to_s' raised an exception.
 *
 * No Ruby usage (internal function)
 *
 * @param arg the bad arg given
 * @return 0
 */
static VALUE
file_arg_rescue(VALUE arg, VALUE raised_exc ATTRIBUTE_UNUSED)
{
    rb_raise(rb_eTypeError, "argument must be path name or open file (%s given)",
             rb_class2name(CLASS_OF(arg)));
}


/**
 * Transform arguments, call either ReadImage or PingImage.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Yields to a block to get Image::Info attributes before calling
 *     Read/PingImage
 *
 * @param class the Ruby class for an Image
 * @param file the file containing image data
 * @param reader which image reader to use (ReadImage or PingImage)
 * @return an array of 1 or more new image objects
 * @see Image_read
 * @see Image_ping
 * @see array_from_images
 */

#if defined(__APPLE__) || defined(__FreeBSD__)
void sig_handler(int sig ATTRIBUTE_UNUSED)
{
}
#endif

static VALUE
rd_image(VALUE class ATTRIBUTE_UNUSED, VALUE file, reader_t reader)
{
    char *filename;
    long filename_l;
    Info *info;
    VALUE info_obj;
    Image *images;
    ExceptionInfo *exception;

    // Create a new Info structure for this read/ping
    info_obj = rm_info_new();
    Data_Get_Struct(info_obj, Info, info);

    if (TYPE(file) == T_FILE)
    {
        rb_io_t *fptr;

        // Ensure file is open - raise error if not
        GetOpenFile(file, fptr);
        rb_io_check_readable(fptr);
        SetImageInfoFile(info, rb_io_stdio_file(fptr));
    }
    else
    {
        // Convert arg to string. If an exception occurs raise an error condition.
        file = rb_rescue(rb_String, file, file_arg_rescue, file);

        filename = rm_str2cstr(file, &filename_l);
        filename_l = min(filename_l, MaxTextExtent-1);
        if (filename_l == 0)
        {
            rb_raise(rb_eArgError, "invalid path");
        }

        memcpy(info->filename, filename, (size_t)filename_l);
        info->filename[filename_l] = '\0';
        SetImageInfoFile(info, NULL);
    }

    exception = AcquireExceptionInfo();

#if defined(__APPLE__) || defined(__FreeBSD__)
    struct sigaction act, oldact;
    act.sa_handler = sig_handler;
    act.sa_flags = SA_RESTART;
    if (sigaction(SIGCHLD, &act, &oldact) < 0)
    {
        rb_sys_fail("sigaction");
    }
#endif

    images = (reader)(info, exception);

#if defined(__APPLE__) || defined(__FreeBSD__)
    if (sigaction(SIGCHLD, &oldact, NULL) < 0)
    {
        rb_sys_fail("sigaction");
    }
#endif

    rm_check_exception(exception, images, DestroyOnError);
    rm_set_user_artifact(images, info);
    DestroyExceptionInfo(exception);

    RB_GC_GUARD(info_obj);

    return array_from_images(images);
}


/**
 * Use this method to translate, scale, shear, or rotate image colors. Although you can use variable
 * sized matrices, typically you use a 5x5 for an RGBA image and a 6x6 for CMYKA. Populate the last
 * row with normalized values to translate.
 *
 * @param color_matrix [Array<Float>] An array of Float values representing the recolor matrix.
 * @return [Magick::Image] a new image
 */
VALUE
Image_recolor(VALUE self, VALUE color_matrix)
{
    Image *image, *new_image;
    unsigned long order;
    long x, len;
    double *matrix;
    ExceptionInfo *exception;
    KernelInfo *kernel_info;

    image = rm_check_destroyed(self);
    color_matrix = rm_check_ary_type(color_matrix);

    // Allocate color matrix from Ruby's memory
    len = RARRAY_LEN(color_matrix);
    matrix = ALLOC_N(double, len);

    for (x = 0; x < len; x++)
    {
        VALUE element = rb_ary_entry(color_matrix, x);
        if (rm_check_num2dbl(element))
        {
            matrix[x] = NUM2DBL(element);
        }
        else
        {
            xfree(matrix);
            rb_raise(rb_eTypeError, "type mismatch: %s given", rb_class2name(CLASS_OF(element)));
        }
    }

    order = (unsigned long)sqrt((double)(len + 1.0));

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    kernel_info = AcquireKernelInfo(NULL, exception);
    if (rm_should_raise_exception(exception, RetainExceptionRetention))
    {
        if (kernel_info != (KernelInfo *) NULL)
        {
            DestroyKernelInfo(kernel_info);
        }
        xfree((void *)matrix);
        rm_raise_exception(exception);
    }
#else
    kernel_info = AcquireKernelInfo(NULL);
#endif
    if (kernel_info == (KernelInfo *) NULL)
    {
        xfree((void *) matrix);
        DestroyExceptionInfo(exception);
        return Qnil;
    }
    kernel_info->width = order;
    kernel_info->height = order;
    kernel_info->values = (double *) matrix;

    new_image = ColorMatrixImage(image, kernel_info, exception);
    kernel_info->values = (double *) NULL;
    DestroyKernelInfo(kernel_info);
    xfree((void *) matrix);

    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Read a Base64-encoded image.
 *
 * @param content [String] the content
 * @return [Array<Magick::Image>] an array of new images
 */
VALUE
Image_read_inline(VALUE self ATTRIBUTE_UNUSED, VALUE content)
{
    VALUE info_obj;
    Image *images;
    ImageInfo *info;
    char *image_data;
    long x, image_data_l;
    unsigned char *blob;
    size_t blob_l;
    ExceptionInfo *exception;

    image_data = rm_str2cstr(content, &image_data_l);

    // Search for a comma. If found, we'll set the start of the
    // image data just following the comma. Otherwise we'll assume
    // the image data starts with the first byte.
    for (x = 0; x < image_data_l; x++)
    {
        if (image_data[x] == ',')
        {
            break;
        }
    }
    if (x < image_data_l)
    {
        image_data += x + 1;
    }

    blob = Base64Decode(image_data, &blob_l);
    if (blob_l == 0)
    {
        rb_raise(rb_eArgError, "can't decode image");
    }

    exception = AcquireExceptionInfo();

    // Create a new Info structure for this read. About the
    // only useful attribute that can be set is `format'.
    info_obj = rm_info_new();
    Data_Get_Struct(info_obj, Info, info);

    images = BlobToImage(info, blob, blob_l, exception);
    magick_free((void *)blob);

    rm_check_exception(exception, images, DestroyOnError);

    DestroyExceptionInfo(exception);
    rm_set_user_artifact(images, info);

    RB_GC_GUARD(info_obj);

    return array_from_images(images);
}


/**
 * Convert a list of images to an array of Image objects.
 *
 * No Ruby usage (internal function)
 *
 * @param images the images
 * @return array of images
 */
static VALUE
array_from_images(Image *images)
{
    VALUE image_obj, image_ary;
    Image *image;

    // Orphan the image, create an Image object, add it to the array.

    image_ary = rb_ary_new();
    while (images)
    {
        image = RemoveFirstImageFromList(&images);
        image_obj = rm_image_new(image);
        rb_ary_push(image_ary, image_obj);
    }

    RB_GC_GUARD(image_obj);
    RB_GC_GUARD(image_ary);

    return image_ary;
}


/**
 * Smooth the contours of an image while still preserving edge information.
 *
 * @param radius [Numeric] A neighbor is defined by radius. Use a radius of 0 and reduce_noise
 *   selects a suitable radius for you.
 * @return [Magick::Image] a new image
 */
VALUE
Image_reduce_noise(VALUE self, VALUE radius)
{
    Image *image, *new_image;
    ExceptionInfo *exception;
    size_t radius_size = NUM2SIZET(radius);

    image = rm_check_destroyed(self);

    exception = AcquireExceptionInfo();
    new_image = StatisticImage(image, NonpeakStatistic, radius_size, radius_size, exception);
    rm_check_exception(exception, new_image, DestroyOnError);

    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Reduce the number of colors in img to the colors used by remap_image. If a dither method is
 * specified then the given colors are dithered over the image as necessary, otherwise the closest
 * color (in RGB colorspace) is selected to replace that pixel in the image.
 *
 * @overload remap(remap_image, dither_method = Magick::RiemersmaDitherMethod)
 *   @param remap_image [Magick::Image, Magick::ImageList] The reference image or imagelist. If an
 *     imagelist, uses the current image.
 *   @param dither_method [Magick::DitherMethod] this object
 *   @return self
 */
VALUE
Image_remap(int argc, VALUE *argv, VALUE self)
{
    Image *image, *remap_image;
    QuantizeInfo quantize_info;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_frozen(self);

    GetQuantizeInfo(&quantize_info);

    switch (argc)
    {
        case 2:
            VALUE_TO_ENUM(argv[1], quantize_info.dither_method, DitherMethod);
#if defined(IMAGEMAGICK_6)
            quantize_info.dither = MagickTrue;
#endif
            break;
        case 1:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or 2)", argc);
            break;
    }

    remap_image = rm_check_destroyed(rm_cur_image(argv[0]));

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    RemapImage(&quantize_info, image, remap_image, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    RemapImage(&quantize_info, image, remap_image);
    rm_check_image_exception(image, RetainOnError);
#endif

    return self;
}


/**
 * Get the type of rendering intent.
 *
 * @return [Magick::RenderingIntent] the rendering intent
 */
VALUE
Image_rendering_intent(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return RenderingIntent_find(image->rendering_intent);
}


/**
 * Set the type of rendering intent..
 *
 * @param ri [Magick::RenderingIntent] the rendering intent
 * @return [Magick::RenderingIntent] the given value
 */
VALUE
Image_rendering_intent_eq(VALUE self, VALUE ri)
{
    Image *image = rm_check_frozen(self);
    VALUE_TO_ENUM(ri, image->rendering_intent, RenderingIntent);
    return ri;
}


#if defined(IMAGEMAGICK_7)
/**
 * Create new blurred image.
 *
 * No Ruby usage (internal function)
 *
 * @param image the image
 * @param blur the blur
 * @return NULL if not apply blur, otherwise a new image
 */
static Image*
blurred_image(Image* image, double blur)
{
    ExceptionInfo *exception;
    Image *new_image;

    exception = AcquireExceptionInfo();
    if (blur > 1.0)
    {
        new_image = BlurImage(image, blur, blur, exception);
    }
    else
    {
        new_image = SharpenImage(image, blur, blur, exception);
    }
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return new_image;
}
#endif


/**
 * Resample image to specified horizontal resolution, vertical resolution,
 * filter and blur factor.
 *
 * No Ruby usage (internal function)
 *
 * @param bang whether the bang (!) version of the method was called
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @return self if bang, otherwise a new image
 * @see Image_resample
 * @see Image_resample_bang
 */
static VALUE
resample(int bang, int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    FilterType filter;
    double x_resolution, y_resolution, blur;
    double width, height;
    ExceptionInfo *exception;

    Data_Get_Struct(self, Image, image);

    // Set up defaults
    filter  = image->filter;
#if defined(IMAGEMAGICK_7)
    blur    = 1.0;
#else
    blur    = image->blur;
#endif
    x_resolution = 72.0;
    y_resolution = 72.0;

    switch (argc)
    {
        case 4:
            blur = NUM2DBL(argv[3]);
        case 3:
            VALUE_TO_ENUM(argv[2], filter, FilterType);
        case 2:
            y_resolution = NUM2DBL(argv[1]);
            if (y_resolution < 0.0)
            {
                rb_raise(rb_eArgError, "invalid y_resolution value (%lf given)", y_resolution);
            }
        case 1:
            x_resolution = NUM2DBL(argv[0]);
            if (x_resolution < 0.0)
            {
                rb_raise(rb_eArgError, "invalid x_resolution value (%lf given)", x_resolution);
            }
            if (argc == 1)
            {
                y_resolution = x_resolution;
            }
#if defined(IMAGEMAGICK_7)
            width = (x_resolution * image->columns /
                        (image->resolution.x == 0.0 ? 72.0 : image->resolution.x) + 0.5);
            height = (y_resolution * image->rows /
                         (image->resolution.y == 0.0 ? 72.0 : image->resolution.y) + 0.5);
#else
            width = (x_resolution * image->columns /
                        (image->x_resolution == 0.0 ? 72.0 : image->x_resolution) + 0.5);
            height = (y_resolution * image->rows /
                         (image->y_resolution == 0.0 ? 72.0 : image->y_resolution) + 0.5);
#endif
            if (width > (double)ULONG_MAX || height > (double)ULONG_MAX)
            {
                rb_raise(rb_eRangeError, "resampled image too big");
            }
            break;
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 4)", argc);
            break;
    }

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    Image *preprocess = blurred_image(image, blur);
    new_image = ResampleImage(preprocess, x_resolution, y_resolution, filter, exception);
    DestroyImage(preprocess);
#else
    new_image = ResampleImage(image, x_resolution, y_resolution, filter, blur, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);

    DestroyExceptionInfo(exception);

    if (bang)
    {
        rm_ensure_result(new_image);
        UPDATE_DATA_PTR(self, new_image);
        rm_image_destroy(image);
        return self;
    }
    return rm_image_new(new_image);
}

/**
 * Resample image to specified horizontal resolution, vertical resolution, filter and blur factor.
 *
 * Resize the image so that its rendered size remains the same as the original at the specified
 * target resolution. For example, if a 300 DPI image renders at 3 inches by 2 inches on a 300 DPI
 * device, when the image has been resampled to 72 DPI, it will render at 3 inches by 2 inches on a
 * 72 DPI device. Note that only a small number of image formats (e.g. JPEG, PNG, and TIFF) are
 * capable of storing the image resolution. For formats which do not support an image resolution,
 * the original resolution of the image must be specified via the density attribute prior to
 * specifying the resample resolution.
 *
 * @overload resample(x_resolution = 72.0, y_resolution = 72.0, filter = self.filter, blur = self.blur)
 *   @param x_resolution [Float] the target horizontal resolution.
 *   @param y_resolution [Float] the target vertical resolution.
 *   @param filter [Magick::FilterType] the filter type
 *   @param blur [Float] the blur size
 *   @return [Magick] a new image
 *   @see Image#resample!
 */
VALUE
Image_resample(int argc, VALUE *argv, VALUE self)
{
    rm_check_destroyed(self);
    return resample(False, argc, argv, self);
}


/**
 * Resample image to specified horizontal resolution, vertical resolution, filter and blur factor.
 * In-place form of {Image#resample}.
 *
 * @overload resample!(x_resolution = 72.0, y_resolution = 72.0, filter = self.filter, blur = self.blur)
 *   @param x_resolution [Float] the target horizontal resolution.
 *   @param y_resolution [Float] the target vertical resolution.
 *   @param filter [Magick::FilterType] the filter type
 *   @param blur [Float] the blur size
 *   @return [Magick] a new image
 *   @see Image#resample
 */
VALUE
Image_resample_bang(int argc, VALUE *argv, VALUE self)
{
    rm_check_frozen(self);
    return resample(True, argc, argv, self);
}


/**
 * Scale an image to the desired dimensions using the specified filter and blur
 * factor.
 *
 * No Ruby usage (internal function)
 *
 * @param bang whether the bang (!) version of the method was called
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @return self if bang, otherwise a new image
 * @see Image_resize
 * @see Image_resize_bang
 */
static VALUE
resize(int bang, int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double scale_arg;
    FilterType filter;
    unsigned long rows, columns;
    double blur, drows, dcols;
    ExceptionInfo *exception;

    Data_Get_Struct(self, Image, image);

    // Set up defaults
    filter  = image->filter;
#if defined(IMAGEMAGICK_7)
    blur    = 1.0;
#else
    blur    = image->blur;
#endif
    rows    = image->rows;
    columns = image->columns;

    switch (argc)
    {
        case 4:
            blur = NUM2DBL(argv[3]);
        case 3:
            VALUE_TO_ENUM(argv[2], filter, FilterType);
        case 2:
            rows = NUM2ULONG(argv[1]);
            columns = NUM2ULONG(argv[0]);
            if (columns == 0 || rows == 0)
            {
                rb_raise(rb_eArgError, "invalid result dimension (%lu, %lu given)", columns, rows);
            }
            break;
        case 1:
            scale_arg = NUM2DBL(argv[0]);
            if (scale_arg < 0.0)
            {
                rb_raise(rb_eArgError, "invalid scale_arg value (%g given)", scale_arg);
            }
            drows = scale_arg * image->rows + 0.5;
            dcols = scale_arg * image->columns + 0.5;
            if (drows > (double)ULONG_MAX || dcols > (double)ULONG_MAX)
            {
                rb_raise(rb_eRangeError, "resized image too big");
            }
            rows = (unsigned long) drows;
            columns = (unsigned long) dcols;
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 to 4)", argc);
            break;
    }

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    Image *preprocess = (argc == 4) ? blurred_image(image, blur) : image;
    new_image = ResizeImage(preprocess, columns, rows, filter, exception);
    if (argc == 4)
    {
        DestroyImage(preprocess);
    }
#else
    new_image = ResizeImage(image, columns, rows, filter, blur, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);

    DestroyExceptionInfo(exception);

    if (bang)
    {
        rm_ensure_result(new_image);
        UPDATE_DATA_PTR(self, new_image);
        rm_image_destroy(image);
        return self;
    }
    return rm_image_new(new_image);
}


/**
 * Scale an image to the desired dimensions using the specified filter and blur factor.
 *
 * @overload resize(scale)
 *   @param scale [Float] You can use this argument instead of specifying the desired width and
 *     height. The percentage size change. For example, 1.25 makes the new image 125% of the size of
 *     the receiver. The scale factor 0.5 makes the new image 50% of the size of the receiver.
 *
 * @overload resize(cols, rows, filter, blur)
 *   @param cols [Float] The desired width
 *   @param rows [Float] The desired height.
 *   @param filter [Magick::FilterType] the filter type
 *   @param blur [Float] the blur size
 *
 * @return [Magick::Image] a new image
 * @see Image#resize!
 */
VALUE
Image_resize(int argc, VALUE *argv, VALUE self)
{
    rm_check_destroyed(self);
    return resize(False, argc, argv, self);
}


/**
 * Scale an image to the desired dimensions using the specified filter and blur factor.
 * In-place form of {Image#resize}.
 *
 * @overload resize!(scale)
 *   @param scale [Float] You can use this argument instead of specifying the desired width and
 *     height. The percentage size change. For example, 1.25 makes the new image 125% of the size of
 *     the receiver. The scale factor 0.5 makes the new image 50% of the size of the receiver.
 *
 * @overload resize!(cols, rows, filter, blur)
 *   @param cols [Float] The desired width
 *   @param rows [Float] The desired height.
 *   @param filter [Magick::FilterType] the filter type
 *   @param blur [Float] the blur size
 *
 * @return [Magick::Image] a new image
 * @see Image#resize!
 */
VALUE
Image_resize_bang(int argc, VALUE *argv, VALUE self)
{
    rm_check_frozen(self);
    return resize(True, argc, argv, self);
}


/**
 * Offset an image as defined by x_offset and y_offset.
 *
 * @param x_offset [Numeric] the x offset
 * @param y_offset [Numeric] the y offset
 * @return [Magick::Image] a new image
 */
VALUE
Image_roll(VALUE self, VALUE x_offset, VALUE y_offset)
{
    Image *image, *new_image;
    ExceptionInfo *exception;
    ssize_t x = NUM2LONG(x_offset);
    ssize_t y = NUM2LONG(y_offset);

    image = rm_check_destroyed(self);

    exception = AcquireExceptionInfo();
    new_image = RollImage(image, x, y, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Rotate the image.
 *
 * No Ruby usage (internal function)
 *
 * @param bang whether the bang (!) version of the method was called
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @return self if bang, otherwise a new image
 * @see Image_rotate
 * @see Image_rotate_bang
 */
static VALUE
rotate(int bang, int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double degrees;
    char *arrow;
    long arrow_l;
    ExceptionInfo *exception;

    Data_Get_Struct(self, Image, image);

    switch (argc)
    {
        case 2:
            arrow = rm_str2cstr(argv[1], &arrow_l);
            if (arrow_l != 1 || (*arrow != '<' && *arrow != '>'))
            {
                rb_raise(rb_eArgError, "second argument must be '<' or '>', '%s' given", arrow);
            }
            if (*arrow == '>' && image->columns <= image->rows)
            {
                return Qnil;
            }
            if (*arrow == '<' && image->columns >= image->rows)
            {
                return Qnil;
            }
        case 1:
            degrees = NUM2DBL(argv[0]);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or 2)", argc);
            break;
    }

    exception = AcquireExceptionInfo();

    new_image = RotateImage(image, degrees, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    if (bang)
    {
        rm_ensure_result(new_image);
        UPDATE_DATA_PTR(self, new_image);
        rm_image_destroy(image);
        return self;
    }
    return rm_image_new(new_image);
}


/**
 * Rotate the receiver by the specified angle. Positive angles rotate clockwise while negative
 * angles rotate counter-clockwise. New pixels introduced by the rotation are the same color as the
 * current background color. Set the background color to "none" to make the new pixels transparent
 * black.
 *
 * @overload rotate(degrees)
 *   @param degrees [Float] The number of degrees to rotate the image.
 *
 * @overload rotate(degrees, qualifier)
 *   @param degrees [Float] The number of degrees to rotate the image.
 *   @param qualifier [String] If present, either ">" or "<". If ">", rotates the image only if the
 *     image's width exceeds its height. If "<" rotates the image only if its height exceeds its
 *     width. If this argument is omitted the image is always rotated.
 *
 * @return [Magick::Image] a new image
 * @see Image#rotate!
 */
VALUE
Image_rotate(int argc, VALUE *argv, VALUE self)
{
    rm_check_destroyed(self);
    return rotate(False, argc, argv, self);
}


/**
 * Rotate the image.
 * In-place form of {Image#rotate}.
 *
 * @overload rotate!(degrees)
 *   @param degrees [Float] The number of degrees to rotate the image.
 *
 * @overload rotate!(degrees, qualifier)
 *   @param degrees [Float] The number of degrees to rotate the image.
 *   @param qualifier [String] If present, either ">" or "<". If ">", rotates the image only if the
 *     image's width exceeds its height. If "<" rotates the image only if its height exceeds its
 *     width. If this argument is omitted the image is always rotated.
 *
 * @return [Magick::Image] a new image
 * @see Image#rotate!
 */
VALUE
Image_rotate_bang(int argc, VALUE *argv, VALUE self)
{
    rm_check_frozen(self);
    return rotate(True, argc, argv, self);
}


/**
 * Return image rows.
 *
 * @return [Numeric] the image rows
 */
VALUE
Image_rows(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, rows, int);
}


/**
 * Scale an image to the desired dimensions with pixel sampling. Unlike other scaling methods, this
 * method does not introduce any additional color into the scaled image.
 *
 * @overload sample(scale)
 *   @param scale [Float] You can use this argument instead of specifying the desired width and
 *     height. The percentage size change. For example, 1.25 makes the new image 125% of the size of
 *     the receiver. The scale factor 0.5 makes the new image 50% of the size of the receiver.
 *
 * @overload sample(cols, rows)
 *   @param cols [Numeric] The desired width.
 *   @param rows [Numeric] The desired height.
 *
 * @return [Magick::Image] a new image
 * @see Image#sample!
 */
VALUE
Image_sample(int argc, VALUE *argv, VALUE self)
{
    rm_check_destroyed(self);
    return scale(False, argc, argv, self, SampleImage);
}


/**
 * Scale an image to the desired dimensions with pixel sampling.
 * In-place form of {Image#sample}.
 *
 * @overload sample!(scale)
 *   @param scale [Float] You can use this argument instead of specifying the desired width and
 *     height. The percentage size change. For example, 1.25 makes the new image 125% of the size of
 *     the receiver. The scale factor 0.5 makes the new image 50% of the size of the receiver.
 *
 * @overload sample!(cols, rows)
 *   @param cols [Numeric] The desired width.
 *   @param rows [Numeric] The desired height.
 *
 * @return [Magick::Image] a new image
 * @see Image#sample
 */
VALUE
Image_sample_bang(int argc, VALUE *argv, VALUE self)
{
    rm_check_frozen(self);
    return scale(True, argc, argv, self, SampleImage);
}


/**
 * Change the size of an image to the given dimensions. Alias of {Image#sample}.
 *
 * @overload scale(scale)
 *   @param scale [Float] You can use this argument instead of specifying the desired width and
 *     height. The percentage size change. For example, 1.25 makes the new image 125% of the size of
 *     the receiver. The scale factor 0.5 makes the new image 50% of the size of the receiver.
 *
 * @overload scale(cols, rows)
 *   @param cols [Numeric] The desired width.
 *   @param rows [Numeric] The desired height.
 *
 * @return [Magick::Image] a new image
 * @see Image#sample
 * @see Image#scale!
 */
VALUE
Image_scale(int argc, VALUE *argv, VALUE self)
{
    rm_check_destroyed(self);
    return scale(False, argc, argv, self, ScaleImage);
}


/**
 * Change the size of an image to the given dimensions. Alias of {Image#sample!}.
 *
 * @overload scale!(scale)
 *   @param scale [Float] You can use this argument instead of specifying the desired width and
 *     height. The percentage size change. For example, 1.25 makes the new image 125% of the size of
 *     the receiver. The scale factor 0.5 makes the new image 50% of the size of the receiver.
 *
 * @overload scale!(cols, rows)
 *   @param cols [Numeric] The desired width.
 *   @param rows [Numeric] The desired height.
 *
 * @return [Magick::Image] a new image
 * @see Image#sample
 * @see Image#scale!
 */
VALUE
Image_scale_bang(int argc, VALUE *argv, VALUE self)
{
    rm_check_frozen(self);
    return scale(True, argc, argv, self, ScaleImage);
}


/**
 * Call ScaleImage or SampleImage
 *
 * Notes:
 *   - If 1 argument > 0, multiply current size by this much.
 *   - If 2 arguments, (cols, rows).
 *
 * No Ruby usage (internal function)
 *
 * @param bang whether the bang (!) version of the method was called
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @param scaler which scalar to use (ScaleImage or SampleImage)
 * @return self if bang, otherwise a new image
 * @see Image_sample
 * @see Image_sample_bang
 * @see Image_scale
 * @see Image_scale_bang
 */
static VALUE
scale(int bang, int argc, VALUE *argv, VALUE self, scaler_t scaler)
{
    Image *image, *new_image;
    unsigned long columns, rows;
    double scale_arg, drows, dcols;
    ExceptionInfo *exception;

    Data_Get_Struct(self, Image, image);

    switch (argc)
    {
        case 2:
            columns = NUM2ULONG(argv[0]);
            rows    = NUM2ULONG(argv[1]);
            if (columns == 0 || rows == 0)
            {
                rb_raise(rb_eArgError, "invalid result dimension (%lu, %lu given)", columns, rows);
            }
            break;
        case 1:
            scale_arg = NUM2DBL(argv[0]);
            if (scale_arg <= 0)
            {
                rb_raise(rb_eArgError, "invalid scale value (%g given)", scale_arg);
            }
            drows = scale_arg * image->rows + 0.5;
            dcols = scale_arg * image->columns + 0.5;
            if (drows > (double)ULONG_MAX || dcols > (double)ULONG_MAX)
            {
                rb_raise(rb_eRangeError, "resized image too big");
            }
            rows = (unsigned long) drows;
            columns = (unsigned long) dcols;
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or 2)", argc);
            break;
    }

    exception = AcquireExceptionInfo();
    new_image = (scaler)(image, columns, rows, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    if (bang)
    {
        rm_ensure_result(new_image);
        UPDATE_DATA_PTR(self, new_image);
        rm_image_destroy(image);
        return self;
    }

    return rm_image_new(new_image);
}


/**
 * Return the scene number assigned to the image the last time the image was written to a
 * multi-image image file.
 *
 * @return [Numeric] the image scene
 */
VALUE
Image_scene(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, scene, ulong);
}


/**
 * Selectively blur pixels within a contrast threshold.
 *
 * @overload selective_blur_channel(radius, sigma, threshold, channel = Magick::AllChannels)
 *   @param radius [Float] the radius value
 *   @param sigma [Float] the sigma value
 *   @param threshold [Float, String] Either a number between 0.0 and 1.0 or a string in the form
 *     "NN%"
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload selective_blur_channel(radius, sigma, threshold, *channels)
 *   @param radius [Float] the radius value
 *   @param sigma [Float] the sigma value
 *   @param threshold [Float, String] Either a number between 0.0 and 1.0 or a string in the form
 *     "NN%"
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_selective_blur_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double radius, sigma, threshold;
    ExceptionInfo *exception;
    ChannelType channels;

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);
    if (argc > 3)
    {
        raise_ChannelType_error(argv[argc-1]);
    }
    if (argc != 3)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 3 or more)", argc);
    }
    radius = NUM2DBL(argv[0]);
    sigma = NUM2DBL(argv[1]);

    // threshold is either a floating-point number or a string in the form "NN%".
    // Either way it's supposed to represent a percentage of the QuantumRange.
    threshold = rm_percentage(argv[2], 1.0) * QuantumRange;

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    new_image = SelectiveBlurImage(image, radius, sigma, threshold, exception);
    CHANGE_RESULT_CHANNEL_MASK(new_image);
    END_CHANNEL_MASK(image);
#else
    new_image = SelectiveBlurImageChannel(image, channels, radius, sigma, threshold, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Sets the depth of the image channel.
 *
 * @param channel_arg [Magick::ChannelType] the channel
 * @param depth [Numeric] the depth
 * @return self
 */
VALUE
Image_set_channel_depth(VALUE self, VALUE channel_arg, VALUE depth)
{
    Image *image;
    ChannelType channel;
    unsigned long channel_depth;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_frozen(self);

    VALUE_TO_ENUM(channel_arg, channel, ChannelType);
    channel_depth = NUM2ULONG(depth);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BEGIN_CHANNEL_MASK(image, channel);
    SetImageDepth(image, channel_depth, exception);
    END_CHANNEL_MASK(image);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    SetImageChannelDepth(image, channel, channel_depth);
    rm_check_image_exception(image, RetainOnError);
#endif

    return self;
}


/**
 * Constructs a grayscale image for each channel specified.
 *
 * @overload separate(channel = Magick::AllChannels)
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload separate(*channels)
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::ImageList] a new ImageList
 */
VALUE
Image_separate(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_images;
    ChannelType channels = 0;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);

    // All arguments are ChannelType enums
    if (argc > 0)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    new_images = SeparateImages(image, exception);
    CHANGE_RESULT_CHANNEL_MASK(new_images);
    END_CHANNEL_MASK(image);
#else
    new_images = SeparateImages(image, channels, exception);
#endif
    rm_check_exception(exception, new_images, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_imagelist_from_images(new_images);
}


/**
 * Applies a special effect to the image, similar to the effect achieved in a photo darkroom by
 * sepia toning.
 *
 * @overload sepiatone(threshold = Magick::QuantumRange)
 *   @param threshold [Float] Threshold ranges from 0 to QuantumRange and is a measure of the extent
 *     of the sepia toning. A threshold of 80% is a good starting point for a reasonable tone.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_sepiatone(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double threshold = (double) QuantumRange;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 1:
            threshold = NUM2DBL(argv[0]);
            break;
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
    }

    exception = AcquireExceptionInfo();
    new_image = SepiaToneImage(image, threshold, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Segments an image by analyzing the histograms of the color components and identifying units that
 * are homogeneous with the fuzzy c-means technique.
 *
 * @overload segment(colorspace = Magick::RGBColorspace, cluster_threshold = 1.0, smoothing_threshold = 1.5, verbose = false)
 *   @param colorspace [Magick::ColorspaceType] A ColorspaceType value. Empirical evidence suggests
 *     that distances in YUV or YIQ correspond to perceptual color differences more closely than do
 *     distances in RGB space. The image is then returned to RGB colorspace after color reduction.
 *   @param cluster_threshold [Float] The number of pixels in each cluster must exceed the the
 *     cluster threshold to be considered valid.
 *   @param smoothing_threshold [Float] The smoothing threshold eliminates noise in the second
 *     derivative of the histogram. As the value is increased, you can expect a smoother second
 *     derivative.
 *   @param verbose [Boolean] If true, segment prints detailed information about the identified classes.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_segment(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    int colorspace              = RGBColorspace;    // These are the Magick++ defaults
    unsigned int verbose        = MagickFalse;
    double cluster_threshold    = 1.0;
    double smoothing_threshold  = 1.5;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 4:
            verbose = RTEST(argv[3]);
        case 3:
            smoothing_threshold = NUM2DBL(argv[2]);
        case 2:
            cluster_threshold = NUM2DBL(argv[1]);
        case 1:
            VALUE_TO_ENUM(argv[0], colorspace, ColorspaceType);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 4)", argc);
            break;
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    SegmentImage(new_image, colorspace, verbose, cluster_threshold, smoothing_threshold, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    SegmentImage(new_image, colorspace, verbose, cluster_threshold, smoothing_threshold);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * If called with an associated block, properties runs the block once for each property defined for
 * the image. The block arguments are the property name and its value. If there is no block,
 * properties returns a hash with one element for each property. The hash key is the property name
 * and the associated value is the property value.
 *
 * @overload properties
 *   @return [Hash] the properties
 *
 * @overload properties
 *   @yield [Magick::Image::Info]
 *   @return [Magick::Image] self
 */
VALUE
Image_properties(VALUE self)
{
    Image *image;
    VALUE attr_hash, ary;
    const char *property, *value;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
#endif

    if (rb_block_given_p())
    {
        ary = rb_ary_new2(2);

        ResetImagePropertyIterator(image);
        property = GetNextImageProperty(image);
        while (property)
        {
#if defined(IMAGEMAGICK_7)
            value = GetImageProperty(image, property, exception);
#else
            value = GetImageProperty(image, property);
#endif
            rb_ary_store(ary, 0, rb_str_new2(property));
            rb_ary_store(ary, 1, rb_str_new2(value));
            rb_yield(ary);
            property = GetNextImageProperty(image);
        }
#if defined(IMAGEMAGICK_7)
        CHECK_EXCEPTION();
        DestroyExceptionInfo(exception);
#else
        rm_check_image_exception(image, RetainOnError);
#endif

        RB_GC_GUARD(ary);

        return self;
    }

    // otherwise return properties hash
    else
    {
        attr_hash = rb_hash_new();
        ResetImagePropertyIterator(image);
        property = GetNextImageProperty(image);
        while (property)
        {
#if defined(IMAGEMAGICK_7)
            value = GetImageProperty(image, property, exception);
#else
            value = GetImageProperty(image, property);
#endif
            rb_hash_aset(attr_hash, rb_str_new2(property), rb_str_new2(value));
            property = GetNextImageProperty(image);
        }
#if defined(IMAGEMAGICK_7)
        CHECK_EXCEPTION();
        DestroyExceptionInfo(exception);
#else
        rm_check_image_exception(image, RetainOnError);
#endif

        RB_GC_GUARD(attr_hash);

        return attr_hash;
    }

}


/**
 * Shine a distant light on an image to create a three-dimensional effect. You control the
 * positioning of the light with azimuth and elevation; azimuth is measured in degrees off the x
 * axis and elevation is measured in pixels above the Z axis.
 *
 * @overload shade(shading = false, azimuth = 30.0, elevation = 30.0)
 *   @param shading [Boolean] If true, shade shades the intensity of each pixel.
 *   @param azimuth [Float] The light source direction. The azimuth is measured in degrees. 0 is at
 *     9 o'clock. Increasing values move the light source counter-clockwise.
 *   @param elevation [Float] The light source direction. The azimuth is measured in degrees. 0 is
 *     at 9 o'clock. Increasing values move the light source counter-clockwise.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_shade(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double azimuth = 30.0, elevation = 30.0;
    unsigned int shading = MagickFalse;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 3:
            elevation = NUM2DBL(argv[2]);
        case 2:
            azimuth = NUM2DBL(argv[1]);
        case 1:
            shading = RTEST(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 3)", argc);
            break;
    }

    exception = AcquireExceptionInfo();
    new_image = ShadeImage(image, shading, azimuth, elevation, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Call ShadowImage. X- and y-offsets are the pixel offset. Alpha is either a number between 0 and 1
 * or a string "NN%". Sigma is the std. dev. of the Gaussian, in pixels.
 *
 * @overload Image#shadow(x_offset = 4, y_offset = 4, sigma = 4.0, alpha = 1.0)
 *   @param x_offset [Numeric] The shadow x-offset
 *   @param y_offset [Numeric] The shadow y-offset
 *   @param sigma [Float] The standard deviation of the Gaussian operator used to produce the
 *     shadow. The higher the number, the "blurrier" the shadow, but the longer it takes to produce
 *     the shadow. Must be > 0.0.
 *   @param alpha [String, Float] The percent alpha of the shadow. The argument may be a
 *     floating-point numeric value or a string in the form "NN%".
 *   @return [Magick::Image] a new image
 */
VALUE
Image_shadow(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double alpha = 100.0;
    double sigma = 4.0;
    long x_offset = 4L;
    long y_offset = 4L;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 4:
            alpha = rm_percentage(argv[3], 1.0);   // Clamp to 1.0 < x <= 100.0
            if (fabs(alpha) < 0.01)
            {
                rb_warning("shadow will be transparent - alpha %g very small", alpha);
            }
            alpha = FMIN(alpha, 1.0);
            alpha = FMAX(alpha, 0.01);
            alpha *= 100.0;
        case 3:
            sigma = NUM2DBL(argv[2]);
        case 2:
            y_offset = NUM2LONG(argv[1]);
        case 1:
            x_offset = NUM2LONG(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 4)", argc);
            break;
    }

    exception = AcquireExceptionInfo();
    new_image = ShadowImage(image, alpha, sigma, x_offset, y_offset, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Sharpen an image.
 *
 * @overload sharpen(radius = 0.0, sigma = 1.0)
 *   @param radius [Float] The radius of the Gaussian operator.
 *   @param sigma [Float] The sigma (standard deviation) of the Gaussian operator.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_sharpen(int argc, VALUE *argv, VALUE self)
{
    return effect_image(self, argc, argv, SharpenImage);
}


/**
 * Sharpen image on a channel.
 *
 * @overload sharpen_channel(radius = 0.0, sigma = 1.0, channel = Magick::AllChannels)
 *   @param radius [Float] The radius of the Gaussian operator.
 *   @param sigma [Float] The sigma (standard deviation) of the Gaussian operator.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload sharpen_channel(radius = 0.0, sigma = 1.0, *channels)
 *   @param radius [Float] The radius of the Gaussian operator.
 *   @param sigma [Float] The sigma (standard deviation) of the Gaussian operator.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_sharpen_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    ChannelType channels;
    ExceptionInfo *exception;
    double radius = 0.0, sigma = 1.0;

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);

    // There must be 0, 1, or 2 remaining arguments.
    switch (argc)
    {
        case 2:
            sigma = NUM2DBL(argv[1]);
            /* Fall thru */
        case 1:
            radius = NUM2DBL(argv[0]);
            /* Fall thru */
        case 0:
            break;
        default:
            raise_ChannelType_error(argv[argc-1]);
    }

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    new_image = SharpenImage(image, radius, sigma, exception);
    CHANGE_RESULT_CHANNEL_MASK(new_image);
    END_CHANNEL_MASK(image);
#else
    new_image = SharpenImageChannel(image, channels, radius, sigma, exception);
#endif

    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Shave pixels from the image edges, leaving a rectangle of the specified width & height in the
 * center.
 *
 * @param width [Numeric] the width to leave
 * @param height [Numeric] the hight to leave
 * @return [Magick::Image] a new image
 * @see Image#shave!
 */
VALUE
Image_shave(VALUE self, VALUE width, VALUE height)
{
    rm_check_destroyed(self);
    return xform_image(False, self, INT2FIX(0), INT2FIX(0), width, height, ShaveImage);
}


/**
 * Shave pixels from the image edges, leaving a rectangle of the specified width & height in the
 * center.
 * In-place form of {Image#shave}.
 *
 * @param width [Numeric] the width to leave
 * @param height [Numeric] the hight to leave
 * @return [Magick::Image] a new image
 * @see Image#shave
 */
VALUE
Image_shave_bang(VALUE self, VALUE width, VALUE height)
{
    rm_check_frozen(self);
    return xform_image(True, self, INT2FIX(0), INT2FIX(0), width, height, ShaveImage);
}


/**
 * Shearing slides one edge of an image along the X or Y axis, creating a parallelogram. An X
 * direction shear slides an edge along the X axis, while a Y direction shear slides an edge along
 * the Y axis. The amount of the shear is controlled by a shear angle. For X direction shears,
 * x_shear is measured relative to the Y axis, and similarly, for Y direction shears y_shear is
 * measured relative to the X axis. Empty triangles left over from shearing the image are filled
 * with the background color.
 *
 * @param x_shear [Float] the x shear (in degrees)
 * @param y_shear [Float] the y shear (in degrees)
 * @return [Magick::Image] a new image
 */
VALUE
Image_shear(VALUE self, VALUE x_shear, VALUE y_shear)
{
    Image *image, *new_image;
    ExceptionInfo *exception;
    double x = NUM2DBL(x_shear);
    double y = NUM2DBL(y_shear);

    image = rm_check_destroyed(self);

    exception = AcquireExceptionInfo();
    new_image = ShearImage(image, x, y, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Adjusts the contrast of an image channel with a non-linear sigmoidal contrast
 * algorithm. Increases the contrast of the image using a sigmoidal transfer function without
 * saturating highlights or shadows.
 *
 * @overload sigmoidal_contrast_channel(contrast = 3.0, midpoint = 50.0, sharpen = false, channel = Magick::AllChannels)

 *   @param contrast [Float] indicates how much to increase the contrast
 *     (0 is none; 3 is typical; 20 is pushing it)
 *   @param midpoint [Float] indicates where midtones fall in the resultant image (0 is white; 50%
 *     is middle-gray; 100% is black). Note that "50%" means "50% of the quantum range." This argument
 *     is a number between 0 and QuantumRange. To specify "50%" use QuantumRange * 0.50.
 *   @param sharpen [Boolean] Set sharpen to true to increase the image contrast otherwise the
 *     contrast is reduced.
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload sigmoidal_contrast_channel(contrast = 3.0, midpoint = 50.0, sharpen = false, *channels)
 *   @param contrast [Float] indicates how much to increase the contrast
 *     (0 is none; 3 is typical; 20 is pushing it)
 *   @param midpoint [Float] indicates where midtones fall in the resultant image (0 is white; 50%
 *     is middle-gray; 100% is black). Note that "50%" means "50% of the quantum range." This argument
 *     is a number between 0 and QuantumRange. To specify "50%" use QuantumRange * 0.50.
 *   @param sharpen [Boolean] Set sharpen to true to increase the image contrast otherwise the
 *     contrast is reduced.
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_sigmoidal_contrast_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    MagickBooleanType sharpen = MagickFalse;
    double contrast = 3.0;
    double midpoint = 50.0;
    ChannelType channels;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);

    switch (argc)
    {
        case 3:
            sharpen  = (MagickBooleanType) RTEST(argv[2]);
        case 2:
            midpoint = NUM2DBL(argv[1]);
        case 1:
            contrast = NUM2DBL(argv[0]);
        case 0:
            break;
        default:
            raise_ChannelType_error(argv[argc-1]);
            break;
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BEGIN_CHANNEL_MASK(new_image, channels);
    SigmoidalContrastImage(new_image, sharpen, contrast, midpoint, exception);
    END_CHANNEL_MASK(new_image);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    SigmoidalContrastImageChannel(new_image, channels, sharpen, contrast, midpoint);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Compute a message digest from an image pixel stream with an implementation of the NIST SHA-256
 * Message Digest algorithm.
 *
 * @return [String, nil] the message digest
 */
VALUE
Image_signature(VALUE self)
{
    Image *image;
    const char *signature;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    SignatureImage(image, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    SignatureImage(image);
    rm_check_image_exception(image, RetainOnError);
#endif
    signature = rm_get_property(image, "signature");
    if (!signature)
    {
        return Qnil;
    }
    return rb_str_new(signature, 64);
}


/**
 * Simulates a pencil sketch. For best results start with a grayscale image.
 *
 * @overload sketch(radius = 0.0, sigma = 1.0, angle = 0.0)
 *   @param radius [Float] The radius
 *   @param sigma [Float] The standard deviation
 *   @param angle [Float] The angle (in degrees)
 *   @return [Magick::Image] a new image
 *   @see motion_blur
 */
VALUE
Image_sketch(int argc, VALUE *argv, VALUE self)
{
    rm_check_destroyed(self);
    return motion_blur(argc, argv, self, SketchImage);
}


/**
 * Apply a special effect to the image, similar to the effect achieved in a photo darkroom by
 * selectively exposing areas of photo sensitive paper to light. Threshold ranges from 0 to
 * QuantumRange and is a measure of the extent of the solarization.
 *
 * @overload solarize(threshold = 50.0)
 *   @param threshold [Float] Ranges from 0 to QuantumRange and is a measure of the extent of the
 *   solarization.
 *   @return a new image
 */
VALUE
Image_solarize(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double threshold = 50.0;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 1:
            threshold = NUM2DBL(argv[0]);
            if (threshold < 0.0 || threshold > QuantumRange)
            {
                rb_raise(rb_eArgError, "threshold out of range, must be >= 0.0 and < QuantumRange");
            }
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
            break;
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    SolarizeImage(new_image, threshold, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    SolarizeImage(new_image, threshold);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Compare two images.
 *
 * @param other [Object] other image
 * @return [-1, 0, 1, nil] the result of compare
 */
VALUE
Image_spaceship(VALUE self, VALUE other)
{
    Image *imageA, *imageB;
    const char *sigA, *sigB;
    int res;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    imageA = rm_check_destroyed(self);

    // If the other object isn't a Image object, then they can't be equal.
    if (!rb_obj_is_kind_of(other, Class_Image))
    {
        return Qnil;
    }

    imageB = rm_check_destroyed(other);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    SignatureImage(imageA, exception);
    CHECK_EXCEPTION();
    SignatureImage(imageB, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    SignatureImage(imageA);
    SignatureImage(imageB);
#endif
    sigA = rm_get_property(imageA, "signature");
    sigB = rm_get_property(imageB, "signature");
    if (!sigA || !sigB)
    {
        rb_raise(Class_ImageMagickError, "can't get image signature");
    }

    res = memcmp(sigA, sigB, 64);
    res = res > 0 ? 1 : (res < 0 ? -1 :  0);    // reduce to 1, -1, 0

    return INT2FIX(res);
}


/**
 * Count the number of channels from the specified list are in an image. Note
 * that this method also removes invalid channels based on the image.
 *
 * No Ruby usage (internal function)
 *
 * @param image the image
 * @param channels the channels
 * @return number of channels
 */
static unsigned long
count_channels(Image *image, ChannelType *channels)
{
    unsigned long ncolors = 0UL;

    if (image->colorspace != CMYKColorspace)
    {
        *channels = (ChannelType) (*channels & ~IndexChannel);  /* remove index channels from count */
    }
#if defined(IMAGEMAGICK_7)
    if ( image->alpha_trait == UndefinedPixelTrait )
#else
    if ( image->matte == MagickFalse )
#endif
    {
        *channels = (ChannelType) (*channels & ~OpacityChannel);  /* remove matte/alpha *channels from count */
    }

    if (*channels & RedChannel)
    {
        ncolors += 1;
    }
    if (*channels & GreenChannel)
    {
        ncolors += 1;
    }
    if (*channels & BlueChannel)
    {
        ncolors += 1;
    }
    if (*channels & IndexChannel)
    {
        ncolors += 1;
    }
    if (*channels & OpacityChannel)
    {
        ncolors += 1;
    }

    return ncolors;
}


/**
 * Fills the image with the specified color or colors, starting at the x,y coordinates associated
 * with the color and using the specified interpolation method.
 *
 * @overload sparse_color(method, x1, y1, color)
 * @overload sparse_color(method, x1, y1, color, x2, y2, color)
 * @overload sparse_color(method, x1, y1, color, x2, y2, color, ...)
 * @overload sparse_color(method, x1, y1, color, channel)
 * @overload sparse_color(method, x1, y1, color, x2, y2, color, channel)
 * @overload sparse_color(method, x1, y1, color, x2, y2, color, ..., channel)
 * @overload sparse_color(method, x1, y1, color, channel, ...)
 * @overload sparse_color(method, x1, y1, color, x2, y2, color, channel, ...)
 * @overload sparse_color(method, x1, y1, color, x2, y2, color, ..., channel, ...)
 *   @param method [Magick::SparseColorMethod] the method
 *   @param x1 [Float] One or more x.
 *   @param y1 [Float] One or more y.
 *   @param color [Magick::Pixel, String] One or more color
 *   @param channel [Magick::ChannelType] one or more ChannelType arguments
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_sparse_color(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    unsigned long x, nargs, ncolors;
    SparseColorMethod method;
    int n, exp;
    double * volatile args;
    ChannelType channels;
    MagickPixel pp;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    n = argc;
    channels = extract_channels(&argc, argv);
    n -= argc;  // n is now the number of channel arguments

    // After the channel arguments have been removed, and not counting the first
    // (method) argument, the number of arguments should be a multiple of 3.
    if (argc < 4 || argc % 3 != 1)
    {
        exp = (argc + 2) / 3 * 3;
        exp = max(exp, 3);
        rb_raise(rb_eArgError, "wrong number of arguments (expected at least %d, got %d)", n+exp+1,  n+argc);
    }

    // Get the method from the argument list
    VALUE_TO_ENUM(argv[0], method, SparseColorMethod);
    argv += 1;
    argc -= 1;

    // A lot of the following code is based on SparseColorOption, in wand/mogrify.c
    ncolors = count_channels(image, &channels);
    nargs = (argc / 3) * (2 + ncolors);

    // Allocate args from Ruby's memory so that GC will collect it if one of
    // the type conversions below raises an exception.
    args = ALLOC_N(double, nargs);
    memset(args, 0, nargs * sizeof(double));

    x = 0;
    n = 0;
    while (n < argc)
    {
        VALUE elem1 = argv[n++];
        VALUE elem2 = argv[n++];
        if (rm_check_num2dbl(elem1) && rm_check_num2dbl(elem2))
        {
            args[x++] = NUM2DBL(elem1);
            args[x++] = NUM2DBL(elem2);
        }
        else
        {
            xfree((void *) args);
            rb_raise(rb_eTypeError, "type mismatch: %s and %s given", rb_class2name(CLASS_OF(elem1)), rb_class2name(CLASS_OF(elem2)));
        }
        Color_to_MagickPixel(NULL, &pp, argv[n++]);
        if (channels & RedChannel)
        {
            args[x++] = pp.red / QuantumRange;
        }
        if (channels & GreenChannel)
        {
            args[x++] = pp.green / QuantumRange;
        }
        if (channels & BlueChannel)
        {
            args[x++] = pp.blue / QuantumRange;
        }
        if (channels & IndexChannel)
        {
            args[x++] = pp.index / QuantumRange;
        }
        if (channels & OpacityChannel)
        {
#if defined(IMAGEMAGICK_7)
            args[x++] = pp.alpha / QuantumRange;
#else
            args[x++] = pp.opacity / QuantumRange;
#endif
        }
    }

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    new_image = SparseColorImage(image, method, nargs, args, exception);
    CHANGE_RESULT_CHANNEL_MASK(new_image);
    END_CHANNEL_MASK(image);
#else
    new_image = SparseColorImage(image, channels, method, nargs, args, exception);
#endif
    xfree((void *) args);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Splice a solid color into the part of the image specified by the x, y, width,
 * and height arguments. If the color argument is specified it must be a color
 * name or Pixel.
 *
 * @overload splice(x, y, width, height, color = self.background_color)
 *   @param x [Numeric] Describe the rectangle to be spliced.
 *   @param y [Numeric] Describe the rectangle to be spliced.
 *   @param width [Numeric] Describe the rectangle to be spliced.
 *   @param height [Numeric] Describe the rectangle to be spliced.
 *   @param color [Magick::Pixel, String] The color to be spliced.
 *   @return [Magick::Image] a new image
 *   @see Image#chop
 */
VALUE
Image_splice(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    PixelColor color, old_color;
    RectangleInfo rectangle;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 4:
            // use background color
            color = image->background_color;
            break;
        case 5:
            // Convert color argument to PixelColor
            Color_to_PixelColor(&color, argv[4]);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 4 or 5)", argc);
            break;
    }

    rectangle.x      = NUM2LONG(argv[0]);
    rectangle.y      = NUM2LONG(argv[1]);
    rectangle.width  = NUM2ULONG(argv[2]);
    rectangle.height = NUM2ULONG(argv[3]);

    exception = AcquireExceptionInfo();

    // Swap in color for the duration of this call.
    old_color = image->background_color;
    image->background_color = color;
    new_image = SpliceImage(image, &rectangle, exception);
    image->background_color = old_color;

    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Randomly displace each pixel in a block defined by "radius".
 *
 * @overload spread(radius = 3.0)
 *   @param radius [Float] The radius
 *   @return [Magick::Image] a new image
 */
VALUE
Image_spread(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double radius = 3.0;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 1:
            radius = NUM2DBL(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
            break;
    }

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    new_image = SpreadImage(image, image->interpolate, radius, exception);
#else
    new_image = SpreadImage(image, radius, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Get the Boolean value that indicates the first image in an animation.
 *
 * @return [Boolean] true or false
 */
VALUE
Image_start_loop(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, start_loop, boolean);
}

/**
 * Set the Boolean value that indicates the first image in an animation.
 *
 * @param val [Boolean] true or false
 * @return [Boolean] the given value
 */
VALUE
Image_start_loop_eq(VALUE self, VALUE val)
{
    IMPLEMENT_ATTR_WRITER(Image, start_loop, boolean);
}


/**
 * Hides a digital watermark in the receiver. You can retrieve the watermark by reading the file
 * with the stegano: prefix, thereby proving the authenticity of the file.
 *
 * The watermarked image must be saved in a lossless RGB format such as MIFF, or PNG. You cannot
 * save a watermarked image in a lossy format such as JPEG or a pseudocolor format such as GIF. Once
 * written, the file must not be modified or processed in any way.
 *
 * @param watermark_image [Magick::Image, Magick::ImageList] Either an imagelist or an image
 * @param offset [Numeric] the start position within the image to hide the watermark.
 * @return [Magick::Image] a new image
 */
VALUE
Image_stegano(VALUE self, VALUE watermark_image, VALUE offset)
{
    Image *image, *new_image;
    VALUE wm_image;
    Image *watermark;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    wm_image = rm_cur_image(watermark_image);
    watermark = rm_check_destroyed(wm_image);

    image->offset = NUM2LONG(offset);

    exception = AcquireExceptionInfo();
    new_image = SteganoImage(image, watermark, exception);
    rm_check_exception(exception, new_image, DestroyOnError);

    DestroyExceptionInfo(exception);

    RB_GC_GUARD(wm_image);

    return rm_image_new(new_image);
}


/**
 * Combine two images and produces a single image that is the composite of a left and right image of
 * a stereo pair. Special red-green stereo glasses are required to view this effect.
 *
 * @param offset_image_arg [Magick::Image, Magick::ImageList] Either an imagelist or an image.
 * @return [Magick::Image] a new image
 */
VALUE
Image_stereo(VALUE self, VALUE offset_image_arg)
{
    Image *image, *new_image;
    VALUE offset_image;
    Image *offset;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    offset_image = rm_cur_image(offset_image_arg);
    offset = rm_check_destroyed(offset_image);

    exception = AcquireExceptionInfo();
    new_image = StereoImage(image, offset, exception);
    rm_check_exception(exception, new_image, DestroyOnError);

    DestroyExceptionInfo(exception);

    RB_GC_GUARD(offset_image);

    return rm_image_new(new_image);
}


/**
 * Return the image's storage class (a.k.a. storage type, class type). If DirectClass then the
 * pixels contain valid RGB or CMYK colors.  If PseudoClass then the image has a colormap referenced
 * by the pixel's index member.
 *
 * @return [Magick::ClassType] the storage class
 */
VALUE
Image_class_type(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return ClassType_find(image->storage_class);
}


/**
 * Change the image's storage class.
 *
 * @param new_class_type [Magick::ClassType] the storage class
 * @return [Magick::ClassType] the given value
 */
VALUE
Image_class_type_eq(VALUE self, VALUE new_class_type)
{
    Image *image;
    ClassType class_type;
    QuantizeInfo qinfo;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_frozen(self);

    VALUE_TO_ENUM(new_class_type, class_type, ClassType);

    if (class_type == UndefinedClass)
    {
        rb_raise(rb_eArgError, "Invalid class type specified.");
    }

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
#endif

    if (image->storage_class == PseudoClass && class_type == DirectClass)
    {
#if defined(IMAGEMAGICK_7)
        SyncImage(image, exception);
        CHECK_EXCEPTION();
#else
        SyncImage(image);
#endif
        magick_free(image->colormap);
        image->colormap = NULL;
    }
    else if (image->storage_class == DirectClass && class_type == PseudoClass)
    {
        GetQuantizeInfo(&qinfo);
        qinfo.number_colors = QuantumRange+1;
#if defined(IMAGEMAGICK_7)
        QuantizeImage(&qinfo, image, exception);
        CHECK_EXCEPTION();
#else
        QuantizeImage(&qinfo, image);
#endif
    }

#if defined(IMAGEMAGICK_7)
    SetImageStorageClass(image, class_type, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    SetImageStorageClass(image, class_type);
#endif
    return new_class_type;
}


/**
 * Replace the pixels in the specified rectangle with the pixels in the pixels array.
 *
 * - This is the complement of get_pixels. The array object returned by get_pixels is suitable for
 *   use as the "new_pixels" argument.
 *
 * @param x_arg [Numeric] x position of start of region
 * @param y_arg [Numeric] y position of start of region
 * @param cols_arg [Numeric] width of region
 * @param rows_arg [Numeric] height of region
 * @param new_pixels [Array<Magick::Pixel>] the replacing pixels
 * @return [Magick::Image] self
 */
VALUE
Image_store_pixels(VALUE self, VALUE x_arg, VALUE y_arg, VALUE cols_arg,
                   VALUE rows_arg, VALUE new_pixels)
{
    Image *image;
    Pixel *pixel;
    VALUE new_pixel;
    long n, size;
    long x, y;
    unsigned long cols, rows;
    unsigned int okay;
    ExceptionInfo *exception;
#if defined(IMAGEMAGICK_7)
    Quantum *pixels;
#else
    PixelPacket *pixels;
#endif

    image = rm_check_destroyed(self);

    x = NUM2LONG(x_arg);
    y = NUM2LONG(y_arg);
    cols = NUM2ULONG(cols_arg);
    rows = NUM2ULONG(rows_arg);
    if (x < 0 || y < 0 || x+cols > image->columns || y+rows > image->rows)
    {
        rb_raise(rb_eRangeError, "geometry (%lux%lu%+ld%+ld) exceeds image bounds",
                 cols, rows, x, y);
    }

    size = (long)(cols * rows);
    new_pixels = rb_Array(new_pixels);
    rm_check_ary_len(new_pixels, size);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    okay = SetImageStorageClass(image, DirectClass, exception);
    CHECK_EXCEPTION();
    if (!okay)
    {
        DestroyExceptionInfo(exception);
        rb_raise(Class_ImageMagickError, "SetImageStorageClass failed. Can't store pixels.");
    }
#else
    okay = SetImageStorageClass(image, DirectClass);
    rm_check_image_exception(image, RetainOnError);
    if (!okay)
    {
        rb_raise(Class_ImageMagickError, "SetImageStorageClass failed. Can't store pixels.");
    }
    exception = AcquireExceptionInfo();
#endif

    // Get a pointer to the pixels. Replace the values with the PixelPackets
    // from the pixels argument.
    {
        pixels = GetAuthenticPixels(image, x, y, cols, rows, exception);
        CHECK_EXCEPTION();

        if (pixels)
        {
#if defined(IMAGEMAGICK_6)
            IndexPacket *indexes = GetAuthenticIndexQueue(image);
#endif
            for (n = 0; n < size; n++)
            {
                new_pixel = rb_ary_entry(new_pixels, n);
                if (CLASS_OF(new_pixel) != Class_Pixel)
                {
                    DestroyExceptionInfo(exception);
                    rb_raise(rb_eTypeError, "Item in array should be a Pixel.");
                }
                Data_Get_Struct(new_pixel, Pixel, pixel);
#if defined(IMAGEMAGICK_7)
                SetPixelRed(image,   pixel->red,   pixels);
                SetPixelGreen(image, pixel->green, pixels);
                SetPixelBlue(image,  pixel->blue,  pixels);
                SetPixelAlpha(image, pixel->alpha, pixels);
                SetPixelBlack(image, pixel->black, pixels);
                pixels += GetPixelChannels(image);
#else
                SetPixelRed(pixels, pixel->red);
                SetPixelGreen(pixels, pixel->green);
                SetPixelBlue(pixels, pixel->blue);
                SetPixelOpacity(pixels, pixel->opacity);
                if (indexes)
                {
                    SetPixelIndex(indexes + n, pixel->black);
                }
                pixels++;
#endif
            }
            SyncAuthenticPixels(image, exception);
            CHECK_EXCEPTION();
        }

        DestroyExceptionInfo(exception);
    }

    RB_GC_GUARD(new_pixel);

    return self;
}


/**
 * Strips an image of all profiles and comments.
 *
 * @return [Magick::Image] self
 */
VALUE
Image_strip_bang(VALUE self)
{
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    Image *image = rm_check_frozen(self);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    StripImage(image, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    StripImage(image);
    rm_check_image_exception(image, RetainOnError);
#endif
    return self;
}


/**
 * Swirl the pixels about the center of the image, where degrees indicates the sweep of the arc
 * through which each pixel is moved. You get a more dramatic effect as the degrees move from 1 to
 * 360.
 *
 * @param degrees_obj [Float] the degrees
 * @return [Magick::Image] a new image
 */
VALUE
Image_swirl(VALUE self, VALUE degrees_obj)
{
    Image *image, *new_image;
    ExceptionInfo *exception;
    double degrees = NUM2DBL(degrees_obj);

    image = rm_check_destroyed(self);

    exception = AcquireExceptionInfo();

#if defined(IMAGEMAGICK_7)
    new_image = SwirlImage(image, degrees, image->interpolate, exception);
#else
    new_image = SwirlImage(image, degrees, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Emulates Magick++'s floodFillTexture.
 *
 * If the FloodfillMethod method is specified, flood-fills texture across pixels starting at the
 * target pixel and matching the specified color.
 *
 * If the FillToBorderMethod method is specified, flood-fills 'texture across pixels starting at the
 * target pixel and stopping at pixels matching the specified color.'
 *
 * @param color_obj [Magick::Pixel, String] the color
 * @param texture_obj [Magick::Image, Magick::ImageList] the texture to fill
 * @param x_obj [Numeric] the x position
 * @param y_obj [Numeric] the y position
 * @param method_obj [Magick::PaintMethod] the method to call (FloodfillMethod or FillToBorderMethod)
 * @return [Magick::Image] a new image
 */
VALUE
Image_texture_flood_fill(VALUE self, VALUE color_obj, VALUE texture_obj,
                         VALUE x_obj, VALUE y_obj, VALUE method_obj)
{
    Image *image, *new_image;
    Image *texture_image;
    PixelColor color;
    VALUE texture;
    DrawInfo *draw_info;
    long x, y;
    PaintMethod method;
    MagickPixel color_mpp;
    MagickBooleanType invert;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

    Color_to_PixelColor(&color, color_obj);
    texture = rm_cur_image(texture_obj);
    texture_image = rm_check_destroyed(texture);

    x = NUM2LONG(x_obj);
    y = NUM2LONG(y_obj);

    if ((unsigned long)x > image->columns || (unsigned long)y > image->rows)
    {
        rb_raise(rb_eArgError, "target out of range. %ldx%ld given, image is %"RMIuSIZE"x%"RMIuSIZE"",
                 x, y, image->columns, image->rows);
    }

    VALUE_TO_ENUM(method_obj, method, PaintMethod);
    if (method != FillToBorderMethod && method != FloodfillMethod)
    {
        rb_raise(rb_eArgError, "paint method must be FloodfillMethod or "
                 "FillToBorderMethod (%d given)", (int)method);
    }

    draw_info = CloneDrawInfo(NULL, NULL);
    if (!draw_info)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }

    draw_info->fill_pattern = rm_clone_image(texture_image);
    new_image = rm_clone_image(image);


    rm_init_magickpixel(new_image, &color_mpp);
    if (method == FillToBorderMethod)
    {
        invert = MagickTrue;
        color_mpp.red   = (MagickRealType) image->border_color.red;
        color_mpp.green = (MagickRealType) image->border_color.green;
        color_mpp.blue  = (MagickRealType) image->border_color.blue;
    }
    else
    {
        invert = MagickFalse;
        color_mpp.red   = (MagickRealType) color.red;
        color_mpp.green = (MagickRealType) color.green;
        color_mpp.blue  = (MagickRealType) color.blue;
    }

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    FloodfillPaintImage(new_image, draw_info, &color_mpp, x, y, invert, exception);
    DestroyDrawInfo(draw_info);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    FloodfillPaintImage(new_image, DefaultChannels, draw_info, &color_mpp, x, y, invert);

    DestroyDrawInfo(draw_info);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    RB_GC_GUARD(texture);

    return rm_image_new(new_image);
}


/**
 * Change the value of individual pixels based on the intensity of each pixel compared to
 * threshold. The result is a high-contrast, two color image.
 *
 * @param threshold_obj [Float] the threshold
 * @return [Magick::Image] a new image
 */
VALUE
Image_threshold(VALUE self, VALUE threshold_obj)
{
    Image *image, *new_image;
    double threshold = NUM2DBL(threshold_obj);
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    BilevelImage(new_image, threshold, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    BilevelImageChannel(new_image, DefaultChannels, threshold);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Call one of the xxxxThresholdImage methods.
 *
 * No Ruby usage (internal function)
 *
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @param thresholder which xxxxThresholdImage method to call
 * @return a new image
 */
static
VALUE threshold_image(int argc, VALUE *argv, VALUE self, thresholder_t thresholder)
{
    Image *image, *new_image;
    double red, green, blue, alpha;
    char ctarg[200];
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 4:
            red     = NUM2DBL(argv[0]);
            green   = NUM2DBL(argv[1]);
            blue    = NUM2DBL(argv[2]);
            alpha   = get_named_alpha_value(argv[3]);
            snprintf(ctarg, sizeof(ctarg), "%f,%f,%f,%f", red, green, blue, QuantumRange - alpha);
            break;
        case 3:
            red     = NUM2DBL(argv[0]);
            green   = NUM2DBL(argv[1]);
            blue    = NUM2DBL(argv[2]);
            snprintf(ctarg, sizeof(ctarg), "%f,%f,%f", red, green, blue);
            break;
        case 2:
            red     = NUM2DBL(argv[0]);
            green   = NUM2DBL(argv[1]);
            snprintf(ctarg, sizeof(ctarg), "%f,%f", red, green);
            break;
        case 1:
            red     = NUM2DBL(argv[0]);
            snprintf(ctarg, sizeof(ctarg), "%f", red);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 to 4)", argc);
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    (thresholder)(new_image, ctarg, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    (thresholder)(new_image, ctarg);
    rm_check_image_exception(new_image, DestroyOnError);
#endif

    return rm_image_new(new_image);
}


/**
 * Fast resize for thumbnail images.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Uses BoxFilter, blur attribute of input image
 *
 * @param bang whether the bang (!) version of the method was called
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @return self if bang, otherwise a new image
 * @see Image_thumbnail
 * @see Image_thumbnail_bang
 */
static VALUE
thumbnail(int bang, int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    unsigned long columns, rows;
    double scale_arg, drows, dcols;
    char image_geometry[MaxTextExtent];
    RectangleInfo geometry;
    ExceptionInfo *exception;

    Data_Get_Struct(self, Image, image);

    switch (argc)
    {
        case 2:
            columns = NUM2ULONG(argv[0]);
            rows = NUM2ULONG(argv[1]);
            if (columns == 0 || rows == 0)
            {
                rb_raise(rb_eArgError, "invalid result dimension (%lu, %lu given)", columns, rows);
            }
            break;
        case 1:
            scale_arg = NUM2DBL(argv[0]);
            if (scale_arg < 0.0)
            {
                rb_raise(rb_eArgError, "invalid scale value (%g given)", scale_arg);
            }
            drows = scale_arg * image->rows + 0.5;
            dcols = scale_arg * image->columns + 0.5;
            if (drows > (double)ULONG_MAX || dcols > (double)ULONG_MAX)
            {
                rb_raise(rb_eRangeError, "resized image too big");
            }
            rows = (unsigned long) drows;
            columns = (unsigned long) dcols;
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or 2)", argc);
            break;
    }

    snprintf(image_geometry, sizeof(image_geometry), "%lux%lu", columns, rows);

    exception = AcquireExceptionInfo();
    ParseRegionGeometry(image, image_geometry, &geometry, exception);
    rm_check_exception(exception, image, RetainOnError);

    new_image = ThumbnailImage(image, geometry.width, geometry.height, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    if (bang)
    {
        rm_ensure_result(new_image);
        UPDATE_DATA_PTR(self, new_image);
        rm_image_destroy(image);
        return self;
    }

    return rm_image_new(new_image);
}


/**
 * The thumbnail method is a fast resizing method suitable for use when the size of the resulting
 * image is < 10% of the original.
 *
 * @overload thumbnail(scale)
 *   @param scale [Float] The desired size represented as a floating-point number. For example, to
 *     make a thumbnail that is 9.5% of the size of the original image, use 0.095.
 *
 * @overload thumbnail(cols, rows)
 *   @param cols [Numeric] The desired width in pixels.
 *
 * @return [Magick::Image] a new image
 * @see Image#thumbnail!
 */
VALUE
Image_thumbnail(int argc, VALUE *argv, VALUE self)
{
    rm_check_destroyed(self);
    return thumbnail(False, argc, argv, self);
}


/**
 * The thumbnail method is a fast resizing method suitable for use when the size of the resulting
 * image is < 10% of the original.  In-place form of {Image#thumbnail}.
 *
 * @overload thumbnail!(scale)
 *   @param scale [Float] The desired size represented as a floating-point number. For example, to
 *     make a thumbnail that is 9.5% of the size of the original image, use 0.095.
 *
 * @overload thumbnail!(cols, rows)
 *   @param cols [Numeric] The desired width in pixels.
 *
 * @return [Magick::Image] a new image
 * @see Image#thumbnail
 */
VALUE
Image_thumbnail_bang(int argc, VALUE *argv, VALUE self)
{
    rm_check_frozen(self);
    return thumbnail(True, argc, argv, self);
}


/**
 * Get the number of ticks per second.
 * This attribute is used in conjunction with the delay attribute to establish the amount of time
 * that must elapse between frames in an animation.The default is 100.
 *
 * @return [Numeric] ticks per second
 */
VALUE
Image_ticks_per_second(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return INT2FIX(image->ticks_per_second);
}


/**
 * Set the number of ticks per second.
 * This attribute is used in conjunction with the delay attribute to establish the amount of time
 * that must elapse between frames in an animation.The default is 100.
 *
 * @param tps [Numeric] ticks per second
 * @return [Numeric] the given value
 */
VALUE
Image_ticks_per_second_eq(VALUE self, VALUE tps)
{
    Image *image = rm_check_frozen(self);
    image->ticks_per_second = NUM2ULONG(tps);
    return tps;
}


/**
 * Applies a color vector to each pixel in the image.
 *
 * - Alpha values are percentages: 0.10 -> 10%.
 *
 * @overload tint(tint, red_alpha, green_alpha = red_alpha, blue_alpha = red_alpha, alpha_alpha = 1.0)
 *   @param tint [Magick::Pixel, String] the color name
 *   @param red_alpha [Float] the red value
 *   @param green_alpha [Float] the green value
 *   @param blue_alpha [Float] the blue value
 *   @param alpha_alpha [Float] the alpha value
 *   @return a new image
 */
VALUE
Image_tint(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    PixelColor tint;
    double red_pct_opaque, green_pct_opaque, blue_pct_opaque;
    double alpha_pct_opaque = 1.0;
    char alpha[50];
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 2:
            red_pct_opaque   = NUM2DBL(argv[1]);
            green_pct_opaque = blue_pct_opaque = red_pct_opaque;
            break;
        case 3:
            red_pct_opaque   = NUM2DBL(argv[1]);
            green_pct_opaque = NUM2DBL(argv[2]);
            blue_pct_opaque  = red_pct_opaque;
            break;
        case 4:
            red_pct_opaque     = NUM2DBL(argv[1]);
            green_pct_opaque   = NUM2DBL(argv[2]);
            blue_pct_opaque    = NUM2DBL(argv[3]);
            break;
        case 5:
            red_pct_opaque     = NUM2DBL(argv[1]);
            green_pct_opaque   = NUM2DBL(argv[2]);
            blue_pct_opaque    = NUM2DBL(argv[3]);
            alpha_pct_opaque   = NUM2DBL(argv[4]);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 to 5)", argc);
            break;
    }

    if (red_pct_opaque < 0.0 || green_pct_opaque < 0.0
        || blue_pct_opaque < 0.0 || alpha_pct_opaque < 0.0)
    {
        rb_raise(rb_eArgError, "alpha percentages must be non-negative.");
    }

    snprintf(alpha, sizeof(alpha),
            "%g,%g,%g,%g", red_pct_opaque*100.0, green_pct_opaque*100.0,
            blue_pct_opaque*100.0, alpha_pct_opaque*100.0);

    Color_to_PixelColor(&tint, argv[0]);
    exception = AcquireExceptionInfo();

#if defined(IMAGEMAGICK_7)
    new_image = TintImage(image, alpha, &tint, exception);
#else
    new_image = TintImage(image, alpha, tint, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Return a "blob" (a String) from the image.
 *
 * - The magick member of the Image structure determines the format of the
 *   returned blob (GIG, JPEG,  PNG, etc.)
 *
 * @return [String] the blob
 * @see Image#from_blob
 */
VALUE
Image_to_blob(VALUE self)
{
    Image *image;
    Info *info;
    const MagickInfo *magick_info;
    VALUE info_obj;
    VALUE blob_str;
    void *blob = NULL;
    size_t length = 2048;       // Do what Magick++ does
    ExceptionInfo *exception;

    // The user can specify the depth (8 or 16, if the format supports
    // both) and the image format by setting the depth and format
    // values in the info parm block.
    info_obj = rm_info_new();
    Data_Get_Struct(info_obj, Info, info);

    image = rm_check_destroyed(self);

    exception = AcquireExceptionInfo();

    // Copy the depth and magick fields to the Image
    if (info->depth != 0)
    {
#if defined(IMAGEMAGICK_7)
        SetImageDepth(image, info->depth, exception);
        CHECK_EXCEPTION();
#else
        SetImageDepth(image, info->depth);
        rm_check_image_exception(image, RetainOnError);
#endif
    }

    if (*info->magick)
    {
        SetImageInfo(info, MagickTrue, exception);
        CHECK_EXCEPTION();

        if (*info->magick == '\0')
        {
            return Qnil;
        }
        strlcpy(image->magick, info->magick, sizeof(image->magick));
    }

    // Fix #2844 - libjpeg exits when image is 0x0
    magick_info = GetMagickInfo(image->magick, exception);
    CHECK_EXCEPTION();

    if (magick_info)
    {
        if (  (!rm_strcasecmp(magick_info->name, "JPEG")
               || !rm_strcasecmp(magick_info->name, "JPG"))
              && (image->rows == 0 || image->columns == 0))
        {
            rb_raise(rb_eRuntimeError, "Can't convert %"RMIuSIZE"x%"RMIuSIZE" %.4s image to a blob",
                     image->columns, image->rows, magick_info->name);
        }
    }

    rm_sync_image_options(image, info);

    blob = ImageToBlob(info, image, &length, exception);
    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    if (length == 0 || !blob)
    {
        return Qnil;
    }

    blob_str = rb_str_new(blob, length);

    magick_free((void*)blob);

    RB_GC_GUARD(info_obj);
    RB_GC_GUARD(blob_str);

    return blob_str;
}


/**
 * Return a color name for the color intensity specified by the Magick::Pixel argument.
 *
 * @param pixel_arg [Magick::Pixel, String] the pixel
 * @return [String] the color name
 */
VALUE
Image_to_color(VALUE self, VALUE pixel_arg)
{
    Image *image;
    PixelColor pixel;
    ExceptionInfo *exception;
    char name[MaxTextExtent];

    image = rm_check_destroyed(self);
    Color_to_PixelColor(&pixel, pixel_arg);
    exception = AcquireExceptionInfo();

#if defined(IMAGEMAGICK_7)
    pixel.depth = MAGICKCORE_QUANTUM_DEPTH;
    pixel.colorspace = image->colorspace;
#endif

    // QueryColorname returns False if the color represented by the PixelPacket
    // doesn't have a "real" name, just a sequence of hex digits. We don't care
    // about that.

    QueryColorname(image, &pixel, AllCompliance, name, exception);
    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);

    return rb_str_new2(name);

}


/**
 * Alias for {Image#number_colors}.
 *
 * @return [Numeric] number of unique colors
 * @see Image#number_colors
 */
VALUE
Image_total_colors(VALUE self)
{
    return Image_number_colors(self);
}


/**
 * Return the total ink density for a CMYK image.
 *
 * @return [Float] the total ink density
 */
VALUE
Image_total_ink_density(VALUE self)
{
    Image *image;
    double density;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    density = GetImageTotalInkDensity(image, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    density = GetImageTotalInkDensity(image);
    rm_check_image_exception(image, RetainOnError);
#endif

    return rb_float_new(density);
}


/**
 * Changes the opacity value of all the pixels that match color to the value specified by
 * opacity. By default the pixel must match exactly, but you can specify a tolerance level by
 * setting the fuzz attribute on the image.
 *
 * - Default alpha is Magick::TransparentAlpha.
 * - Can use Magick::OpaqueAlpha or Magick::TransparentAlpha, or any
 *   value >= 0 && <= QuantumRange.
 * - Use Image#fuzz= to define the tolerance level.
 *
 * @overload transparent(color, alpha: Magick::TransparentAlpha)
 *   @param color [Magick::Pixel, String] The color
 *   @param alpha alpha [Numeric] the alpha
 *   @return [Magick::Image] a new image
 */
VALUE
Image_transparent(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    MagickPixel color;
    Quantum alpha = TransparentAlpha;
    MagickBooleanType okay;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif


    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 2:
            alpha = get_named_alpha_value(argv[1]);
        case 1:
            Color_to_MagickPixel(image, &color, argv[0]);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or 2)", argc);
            break;
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    okay = TransparentPaintImage(new_image, &color, alpha, MagickFalse, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    okay = TransparentPaintImage(new_image, &color, QuantumRange - alpha, MagickFalse);
    rm_check_image_exception(new_image, DestroyOnError);
#endif
    if (!okay)
    {
        // Force exception
        DestroyImage(new_image);
        rm_magick_error("TransparentPaintImage failed with no explanation");
    }

    return rm_image_new(new_image);
}


/**
 * Changes the opacity value associated with any pixel between low and high to the value defined by
 * opacity.
 *
 * As there is one fuzz value for the all the channels, the transparent method is not suitable for
 * the operations like chroma, where the tolerance for similarity of two color components (RGB) can
 * be different, Thus we define this method take two target pixels (one low and one high) and all
 * the pixels of an image which are lying between these two pixels are made transparent.
 *
 * @overload transparent_chroma(low, high, invert, alpha: Magick::TransparentAlpha)
 *   @param low [Magick::Pixel, String] The low ends of the pixel range
 *   @param high [Magick::Pixel, String] The high ends of the pixel range
 *   @param invert [Boolean] If true, all pixels outside the range are set to opacity.
 *   @param alpha [Numeric] The desired alpha.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_transparent_chroma(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    Quantum alpha = TransparentAlpha;
    MagickPixel low, high;
    MagickBooleanType invert = MagickFalse;
    MagickBooleanType okay;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

    switch (argc)
    {
        case 4:
            if (TYPE(argv[argc - 1]) == T_HASH)
            {
                invert = RTEST(argv[3]);
            }
            else
            {
                invert = RTEST(argv[2]);
            }
        case 3:
            alpha = get_named_alpha_value(argv[argc - 1]);
        case 2:
            Color_to_MagickPixel(image, &high, argv[1]);
            Color_to_MagickPixel(image, &low, argv[0]);
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 2, 3 or 4)", argc);
            break;
    }

    new_image = rm_clone_image(image);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    okay = TransparentPaintImageChroma(new_image, &low, &high, alpha, invert, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    okay = TransparentPaintImageChroma(new_image, &low, &high, QuantumRange - alpha, invert);
    rm_check_image_exception(new_image, DestroyOnError);
#endif
    if (!okay)
    {
        // Force exception
        DestroyImage(new_image);
        rm_magick_error("TransparentPaintImageChroma failed with no explanation");
    }

    return rm_image_new(new_image);
}


/**
 * Return the name of the transparent color as a String.
 *
 * @return [String] the name of the transparent color
 */
VALUE
Image_transparent_color(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return rm_pixelcolor_to_color_name(image, &image->transparent_color);
}


/**
 * Set the the transparent color to the specified color spec.
 *
 * @param color [Magick::Pixel, String] the transparent color
 * @return [Magick::Pixel, String] the given color
 */
VALUE
Image_transparent_color_eq(VALUE self, VALUE color)
{
    Image *image = rm_check_frozen(self);
    Color_to_PixelColor(&image->transparent_color, color);
    return color;
}


/**
 * Creates a horizontal mirror image by reflecting the pixels around the central y-axis while
 * rotating them by 90 degrees.
 *
 * @return [Magick::Image] a new image
 * @see Image#transpose!
 */
VALUE
Image_transpose(VALUE self)
{
    rm_check_destroyed(self);
    return crisscross(False, self, TransposeImage);
}


/**
 * Creates a horizontal mirror image by reflecting the pixels around the central y-axis while
 * rotating them by 90 degrees.
 * In-place form of {Image#transpose}.
 *
 * @return [Magick::Image] a new image
 * @see Image#transpose
 */
VALUE
Image_transpose_bang(VALUE self)
{
    rm_check_frozen(self);
    return crisscross(True, self, TransposeImage);
}


/**
 * Creates a vertical mirror image by reflecting the pixels around the central x-axis while rotating
 * them by 270 degrees
 *
 * @return [Magick::Image] a new image
 * @see Image#transverse!
 */
VALUE
Image_transverse(VALUE self)
{
    rm_check_destroyed(self);
    return crisscross(False, self, TransverseImage);
}

/**
 * Creates a vertical mirror image by reflecting the pixels around the central x-axis while rotating
 * them by 270 degrees
 * In-place form of {Image#transverse}.
 *
 * @return [Magick::Image] a new image
 * @see Image#transverse
 */
VALUE
Image_transverse_bang(VALUE self)
{
    rm_check_frozen(self);
    return crisscross(True, self, TransverseImage);
}


/**
 * Convenient front-end to CropImage.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Respects fuzz attribute.
 *
 * @param bang whether the bang (!) version of the method was called
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @return self if bang, otherwise a new image
 * @see Image_trim
 * @see Image_trim_bang
 */
static VALUE
trimmer(int bang, int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    ExceptionInfo *exception;
    int reset_page = 0;

    switch (argc)
    {
        case 1:
            reset_page = RTEST(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (expecting 0 or 1, got %d)", argc);
            break;
    }

    Data_Get_Struct(self, Image, image);

    exception = AcquireExceptionInfo();
    new_image = TrimImage(image, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    rm_ensure_result(new_image);

    if (reset_page)
    {
        ResetImagePage(new_image, "0x0+0+0");
    }

    if (bang)
    {
        UPDATE_DATA_PTR(self, new_image);
        rm_image_destroy(image);
        return self;
    }

    return rm_image_new(new_image);
}


/**
 * Removes the edges that are exactly the same color as the corner pixels. Use the fuzz attribute to
 * make trim remove edges that are nearly the same color as the corner pixels.
 *
 * @overload trim(reset = false)
 *   @param reset [Boolean] The trim method retains the offset information in the cropped
 *     image. This may cause the image to appear to be surrounded by blank or black space when viewed
 *     with an external viewer. This only occurs when the image is saved in a format (such as GIF)
 *     that saves offset information. To reset the offset data, use true as the argument to trim.
 *   @return [Magick::Image] a new image
 *   @see Image#trim!
 */
VALUE
Image_trim(int argc, VALUE *argv, VALUE self)
{
    rm_check_destroyed(self);
    return trimmer(False, argc, argv, self);
}


/**
 * Removes the edges that are exactly the same color as the corner pixels. Use the fuzz attribute to
 * make trim remove edges that are nearly the same color as the corner pixels.
 *
 * @overload trim!(reset = false)
 *   @param reset [Boolean] The trim method retains the offset information in the cropped
 *     image. This may cause the image to appear to be surrounded by blank or black space when viewed
 *     with an external viewer. This only occurs when the image is saved in a format (such as GIF)
 *     that saves offset information. To reset the offset data, use true as the argument to trim.
 *   @return [Magick::Image] a new image
 *   @see Image#trim
 */
VALUE
Image_trim_bang(int argc, VALUE *argv, VALUE self)
{
    rm_check_frozen(self);
    return trimmer(True, argc, argv, self);
}


/**
 * Get the direction that the image gravitates within the composite.
 *
 * @return [Magick::GravityType] the image gravity
 */
VALUE Image_gravity(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return GravityType_find(image->gravity);
}


/**
 * Set the direction that the image gravitates within the composite.
 *
 * @param gravity [Magick::GravityType] the image gravity
 * @return [Magick::GravityType] the given value
 */
VALUE Image_gravity_eq(VALUE self, VALUE gravity)
{
    Image *image = rm_check_frozen(self);
    VALUE_TO_ENUM(gravity, image->gravity, GravityType);
    return gravity;
}


/**
 * Get the image type classification.
 * For example, GrayscaleType.
 * Don't confuse this attribute with the format, that is "GIF" or "JPG".
 *
 * @return [Magick::ImageType] the image type
 */
VALUE Image_image_type(VALUE self)
{
    Image *image;
    ImageType type;
#if defined(IMAGEMAGICK_6)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);
#if defined(IMAGEMAGICK_7)
    type = GetImageType(image);
#else
    exception = AcquireExceptionInfo();
    type = GetImageType(image, exception);
    CHECK_EXCEPTION();

    DestroyExceptionInfo(exception);
#endif

    return ImageType_find(type);
}


/**
 * Set the image type classification.
 *
 * @param image_type [Magick::ImageType] the image type
 * @return [Magick::ImageType] the given type
 */
VALUE Image_image_type_eq(VALUE self, VALUE image_type)
{
    Image *image;
    ImageType type;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_frozen(self);
    VALUE_TO_ENUM(image_type, type, ImageType);
#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    SetImageType(image, type, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    SetImageType(image, type);
#endif
    return image_type;
}


/**
 * Removes an artifact from the image and returns its value.
 *
 * @param artifact [String] the artifact
 * @return [Magick::Image] self
 * @see Image#define
 */
VALUE
Image_undefine(VALUE self, VALUE artifact)
{
    Image *image;
    char *key;

    image = rm_check_frozen(self);
    key = StringValueCStr(artifact);
    DeleteImageArtifact(image, key);
    return self;
}


/**
 * Constructs a new image with one pixel for each unique color in the image. The new image has 1
 * row. The row has 1 column for each unique pixel in the image.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_unique_colors(VALUE self)
{
    Image *image, *new_image;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    exception = AcquireExceptionInfo();

    new_image = UniqueImageColors(image, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Get the units of image resolution.
 *
 * @return [Magick::ResolutionType] the resolution type
 */
VALUE
Image_units(VALUE self)
{
    Image *image = rm_check_destroyed(self);
    return ResolutionType_find(image->units);
}


/**
 * Set the units of image resolution.
 *
 * @param restype [Magick::ResolutionType] the resolution type
 * @return [Magick::ResolutionType] the given value
 */
VALUE
Image_units_eq(VALUE self, VALUE restype)
{
    ResolutionType units;
    Image *image = rm_check_frozen(self);

    VALUE_TO_ENUM(restype, units, ResolutionType);

    if (image->units != units)
    {
        switch (image->units)
        {
            case PixelsPerInchResolution:
                if (units == PixelsPerCentimeterResolution)
                {
#if defined(IMAGEMAGICK_7)
                    image->resolution.x /= 2.54;
                    image->resolution.y /= 2.54;
#else
                    image->x_resolution /= 2.54;
                    image->y_resolution /= 2.54;
#endif
                }
                break;

            case PixelsPerCentimeterResolution:
                if (units == PixelsPerInchResolution)
                {
#if defined(IMAGEMAGICK_7)
                    image->resolution.x *= 2.54;
                    image->resolution.y *= 2.54;
#else
                    image->x_resolution *= 2.54;
                    image->y_resolution *= 2.54;
#endif
                }
                break;

            default:
                // UndefinedResolution
#if defined(IMAGEMAGICK_7)
                image->resolution.x = 0.0;
                image->resolution.y = 0.0;
#else
                image->x_resolution = 0.0;
                image->y_resolution = 0.0;
#endif
                break;
        }

        image->units = units;
    }

    return restype;
}


/**
 * Sharpen an image. "amount" is the percentage of the difference between the original and the blur
 * image that is added back into the original. "threshold" is the threshold in pixels needed to
 * apply the diffence amount.
 *
 * No Ruby usage (internal function)
 *
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param radious the radious
 * @param sigma the sigma
 * @param amount the amount
 * @param threshold the threshold
 * @see Image_unsharp_mask
 */
static void
unsharp_mask_args(int argc, VALUE *argv, double *radius, double *sigma,
                  double *amount, double *threshold)
{
    switch (argc)
    {
        case 4:
            *threshold = NUM2DBL(argv[3]);
            if (*threshold < 0.0)
            {
                rb_raise(rb_eArgError, "threshold must be >= 0.0");
            }
        case 3:
            *amount = NUM2DBL(argv[2]);
            if (*amount <= 0.0)
            {
                rb_raise(rb_eArgError, "amount must be > 0.0");
            }
        case 2:
            *sigma = NUM2DBL(argv[1]);
            if (*sigma == 0.0)
            {
                rb_raise(rb_eArgError, "sigma must be != 0.0");
            }
        case 1:
            *radius = NUM2DBL(argv[0]);
            if (*radius < 0.0)
            {
                rb_raise(rb_eArgError, "radius must be >= 0.0");
            }
        case 0:
            break;

            // This case can't occur if we're called from Image_unsharp_mask_channel
            // because it has already raised an exception for the the argc > 4 case.
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 4)", argc);
    }
}


/**
 * Sharpen an image. "amount" is the percentage of the difference between the original and the blur
 * image that is added back into the original. "threshold" is the threshold in pixels needed to
 * apply the diffence amount.
 *
 * @overload unsharp_mask(radius = 0.0, sigma = 1.0, amount = 1.0, threshold = 0.05)
 *   @param radius [Float] The radius of the Gaussian operator.
 *   @param sigma [Float] The standard deviation of the Gaussian operator.
 *   @param amount [Float] The percentage of the blurred image to be added to the receiver,
 *     specified as a fraction between 0 and 1.0
 *   @param threshold [Float] The threshold needed to apply the amount, specified as a fraction
 *     between 0 and 1.0
 *   @return [Magick::Image] a new image
 */
VALUE
Image_unsharp_mask(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double radius = 0.0, sigma = 1.0, amount = 1.0, threshold = 0.05;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    unsharp_mask_args(argc, argv, &radius, &sigma, &amount, &threshold);

    exception = AcquireExceptionInfo();
    new_image = UnsharpMaskImage(image, radius, sigma, amount, threshold, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Sharpen an image. "amount" is the percentage of the difference between the original and the blur
 * image that is added back into the original. "threshold" is the threshold in pixels needed to
 * apply the diffence amount.
 *
 * Only the specified channels are sharpened.
 *
 * @overload unsharp_mask(radius = 0.0, sigma = 1.0, amount = 1.0, threshold = 0.05, channel = Magick::AllChannels)
 *   @param radius [Float] The radius of the Gaussian operator.
 *   @param sigma [Float] The standard deviation of the Gaussian operator.
 *   @param amount [Float] The percentage of the blurred image to be added to the receiver,
 *     specified as a fraction between 0 and 1.0
 *   @param threshold [Float] The threshold needed to apply the amount, specified as a fraction
 *     between 0 and 1.0
 *   @param channel [Magick::ChannelType] a ChannelType arguments.
 *
 * @overload unsharp_mask(radius = 0.0, sigma = 1.0, amount = 1.0, threshold = 0.05, *channels)
 *   @param radius [Float] The radius of the Gaussian operator.
 *   @param sigma [Float] The standard deviation of the Gaussian operator.
 *   @param amount [Float] The percentage of the blurred image to be added to the receiver,
 *     specified as a fraction between 0 and 1.0
 *   @param threshold [Float] The threshold needed to apply the amount, specified as a fraction
 *     between 0 and 1.0
 *   @param *channels [Magick::ChannelType] one or more ChannelType arguments.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_unsharp_mask_channel(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    ChannelType channels;
    double radius = 0.0, sigma = 1.0, amount = 1.0, threshold = 0.05;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    channels = extract_channels(&argc, argv);
    if (argc > 4)
    {
        raise_ChannelType_error(argv[argc-1]);
    }

    unsharp_mask_args(argc, argv, &radius, &sigma, &amount, &threshold);

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    BEGIN_CHANNEL_MASK(image, channels);
    new_image = UnsharpMaskImage(image, radius, sigma, amount, threshold, exception);
    CHANGE_RESULT_CHANNEL_MASK(new_image);
    END_CHANNEL_MASK(image);
#else
    new_image = UnsharpMaskImageChannel(image, channels, radius, sigma, amount, threshold, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Soften the edges of an image.
 *
 * @overload vignette(horz_radius = self.columns*0.1+0.5, vert_radius = self.rows*0.1+0.5, radius = 0.0, sigma = 1.0)
 *   @param horz_radius [Float] Influences the amount of background color in the horizontal dimension.
 *   @param vert_radius [Float] Influences the amount of background color in the vertical dimension.
 *   @param radius [Float] Controls the amount of blurring.
 *   @param sigma [Float] Controls the amount of blurring.
 *   @return [Magick::Image] a new image
 */
VALUE
Image_vignette(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    long horz_radius, vert_radius;
    double radius = 0.0, sigma = 10.0;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);

    horz_radius = (long)(image->columns * 0.10 + 0.5);
    vert_radius = (long)(image->rows * 0.10 + 0.5);

    switch (argc)
    {
        case 4:
            sigma = NUM2DBL(argv[3]);
        case 3:
            radius = NUM2DBL(argv[2]);
        case 2:
            vert_radius = NUM2INT(argv[1]);
        case 1:
            horz_radius = NUM2INT(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 4)", argc);
            break;
    }

    exception = AcquireExceptionInfo();

    new_image = VignetteImage(image, radius, sigma, horz_radius, vert_radius, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Get the "virtual pixels" behave.
 * Virtual pixels are pixels that are outside the boundaries of the image.
 *
 * @return [Magick::VirtualPixelMethod] the VirtualPixelMethod
 */
VALUE
Image_virtual_pixel_method(VALUE self)
{
    Image *image;
    VirtualPixelMethod vpm;

    image = rm_check_destroyed(self);
    vpm = GetImageVirtualPixelMethod(image);
    return VirtualPixelMethod_find(vpm);
}


/**
 * Specify how "virtual pixels" behave.
 * Virtual pixels are pixels that are outside the boundaries of the image.
 *
 * @param method [Magick::VirtualPixelMethod] the VirtualPixelMethod
 * @return [Magick::VirtualPixelMethod] the given method
 */
VALUE
Image_virtual_pixel_method_eq(VALUE self, VALUE method)
{
    Image *image;
    VirtualPixelMethod vpm;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_frozen(self);
    VALUE_TO_ENUM(method, vpm, VirtualPixelMethod);
#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    SetImageVirtualPixelMethod(image, vpm, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    SetImageVirtualPixelMethod(image, vpm);
    rm_check_image_exception(image, RetainOnError);
#endif
    return method;
}


/**
 * Composites a watermark image on the target image using the Modulate composite operator. This
 * composite operation operates in the HSL colorspace and combines part of the lightness, part of
 * the saturation, and all of the hue of each pixel in the watermark with the corresponding pixel in
 * the target image
 *
 * @overload watermark(mark, brightness = 1.0, saturation = 1.0, x_off = 0, y_off = 0)
 *   @param mark [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param brightness [Float] The fraction of the lightness component of the watermark pixels to be
 *     composited onto the target image. Must be a non-negative number or a string in the form
 *     "NN%". If lightness is a number it is interpreted as a percentage. Both 0.25 and "25%" mean
 *     25%. The default is 100%.
 *   @param saturation [Float] The fraction of the saturation component of the watermark pixels to
 *     be composited onto the target image. Must be a non-negative number or a string in the form
 *     "NN%". If lightness is a number it is interpreted as a percentage. Both 0.25 and "25%" mean
 *     25%. The default is 100%.
 *   @param x_off [Numeric] The offset of the watermark, measured from the left-hand side of the
 *     target image.
 *   @param y_off [Numeri] The offset of the watermark, measured from the top of the target image.
 *
 * @overload watermark(mark, brightness, saturation, gravity, x_off = 0, y_off = 0)
 *   @param mark [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param brightness [Float] The fraction of the lightness component of the watermark pixels to be
 *     composited onto the target image. Must be a non-negative number or a string in the form
 *     "NN%". If lightness is a number it is interpreted as a percentage. Both 0.25 and "25%" mean
 *     25%. The default is 100%.
 *   @param saturation [Float] The fraction of the saturation component of the watermark pixels to
 *     be composited onto the target image. Must be a non-negative number or a string in the form
 *     "NN%". If lightness is a number it is interpreted as a percentage. Both 0.25 and "25%" mean
 *     25%. The default is 100%.
 *   @param gravity [Magick::GravityType] the gravity for offset. the offsets are measured from the
 *     NorthWest corner by default.
 *   @param x_off [Numeric] The offset of the watermark, measured from the left-hand side of the
 *     target image.
 *   @param y_off [Numeri] The offset of the watermark, measured from the top of the target image.
 *
 * @return [Magick::Image] a new image
 */
VALUE
Image_watermark(int argc, VALUE *argv, VALUE self)
{
    Image *image, *overlay, *new_image;
    double src_percent = 100.0, dst_percent = 100.0;
    long x_offset = 0L, y_offset = 0L;
    char geometry[20];
    VALUE ovly;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

    if (argc < 1)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 to 6)", argc);
    }

    ovly = rm_cur_image(argv[0]);
    overlay = rm_check_destroyed(ovly);

    if (argc > 3)
    {
        get_composite_offsets(argc-3, &argv[3], image, overlay, &x_offset, &y_offset);
        // There must be 3 arguments left
        argc = 3;
    }

    switch (argc)
    {
        case 3:
            dst_percent = rm_percentage(argv[2], 1.0) * 100.0;
        case 2:
            src_percent = rm_percentage(argv[1], 1.0) * 100.0;
        case 1:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 2 to 6)", argc);
            break;
    }

    blend_geometry(geometry, sizeof(geometry), src_percent, dst_percent);
    CloneString(&overlay->geometry, geometry);
    SetImageArtifact(overlay, "compose:args", geometry);

    new_image = rm_clone_image(image);
#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    CompositeImage(new_image, overlay, ModulateCompositeOp, MagickTrue, x_offset, y_offset, exception);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);
#else
    CompositeImage(new_image, ModulateCompositeOp, overlay, x_offset, y_offset);

    rm_check_image_exception(new_image, DestroyOnError);
#endif

    RB_GC_GUARD(ovly);

    return rm_image_new(new_image);
}


/**
 * Create a "ripple" effect in the image by shifting the pixels vertically along a sine wave whose
 * amplitude and wavelength is specified by the given parameters.
 *
 * @overload wave(amplitude = 25.0, wavelength = 150.0)
 *   @param amplitude [Float] the amplitude
 *   @param wavelength [Float] the wave length
 *   @return [Magick::Image] a new image
 */
VALUE
Image_wave(int argc, VALUE *argv, VALUE self)
{
    Image *image, *new_image;
    double amplitude = 25.0, wavelength = 150.0;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 2:
            wavelength = NUM2DBL(argv[1]);
        case 1:
            amplitude = NUM2DBL(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 2)", argc);
            break;
    }

    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    new_image = WaveImage(image, amplitude, wavelength, image->interpolate, exception);
#else
    new_image = WaveImage(image, amplitude, wavelength, exception);
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Creates a "wet floor" reflection. The reflection is an inverted copy of the image that changes
 * from partially transparent to entirely transparent. By default only the bottom third of the image
 * appears in the reflection.
 *
 * @overload wet_floor(initial = 0.5, rate = 1.0)
 *   @param initial [Float] A value between 0.0 and 1.0 that specifies the initial percentage of
 *     transparency. Higher values cause the top of the reflection to be more transparent, lower
 *     values less transparent. The default is 0.5, which means that the top of the reflection is 50%
 *     transparent.
 *   @param rate [Float] A non-negative value that specifies how rapidly the reflection transitions
 *     from the initial level of transparency to entirely transparent. The default value is 1.0, which
 *     means that the transition occurs in 1/3 the image height. Values greater than 1.0 speed up the
 *     transition (the reflection will have fewer rows), values lower than 1.0 slow down the
 *     transition (the reflection will have more rows). A value of 0.0 means that the level of
 *     transparency will not change.
 *   @return [Magick::Image] a new image
 *   @see http://en.wikipedia.org/wiki/Wet_floor_effect
 */
VALUE
Image_wet_floor(int argc, VALUE *argv, VALUE self)
{
    Image *image, *reflection, *flip_image;
#if defined(IMAGEMAGICK_7)
    const Quantum *p;
    Quantum *q;
#else
    const PixelPacket *p;
    PixelPacket *q;
#endif
    RectangleInfo geometry;
    long x, y, max_rows;
    double initial = 0.5;
    double rate = 1.0;
    double opacity, step;
    const char *func;
    ExceptionInfo *exception;

    image = rm_check_destroyed(self);
    switch (argc)
    {
        case 2:
            rate = NUM2DBL(argv[1]);
        case 1:
            initial = NUM2DBL(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 2)", argc);
            break;
    }


    if (initial < 0.0 || initial > 1.0)
    {
        rb_raise(rb_eArgError, "Initial transparency must be in the range 0.0-1.0 (%g)", initial);
    }
    if (rate < 0.0)
    {
        rb_raise(rb_eArgError, "Transparency change rate must be >= 0.0 (%g)", rate);
    }

#if defined(IMAGEMAGICK_7)
    initial *= QuantumRange;
#else
    initial *= TransparentOpacity;
#endif

    // The number of rows in which to transition from the initial level of
    // transparency to complete transparency. rate == 0.0 -> no change.
    if (rate > 0.0)
    {
        max_rows = (long)((double)image->rows) / (3.0 * rate);
        max_rows = (long)min((unsigned long)max_rows, image->rows);
#if defined(IMAGEMAGICK_7)
        step =  (QuantumRange - initial) / max_rows;
#else
        step =  (TransparentOpacity - initial) / max_rows;
#endif
    }
    else
    {
        max_rows = (long)image->rows;
        step = 0.0;
    }


    exception = AcquireExceptionInfo();
    flip_image = FlipImage(image, exception);
    CHECK_EXCEPTION();


    geometry.x = 0;
    geometry.y = 0;
    geometry.width = image->columns;
    geometry.height = max_rows;
    reflection = CropImage(flip_image, &geometry, exception);
    DestroyImage(flip_image);
    CHECK_EXCEPTION();


#if defined(IMAGEMAGICK_7)
    SetImageStorageClass(reflection, DirectClass, exception);
    rm_check_exception(exception, reflection, DestroyOnError);
    SetImageAlphaChannel(reflection, ActivateAlphaChannel, exception);
    rm_check_exception(exception, reflection, DestroyOnError);
#else
    SetImageStorageClass(reflection, DirectClass);
    rm_check_image_exception(reflection, DestroyOnError);


    reflection->matte = MagickTrue;
#endif
    opacity = initial;

    for (y = 0; y < max_rows; y++)
    {
#if defined(IMAGEMAGICK_7)
        if (opacity > QuantumRange)
        {
            opacity = QuantumRange;
        }
#else
        if (opacity > TransparentOpacity)
        {
            opacity = TransparentOpacity;
        }
#endif

        p = GetVirtualPixels(reflection, 0, y, image->columns, 1, exception);
        rm_check_exception(exception, reflection, DestroyOnError);
        if (!p)
        {
            func = "AcquireImagePixels";
            goto error;
        }

        q = QueueAuthenticPixels(reflection, 0, y, image->columns, 1, exception);

        rm_check_exception(exception, reflection, DestroyOnError);
        if (!q)
        {
            func = "SetImagePixels";
            goto error;
        }

        for (x = 0; x < (long) image->columns; x++)
        {
            // Never make a pixel *less* transparent than it already is.
#if defined(IMAGEMAGICK_7)
            *q = *p;
            SetPixelAlpha(reflection, min(GetPixelAlpha(image, q), QuantumRange - (Quantum)opacity), q);

            p += GetPixelChannels(reflection);
            q += GetPixelChannels(reflection);
#else
            q[x] = p[x];
            q[x].opacity = max(q[x].opacity, (Quantum)opacity);
#endif
        }


        SyncAuthenticPixels(reflection, exception);
        rm_check_exception(exception, reflection, DestroyOnError);

        opacity += step;
    }


    DestroyExceptionInfo(exception);
    return rm_image_new(reflection);

    error:
    DestroyExceptionInfo(exception);
    DestroyImage(reflection);
    rb_raise(rb_eRuntimeError, "%s failed on row %lu", func, y);
    return(VALUE)0;
}


/**
 * Forces all pixels above the threshold into white while leaving all pixels below the threshold
 * unchanged.
 *
 * @overload white_threshold(red, green, blue, alpha: alpha)
 *  @param red [Float] the number for red channel
 *  @param green [Float] the number for green channel
 *  @param blue [Float] the number for blue channel
 *  @param alpha [Numeric] the number for alpha channel
 *  @return [Magick::Image] a new image
 *  @see Image#black_threshold
 */
VALUE
Image_white_threshold(int argc, VALUE *argv, VALUE self)
{
    return threshold_image(argc, argv, self, WhiteThresholdImage);
}


/**
 * Copy the filename to the Info and to the Image. Add format prefix if necessary. This complicated
 * code is necessary to handle filenames like the kind Tempfile.new produces, which have an
 * "extension" in the form ".n", which confuses SetMagickInfo. So we don't use SetMagickInfo any
 * longer.
 *
 * No Ruby usage (internal function)
 *
 * @param info the Info
 * @param file the file
 */
void add_format_prefix(Info *info, VALUE file)
{
    char *filename;
    long filename_l;
    const MagickInfo *magick_info, *magick_info2;
    ExceptionInfo *exception;
    char magic[MaxTextExtent];
    size_t magic_l;
    size_t prefix_l;
    char *p;

    // Convert arg to string. If an exception occurs raise an error condition.
    file = rb_rescue(rb_String, file, file_arg_rescue, file);

    filename = rm_str2cstr(file, &filename_l);

    if (*info->magick == '\0')
    {
        memset(info->filename, 0, sizeof(info->filename));
        memcpy(info->filename, filename, (size_t)min(filename_l, MaxTextExtent-1));
        return;
    }

    // If the filename starts with a prefix, and it's a valid image format
    // prefix, then check for a conflict. If it's not a valid format prefix,
    // ignore it.
    p = memchr(filename, ':', (size_t)filename_l);
    if (p)
    {
        memset(magic, '\0', sizeof(magic));
        magic_l = p - filename;
        memcpy(magic, filename, magic_l);

        exception = AcquireExceptionInfo();
        magick_info = GetMagickInfo(magic, exception);
        CHECK_EXCEPTION();
        DestroyExceptionInfo(exception);

        if (magick_info && magick_info->magick_module)
        {
            // We have to compare the module names because some formats have
            // more than one name. JPG and JPEG, for example.
            exception = AcquireExceptionInfo();
            magick_info2 = GetMagickInfo(info->magick, exception);
            CHECK_EXCEPTION();
            DestroyExceptionInfo(exception);

            if (magick_info2->magick_module && strcmp(magick_info->magick_module, magick_info2->magick_module) != 0)
            {
                rb_raise(rb_eRuntimeError,
                         "filename prefix `%s' conflicts with output format `%s'",
                         magick_info->name, info->magick);
            }

            // The filename prefix already matches the specified format.
            // Just copy the filename as-is.
            memset(info->filename, 0, sizeof(info->filename));
            filename_l = min((size_t)filename_l, sizeof(info->filename));
            memcpy(info->filename, filename, (size_t)filename_l);
            return;
        }
    }

    // The filename doesn't start with a format prefix. Add the format from
    // the image info as the filename prefix.

    memset(info->filename, 0, sizeof(info->filename));
    prefix_l = min(sizeof(info->filename)-1, rm_strnlen_s(info->magick, sizeof(info->magick)));
    memcpy(info->filename, info->magick, prefix_l);
    info->filename[prefix_l++] = ':';

    filename_l = min(sizeof(info->filename) - prefix_l - 1, (size_t)filename_l);
    memcpy(info->filename+prefix_l, filename, (size_t)filename_l);
    info->filename[prefix_l+filename_l] = '\0';

    return;
}


/**
 * Write the image to the file.
 *
 * @param file [File, String] the file
 * @return [Magick::Image] self
 */
VALUE
Image_write(VALUE self, VALUE file)
{
    Image *image;
    Info *info;
    VALUE info_obj;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image = rm_check_destroyed(self);

    info_obj = rm_info_new();
    Data_Get_Struct(info_obj, Info, info);

    if (TYPE(file) == T_FILE)
    {
        rb_io_t *fptr;

        // Ensure file is open - raise error if not
        GetOpenFile(file, fptr);
        rb_io_check_writable(fptr);
#if defined(_WIN32)
        add_format_prefix(info, fptr->pathv);
        strlcpy(image->filename, info->filename, sizeof(image->filename));
        SetImageInfoFile(info, NULL);
#else
        SetImageInfoFile(info, rb_io_stdio_file(fptr));
        memset(image->filename, 0, sizeof(image->filename));
#endif
    }
    else
    {
        add_format_prefix(info, file);
        strlcpy(image->filename, info->filename, sizeof(image->filename));
        SetImageInfoFile(info, NULL);
    }

    rm_sync_image_options(image, info);

    info->adjoin = MagickFalse;
#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    WriteImage(info, image, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    WriteImage(info, image);
    rm_check_image_exception(image, RetainOnError);
#endif

    RB_GC_GUARD(info_obj);

    return self;
}

#if defined(IMAGEMAGICK_7)
/**
 * Get the horizontal resolution of the image.
 *
 * @return [Float] the resolution
 */
VALUE
Image_x_resolution(VALUE self)
{
    IMPLEMENT_ATTR_READERF(Image, x_resolution, resolution.x, dbl);
}

/**
 * Set the horizontal resolution of the image.
 *
 * @param val [Float] the resolution
 * @return [Float] the given resolution
 */
VALUE
Image_x_resolution_eq(VALUE self, VALUE val)
{
    IMPLEMENT_ATTR_WRITERF(Image, x_resolution, resolution.x, dbl);
}

/**
 * Get the vertical resolution of the image.
 *
 * @return [Float] the resolution
 */
VALUE
Image_y_resolution(VALUE self)
{
    IMPLEMENT_ATTR_READERF(Image, y_resolution, resolution.y, dbl);
}

/**
 * Set the vertical resolution of the image.
 *
 * @param val [Float] the resolution
 * @return [Float] the given resolution
 */
VALUE
Image_y_resolution_eq(VALUE self, VALUE val)
{
    IMPLEMENT_ATTR_WRITERF(Image, y_resolution, resolution.y, dbl);
}
#else
/**
 * Get the horizontal resolution of the image.
 *
 * @return [Float] the resolution
 */
VALUE
Image_x_resolution(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, x_resolution, dbl);
}

/**
 * Set the horizontal resolution of the image.
 *
 * @param val [Float] the resolution
 * @return [Float] the given resolution
 */
VALUE
Image_x_resolution_eq(VALUE self, VALUE val)
{
    IMPLEMENT_ATTR_WRITER(Image, x_resolution, dbl);
}

/**
 * Get the vertical resolution of the image.
 *
 * @return [Float] the resolution
 */
VALUE
Image_y_resolution(VALUE self)
{
    IMPLEMENT_ATTR_READER(Image, y_resolution, dbl);
}

/**
 * Set the vertical resolution of the image.
 *
 * @param val [Float] the resolution
 * @return [Float] the given resolution
 */
VALUE
Image_y_resolution_eq(VALUE self, VALUE val)
{
    IMPLEMENT_ATTR_WRITER(Image, y_resolution, dbl);
}
#endif


/**
 * Determine if the argument list is x, y, width, height
 * or
 * gravity, width, height
 * or
 * gravity, x, y, width, height
 *
 * If the 2nd or 3rd, compute new x, y values.
 *
 * The argument list can have a trailing true, false, or nil argument. If
 * present and true, after cropping reset the page fields in the image.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Call xform_image to do the cropping.
 *
 * @param bang whether the bang (!) version of the method was called
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @return self if bang, otherwise a new image
 * @see xform_image
 */
static VALUE
cropper(int bang, int argc, VALUE *argv, VALUE self)
{
    VALUE x, y, width, height;
    unsigned long nx = 0, ny = 0;
    unsigned long columns, rows;
    int reset_page = 0;
    GravityType gravity;
    Image *image;
    VALUE cropped;

    // Check for a "reset page" trailing argument.
    if (argc >= 1)
    {
        switch (TYPE(argv[argc-1]))
        {
            case T_TRUE:
                reset_page = 1;
                // fall thru
            case T_FALSE:
            case T_NIL:
                argc -= 1;
            default:
                break;
        }
    }

    switch (argc)
    {
        case 5:
            Data_Get_Struct(self, Image, image);

            VALUE_TO_ENUM(argv[0], gravity, GravityType);

            x      = argv[1];
            y      = argv[2];
            width  = argv[3];
            height = argv[4];

            nx      = NUM2ULONG(x);
            ny      = NUM2ULONG(y);
            columns = NUM2ULONG(width);
            rows    = NUM2ULONG(height);

            switch (gravity)
            {
                case NorthEastGravity:
                case EastGravity:
                case SouthEastGravity:
                    nx = image->columns - columns - nx;
                    break;
                case NorthGravity:
                case SouthGravity:
                case CenterGravity:
                    nx += image->columns/2 - columns/2;
                    break;
                default:
                    break;
            }
            switch (gravity)
            {
                case SouthWestGravity:
                case SouthGravity:
                case SouthEastGravity:
                    ny = image->rows - rows - ny;
                    break;
                case EastGravity:
                case WestGravity:
                case CenterGravity:
                    ny += image->rows/2 - rows/2;
                    break;
                case NorthEastGravity:
                case NorthGravity:
                default:
                    break;
            }

            x = ULONG2NUM(nx);
            y = ULONG2NUM(ny);
            break;
        case 4:
            x      = argv[0];
            y      = argv[1];
            width  = argv[2];
            height = argv[3];
            break;
        case 3:

            // Convert the width & height arguments to unsigned longs.
            // Compute the x & y offsets from the gravity and then
            // convert them to VALUEs.
            VALUE_TO_ENUM(argv[0], gravity, GravityType);
            width   = argv[1];
            height  = argv[2];
            columns = NUM2ULONG(width);
            rows    = NUM2ULONG(height);

            Data_Get_Struct(self, Image, image);

            switch (gravity)
            {
                case ForgetGravity:
                case NorthWestGravity:
                    nx = 0;
                    ny = 0;
                    break;
                case NorthGravity:
                    nx = (image->columns - columns) / 2;
                    ny = 0;
                    break;
                case NorthEastGravity:
                    nx = image->columns - columns;
                    ny = 0;
                    break;
                case WestGravity:
                    nx = 0;
                    ny = (image->rows - rows) / 2;
                    break;
                case EastGravity:
                    nx = image->columns - columns;
                    ny = (image->rows - rows) / 2;
                    break;
                case SouthWestGravity:
                    nx = 0;
                    ny = image->rows - rows;
                    break;
                case SouthGravity:
                    nx = (image->columns - columns) / 2;
                    ny = image->rows - rows;
                    break;
                case SouthEastGravity:
                    nx = image->columns - columns;
                    ny = image->rows - rows;
                    break;
                case CenterGravity:
                    nx = (image->columns - columns) / 2;
                    ny = (image->rows - rows) / 2;
                    break;
#if defined(IMAGEMAGICK_6)
                case StaticGravity:
                    rb_raise(rb_eNotImpError, "`StaticGravity' is not supported");
                    break;
#endif
            }

            x = ULONG2NUM(nx);
            y = ULONG2NUM(ny);
            break;
        default:
            if (reset_page)
            {
                rb_raise(rb_eArgError, "wrong number of arguments (%d for 4, 5, or 6)", argc);
            }
            else
            {
                rb_raise(rb_eArgError, "wrong number of arguments (%d for 3, 4, or 5)", argc);
            }
            break;
    }

    cropped = xform_image(bang, self, x, y, width, height, CropImage);
    if (reset_page)
    {
        Data_Get_Struct(cropped, Image, image);
        ResetImagePage(image, "0x0+0+0");
    }

    RB_GC_GUARD(x);
    RB_GC_GUARD(y);
    RB_GC_GUARD(width);
    RB_GC_GUARD(height);

    return cropped;
}


/**
 * Call one of the image transformation functions.
 *
 * No Ruby usage (internal function)
 *
 * @param bang whether the bang (!) version of the method was called
 * @param self this object
 * @param x x position of start of region
 * @param y y position of start of region
 * @param width width of region
 * @param height height of region
 * @param xformer the transformation function
 * @return self if bang, otherwise a new image
 */
static VALUE
xform_image(int bang, VALUE self, VALUE x, VALUE y, VALUE width, VALUE height, xformer_t xformer)
{
    Image *image, *new_image;
    RectangleInfo rect;
    ExceptionInfo *exception;

    Data_Get_Struct(self, Image, image);
    rect.x      = NUM2LONG(x);
    rect.y      = NUM2LONG(y);
    rect.width  = NUM2ULONG(width);
    rect.height = NUM2ULONG(height);

    exception = AcquireExceptionInfo();

    new_image = (xformer)(image, &rect, exception);

    // An exception can occur in either the old or the new images
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

#if defined(IMAGEMAGICK_6)
    if (rm_should_raise_exception(&image->exception, RetainExceptionRetention))
    {
        DestroyImage(new_image);
        rm_check_image_exception(image, RetainOnError);
    }
#endif

    if (bang)
    {
        rm_ensure_result(new_image);
        UPDATE_DATA_PTR(self, new_image);
        rm_image_destroy(image);
        return self;
    }

    return rm_image_new(new_image);

}


/**
 * Remove all the ChannelType arguments from the end of the argument list.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Returns DefaultChannels if no channel arguments were found.
 *   - Returns the number of remaining arguments.
 *
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @return A ChannelType value suitable for passing into an xMagick function.
 */
ChannelType extract_channels(int *argc, VALUE *argv)
{
    VALUE arg;
    ChannelType channels, ch_arg;

    channels = 0;
    while (*argc > 0)
    {
        arg = argv[(*argc)-1];

        // Stop when you find a non-ChannelType argument
        if (CLASS_OF(arg) != Class_ChannelType)
        {
            break;
        }
        VALUE_TO_ENUM(arg, ch_arg, ChannelType);
        channels |= ch_arg;
        *argc -= 1;
    }

    if (channels == 0)
    {
        channels = DefaultChannels;
    }

    RB_GC_GUARD(arg);

    return channels;
}


/**
 * Raise TypeError when an non-ChannelType object is unexpectedly encountered.
 *
 * No Ruby usage (internal function)
 *
 * @param arg the argument
 */
void
raise_ChannelType_error(VALUE arg)
{
    rb_raise(rb_eTypeError, "argument must be a ChannelType value (%s given)",
             rb_class2name(CLASS_OF(arg)));
}



/**
 * If Magick.trace_proc is not nil, build an argument list and call the proc.
 *
 * No Ruby usage (internal function)
 *
 * @param image the image
 * @param which which operation the proc is being called for
 */
static void call_trace_proc(Image *image, const char *which)
{
    VALUE trace;
    VALUE trace_args[4];

    if (rb_ivar_defined(Module_Magick, rm_ID_trace_proc) == Qtrue)
    {
        trace = rb_ivar_get(Module_Magick, rm_ID_trace_proc);
        if (!NIL_P(trace))
        {
            // Maybe the stack won't get extended until we need the space.
            char buffer[MaxTextExtent];

            trace_args[0] = ID2SYM(rb_intern(which));

            build_inspect_string(image, buffer, sizeof(buffer));
            trace_args[1] = rb_str_new2(buffer);

            snprintf(buffer, sizeof(buffer), "%p", (void *)image);
            trace_args[2] = rb_str_new2(buffer+2);      // don't use leading 0x
            trace_args[3] = ID2SYM(rb_frame_this_func());
            rb_funcall2(trace, rm_ID_call, 4, (VALUE *)trace_args);
        }
    }

    RB_GC_GUARD(trace);
}


static VALUE
rm_trace_creation_body(VALUE img)
{
    Image *image = (Image *)img;
    call_trace_proc(image, "c");
    return Qnil;
}

static VALUE
rm_trace_creation_handle_exception(VALUE img, VALUE exc)
{
    Image *image = (Image *)img;
    DestroyImage(image);
    rb_exc_raise(exc);
}

/**
 * Trace image creation
 *
 * No Ruby usage (internal function)
 *
 * @param image the image
 * @see call_trace_proc
 */
void rm_trace_creation(Image *image)
{
    rb_rescue(rm_trace_creation_body, (VALUE)image, rm_trace_creation_handle_exception, (VALUE)image);
}



/**
 * Destroy an image. Called from GC when all references to the image have gone
 * out of scope.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - A NULL Image pointer indicates that the image has already been destroyed
 *     by Image#destroy!
 *
 * @param img the image
 */
void rm_image_destroy(void *img)
{
    Image *image = (Image *)img;

    if (img != NULL)
    {
        call_trace_proc(image, "d");
        DestroyImage(image);
    }
}



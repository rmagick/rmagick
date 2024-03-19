/**************************************************************************//**
 * ImageList class method definitions for RMagick.
 *
 * Copyright &copy; 2002 - 2009 by Timothy P. Hunter
 *
 * Changes since Nov. 2009 copyright &copy; by Benjamin Thomas and Omer Bar-or
 *
 * @file     rmilist.cpp
 * @version  $Id: rmilist.cpp,v 1.94 2009/12/20 02:33:33 baror Exp $
 * @author   Tim Hunter
 ******************************************************************************/

#include "rmagick.h"

static Image *clone_imagelist(Image *);
static Image *images_from_imagelist(VALUE);
static long imagelist_length(VALUE);
static long check_imagelist_length(VALUE);
static void imagelist_push(VALUE, VALUE);
static VALUE ImageList_new(void);


DEFINE_GVL_STUB3(AppendImages, const Image *, const MagickBooleanType, ExceptionInfo *);
DEFINE_GVL_STUB5(CloneImage, const Image *, const size_t, const size_t, const MagickBooleanType, ExceptionInfo *);
DEFINE_GVL_STUB2(CloneImageList, const Image *, ExceptionInfo *);
DEFINE_GVL_STUB2(CoalesceImages, const Image *, ExceptionInfo *);
DEFINE_GVL_STUB2(DisposeImages, const Image *, ExceptionInfo *);
DEFINE_GVL_STUB3(EvaluateImages, const Image *, const MagickEvaluateOperator, ExceptionInfo *);
DEFINE_GVL_STUB4(ImagesToBlob, const ImageInfo *, Image *, size_t *, ExceptionInfo *);
DEFINE_GVL_STUB3(MergeImageLayers, Image *, const LayerMethod, ExceptionInfo *);
DEFINE_GVL_STUB3(MontageImages, const Image *, const MontageInfo *, ExceptionInfo *);
DEFINE_GVL_STUB3(MorphImages, const Image *, const size_t, ExceptionInfo *);
DEFINE_GVL_STUB2(OptimizeImageLayers, const Image *, ExceptionInfo *);
DEFINE_GVL_STUB2(OptimizePlusImageLayers, const Image *, ExceptionInfo *);
#if defined(IMAGEMAGICK_7)
DEFINE_GVL_STUB3(AnimateImages, const ImageInfo *, Image *, ExceptionInfo *);
DEFINE_GVL_STUB3(CombineImages, const Image *, const ColorspaceType, ExceptionInfo *);
DEFINE_GVL_STUB3(CompareImagesLayers, const Image *, const LayerMethod, ExceptionInfo *);
DEFINE_GVL_STUB3(QuantizeImages, const QuantizeInfo *, Image *, ExceptionInfo *);
DEFINE_GVL_STUB4(RemapImages, const QuantizeInfo *, Image *, const Image *, ExceptionInfo *);
DEFINE_GVL_STUB3(WriteImage, const ImageInfo *, Image *, ExceptionInfo *);
#else
DEFINE_GVL_STUB2(AnimateImages, const ImageInfo *, Image *);
DEFINE_GVL_STUB3(CombineImages, const Image *, const ChannelType, ExceptionInfo *);
DEFINE_GVL_STUB3(CompareImageLayers, const Image *, const ImageLayerMethod, ExceptionInfo *);
DEFINE_GVL_STUB2(DeconstructImages, const Image *, ExceptionInfo *);
DEFINE_GVL_STUB2(QuantizeImages, const QuantizeInfo *, Image *);
DEFINE_GVL_STUB3(RemapImages, const QuantizeInfo *, Image *, const Image *);
DEFINE_GVL_STUB2(WriteImage, const ImageInfo *, Image *);
#endif

DEFINE_GVL_VOID_STUB6(CompositeLayers, Image *, const CompositeOperator, Image *, const ssize_t, const ssize_t, ExceptionInfo *);
DEFINE_GVL_VOID_STUB2(OptimizeImageTransparency, const Image *, ExceptionInfo *);
DEFINE_GVL_VOID_STUB2(RemoveDuplicateLayers, Image **, ExceptionInfo *);
DEFINE_GVL_VOID_STUB2(RemoveZeroDelayLayers, Image **, ExceptionInfo *);


/**
 * Repeatedly display the images in the images array to an XWindow screen. The
 * +delay+ argument is the number of 1/100ths of a second (0 to 65535) to delay
 * between images.
 *
 * @overload animate
 *
 * @overload animate(delay)
 *   @param delay [Numeric] the length of time between each image in an animation
 *   @yield [info]
 *   @yieldparam info [Magick::Image::Info]
 *
 * @return [Magick::ImageList] self
 */

VALUE
ImageList_animate(int argc, VALUE *argv, VALUE self)
{
    Image *images;
    Info *info;
    VALUE info_obj;
    unsigned int delay;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    if (argc == 1)
    {
        delay = NUM2UINT(argv[0]);
    }
    if (argc > 1)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 or 1)", argc);
    }

    // Create a new Info object to use with this call
    info_obj = rm_info_new();

    // Convert the images array to an images sequence.
    images = images_from_imagelist(self);

    if (argc == 1)
    {
        Image *img;

        for (img = images; img; img = GetNextImageInList(img))
        {
            img->delay = delay;
        }
    }

    TypedData_Get_Struct(info_obj, Info, &rm_info_data_type, info);
#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    GVL_STRUCT_TYPE(AnimateImages) args = { info, images, exception };
    CALL_FUNC_WITHOUT_GVL(GVL_FUNC(AnimateImages), &args);
    rm_split(images);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    GVL_STRUCT_TYPE(AnimateImages) args = { info, images };
    CALL_FUNC_WITHOUT_GVL(GVL_FUNC(AnimateImages), &args);
    rm_split(images);
    rm_check_image_exception(images, RetainOnError);
#endif

    RB_GC_GUARD(info_obj);

    return self;
}


/**
 * Append all the images
 *
 * @param stack_arg [Magick::ImageList] the stack of images
 * @return [Magick::Image] a frame object for the result
 */
VALUE
ImageList_append(VALUE self, VALUE stack_arg)
{
    Image *images, *new_image;
    MagickBooleanType stack;
    ExceptionInfo *exception;

    // Convert the image array to an image sequence.
    images = images_from_imagelist(self);

    // If stack == true, stack rectangular images top-to-bottom,
    // otherwise left-to-right.
    stack = (MagickBooleanType)RTEST(stack_arg);

    exception = AcquireExceptionInfo();
    GVL_STRUCT_TYPE(AppendImages) args = { images, stack, exception };
    new_image = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(AppendImages), &args);
    rm_split(images);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Average all images together
 *
 * @return [Magick::Image] a frame object for the averaged image
 */
VALUE
ImageList_average(VALUE self)
{
    Image *images, *new_image;
    ExceptionInfo *exception;

    // Convert the images array to an images sequence.
    images = images_from_imagelist(self);

    exception = AcquireExceptionInfo();
    GVL_STRUCT_TYPE(EvaluateImages) args = { images, MeanEvaluateOperator, exception };
    new_image = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(EvaluateImages), &args);
    rm_split(images);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Composites a set of images while respecting any page offsets and disposal methods.
 *
 * - Respects the delay, matte, and start_loop fields in each image.
 *
 * @return [Magick::ImageList] a new image with the coalesced image sequence return stored in the
 *   images array
 */
VALUE
ImageList_coalesce(VALUE self)
{
    Image *images, *new_images;
    ExceptionInfo *exception;

    // Convert the image array to an image sequence.
    images = images_from_imagelist(self);

    exception = AcquireExceptionInfo();
    GVL_STRUCT_TYPE(CoalesceImages) args = { images, exception };
    new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(CoalesceImages), &args);
    rm_split(images);
    rm_check_exception(exception, new_images, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_imagelist_from_images(new_images);
}


/**
 * Combines the images using the specified colorspace.
 *
 * @overload combine
 *
 * @overload combine(colorspace)
 *   @param colorspace [Magick::ColorspaceType] the colorspace
 *
 * @return [Magick::Image] a new image
 */
VALUE ImageList_combine(int argc, VALUE *argv, VALUE self)
{
#if defined(IMAGEMAGICK_6)
    ChannelType channel;
    ColorspaceType old_colorspace;
#endif
    ColorspaceType colorspace;
    long len;
    Image *images, *new_image;
    ExceptionInfo *exception;

    len = check_imagelist_length(self);

    switch (argc)
    {
        case 1:
            VALUE_TO_ENUM(argv[0], colorspace, ColorspaceType);
            break;
        case 0:
            colorspace = sRGBColorspace;
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (expected 1, got %d)", argc);
            break;
    }

#if defined(IMAGEMAGICK_7)
    if (len > 5)
    {
        rb_raise(rb_eArgError, "invalid number of images in this image list");
    }
    if (len == 5 && colorspace != CMYKColorspace)
    {
        rb_raise(rb_eArgError, "invalid number of images in this image list");
    }
#else
    channel = RedChannel;
    switch (len)
    {
        case 5:
            if (colorspace == CMYKColorspace)
                channel = (ChannelType)(channel | AlphaChannel);
            else
                rb_raise(rb_eArgError, "invalid number of images in this image list");
        case 4:
            if (colorspace == CMYKColorspace)
                channel = (ChannelType)(channel | IndexChannel);
            else
                channel = (ChannelType)(channel | AlphaChannel);
        case 3:
            channel = (ChannelType)(channel | GreenChannel);
            channel = (ChannelType)(channel | BlueChannel);
            break;
        case 2:
            channel = (ChannelType)(channel | AlphaChannel);
            break;
        case 1:
            break;
        default:
            rb_raise(rb_eArgError, "invalid number of images in this image list");
            break;
    }
#endif

    images = images_from_imagelist(self);
    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_6)
    old_colorspace = images->colorspace;
    SetImageColorspace(images, colorspace);
    GVL_STRUCT_TYPE(CombineImages) args = { images, channel, exception };
#else
    GVL_STRUCT_TYPE(CombineImages) args = { images, colorspace, exception };
#endif
    new_image = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(CombineImages), &args);

    rm_split(images);
#if defined(IMAGEMAGICK_6)
    images->colorspace = old_colorspace;
#endif
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * An image from source images is composited over an image from receiver's list until one list is finished.
 *
 * @overload composite_layers(images)
 *   @param images [Magick::ImageList] the source images
 *
 * @overload composite_layers(images, composite_op)
 *   - Default operator is {Magick::OverCompositeOp}
 *   @param images [Magick::ImageList] the source images
 *   @param composite_op [Magick::CompositeOperator] the operator
 *
 * @return [Magick::ImageList] a new imagelist
 */
VALUE
ImageList_composite_layers(int argc, VALUE *argv, VALUE self)
{
    VALUE source_images;
    Image *dest, *source, *new_images;
    RectangleInfo geometry;
    CompositeOperator composite_op = OverCompositeOp;
    ExceptionInfo *exception;

    switch (argc)
    {
        case 2:
            VALUE_TO_ENUM(argv[1], composite_op, CompositeOperator);
        case 1:
            source_images = argv[0];
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (expected 1 or 2, got %d)", argc);
            break;
    }

    // Convert ImageLists to image sequences.
    dest = images_from_imagelist(self);
    new_images = clone_imagelist(dest);
    rm_split(dest);

    source = images_from_imagelist(source_images);

    SetGeometry(new_images, &geometry);
    ParseAbsoluteGeometry(new_images->geometry, &geometry);

    geometry.width  = source->page.width != 0 ? source->page.width : source->columns;
    geometry.height = source->page.height != 0 ? source->page.height : source->rows;
    GravityAdjustGeometry(new_images->page.width  != 0 ? new_images->page.width  : new_images->columns,
                          new_images->page.height != 0 ? new_images->page.height : new_images->rows,
                          new_images->gravity, &geometry);

    exception = AcquireExceptionInfo();
    GVL_STRUCT_TYPE(CompositeLayers) args = { new_images, composite_op, source, geometry.x, geometry.y, exception };
    CALL_FUNC_WITHOUT_GVL(GVL_FUNC(CompositeLayers), &args);
    rm_split(source);
    rm_check_exception(exception, new_images, DestroyOnError);
    DestroyExceptionInfo(exception);

    RB_GC_GUARD(source_images);

    return rm_imagelist_from_images(new_images);
}


/**
 * Compare each image with the next in a sequence and returns the maximum
 * bounding region of any pixel differences it discovers.
 *
 * @return [Magick::ImageList] a new imagelist
 */
VALUE
ImageList_deconstruct(VALUE self)
{
    Image *new_images, *images;
    ExceptionInfo *exception;

    images = images_from_imagelist(self);
    exception = AcquireExceptionInfo();
#if defined(IMAGEMAGICK_7)
    GVL_STRUCT_TYPE(CompareImagesLayers) args = { images, CompareAnyLayer, exception };
    new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(CompareImagesLayers), &args);
#else
    GVL_STRUCT_TYPE(DeconstructImages) args = { images, exception };
    new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(DeconstructImages), &args);
#endif
    rm_split(images);
    rm_check_exception(exception, new_images, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_imagelist_from_images(new_images);
}


/**
 * Display all the images to an X window screen.
 *
 * @yield [info]
 * @yieldparam info [Magick::Image::Info]
 * @return [Magick::ImageList] self
 */
VALUE
ImageList_display(VALUE self)
{
    Image *images;
    Info *info;
    VALUE info_obj;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    // Create a new Info object to use with this call
    info_obj = rm_info_new();
    TypedData_Get_Struct(info_obj, Info, &rm_info_data_type, info);

    // Convert the images array to an images sequence.
    images = images_from_imagelist(self);
#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    DisplayImages(info, images, exception);
    rm_split(images);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    DisplayImages(info, images);
    rm_split(images);
    rm_check_image_exception(images, RetainOnError);
#endif

    RB_GC_GUARD(info_obj);

    return self;
}


/**
 * Merge all the images into a single image.
 *
 * @return [Magick::ImageList] the new image
 */
VALUE
ImageList_flatten_images(VALUE self)
{
    Image *images, *new_image;
    ExceptionInfo *exception;

    images = images_from_imagelist(self);
    exception = AcquireExceptionInfo();

    GVL_STRUCT_TYPE(MergeImageLayers) args = { images, FlattenLayer, exception };
    new_image = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(MergeImageLayers), &args);

    rm_split(images);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Tile one or more thumbnails across an image canvas.
 *
 * @overload montage
 *
 * @overload montage
 *   Creates {Magick::ImageList::Montage} object, yields to block
 *   if present in {Magick::ImageList::Montage} object's scope.
 *   @yield [opt]
 *   @yieldparam opt [Magick::ImageList::Montage]
 *
 * @return [Magick::ImageList] a new image list
 */
VALUE
ImageList_montage(VALUE self)
{
    VALUE montage_obj;
    Montage *montage;
    Image *new_images, *images;
    ExceptionInfo *exception;

    // Create a new instance of the Magick::ImageList::Montage class
    montage_obj = rm_montage_new();
    if (rb_block_given_p())
    {
        rb_yield(montage_obj);
    }

    TypedData_Get_Struct(montage_obj, Montage, &rm_montage_data_type, montage);

    images = images_from_imagelist(self);

    for (Image *image = images; image; image = GetNextImageInList(image))
    {
        if (montage->compose != UndefinedCompositeOp)
        {
            image->compose = montage->compose;
        }
        image->background_color = montage->info->background_color;
        image->border_color = montage->info->border_color;
        image->matte_color = montage->info->matte_color;
        image->gravity = montage->info->gravity;
    }

    exception = AcquireExceptionInfo();

    // MontageImage can return more than one image.
    GVL_STRUCT_TYPE(MontageImages) args = { images, montage->info, exception };
    new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(MontageImages), &args);
    rm_split(images);
    rm_check_exception(exception, new_images, DestroyOnError);
    DestroyExceptionInfo(exception);

    RB_GC_GUARD(montage_obj);

    return rm_imagelist_from_images(new_images);
}


/**
 * Requires a minimum of two images. The first image is transformed into the
 * second by a number of intervening images as specified by "nimages".
 *
 * @note Sets +@scenes+ to 0
 * @param nimages [Numeric] the number of images
 * @return [Magick::ImageList] a new image list with the images array set to the morph sequence.
 */
VALUE
ImageList_morph(VALUE self, VALUE nimages)
{
    Image *images, *new_images;
    ExceptionInfo *exception;
    size_t number_images;


    // Use a signed long so we can test for a negative argument.
    if (NUM2LONG(nimages) <= 0)
    {
        rb_raise(rb_eArgError, "number of intervening images must be > 0");
    }

    number_images = NUM2LONG(nimages);
    images = images_from_imagelist(self);
    exception = AcquireExceptionInfo();
    GVL_STRUCT_TYPE(MorphImages) args = { images, number_images, exception };
    new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(MorphImages), &args);
    rm_split(images);
    rm_check_exception(exception, new_images, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_imagelist_from_images(new_images);
}


/**
 * Merge all the images into a single image.
 *
 * @return [Magick::Image] the new image
 */
VALUE
ImageList_mosaic(VALUE self)
{
    Image *images, *new_image;
    ExceptionInfo *exception;

    images = images_from_imagelist(self);

    exception = AcquireExceptionInfo();
    GVL_STRUCT_TYPE(MergeImageLayers) args = { images, MosaicLayer, exception };
    new_image = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(MergeImageLayers), &args);

    rm_split(images);
    rm_check_exception(exception, new_image, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_image_new(new_image);
}


/**
 * Optimizes or compares the images in the list.
 * Equivalent to the -layers option in ImageMagick's mogrify command.
 *
 * @param method [Magick::LayerMethod] the method to use
 * @return [Magick::ImageList] a new imagelist
 */
VALUE
ImageList_optimize_layers(VALUE self, VALUE method)
{
    Image *images, *new_images, *new_images2;
    LayerMethod mthd;
    ExceptionInfo *exception;
    QuantizeInfo quantize_info;

    new_images2 = NULL;     // defeat "unused variable" message

    VALUE_TO_ENUM(method, mthd, LayerMethod);
    images = images_from_imagelist(self);

    exception = AcquireExceptionInfo();
    switch (mthd)
    {
        case CoalesceLayer:
            {
                GVL_STRUCT_TYPE(CoalesceImages) args = { images, exception };
                new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(CoalesceImages), &args);
            }
            break;
        case DisposeLayer:
            {
                GVL_STRUCT_TYPE(DisposeImages) args = { images, exception };
                new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(DisposeImages), &args);
            }
            break;
        case OptimizeTransLayer:
            {
                new_images = clone_imagelist(images);
                GVL_STRUCT_TYPE(OptimizeImageTransparency) args = { new_images, exception };
                CALL_FUNC_WITHOUT_GVL(GVL_FUNC(OptimizeImageTransparency), &args);
            }
            break;
        case RemoveDupsLayer:
            {
                new_images = clone_imagelist(images);
                GVL_STRUCT_TYPE(RemoveDuplicateLayers) args = { &new_images, exception };
                CALL_FUNC_WITHOUT_GVL(GVL_FUNC(RemoveDuplicateLayers), &args);
            }
            break;
        case RemoveZeroLayer:
            {
                new_images = clone_imagelist(images);
                GVL_STRUCT_TYPE(RemoveZeroDelayLayers) args = { &new_images, exception };
                CALL_FUNC_WITHOUT_GVL(GVL_FUNC(RemoveZeroDelayLayers), &args);
            }
            break;
        case CompositeLayer:
            rm_split(images);
            DestroyExceptionInfo(exception);
            rb_raise(rb_eNotImpError, "Magick::CompositeLayer is not supported. Use the composite_layers method instead.");
            break;
            // In 6.3.4-ish, OptimizeImageLayer replaced OptimizeLayer
        case OptimizeImageLayer:
            {
                GVL_STRUCT_TYPE(OptimizeImageLayers) args = { images, exception };
                new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(OptimizeImageLayers), &args);
            }
            break;
            // and OptimizeLayer became a "General Purpose, GIF Animation Optimizer" (ref. mogrify.c)
        case OptimizeLayer:
            {
                GVL_STRUCT_TYPE(CoalesceImages) args_CoalesceImages = { images, exception };
                new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(CoalesceImages), &args_CoalesceImages);
                rm_split(images);
                rm_check_exception(exception, new_images, DestroyOnError);

                GVL_STRUCT_TYPE(OptimizeImageLayers) args_OptimizeImageLayers = { new_images, exception };
                new_images2 = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(OptimizeImageLayers), &args_OptimizeImageLayers);
                DestroyImageList(new_images);
                rm_check_exception(exception, new_images2, DestroyOnError);

                new_images = new_images2;
                GVL_STRUCT_TYPE(OptimizeImageTransparency) args_OptimizeImageTransparency = { new_images, exception };
                CALL_FUNC_WITHOUT_GVL(GVL_FUNC(OptimizeImageTransparency), &args_OptimizeImageTransparency);
                rm_check_exception(exception, new_images, DestroyOnError);
                // mogrify supports -dither here. We don't.
                GetQuantizeInfo(&quantize_info);
#if defined(IMAGEMAGICK_7)
                GVL_STRUCT_TYPE(RemapImages) args_RemapImages = { &quantize_info, new_images, NULL, exception };
#else
                GVL_STRUCT_TYPE(RemapImages) args_RemapImages = { &quantize_info, new_images, NULL };
#endif
                CALL_FUNC_WITHOUT_GVL(GVL_FUNC(RemapImages), &args_RemapImages);

            }
            break;
        case OptimizePlusLayer:
            {
                GVL_STRUCT_TYPE(OptimizePlusImageLayers) args = { images, exception };
                new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(OptimizePlusImageLayers), &args);
            }
            break;
        case CompareAnyLayer:
        case CompareClearLayer:
        case CompareOverlayLayer:
            {
#if defined(IMAGEMAGICK_7)
                GVL_STRUCT_TYPE(CompareImagesLayers) args = { images, mthd, exception };
                new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(CompareImagesLayers), &args);
#else
                GVL_STRUCT_TYPE(CompareImageLayers) args = { images, mthd, exception };
                new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(CompareImageLayers), &args);
#endif
            }
            break;
        case MosaicLayer:
            {
                GVL_STRUCT_TYPE(MergeImageLayers) args = { images, mthd, exception };
                new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(MergeImageLayers), &args);
            }
            break;
        case FlattenLayer:
            {
                GVL_STRUCT_TYPE(MergeImageLayers) args = { images, mthd, exception };
                new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(MergeImageLayers), &args);
            }
            break;
        case MergeLayer:
            {
                GVL_STRUCT_TYPE(MergeImageLayers) args = { images, mthd, exception };
                new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(MergeImageLayers), &args);
            }
            break;
        case TrimBoundsLayer:
            {
                GVL_STRUCT_TYPE(MergeImageLayers) args = { images, mthd, exception };
                new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(MergeImageLayers), &args);
            }
            break;
        default:
            rm_split(images);
            DestroyExceptionInfo(exception);
            rb_raise(rb_eArgError, "undefined layer method");
            break;
    }

    rm_split(images);
    rm_check_exception(exception, new_images, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_imagelist_from_images(new_images);
}


/**
 * Create a new ImageList object with no images.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - this simply calls ImageList.new() in RMagick.rb
 *
 * @return a new imagelist
 */
static VALUE
ImageList_new(void)
{
    return rb_funcall(Class_ImageList, rm_ID_new, 0);
}


/**
 * Construct a new imagelist object from a list of images.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Sets \@scene to 0.
 *
 * @param images the images
 * @return a new imagelist
 * @see images_from_imagelist
 */
VALUE
rm_imagelist_from_images(Image *images)
{
    VALUE new_imagelist;

    rm_ensure_result(images);

    new_imagelist = ImageList_new();

    while (images)
    {
        Image *image;

        image = RemoveFirstImageFromList(&images);
        imagelist_push(new_imagelist, rm_image_new(image));
    }

    rb_iv_set(new_imagelist, "@scene", INT2FIX(0));

    RB_GC_GUARD(new_imagelist);

    return new_imagelist;
}


/**
 * Convert an array of Image *s to an ImageMagick scene sequence (i.e. a
 * doubly-linked list of Images).
 *
 * No Ruby usage (internal function)
 *
 * @param imagelist the imagelist
 * @return a pointer to the head of the scene sequence list
 * @see rm_imagelist_from_images
 */
static Image *
images_from_imagelist(VALUE imagelist)
{
    long x, len;
    Image *head = NULL;
    VALUE images, t;

    len = check_imagelist_length(imagelist);

    images = rb_iv_get(imagelist, "@images");
    for (x = 0; x < len; x++)
    {
        Image *image;

        t = rb_ary_entry(images, x);
        image = rm_check_destroyed(t);
        // avoid a loop in this linked imagelist, issue #202
        if (head == image || GetPreviousImageInList(image) != NULL)
        {
            image = rm_clone_image(image);

            // Wrap raw ImageMagick object by Ruby object to destroy using Ruby's GC.
            rm_image_new(image);
        }
        AppendImageToList(&head, image);
    }

    RB_GC_GUARD(images);
    RB_GC_GUARD(t);

    return head;
}


/**
 * return the # of images in an imagelist.
 *
 * No Ruby usage (internal function)
 *
 * @param imagelist the imagelist
 * @return the number of images
 */
static long
imagelist_length(VALUE imagelist)
{
    VALUE images = rb_iv_get(imagelist, "@images");
    if (!RB_TYPE_P(images, T_ARRAY))
    {
        rb_raise(Class_ImageMagickError, "@images is not of type Array");
    }

    RB_GC_GUARD(images);

    return RARRAY_LEN(images);
}


/**
 * Raise exception if imagelist is emtpy.
 *
 * No Ruby usage (internal function)
 *
 * @param imagelist the imagelist
 * @return the number of images
 * @throw ArgError
 */
static long
check_imagelist_length(VALUE imagelist)
{
    long len = imagelist_length(imagelist);

    if (len == 0)
    {
        rb_raise(rb_eArgError, "no images in this image list");
    }

    return len;
}


/**
 * Push an image onto the end of the imagelist.
 *
 * No Ruby usage (internal function)
 *
 * @param imagelist the imagelist
 * @param image the image
 */
static void
imagelist_push(VALUE imagelist, VALUE image)
{
    rb_check_frozen(imagelist);
    rb_funcall(imagelist, rm_ID_push, 1, image);
}


/**
 * Clone a list of images, handle errors.
 *
 * No Ruby usage (internal function)
 *
 * @param images the images
 * @return a new array of images
 */
static Image *
clone_imagelist(Image *images)
{
    Image *new_imagelist = NULL, *image;
    ExceptionInfo *exception;

    exception = AcquireExceptionInfo();

    image = GetFirstImageInList(images);
    while (image)
    {
        Image *clone;

        GVL_STRUCT_TYPE(CloneImage) args = { image, 0, 0, MagickTrue, exception };
        clone = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(CloneImage), &args);
        rm_check_exception(exception, new_imagelist, DestroyOnError);
        AppendImageToList(&new_imagelist, clone);
        image = GetNextImageInList(image);
    }

    DestroyExceptionInfo(exception);
    return new_imagelist;
}


/**
 * Analyzes the colors within a set of reference images and chooses a fixed number of colors to represent the set.
 * The goal of the algorithm is to minimize the difference between the input and output images while minimizing the processing time.
 *
 * @overload quantize(number_colors = 256, colorspace = Magick::RGBColorsapce, dither = true, tree_depth = 0, measure_error = false)
 *   @param number_colors [Numeric] the maximum number of colors to use in the output images.
 *   @param colorspace [Magick::ColorspaceType] the colorspace to quantize in.
 *   @param dither [Magick::DitherMethod, Boolean] a DitherMethod value or true if you want apply dither.
 *   @param tree_depth [Numeric] specify the tree depth to use while quantizing.
 *   @param measure_error [Boolean] calculate quantization errors when quantizing the image.
 *   @return [Magick::ImageList] a new ImageList with quantized images
 *   @note Sets +@scene+ to the same value as +self.scene+
 */
VALUE
ImageList_quantize(int argc, VALUE *argv, VALUE self)
{
    Image *images, *new_images;
    Image *new_image;
    QuantizeInfo quantize_info;
    ExceptionInfo *exception;
    VALUE new_imagelist, scene;

    GetQuantizeInfo(&quantize_info);

    switch (argc)
    {
        case 5:
            quantize_info.measure_error = (MagickBooleanType) RTEST(argv[4]);
        case 4:
            quantize_info.tree_depth = (unsigned long)NUM2INT(argv[3]);
        case 3:
#if defined(IMAGEMAGICK_7)
            if (rb_obj_is_kind_of(argv[2], Class_DitherMethod))
            {
                VALUE_TO_ENUM(argv[2], quantize_info.dither_method, DitherMethod);
            }
            else
            {
                quantize_info.dither_method = RTEST(argv[2]) ? UndefinedDitherMethod : NoDitherMethod;
            }
#else
            if (rb_obj_is_kind_of(argv[2], Class_DitherMethod))
            {
                VALUE_TO_ENUM(argv[2], quantize_info.dither_method, DitherMethod);
                quantize_info.dither = (MagickBooleanType)(quantize_info.dither_method != NoDitherMethod);
            }
            else
            {
                quantize_info.dither = (MagickBooleanType) RTEST(argv[2]);
            }
#endif
        case 2:
            VALUE_TO_ENUM(argv[1], quantize_info.colorspace, ColorspaceType);
        case 1:
            quantize_info.number_colors = NUM2ULONG(argv[0]);
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 5)", argc);
            break;
    }


    // Convert image array to image sequence, clone image sequence.
    images = images_from_imagelist(self);
    exception = AcquireExceptionInfo();
    GVL_STRUCT_TYPE(CloneImageList) args_CloneImageList = { images, exception };
    new_images = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(CloneImageList), &args_CloneImageList);
    rm_split(images);
    rm_check_exception(exception, new_images, DestroyOnError);

    rm_ensure_result(new_images);

#if defined(IMAGEMAGICK_7)
    GVL_STRUCT_TYPE(QuantizeImages) args_QuantizeImages = { &quantize_info, new_images, exception };
#else
    GVL_STRUCT_TYPE(QuantizeImages) args_QuantizeImages = { &quantize_info, new_images };
#endif
    CALL_FUNC_WITHOUT_GVL(GVL_FUNC(QuantizeImages), &args_QuantizeImages);
    rm_check_exception(exception, new_images, DestroyOnError);
    DestroyExceptionInfo(exception);

    // Create new ImageList object, convert mapped image sequence to images,
    // append to images array.
    new_imagelist = ImageList_new();
    while ((new_image = RemoveFirstImageFromList(&new_images)))
    {
        imagelist_push(new_imagelist, rm_image_new(new_image));
    }

    // Set @scene in new ImageList object to same value as in self.
    scene = rb_iv_get(self, "@scene");
    rb_iv_set(new_imagelist, "@scene", scene);

    RB_GC_GUARD(new_imagelist);
    RB_GC_GUARD(scene);

    return new_imagelist;
}


/**
 * Reduce the colors used in the image list to the set of colors in +remap_image+.
 *
 * @overload remap(remap_image = nil, dither_method = Magick::RiemersmaDitherMethod)
 *   @param remap_image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param dither_method [Magick::DitherMethod] a DitherMethod value.
 *   @return [Magick::ImageList] self
 *   @note Modifies images in-place.
 */
VALUE
ImageList_remap(int argc, VALUE *argv, VALUE self)
{
    Image *images, *remap_image = NULL;
    QuantizeInfo quantize_info;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    if (argc > 0 && argv[0] != Qnil)
    {
        VALUE t = rm_cur_image(argv[0]);
        remap_image = rm_check_destroyed(t);
        RB_GC_GUARD(t);
    }

    GetQuantizeInfo(&quantize_info);

    if (argc > 1)
    {
        VALUE_TO_ENUM(argv[1], quantize_info.dither_method, DitherMethod);
#if defined(IMAGEMAGICK_6)
        quantize_info.dither = MagickTrue;
#endif
    }
    if (argc > 2)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or 2)", argc);
    }

    images = images_from_imagelist(self);

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    GVL_STRUCT_TYPE(RemapImages) args = { &quantize_info, images, remap_image, exception };
    CALL_FUNC_WITHOUT_GVL(GVL_FUNC(RemapImages), &args);
    rm_split(images);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    GVL_STRUCT_TYPE(RemapImages) args = { &quantize_info, images, remap_image };
    CALL_FUNC_WITHOUT_GVL(GVL_FUNC(RemapImages), &args);
    rm_split(images);
    rm_check_image_exception(images, RetainOnError);
#endif

    return self;
}


/**
 * Return the imagelist as a blob (a String).
 *
 * @overload to_blob
 *
 * @overload to_blob
 *   Runs an info parm block if present - the user can specify the image format and depth
 *   @yield [info]
 *   @yieldparam info [Magick::Image::Info]
 *
 * @return [String] the blob
 */
VALUE
ImageList_to_blob(VALUE self)
{
    Image *images, *image;
    Info *info;
    VALUE info_obj;
    VALUE blob_str;
    void *blob = NULL;
    size_t length = 0;
    ExceptionInfo *exception;

    info_obj = rm_info_new();
    TypedData_Get_Struct(info_obj, Info, &rm_info_data_type, info);

    // Convert the images array to an images sequence.
    images = images_from_imagelist(self);

    exception = AcquireExceptionInfo();
    SetImageInfo(info, MagickTrue, exception);
    rm_check_exception(exception, images, RetainOnError);

    if (*info->magick != '\0')
    {
        Image *img;
        for (img = images; img; img = GetNextImageInList(img))
        {
            strlcpy(img->magick, info->magick, sizeof(img->magick));
        }
    }

    for (image = images; image; image = GetNextImageInList(image))
    {
        rm_sync_image_options(image, info);
    }

    // Unconditionally request multi-images support. The worst that
    // can happen is that there's only one image or the format
    // doesn't support multi-image files.
    info->adjoin = MagickTrue;
    GVL_STRUCT_TYPE(ImagesToBlob) args = { info, images, &length, exception };
    blob = CALL_FUNC_WITHOUT_GVL(GVL_FUNC(ImagesToBlob), &args);
    if (blob && exception->severity >= ErrorException)
    {
        magick_free((void*)blob);
        blob = NULL;
        length = 0;
    }
    rm_split(images);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);


    if (length == 0 || !blob)
    {
        return Qnil;
    }

    blob_str = rb_str_new((const char *)blob, (long)length);
    magick_free((void*)blob);

    RB_GC_GUARD(info_obj);
    RB_GC_GUARD(blob_str);

    return blob_str;
}


/**
 * Write all the images to the specified file. If the file format supports
 * multi-image files, and the 'images' array contains more than one image, then
 * the images will be written as a single multi-image file. Otherwise each image
 * will be written to a separate file.
 *
 * @yield [info]
 * @yieldparam info [Magick::Image::Info]
 * @param file [File, String] the file
 */
VALUE
ImageList_write(VALUE self, VALUE file)
{
    Image *images, *img;
    Info *info;
    const MagickInfo *m;
    VALUE info_obj;
    unsigned long scene;
    ExceptionInfo *exception;

    info_obj = rm_info_new();
    TypedData_Get_Struct(info_obj, Info, &rm_info_data_type, info);


    if (TYPE(file) == T_FILE)
    {
        rb_io_t *fptr;

        // Ensure file is open - raise error if not
        GetOpenFile(file, fptr);
        rb_io_check_writable(fptr);

        add_format_prefix(info, rm_io_path(file));
#if defined(_WIN32)
        SetImageInfoFile(info, NULL);
#else
        SetImageInfoFile(info, rb_io_stdio_file(fptr));
#endif
    }
    else
    {
        add_format_prefix(info, file);
        SetImageInfoFile(info, NULL);
    }

    // Convert the images array to an images sequence.
    images = images_from_imagelist(self);

    // Copy the filename into each image. Set a scene number to be used if
    // writing multiple files. (Ref: ImageMagick's utilities/convert.c
    for (scene = 0, img = images; img; img = GetNextImageInList(img))
    {
        img->scene = scene++;
        strlcpy(img->filename, info->filename, sizeof(img->filename));
    }

    // Find out if the format supports multi-images files.
    exception = AcquireExceptionInfo();
    SetImageInfo(info, MagickTrue, exception);
    rm_check_exception(exception, images, RetainOnError);

    m = GetMagickInfo(info->magick, exception);
    rm_check_exception(exception, images, RetainOnError);
#if defined(IMAGEMAGICK_6)
    DestroyExceptionInfo(exception);
#endif

    // Tell WriteImage if we want a multi-images file.
    if (imagelist_length(self) > 1L && m && GetMagickAdjoin(m))
    {
        info->adjoin = MagickTrue;
    }

    for (img = images; img; img = GetNextImageInList(img))
    {
        rm_sync_image_options(img, info);
#if defined(IMAGEMAGICK_7)
        GVL_STRUCT_TYPE(WriteImage) args = { info, img, exception };
        CALL_FUNC_WITHOUT_GVL(GVL_FUNC(WriteImage), &args);
        rm_check_exception(exception, img, RetainOnError);
#else
        GVL_STRUCT_TYPE(WriteImage) args = { info, img };
        CALL_FUNC_WITHOUT_GVL(GVL_FUNC(WriteImage), &args);
        // images will be split before raising an exception
        rm_check_image_exception(images, RetainOnError);
#endif
        if (info->adjoin)
        {
            break;
        }
    }

#if defined(IMAGEMAGICK_7)
    DestroyExceptionInfo(exception);
#endif

    rm_split(images);

    RB_GC_GUARD(info_obj);

    return self;
}

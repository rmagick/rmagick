/**************************************************************************//**
 * ImageList class method definitions for RMagick.
 *
 * Copyright &copy; 2002 - 2009 by Timothy P. Hunter
 *
 * Changes since Nov. 2009 copyright &copy; by Benjamin Thomas and Omer Bar-or
 *
 * @file     rmilist.c
 * @version  $Id: rmilist.c,v 1.94 2009/12/20 02:33:33 baror Exp $
 * @author   Tim Hunter
 ******************************************************************************/

#include "rmagick.h"

static Image *clone_imagelist(Image *);
static Image *images_from_imagelist(VALUE);
static long imagelist_length(VALUE);
static long check_imagelist_length(VALUE);
static void imagelist_push(VALUE, VALUE);
static VALUE ImageList_new(void);





/**
 * Repeatedly display the images in the images array to an XWindow screen. The
 * +delay+ argument is the number of 1/100ths of a second (0 to 65535) to delay
 * between images.
 *
 * @overload animate
 *
 * @overload animate(delay)
 *   @param delay [Numeric] the length of time between each image in an animation
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

    Data_Get_Struct(info_obj, Info, info);
#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    AnimateImages(info, images, exception);
    rm_split(images);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    AnimateImages(info, images);
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
    unsigned int stack;
    ExceptionInfo *exception;

    // Convert the image array to an image sequence.
    images = images_from_imagelist(self);

    // If stack == true, stack rectangular images top-to-bottom,
    // otherwise left-to-right.
    stack = RTEST(stack_arg);

    exception = AcquireExceptionInfo();
    new_image = AppendImages(images, stack, exception);
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
    new_image = EvaluateImages(images, MeanEvaluateOperator, exception);

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
    new_images = CoalesceImages(images, exception);
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
                channel |= AlphaChannel;
            else
                rb_raise(rb_eArgError, "invalid number of images in this image list");
        case 4:
            if (colorspace == CMYKColorspace)
                channel |= IndexChannel;
            else
                channel |= AlphaChannel;
        case 3:
            channel |= GreenChannel;
            channel |= BlueChannel;
            break;
        case 2:
            channel |= AlphaChannel;
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
    new_image = CombineImages(images, channel, exception);
#else
    new_image = CombineImages(images, colorspace, exception);
#endif

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
 * @overload composite_layers(images, operator)
 *   - Default operator is {Magick::OverCompositeOp}
 *   @param images [Magick::ImageList] the source images
 *   @param operator [Magick::CompositeOperator] the operator
 *
 * @return [Magick::ImageList] a new imagelist
 */
VALUE
ImageList_composite_layers(int argc, VALUE *argv, VALUE self)
{
    VALUE source_images;
    Image *dest, *source, *new_images;
    RectangleInfo geometry;
    CompositeOperator operator = OverCompositeOp;
    ExceptionInfo *exception;

    switch (argc)
    {
        case 2:
            VALUE_TO_ENUM(argv[1], operator, CompositeOperator);
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
    CompositeLayers(new_images, operator, source, geometry.x, geometry.y, exception);
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
    new_images = CompareImagesLayers(images, CompareAnyLayer, exception);
#else
    new_images = DeconstructImages(images, exception);
#endif
    rm_split(images);
    rm_check_exception(exception, new_images, DestroyOnError);
    DestroyExceptionInfo(exception);

    return rm_imagelist_from_images(new_images);
}


/**
 * Display all the images to an X window screen.
 *
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
    Data_Get_Struct(info_obj, Info, info);

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

    new_image = MergeImageLayers(images, FlattenLayer, exception);

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
 *   @yield [Magick::ImageList::Montage]
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
        // Run the block in the instance's context, allowing the app to modify the
        // object's attributes.
        if (rb_proc_arity(rb_block_proc()) == 0)
        {
            rb_warn("passing a block without an image argument is deprecated");
            rb_obj_instance_eval(0, NULL, montage_obj);
        }
        else
        {
            rb_yield(montage_obj);
        }
    }

    Data_Get_Struct(montage_obj, Montage, montage);

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
    new_images = MontageImages(images, montage->info, exception);
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
    long number_images;


    // Use a signed long so we can test for a negative argument.
    number_images = NUM2LONG(nimages);
    if (number_images <= 0)
    {
        rb_raise(rb_eArgError, "number of intervening images must be > 0");
    }

    images = images_from_imagelist(self);
    exception = AcquireExceptionInfo();
    new_images = MorphImages(images, (unsigned long)number_images, exception);
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
    new_image = MergeImageLayers(images, MosaicLayer, exception);

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
            new_images = CoalesceImages(images, exception);
            break;
        case DisposeLayer:
            new_images = DisposeImages(images, exception);
            break;
        case OptimizeTransLayer:
            new_images = clone_imagelist(images);
            OptimizeImageTransparency(new_images, exception);
            break;
        case RemoveDupsLayer:
            new_images = clone_imagelist(images);
            RemoveDuplicateLayers(&new_images, exception);
            break;
        case RemoveZeroLayer:
            new_images = clone_imagelist(images);
            RemoveZeroDelayLayers(&new_images, exception);
            break;
        case CompositeLayer:
            rm_split(images);
            DestroyExceptionInfo(exception);
            rb_raise(rb_eNotImpError, "Magick::CompositeLayer is not supported. Use the composite_layers method instead.");
            break;
            // In 6.3.4-ish, OptimizeImageLayer replaced OptimizeLayer
        case OptimizeImageLayer:
            new_images = OptimizeImageLayers(images, exception);
            break;
            // and OptimizeLayer became a "General Purpose, GIF Animation Optimizer" (ref. mogrify.c)
        case OptimizeLayer:
            new_images = CoalesceImages(images, exception);
            rm_split(images);
            rm_check_exception(exception, new_images, DestroyOnError);
            new_images2 = OptimizeImageLayers(new_images, exception);
            DestroyImageList(new_images);
            rm_check_exception(exception, new_images2, DestroyOnError);
            new_images = new_images2;
            OptimizeImageTransparency(new_images, exception);
            rm_check_exception(exception, new_images, DestroyOnError);
            // mogrify supports -dither here. We don't.
            GetQuantizeInfo(&quantize_info);
#if defined(IMAGEMAGICK_7)
            RemapImages(&quantize_info, new_images, NULL, exception);
#else
            RemapImages(&quantize_info, new_images, NULL);
#endif
            break;
        case OptimizePlusLayer:
            new_images = OptimizePlusImageLayers(images, exception);
            break;
        case CompareAnyLayer:
        case CompareClearLayer:
        case CompareOverlayLayer:
#if defined(IMAGEMAGICK_7)
            new_images = CompareImagesLayers(images, mthd, exception);
#else
            new_images = CompareImageLayers(images, mthd, exception);
#endif
            break;
        case MosaicLayer:
            new_images = MergeImageLayers(images, mthd, exception);
            break;
        case FlattenLayer:
            new_images = MergeImageLayers(images, mthd, exception);
            break;
        case MergeLayer:
            new_images = MergeImageLayers(images, mthd, exception);
            break;
        case TrimBoundsLayer:
            new_images = MergeImageLayers(images, mthd, exception);
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

        clone = CloneImage(image, 0, 0, MagickTrue, exception);
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
                quantize_info.dither = quantize_info.dither_method != NoDitherMethod;
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
    new_images = CloneImageList(images, exception);
    rm_split(images);
    rm_check_exception(exception, new_images, DestroyOnError);

    rm_ensure_result(new_images);

#if defined(IMAGEMAGICK_7)
    QuantizeImages(&quantize_info, new_images, exception);
#else
    QuantizeImages(&quantize_info, new_images);
#endif
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
    RemapImages(&quantize_info, images, remap_image, exception);
    rm_split(images);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    RemapImages(&quantize_info, images, remap_image);
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
 *   @yield [Magick::Image::Info]
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
    Data_Get_Struct(info_obj, Info, info);

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
    blob = ImagesToBlob(info, images, &length, exception);
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

    blob_str = rb_str_new(blob, (long)length);
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
    Data_Get_Struct(info_obj, Info, info);


    if (TYPE(file) == T_FILE)
    {
        rb_io_t *fptr;

        // Ensure file is open - raise error if not
        GetOpenFile(file, fptr);
#if defined(_WIN32)
        add_format_prefix(info, fptr->pathv);
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
    if (imagelist_length(self) > 1L && GetMagickAdjoin(m))
    {
        info->adjoin = MagickTrue;
    }

    for (img = images; img; img = GetNextImageInList(img))
    {
        rm_sync_image_options(img, info);
#if defined(IMAGEMAGICK_7)
        WriteImage(info, img, exception);
        rm_check_exception(exception, img, RetainOnError);
#else
        WriteImage(info, img);
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

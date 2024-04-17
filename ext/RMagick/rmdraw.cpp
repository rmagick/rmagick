/**************************************************************************//**
 * Contains Draw class methods.
 *
 * Copyright &copy; 2002 - 2009 by Timothy P. Hunter
 *
 * Changes since Nov. 2009 copyright &copy; by Benjamin Thomas and Omer Bar-or
 *
 * @file     rmdraw.cpp
 * @version  $Id: rmdraw.cpp,v 1.83 2009/12/20 02:33:33 baror Exp $
 * @author   Tim Hunter
 ******************************************************************************/

#include "rmagick.h"
#include "float.h"

static void Draw_compact(void *drawptr);
static void Draw_mark(void *);
static void Draw_destroy(void *);
static size_t Draw_memsize(const void *);
static VALUE new_DrawOptions(void);
static VALUE get_type_metrics(int, VALUE *, VALUE, gvl_function_t);

const rb_data_type_t rm_draw_data_type = {
    "Magick::Draw",
    {
        Draw_mark,
        Draw_destroy,
        Draw_memsize,
        Draw_compact,
    },
    0, 0,
    RUBY_TYPED_FROZEN_SHAREABLE,
};


DEFINE_GVL_STUB4(BlobToImage, const ImageInfo *, const void *, const size_t, ExceptionInfo *);
DEFINE_GVL_STUB4(ImageToBlob, const ImageInfo *, Image *, size_t *, ExceptionInfo *);
#if defined(IMAGEMAGICK_7)
DEFINE_GVL_STUB3(AnnotateImage, Image *, const DrawInfo *, ExceptionInfo *);
DEFINE_GVL_STUB3(DrawImage, Image *, const DrawInfo *, ExceptionInfo *);
DEFINE_GVL_STUB4(GetMultilineTypeMetrics, Image *, const DrawInfo *, TypeMetric *, ExceptionInfo *);
DEFINE_GVL_STUB4(GetTypeMetrics, Image *, const DrawInfo *, TypeMetric *, ExceptionInfo *);
#else
DEFINE_GVL_STUB2(AnnotateImage, Image *, const DrawInfo *);
DEFINE_GVL_STUB2(DrawImage, Image *, const DrawInfo *);
DEFINE_GVL_STUB3(GetMultilineTypeMetrics, Image *, const DrawInfo *, TypeMetric *);
DEFINE_GVL_STUB3(GetTypeMetrics, Image *, const DrawInfo *, TypeMetric *);
#endif


/**
 * Set the affine matrix from an {Magick::AffineMatrix}.
 *
 * @param matrix [Magick::AffineMatrix] the affine matrix
 * @return [Magick::AffineMatrix] the given matrix
 */
VALUE
Draw_affine_eq(VALUE self, VALUE matrix)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    Export_AffineMatrix(&draw->info->affine, matrix);
    return matrix;
}


/**
 * Set the text alignment from an {Magick::AlignType}.
 *
 * @param align [Magick::AlignType] the text alignment
 * @return [Magick::AlignType] the given align
 */
VALUE
Draw_align_eq(VALUE self, VALUE align)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    VALUE_TO_ENUM(align, draw->info->align, AlignType);
    return align;
}


/**
 * Set text decorate from an {Magick::DecorationType}.
 *
 * @param decorate [Magick::DecorationType] the decorate type
 * @return [Magick::DecorationType] the given decorate
 */
VALUE
Draw_decorate_eq(VALUE self, VALUE decorate)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    VALUE_TO_ENUM(decorate, draw->info->decorate, DecorationType);
    return decorate;
}


/**
 * Set density.
 *
 * @param density [String] the density
 * @return [String] the given density
 */
VALUE
Draw_density_eq(VALUE self, VALUE density)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    magick_clone_string(&draw->info->density, StringValueCStr(density));

    return density;
}


/**
 * Set text encoding.
 *
 * @param encoding [String] the encoding name
 * @return [String] the given encoding name
 */
VALUE
Draw_encoding_eq(VALUE self, VALUE encoding)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    magick_clone_string(&draw->info->encoding, StringValueCStr(encoding));

    return encoding;
}


/**
 * Set fill color.
 *
 * @param fill [Magick::Pixel, String] the fill color
 * @return [Magick::Pixel, String] the given fill color
 */
VALUE
Draw_fill_eq(VALUE self, VALUE fill)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    Color_to_PixelColor(&draw->info->fill, fill);
    return fill;
}


/**
 * Accept an image as a fill pattern.
 *
 * @param pattern [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *   imagelist, uses the current image.
 * @return [Magick::Image] the given pattern image
 * @see #stroke_pattern=
 * @see #tile=
 */
VALUE
Draw_fill_pattern_eq(VALUE self, VALUE pattern)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);

    if (draw->info->fill_pattern != NULL)
    {
        // Do not trace destruction
        DestroyImage(draw->info->fill_pattern);
        draw->info->fill_pattern = NULL;
    }

    if (!NIL_P(pattern))
    {
        Image *image;

        pattern = rm_cur_image(pattern);
        image = rm_check_destroyed(pattern);
        // Do not trace creation
        draw->info->fill_pattern = rm_clone_image(image);
    }

    return pattern;
}


/**
 * Set the font name.
 *
 * @param font [String] the font name
 * @return [String] the given font name
 */
VALUE
Draw_font_eq(VALUE self, VALUE font)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    magick_clone_string(&draw->info->font, StringValueCStr(font));

    return font;
}


/**
 * Set the font family name.
 *
 * @param family [String] the font family name
 * @return [String] the given family name
 */
VALUE
Draw_font_family_eq(VALUE self, VALUE family)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    magick_clone_string(&draw->info->family, StringValueCStr(family));

    return family;
}


/**
 * Set the stretch as spacing between text characters.
 *
 * @param stretch [Magick::StretchType] the stretch type
 * @return [Magick::StretchType] the given stretch type
 */
VALUE
Draw_font_stretch_eq(VALUE self, VALUE stretch)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    VALUE_TO_ENUM(stretch, draw->info->stretch, StretchType);
    return stretch;
}


/**
 * Set font style.
 *
 * @param style [Magick::StyleType] the font style
 * @return [Magick::StyleType] the given font style
 */
VALUE
Draw_font_style_eq(VALUE self, VALUE style)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    VALUE_TO_ENUM(style, draw->info->style, StyleType);
    return style;
}


/**
 * Set font weight.
 *
 * @param weight [Magick::WeightType, Numeric] the font weight
 * @return [Magick::WeightType, Numeric] the given font weight
 * @note The font weight can be one of the font weight constants or a number between 100 and 900
 */
VALUE
Draw_font_weight_eq(VALUE self, VALUE weight)
{
    Draw *draw;
    size_t w;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);

    if (FIXNUM_P(weight))
    {
        w = FIX2INT(weight);
        if (w < 100 || w > 900)
        {
            rb_raise(rb_eArgError, "invalid font weight (%" RMIuSIZE " given)", w);
        }
        draw->info->weight = w;
    }
    else
    {
        VALUE_TO_ENUM(weight, w, WeightType);
        switch (w)
        {
            case AnyWeight:
                draw->info->weight = 0;
                break;
            case NormalWeight:
                draw->info->weight = 400;
                break;
            case BoldWeight:
                draw->info->weight = 700;
                break;
            case BolderWeight:
                if (draw->info->weight <= 800)
                    draw->info->weight += 100;
                break;
            case LighterWeight:
                if (draw->info->weight >= 100)
                    draw->info->weight -= 100;
                break;
            default:
                rb_raise(rb_eArgError, "unknown font weight");
                break;
        }
    }

    return weight;
}


/**
 * Set gravity to draw text.
 * Gravity affects text placement in bounding area according to rules:
 *
 * - +NorthWestGravity+  - text bottom-left corner placed at top-left
 * - +NorthGravity+      - text bottom-center placed at top-center
 * - +NorthEastGravity+  - text bottom-right corner placed at top-right
 * - +WestGravity+       - text left-center placed at left-center
 * - +CenterGravity+     - text center placed at center
 * - +EastGravity+       - text right-center placed at right-center
 * - +SouthWestGravity+  - text top-left placed at bottom-left
 * - +SouthGravity+      - text top-center placed at bottom-center
 * - +SouthEastGravity+  - text top-right placed at bottom-right
 *
 * @param grav [Magick::GravityType] this gravity type
 * @return [Magick::GravityType] the given gravity type
 */
VALUE
Draw_gravity_eq(VALUE self, VALUE grav)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    VALUE_TO_ENUM(grav, draw->info->gravity, GravityType);

    return grav;
}


/**
 * Set kerning as spacing between two letters.
 *
 * @param kerning [Float] the kerning
 * @return [Float] the given kerning
 */
VALUE
Draw_kerning_eq(VALUE self, VALUE kerning)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    draw->info->kerning = NUM2DBL(kerning);
    return kerning;
}


/**
 * Set spacing between two lines.
 *
 * @param spacing [Float] the spacing
 * @return [Float] the given spacing
 */
VALUE
Draw_interline_spacing_eq(VALUE self, VALUE spacing)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    draw->info->interline_spacing = NUM2DBL(spacing);
    return spacing;
}


/**
 * Set spacing between two words.
 *
 * @param spacing [Float] the spacing
 * @return [Float] the given spacing
 */
VALUE
Draw_interword_spacing_eq(VALUE self, VALUE spacing)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    draw->info->interword_spacing = NUM2DBL(spacing);
    return spacing;
}


/**
 * Convert an image to a blob and the blob to a String.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Returns Qnil if there is no image
 *
 * @param image the Image to convert
 * @return Ruby string representation of image
 * @see str_to_image
 */
static VALUE
image_to_str(Image *image)
{
    VALUE dimg = Qnil;

    if (image)
    {
        unsigned char *blob;
        size_t length;
        Info *info;
        ExceptionInfo *exception;

        info = CloneImageInfo(NULL);
        exception = AcquireExceptionInfo();
        GVL_STRUCT_TYPE(ImageToBlob) args = { info, image, &length, exception };
        blob = (unsigned char *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(ImageToBlob), &args);
        DestroyImageInfo(info);
        CHECK_EXCEPTION();
        DestroyExceptionInfo(exception);
        dimg = rb_str_new((char *)blob, (long)length);
        magick_free((void*)blob);
    }

    RB_GC_GUARD(dimg);

    return dimg;
}


/**
 * Undo the image_to_str, above.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Returns NULL if the argument is Qnil
 *
 * @param str the Ruby string to convert
 * @return Image represented by str
 * @see image_to_str
 */
static
Image *str_to_image(VALUE str)
{
    Image *image = NULL;

    if (str != Qnil)
    {
        Info *info;
        ExceptionInfo *exception;

        info = CloneImageInfo(NULL);
        exception = AcquireExceptionInfo();
        GVL_STRUCT_TYPE(BlobToImage) args = { info, RSTRING_PTR(str), (size_t)RSTRING_LEN(str), exception };
        image = (Image *)CALL_FUNC_WITHOUT_GVL(GVL_FUNC(BlobToImage), &args);
        DestroyImageInfo(info);
        CHECK_EXCEPTION();
        DestroyExceptionInfo(exception);
    }

    return image;
}


/**
 * Dump custom marshal for Draw objects.
 *
 * - Instead of trying to replicate Ruby's support for cross-system
 *   marshalling, exploit it. Convert the Draw fields to Ruby objects and
 *   store them in a hash. Let Ruby marshal the hash.
 * - Commented out code that dumps/loads fields that are used internally by
 *   ImageMagick and shouldn't be marshaled. I left the code as placeholders
 *   so I'll know which fields have been deliberately omitted.
 *
 * @return [Hash] the marshalled object
 * @todo Handle gradients when christy gets the new gradient support added (23Dec08)
 */
VALUE
Draw_marshal_dump(VALUE self)
{
    Draw *draw;
    VALUE ddraw;

    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);

    // Raise an exception if the Draw has a non-NULL gradient or element_reference field
    if (draw->info->element_reference.type != UndefinedReference
        || draw->info->gradient.type != UndefinedGradient)
    {
        rb_raise(rb_eTypeError, "can't dump gradient definition");
    }

    ddraw = rb_hash_new();

    rb_hash_aset(ddraw, CSTR2SYM("affine"), Import_AffineMatrix(&draw->info->affine));
    rb_hash_aset(ddraw, CSTR2SYM("gravity"), INT2FIX(draw->info->gravity));
    rb_hash_aset(ddraw, CSTR2SYM("fill"), Pixel_from_PixelColor(&draw->info->fill));
    rb_hash_aset(ddraw, CSTR2SYM("stroke"), Pixel_from_PixelColor(&draw->info->stroke));
    rb_hash_aset(ddraw, CSTR2SYM("stroke_width"), rb_float_new(draw->info->stroke_width));
    rb_hash_aset(ddraw, CSTR2SYM("fill_pattern"), image_to_str(draw->info->fill_pattern));
    rb_hash_aset(ddraw, CSTR2SYM("stroke_pattern"), image_to_str(draw->info->stroke_pattern));
    rb_hash_aset(ddraw, CSTR2SYM("stroke_antialias"), draw->info->stroke_antialias ? Qtrue : Qfalse);
    rb_hash_aset(ddraw, CSTR2SYM("text_antialias"), draw->info->text_antialias ? Qtrue : Qfalse);
    rb_hash_aset(ddraw, CSTR2SYM("decorate"), INT2FIX(draw->info->decorate));
    rb_hash_aset(ddraw, CSTR2SYM("font"), MAGICK_STRING_TO_OBJ(draw->info->font));
    rb_hash_aset(ddraw, CSTR2SYM("family"), MAGICK_STRING_TO_OBJ(draw->info->family));
    rb_hash_aset(ddraw, CSTR2SYM("style"), INT2FIX(draw->info->style));
    rb_hash_aset(ddraw, CSTR2SYM("stretch"), INT2FIX(draw->info->stretch));
    rb_hash_aset(ddraw, CSTR2SYM("weight"), ULONG2NUM(draw->info->weight));
    rb_hash_aset(ddraw, CSTR2SYM("encoding"), MAGICK_STRING_TO_OBJ(draw->info->encoding));
    rb_hash_aset(ddraw, CSTR2SYM("pointsize"), rb_float_new(draw->info->pointsize));
    rb_hash_aset(ddraw, CSTR2SYM("density"), MAGICK_STRING_TO_OBJ(draw->info->density));
    rb_hash_aset(ddraw, CSTR2SYM("align"), INT2FIX(draw->info->align));
    rb_hash_aset(ddraw, CSTR2SYM("undercolor"), Pixel_from_PixelColor(&draw->info->undercolor));
    rb_hash_aset(ddraw, CSTR2SYM("clip_units"), INT2FIX(draw->info->clip_units));
#if defined(IMAGEMAGICK_7)
    rb_hash_aset(ddraw, CSTR2SYM("alpha"), QUANTUM2NUM(draw->info->alpha));
#else
    rb_hash_aset(ddraw, CSTR2SYM("opacity"), QUANTUM2NUM(draw->info->opacity));
#endif
    rb_hash_aset(ddraw, CSTR2SYM("kerning"), rb_float_new(draw->info->kerning));
    rb_hash_aset(ddraw, CSTR2SYM("interword_spacing"), rb_float_new(draw->info->interword_spacing));

    // Non-DrawInfo fields
    rb_hash_aset(ddraw, CSTR2SYM("primitives"), draw->primitives);

    return ddraw;
}


/**
 * Load the marshalled object
 *
 * @param ddraw [Hash] the marshalled object
 * @return [Magick::Draw] self, once marshalled
 */
VALUE
Draw_marshal_load(VALUE self, VALUE ddraw)
{
    Draw *draw;
    VALUE val;

    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);

    if (draw->info == NULL)
    {
        ImageInfo *image_info;

        image_info = CloneImageInfo(NULL);
        draw->info = CloneDrawInfo(image_info, (DrawInfo *) NULL);
        DestroyImageInfo(image_info);
    }
    OBJ_TO_MAGICK_STRING(draw->info->geometry, rb_hash_aref(ddraw, CSTR2SYM("geometry")));

    val = rb_hash_aref(ddraw, CSTR2SYM("affine"));
    Export_AffineMatrix(&draw->info->affine, val);

    draw->info->gravity = (GravityType) FIX2INT(rb_hash_aref(ddraw, CSTR2SYM("gravity")));

    val = rb_hash_aref(ddraw, CSTR2SYM("fill"));
    Color_to_PixelColor(&draw->info->fill, val);

    val = rb_hash_aref(ddraw, CSTR2SYM("stroke"));
    Color_to_PixelColor(&draw->info->stroke, val);

    draw->info->stroke_width = NUM2DBL(rb_hash_aref(ddraw, CSTR2SYM("stroke_width")));
    draw->info->fill_pattern = str_to_image(rb_hash_aref(ddraw, CSTR2SYM("fill_pattern")));
    draw->info->stroke_pattern = str_to_image(rb_hash_aref(ddraw, CSTR2SYM("stroke_pattern")));
    draw->info->stroke_antialias = (MagickBooleanType)RTEST(rb_hash_aref(ddraw, CSTR2SYM("stroke_antialias")));
    draw->info->text_antialias = (MagickBooleanType)RTEST(rb_hash_aref(ddraw, CSTR2SYM("text_antialias")));
    draw->info->decorate = (DecorationType) FIX2INT(rb_hash_aref(ddraw, CSTR2SYM("decorate")));
    OBJ_TO_MAGICK_STRING(draw->info->font, rb_hash_aref(ddraw, CSTR2SYM("font")));
    OBJ_TO_MAGICK_STRING(draw->info->family, rb_hash_aref(ddraw, CSTR2SYM("family")));

    draw->info->style = (StyleType) FIX2INT(rb_hash_aref(ddraw, CSTR2SYM("style")));
    draw->info->stretch = (StretchType) FIX2INT(rb_hash_aref(ddraw, CSTR2SYM("stretch")));
    draw->info->weight = NUM2ULONG(rb_hash_aref(ddraw, CSTR2SYM("weight")));
    OBJ_TO_MAGICK_STRING(draw->info->encoding, rb_hash_aref(ddraw, CSTR2SYM("encoding")));
    draw->info->pointsize = NUM2DBL(rb_hash_aref(ddraw, CSTR2SYM("pointsize")));
    OBJ_TO_MAGICK_STRING(draw->info->density, rb_hash_aref(ddraw, CSTR2SYM("density")));
    draw->info->align = (AlignType) FIX2INT(rb_hash_aref(ddraw, CSTR2SYM("align")));

    val = rb_hash_aref(ddraw, CSTR2SYM("undercolor"));
    Color_to_PixelColor(&draw->info->undercolor, val);

    draw->info->clip_units = (ClipPathUnits)FIX2INT(rb_hash_aref(ddraw, CSTR2SYM("clip_units")));
#if defined(IMAGEMAGICK_7)
    draw->info->alpha = NUM2QUANTUM(rb_hash_aref(ddraw, CSTR2SYM("alpha")));
#else
    draw->info->opacity = NUM2QUANTUM(rb_hash_aref(ddraw, CSTR2SYM("opacity")));
#endif
    draw->info->kerning = NUM2DBL(rb_hash_aref(ddraw, CSTR2SYM("kerning")));
    draw->info->interword_spacing = NUM2DBL(rb_hash_aref(ddraw, CSTR2SYM("interword_spacing")));

    draw->primitives = rb_hash_aref(ddraw, CSTR2SYM("primitives"));

    RB_GC_GUARD(val);

    return self;
}


/**
 * Set point size to draw text.
 *
 * @param pointsize [Float] the pointsize
 * @return [Float] the given pointsize
 */
VALUE
Draw_pointsize_eq(VALUE self, VALUE pointsize)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    draw->info->pointsize = NUM2DBL(pointsize);
    return pointsize;
}


/**
 * Set rotation. The argument should be in degrees.
 *
 * @param deg [Float] the number of degrees
 * @return [Float] the given degrees
 */
VALUE
Draw_rotation_eq(VALUE self, VALUE deg)
{
    Draw *draw;
    double degrees;
    AffineMatrix affine, current;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);

    degrees = NUM2DBL(deg);
    if (fabs(degrees) > DBL_EPSILON)
    {
        current   = draw->info->affine;
        affine.sx = cos(DegreesToRadians(fmod(degrees, 360.0)));
        affine.rx = sin(DegreesToRadians(fmod(degrees, 360.0)));
        affine.tx = 0.0;
        affine.ry = (-sin(DegreesToRadians(fmod(degrees, 360.0))));
        affine.sy = cos(DegreesToRadians(fmod(degrees, 360.0)));
        affine.ty = 0.0;

        draw->info->affine.sx = current.sx*affine.sx+current.ry*affine.rx;
        draw->info->affine.rx = current.rx*affine.sx+current.sy*affine.rx;
        draw->info->affine.ry = current.sx*affine.ry+current.ry*affine.sy;
        draw->info->affine.sy = current.rx*affine.ry+current.sy*affine.sy;
        draw->info->affine.tx = current.sx*affine.tx+current.ry*affine.ty+current.tx;
    }

    return deg;
}


/**
 * Set stroke.
 *
 * @param stroke [Magick::Pixel, String] the stroke
 * @return [Magick::Pixel, String] the given stroke
 */
VALUE
Draw_stroke_eq(VALUE self, VALUE stroke)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    Color_to_PixelColor(&draw->info->stroke, stroke);
    return stroke;
}


/**
 * Accept an image as a stroke pattern.
 *
 * @param pattern [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *   imagelist, uses the current image.
 * @return [Magick::Image] the given pattern
 * @see #fill_pattern
 */
VALUE
Draw_stroke_pattern_eq(VALUE self, VALUE pattern)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);

    if (draw->info->stroke_pattern != NULL)
    {
        // Do not trace destruction
        DestroyImage(draw->info->stroke_pattern);
        draw->info->stroke_pattern = NULL;
    }

    if (!NIL_P(pattern))
    {
        Image *image;

        // DestroyDrawInfo destroys the clone
        pattern = rm_cur_image(pattern);
        image = rm_check_destroyed(pattern);
        // Do not trace creation
        draw->info->stroke_pattern = rm_clone_image(image);
    }

    return pattern;
}


/**
 * Set stroke width.
 *
 * @param stroke_width [Float] the stroke width
 * @return [Float] the given stroke width
 */
VALUE
Draw_stroke_width_eq(VALUE self, VALUE stroke_width)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    draw->info->stroke_width = NUM2DBL(stroke_width);
    return stroke_width;
}


/**
 * Set whether to enable text antialias.
 *
 * @param text_antialias [Boolean] true if enable text antialias
 * @return [Boolean] the given value
 */
VALUE
Draw_text_antialias_eq(VALUE self, VALUE text_antialias)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    draw->info->text_antialias = (MagickBooleanType) RTEST(text_antialias);
    return text_antialias;
}


/**
 * Accept an image as a fill pattern. This is alias of {Draw#fill_pattern=}.
 *
 * @param image [Magick::Image] the image to tile
 * @return [Magick::Image] the given image
 */
VALUE
Draw_tile_eq(VALUE self, VALUE image)
{
    return Draw_fill_pattern_eq(self, image);
}


/**
 * Set undercolor.
 *
 * @param undercolor [Magick::Pixel, String] the undercolor
 * @return [Magick::Pixel, String] the given undercolor
 */
VALUE
Draw_undercolor_eq(VALUE self, VALUE undercolor)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    Color_to_PixelColor(&draw->info->undercolor, undercolor);
    return undercolor;
}


/**
 * Annotates an image with text.
 *
 * - Additional Draw attribute methods may be called in the optional block,
 *   which is executed in the context of an Draw object.
 *
 * @param image_arg [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *   imagelist, uses the current image.
 * @param width_arg [Numeric] the width
 * @param height_arg [Numeric] the height
 * @param x_arg [Numeric] x position
 * @param y_arg [Numeric] y position
 * @param text [String] the annotation text
 * @return [Magick::Draw] self
 */
VALUE Draw_annotate(
                   VALUE self,
                   VALUE image_arg,
                   VALUE width_arg,
                   VALUE height_arg,
                   VALUE x_arg,
                   VALUE y_arg,
                   VALUE text)
{
    Draw *draw;
    Image *image;
    unsigned long width, height;
    long x, y;
    AffineMatrix keep;
    char geometry_str[100];
    char *embed_text;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    // Save the affine matrix in case it is modified by
    // Draw#rotation=
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    keep = draw->info->affine;

    image_arg = rm_cur_image(image_arg);
    image = rm_check_frozen(image_arg);

    // If we have an optional parm block, run it in self's context,
    // allowing the app a chance to modify the object's attributes
    if (rb_block_given_p())
    {
        rb_yield(self);
    }

    // Translate & store in Draw structure
    embed_text = StringValueCStr(text);
#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    draw->info->text = InterpretImageProperties(NULL, image, embed_text, exception);
    if (rm_should_raise_exception(exception, RetainExceptionRetention))
    {
        if (draw->info->text)
        {
            magick_free(draw->info->text);
        }
        rm_raise_exception(exception);
    }
#else
    draw->info->text = InterpretImageProperties(NULL, image, embed_text);
#endif
    if (!draw->info->text)
    {
#if defined(IMAGEMAGICK_7)
        DestroyExceptionInfo(exception);
#endif
        rb_raise(rb_eArgError, "no text");
    }

    // Create geometry string, copy to Draw structure, overriding
    // any previously existing value.
    width  = NUM2ULONG(width_arg);
    height = NUM2ULONG(height_arg);
    x      = NUM2LONG(x_arg);
    y      = NUM2LONG(y_arg);

    if (width == 0 && height == 0)
    {
        snprintf(geometry_str, sizeof(geometry_str), "%+ld%+ld", x, y);
    }

    // WxH is non-zero
    else
    {
        snprintf(geometry_str, sizeof(geometry_str), "%lux%lu%+ld%+ld", width, height, x, y);
    }

    magick_clone_string(&draw->info->geometry, geometry_str);

#if defined(IMAGEMAGICK_7)
    GVL_STRUCT_TYPE(AnnotateImage) args = { image, draw->info, exception };
#else
    GVL_STRUCT_TYPE(AnnotateImage) args = { image, draw->info };
#endif
    CALL_FUNC_WITHOUT_GVL(GVL_FUNC(AnnotateImage), &args);

    magick_free(draw->info->text);
    draw->info->text = NULL;
    draw->info->affine = keep;

#if defined(IMAGEMAGICK_7)
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    rm_check_image_exception(image, RetainOnError);
#endif

    return self;
}


/**
 * Clones this object.
 *
 * @return [Magick::Draw] the cloned object
 */
VALUE
Draw_clone(VALUE self)
{
    VALUE clone;

    clone = Draw_dup(self);
    if (OBJ_FROZEN(self))
    {
        OBJ_FREEZE(clone);
    }

    RB_GC_GUARD(clone);

    return clone;
}


/**
 * Draw the image.
 *
 * @overload composite(x, y, width, height, image)
 *   @param x [Numeric] x position
 *   @param y [Numeric] y position
 *   @param width [Numeric] the width
 *   @param height [Numeric] the height
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *
 * @overload composite(x, y, width, height, image, composite_op = Magick::OverCompositeOp)
 *   - The "image" argument can be either an ImageList object or an Image
 *     argument.
 *   @param x [Numeric] x position
 *   @param y [Numeric] y position
 *   @param width [Numeric] the width
 *   @param height [Numeric] the height
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param composite_op [Magick::CompositeOperator] the operator
 *
 * @return [Magick::Draw] self
 */
VALUE
Draw_composite(int argc, VALUE *argv, VALUE self)
{
    Draw *draw;
    const char *op;
    double x, y, width, height;
    CompositeOperator composite_op;
    VALUE image;
    Image *comp_img;
    struct TmpFile_Name *tmpfile_name;
    char name[MaxTextExtent];
    // Buffer for "image" primitive
    char primitive[MaxTextExtent];

    if (argc < 5 || argc > 6)
    {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for 5 or 6)", argc);
    }

    // Retrieve the image to composite
    image = rm_cur_image(argv[4]);
    comp_img = rm_check_destroyed(image);

    x = NUM2DBL(argv[0]);
    y = NUM2DBL(argv[1]);
    width  = NUM2DBL(argv[2]);
    height = NUM2DBL(argv[3]);

    composite_op = OverCompositeOp;
    if (argc == 6)
    {
        VALUE_TO_ENUM(argv[5], composite_op, CompositeOperator);
    }

    op = CommandOptionToMnemonic(MagickComposeOptions, composite_op);
    if (rm_strcasecmp("Unrecognized", op) == 0)
    {
        rb_raise(rb_eArgError, "unknown composite operator (%d)", composite_op);
    }

    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);

    // Create a temp copy of the composite image
    rm_write_temp_image(comp_img, name, sizeof(name));

    // Add the temp filename to the filename array.
    // Use Magick storage since we need to keep the list around
    // until destroy_Draw is called.
    tmpfile_name = (struct TmpFile_Name *)magick_malloc(sizeof(struct TmpFile_Name) + rm_strnlen_s(name, sizeof(name)));
    strcpy(tmpfile_name->name, name);
    tmpfile_name->next = draw->tmpfile_ary;
    draw->tmpfile_ary = tmpfile_name;

    // Form the drawing primitive
    snprintf(primitive, sizeof(primitive), "image %s %g,%g,%g,%g '%s'", op, x, y, width, height, name);


    // Send "primitive" to self.
    rb_funcall(self, rb_intern("primitive"), 1, rb_str_new2(primitive));

    RB_GC_GUARD(image);

    return self;
}


/**
 * Execute the stored drawing primitives on the current image.
 *
 * @param image_arg [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *   imagelist, uses the current image.
 * @return [Magick::Draw] self
 */
VALUE
Draw_draw(VALUE self, VALUE image_arg)
{
    Draw *draw;
    Image *image;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    image_arg = rm_cur_image(image_arg);
    image = rm_check_frozen(image_arg);

    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    if (draw->primitives == 0)
    {
        rb_raise(rb_eArgError, "nothing to draw");
    }

    // Point the DrawInfo structure at the current set of primitives.
    magick_clone_string(&(draw->info->primitive), StringValueCStr(draw->primitives));

#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    GVL_STRUCT_TYPE(DrawImage) args = { image, draw->info, exception };
#else
    GVL_STRUCT_TYPE(DrawImage) args = { image, draw->info };
#endif
    CALL_FUNC_WITHOUT_GVL(GVL_FUNC(DrawImage), &args);

    magick_free(draw->info->primitive);
    draw->info->primitive = NULL;

#if defined(IMAGEMAGICK_7)
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);
#else
    rm_check_image_exception(image, RetainOnError);
#endif

    return self;
}


/**
 * Duplicate a Draw object.
 *
 * - Constructs a new Draw object, then calls initialize_copy.
 *
 * @return [Magick::Draw] the duplicated object
 */
VALUE
Draw_dup(VALUE self)
{
    Draw *draw;
    VALUE dup;

    draw = ALLOC(Draw);
    memset(draw, 0, sizeof(Draw));
    dup = TypedData_Wrap_Struct(CLASS_OF(self), &rm_draw_data_type, draw);
    RB_GC_GUARD(dup);

    return rb_funcall(dup, rm_ID_initialize_copy, 1, self);
}


/**
 * Returns measurements for a given font and text string.
 *
 * - If the image argument has been omitted, use a dummy image, but make sure
 *   the text has none of the special characters that refer to image
 *   attributes.
 *
 * @overload get_type_metrics(text)
 *   @param text [String] The string to be rendered.
 *
 * @overload get_type_metrics(image, text)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param text [String] The string to be rendered.
 *
 * @return [Magick::TypeMetric] The information for a specific string if rendered on a image.
 */
VALUE
Draw_get_type_metrics(
                     int argc,
                     VALUE *argv,
                     VALUE self)
{
    return get_type_metrics(argc, argv, self, GVL_FUNC(GetTypeMetrics));
}


/**
 * Returns measurements for a given font and text string.
 *
 * - If the image argument has been omitted, use a dummy image, but make sure
 *   the text has none of the special characters that refer to image
 *   attributes.
 *
 * @overload get_multiline_type_metrics(text)
 *   @param text [String] The string to be rendered.
 *
 * @overload Draw#get_multiline_type_metrics(image, text)
 *   @param image [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *     imagelist, uses the current image.
 *   @param text [String] The string to be rendered.
 *
 * @return [Magick::TypeMetric] The information for a specific string if rendered on a image.
 */
VALUE
Draw_get_multiline_type_metrics(
                               int argc,
                               VALUE *argv,
                               VALUE self)
{
    return get_type_metrics(argc, argv, self, GVL_FUNC(GetMultilineTypeMetrics));
}


/**
 * Initialize clone, dup methods.
 *
 * @param orig the original object
 * @return [Magick::Draw] self
 */
VALUE Draw_init_copy(VALUE self, VALUE orig)
{
    Draw *copy, *original;

    TypedData_Get_Struct(orig, Draw, &rm_draw_data_type, original);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, copy);

    copy->info = CloneDrawInfo(NULL, original->info);
    if (!copy->info)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }

    if (original->primitives)
    {
        copy->primitives = rb_str_dup(original->primitives);
    }

    return self;
}


/**
 * Initialize Draw object.
 *
 * @return [Magick::Draw] self
 */
VALUE
Draw_initialize(VALUE self)
{
    Draw *draw, *draw_options;
    VALUE options;

    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);

    options = new_DrawOptions();
    TypedData_Get_Struct(options, Draw, &rm_draw_data_type, draw_options);
    draw->info = draw_options->info;
    draw_options->info = NULL;

    RB_GC_GUARD(options);

    return self;
}


/**
 * Display the primitives.
 *
 * @return [String] the draw primitives or the Ruby string "(no primitives defined)"
 *   if they are not defined
 */
VALUE
Draw_inspect(VALUE self)
{
    Draw *draw;

    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    return draw->primitives ? draw->primitives : rb_str_new2("(no primitives defined)");
}


/**
 * Create a new Draw object.
 *
 * @return [Magick::Draw] a new Draw object
 */
VALUE Draw_alloc(VALUE klass)
{
    Draw *draw;
    VALUE draw_obj;

    draw = ALLOC(Draw);
    memset(draw, 0, sizeof(Draw));
    draw_obj = TypedData_Wrap_Struct(klass, &rm_draw_data_type, draw);

    RB_GC_GUARD(draw_obj);

    return draw_obj;
}


/**
 * Add a drawing primitive to the list of primitives in the Draw object.
 *
 * @param primitive [String] the primitive to add
 * @return [Magick::Draw] self
 */
VALUE
Draw_primitive(VALUE self, VALUE primitive)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);

    if (draw->primitives == (VALUE)0)
    {
        draw->primitives = primitive;
    }
    else
    {
        draw->primitives = rb_str_plus(draw->primitives, rb_str_new2("\n"));
        draw->primitives = rb_str_concat(draw->primitives, primitive);
    }

    return self;
}

/**
 * Compact the objects.
 *
 * No Ruby usage (internal function)
 *
 * @param drawptr pointer to a Draw object
 */
static void
Draw_compact(void *drawptr)
{
    Draw *draw = (Draw *)drawptr;

    if (draw->primitives != (VALUE)0)
    {
        draw->primitives = rb_gc_location(draw->primitives);
    }
}

/**
 * Mark referenced objects.
 *
 * No Ruby usage (internal function)
 *
 * @param drawptr pointer to a Draw object
 */
static void
Draw_mark(void *drawptr)
{
    Draw *draw = (Draw *)drawptr;

    if (draw->primitives != (VALUE)0)
    {
        rb_gc_mark_movable(draw->primitives);
    }
}


/**
 * Free the memory associated with an Draw object.
 *
 * No Ruby usage (internal function)
 *
 * @param drawptr pointer to a Draw object
 */
static void
Draw_destroy(void *drawptr)
{
    Draw *draw = (Draw *)drawptr;

    if (draw->info)
    {
        DestroyDrawInfo(draw->info);
        draw->info = NULL;
    }

    // Erase any temporary image files.
    while (draw->tmpfile_ary)
    {
        struct TmpFile_Name *tmpfile_name;

        tmpfile_name = draw->tmpfile_ary;
        draw->tmpfile_ary = draw->tmpfile_ary->next;
        rm_delete_temp_image(tmpfile_name->name);
        magick_free(tmpfile_name);
    }

    xfree(drawptr);
}

/**
  * Get Draw object size.
  *
  * No Ruby usage (internal function)
  *
  * @param infoptr pointer to the Draw object
  */
static size_t
Draw_memsize(const void *drawptr)
{
    return sizeof(Draw);
}

/**
 * Allocate & initialize a DrawOptions object.
 *
 * No Ruby usage (internal function)
 *
 * @return a new DrawOptions object
 */
static VALUE
new_DrawOptions(void)
{
    return DrawOptions_initialize(Draw_alloc(Class_DrawOptions));
}


/**
 * Create a DrawOptions object.
 *
 * - The DrawOptions class is the same as the Draw class except is has only
 *   the attribute writer functions
 *
 * @return [Magick::Image::DrawOptions] a new DrawOptions object
 */
VALUE
DrawOptions_alloc(VALUE klass)
{
    Draw *draw_options;
    VALUE draw_options_obj;

    draw_options = ALLOC(Draw);
    memset(draw_options, 0, sizeof(Draw));
    draw_options_obj = TypedData_Wrap_Struct(klass, &rm_draw_data_type, draw_options);

    RB_GC_GUARD(draw_options_obj);

    return draw_options_obj;
}


/**
 * Initialize a DrawOptions object.
 *
 * @return [Magick::Image::DrawOptions] self
 */
VALUE
DrawOptions_initialize(VALUE self)
{
    Draw *draw_options;

    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw_options);
    draw_options->info = AcquireDrawInfo();
    if (!draw_options->info)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }

    if (rb_block_given_p())
    {
        rb_yield(self);
    }

    return self;
}


/**
 * Allocate a new Magick::Image::PolaroidOptions object.
 *
 * - Internally a PolaroidOptions object is the same as a Draw object. The
 *   methods are implemented by Draw methods in rmdraw.cpp.
 *
 * @return [Magick::Image::PolaroidOptions] a new PolaroidOptions object
 */
VALUE
PolaroidOptions_alloc(VALUE klass)
{
    VALUE polaroid_obj;
    ImageInfo *image_info;
    Draw *draw;

    image_info = CloneImageInfo(NULL);

    draw = ALLOC(Draw);
    memset(draw, 0, sizeof(*draw));

    draw->info = CloneDrawInfo(image_info, (DrawInfo *) NULL);
    (void) DestroyImageInfo(image_info);

    polaroid_obj = TypedData_Wrap_Struct(klass, &rm_draw_data_type, draw);

    RB_GC_GUARD(polaroid_obj);

    return polaroid_obj;
}


/**
 * Initialize a PolaroidOptions object.
 *
 * @yield [opt]
 * @yieldparam opt [Magick::Image::PolaroidOptions] self
 * @return [Magick::Image::PolaroidOptions] self
 */
VALUE
PolaroidOptions_initialize(VALUE self)
{
    Draw *draw;
    ExceptionInfo *exception;

    // Default shadow color
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);

    exception = AcquireExceptionInfo();
    QueryColorCompliance("gray75", AllCompliance, &draw->shadow_color, exception);
    CHECK_EXCEPTION();
    QueryColorCompliance("#dfdfdf", AllCompliance, &draw->info->border_color, exception);
    CHECK_EXCEPTION();
    DestroyExceptionInfo(exception);

    if (rb_block_given_p())
    {
        rb_yield(self);
    }

    return self;
}


/**
 * Allocate a PolaroidOptions instance.
 *
 * No Ruby usage (internal function)
 *
 * @return new PolaroidOptions object
 */
VALUE
rm_polaroid_new(void)
{
    return PolaroidOptions_initialize(PolaroidOptions_alloc(Class_PolaroidOptions));
}


/**
 * Set the shadow color attribute.
 *
 * @param shadow [Magick::Pixel, String] the shadow color
 * @return [Magick::Pixel, String] the given shadow color
 */
VALUE
PolaroidOptions_shadow_color_eq(VALUE self, VALUE shadow)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    Color_to_PixelColor(&draw->shadow_color, shadow);
    return shadow;
}


/**
 * Set the border color.
 *
 * @param border [Magick::Pixel, String] the border color
 * @return [Magick::Pixel, String] the given border color
 */
VALUE
PolaroidOptions_border_color_eq(VALUE self, VALUE border)
{
    Draw *draw;

    rb_check_frozen(self);
    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
    Color_to_PixelColor(&draw->info->border_color, border);
    return border;
}


/**
 * Create a dummy object of an image class.
 *
 * No Ruby usage (internal function)
 *
 * @param klass the class for which to create a dummy
 * @return the newly allocated dummy
 */
static VALUE
get_dummy_tm_img(VALUE klass)
{
#define DUMMY_IMG_CLASS_VAR "@@_dummy_img_"
    VALUE dummy_img = 0;

    if (rb_cvar_defined(klass, rb_intern(DUMMY_IMG_CLASS_VAR)) != Qtrue)
    {
        Info *info;
        Image *image;

        info = CloneImageInfo(NULL);
        if (!info)
        {
            rb_raise(rb_eNoMemError, "not enough memory to continue");
        }
        image = rm_acquire_image(info);
        DestroyImageInfo(info);

        if (!image)
        {
            rb_raise(rb_eNoMemError, "not enough memory to continue");
        }
        dummy_img = rm_image_new(image);

        rb_cv_set(klass, DUMMY_IMG_CLASS_VAR, dummy_img);
    }
    dummy_img = rb_cv_get(klass, DUMMY_IMG_CLASS_VAR);

    RB_GC_GUARD(dummy_img);

    return dummy_img;
}


// aliases for common use of structure types; GetMultilineTypeMetrics, GetTypeMetrics
typedef GVL_STRUCT_TYPE(GetTypeMetrics) GVL_STRUCT_TYPE(get_type_metrics);

/**
 * Call a get-type-metrics function.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - called by Draw_get_type_metrics and Draw_get_multiline_type_metrics
 *
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @param getter which type metrics to get
 * @return the type metrics
 * @see Draw_get_type_metrics
 * @see Draw_get_multiline_type_metrics
 */
static VALUE
get_type_metrics(int argc, VALUE *argv, VALUE self, gvl_function_t fp)
{
    Image *image;
    Draw *draw;
    VALUE t;
    TypeMetric metrics;
    char *text = NULL;
    size_t text_l;
    MagickBooleanType okay;
#if defined(IMAGEMAGICK_7)
    ExceptionInfo *exception;
#endif

    switch (argc)
    {
        case 1:                   // use default image
            text = rm_str2cstr(argv[0], &text_l);
            TypedData_Get_Struct(get_dummy_tm_img(CLASS_OF(self)), Image, &rm_image_data_type, image);
            break;
        case 2:
            t = rm_cur_image(argv[0]);
            image = rm_check_destroyed(t);
            text = rm_str2cstr(argv[1], &text_l);
            break;                  // okay
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 1 or 2)", argc);
            break;
    }

    if (text_l == 0)
    {
        rb_raise(rb_eArgError, "no text to measure");
    }

    TypedData_Get_Struct(self, Draw, &rm_draw_data_type, draw);
#if defined(IMAGEMAGICK_7)
    exception = AcquireExceptionInfo();
    draw->info->text = InterpretImageProperties(NULL, image, text, exception);
    if (rm_should_raise_exception(exception, RetainExceptionRetention))
    {
        if (draw->info->text)
        {
            magick_free(draw->info->text);
        }
        rm_raise_exception(exception);
    }
#else
    draw->info->text = InterpretImageProperties(NULL, image, text);
#endif
    if (!draw->info->text)
    {
#if defined(IMAGEMAGICK_7)
        DestroyExceptionInfo(exception);
#endif
        rb_raise(rb_eArgError, "no text to measure");
    }

#if defined(IMAGEMAGICK_7)
    GVL_STRUCT_TYPE(get_type_metrics) args = { image, draw->info, &metrics, exception };
#else
    GVL_STRUCT_TYPE(get_type_metrics) args = { image, draw->info, &metrics };
#endif
    void *ret = CALL_FUNC_WITHOUT_GVL(fp, &args);
    okay = static_cast<MagickBooleanType>(reinterpret_cast<intptr_t &>(ret));

    magick_free(draw->info->text);
    draw->info->text = NULL;

    if (!okay)
    {
#if defined(IMAGEMAGICK_7)
        CHECK_EXCEPTION();
        DestroyExceptionInfo(exception);
#else
        rm_check_image_exception(image, RetainOnError);
#endif

        // Shouldn't get here...
        rb_raise(rb_eRuntimeError, "Can't measure text. Are the fonts installed? "
                 "Is the FreeType library installed?");
    }
#if defined(IMAGEMAGICK_7)
    DestroyExceptionInfo(exception);
#endif

    RB_GC_GUARD(t);

    return Import_TypeMetric(&metrics);
}

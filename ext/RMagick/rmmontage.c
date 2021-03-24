/**************************************************************************//**
 * Contains Montage class methods.
 *
 * Copyright &copy; 2002 - 2009 by Timothy P. Hunter
 *
 * Changes since Nov. 2009 copyright &copy; by Benjamin Thomas and Omer Bar-or
 *
 * @file     rmmontage.c
 * @version  $Id: rmmontage.c,v 1.5 2009/12/20 02:33:33 baror Exp $
 * @author   Tim Hunter
 ******************************************************************************/

#include "rmagick.h"





/**
 * Destory the MontageInfo struct and free the Montage struct.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - If the Magick::ImageList::Montage#texture method wrote a texture file, the file is
 *     deleted here.
 *
 * @param obj the montage object
 */
static void
destroy_Montage(void *obj)
{
    Montage *montage = obj;

    // If we saved a temporary texture image, delete it now.
    if (montage->info && montage->info->texture != NULL)
    {
        rm_delete_temp_image(montage->info->texture);
        magick_free(montage->info->texture);
        montage->info->texture = NULL;
    }
    if (montage->info)
    {
        DestroyMontageInfo(montage->info);
        montage->info = NULL;
    }
    xfree(montage);
}


/**
 * Create a new Montage object.
 *
 * @return [Magick::ImageList::Montage] a new Montage object
 */
VALUE
Montage_alloc(VALUE class)
{
    MontageInfo *montage_info;
    Montage *montage;
    Info *image_info;
    VALUE montage_obj;

    // DO NOT call rm_info_new - we don't want to support an Info parm block.
    image_info = CloneImageInfo(NULL);
    if (!image_info)
    {
        rb_raise(rb_eNoMemError, "not enough memory to initialize Info object");
    }

    montage_info = CloneMontageInfo(image_info, NULL);
    (void) DestroyImageInfo(image_info);

    if (!montage_info)
    {
        rb_raise(rb_eNoMemError, "not enough memory to initialize Magick::ImageList::Montage object");
    }

    montage = ALLOC(Montage);
    montage->info = montage_info;
    montage->compose = OverCompositeOp;
    montage_obj = Data_Wrap_Struct(class, NULL, destroy_Montage, montage);

    RB_GC_GUARD(montage_obj);

    return montage_obj;
}


/**
 * Set background_color value.
 *
 * @param color [Magick::Pixel, String] the color name
 * @return [Magick::Pixel, String] the given color name
 */
VALUE
Montage_background_color_eq(VALUE self, VALUE color)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    Color_to_PixelColor(&montage->info->background_color, color);
    return color;
}


/**
 * Set border_color value.
 *
 * @param color [Magick::Pixel, String] the color name
 * @return [Magick::Pixel, String] the given color name
 */
VALUE
Montage_border_color_eq(VALUE self, VALUE color)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    Color_to_PixelColor(&montage->info->border_color, color);
    return color;
}


/**
 * Set border_width value.
 *
 * @param width [Numeric] the width
 * @return [Numeric] the given width
 */
VALUE
Montage_border_width_eq(VALUE self, VALUE width)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    montage->info->border_width = NUM2ULONG(width);
    return width;
}


/**
 * Set a composition operator.
 *
 * @param compose [Magick::CompositeOperator] the composition operator
 * @return [Magick::CompositeOperator] the given compose operator
 */
VALUE
Montage_compose_eq(VALUE self, VALUE compose)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    VALUE_TO_ENUM(compose, montage->compose, CompositeOperator);
    return compose;
}


/**
 * Set filename value.
 *
 * @param filename [String] the filename
 * @return [String] filename
 */
VALUE
Montage_filename_eq(VALUE self, VALUE filename)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    strlcpy(montage->info->filename, StringValueCStr(filename), sizeof(montage->info->filename));
    return filename;
}


/**
 * Set fill value.
 *
 * @param color [Magick::Pixel, String] the color name
 * @return [Magick::Pixel, String] the given color name
 */
VALUE
Montage_fill_eq(VALUE self, VALUE color)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    Color_to_PixelColor(&montage->info->fill, color);
    return color;
}


/**
 * Set font value.
 *
 * @param font [String] the font name
 * @return [String] the given font name
 */
VALUE
Montage_font_eq(VALUE self, VALUE font)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    magick_clone_string(&montage->info->font, StringValueCStr(font));

    return font;
}


/**
 * Set frame value.
 *
 * - The geometry is a string in the form:
 *      <width>x<height>+<outer-bevel-width>+<inner-bevel-width>
 *   or a Geometry object
 *
 * @param frame_arg [String] the frame geometry
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Montage_frame_eq(VALUE self, VALUE frame_arg)
{
    Montage *montage;
    VALUE frame;

    Data_Get_Struct(self, Montage, montage);
    frame = rb_String(frame_arg);
    magick_clone_string(&montage->info->frame, StringValueCStr(frame));

    RB_GC_GUARD(frame);

    return frame_arg;
}


/**
 * Set geometry value.
 *
 * - The geometry is a string in the form:
 *      <width>x<height>+<outer-bevel-width>+<inner-bevel-width>
 *   or a Geometry object
 *
 * @param geometry_arg [String] the geometry
 * @return [String] the given geometry
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Montage_geometry_eq(VALUE self, VALUE geometry_arg)
{
    Montage *montage;
    VALUE geometry;

    Data_Get_Struct(self, Montage, montage);
    geometry = rb_String(geometry_arg);
    magick_clone_string(&montage->info->geometry, StringValueCStr(geometry));

    RB_GC_GUARD(geometry);

    return geometry_arg;
}


/**
 * Set gravity value.
 *
 * @param gravity [Magick::GravityType] the gravity type
 * @return [Magick::GravityType] the given gravity
 */
VALUE
Montage_gravity_eq(VALUE self, VALUE gravity)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    VALUE_TO_ENUM(gravity, montage->info->gravity, GravityType);
    return gravity;
}


/**
 * Initialize a Montage object. Does nothing currently.
 *
 * @return [Magick::ImageList::Montage] self
 */
VALUE
Montage_initialize(VALUE self)
{
    // Nothing to do!
    return self;
}


/**
 * Set matte_color value.
 *
 * @param color [Magick::Pixel, String] the color name
 * @return [Magick::Pixel, String] the given color name
 */
VALUE
Montage_matte_color_eq(VALUE self, VALUE color)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    Color_to_PixelColor(&montage->info->matte_color, color);
    return color;
}


/**
 * Set pointsize value.
 *
 * @param size [Numeric] the point size
 * @return [Numeric] the given point size
 */
VALUE
Montage_pointsize_eq(VALUE self, VALUE size)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    montage->info->pointsize = NUM2DBL(size);
    return size;
}


/**
 * Set shadow value.
 *
 * @param shadow [Bool] true if the shadow will be enabled
 * @return [Bool] the given value
 */
VALUE
Montage_shadow_eq(VALUE self, VALUE shadow)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    montage->info->shadow = (MagickBooleanType) RTEST(shadow);
    return shadow;
}


/**
 * Set stroke value.
 *
 * @param color [Magick::Pixel, String] the color name
 * @return [Magick::Pixel, String] the given color name
 */
VALUE
Montage_stroke_eq(VALUE self, VALUE color)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    Color_to_PixelColor(&montage->info->stroke, color);
    return color;
}


/**
 * Set texture value.
 *
 * @param texture [Magick::Image, Magick::ImageList] Either an imagelist or an image. If an
 *   imagelist, uses the current image.
 * @return [Magick::Image] the given texture image
 */
VALUE
Montage_texture_eq(VALUE self, VALUE texture)
{
    Montage *montage;
    Image *texture_image;
    char temp_name[MaxTextExtent];

    Data_Get_Struct(self, Montage, montage);

    // If we had a previously defined temp texture image,
    // remove it now in preparation for this new one.
    if (montage->info->texture)
    {
        rm_delete_temp_image(montage->info->texture);
        magick_free(montage->info->texture);
        montage->info->texture = NULL;
    }

    texture = rm_cur_image(texture);
    texture_image = rm_check_destroyed(texture);

    // Write a temp copy of the image & save its name.
    rm_write_temp_image(texture_image, temp_name, sizeof(temp_name));
    magick_clone_string(&montage->info->texture, temp_name);

    return texture;
}


/**
 * Set tile value.
 *
 * - The geometry is a string in the form:
 *      <width>x<height>+<outer-bevel-width>+<inner-bevel-width>
 *   or a Geometry object
 *
 * @param tile_arg [String] the tile geometry
 * @return [String] the given tile geometry
 * @see https://www.imagemagick.org/Magick++/Geometry.html
 */
VALUE
Montage_tile_eq(VALUE self, VALUE tile_arg)
{
    Montage *montage;
    VALUE tile;

    Data_Get_Struct(self, Montage, montage);
    tile = rb_String(tile_arg);
    magick_clone_string(&montage->info->tile, StringValueCStr(tile));

    RB_GC_GUARD(tile);

    return tile_arg;
}


/**
 * Set title value.
 *
 * @param title [String] the title
 * @return [String] the given title
 */
VALUE
Montage_title_eq(VALUE self, VALUE title)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    magick_clone_string(&montage->info->title, StringValueCStr(title));
    return title;
}


/**
 * Return a new Magick::ImageList::Montage object.
 *
 * No Ruby usage (internal function)
 *
 * @return a new Magick::ImageList::Montage object
 */
VALUE
rm_montage_new(void)
{
    return Montage_initialize(Montage_alloc(Class_Montage));
}


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
 *   - If the Magick::Montage#texture method wrote a texture file, the file is
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
        (void) DestroyMontageInfo(montage->info);
        montage->info = NULL;
    }
    xfree(montage);
}


/**
 * Create a new Montage object.
 *
 * Ruby usage:
 *   - @verbatim Montage.new @endverbatim
 *
 * @param class the Ruby class to use
 * @return a new Montage object
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
    (void) (void) DestroyImageInfo(image_info);

    if (!montage_info)
    {
        rb_raise(rb_eNoMemError, "not enough memory to initialize Magick::Montage object");
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
 * Ruby usage:
 *   - @verbatim Magick::Montage#background_color(color-name) @endverbatim
 *
 * @param self this object
 * @param color the color name
 * @return color
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
 * Ruby usage:
 *   - @verbatim Magick::Montage#border_color(color-name) @endverbatim
 *
 * @param self this object
 * @param color the color name
 * @return color
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
 * Ruby usage:
 *   - @verbatim Magick::Montage#border_width(width) @endverbatim
 *
 * @param self this object
 * @param width the width
 * @return width
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
 * Ruby usage:
 *   - @verbatim Magick::Montage#compose(width) @endverbatim
 *
 * @param self this object
 * @param compose the composition operator
 * @return compose
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
 * Ruby usage:
 *   - @verbatim Magick::Montage#filename(name) @endverbatim
 *
 * @param self this object
 * @param filename the filename
 * @return filename
 */
VALUE
Montage_filename_eq(VALUE self, VALUE filename)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    strncpy(montage->info->filename, StringValuePtr(filename), MaxTextExtent-1);
    return filename;
}


/**
 * Set fill value.
 *
 * Ruby usage:
 *   - @verbatim Magick::Montage#fill(color-name) @endverbatim
 *
 * @param self this object
 * @param color the color name
 * @return color
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
 * Ruby usage:
 *   - @verbatim Magick::Montage#font(font-name) @endverbatim
 *
 * @param self this object
 * @param font the font name
 * @return font
 */
VALUE
Montage_font_eq(VALUE self, VALUE font)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    magick_clone_string(&montage->info->font, StringValuePtr(font));

    return font;
}


/**
 * Set frame value.
 *
 * Ruby usage:
 *   - @verbatim Magick::Montage#frame(frame-geometry) @endverbatim
 *
 * Notes:
 *   - The geometry is a string in the form:
 *     @verbatim <width>x<height>+<outer-bevel-width>+<inner-bevel-width> @endverbatim
 *     or a Geometry object
 *
 * @param self this object
 * @param frame_arg the frame geometry
 * @return frame_arg
 */
VALUE
Montage_frame_eq(VALUE self, VALUE frame_arg)
{
    Montage *montage;
    VALUE frame;

    Data_Get_Struct(self, Montage, montage);
    frame = rm_to_s(frame_arg);
    magick_clone_string(&montage->info->frame, StringValuePtr(frame));

    RB_GC_GUARD(frame);

    return frame_arg;
}


/**
 * Set geometry value.
 *
 * Ruby usage:
 *   - @verbatim Magick::Montage#geometry(geometry) @endverbatim
 *
 * @param self this object
 * @param geometry_arg the geometry
 * @return geometry_arg
 */
VALUE
Montage_geometry_eq(VALUE self, VALUE geometry_arg)
{
    Montage *montage;
    VALUE geometry;

    Data_Get_Struct(self, Montage, montage);
    geometry = rm_to_s(geometry_arg);
    magick_clone_string(&montage->info->geometry, StringValuePtr(geometry));

    RB_GC_GUARD(geometry);

    return geometry_arg;
}


/**
 * Set gravity value.
 *
 * Ruby usage:
 *   - @verbatim Magick::Montage#gravity(gravity-type) @endverbatim
 *
 * @param self this object
 * @param gravity the gravity type
 * @return gravity
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
 * Ruby usage:
 *   - @verbatim Magick::Montage#initialize @endverbatim
 *
 * @param self this object
 * @return self
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
 * Ruby usage:
 *   - @verbatim Magick::Montage#matte_color(color-name) @endverbatim
 *
 * @param self this object
 * @param color the color name
 * @return color
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
 * Ruby usage:
 *   - @verbatim Magick::Montage#pointsize= @endverbatim
 *
 * @param self this object
 * @param size the point size
 * @return size
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
 * Ruby usage:
 *   - @verbatim Magick::Montage#shadow= @endverbatim
 *
 * @param self this object
 * @param shadow the shadow
 * @return shadow
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
 * Ruby usage:
 *   - @verbatim Magick::Montage#stroke(color-name) @endverbatim
 *
 * @param self this object
 * @param color the color name
 * @return self
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
 * Ruby usage:
 *   - @verbatim Montage#texture(texture-image) @endverbatim
 *
 * @param self this object
 * @param texture the texture image
 * @return texture
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
    rm_write_temp_image(texture_image, temp_name);
    magick_clone_string(&montage->info->texture, temp_name);

    return texture;
}


/**
 * Set tile value.
 *
 * Ruby usage:
 *   - @verbatim Magick::Montage#tile(tile) @endverbatim
 *
 * @param self this object
 * @param tile_arg the tile
 * @return tile_arg
 */
VALUE
Montage_tile_eq(VALUE self, VALUE tile_arg)
{
    Montage *montage;
    VALUE tile;

    Data_Get_Struct(self, Montage, montage);
    tile = rm_to_s(tile_arg);
    magick_clone_string(&montage->info->tile, StringValuePtr(tile));

    RB_GC_GUARD(tile);

    return tile_arg;
}


/**
 * Set title value.
 *
 * Ruby usage:
 *   - @verbatim Magick::Montage#title(title) @endverbatim
 *
 * @param self this object
 * @param title the title
 * @return title
 */
VALUE
Montage_title_eq(VALUE self, VALUE title)
{
    Montage *montage;

    Data_Get_Struct(self, Montage, montage);
    magick_clone_string(&montage->info->title, StringValuePtr(title));
    return title;
}


/**
 * Return a new Magick::Montage object.
 *
 * No Ruby usage (internal function)
 *
 * @return a new Magick::Montage object
 */
VALUE
rm_montage_new(void)
{
    return Montage_initialize(Montage_alloc(Class_Montage));
}


/**************************************************************************//**
 * Contains various Struct class methods.
 *
 * Copyright &copy; 2002 - 2009 by Timothy P. Hunter
 *
 * Changes since Nov. 2009 copyright &copy; by Benjamin Thomas and Omer Bar-or
 *
 * @file     rmstruct.c
 * @version  $Id: rmstruct.c,v 1.5 2009/12/20 02:33:34 baror Exp $
 * @author   Tim Hunter
 ******************************************************************************/

#include "rmagick.h"




/**
 * Given a C AffineMatrix, create the equivalent AffineMatrix object.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - am = Magick::AffineMatrix.new(sx, rx, ry, sy, tx, ty)
 *
 * @param affine the C AffineMatrix
 * @return a Ruby AffineMatrix object
 */
VALUE
Import_AffineMatrix(AffineMatrix *affine)
{
    VALUE argv[6];

    argv[0] = rb_float_new(affine->sx);
    argv[1] = rb_float_new(affine->rx);
    argv[2] = rb_float_new(affine->ry);
    argv[3] = rb_float_new(affine->sy);
    argv[4] = rb_float_new(affine->tx);
    argv[5] = rb_float_new(affine->ty);
    return rb_class_new_instance(6, argv, Class_AffineMatrix);
}


/**
 * Convert a Magick::AffineMatrix object to a AffineMatrix structure.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - If not initialized, the defaults are [sx,rx,ry,sy,tx,ty] = [1,0,0,1,0,0]
 *
 * @param am The C AffineMatrix to modify
 * @param st the Ruby AffineMatrix object
 */
void
Export_AffineMatrix(AffineMatrix *am, VALUE st)
{
    VALUE values, v;

    if (CLASS_OF(st) != Class_AffineMatrix)
    {
        rb_raise(rb_eTypeError, "type mismatch: %s given",
                 rb_class2name(CLASS_OF(st)));
    }
    values = rb_funcall(st, rm_ID_values, 0);
    v = rb_ary_entry(values, 0);
    am->sx = v == Qnil ? 1.0 : NUM2DBL(v);
    v = rb_ary_entry(values, 1);
    am->rx = v == Qnil ? 0.0 : NUM2DBL(v);
    v = rb_ary_entry(values, 2);
    am->ry = v == Qnil ? 0.0 : NUM2DBL(v);
    v = rb_ary_entry(values, 3);
    am->sy = v == Qnil ? 1.0 : NUM2DBL(v);
    v = rb_ary_entry(values, 4);
    am->tx = v == Qnil ? 0.0 : NUM2DBL(v);
    v = rb_ary_entry(values, 5);
    am->ty = v == Qnil ? 0.0 : NUM2DBL(v);

    RB_GC_GUARD(values);
    RB_GC_GUARD(v);
}


/**
 * Create a Magick::ChromaticityInfo object from a ChromaticityInfo structure.
 *
 * No Ruby usage (internal function)
 *
 * @param ci the C ChromaticityInfo
 * @return a Ruby Magick::ChromaticityInfo object
 */
VALUE
ChromaticityInfo_new(ChromaticityInfo *ci)
{
    VALUE red_primary;
    VALUE green_primary;
    VALUE blue_primary;
    VALUE white_point;

    red_primary   = Import_PrimaryInfo(&ci->red_primary);
    green_primary = Import_PrimaryInfo(&ci->green_primary);
    blue_primary  = Import_PrimaryInfo(&ci->blue_primary);
    white_point   = Import_PrimaryInfo(&ci->white_point);

    RB_GC_GUARD(red_primary);
    RB_GC_GUARD(green_primary);
    RB_GC_GUARD(blue_primary);
    RB_GC_GUARD(white_point);

    return rb_funcall(Class_Chromaticity, rm_ID_new, 4
                    , red_primary, green_primary, blue_primary, white_point);
}


/**
 * Extract the elements from a Magick::ChromaticityInfo and store in a
 * ChromaticityInfo structure.
 *
 * No Ruby usage (internal function)
 *
 * @param ci the C ChromaticityInfo structure to modify
 * @param chrom the Ruby Magick::ChromaticityInfo object
 */
void
Export_ChromaticityInfo(ChromaticityInfo *ci, VALUE chrom)
{
    VALUE chrom_members;
    VALUE red_primary, green_primary, blue_primary, white_point;
    VALUE entry_members, x, y;
    ID values_id;

    if (CLASS_OF(chrom) != Class_Chromaticity)
    {
        rb_raise(rb_eTypeError, "type mismatch: %s given",
                 rb_class2name(CLASS_OF(chrom)));
    }
    values_id = rm_ID_values;

    // Get the struct members in an array
    chrom_members = rb_funcall(chrom, values_id, 0);
    red_primary   = rb_ary_entry(chrom_members, 0);
    green_primary = rb_ary_entry(chrom_members, 1);
    blue_primary  = rb_ary_entry(chrom_members, 2);
    white_point = rb_ary_entry(chrom_members, 3);

    // Get the red_primary PrimaryInfo members in an array
    entry_members = rb_funcall(red_primary, values_id, 0);
    x = rb_ary_entry(entry_members, 0);         // red_primary.x
    ci->red_primary.x = x == Qnil ? 0.0 : NUM2DBL(x);
    y = rb_ary_entry(entry_members, 1);         // red_primary.y
    ci->red_primary.y = y == Qnil ? 0.0 : NUM2DBL(y);
    ci->red_primary.z = 0.0;

    // Get the green_primary PrimaryInfo members in an array
    entry_members = rb_funcall(green_primary, values_id, 0);
    x = rb_ary_entry(entry_members, 0);         // green_primary.x
    ci->green_primary.x = x == Qnil ? 0.0 : NUM2DBL(x);
    y = rb_ary_entry(entry_members, 1);         // green_primary.y
    ci->green_primary.y = y == Qnil ? 0.0 : NUM2DBL(y);
    ci->green_primary.z = 0.0;

    // Get the blue_primary PrimaryInfo members in an array
    entry_members = rb_funcall(blue_primary, values_id, 0);
    x = rb_ary_entry(entry_members, 0);         // blue_primary.x
    ci->blue_primary.x = x == Qnil ? 0.0 : NUM2DBL(x);
    y = rb_ary_entry(entry_members, 1);         // blue_primary.y
    ci->blue_primary.y = y == Qnil ? 0.0 : NUM2DBL(y);
    ci->blue_primary.z = 0.0;

    // Get the white_point PrimaryInfo members in an array
    entry_members = rb_funcall(white_point, values_id, 0);
    x = rb_ary_entry(entry_members, 0);         // white_point.x
    ci->white_point.x = x == Qnil ? 0.0 : NUM2DBL(x);
    y = rb_ary_entry(entry_members, 1);         // white_point.y
    ci->white_point.y = y == Qnil ? 0.0 : NUM2DBL(y);
    ci->white_point.z = 0.0;

    RB_GC_GUARD(chrom_members);
    RB_GC_GUARD(red_primary);
    RB_GC_GUARD(green_primary);
    RB_GC_GUARD(blue_primary);
    RB_GC_GUARD(white_point);
    RB_GC_GUARD(entry_members);
    RB_GC_GUARD(x);
    RB_GC_GUARD(y);
}


/**
 * Create a string representation of a Magick::Chromaticity.
 *
 * Ruby usage:
 *   - @verbatim Magick::Chromaticity#to_s @endverbatim
 *
 * @param self this object
 * @return the string
 */
VALUE
ChromaticityInfo_to_s(VALUE self)
{
    ChromaticityInfo ci;
    char buff[200];

    Export_ChromaticityInfo(&ci, self);
    sprintf(buff, "red_primary=(x=%g,y=%g) "
                  "green_primary=(x=%g,y=%g) "
                  "blue_primary=(x=%g,y=%g) "
                  "white_point=(x=%g,y=%g) ",
                  ci.red_primary.x, ci.red_primary.y,
                  ci.green_primary.x, ci.green_primary.y,
                  ci.blue_primary.x, ci.blue_primary.y,
                  ci.white_point.x, ci.white_point.y);
    return rb_str_new2(buff);
}


/**
 * Convert a ColorInfo structure to a Magick::Color.
 *
 * No Ruby usage (internal function)
 *
 * @param ci the C ColorInfo structure
 * @return a Ruby Magick::Color object
 */
VALUE
Import_ColorInfo(const ColorInfo *ci)
{
    ComplianceType compliance_type;
    VALUE name;
    VALUE compliance;
    VALUE color;

    name       = rb_str_new2(ci->name);

    compliance_type = ci->compliance;
    compliance = ComplianceType_find(compliance_type);
    color      = Pixel_from_MagickPixel(&(ci->color));

    RB_GC_GUARD(name);
    RB_GC_GUARD(compliance);
    RB_GC_GUARD(color);

    return rb_funcall(Class_Color, rm_ID_new, 3
                    , name, compliance, color);
}


/**
 * Convert a Magick::Color to a ColorInfo structure.
 *
 * No Ruby usage (internal function)
 *
 * @param ci the C ColorInfo structure to modify
 * @param st the Ruby Magick::Color object
 */
void
Export_ColorInfo(ColorInfo *ci, VALUE st)
{
    PixelColor pixel;
    VALUE members, m;

    if (CLASS_OF(st) != Class_Color)
    {
        rb_raise(rb_eTypeError, "type mismatch: %s given",
                 rb_class2name(CLASS_OF(st)));
    }

    memset(ci, '\0', sizeof(ColorInfo));

    members = rb_funcall(st, rm_ID_values, 0);

    m = rb_ary_entry(members, 0);
    if (m != Qnil)
    {
        (void) CloneString((char **)&(ci->name), StringValuePtr(m));
    }
    m = rb_ary_entry(members, 1);
    if (m != Qnil)
    {
        VALUE_TO_ENUM(m, ci->compliance, ComplianceType);
    }
    m = rb_ary_entry(members, 2);
    if (m != Qnil)
    {
        Color_to_PixelColor(&pixel, m);
        // For >= 6.3.0, ColorInfo.color is a MagickPixelPacket so we have to
        // convert the PixelPacket.
        rm_init_magickpixel(NULL, &ci->color);
        ci->color.red = (MagickRealType) pixel.red;
        ci->color.green = (MagickRealType) pixel.green;
        ci->color.blue = (MagickRealType) pixel.blue;
        ci->color.opacity = (MagickRealType) OpaqueOpacity;
        ci->color.index = (MagickRealType) 0;
    }

    RB_GC_GUARD(members);
    RB_GC_GUARD(m);
}


/**
 * Convert either a String color name or a Magick::Pixel to a MagickPixel.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - The channel values in a MagickPixel are doubles.
 *
 * @param image the Image
 * @param mpp The MagickPixel to modify
 * @param color the name of the color
 */
void
Color_to_MagickPixel(Image *image, MagickPixel *mpp, VALUE color)
{
    PixelColor pp;

    // image can be NULL
    rm_init_magickpixel(image, mpp);

    Color_to_PixelColor(&pp, color);
    mpp->red = (MagickRealType) pp.red;
    mpp->green = (MagickRealType) pp.green;
    mpp->blue = (MagickRealType) pp.blue;
    mpp->opacity = (MagickRealType) pp.opacity;
}


/**
 * Free the storage allocated by Export_ColorInfo.
 *
 * No Ruby usage (internal function)
 *
 * @param ci the ColorInfo object
 * @see Export_ColorInfo
 */
static void
destroy_ColorInfo(ColorInfo *ci)
{
    magick_free((void*)ci->name);
    ci->name = NULL;
}


/**
 * Return a string representation of a Magick::Color object.
 *
 * Ruby usage:
 *   - @verbatim Color#to_s @endverbatim
 *
 * @param self this object
 * @return the string
 */
VALUE
Color_to_s(VALUE self)
{
    ColorInfo ci;
    char buff[1024];

    Export_ColorInfo(&ci, self);

    sprintf(buff, "name=%s, compliance=%s, "
#if (MAGICKCORE_QUANTUM_DEPTH  == 32 || MAGICKCORE_QUANTUM_DEPTH  == 64) && defined(HAVE_TYPE_LONG_DOUBLE)
                  "color.red=%Lg, color.green=%Lg, color.blue=%Lg, color.alpha=%Lg ",
#else
                  "color.red=%g, color.green=%g, color.blue=%g, color.alpha=%g ",
#endif
                  ci.name,
                  ComplianceType_name(&ci.compliance),
                  ci.color.red, ci.color.green, ci.color.blue, QuantumRange - ci.color.opacity);

    destroy_ColorInfo(&ci);
    return rb_str_new2(buff);
}

/**
 * Convert a TypeInfo structure to a Magick::Font.
 *
 * No Ruby usage (internal function)
 *
 * @param ti the C TypeInfo structure
 * @return a Ruby Magick::Font object
 */
VALUE
Import_TypeInfo(const TypeInfo *ti)
{
    VALUE name, description, family;
    VALUE style, stretch, weight;
    VALUE encoding, foundry, format;

    name        = rb_str_new2(ti->name);
    family      = rb_str_new2(ti->family);
    style       = StyleType_find(ti->style);
    stretch     = StretchType_find(ti->stretch);
    weight      = ULONG2NUM(ti->weight);
    description = ti->description ? rb_str_new2(ti->description) : Qnil;
    encoding    = ti->encoding    ? rb_str_new2(ti->encoding) : Qnil;
    foundry     = ti->foundry     ? rb_str_new2(ti->foundry)  : Qnil;
    format      = ti->format      ? rb_str_new2(ti->format)   : Qnil;

    RB_GC_GUARD(name);
    RB_GC_GUARD(description);
    RB_GC_GUARD(family);
    RB_GC_GUARD(style);
    RB_GC_GUARD(stretch);
    RB_GC_GUARD(weight);
    RB_GC_GUARD(encoding);
    RB_GC_GUARD(foundry);
    RB_GC_GUARD(format);

    return rb_funcall(Class_Font, rm_ID_new, 9
                    , name, description, family, style
                    , stretch, weight, encoding, foundry, format);
}


/**
 * Convert a Magick::Font to a TypeInfo structure.
 *
 * No Ruby usage (internal function)
 *
 * @param ti the C TypeInfo structure to modify
 * @param st the Ruby Magick::Font object
 */
void
Export_TypeInfo(TypeInfo *ti, VALUE st)
{
    VALUE members, m;

    if (CLASS_OF(st) != Class_Font)
    {
        rb_raise(rb_eTypeError, "type mismatch: %s given",
                 rb_class2name(CLASS_OF(st)));
    }

    memset(ti, '\0', sizeof(TypeInfo));

    members = rb_funcall(st, rm_ID_values, 0);
    m = rb_ary_entry(members, 0);
    if (m != Qnil)
    {
        (void) CloneString((char **)&(ti->name), StringValuePtr(m));
    }
    m = rb_ary_entry(members, 1);
    if (m != Qnil)
    {
        (void) CloneString((char **)&(ti->description), StringValuePtr(m));
    }
    m = rb_ary_entry(members, 2);
    if (m != Qnil)
    {
        (void) CloneString((char **)&(ti->family), StringValuePtr(m));
    }
    m = rb_ary_entry(members, 3); ti->style   = m == Qnil ? 0 : FIX2INT(Enum_to_i(m));
    m = rb_ary_entry(members, 4); ti->stretch = m == Qnil ? 0 : FIX2INT(Enum_to_i(m));
    m = rb_ary_entry(members, 5); ti->weight  = m == Qnil ? 0 : FIX2INT(m);

    m = rb_ary_entry(members, 6);
    if (m != Qnil)
        (void) CloneString((char **)&(ti->encoding), StringValuePtr(m));
    m = rb_ary_entry(members, 7);
    if (m != Qnil)
        (void) CloneString((char **)&(ti->foundry), StringValuePtr(m));
    m = rb_ary_entry(members, 8);
    if (m != Qnil)
        (void) CloneString((char **)&(ti->format), StringValuePtr(m));

    RB_GC_GUARD(members);
    RB_GC_GUARD(m);
}


/**
 * Free the storage allocated by Export_TypeInfo.
 *
 * No Ruby usage (internal function)
 *
 * @param ti the TypeInfo object
 * @see Export_TypeInfo
 */
static void
destroy_TypeInfo(TypeInfo *ti)
{
    magick_free((void*)ti->name);
    ti->name = NULL;
    magick_free((void*)ti->description);
    ti->description = NULL;
    magick_free((void*)ti->family);
    ti->family = NULL;
    magick_free((void*)ti->encoding);
    ti->encoding = NULL;
    magick_free((void*)ti->foundry);
    ti->foundry = NULL;
    magick_free((void*)ti->format);
    ti->format = NULL;
}


/**
 * Implement the Font#to_s method.
 *
 * No Ruby usage (internal function)
 *
 * @param self this object
 * @return the string
 */
VALUE
Font_to_s(VALUE self)
{
    TypeInfo ti;
    char weight[20];
    char buff[1024];

    Export_TypeInfo(&ti, self);

    switch (ti.weight)
    {
        case 400:
            strcpy(weight, "NormalWeight");
            break;
        case 700:
            strcpy(weight, "BoldWeight");
            break;
        default:
            sprintf(weight, "%lu", ti.weight);
            break;
    }

    sprintf(buff, "name=%s, description=%s, "
                  "family=%s, style=%s, stretch=%s, weight=%s, "
                  "encoding=%s, foundry=%s, format=%s",
                  ti.name,
                  ti.description,
                  ti.family,
                  StyleType_name(ti.style),
                  StretchType_name(ti.stretch),
                  weight,
                  ti.encoding ? ti.encoding : "",
                  ti.foundry ? ti.foundry : "",
                  ti.format ? ti.format : "");

    destroy_TypeInfo(&ti);
    return rb_str_new2(buff);

}


/**
 * Create a Magick::Point object from a PointInfo structure.
 *
 * No Ruby usage (internal function)
 *
 * @param p the C PointInfo structure
 * @return a Ruby Magick::Point object
 */
VALUE
Import_PointInfo(PointInfo *p)
{
    return rb_funcall(Class_Point, rm_ID_new, 2
                    , INT2FIX(p->x), INT2FIX(p->y));
}


/**
 * Convert a Magick::Point object to a PointInfo structure.
 *
 * No Ruby usage (internal function)
 *
 * @param pi the C PointInfo structure to modify
 * @param sp the Ruby Magick::Point object
 */
void
Export_PointInfo(PointInfo *pi, VALUE sp)
{
    VALUE members, m;

    if (CLASS_OF(sp) != Class_Point)
    {
        rb_raise(rb_eTypeError, "type mismatch: %s given",
                 rb_class2name(CLASS_OF(sp)));
    }
    members = rb_funcall(sp, rm_ID_values, 0);
    m = rb_ary_entry(members, 0);
    pi->x = m == Qnil ? 0.0 : NUM2DBL(m);
    m = rb_ary_entry(members, 1);
    pi->y = m == Qnil ? 0.0 : NUM2DBL(m);

    RB_GC_GUARD(members);
    RB_GC_GUARD(m);
}


/**
 * Create a Magick::PrimaryInfo object from a PrimaryInfo structure.
 *
 * No Ruby usage (internal function)
 *
 * @param p the C PrimaryInfo structure
 * @return a Ruby Magick::PrimaryInfo object
 */
VALUE
Import_PrimaryInfo(PrimaryInfo *p)
{
    return rb_funcall(Class_Primary, rm_ID_new, 3
                    , INT2FIX(p->x), INT2FIX(p->y), INT2FIX(p->z));
}


/**
 * Convert a Magick::PrimaryInfo object to a PrimaryInfo structure.
 *
 * No Ruby usage (internal function)
 *
 * @param pi the C PrimaryInfo structure to modify
 * @param sp the Ruby Magick::PrimaryInfo object
 */
void
Export_PrimaryInfo(PrimaryInfo *pi, VALUE sp)
{
    VALUE members, m;

    if (CLASS_OF(sp) != Class_Primary)
    {
        rb_raise(rb_eTypeError, "type mismatch: %s given",
                 rb_class2name(CLASS_OF(sp)));
    }
    members = rb_funcall(sp, rm_ID_values, 0);
    m = rb_ary_entry(members, 0);
    pi->x = m == Qnil ? 0.0 : NUM2DBL(m);
    m = rb_ary_entry(members, 1);
    pi->y = m == Qnil ? 0.0 : NUM2DBL(m);
    m = rb_ary_entry(members, 2);
    pi->z = m == Qnil ? 0.0 : NUM2DBL(m);

    RB_GC_GUARD(members);
    RB_GC_GUARD(m);
}


/**
 * Create a string representation of a Magick::PrimaryInfo.
 *
 * Ruby usage:
 *   - @verbatim Magick::PrimaryInfo#to_s @endverbatim
 *
 * @param self this object
 * @return the string
 */
VALUE
PrimaryInfo_to_s(VALUE self)
{
    PrimaryInfo pi;
    char buff[100];

    Export_PrimaryInfo(&pi, self);
    sprintf(buff, "x=%g, y=%g, z=%g", pi.x, pi.y, pi.z);
    return rb_str_new2(buff);
}


/**
 * Convert a RectangleInfo structure to a Magick::Rectangle.
 *
 * No Ruby usage (internal function)
 *
 * @param rect the C RectangleInfo structure
 * @return a Ruby Magick::Rectangle object
 */
VALUE
Import_RectangleInfo(RectangleInfo *rect)
{
    VALUE width;
    VALUE height;
    VALUE x, y;

    width  = UINT2NUM(rect->width);
    height = UINT2NUM(rect->height);
    x      = INT2NUM(rect->x);
    y      = INT2NUM(rect->y);

    RB_GC_GUARD(width);
    RB_GC_GUARD(height);
    RB_GC_GUARD(x);
    RB_GC_GUARD(y);

    return rb_funcall(Class_Rectangle, rm_ID_new, 4
                    , width, height, x, y);
}


/**
 * Convert a Magick::Rectangle to a RectangleInfo structure.
 *
 * No Ruby usage (internal function)
 *
 * @param rect the C RectangleInfo structure to modify
 * @param sr the Ruby Magick::Rectangle object
 */
void
Export_RectangleInfo(RectangleInfo *rect, VALUE sr)
{
    VALUE members, m;

    if (CLASS_OF(sr) != Class_Rectangle)
    {
        rb_raise(rb_eTypeError, "type mismatch: %s given",
                 rb_class2name(CLASS_OF(sr)));
    }
    members = rb_funcall(sr, rm_ID_values, 0);
    m = rb_ary_entry(members, 0);
    rect->width  = m == Qnil ? 0 : NUM2ULONG(m);
    m = rb_ary_entry(members, 1);
    rect->height = m == Qnil ? 0 : NUM2ULONG(m);
    m = rb_ary_entry(members, 2);
    rect->x      = m == Qnil ? 0 : NUM2LONG (m);
    m = rb_ary_entry(members, 3);
    rect->y      = m == Qnil ? 0 : NUM2LONG (m);

    RB_GC_GUARD(members);
    RB_GC_GUARD(m);
}


/**
 * Create a string representation of a Magick::Rectangle.
 *
 * Ruby usage:
 *   - @verbatim Magick::Rectangle#to_s @endverbatim
 *
 * @param self this object
 * @return the string
 */
VALUE
RectangleInfo_to_s(VALUE self)
{
    RectangleInfo rect;
    char buff[100];

    Export_RectangleInfo(&rect, self);
    sprintf(buff, "width=%lu, height=%lu, x=%ld, y=%ld"
          , rect.width, rect.height, rect.x, rect.y);
    return rb_str_new2(buff);
}


/**
 * Convert a SegmentInfo structure to a Magick::Segment.
 *
 * No Ruby usage (internal function)
 *
 * @param segment the C SegmentInfo structure
 * @return a Ruby Magick::Segment object
 */
VALUE
Import_SegmentInfo(SegmentInfo *segment)
{
    VALUE x1, y1, x2, y2;

    x1 = rb_float_new(segment->x1);
    y1 = rb_float_new(segment->y1);
    x2 = rb_float_new(segment->x2);
    y2 = rb_float_new(segment->y2);

    RB_GC_GUARD(x1);
    RB_GC_GUARD(y1);
    RB_GC_GUARD(x2);
    RB_GC_GUARD(y2);
    
    return rb_funcall(Class_Segment, rm_ID_new, 4, x1, y1, x2, y2);
}


/**
 * Convert a Magick::Segment to a SegmentInfo structure.
 *
 * No Ruby usage (internal function)
 *
 * @param segment the C SegmentInfo structure to modify
 * @param s the Ruby Magick::Segment object
 */
void
Export_SegmentInfo(SegmentInfo *segment, VALUE s)
{
    VALUE members, m;

    if (CLASS_OF(s) != Class_Segment)
    {
        rb_raise(rb_eTypeError, "type mismatch: %s given",
                 rb_class2name(CLASS_OF(s)));
    }

    members = rb_funcall(s, rm_ID_values, 0);
    m = rb_ary_entry(members, 0);
    segment->x1 = m == Qnil ? 0.0 : NUM2DBL(m);
    m = rb_ary_entry(members, 1);
    segment->y1 = m == Qnil ? 0.0 : NUM2DBL(m);
    m = rb_ary_entry(members, 2);
    segment->x2 = m == Qnil ? 0.0 : NUM2DBL(m);
    m = rb_ary_entry(members, 3);
    segment->y2 = m == Qnil ? 0.0 : NUM2DBL(m);

    RB_GC_GUARD(members);
    RB_GC_GUARD(m);
}


/**
 * Create a string representation of a Magick::Segment.
 *
 * Ruby usage:
 *   - @verbatim Magick::SegmentInfo#to_s @endverbatim
 *
 * @param self this object
 * @return the string
 */
VALUE
SegmentInfo_to_s(VALUE self)
{
    SegmentInfo segment;
    char buff[100];

    Export_SegmentInfo(&segment, self);
    sprintf(buff, "x1=%g, y1=%g, x2=%g, y2=%g"
          , segment.x1, segment.y1, segment.x2, segment.y2);
    return rb_str_new2(buff);
}


/**
 * Convert a TypeMetric structure to a Magick::TypeMetric.
 *
 * No Ruby usage (internal function)
 *
 * @param tm the C TypeMetric structure
 * @return a Ruby Magick::TypeMetric object
 */
VALUE
Import_TypeMetric(TypeMetric *tm)
{
    VALUE pixels_per_em;
    VALUE ascent, descent;
    VALUE width, height, max_advance;
    VALUE bounds, underline_position, underline_thickness;

    pixels_per_em       = Import_PointInfo(&tm->pixels_per_em);
    ascent              = rb_float_new(tm->ascent);
    descent             = rb_float_new(tm->descent);
    width               = rb_float_new(tm->width);
    height              = rb_float_new(tm->height);
    max_advance         = rb_float_new(tm->max_advance);
    bounds              = Import_SegmentInfo(&tm->bounds);
    underline_position  = rb_float_new(tm->underline_position);
    underline_thickness = rb_float_new(tm->underline_position);

    RB_GC_GUARD(pixels_per_em);
    RB_GC_GUARD(ascent);
    RB_GC_GUARD(descent);
    RB_GC_GUARD(width);
    RB_GC_GUARD(height);
    RB_GC_GUARD(max_advance);
    RB_GC_GUARD(bounds);
    RB_GC_GUARD(underline_position);
    RB_GC_GUARD(underline_thickness);

    return rb_funcall(Class_TypeMetric, rm_ID_new, 9
                    , pixels_per_em, ascent, descent, width
                    , height, max_advance, bounds
                    , underline_position, underline_thickness);
}


/**
 * Convert a Magick::TypeMetric to a TypeMetric structure.
 *
 * No Ruby usage (internal function)
 *
 * @param tm the C TypeMetric structure to modify
 * @param st the Ruby Magick::TypeMetric object
 */
void
Export_TypeMetric(TypeMetric *tm, VALUE st)
{
    VALUE members, m;
    VALUE pixels_per_em;

    if (CLASS_OF(st) != Class_TypeMetric)
    {
        rb_raise(rb_eTypeError, "type mismatch: %s given",
                 rb_class2name(CLASS_OF(st)));
    }
    members = rb_funcall(st, rm_ID_values, 0);

    pixels_per_em   = rb_ary_entry(members, 0);
    Export_PointInfo(&tm->pixels_per_em, pixels_per_em);

    m = rb_ary_entry(members, 1);
    tm->ascent      = m == Qnil ? 0.0 : NUM2DBL(m);
    m = rb_ary_entry(members, 2);
    tm->descent     = m == Qnil ? 0.0 : NUM2DBL(m);
    m = rb_ary_entry(members, 3);
    tm->width       = m == Qnil ? 0.0 : NUM2DBL(m);
    m = rb_ary_entry(members, 4);
    tm->height      = m == Qnil ? 0.0 : NUM2DBL(m);
    m = rb_ary_entry(members, 5);
    tm->max_advance = m == Qnil ? 0.0 : NUM2DBL(m);

    m = rb_ary_entry(members, 6);
    Export_SegmentInfo(&tm->bounds, m);

    m = rb_ary_entry(members, 7);
    tm->underline_position  = m == Qnil ? 0.0 : NUM2DBL(m);
    m = rb_ary_entry(members, 8);
    tm->underline_thickness = m == Qnil ? 0.0 : NUM2DBL(m);

    RB_GC_GUARD(members);
    RB_GC_GUARD(m);
    RB_GC_GUARD(pixels_per_em);
}


/**
 * Create a string representation of a Magick::TypeMetric.
 *
 * Ruby usage:
 *   - @verbatim Magick::TypeMetric#to_s @endverbatim
 *
 * @param self this object
 * @return the string
 */
VALUE
TypeMetric_to_s(VALUE self)
{
    VALUE str;
    TypeMetric tm;
    char temp[200];
    int len;

    Export_TypeMetric(&tm, self);

    len = sprintf(temp, "pixels_per_em=(x=%g,y=%g) ", tm.pixels_per_em.x, tm.pixels_per_em.y);
    str = rb_str_new(temp, len);
    len = sprintf(temp, "ascent=%g descent=%g ",tm.ascent, tm.descent);
    rb_str_cat(str, temp, len);
    len = sprintf(temp, "width=%g height=%g max_advance=%g ", tm.width, tm.height, tm.max_advance);
    rb_str_cat(str, temp, len);
    len = sprintf(temp, "bounds.x1=%g bounds.y1=%g ", tm.bounds.x1, tm.bounds.y1);
    rb_str_cat(str, temp, len);
    len = sprintf(temp, "bounds.x2=%g bounds.y2=%g ", tm.bounds.x2, tm.bounds.y2);
    rb_str_cat(str, temp, len);
    len = sprintf(temp, "underline_position=%g underline_thickness=%g", tm.underline_position, tm.underline_thickness);
    rb_str_cat(str, temp, len);

    RB_GC_GUARD(str);

    return str;
}


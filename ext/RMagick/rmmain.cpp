/**************************************************************************//**
 * Contains all module, class, method declarations. Defines all constants.
 * Contains Magick module methods.
 *
 * Copyright &copy; 2002 - 2009 by Timothy P. Hunter
 *
 * Changes since Nov. 2009 copyright &copy; by Benjamin Thomas and Omer Bar-or
 *
 * @file     rmmain.cpp
 * @version  $Id: rmmain.cpp,v 1.303 2009/12/20 02:33:33 baror Exp $
 * @author   Tim Hunter
 ******************************************************************************/

#define MAIN                        // Define external variables
#include "rmagick.h"

#if defined(HAVE_SETMAGICKALIGNEDMEMORYMETHODS)
    #if defined(HAVE_POSIX_MEMALIGN) || defined(HAVE__ALIGNED_MSIZE)
        #define USE_RM_ALIGNED_MALLOC 1

        #if defined(HAVE_MALLOC_H)
            #include <malloc.h>
        #elif defined(HAVE_MALLOC_MALLOC_H)
            #include <malloc/malloc.h>
        #endif
    #endif
#endif

/*----------------------------------------------------------------------------\
| External declarations
\----------------------------------------------------------------------------*/
void Init_RMagick(void);

static void test_Magick_version(void);
static void version_constants(void);
static void features_constant(void);


/*
 *  Enum constants - define a subclass of Enum for the specified enumeration.
 *  Define an instance of the subclass for each member in the enumeration.
 *  Initialize each instance with its name and value.
 */
//! define Ruby enum
#define DEF_ENUM(tag) {\
   VALUE _klass, _enum;\
   _klass =  Class_##tag = rm_define_enum_type(#tag);

//! define Ruby enumerator elements
#define ENUMERATOR(val)\
   _enum = rm_enum_new(_klass, ID2SYM(rb_intern(#val)), INT2NUM(val));\
   rb_define_const(Module_Magick, #val, _enum);

//! define Ruby enumerator elements when name is different from the value
#define ENUMERATORV(name, val)\
   _enum = rm_enum_new(_klass, ID2SYM(rb_intern(#name)), INT2NUM(val));\
   rb_define_const(Module_Magick, #name, _enum);

//! end of an enumerator
#define END_ENUM }

/*
 *  Handle transferring ImageMagick memory allocations/frees to Ruby.
 *  These functions have the same signature as the equivalent C functions.
 */

/**
 * Allocate memory.
 *
 * No Ruby usage (internal function)
 *
 * @param size the size of memory to allocate
 * @return pointer to a block of memory
 */
static void *rm_malloc(size_t size)
{
    return xmalloc((long)size);
}




/**
 * Reallocate memory.
 *
 * No Ruby usage (internal function)
 *
 * @param ptr pointer to the existing block of memory
 * @param size the new size of memory to allocate
 * @return pointer to a block of memory
 */
static void *rm_realloc(void *ptr, size_t size)
{
    return xrealloc(ptr, (long)size);
}




/**
 * Free memory.
 *
 * No Ruby usage (internal function)
 *
 * @param ptr pointer to the existing block of memory
 */
static void rm_free(void *ptr)
{
    xfree(ptr);
}



#if USE_RM_ALIGNED_MALLOC

static size_t
rm_aligned_malloc_size(void *ptr)
{
#if defined(HAVE_MALLOC_USABLE_SIZE)
    return malloc_usable_size(ptr);
#elif defined(HAVE_MALLOC_SIZE)
    return malloc_size(ptr);
#elif defined(HAVE__ALIGNED_MSIZE)
// Refered to https://github.com/ImageMagick/ImageMagick/blob/master/MagickCore/memory-private.h
#define MAGICKCORE_SIZEOF_VOID_P 8
#define CACHE_LINE_SIZE  (8 * MAGICKCORE_SIZEOF_VOID_P)
    size_t _aligned_msize(void *memblock, size_t alignment, size_t offset);
    return _aligned_msize(ptr, CACHE_LINE_SIZE, 0);
#endif
}


/**
 * Allocate aligned memory.
 *
 * No Ruby usage (internal function)
 *
 * @param size the size of memory to allocate
 * @return pointer to a block of memory
 */
static void *rm_aligned_malloc(size_t size, size_t alignment)
{
    void *res;
    size_t allocated_size;

#if defined(HAVE_POSIX_MEMALIGN)
    if (posix_memalign(&res, alignment, size) != 0) {
        return NULL;
    }
#elif defined(HAVE__ALIGNED_MSIZE)
    res = _aligned_malloc(size, alignment);
#endif

    allocated_size = rm_aligned_malloc_size(res);
    rb_gc_adjust_memory_usage(allocated_size);
    return res;
}




/**
 * Free aligned memory.
 *
 * No Ruby usage (internal function)
 *
 * @param ptr pointer to the existing block of memory
 */
static void rm_aligned_free(void *ptr)
{
    size_t allocated_size = rm_aligned_malloc_size(ptr);
    rb_gc_adjust_memory_usage(-allocated_size);

#if defined(HAVE_POSIX_MEMALIGN)
    free(ptr);
#elif defined(HAVE__ALIGNED_MSIZE)
    _aligned_free(ptr);
#endif
}

#endif



/**
 * Use managed memory.
 *
 * No Ruby usage (internal function)
 */
static inline void managed_memory_enable(VALUE enable)
{
    if (enable)
    {
        SetMagickMemoryMethods(rm_malloc, rm_realloc, rm_free);
#if USE_RM_ALIGNED_MALLOC
        SetMagickAlignedMemoryMethods(rm_aligned_malloc, rm_aligned_free);
#endif
    }
    rb_define_const(Module_Magick, "MANAGED_MEMORY", enable);
}

static void set_managed_memory(void)
{
    char *disable = getenv("RMAGICK_DISABLE_MANAGED_MEMORY");

    if (disable)
    {
        managed_memory_enable(Qfalse);
        return;
    }

#if defined(_WIN32)
#if defined(IMAGEMAGICK_GREATER_THAN_EQUAL_6_9_0)
    managed_memory_enable(Qtrue);
#else
    // Disable managed memory feature with ImageMagick 6.8.x or below because causes crash.
    // Refer https://ci.appveyor.com/project/mockdeep/rmagick/builds/24706171
    managed_memory_enable(Qfalse);
#endif
#else
    // Not Windows
    managed_memory_enable(Qtrue);
#endif
}




/**
 * Define the classes and constants.
 *
 * No Ruby usage (internal function)
 */
void
Init_RMagick2(void)
{
#ifdef HAVE_RB_EXT_RACTOR_SAFE
    rb_ext_ractor_safe(true);
#endif

    Module_Magick = rb_define_module("Magick");

    set_managed_memory();

    MagickCoreGenesis("RMagick", MagickFalse);

    test_Magick_version();

    /*-----------------------------------------------------------------------*/
    /* Create IDs for frequently used methods, etc.                          */
    /*-----------------------------------------------------------------------*/

    rm_ID_call             = rb_intern("call");
    rm_ID_changed          = rb_intern("changed");
    rm_ID_cur_image        = rb_intern("cur_image");
    rm_ID_dup              = rb_intern("dup");
    rm_ID_fill             = rb_intern("fill");
    rm_ID_Geometry         = rb_intern("Geometry");
    rm_ID_height           = rb_intern("height");
    rm_ID_initialize_copy  = rb_intern("initialize_copy");
    rm_ID_notify_observers = rb_intern("notify_observers");
    rm_ID_new              = rb_intern("new");
    rm_ID_push             = rb_intern("push");
    rm_ID_values           = rb_intern("values");
    rm_ID_width            = rb_intern("width");

    /*-----------------------------------------------------------------------*/
    /* Module Magick methods                                                 */
    /*-----------------------------------------------------------------------*/

    rb_define_module_function(Module_Magick, "colors", RUBY_METHOD_FUNC(Magick_colors), 0);
    rb_define_module_function(Module_Magick, "fonts", RUBY_METHOD_FUNC(Magick_fonts), 0);
    rb_define_module_function(Module_Magick, "init_formats", RUBY_METHOD_FUNC(Magick_init_formats), 0);
    rb_define_module_function(Module_Magick, "limit_resource", RUBY_METHOD_FUNC(Magick_limit_resource), -1);
    rb_define_module_function(Module_Magick, "set_cache_threshold", RUBY_METHOD_FUNC(Magick_set_cache_threshold), 1);
    rb_define_module_function(Module_Magick, "set_log_event_mask", RUBY_METHOD_FUNC(Magick_set_log_event_mask), -1);
    rb_define_module_function(Module_Magick, "set_log_format", RUBY_METHOD_FUNC(Magick_set_log_format), 1);

    /*-----------------------------------------------------------------------*/
    /* Class Magick::Image methods                                           */
    /*-----------------------------------------------------------------------*/

    Class_Image = rb_define_class_under(Module_Magick, "Image", rb_cObject);

    // Define an alias for Object#display before we override it
    rb_define_alias(Class_Image, "__display__", "display");

    rb_define_alloc_func(Class_Image, Image_alloc);
    rb_define_method(Class_Image, "initialize", RUBY_METHOD_FUNC(Image_initialize), -1);

    rb_define_singleton_method(Class_Image, "constitute", RUBY_METHOD_FUNC(Image_constitute), 4);
    rb_define_singleton_method(Class_Image, "_load", RUBY_METHOD_FUNC(Image__load), 1);
    rb_define_singleton_method(Class_Image, "capture", RUBY_METHOD_FUNC(Image_capture), -1);
    rb_define_singleton_method(Class_Image, "ping", RUBY_METHOD_FUNC(Image_ping), 1);
    rb_define_singleton_method(Class_Image, "read", RUBY_METHOD_FUNC(Image_read), 1);
    rb_define_singleton_method(Class_Image, "read_inline", RUBY_METHOD_FUNC(Image_read_inline), 1);
    rb_define_singleton_method(Class_Image, "from_blob", RUBY_METHOD_FUNC(Image_from_blob), 1);

    // Define the attributes
    rb_define_method(Class_Image, "background_color", RUBY_METHOD_FUNC(Image_background_color), 0);
    rb_define_method(Class_Image, "background_color=", RUBY_METHOD_FUNC(Image_background_color_eq), 1);
    rb_define_method(Class_Image, "base_columns", RUBY_METHOD_FUNC(Image_base_columns), 0);
    rb_define_method(Class_Image, "base_filename", RUBY_METHOD_FUNC(Image_base_filename), 0);
    rb_define_method(Class_Image, "base_rows", RUBY_METHOD_FUNC(Image_base_rows), 0);
    rb_define_method(Class_Image, "bias", RUBY_METHOD_FUNC(Image_bias), 0);
    rb_define_method(Class_Image, "bias=", RUBY_METHOD_FUNC(Image_bias_eq), 1);
    rb_define_method(Class_Image, "black_point_compensation", RUBY_METHOD_FUNC(Image_black_point_compensation), 0);
    rb_define_method(Class_Image, "black_point_compensation=", RUBY_METHOD_FUNC(Image_black_point_compensation_eq), 1);
    rb_define_method(Class_Image, "border_color", RUBY_METHOD_FUNC(Image_border_color), 0);
    rb_define_method(Class_Image, "border_color=", RUBY_METHOD_FUNC(Image_border_color_eq), 1);
    rb_define_method(Class_Image, "bounding_box", RUBY_METHOD_FUNC(Image_bounding_box), 0);
    rb_define_method(Class_Image, "chromaticity", RUBY_METHOD_FUNC(Image_chromaticity), 0);
    rb_define_method(Class_Image, "chromaticity=", RUBY_METHOD_FUNC(Image_chromaticity_eq), 1);
    rb_define_method(Class_Image, "color_profile", RUBY_METHOD_FUNC(Image_color_profile), 0);
    rb_define_method(Class_Image, "color_profile=", RUBY_METHOD_FUNC(Image_color_profile_eq), 1);
    rb_define_method(Class_Image, "colors", RUBY_METHOD_FUNC(Image_colors), 0);
    rb_define_method(Class_Image, "colorspace", RUBY_METHOD_FUNC(Image_colorspace), 0);
    rb_define_method(Class_Image, "colorspace=", RUBY_METHOD_FUNC(Image_colorspace_eq), 1);
    rb_define_method(Class_Image, "columns", RUBY_METHOD_FUNC(Image_columns), 0);
    rb_define_method(Class_Image, "compose", RUBY_METHOD_FUNC(Image_compose), 0);
    rb_define_method(Class_Image, "compose=", RUBY_METHOD_FUNC(Image_compose_eq), 1);
    rb_define_method(Class_Image, "compression", RUBY_METHOD_FUNC(Image_compression), 0);
    rb_define_method(Class_Image, "compression=", RUBY_METHOD_FUNC(Image_compression_eq), 1);
    rb_define_method(Class_Image, "delay", RUBY_METHOD_FUNC(Image_delay), 0);
    rb_define_method(Class_Image, "delay=", RUBY_METHOD_FUNC(Image_delay_eq), 1);
    rb_define_method(Class_Image, "density", RUBY_METHOD_FUNC(Image_density), 0);
    rb_define_method(Class_Image, "density=", RUBY_METHOD_FUNC(Image_density_eq), 1);
    rb_define_method(Class_Image, "depth", RUBY_METHOD_FUNC(Image_depth), 0);
    rb_define_method(Class_Image, "directory", RUBY_METHOD_FUNC(Image_directory), 0);
    rb_define_method(Class_Image, "dispose", RUBY_METHOD_FUNC(Image_dispose), 0);
    rb_define_method(Class_Image, "dispose=", RUBY_METHOD_FUNC(Image_dispose_eq), 1);
    rb_define_method(Class_Image, "endian", RUBY_METHOD_FUNC(Image_endian), 0);
    rb_define_method(Class_Image, "endian=", RUBY_METHOD_FUNC(Image_endian_eq), 1);
    rb_define_method(Class_Image, "extract_info", RUBY_METHOD_FUNC(Image_extract_info), 0);
    rb_define_method(Class_Image, "extract_info=", RUBY_METHOD_FUNC(Image_extract_info_eq), 1);
    rb_define_method(Class_Image, "filename", RUBY_METHOD_FUNC(Image_filename), 0);
    rb_define_method(Class_Image, "filesize", RUBY_METHOD_FUNC(Image_filesize), 0);
    rb_define_method(Class_Image, "filter", RUBY_METHOD_FUNC(Image_filter), 0);
    rb_define_method(Class_Image, "filter=", RUBY_METHOD_FUNC(Image_filter_eq), 1);
    rb_define_method(Class_Image, "format", RUBY_METHOD_FUNC(Image_format), 0);
    rb_define_method(Class_Image, "format=", RUBY_METHOD_FUNC(Image_format_eq), 1);
    rb_define_method(Class_Image, "fuzz", RUBY_METHOD_FUNC(Image_fuzz), 0);
    rb_define_method(Class_Image, "fuzz=", RUBY_METHOD_FUNC(Image_fuzz_eq), 1);
    rb_define_method(Class_Image, "gamma", RUBY_METHOD_FUNC(Image_gamma), 0);
    rb_define_method(Class_Image, "gamma=", RUBY_METHOD_FUNC(Image_gamma_eq), 1);
    rb_define_method(Class_Image, "geometry", RUBY_METHOD_FUNC(Image_geometry), 0);
    rb_define_method(Class_Image, "geometry=", RUBY_METHOD_FUNC(Image_geometry_eq), 1);
    rb_define_method(Class_Image, "gravity", RUBY_METHOD_FUNC(Image_gravity), 0);
    rb_define_method(Class_Image, "gravity=", RUBY_METHOD_FUNC(Image_gravity_eq), 1);
    rb_define_method(Class_Image, "image_type", RUBY_METHOD_FUNC(Image_image_type), 0);
    rb_define_method(Class_Image, "image_type=", RUBY_METHOD_FUNC(Image_image_type_eq), 1);
    rb_define_method(Class_Image, "interlace", RUBY_METHOD_FUNC(Image_interlace), 0);
    rb_define_method(Class_Image, "interlace=", RUBY_METHOD_FUNC(Image_interlace_eq), 1);
    rb_define_method(Class_Image, "iptc_profile", RUBY_METHOD_FUNC(Image_iptc_profile), 0);
    rb_define_method(Class_Image, "iptc_profile=", RUBY_METHOD_FUNC(Image_iptc_profile_eq), 1);
    rb_define_method(Class_Image, "iterations", RUBY_METHOD_FUNC(Image_iterations), 0);        // do not document! Only used by Image#iterations=
    rb_define_method(Class_Image, "iterations=", RUBY_METHOD_FUNC(Image_iterations_eq), 1);        // do not document! Only used by Image#iterations=
    rb_define_method(Class_Image, "matte_color", RUBY_METHOD_FUNC(Image_matte_color), 0);
    rb_define_method(Class_Image, "matte_color=", RUBY_METHOD_FUNC(Image_matte_color_eq), 1);
    rb_define_method(Class_Image, "mean_error_per_pixel", RUBY_METHOD_FUNC(Image_mean_error_per_pixel), 0);
    rb_define_method(Class_Image, "mime_type", RUBY_METHOD_FUNC(Image_mime_type), 0);
    rb_define_method(Class_Image, "montage", RUBY_METHOD_FUNC(Image_montage), 0);
    rb_define_method(Class_Image, "normalized_mean_error", RUBY_METHOD_FUNC(Image_normalized_mean_error), 0);
    rb_define_method(Class_Image, "normalized_maximum_error", RUBY_METHOD_FUNC(Image_normalized_maximum_error), 0);
    rb_define_method(Class_Image, "number_colors", RUBY_METHOD_FUNC(Image_number_colors), 0);
    rb_define_method(Class_Image, "offset", RUBY_METHOD_FUNC(Image_offset), 0);
    rb_define_method(Class_Image, "offset=", RUBY_METHOD_FUNC(Image_offset_eq), 1);
    rb_define_method(Class_Image, "orientation", RUBY_METHOD_FUNC(Image_orientation), 0);
    rb_define_method(Class_Image, "orientation=", RUBY_METHOD_FUNC(Image_orientation_eq), 1);
    rb_define_method(Class_Image, "page", RUBY_METHOD_FUNC(Image_page), 0);
    rb_define_method(Class_Image, "page=", RUBY_METHOD_FUNC(Image_page_eq), 1);
    rb_define_method(Class_Image, "pixel_interpolation_method", RUBY_METHOD_FUNC(Image_pixel_interpolation_method), 0);
    rb_define_method(Class_Image, "pixel_interpolation_method=", RUBY_METHOD_FUNC(Image_pixel_interpolation_method_eq), 1);
    rb_define_method(Class_Image, "quality", RUBY_METHOD_FUNC(Image_quality), 0);
    rb_define_method(Class_Image, "quantum_depth", RUBY_METHOD_FUNC(Image_quantum_depth), 0);
    rb_define_method(Class_Image, "rendering_intent", RUBY_METHOD_FUNC(Image_rendering_intent), 0);
    rb_define_method(Class_Image, "rendering_intent=", RUBY_METHOD_FUNC(Image_rendering_intent_eq), 1);
    rb_define_method(Class_Image, "rows", RUBY_METHOD_FUNC(Image_rows), 0);
    rb_define_method(Class_Image, "scene", RUBY_METHOD_FUNC(Image_scene), 0);
    rb_define_method(Class_Image, "start_loop", RUBY_METHOD_FUNC(Image_start_loop), 0);
    rb_define_method(Class_Image, "start_loop=", RUBY_METHOD_FUNC(Image_start_loop_eq), 1);
    rb_define_method(Class_Image, "class_type", RUBY_METHOD_FUNC(Image_class_type), 0);
    rb_define_method(Class_Image, "class_type=", RUBY_METHOD_FUNC(Image_class_type_eq), 1);
    rb_define_method(Class_Image, "ticks_per_second", RUBY_METHOD_FUNC(Image_ticks_per_second), 0);
    rb_define_method(Class_Image, "ticks_per_second=", RUBY_METHOD_FUNC(Image_ticks_per_second_eq), 1);
    rb_define_method(Class_Image, "total_colors", RUBY_METHOD_FUNC(Image_total_colors), 0);
    rb_define_method(Class_Image, "total_ink_density", RUBY_METHOD_FUNC(Image_total_ink_density), 0);
    rb_define_method(Class_Image, "transparent_color", RUBY_METHOD_FUNC(Image_transparent_color), 0);
    rb_define_method(Class_Image, "transparent_color=", RUBY_METHOD_FUNC(Image_transparent_color_eq), 1);
    rb_define_method(Class_Image, "units", RUBY_METHOD_FUNC(Image_units), 0);
    rb_define_method(Class_Image, "units=", RUBY_METHOD_FUNC(Image_units_eq), 1);
    rb_define_method(Class_Image, "virtual_pixel_method", RUBY_METHOD_FUNC(Image_virtual_pixel_method), 0);
    rb_define_method(Class_Image, "virtual_pixel_method=", RUBY_METHOD_FUNC(Image_virtual_pixel_method_eq), 1);
    rb_define_method(Class_Image, "x_resolution", RUBY_METHOD_FUNC(Image_x_resolution), 0);
    rb_define_method(Class_Image, "x_resolution=", RUBY_METHOD_FUNC(Image_x_resolution_eq), 1);
    rb_define_method(Class_Image, "y_resolution", RUBY_METHOD_FUNC(Image_y_resolution), 0);
    rb_define_method(Class_Image, "y_resolution=", RUBY_METHOD_FUNC(Image_y_resolution_eq), 1);

    rb_define_method(Class_Image, "adaptive_blur", RUBY_METHOD_FUNC(Image_adaptive_blur), -1);
    rb_define_method(Class_Image, "adaptive_blur_channel", RUBY_METHOD_FUNC(Image_adaptive_blur_channel), -1);
    rb_define_method(Class_Image, "adaptive_resize", RUBY_METHOD_FUNC(Image_adaptive_resize), -1);
    rb_define_method(Class_Image, "adaptive_sharpen", RUBY_METHOD_FUNC(Image_adaptive_sharpen), -1);
    rb_define_method(Class_Image, "adaptive_sharpen_channel", RUBY_METHOD_FUNC(Image_adaptive_sharpen_channel), -1);
    rb_define_method(Class_Image, "adaptive_threshold", RUBY_METHOD_FUNC(Image_adaptive_threshold), -1);
    rb_define_method(Class_Image, "add_compose_mask", RUBY_METHOD_FUNC(Image_add_compose_mask), 1);
    rb_define_method(Class_Image, "add_noise", RUBY_METHOD_FUNC(Image_add_noise), 1);
    rb_define_method(Class_Image, "add_noise_channel", RUBY_METHOD_FUNC(Image_add_noise_channel), -1);
    rb_define_method(Class_Image, "add_profile", RUBY_METHOD_FUNC(Image_add_profile), 1);
    rb_define_method(Class_Image, "affine_transform", RUBY_METHOD_FUNC(Image_affine_transform), 1);
    rb_define_method(Class_Image, "remap", RUBY_METHOD_FUNC(Image_remap), -1);
    rb_define_method(Class_Image, "alpha", RUBY_METHOD_FUNC(Image_alpha), -1);
    rb_define_method(Class_Image, "alpha?", RUBY_METHOD_FUNC(Image_alpha_q), 0);
    rb_define_method(Class_Image, "[]", RUBY_METHOD_FUNC(Image_aref), 1);
    rb_define_method(Class_Image, "[]=", RUBY_METHOD_FUNC(Image_aset), 2);
    rb_define_method(Class_Image, "auto_gamma_channel", RUBY_METHOD_FUNC(Image_auto_gamma_channel), -1);
    rb_define_method(Class_Image, "auto_level_channel", RUBY_METHOD_FUNC(Image_auto_level_channel), -1);
    rb_define_method(Class_Image, "auto_orient", RUBY_METHOD_FUNC(Image_auto_orient), 0);
    rb_define_method(Class_Image, "auto_orient!", RUBY_METHOD_FUNC(Image_auto_orient_bang), 0);
    rb_define_method(Class_Image, "properties", RUBY_METHOD_FUNC(Image_properties), 0);
    rb_define_method(Class_Image, "bilevel_channel", RUBY_METHOD_FUNC(Image_bilevel_channel), -1);
    rb_define_method(Class_Image, "black_threshold", RUBY_METHOD_FUNC(Image_black_threshold), -1);
    rb_define_method(Class_Image, "blend", RUBY_METHOD_FUNC(Image_blend), -1);
    rb_define_method(Class_Image, "blue_shift", RUBY_METHOD_FUNC(Image_blue_shift), -1);
    rb_define_method(Class_Image, "blur_image", RUBY_METHOD_FUNC(Image_blur_image), -1);
    rb_define_method(Class_Image, "blur_channel", RUBY_METHOD_FUNC(Image_blur_channel), -1);
    rb_define_method(Class_Image, "border", RUBY_METHOD_FUNC(Image_border), 3);
    rb_define_method(Class_Image, "border!", RUBY_METHOD_FUNC(Image_border_bang), 3);
    rb_define_method(Class_Image, "change_geometry", RUBY_METHOD_FUNC(Image_change_geometry), 1);
    rb_define_method(Class_Image, "change_geometry!", RUBY_METHOD_FUNC(Image_change_geometry), 1);
    rb_define_method(Class_Image, "changed?", RUBY_METHOD_FUNC(Image_changed_q), 0);
    rb_define_method(Class_Image, "channel", RUBY_METHOD_FUNC(Image_channel), 1);
    // An alias for compare_channel
    rb_define_method(Class_Image, "channel_compare", RUBY_METHOD_FUNC(Image_compare_channel), -1);
    rb_define_method(Class_Image, "check_destroyed", RUBY_METHOD_FUNC(Image_check_destroyed), 0);
    rb_define_method(Class_Image, "compare_channel", RUBY_METHOD_FUNC(Image_compare_channel), -1);
    rb_define_method(Class_Image, "channel_depth", RUBY_METHOD_FUNC(Image_channel_depth), -1);
    rb_define_method(Class_Image, "channel_extrema", RUBY_METHOD_FUNC(Image_channel_extrema), -1);
    rb_define_method(Class_Image, "channel_mean", RUBY_METHOD_FUNC(Image_channel_mean), -1);
    rb_define_method(Class_Image, "channel_entropy", RUBY_METHOD_FUNC(Image_channel_entropy), -1);
    rb_define_method(Class_Image, "charcoal", RUBY_METHOD_FUNC(Image_charcoal), -1);
    rb_define_method(Class_Image, "chop", RUBY_METHOD_FUNC(Image_chop), 4);
    rb_define_method(Class_Image, "clut_channel", RUBY_METHOD_FUNC(Image_clut_channel), -1);
    rb_define_method(Class_Image, "clone", RUBY_METHOD_FUNC(Image_clone), 0);
    rb_define_method(Class_Image, "color_flood_fill", RUBY_METHOD_FUNC(Image_color_flood_fill), 5);
    rb_define_method(Class_Image, "color_histogram", RUBY_METHOD_FUNC(Image_color_histogram), 0);
    rb_define_method(Class_Image, "colorize", RUBY_METHOD_FUNC(Image_colorize), -1);
    rb_define_method(Class_Image, "colormap", RUBY_METHOD_FUNC(Image_colormap), -1);
    rb_define_method(Class_Image, "composite", RUBY_METHOD_FUNC(Image_composite), -1);
    rb_define_method(Class_Image, "composite!", RUBY_METHOD_FUNC(Image_composite_bang), -1);
    rb_define_method(Class_Image, "composite_affine", RUBY_METHOD_FUNC(Image_composite_affine), 2);
    rb_define_method(Class_Image, "composite_channel", RUBY_METHOD_FUNC(Image_composite_channel), -1);
    rb_define_method(Class_Image, "composite_channel!", RUBY_METHOD_FUNC(Image_composite_channel_bang), -1);
    rb_define_method(Class_Image, "composite_mathematics", RUBY_METHOD_FUNC(Image_composite_mathematics), -1);
    rb_define_method(Class_Image, "composite_tiled", RUBY_METHOD_FUNC(Image_composite_tiled), -1);
    rb_define_method(Class_Image, "composite_tiled!", RUBY_METHOD_FUNC(Image_composite_tiled_bang), -1);
    rb_define_method(Class_Image, "compress_colormap!", RUBY_METHOD_FUNC(Image_compress_colormap_bang), 0);
    rb_define_method(Class_Image, "contrast", RUBY_METHOD_FUNC(Image_contrast), -1);
    rb_define_method(Class_Image, "contrast_stretch_channel", RUBY_METHOD_FUNC(Image_contrast_stretch_channel), -1);
    rb_define_method(Class_Image, "convolve", RUBY_METHOD_FUNC(Image_convolve), 2);
    rb_define_method(Class_Image, "convolve_channel", RUBY_METHOD_FUNC(Image_convolve_channel), -1);
    rb_define_method(Class_Image, "morphology", RUBY_METHOD_FUNC(Image_morphology), 3);
    rb_define_method(Class_Image, "morphology_channel", RUBY_METHOD_FUNC(Image_morphology_channel), 4);
    rb_define_method(Class_Image, "copy", RUBY_METHOD_FUNC(Image_copy), 0);
    rb_define_method(Class_Image, "crop", RUBY_METHOD_FUNC(Image_crop), -1);
    rb_define_method(Class_Image, "crop!", RUBY_METHOD_FUNC(Image_crop_bang), -1);
    rb_define_method(Class_Image, "cycle_colormap", RUBY_METHOD_FUNC(Image_cycle_colormap), 1);
    rb_define_method(Class_Image, "decipher", RUBY_METHOD_FUNC(Image_decipher), 1);
    rb_define_method(Class_Image, "define", RUBY_METHOD_FUNC(Image_define), 2);
    rb_define_method(Class_Image, "deskew", RUBY_METHOD_FUNC(Image_deskew), -1);
    rb_define_method(Class_Image, "delete_compose_mask", RUBY_METHOD_FUNC(Image_delete_compose_mask), 0);
    rb_define_method(Class_Image, "delete_profile", RUBY_METHOD_FUNC(Image_delete_profile), 1);
    rb_define_method(Class_Image, "despeckle", RUBY_METHOD_FUNC(Image_despeckle), 0);
    rb_define_method(Class_Image, "destroy!", RUBY_METHOD_FUNC(Image_destroy_bang), 0);
    rb_define_method(Class_Image, "destroyed?", RUBY_METHOD_FUNC(Image_destroyed_q), 0);
    rb_define_method(Class_Image, "difference", RUBY_METHOD_FUNC(Image_difference), 1);
    rb_define_method(Class_Image, "dispatch", RUBY_METHOD_FUNC(Image_dispatch), -1);
    rb_define_method(Class_Image, "displace", RUBY_METHOD_FUNC(Image_displace), -1);
    rb_define_method(Class_Image, "display", RUBY_METHOD_FUNC(Image_display), 0);
    rb_define_method(Class_Image, "dissolve", RUBY_METHOD_FUNC(Image_dissolve), -1);
    rb_define_method(Class_Image, "distort", RUBY_METHOD_FUNC(Image_distort), -1);
    rb_define_method(Class_Image, "distortion_channel", RUBY_METHOD_FUNC(Image_distortion_channel), -1);
    rb_define_method(Class_Image, "_dump", RUBY_METHOD_FUNC(Image__dump), 1);
    rb_define_method(Class_Image, "dup", RUBY_METHOD_FUNC(Image_dup), 0);
    rb_define_method(Class_Image, "each_profile", RUBY_METHOD_FUNC(Image_each_profile), 0);
    rb_define_method(Class_Image, "edge", RUBY_METHOD_FUNC(Image_edge), -1);
    rb_define_method(Class_Image, "emboss", RUBY_METHOD_FUNC(Image_emboss), -1);
    rb_define_method(Class_Image, "encipher", RUBY_METHOD_FUNC(Image_encipher), 1);
    rb_define_method(Class_Image, "enhance", RUBY_METHOD_FUNC(Image_enhance), 0);
    rb_define_method(Class_Image, "equalize", RUBY_METHOD_FUNC(Image_equalize), 0);
    rb_define_method(Class_Image, "equalize_channel", RUBY_METHOD_FUNC(Image_equalize_channel), -1);
    rb_define_method(Class_Image, "erase!", RUBY_METHOD_FUNC(Image_erase_bang), 0);
    rb_define_method(Class_Image, "excerpt", RUBY_METHOD_FUNC(Image_excerpt), 4);
    rb_define_method(Class_Image, "excerpt!", RUBY_METHOD_FUNC(Image_excerpt_bang), 4);
    rb_define_method(Class_Image, "export_pixels", RUBY_METHOD_FUNC(Image_export_pixels), -1);
    rb_define_method(Class_Image, "export_pixels_to_str", RUBY_METHOD_FUNC(Image_export_pixels_to_str), -1);
    rb_define_method(Class_Image, "extent", RUBY_METHOD_FUNC(Image_extent), -1);
    rb_define_method(Class_Image, "find_similar_region", RUBY_METHOD_FUNC(Image_find_similar_region), -1);
    rb_define_method(Class_Image, "flip", RUBY_METHOD_FUNC(Image_flip), 0);
    rb_define_method(Class_Image, "flip!", RUBY_METHOD_FUNC(Image_flip_bang), 0);
    rb_define_method(Class_Image, "flop", RUBY_METHOD_FUNC(Image_flop), 0);
    rb_define_method(Class_Image, "flop!", RUBY_METHOD_FUNC(Image_flop_bang), 0);
    rb_define_method(Class_Image, "frame", RUBY_METHOD_FUNC(Image_frame), -1);
    rb_define_method(Class_Image, "function_channel", RUBY_METHOD_FUNC(Image_function_channel), -1);
    rb_define_method(Class_Image, "fx", RUBY_METHOD_FUNC(Image_fx), -1);
    rb_define_method(Class_Image, "gamma_channel", RUBY_METHOD_FUNC(Image_gamma_channel), -1);
    rb_define_method(Class_Image, "gamma_correct", RUBY_METHOD_FUNC(Image_gamma_correct), -1);
    rb_define_method(Class_Image, "gaussian_blur", RUBY_METHOD_FUNC(Image_gaussian_blur), -1);
    rb_define_method(Class_Image, "gaussian_blur_channel", RUBY_METHOD_FUNC(Image_gaussian_blur_channel), -1);
    rb_define_method(Class_Image, "get_pixels", RUBY_METHOD_FUNC(Image_get_pixels), 4);
    rb_define_method(Class_Image, "gray?", RUBY_METHOD_FUNC(Image_gray_q), 0);
    rb_define_method(Class_Image, "grey?", RUBY_METHOD_FUNC(Image_gray_q), 0);
    rb_define_method(Class_Image, "histogram?", RUBY_METHOD_FUNC(Image_histogram_q), 0);
    rb_define_method(Class_Image, "implode", RUBY_METHOD_FUNC(Image_implode), -1);
    rb_define_method(Class_Image, "import_pixels", RUBY_METHOD_FUNC(Image_import_pixels), -1);
    rb_define_method(Class_Image, "initialize_copy", RUBY_METHOD_FUNC(Image_init_copy), 1);
    rb_define_method(Class_Image, "inspect", RUBY_METHOD_FUNC(Image_inspect), 0);
    rb_define_method(Class_Image, "level2", RUBY_METHOD_FUNC(Image_level2), -1);
    rb_define_method(Class_Image, "level_channel", RUBY_METHOD_FUNC(Image_level_channel), -1);
    rb_define_method(Class_Image, "level_colors", RUBY_METHOD_FUNC(Image_level_colors), -1);
    rb_define_method(Class_Image, "levelize_channel", RUBY_METHOD_FUNC(Image_levelize_channel), -1);
    rb_define_method(Class_Image, "linear_stretch", RUBY_METHOD_FUNC(Image_linear_stretch), -1);
    rb_define_method(Class_Image, "liquid_rescale", RUBY_METHOD_FUNC(Image_liquid_rescale), -1);
    rb_define_method(Class_Image, "magnify", RUBY_METHOD_FUNC(Image_magnify), 0);
    rb_define_method(Class_Image, "magnify!", RUBY_METHOD_FUNC(Image_magnify_bang), 0);
    rb_define_method(Class_Image, "marshal_dump", RUBY_METHOD_FUNC(Image_marshal_dump), 0);
    rb_define_method(Class_Image, "marshal_load", RUBY_METHOD_FUNC(Image_marshal_load), 1);
    rb_define_method(Class_Image, "mask", RUBY_METHOD_FUNC(Image_mask), -1);
    rb_define_method(Class_Image, "matte_flood_fill", RUBY_METHOD_FUNC(Image_matte_flood_fill), -1);
    rb_define_method(Class_Image, "median_filter", RUBY_METHOD_FUNC(Image_median_filter), -1);
    rb_define_method(Class_Image, "minify", RUBY_METHOD_FUNC(Image_minify), 0);
    rb_define_method(Class_Image, "minify!", RUBY_METHOD_FUNC(Image_minify_bang), 0);
    rb_define_method(Class_Image, "modulate", RUBY_METHOD_FUNC(Image_modulate), -1);
    rb_define_method(Class_Image, "monochrome?", RUBY_METHOD_FUNC(Image_monochrome_q), 0);
    rb_define_method(Class_Image, "motion_blur", RUBY_METHOD_FUNC(Image_motion_blur), -1);
    rb_define_method(Class_Image, "negate", RUBY_METHOD_FUNC(Image_negate), -1);
    rb_define_method(Class_Image, "negate_channel", RUBY_METHOD_FUNC(Image_negate_channel), -1);
    rb_define_method(Class_Image, "normalize", RUBY_METHOD_FUNC(Image_normalize), 0);
    rb_define_method(Class_Image, "normalize_channel", RUBY_METHOD_FUNC(Image_normalize_channel), -1);
    rb_define_method(Class_Image, "oil_paint", RUBY_METHOD_FUNC(Image_oil_paint), -1);
    rb_define_method(Class_Image, "opaque", RUBY_METHOD_FUNC(Image_opaque), 2);
    rb_define_method(Class_Image, "opaque_channel", RUBY_METHOD_FUNC(Image_opaque_channel), -1);
    rb_define_method(Class_Image, "opaque?", RUBY_METHOD_FUNC(Image_opaque_q), 0);
    rb_define_method(Class_Image, "ordered_dither", RUBY_METHOD_FUNC(Image_ordered_dither), -1);
    rb_define_method(Class_Image, "paint_transparent", RUBY_METHOD_FUNC(Image_paint_transparent), -1);
    rb_define_method(Class_Image, "palette?", RUBY_METHOD_FUNC(Image_palette_q), 0);
    rb_define_method(Class_Image, "pixel_color", RUBY_METHOD_FUNC(Image_pixel_color), -1);
    rb_define_method(Class_Image, "polaroid", RUBY_METHOD_FUNC(Image_polaroid), -1);
    rb_define_method(Class_Image, "posterize", RUBY_METHOD_FUNC(Image_posterize), -1);
//  rb_define_method(Class_Image, "plasma", RUBY_METHOD_FUNC(Image_plasma), 6);
    rb_define_method(Class_Image, "preview", RUBY_METHOD_FUNC(Image_preview), 1);
    rb_define_method(Class_Image, "profile!", RUBY_METHOD_FUNC(Image_profile_bang), 2);
    rb_define_method(Class_Image, "quantize", RUBY_METHOD_FUNC(Image_quantize), -1);
    rb_define_method(Class_Image, "quantum_operator", RUBY_METHOD_FUNC(Image_quantum_operator), -1);
    rb_define_method(Class_Image, "radial_blur", RUBY_METHOD_FUNC(Image_radial_blur), 1);
    rb_define_method(Class_Image, "radial_blur_channel", RUBY_METHOD_FUNC(Image_radial_blur_channel), -1);
    rb_define_method(Class_Image, "raise", RUBY_METHOD_FUNC(Image_raise), -1);
    rb_define_method(Class_Image, "random_threshold_channel", RUBY_METHOD_FUNC(Image_random_threshold_channel), -1);
    rb_define_method(Class_Image, "recolor", RUBY_METHOD_FUNC(Image_recolor), 1);
    rb_define_method(Class_Image, "reduce_noise", RUBY_METHOD_FUNC(Image_reduce_noise), 1);
    rb_define_method(Class_Image, "resample", RUBY_METHOD_FUNC(Image_resample), -1);
    rb_define_method(Class_Image, "resample!", RUBY_METHOD_FUNC(Image_resample_bang), -1);
    rb_define_method(Class_Image, "resize", RUBY_METHOD_FUNC(Image_resize), -1);
    rb_define_method(Class_Image, "resize!", RUBY_METHOD_FUNC(Image_resize_bang), -1);
    rb_define_method(Class_Image, "roll", RUBY_METHOD_FUNC(Image_roll), 2);
    rb_define_method(Class_Image, "rotate", RUBY_METHOD_FUNC(Image_rotate), -1);
    rb_define_method(Class_Image, "rotate!", RUBY_METHOD_FUNC(Image_rotate_bang), -1);
    rb_define_method(Class_Image, "sample", RUBY_METHOD_FUNC(Image_sample), -1);
    rb_define_method(Class_Image, "sample!", RUBY_METHOD_FUNC(Image_sample_bang), -1);
    rb_define_method(Class_Image, "scale", RUBY_METHOD_FUNC(Image_scale), -1);
    rb_define_method(Class_Image, "scale!", RUBY_METHOD_FUNC(Image_scale_bang), -1);
    rb_define_method(Class_Image, "segment", RUBY_METHOD_FUNC(Image_segment), -1);
    rb_define_method(Class_Image, "selective_blur_channel", RUBY_METHOD_FUNC(Image_selective_blur_channel), -1);
    rb_define_method(Class_Image, "separate", RUBY_METHOD_FUNC(Image_separate), -1);
    rb_define_method(Class_Image, "sepiatone", RUBY_METHOD_FUNC(Image_sepiatone), -1);
    rb_define_method(Class_Image, "set_channel_depth", RUBY_METHOD_FUNC(Image_set_channel_depth), 2);
    rb_define_method(Class_Image, "shade", RUBY_METHOD_FUNC(Image_shade), -1);
    rb_define_method(Class_Image, "shadow", RUBY_METHOD_FUNC(Image_shadow), -1);
    rb_define_method(Class_Image, "sharpen", RUBY_METHOD_FUNC(Image_sharpen), -1);
    rb_define_method(Class_Image, "sharpen_channel", RUBY_METHOD_FUNC(Image_sharpen_channel), -1);
    rb_define_method(Class_Image, "shave", RUBY_METHOD_FUNC(Image_shave), 2);
    rb_define_method(Class_Image, "shave!", RUBY_METHOD_FUNC(Image_shave_bang), 2);
    rb_define_method(Class_Image, "shear", RUBY_METHOD_FUNC(Image_shear), 2);
    rb_define_method(Class_Image, "sigmoidal_contrast_channel", RUBY_METHOD_FUNC(Image_sigmoidal_contrast_channel), -1);
    rb_define_method(Class_Image, "signature", RUBY_METHOD_FUNC(Image_signature), 0);
    rb_define_method(Class_Image, "sketch", RUBY_METHOD_FUNC(Image_sketch), -1);
    rb_define_method(Class_Image, "solarize", RUBY_METHOD_FUNC(Image_solarize), -1);
    rb_define_method(Class_Image, "<=>", RUBY_METHOD_FUNC(Image_spaceship), 1);
    rb_define_method(Class_Image, "sparse_color", RUBY_METHOD_FUNC(Image_sparse_color), -1);
    rb_define_method(Class_Image, "splice", RUBY_METHOD_FUNC(Image_splice), -1);
    rb_define_method(Class_Image, "spread", RUBY_METHOD_FUNC(Image_spread), -1);
    rb_define_method(Class_Image, "stegano", RUBY_METHOD_FUNC(Image_stegano), 2);
    rb_define_method(Class_Image, "stereo", RUBY_METHOD_FUNC(Image_stereo), 1);
    rb_define_method(Class_Image, "strip!", RUBY_METHOD_FUNC(Image_strip_bang), 0);
    rb_define_method(Class_Image, "store_pixels", RUBY_METHOD_FUNC(Image_store_pixels), 5);
    rb_define_method(Class_Image, "swirl", RUBY_METHOD_FUNC(Image_swirl), 1);
    rb_define_method(Class_Image, "texture_flood_fill", RUBY_METHOD_FUNC(Image_texture_flood_fill), 5);
    rb_define_method(Class_Image, "threshold", RUBY_METHOD_FUNC(Image_threshold), 1);
    rb_define_method(Class_Image, "thumbnail", RUBY_METHOD_FUNC(Image_thumbnail), -1);
    rb_define_method(Class_Image, "thumbnail!", RUBY_METHOD_FUNC(Image_thumbnail_bang), -1);
    rb_define_method(Class_Image, "tint", RUBY_METHOD_FUNC(Image_tint), -1);
    rb_define_method(Class_Image, "to_color", RUBY_METHOD_FUNC(Image_to_color), 1);
    rb_define_method(Class_Image, "to_blob", RUBY_METHOD_FUNC(Image_to_blob), 0);
    rb_define_method(Class_Image, "transparent", RUBY_METHOD_FUNC(Image_transparent), -1);
    rb_define_method(Class_Image, "transparent_chroma", RUBY_METHOD_FUNC(Image_transparent_chroma), -1);
    rb_define_method(Class_Image, "transpose", RUBY_METHOD_FUNC(Image_transpose), 0);
    rb_define_method(Class_Image, "transpose!", RUBY_METHOD_FUNC(Image_transpose_bang), 0);
    rb_define_method(Class_Image, "transverse", RUBY_METHOD_FUNC(Image_transverse), 0);
    rb_define_method(Class_Image, "transverse!", RUBY_METHOD_FUNC(Image_transverse_bang), 0);
    rb_define_method(Class_Image, "trim", RUBY_METHOD_FUNC(Image_trim), -1);
    rb_define_method(Class_Image, "trim!", RUBY_METHOD_FUNC(Image_trim_bang), -1);
    rb_define_method(Class_Image, "undefine", RUBY_METHOD_FUNC(Image_undefine), 1);
    rb_define_method(Class_Image, "unique_colors", RUBY_METHOD_FUNC(Image_unique_colors), 0);
    rb_define_method(Class_Image, "unsharp_mask", RUBY_METHOD_FUNC(Image_unsharp_mask), -1);
    rb_define_method(Class_Image, "unsharp_mask_channel", RUBY_METHOD_FUNC(Image_unsharp_mask_channel), -1);
    rb_define_method(Class_Image, "vignette", RUBY_METHOD_FUNC(Image_vignette), -1);
    rb_define_method(Class_Image, "watermark", RUBY_METHOD_FUNC(Image_watermark), -1);
    rb_define_method(Class_Image, "wave", RUBY_METHOD_FUNC(Image_wave), -1);
    rb_define_method(Class_Image, "wet_floor", RUBY_METHOD_FUNC(Image_wet_floor), -1);
    rb_define_method(Class_Image, "white_threshold", RUBY_METHOD_FUNC(Image_white_threshold), -1);
    rb_define_method(Class_Image, "write", RUBY_METHOD_FUNC(Image_write), 1);

    /*-----------------------------------------------------------------------*/
    /* Class Magick::ImageList methods                                       */
    /*-----------------------------------------------------------------------*/

    Class_ImageList = rb_define_class_under(Module_Magick, "ImageList", rb_cObject);

    // Define an alias for Object#display before we override it
    rb_define_alias(Class_ImageList, "__display__", "display");
    rb_define_method(Class_ImageList, "remap", RUBY_METHOD_FUNC(ImageList_remap), -1);
    rb_define_method(Class_ImageList, "animate", RUBY_METHOD_FUNC(ImageList_animate), -1);
    rb_define_method(Class_ImageList, "append", RUBY_METHOD_FUNC(ImageList_append), 1);
    rb_define_method(Class_ImageList, "average", RUBY_METHOD_FUNC(ImageList_average), 0);
    rb_define_method(Class_ImageList, "coalesce", RUBY_METHOD_FUNC(ImageList_coalesce), 0);
    rb_define_method(Class_ImageList, "combine", RUBY_METHOD_FUNC(ImageList_combine), -1);
    rb_define_method(Class_ImageList, "composite_layers", RUBY_METHOD_FUNC(ImageList_composite_layers), -1);
    rb_define_method(Class_ImageList, "deconstruct", RUBY_METHOD_FUNC(ImageList_deconstruct), 0);
    rb_define_method(Class_ImageList, "display", RUBY_METHOD_FUNC(ImageList_display), 0);
    rb_define_method(Class_ImageList, "flatten_images", RUBY_METHOD_FUNC(ImageList_flatten_images), 0);
    rb_define_method(Class_ImageList, "montage", RUBY_METHOD_FUNC(ImageList_montage), 0);
    rb_define_method(Class_ImageList, "morph", RUBY_METHOD_FUNC(ImageList_morph), 1);
    rb_define_method(Class_ImageList, "mosaic", RUBY_METHOD_FUNC(ImageList_mosaic), 0);
    rb_define_method(Class_ImageList, "optimize_layers", RUBY_METHOD_FUNC(ImageList_optimize_layers), 1);
    rb_define_method(Class_ImageList, "quantize", RUBY_METHOD_FUNC(ImageList_quantize), -1);
    rb_define_method(Class_ImageList, "to_blob", RUBY_METHOD_FUNC(ImageList_to_blob), 0);
    rb_define_method(Class_ImageList, "write", RUBY_METHOD_FUNC(ImageList_write), 1);

    /*-----------------------------------------------------------------------*/
    /* Class Magick::Draw methods                                            */
    /*-----------------------------------------------------------------------*/

    Class_Draw = rb_define_class_under(Module_Magick, "Draw", rb_cObject);
    rb_define_alloc_func(Class_Draw, Draw_alloc);

    // Define the attributes
    Module_DrawAttribute = rb_define_module_under(Module_Magick, "DrawAttribute");
    rb_define_method(Module_DrawAttribute, "affine=", RUBY_METHOD_FUNC(Draw_affine_eq), 1);
    rb_define_method(Module_DrawAttribute, "align=", RUBY_METHOD_FUNC(Draw_align_eq), 1);
    rb_define_method(Module_DrawAttribute, "decorate=", RUBY_METHOD_FUNC(Draw_decorate_eq), 1);
    rb_define_method(Module_DrawAttribute, "density=", RUBY_METHOD_FUNC(Draw_density_eq), 1);
    rb_define_method(Module_DrawAttribute, "encoding=", RUBY_METHOD_FUNC(Draw_encoding_eq), 1);
    rb_define_method(Module_DrawAttribute, "fill=", RUBY_METHOD_FUNC(Draw_fill_eq), 1);
    rb_define_method(Module_DrawAttribute, "fill_pattern=", RUBY_METHOD_FUNC(Draw_fill_pattern_eq), 1);
    rb_define_method(Module_DrawAttribute, "font=", RUBY_METHOD_FUNC(Draw_font_eq), 1);
    rb_define_method(Module_DrawAttribute, "font_family=", RUBY_METHOD_FUNC(Draw_font_family_eq), 1);
    rb_define_method(Module_DrawAttribute, "font_stretch=", RUBY_METHOD_FUNC(Draw_font_stretch_eq), 1);
    rb_define_method(Module_DrawAttribute, "font_style=", RUBY_METHOD_FUNC(Draw_font_style_eq), 1);
    rb_define_method(Module_DrawAttribute, "font_weight=", RUBY_METHOD_FUNC(Draw_font_weight_eq), 1);
    rb_define_method(Module_DrawAttribute, "gravity=", RUBY_METHOD_FUNC(Draw_gravity_eq), 1);
    rb_define_method(Module_DrawAttribute, "interline_spacing=", RUBY_METHOD_FUNC(Draw_interline_spacing_eq), 1);
    rb_define_method(Module_DrawAttribute, "interword_spacing=", RUBY_METHOD_FUNC(Draw_interword_spacing_eq), 1);
    rb_define_method(Module_DrawAttribute, "kerning=", RUBY_METHOD_FUNC(Draw_kerning_eq), 1);
    rb_define_method(Module_DrawAttribute, "pointsize=", RUBY_METHOD_FUNC(Draw_pointsize_eq), 1);
    rb_define_method(Module_DrawAttribute, "rotation=", RUBY_METHOD_FUNC(Draw_rotation_eq), 1);
    rb_define_method(Module_DrawAttribute, "stroke=", RUBY_METHOD_FUNC(Draw_stroke_eq), 1);
    rb_define_method(Module_DrawAttribute, "stroke_pattern=", RUBY_METHOD_FUNC(Draw_stroke_pattern_eq), 1);
    rb_define_method(Module_DrawAttribute, "stroke_width=", RUBY_METHOD_FUNC(Draw_stroke_width_eq), 1);
    rb_define_method(Module_DrawAttribute, "text_antialias=", RUBY_METHOD_FUNC(Draw_text_antialias_eq), 1);
    rb_define_method(Module_DrawAttribute, "tile=", RUBY_METHOD_FUNC(Draw_tile_eq), 1);
    rb_define_method(Module_DrawAttribute, "undercolor=", RUBY_METHOD_FUNC(Draw_undercolor_eq), 1);

    rb_include_module(Class_Draw, Module_DrawAttribute);

    rb_define_method(Class_Draw, "annotate", RUBY_METHOD_FUNC(Draw_annotate), 6);
    rb_define_method(Class_Draw, "clone", RUBY_METHOD_FUNC(Draw_clone), 0);
    rb_define_method(Class_Draw, "composite", RUBY_METHOD_FUNC(Draw_composite), -1);
    rb_define_method(Class_Draw, "draw", RUBY_METHOD_FUNC(Draw_draw), 1);
    rb_define_method(Class_Draw, "dup", RUBY_METHOD_FUNC(Draw_dup), 0);
    rb_define_method(Class_Draw, "get_type_metrics", RUBY_METHOD_FUNC(Draw_get_type_metrics), -1);
    rb_define_method(Class_Draw, "get_multiline_type_metrics", RUBY_METHOD_FUNC(Draw_get_multiline_type_metrics), -1);
    rb_define_method(Class_Draw, "initialize", RUBY_METHOD_FUNC(Draw_initialize), 0);
    rb_define_method(Class_Draw, "initialize_copy", RUBY_METHOD_FUNC(Draw_init_copy), 1);
    rb_define_method(Class_Draw, "inspect", RUBY_METHOD_FUNC(Draw_inspect), 0);
    rb_define_method(Class_Draw, "marshal_dump", RUBY_METHOD_FUNC(Draw_marshal_dump), 0);
    rb_define_method(Class_Draw, "marshal_load", RUBY_METHOD_FUNC(Draw_marshal_load), 1);
    rb_define_method(Class_Draw, "primitive", RUBY_METHOD_FUNC(Draw_primitive), 1);

    /*-----------------------------------------------------------------------*/
    /* Class Magick::DrawOptions is identical to Magick::Draw but with       */
    /* only the attribute writer methods. This is the object that is passed  */
    /* to the block associated with the Draw.new method call.                */
    /*-----------------------------------------------------------------------*/

    Class_DrawOptions = rb_define_class_under(Class_Image, "DrawOptions", rb_cObject);

    rb_define_alloc_func(Class_DrawOptions, DrawOptions_alloc);

    rb_define_method(Class_DrawOptions, "initialize", RUBY_METHOD_FUNC(DrawOptions_initialize), 0);

    rb_include_module(Class_DrawOptions, Module_DrawAttribute);


    /*-----------------------------------------------------------------------*/
    /* Class Magick::Pixel                                                   */
    /*-----------------------------------------------------------------------*/

    Class_Pixel = rb_define_class_under(Module_Magick, "Pixel", rb_cObject);

    // include Comparable
    rb_include_module(Class_Pixel, rb_mComparable);

    // Magick::Pixel has 3 constructors: "new" "from_color", "from_hsla"
    rb_define_alloc_func(Class_Pixel, Pixel_alloc);
    rb_define_singleton_method(Class_Pixel, "from_color", RUBY_METHOD_FUNC(Pixel_from_color), 1);
    rb_define_singleton_method(Class_Pixel, "from_hsla", RUBY_METHOD_FUNC(Pixel_from_hsla), -1);

    // Define the RGBA attributes
    rb_define_method(Class_Pixel, "red", RUBY_METHOD_FUNC(Pixel_red), 0);
    rb_define_method(Class_Pixel, "red=", RUBY_METHOD_FUNC(Pixel_red_eq), 1);
    rb_define_method(Class_Pixel, "green", RUBY_METHOD_FUNC(Pixel_green), 0);
    rb_define_method(Class_Pixel, "green=", RUBY_METHOD_FUNC(Pixel_green_eq), 1);
    rb_define_method(Class_Pixel, "blue", RUBY_METHOD_FUNC(Pixel_blue), 0);
    rb_define_method(Class_Pixel, "blue=", RUBY_METHOD_FUNC(Pixel_blue_eq), 1);
    rb_define_method(Class_Pixel, "alpha", RUBY_METHOD_FUNC(Pixel_alpha), 0);
    rb_define_method(Class_Pixel, "alpha=", RUBY_METHOD_FUNC(Pixel_alpha_eq), 1);

    // Define the CMYK attributes
    rb_define_method(Class_Pixel, "cyan", RUBY_METHOD_FUNC(Pixel_cyan), 0);
    rb_define_method(Class_Pixel, "cyan=", RUBY_METHOD_FUNC(Pixel_cyan_eq), 1);
    rb_define_method(Class_Pixel, "magenta", RUBY_METHOD_FUNC(Pixel_magenta), 0);
    rb_define_method(Class_Pixel, "magenta=", RUBY_METHOD_FUNC(Pixel_magenta_eq), 1);
    rb_define_method(Class_Pixel, "yellow", RUBY_METHOD_FUNC(Pixel_yellow), 0);
    rb_define_method(Class_Pixel, "yellow=", RUBY_METHOD_FUNC(Pixel_yellow_eq), 1);
    rb_define_method(Class_Pixel, "black", RUBY_METHOD_FUNC(Pixel_black), 0);
    rb_define_method(Class_Pixel, "black=", RUBY_METHOD_FUNC(Pixel_black_eq), 1);


    // Define the instance methods
    rb_define_method(Class_Pixel, "<=>", RUBY_METHOD_FUNC(Pixel_spaceship), 1);
    rb_define_method(Class_Pixel, "===", RUBY_METHOD_FUNC(Pixel_case_eq), 1);
    rb_define_method(Class_Pixel, "eql?", RUBY_METHOD_FUNC(Pixel_eql_q), 1);
    rb_define_method(Class_Pixel, "initialize", RUBY_METHOD_FUNC(Pixel_initialize), -1);
    rb_define_method(Class_Pixel, "initialize_copy", RUBY_METHOD_FUNC(Pixel_init_copy), 1);
    rb_define_method(Class_Pixel, "clone", RUBY_METHOD_FUNC(Pixel_clone), 0);
    rb_define_method(Class_Pixel, "dup", RUBY_METHOD_FUNC(Pixel_dup), 0);
    rb_define_method(Class_Pixel, "fcmp", RUBY_METHOD_FUNC(Pixel_fcmp), -1);
    rb_define_method(Class_Pixel, "hash", RUBY_METHOD_FUNC(Pixel_hash), 0);
    rb_define_method(Class_Pixel, "intensity", RUBY_METHOD_FUNC(Pixel_intensity), 0);
    rb_define_method(Class_Pixel, "marshal_dump", RUBY_METHOD_FUNC(Pixel_marshal_dump), 0);
    rb_define_method(Class_Pixel, "marshal_load", RUBY_METHOD_FUNC(Pixel_marshal_load), 1);
    rb_define_method(Class_Pixel, "to_color", RUBY_METHOD_FUNC(Pixel_to_color), -1);
    rb_define_method(Class_Pixel, "to_hsla", RUBY_METHOD_FUNC(Pixel_to_hsla), 0);
    rb_define_method(Class_Pixel, "to_s", RUBY_METHOD_FUNC(Pixel_to_s), 0);

    /*-----------------------------------------------------------------------*/
    /* Class Magick::ImageList::Montage methods                              */
    /*-----------------------------------------------------------------------*/

    Class_Montage = rb_define_class_under(Class_ImageList, "Montage", rb_cObject);

    rb_define_alloc_func(Class_Montage, Montage_alloc);

    rb_define_method(Class_Montage, "initialize", RUBY_METHOD_FUNC(Montage_initialize), 0);
    rb_define_method(Class_Montage, "freeze", RUBY_METHOD_FUNC(rm_no_freeze), 0);

    // These accessors supply optional arguments for Magick::ImageList::Montage.new
    rb_define_method(Class_Montage, "background_color=", RUBY_METHOD_FUNC(Montage_background_color_eq), 1);
    rb_define_method(Class_Montage, "border_color=", RUBY_METHOD_FUNC(Montage_border_color_eq), 1);
    rb_define_method(Class_Montage, "border_width=", RUBY_METHOD_FUNC(Montage_border_width_eq), 1);
    rb_define_method(Class_Montage, "compose=", RUBY_METHOD_FUNC(Montage_compose_eq), 1);
    rb_define_method(Class_Montage, "filename=", RUBY_METHOD_FUNC(Montage_filename_eq), 1);
    rb_define_method(Class_Montage, "fill=", RUBY_METHOD_FUNC(Montage_fill_eq), 1);
    rb_define_method(Class_Montage, "font=", RUBY_METHOD_FUNC(Montage_font_eq), 1);
    rb_define_method(Class_Montage, "frame=", RUBY_METHOD_FUNC(Montage_frame_eq), 1);
    rb_define_method(Class_Montage, "geometry=", RUBY_METHOD_FUNC(Montage_geometry_eq), 1);
    rb_define_method(Class_Montage, "gravity=", RUBY_METHOD_FUNC(Montage_gravity_eq), 1);
    rb_define_method(Class_Montage, "matte_color=", RUBY_METHOD_FUNC(Montage_matte_color_eq), 1);
    rb_define_method(Class_Montage, "pointsize=", RUBY_METHOD_FUNC(Montage_pointsize_eq), 1);
    rb_define_method(Class_Montage, "shadow=", RUBY_METHOD_FUNC(Montage_shadow_eq), 1);
    rb_define_method(Class_Montage, "stroke=", RUBY_METHOD_FUNC(Montage_stroke_eq), 1);
    rb_define_method(Class_Montage, "texture=", RUBY_METHOD_FUNC(Montage_texture_eq), 1);
    rb_define_method(Class_Montage, "tile=", RUBY_METHOD_FUNC(Montage_tile_eq), 1);
    rb_define_method(Class_Montage, "title=", RUBY_METHOD_FUNC(Montage_title_eq), 1);

    /*-----------------------------------------------------------------------*/
    /* Class Magick::Image::Info                                             */
    /*-----------------------------------------------------------------------*/

    Class_Info = rb_define_class_under(Class_Image, "Info", rb_cObject);

    rb_define_alloc_func(Class_Info, Info_alloc);

    rb_define_method(Class_Info, "initialize", RUBY_METHOD_FUNC(Info_initialize), 0);
    rb_define_method(Class_Info, "channel", RUBY_METHOD_FUNC(Info_channel), -1);
    rb_define_method(Class_Info, "freeze", RUBY_METHOD_FUNC(rm_no_freeze), 0);
    rb_define_method(Class_Info, "define", RUBY_METHOD_FUNC(Info_define), -1);
    rb_define_method(Class_Info, "[]=", RUBY_METHOD_FUNC(Info_aset), -1);
    rb_define_method(Class_Info, "[]", RUBY_METHOD_FUNC(Info_aref), -1);
    rb_define_method(Class_Info, "undefine", RUBY_METHOD_FUNC(Info_undefine), 2);

    // Define the attributes
    rb_define_method(Class_Info, "antialias", RUBY_METHOD_FUNC(Info_antialias), 0);
    rb_define_method(Class_Info, "antialias=", RUBY_METHOD_FUNC(Info_antialias_eq), 1);
    rb_define_method(Class_Info, "attenuate", RUBY_METHOD_FUNC(Info_attenuate), 0);
    rb_define_method(Class_Info, "attenuate=", RUBY_METHOD_FUNC(Info_attenuate_eq), 1);
    rb_define_method(Class_Info, "authenticate", RUBY_METHOD_FUNC(Info_authenticate), 0);
    rb_define_method(Class_Info, "authenticate=", RUBY_METHOD_FUNC(Info_authenticate_eq), 1);
    rb_define_method(Class_Info, "background_color", RUBY_METHOD_FUNC(Info_background_color), 0);
    rb_define_method(Class_Info, "background_color=", RUBY_METHOD_FUNC(Info_background_color_eq), 1);
    rb_define_method(Class_Info, "border_color", RUBY_METHOD_FUNC(Info_border_color), 0);
    rb_define_method(Class_Info, "border_color=", RUBY_METHOD_FUNC(Info_border_color_eq), 1);
    rb_define_method(Class_Info, "caption", RUBY_METHOD_FUNC(Info_caption), 0);
    rb_define_method(Class_Info, "caption=", RUBY_METHOD_FUNC(Info_caption_eq), 1);
    rb_define_method(Class_Info, "colorspace", RUBY_METHOD_FUNC(Info_colorspace), 0);
    rb_define_method(Class_Info, "colorspace=", RUBY_METHOD_FUNC(Info_colorspace_eq), 1);
    rb_define_method(Class_Info, "comment", RUBY_METHOD_FUNC(Info_comment), 0);
    rb_define_method(Class_Info, "comment=", RUBY_METHOD_FUNC(Info_comment_eq), 1);
    rb_define_method(Class_Info, "compression", RUBY_METHOD_FUNC(Info_compression), 0);
    rb_define_method(Class_Info, "compression=", RUBY_METHOD_FUNC(Info_compression_eq), 1);
    rb_define_method(Class_Info, "delay", RUBY_METHOD_FUNC(Info_delay), 0);
    rb_define_method(Class_Info, "delay=", RUBY_METHOD_FUNC(Info_delay_eq), 1);
    rb_define_method(Class_Info, "density", RUBY_METHOD_FUNC(Info_density), 0);
    rb_define_method(Class_Info, "density=", RUBY_METHOD_FUNC(Info_density_eq), 1);
    rb_define_method(Class_Info, "depth", RUBY_METHOD_FUNC(Info_depth), 0);
    rb_define_method(Class_Info, "depth=", RUBY_METHOD_FUNC(Info_depth_eq), 1);
    rb_define_method(Class_Info, "dispose", RUBY_METHOD_FUNC(Info_dispose), 0);
    rb_define_method(Class_Info, "dispose=", RUBY_METHOD_FUNC(Info_dispose_eq), 1);
    rb_define_method(Class_Info, "dither", RUBY_METHOD_FUNC(Info_dither), 0);
    rb_define_method(Class_Info, "dither=", RUBY_METHOD_FUNC(Info_dither_eq), 1);
    rb_define_method(Class_Info, "endian", RUBY_METHOD_FUNC(Info_endian), 0);
    rb_define_method(Class_Info, "endian=", RUBY_METHOD_FUNC(Info_endian_eq), 1);
    rb_define_method(Class_Info, "extract", RUBY_METHOD_FUNC(Info_extract), 0);
    rb_define_method(Class_Info, "extract=", RUBY_METHOD_FUNC(Info_extract_eq), 1);
    rb_define_method(Class_Info, "filename", RUBY_METHOD_FUNC(Info_filename), 0);
    rb_define_method(Class_Info, "filename=", RUBY_METHOD_FUNC(Info_filename_eq), 1);
    rb_define_method(Class_Info, "fill", RUBY_METHOD_FUNC(Info_fill), 0);
    rb_define_method(Class_Info, "fill=", RUBY_METHOD_FUNC(Info_fill_eq), 1);
    rb_define_method(Class_Info, "font", RUBY_METHOD_FUNC(Info_font), 0);
    rb_define_method(Class_Info, "font=", RUBY_METHOD_FUNC(Info_font_eq), 1);
    rb_define_method(Class_Info, "format", RUBY_METHOD_FUNC(Info_format), 0);
    rb_define_method(Class_Info, "format=", RUBY_METHOD_FUNC(Info_format_eq), 1);
    rb_define_method(Class_Info, "fuzz", RUBY_METHOD_FUNC(Info_fuzz), 0);
    rb_define_method(Class_Info, "fuzz=", RUBY_METHOD_FUNC(Info_fuzz_eq), 1);
    rb_define_method(Class_Info, "gravity", RUBY_METHOD_FUNC(Info_gravity), 0);
    rb_define_method(Class_Info, "gravity=", RUBY_METHOD_FUNC(Info_gravity_eq), 1);
    rb_define_method(Class_Info, "image_type", RUBY_METHOD_FUNC(Info_image_type), 0);
    rb_define_method(Class_Info, "image_type=", RUBY_METHOD_FUNC(Info_image_type_eq), 1);
    rb_define_method(Class_Info, "interlace", RUBY_METHOD_FUNC(Info_interlace), 0);
    rb_define_method(Class_Info, "interlace=", RUBY_METHOD_FUNC(Info_interlace_eq), 1);
    rb_define_method(Class_Info, "label", RUBY_METHOD_FUNC(Info_label), 0);
    rb_define_method(Class_Info, "label=", RUBY_METHOD_FUNC(Info_label_eq), 1);
    rb_define_method(Class_Info, "matte_color", RUBY_METHOD_FUNC(Info_matte_color), 0);
    rb_define_method(Class_Info, "matte_color=", RUBY_METHOD_FUNC(Info_matte_color_eq), 1);
    rb_define_method(Class_Info, "monochrome", RUBY_METHOD_FUNC(Info_monochrome), 0);
    rb_define_method(Class_Info, "monochrome=", RUBY_METHOD_FUNC(Info_monochrome_eq), 1);
    rb_define_method(Class_Info, "number_scenes", RUBY_METHOD_FUNC(Info_number_scenes), 0);
    rb_define_method(Class_Info, "number_scenes=", RUBY_METHOD_FUNC(Info_number_scenes_eq), 1);
    rb_define_method(Class_Info, "orientation", RUBY_METHOD_FUNC(Info_orientation), 0);
    rb_define_method(Class_Info, "orientation=", RUBY_METHOD_FUNC(Info_orientation_eq), 1);
    rb_define_method(Class_Info, "origin", RUBY_METHOD_FUNC(Info_origin), 0);         // new in 6.3.1
    rb_define_method(Class_Info, "origin=", RUBY_METHOD_FUNC(Info_origin_eq), 1);         // new in 6.3.1
    rb_define_method(Class_Info, "page", RUBY_METHOD_FUNC(Info_page), 0);
    rb_define_method(Class_Info, "page=", RUBY_METHOD_FUNC(Info_page_eq), 1);
    rb_define_method(Class_Info, "pointsize", RUBY_METHOD_FUNC(Info_pointsize), 0);
    rb_define_method(Class_Info, "pointsize=", RUBY_METHOD_FUNC(Info_pointsize_eq), 1);
    rb_define_method(Class_Info, "quality", RUBY_METHOD_FUNC(Info_quality), 0);
    rb_define_method(Class_Info, "quality=", RUBY_METHOD_FUNC(Info_quality_eq), 1);
    rb_define_method(Class_Info, "sampling_factor", RUBY_METHOD_FUNC(Info_sampling_factor), 0);
    rb_define_method(Class_Info, "sampling_factor=", RUBY_METHOD_FUNC(Info_sampling_factor_eq), 1);
    rb_define_method(Class_Info, "scene", RUBY_METHOD_FUNC(Info_scene), 0);
    rb_define_method(Class_Info, "scene=", RUBY_METHOD_FUNC(Info_scene_eq), 1);
    rb_define_method(Class_Info, "server_name", RUBY_METHOD_FUNC(Info_server_name), 0);
    rb_define_method(Class_Info, "server_name=", RUBY_METHOD_FUNC(Info_server_name_eq), 1);
    rb_define_method(Class_Info, "size", RUBY_METHOD_FUNC(Info_size), 0);
    rb_define_method(Class_Info, "size=", RUBY_METHOD_FUNC(Info_size_eq), 1);
    rb_define_method(Class_Info, "stroke", RUBY_METHOD_FUNC(Info_stroke), 0);
    rb_define_method(Class_Info, "stroke=", RUBY_METHOD_FUNC(Info_stroke_eq), 1);
    rb_define_method(Class_Info, "stroke_width", RUBY_METHOD_FUNC(Info_stroke_width), 0);
    rb_define_method(Class_Info, "stroke_width=", RUBY_METHOD_FUNC(Info_stroke_width_eq), 1);
    rb_define_method(Class_Info, "texture=", RUBY_METHOD_FUNC(Info_texture_eq), 1);
    rb_define_method(Class_Info, "tile_offset", RUBY_METHOD_FUNC(Info_tile_offset), 0);
    rb_define_method(Class_Info, "tile_offset=", RUBY_METHOD_FUNC(Info_tile_offset_eq), 1);
    rb_define_method(Class_Info, "transparent_color", RUBY_METHOD_FUNC(Info_transparent_color), 0);
    rb_define_method(Class_Info, "transparent_color=", RUBY_METHOD_FUNC(Info_transparent_color_eq), 1);
    rb_define_method(Class_Info, "undercolor", RUBY_METHOD_FUNC(Info_undercolor), 0);
    rb_define_method(Class_Info, "undercolor=", RUBY_METHOD_FUNC(Info_undercolor_eq), 1);
    rb_define_method(Class_Info, "units", RUBY_METHOD_FUNC(Info_units), 0);
    rb_define_method(Class_Info, "units=", RUBY_METHOD_FUNC(Info_units_eq), 1);
    rb_define_method(Class_Info, "view", RUBY_METHOD_FUNC(Info_view), 0);
    rb_define_method(Class_Info, "view=", RUBY_METHOD_FUNC(Info_view_eq), 1);

    /*-----------------------------------------------------------------------*/
    /* Class Magick::KernelInfo                                              */
    /*-----------------------------------------------------------------------*/

    Class_KernelInfo = rb_define_class_under(Module_Magick, "KernelInfo", rb_cObject);

    rb_define_alloc_func(Class_KernelInfo, KernelInfo_alloc);

    rb_define_method(Class_KernelInfo, "initialize", RUBY_METHOD_FUNC(KernelInfo_initialize), 1);
    rb_define_method(Class_KernelInfo, "unity_add", RUBY_METHOD_FUNC(KernelInfo_unity_add), 1);
    rb_define_method(Class_KernelInfo, "scale", RUBY_METHOD_FUNC(KernelInfo_scale), 2);
    rb_define_method(Class_KernelInfo, "scale_geometry", RUBY_METHOD_FUNC(KernelInfo_scale_geometry), 1);
    rb_define_method(Class_KernelInfo, "clone", RUBY_METHOD_FUNC(KernelInfo_clone), 0);
    rb_define_method(Class_KernelInfo, "dup", RUBY_METHOD_FUNC(KernelInfo_clone), 0);

    rb_define_singleton_method(Class_KernelInfo, "builtin", RUBY_METHOD_FUNC(KernelInfo_builtin), 2);


    /*-----------------------------------------------------------------------*/
    /* Class Magick::Image::PolaroidOptions                                  */
    /*-----------------------------------------------------------------------*/

    Class_PolaroidOptions = rb_define_class_under(Class_Image, "PolaroidOptions", rb_cObject);

    rb_define_alloc_func(Class_PolaroidOptions, PolaroidOptions_alloc);

    rb_define_method(Class_PolaroidOptions, "initialize", RUBY_METHOD_FUNC(PolaroidOptions_initialize), 0);

    // Define the attributes
    rb_define_method(Class_PolaroidOptions, "shadow_color=", RUBY_METHOD_FUNC(PolaroidOptions_shadow_color_eq), 1);
    rb_define_method(Class_PolaroidOptions, "border_color=", RUBY_METHOD_FUNC(PolaroidOptions_border_color_eq), 1);

    // The other attribute writer methods are implemented by Draw's functions
    rb_include_module(Class_PolaroidOptions, Module_DrawAttribute);

    /*-----------------------------------------------------------------------*/
    /* Magick::******Fill classes and methods                                */
    /*-----------------------------------------------------------------------*/

    // class Magick::GradientFill
    Class_GradientFill = rb_define_class_under(Module_Magick, "GradientFill", rb_cObject);

    rb_define_alloc_func(Class_GradientFill, GradientFill_alloc);

    rb_define_method(Class_GradientFill, "initialize", RUBY_METHOD_FUNC(GradientFill_initialize), 6);
    rb_define_method(Class_GradientFill, "fill", RUBY_METHOD_FUNC(GradientFill_fill), 1);

    // class Magick::TextureFill
    Class_TextureFill = rb_define_class_under(Module_Magick, "TextureFill", rb_cObject);

    rb_define_alloc_func(Class_TextureFill, TextureFill_alloc);

    rb_define_method(Class_TextureFill, "initialize", RUBY_METHOD_FUNC(TextureFill_initialize), 1);
    rb_define_method(Class_TextureFill, "fill", RUBY_METHOD_FUNC(TextureFill_fill), 1);

    /*-----------------------------------------------------------------------*/
    /* Class Magick::ImageMagickError < StandardError                        */
    /* Class Magick::FatalImageMagickError < StandardError                   */
    /*-----------------------------------------------------------------------*/

    Class_ImageMagickError = rb_define_class_under(Module_Magick, "ImageMagickError", rb_eStandardError);
    rb_define_method(Class_ImageMagickError, "initialize", RUBY_METHOD_FUNC(ImageMagickError_initialize), -1);
    rb_define_attr(Class_ImageMagickError, MAGICK_LOC, True, False);

    Class_FatalImageMagickError = rb_define_class_under(Module_Magick, "FatalImageMagickError", rb_eStandardError);


    /*-----------------------------------------------------------------------*/
    /* Class Magick::DestroyedImageError < StandardError                     */
    /*-----------------------------------------------------------------------*/
    Class_DestroyedImageError = rb_define_class_under(Module_Magick, "DestroyedImageError", rb_eStandardError);


    // Miscellaneous fixed-point constants
    DEF_CONST(QuantumRange);
    DEF_CONST(MAGICKCORE_QUANTUM_DEPTH);
    DEF_CONSTV(OpaqueAlpha, QuantumRange);
    DEF_CONSTV(TransparentAlpha, 0);

    version_constants();
    features_constant();

    /*-----------------------------------------------------------------------*/
    /* Class Magick::Enum                                                    */
    /*-----------------------------------------------------------------------*/

    // includes Comparable
    Class_Enum = rb_define_class_under(Module_Magick, "Enum", rb_cObject);
    rb_include_module(Class_Enum, rb_mComparable);

    rb_define_alloc_func(Class_Enum, Enum_alloc);

    rb_define_method(Class_Enum, "initialize", RUBY_METHOD_FUNC(Enum_initialize), 2);
    rb_define_method(Class_Enum, "to_s", RUBY_METHOD_FUNC(Enum_to_s), 0);
    rb_define_method(Class_Enum, "to_i", RUBY_METHOD_FUNC(Enum_to_i), 0);
    rb_define_method(Class_Enum, "<=>", RUBY_METHOD_FUNC(Enum_spaceship), 1);
    rb_define_method(Class_Enum, "===", RUBY_METHOD_FUNC(Enum_case_eq), 1);
    rb_define_method(Class_Enum, "|", RUBY_METHOD_FUNC(Enum_bitwise_or), 1);

    // AlignType constants
    DEF_ENUM(AlignType)
        ENUMERATOR(UndefinedAlign)
        ENUMERATOR(LeftAlign)
        ENUMERATOR(CenterAlign)
        ENUMERATOR(RightAlign)
    END_ENUM

    // AlphaChannelOption constants
    DEF_ENUM(AlphaChannelOption)
        ENUMERATOR(UndefinedAlphaChannel)
        ENUMERATOR(ActivateAlphaChannel)
        ENUMERATOR(DeactivateAlphaChannel)
        ENUMERATOR(SetAlphaChannel)
        ENUMERATOR(RemoveAlphaChannel)
        ENUMERATOR(CopyAlphaChannel)
        ENUMERATOR(ExtractAlphaChannel)
        ENUMERATOR(OpaqueAlphaChannel)
        ENUMERATOR(ShapeAlphaChannel)
        ENUMERATOR(TransparentAlphaChannel)
        ENUMERATOR(BackgroundAlphaChannel)
        ENUMERATOR(AssociateAlphaChannel)
        ENUMERATOR(DisassociateAlphaChannel)
#if defined(IMAGEMAGICK_7)
        ENUMERATOR(OnAlphaChannel)
        ENUMERATOR(OffAlphaChannel)
#else
        ENUMERATORV(OnAlphaChannel, ActivateAlphaChannel)
        ENUMERATORV(OffAlphaChannel, DeactivateAlphaChannel)
#endif
    END_ENUM

    // AnchorType constants (for Draw#text_anchor - these are not defined by ImageMagick)
    DEF_ENUM(AnchorType)
        ENUMERATOR(StartAnchor)
        ENUMERATOR(MiddleAnchor)
        ENUMERATOR(EndAnchor)
    END_ENUM

    // ChannelType constants
    DEF_ENUM(ChannelType)
        ENUMERATOR(UndefinedChannel)
        ENUMERATOR(RedChannel)
        ENUMERATOR(CyanChannel)
        ENUMERATOR(GreenChannel)
        ENUMERATOR(MagentaChannel)
        ENUMERATOR(BlueChannel)
        ENUMERATOR(YellowChannel)
        ENUMERATOR(OpacityChannel)
        ENUMERATOR(BlackChannel)
        ENUMERATOR(IndexChannel)
        ENUMERATOR(GrayChannel)
        ENUMERATOR(CompositeChannels)
        ENUMERATOR(AllChannels)
        ENUMERATOR(TrueAlphaChannel)
        ENUMERATOR(RGBChannels)
        ENUMERATOR(GrayChannels)
        ENUMERATOR(SyncChannels)
        ENUMERATORV(AlphaChannel, OpacityChannel)
        ENUMERATORV(DefaultChannels, 0xff & ~OpacityChannel)
        ENUMERATORV(HueChannel, RedChannel)
        ENUMERATORV(LuminosityChannel, BlueChannel)
        ENUMERATORV(SaturationChannel, GreenChannel)
    END_ENUM

    // ClassType constants
    DEF_ENUM(ClassType)
        ENUMERATOR(UndefinedClass)
        ENUMERATOR(PseudoClass)
        ENUMERATOR(DirectClass)
    END_ENUM

    // ColorspaceType constants
    DEF_ENUM(ColorspaceType)
        ENUMERATOR(UndefinedColorspace)
        ENUMERATOR(RGBColorspace)
        ENUMERATOR(GRAYColorspace)
        ENUMERATOR(TransparentColorspace)
        ENUMERATOR(OHTAColorspace)
        ENUMERATOR(XYZColorspace)
        ENUMERATOR(YCbCrColorspace)
        ENUMERATOR(YCCColorspace)
        ENUMERATOR(YIQColorspace)
        ENUMERATOR(YPbPrColorspace)
        ENUMERATOR(YUVColorspace)
        ENUMERATOR(CMYKColorspace)
        ENUMERATORV(SRGBColorspace, sRGBColorspace)
        ENUMERATOR(HSLColorspace)
        ENUMERATOR(HWBColorspace)
        ENUMERATOR(HSBColorspace)
        ENUMERATOR(LabColorspace)
        ENUMERATOR(Rec601YCbCrColorspace)
        ENUMERATOR(Rec709YCbCrColorspace)
        ENUMERATOR(LogColorspace)
        ENUMERATOR(CMYColorspace)
        ENUMERATOR(LuvColorspace)
        ENUMERATOR(HCLColorspace)
        ENUMERATOR(LCHColorspace)
        ENUMERATOR(LMSColorspace)
        ENUMERATOR(LCHabColorspace)
        ENUMERATOR(LCHuvColorspace)
        ENUMERATORV(ScRGBColorspace, scRGBColorspace)
        ENUMERATOR(HSIColorspace)
        ENUMERATOR(HSVColorspace)
        ENUMERATOR(HCLpColorspace)
        ENUMERATOR(YDbDrColorspace)
        ENUMERATORV(XyYColorspace, xyYColorspace)
#if defined(IMAGEMAGICK_7)
#if defined(IMAGEMAGICK_GREATER_THAN_EQUAL_7_0_8)
        ENUMERATOR(LinearGRAYColorspace)
#endif
#if defined(IMAGEMAGICK_GREATER_THAN_EQUAL_7_0_10)
        ENUMERATOR(JzazbzColorspace)
#endif
#elif defined(IMAGEMAGICK_GREATER_THAN_EQUAL_6_9_10)
        ENUMERATOR(LinearGRAYColorspace)
#endif
    END_ENUM

    // ComplianceType constants are defined as enums but used as bit flags
    DEF_ENUM(ComplianceType)
        ENUMERATOR(UndefinedCompliance)
        // AllCompliance is 0xffff, not too useful for us!
        ENUMERATORV(AllCompliance, SVGCompliance|X11Compliance|XPMCompliance)
        ENUMERATOR(NoCompliance)
        ENUMERATOR(SVGCompliance)
        ENUMERATOR(X11Compliance)
        ENUMERATOR(XPMCompliance)
    END_ENUM

    // CompositeOperator constants
    DEF_ENUM(CompositeOperator)
        ENUMERATOR(AtopCompositeOp)
        ENUMERATOR(BlendCompositeOp)
        ENUMERATOR(BlurCompositeOp)
        ENUMERATOR(BumpmapCompositeOp)
        ENUMERATOR(ChangeMaskCompositeOp)
        ENUMERATOR(ClearCompositeOp)
        ENUMERATOR(ColorBurnCompositeOp)
        ENUMERATOR(ColorDodgeCompositeOp)
        ENUMERATOR(ColorizeCompositeOp)
        ENUMERATOR(CopyBlackCompositeOp)
        ENUMERATOR(CopyBlueCompositeOp)
        ENUMERATOR(CopyCompositeOp)
        ENUMERATOR(CopyCyanCompositeOp)
        ENUMERATOR(CopyGreenCompositeOp)
        ENUMERATOR(CopyMagentaCompositeOp)
        ENUMERATOR(CopyRedCompositeOp)
        ENUMERATOR(CopyYellowCompositeOp)
        ENUMERATOR(DarkenCompositeOp)
        ENUMERATOR(DarkenIntensityCompositeOp)
        ENUMERATOR(DistortCompositeOp)
        ENUMERATOR(DivideDstCompositeOp)
        ENUMERATOR(DivideSrcCompositeOp)
        ENUMERATOR(DstAtopCompositeOp)
        ENUMERATOR(DstCompositeOp)
        ENUMERATOR(DstInCompositeOp)
        ENUMERATOR(DstOutCompositeOp)
        ENUMERATOR(DstOverCompositeOp)
        ENUMERATOR(DifferenceCompositeOp)
        ENUMERATOR(DisplaceCompositeOp)
        ENUMERATOR(DissolveCompositeOp)
        ENUMERATOR(ExclusionCompositeOp)
        ENUMERATOR(HardLightCompositeOp)
        ENUMERATOR(HueCompositeOp)
        ENUMERATOR(InCompositeOp)
        ENUMERATOR(LightenCompositeOp)
        ENUMERATOR(LightenIntensityCompositeOp)
        ENUMERATOR(LinearBurnCompositeOp)
        ENUMERATOR(LinearDodgeCompositeOp)
        ENUMERATOR(LinearLightCompositeOp)
        ENUMERATOR(LuminizeCompositeOp)
        ENUMERATOR(MathematicsCompositeOp)
        ENUMERATOR(MinusDstCompositeOp)
        ENUMERATOR(MinusSrcCompositeOp)
        ENUMERATOR(ModulateCompositeOp)
        ENUMERATOR(ModulusAddCompositeOp)
        ENUMERATOR(ModulusSubtractCompositeOp)
        ENUMERATOR(MultiplyCompositeOp)
        ENUMERATOR(NoCompositeOp)
        ENUMERATOR(OutCompositeOp)
        ENUMERATOR(OverCompositeOp)
        ENUMERATOR(OverlayCompositeOp)
        ENUMERATOR(PegtopLightCompositeOp)
        ENUMERATOR(PinLightCompositeOp)
        ENUMERATOR(PlusCompositeOp)
        ENUMERATOR(ReplaceCompositeOp)    // synonym for CopyCompositeOp
        ENUMERATOR(SaturateCompositeOp)
        ENUMERATOR(ScreenCompositeOp)
        ENUMERATOR(SoftLightCompositeOp)
        ENUMERATOR(SrcAtopCompositeOp)
        ENUMERATOR(SrcCompositeOp)
        ENUMERATOR(SrcInCompositeOp)
        ENUMERATOR(SrcOutCompositeOp)
        ENUMERATOR(SrcOverCompositeOp)
        ENUMERATOR(ThresholdCompositeOp)
        ENUMERATOR(UndefinedCompositeOp)
        ENUMERATOR(VividLightCompositeOp)
        ENUMERATOR(XorCompositeOp)
        ENUMERATOR(HardMixCompositeOp)
#if defined(IMAGEMAGICK_7)
        ENUMERATOR(CopyAlphaCompositeOp)
#else
        ENUMERATORV(CopyAlphaCompositeOp, CopyOpacityCompositeOp)
#endif
    END_ENUM

    // CompressionType constants
    DEF_ENUM(CompressionType)
        ENUMERATOR(UndefinedCompression)
        ENUMERATOR(NoCompression)
        ENUMERATOR(B44Compression)
        ENUMERATOR(B44ACompression)
        ENUMERATOR(BZipCompression)
        ENUMERATOR(DXT1Compression)
        ENUMERATOR(DXT3Compression)
        ENUMERATOR(DXT5Compression)
        ENUMERATOR(FaxCompression)
        ENUMERATOR(Group4Compression)
        ENUMERATOR(JPEGCompression)
        ENUMERATOR(JPEG2000Compression)
        ENUMERATOR(LosslessJPEGCompression)
        ENUMERATOR(LZWCompression)
        ENUMERATOR(PizCompression)
        ENUMERATOR(Pxr24Compression)
        ENUMERATOR(RLECompression)
        ENUMERATOR(ZipCompression)
        ENUMERATOR(ZipSCompression)
        ENUMERATOR(LZMACompression)
        ENUMERATOR(JBIG1Compression)
        ENUMERATOR(JBIG2Compression)
    END_ENUM

    // DecorationType constants
    DEF_ENUM(DecorationType)
        ENUMERATOR(NoDecoration)
        ENUMERATOR(UnderlineDecoration)
        ENUMERATOR(OverlineDecoration)
        ENUMERATOR(LineThroughDecoration)
    END_ENUM

    // DisposeType constants
    DEF_ENUM(DisposeType)
        ENUMERATOR(UnrecognizedDispose)
        ENUMERATOR(UndefinedDispose)
        ENUMERATOR(BackgroundDispose)
        ENUMERATOR(NoneDispose)
        ENUMERATOR(PreviousDispose)
    END_ENUM

    // DistortMethod constants
    DEF_ENUM(DistortMethod)
        ENUMERATOR(UndefinedDistortion)
        ENUMERATOR(AffineDistortion)
        ENUMERATOR(AffineProjectionDistortion)
        ENUMERATOR(ArcDistortion)
        ENUMERATOR(PolarDistortion)
        ENUMERATOR(DePolarDistortion)
        ENUMERATOR(BarrelDistortion)
        ENUMERATOR(BilinearDistortion)
        ENUMERATOR(BilinearForwardDistortion)
        ENUMERATOR(BilinearReverseDistortion)
        ENUMERATOR(PerspectiveDistortion)
        ENUMERATOR(PerspectiveProjectionDistortion)
        ENUMERATOR(PolynomialDistortion)
        ENUMERATOR(ScaleRotateTranslateDistortion)
        ENUMERATOR(ShepardsDistortion)
        ENUMERATOR(BarrelInverseDistortion)
        ENUMERATOR(Cylinder2PlaneDistortion)
        ENUMERATOR(Plane2CylinderDistortion)
        ENUMERATOR(ResizeDistortion)
        ENUMERATOR(SentinelDistortion)
    END_ENUM

    DEF_ENUM(DitherMethod)
        ENUMERATOR(UndefinedDitherMethod)
        ENUMERATOR(NoDitherMethod)
        ENUMERATOR(RiemersmaDitherMethod)
        ENUMERATOR(FloydSteinbergDitherMethod)
    END_ENUM

    DEF_ENUM(EndianType)
        ENUMERATOR(UndefinedEndian)
        ENUMERATOR(LSBEndian)
        ENUMERATOR(MSBEndian)
    END_ENUM

    // FilterType constants
    DEF_ENUM(FilterType)
        ENUMERATOR(UndefinedFilter)
        ENUMERATOR(PointFilter)
        ENUMERATOR(BoxFilter)
        ENUMERATOR(TriangleFilter)
        ENUMERATOR(HermiteFilter)
        ENUMERATOR(HanningFilter)
        ENUMERATOR(HammingFilter)
        ENUMERATOR(BlackmanFilter)
        ENUMERATOR(GaussianFilter)
        ENUMERATOR(QuadraticFilter)
        ENUMERATOR(CubicFilter)
        ENUMERATOR(CatromFilter)
        ENUMERATOR(MitchellFilter)
        ENUMERATOR(LanczosFilter)
        ENUMERATOR(BesselFilter)
        ENUMERATOR(SincFilter)
        ENUMERATOR(KaiserFilter)
        ENUMERATOR(WelshFilter)
        ENUMERATOR(ParzenFilter)
        ENUMERATOR(LagrangeFilter)
        ENUMERATOR(BohmanFilter)
        ENUMERATOR(BartlettFilter)
        ENUMERATOR(JincFilter)
        ENUMERATOR(SincFastFilter)
        ENUMERATOR(LanczosSharpFilter)
        ENUMERATOR(Lanczos2Filter)
        ENUMERATOR(Lanczos2SharpFilter)
        ENUMERATOR(RobidouxFilter)
        ENUMERATOR(RobidouxSharpFilter)
        ENUMERATOR(CosineFilter)
        ENUMERATOR(SplineFilter)
        ENUMERATOR(LanczosRadiusFilter)
        ENUMERATORV(WelchFilter, WelshFilter)
        ENUMERATORV(HannFilter, HanningFilter)
    END_ENUM

    // GravityType constants
    DEF_ENUM(GravityType)
        ENUMERATOR(UndefinedGravity)
        ENUMERATOR(ForgetGravity)
        ENUMERATOR(NorthWestGravity)
        ENUMERATOR(NorthGravity)
        ENUMERATOR(NorthEastGravity)
        ENUMERATOR(WestGravity)
        ENUMERATOR(CenterGravity)
        ENUMERATOR(EastGravity)
        ENUMERATOR(SouthWestGravity)
        ENUMERATOR(SouthGravity)
        ENUMERATOR(SouthEastGravity)
    END_ENUM

    // ImageType constants
    DEF_ENUM(ImageType)
        ENUMERATOR(UndefinedType)
        ENUMERATOR(BilevelType)
        ENUMERATOR(GrayscaleType)
        ENUMERATOR(PaletteType)
        ENUMERATOR(TrueColorType)
        ENUMERATOR(ColorSeparationType)
        ENUMERATOR(OptimizeType)
#if defined(IMAGEMAGICK_7)
        ENUMERATOR(GrayscaleAlphaType)
        ENUMERATOR(PaletteAlphaType)
        ENUMERATOR(TrueColorAlphaType)
        ENUMERATOR(ColorSeparationAlphaType)
        ENUMERATOR(PaletteBilevelAlphaType)
#else
        ENUMERATORV(GrayscaleAlphaType, GrayscaleMatteType)
        ENUMERATORV(PaletteAlphaType, PaletteMatteType)
        ENUMERATORV(TrueColorAlphaType, TrueColorMatteType)
        ENUMERATORV(ColorSeparationAlphaType, ColorSeparationMatteType)
        ENUMERATORV(PaletteBilevelAlphaType, PaletteBilevelMatteType)
#endif
    END_ENUM

    // InterlaceType constants
    DEF_ENUM(InterlaceType)
        ENUMERATOR(UndefinedInterlace)
        ENUMERATOR(NoInterlace)
        ENUMERATOR(LineInterlace)
        ENUMERATOR(PlaneInterlace)
        ENUMERATOR(PartitionInterlace)
        ENUMERATOR(GIFInterlace)
        ENUMERATOR(JPEGInterlace)
        ENUMERATOR(PNGInterlace)
    END_ENUM

    DEF_ENUM(MagickFunction)
        ENUMERATOR(UndefinedFunction)
        ENUMERATOR(PolynomialFunction)
        ENUMERATOR(SinusoidFunction)
        ENUMERATOR(ArcsinFunction)
        ENUMERATOR(ArctanFunction)
    END_ENUM

    DEF_ENUM(LayerMethod)
        ENUMERATOR(UndefinedLayer)
        ENUMERATOR(CompareAnyLayer)
        ENUMERATOR(CompareClearLayer)
        ENUMERATOR(CompareOverlayLayer)
        ENUMERATOR(OptimizeLayer)
        ENUMERATOR(OptimizePlusLayer)
        ENUMERATOR(CoalesceLayer)
        ENUMERATOR(DisposeLayer)
        ENUMERATOR(OptimizeTransLayer)
        ENUMERATOR(OptimizeImageLayer)
        ENUMERATOR(RemoveDupsLayer)
        ENUMERATOR(RemoveZeroLayer)
        ENUMERATOR(CompositeLayer)
        ENUMERATOR(MergeLayer)
        ENUMERATOR(MosaicLayer)
        ENUMERATOR(FlattenLayer)
        ENUMERATOR(TrimBoundsLayer)
    END_ENUM

    DEF_ENUM(MetricType)
        ENUMERATOR(AbsoluteErrorMetric)
        ENUMERATOR(MeanAbsoluteErrorMetric)
        ENUMERATOR(MeanSquaredErrorMetric)
        ENUMERATOR(PeakAbsoluteErrorMetric)
        ENUMERATOR(RootMeanSquaredErrorMetric)
        ENUMERATOR(NormalizedCrossCorrelationErrorMetric)
        ENUMERATOR(FuzzErrorMetric)
        ENUMERATOR(PerceptualHashErrorMetric)
#if defined(IMAGEMAGICK_7)
        ENUMERATOR(UndefinedErrorMetric)
        ENUMERATOR(MeanErrorPerPixelErrorMetric)
        ENUMERATOR(PeakSignalToNoiseRatioErrorMetric)
#else
        ENUMERATORV(UndefinedErrorMetric, UndefinedMetric)
        ENUMERATORV(MeanErrorPerPixelErrorMetric, MeanErrorPerPixelMetric)
        ENUMERATORV(PeakSignalToNoiseRatioErrorMetric, PeakSignalToNoiseRatioMetric)
#endif
    END_ENUM

    // NoiseType constants
    DEF_ENUM(NoiseType)
        ENUMERATOR(UniformNoise)
        ENUMERATOR(GaussianNoise)
        ENUMERATOR(MultiplicativeGaussianNoise)
        ENUMERATOR(ImpulseNoise)
        ENUMERATOR(LaplacianNoise)
        ENUMERATOR(PoissonNoise)
        ENUMERATOR(RandomNoise)
    END_ENUM

    // Orientation constants
    DEF_ENUM(OrientationType)
        ENUMERATOR(UndefinedOrientation)
        ENUMERATOR(TopLeftOrientation)
        ENUMERATOR(TopRightOrientation)
        ENUMERATOR(BottomRightOrientation)
        ENUMERATOR(BottomLeftOrientation)
        ENUMERATOR(LeftTopOrientation)
        ENUMERATOR(RightTopOrientation)
        ENUMERATOR(RightBottomOrientation)
        ENUMERATOR(LeftBottomOrientation)
    END_ENUM

    // Paint method constants
    DEF_ENUM(PaintMethod)
        ENUMERATOR(PointMethod)
        ENUMERATOR(ReplaceMethod)
        ENUMERATOR(FloodfillMethod)
        ENUMERATOR(FillToBorderMethod)
        ENUMERATOR(ResetMethod)
    END_ENUM

    // PixelInterpolateMethod constants
    DEF_ENUM(PixelInterpolateMethod)
        ENUMERATOR(UndefinedInterpolatePixel)
        ENUMERATOR(AverageInterpolatePixel)
        ENUMERATOR(BilinearInterpolatePixel)
        ENUMERATOR(IntegerInterpolatePixel)
        ENUMERATOR(MeshInterpolatePixel)
#if defined(IMAGEMAGICK_7)
        ENUMERATOR(NearestInterpolatePixel)
#else
        ENUMERATORV(NearestInterpolatePixel, NearestNeighborInterpolatePixel)
#endif
        ENUMERATOR(SplineInterpolatePixel)
        ENUMERATOR(Average9InterpolatePixel)
        ENUMERATOR(Average16InterpolatePixel)
        ENUMERATOR(BlendInterpolatePixel)
        ENUMERATOR(BackgroundInterpolatePixel)
        ENUMERATOR(CatromInterpolatePixel)
    END_ENUM

    // PreviewType
    DEF_ENUM(PreviewType)
        ENUMERATOR(UndefinedPreview)
        ENUMERATOR(RotatePreview)
        ENUMERATOR(ShearPreview)
        ENUMERATOR(RollPreview)
        ENUMERATOR(HuePreview)
        ENUMERATOR(SaturationPreview)
        ENUMERATOR(BrightnessPreview)
        ENUMERATOR(GammaPreview)
        ENUMERATOR(SpiffPreview)
        ENUMERATOR(DullPreview)
        ENUMERATOR(GrayscalePreview)
        ENUMERATOR(QuantizePreview)
        ENUMERATOR(DespecklePreview)
        ENUMERATOR(ReduceNoisePreview)
        ENUMERATOR(AddNoisePreview)
        ENUMERATOR(SharpenPreview)
        ENUMERATOR(BlurPreview)
        ENUMERATOR(ThresholdPreview)
        ENUMERATOR(EdgeDetectPreview)
        ENUMERATOR(SpreadPreview)
        ENUMERATOR(SolarizePreview)
        ENUMERATOR(ShadePreview)
        ENUMERATOR(RaisePreview)
        ENUMERATOR(SegmentPreview)
        ENUMERATOR(SwirlPreview)
        ENUMERATOR(ImplodePreview)
        ENUMERATOR(WavePreview)
        ENUMERATOR(OilPaintPreview)
        ENUMERATOR(CharcoalDrawingPreview)
        ENUMERATOR(JPEGPreview)
    END_ENUM

    DEF_ENUM(QuantumExpressionOperator)
        ENUMERATOR(UndefinedQuantumOperator)
        ENUMERATOR(AddQuantumOperator)
        ENUMERATOR(AndQuantumOperator)
        ENUMERATOR(DivideQuantumOperator)
        ENUMERATOR(LShiftQuantumOperator)
        ENUMERATOR(MaxQuantumOperator)
        ENUMERATOR(MinQuantumOperator)
        ENUMERATOR(MultiplyQuantumOperator)
        ENUMERATOR(OrQuantumOperator)
        ENUMERATOR(RShiftQuantumOperator)
        ENUMERATOR(SubtractQuantumOperator)
        ENUMERATOR(XorQuantumOperator)
        ENUMERATOR(PowQuantumOperator)
        ENUMERATOR(LogQuantumOperator)
        ENUMERATOR(ThresholdQuantumOperator)
        ENUMERATOR(ThresholdBlackQuantumOperator)
        ENUMERATOR(ThresholdWhiteQuantumOperator)
        ENUMERATOR(GaussianNoiseQuantumOperator)
        ENUMERATOR(ImpulseNoiseQuantumOperator)
        ENUMERATOR(LaplacianNoiseQuantumOperator)
        ENUMERATOR(MultiplicativeNoiseQuantumOperator)
        ENUMERATOR(PoissonNoiseQuantumOperator)
        ENUMERATOR(UniformNoiseQuantumOperator)
        ENUMERATOR(CosineQuantumOperator)
        ENUMERATOR(SetQuantumOperator)
        ENUMERATOR(SineQuantumOperator)
        ENUMERATOR(AddModulusQuantumOperator)
        ENUMERATOR(MeanQuantumOperator)
        ENUMERATOR(AbsQuantumOperator)
        ENUMERATOR(ExponentialQuantumOperator)
        ENUMERATOR(MedianQuantumOperator)
        ENUMERATOR(SumQuantumOperator)
        ENUMERATOR(RootMeanSquareQuantumOperator)
    END_ENUM

    // RenderingIntent
    DEF_ENUM(RenderingIntent)
        ENUMERATOR(UndefinedIntent)
        ENUMERATOR(SaturationIntent)
        ENUMERATOR(PerceptualIntent)
        ENUMERATOR(AbsoluteIntent)
        ENUMERATOR(RelativeIntent)
    END_ENUM

    // ResolutionType constants
    DEF_ENUM(ResolutionType)
        ENUMERATOR(UndefinedResolution)
        ENUMERATOR(PixelsPerInchResolution)
        ENUMERATOR(PixelsPerCentimeterResolution)
    END_ENUM

    DEF_ENUM(SparseColorMethod)
        ENUMERATOR(UndefinedColorInterpolate)
        ENUMERATOR(BarycentricColorInterpolate)
        ENUMERATOR(BilinearColorInterpolate)
        //ENUMERATOR(PolynomialColorInterpolate)
        ENUMERATOR(ShepardsColorInterpolate)
        ENUMERATOR(VoronoiColorInterpolate)
        ENUMERATOR(InverseColorInterpolate)
    END_ENUM

    // SpreadMethod
    DEF_ENUM(SpreadMethod)
        ENUMERATOR(UndefinedSpread)
        ENUMERATOR(PadSpread)
        ENUMERATOR(ReflectSpread)
        ENUMERATOR(RepeatSpread)
    END_ENUM

    // StorageType
    DEF_ENUM(StorageType)
        ENUMERATOR(UndefinedPixel)
        ENUMERATOR(CharPixel)
        ENUMERATOR(DoublePixel)
        ENUMERATOR(FloatPixel)
        ENUMERATOR(LongPixel)
        ENUMERATOR(QuantumPixel)
        ENUMERATOR(ShortPixel)
    END_ENUM

    // StretchType constants
    DEF_ENUM(StretchType)
        ENUMERATOR(NormalStretch)
        ENUMERATOR(UltraCondensedStretch)
        ENUMERATOR(ExtraCondensedStretch)
        ENUMERATOR(CondensedStretch)
        ENUMERATOR(SemiCondensedStretch)
        ENUMERATOR(SemiExpandedStretch)
        ENUMERATOR(ExpandedStretch)
        ENUMERATOR(ExtraExpandedStretch)
        ENUMERATOR(UltraExpandedStretch)
        ENUMERATOR(AnyStretch)
    END_ENUM

    // StyleType constants
    DEF_ENUM(StyleType)
        ENUMERATOR(NormalStyle)
        ENUMERATOR(ItalicStyle)
        ENUMERATOR(ObliqueStyle)
        ENUMERATOR(AnyStyle)
    END_ENUM

    // VirtualPixelMethod
    DEF_ENUM(VirtualPixelMethod)
        ENUMERATOR(UndefinedVirtualPixelMethod)
        ENUMERATOR(EdgeVirtualPixelMethod)
        ENUMERATOR(MirrorVirtualPixelMethod)
        ENUMERATOR(TileVirtualPixelMethod)
        ENUMERATOR(TransparentVirtualPixelMethod)
        ENUMERATOR(BackgroundVirtualPixelMethod)
        ENUMERATOR(DitherVirtualPixelMethod)
        ENUMERATOR(RandomVirtualPixelMethod)
        ENUMERATOR(MaskVirtualPixelMethod)
        ENUMERATOR(BlackVirtualPixelMethod)
        ENUMERATOR(GrayVirtualPixelMethod)
        ENUMERATOR(WhiteVirtualPixelMethod)
        ENUMERATOR(HorizontalTileVirtualPixelMethod)
        ENUMERATOR(VerticalTileVirtualPixelMethod)
        ENUMERATOR(HorizontalTileEdgeVirtualPixelMethod)
        ENUMERATOR(VerticalTileEdgeVirtualPixelMethod)
        ENUMERATOR(CheckerTileVirtualPixelMethod)
    END_ENUM
    // WeightType constants
    DEF_ENUM(WeightType)
        ENUMERATOR(AnyWeight)
        ENUMERATOR(NormalWeight)
        ENUMERATOR(BoldWeight)
        ENUMERATOR(BolderWeight)
        ENUMERATOR(LighterWeight)
    END_ENUM

    // For KernelInfo scaling
    DEF_ENUM(GeometryFlags)
        ENUMERATOR(NoValue)
        ENUMERATOR(XValue)
        ENUMERATOR(XiValue)
        ENUMERATOR(YValue)
        ENUMERATOR(PsiValue)
        ENUMERATOR(WidthValue)
        ENUMERATOR(RhoValue)
        ENUMERATOR(HeightValue)
        ENUMERATOR(SigmaValue)
        ENUMERATOR(ChiValue)
        ENUMERATOR(XiNegative)
        ENUMERATOR(XNegative)
        ENUMERATOR(PsiNegative)
        ENUMERATOR(YNegative)
        ENUMERATOR(ChiNegative)
        ENUMERATOR(PercentValue)
        ENUMERATOR(AspectValue)
        ENUMERATOR(NormalizeValue)
        ENUMERATOR(LessValue)
        ENUMERATOR(GreaterValue)
        ENUMERATOR(MinimumValue)
        ENUMERATOR(CorrelateNormalizeValue)
        ENUMERATOR(AreaValue)
        ENUMERATOR(DecimalValue)
        ENUMERATOR(SeparatorValue)
        ENUMERATOR(AllValues)
    END_ENUM

    // Morphology methods
    DEF_ENUM(MorphologyMethod)
      ENUMERATOR(UndefinedMorphology)
      ENUMERATOR(ConvolveMorphology)
      ENUMERATOR(CorrelateMorphology)
      ENUMERATOR(ErodeMorphology)
      ENUMERATOR(DilateMorphology)
      ENUMERATOR(ErodeIntensityMorphology)
      ENUMERATOR(DilateIntensityMorphology)
      ENUMERATOR(DistanceMorphology)
      ENUMERATOR(OpenMorphology)
      ENUMERATOR(CloseMorphology)
      ENUMERATOR(OpenIntensityMorphology)
      ENUMERATOR(CloseIntensityMorphology)
      ENUMERATOR(SmoothMorphology)
      ENUMERATOR(EdgeInMorphology)
      ENUMERATOR(EdgeOutMorphology)
      ENUMERATOR(EdgeMorphology)
      ENUMERATOR(TopHatMorphology)
      ENUMERATOR(BottomHatMorphology)
      ENUMERATOR(HitAndMissMorphology)
      ENUMERATOR(ThinningMorphology)
      ENUMERATOR(ThickenMorphology)
      ENUMERATOR(VoronoiMorphology)
      ENUMERATOR(IterativeDistanceMorphology)
    END_ENUM

    DEF_ENUM(KernelInfoType)
      ENUMERATOR(UndefinedKernel)
      ENUMERATOR(UnityKernel)
      ENUMERATOR(GaussianKernel)
      ENUMERATOR(DoGKernel)
      ENUMERATOR(LoGKernel)
      ENUMERATOR(BlurKernel)
      ENUMERATOR(CometKernel)
      ENUMERATOR(LaplacianKernel)
      ENUMERATOR(SobelKernel)
      ENUMERATOR(FreiChenKernel)
      ENUMERATOR(RobertsKernel)
      ENUMERATOR(PrewittKernel)
      ENUMERATOR(CompassKernel)
      ENUMERATOR(KirschKernel)
      ENUMERATOR(DiamondKernel)
      ENUMERATOR(SquareKernel)
      ENUMERATOR(RectangleKernel)
      ENUMERATOR(OctagonKernel)
      ENUMERATOR(DiskKernel)
      ENUMERATOR(PlusKernel)
      ENUMERATOR(CrossKernel)
      ENUMERATOR(RingKernel)
      ENUMERATOR(PeaksKernel)
      ENUMERATOR(EdgesKernel)
      ENUMERATOR(CornersKernel)
      ENUMERATOR(DiagonalsKernel)
      ENUMERATOR(LineEndsKernel)
      ENUMERATOR(LineJunctionsKernel)
      ENUMERATOR(RidgesKernel)
      ENUMERATOR(ConvexHullKernel)
      ENUMERATOR(ThinSEKernel)
      ENUMERATOR(SkeletonKernel)
      ENUMERATOR(ChebyshevKernel)
      ENUMERATOR(ManhattanKernel)
      ENUMERATOR(OctagonalKernel)
      ENUMERATOR(EuclideanKernel)
      ENUMERATOR(UserDefinedKernel)
      ENUMERATOR(BinomialKernel)
    END_ENUM

    /*-----------------------------------------------------------------------*/
    /* Struct classes                                                        */
    /*-----------------------------------------------------------------------*/

    // Pass NULL as the structure name to keep them from polluting the Struct
    // namespace. The only way to use these classes is via the Magick:: namespace.

    // Magick::AffineMatrix
    Class_AffineMatrix = rb_struct_define_under(Module_Magick, "AffineMatrix",
                                                "sx", "rx", "ry", "sy", "tx", "ty", NULL);

    // Magick::Primary
    Class_Primary = rb_struct_define_under(Module_Magick, "Primary",
                                           "x", "y", "z", NULL);
    rb_define_method(Class_Primary, "to_s", RUBY_METHOD_FUNC(PrimaryInfo_to_s), 0);

    // Magick::Chromaticity
    Class_Chromaticity = rb_struct_define_under(Module_Magick, "Chromaticity",
                                                "red_primary", "green_primary",
                                                "blue_primary", "white_point", NULL);
    rb_define_method(Class_Chromaticity, "to_s", RUBY_METHOD_FUNC(ChromaticityInfo_to_s), 0);

    // Magick::Color
    Class_Color = rb_struct_define_under(Module_Magick, "Color",
                                         "name", "compliance", "color", NULL);
    rb_define_method(Class_Color, "to_s", RUBY_METHOD_FUNC(Color_to_s), 0);

    // Magick::Point
    Class_Point = rb_struct_define_under(Module_Magick, "Point",
                                         "x", "y", NULL);

    // Magick::Rectangle
    Class_Rectangle = rb_struct_define_under(Module_Magick, "Rectangle",
                                             "width", "height", "x", "y", NULL);
    rb_define_method(Class_Rectangle, "to_s", RUBY_METHOD_FUNC(RectangleInfo_to_s), 0);

    // Magick::Segment
    Class_Segment = rb_struct_define_under(Module_Magick, "Segment",
                                           "x1", "y1", "x2", "y2", NULL);
    rb_define_method(Class_Segment, "to_s", RUBY_METHOD_FUNC(SegmentInfo_to_s), 0);

    // Magick::Font
    Class_Font = rb_struct_define_under(Module_Magick, "Font",
                                        "name", "description",
                                        "family", "style", "stretch", "weight",
                                        "encoding", "foundry", "format", NULL);
    rb_define_method(Class_Font, "to_s", RUBY_METHOD_FUNC(Font_to_s), 0);

    // Magick::TypeMetric
    Class_TypeMetric = rb_struct_define_under(Module_Magick, "TypeMetric",
                                              "pixels_per_em", "ascent", "descent",
                                              "width", "height", "max_advance", "bounds",
                                              "underline_position", "underline_thickness", NULL);
    rb_define_method(Class_TypeMetric, "to_s", RUBY_METHOD_FUNC(TypeMetric_to_s), 0);


    /*-----------------------------------------------------------------------*/
    /* Error handlers                                                        */
    /*-----------------------------------------------------------------------*/

    SetFatalErrorHandler(rm_fatal_error_handler);
    SetErrorHandler(rm_error_handler);
    SetWarningHandler(rm_warning_handler);
}




/**
 * Ensure the version of ImageMagick we're running with matches the version we
 * were compiled with.
 *
 * No Ruby usage (internal function)
 */
static void
test_Magick_version(void)
{
    size_t version_number;
    const char *version_str;

    /* ImageMagick versions are defined as major, minor and patch, each of which are defined as a value in 1 byte. */
    /* ImageMagick 6.9.12 has `#define MagickLibVersion  0x69C` */
    /* It use only major and minor versions. */
    size_t mask_major_minor_version = 0xFFFFFFF0;

    version_str = GetMagickVersion(&version_number);
    if ((version_number & mask_major_minor_version) != (MagickLibVersion & mask_major_minor_version))
    {
        int n, x;

        // Extract the string "ImageMagick X.Y.Z"
        n = 0;
        for (x = 0; version_str[x] != '\0'; x++)
        {
            if (version_str[x] == ' ' && ++n == 2)
            {
                break;
            }
        }

        rb_raise(rb_eRuntimeError,
                 "This installation of RMagick was configured with %s %s but %.*s is in use.\n"
                 "Please re-install RMagick to correct the issue.\n",
                 MagickPackageName, MagickLibVersionText, x, version_str);
    }

}





/**
 * Create Version, Magick_version, and Version_long constants.
 *
 * No Ruby usage (internal function)
 */
static void
version_constants(void)
{
    const char *mgk_version;
    VALUE str;
    char long_version[1000];

    mgk_version = GetMagickVersion(NULL);

    str = rb_str_new2(mgk_version);
    rb_obj_freeze(str);
    rb_define_const(Module_Magick, "Magick_version", str);

    str = rb_str_new2(Q(RMAGICK_VERSION_STRING));
    rb_obj_freeze(str);
    rb_define_const(Module_Magick, "Version", str);

    snprintf(long_version, sizeof(long_version),
            "This is %s ($Date: 2009/12/20 02:33:33 $) Copyright (C) 2009 by Timothy P. Hunter\n"
            "Built with %s\n"
            "Built for %s\n"
            "Web page: https://rmagick.github.io/\n",
            Q(RMAGICK_VERSION_STRING), mgk_version, Q(RUBY_VERSION_STRING));

    str = rb_str_new2(long_version);
    rb_obj_freeze(str);
    rb_define_const(Module_Magick, "Long_version", str);

    RB_GC_GUARD(str);
}


/**
 * Create Features constant.
 *
 * No Ruby usage (internal function)
 */
static void
features_constant(void)
{
    VALUE features;

    // 6.5.7 - latest (7.0.0)
    features = rb_str_new2(GetMagickFeatures());

    rb_obj_freeze(features);
    rb_define_const(Module_Magick, "Magick_features", features);

    RB_GC_GUARD(features);
}

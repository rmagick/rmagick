/**************************************************************************//**
 * Utility functions for RMagick.
 *
 * Copyright &copy; 2002 - 2009 by Timothy P. Hunter
 *
 * Changes since Nov. 2009 copyright &copy; by Benjamin Thomas and Omer Bar-or
 *
 * @file     rmutil.c
 * @version  $Id: rmutil.c,v 1.182 2009/12/21 10:34:58 baror Exp $
 * @author   Tim Hunter
 ******************************************************************************/

#include "rmagick.h"
#include <errno.h>

static void handle_exception(ExceptionInfo *, Image *, ErrorRetention);


/**
 * ImageMagick safe version of malloc.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Use when managing memory that ImageMagick may have allocated or may free.
 *   - If malloc fails, it raises an exception.
 *   - magick_safe_malloc and magick_safe_realloc prevent exceptions caused by
 *     integer overflow. Added in 6.3.5-9 but backwards compatible with prior
 *     releases.
 *
 * @param count the number of quantum elements to allocate
 * @param quantum the number of bytes in each quantum
 * @return a pointer to a block of memory that is at least count*quantum
 */
void *
magick_safe_malloc(const size_t count, const size_t quantum)
{
    void *ptr;

    ptr = AcquireQuantumMemory(count, quantum);
    if (!ptr)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }
    return ptr;
}


/**
 * ImageMagick version of malloc.
 *
 * No Ruby usage (internal function)
 *
 * @param size the size of memory to allocate
 * @return pointer to a block of memory
 */
void *
magick_malloc(const size_t size)
{
    void *ptr;
    ptr = AcquireMagickMemory(size);
    if (!ptr)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }

    return ptr;
}


/**
 * ImageMagick version of free.
 *
 * No Ruby usage (internal function)
 *
 * @param ptr pointer to the existing block of memory
 */
void
magick_free(void *ptr)
{
    (void) RelinquishMagickMemory(ptr);
}


/**
 * ImageMagick safe version of realloc.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Use when managing memory that ImageMagick may have allocated or may free.
 *   - If malloc fails, it raises an exception.
 *   - magick_safe_malloc and magick_safe_realloc prevent exceptions caused by
 *     integer overflow. Added in 6.3.5-9 but backwards compatible with prior
 *     releases.
 *
 * @param memory the existing block of memory
 * @param count the number of quantum elements to allocate
 * @param quantum the number of bytes in each quantum
 * @return a pointer to a block of memory that is at least count*quantum in size
 */
void *
magick_safe_realloc(void *memory, const size_t count, const size_t quantum)
{
    void *v;
    v = ResizeQuantumMemory(memory, count, quantum);
    if (!v)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }
    return v;
}


/**
 * ImageMagick version of realloc.
 *
 * No Ruby usage (internal function)
 *
 * @param ptr pointer to the existing block of memory
 * @param size the new size of memory to allocate
 * @return pointer to a block of memory
 */
void *
magick_realloc(void *ptr, const size_t size)
{
    void *v;
    v = ResizeMagickMemory(ptr, size);
    if (!v)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }
    return v;
}


/**
 * Make a copy of a string in malloc'd memory.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Any existing string pointed to by *new_str is freed.
 *   - CloneString asserts if no memory. No need to check its return value.
 *
 * @param new_str pointer to the new string
 * @param str the string to copy
 */
void
 magick_clone_string(char **new_str, const char *str)
{
    (void) CloneString(new_str, str);
}


/**
 * Compare s1 and s2 ignoring case.
 *
 * No Ruby usage (internal function)
 *
 * @param s1 the first string
 * @param s2 the second string
 * @return same as strcmp(3)
 */
int
rm_strcasecmp(const char *s1, const char *s2)
{
    while (*s1 && *s2)
    {
        if (toupper(*s1) != toupper(*s2))
        {
            break;
        }
        s1 += 1;
        s2 += 1;
    }
    return (int)(*s1 - *s2);
}


/**
 * Compare s1 and s2 ignoring case.
 *
 * No Ruby usage (internal function)
 *
 * @param s1 the first string
 * @param s2 the second string
 * @param n number of characters to compare
 * @return same as strcmp(3)
 */
int
rm_strncasecmp(const char *s1, const char *s2, size_t n)
{
    if (n == 0)
    {
        return 0;
    }
    while (toupper(*s1) == toupper(*s2))
    {
        if (--n == 0 || *s1 == '\0')
        {
            return 0;
        }
        s1 += 1;
        s2 += 1;
    }
    return (int)(*s1 - *s2);
}


/**
 * Raise exception if array too short.
 *
 * No Ruby usage (internal function)
 *
 * @param ary the array
 * @param len the minimum length
 * @throw IndexError
 */
void
rm_check_ary_len(VALUE ary, long len)
{
    if (RARRAY_LEN(ary) < len)
    {
        rb_raise(rb_eIndexError, "not enough elements in array - expecting %ld, got %ld",
                        len, (long)RARRAY_LEN(ary));
    }
}


/**
 * Raise exception if ary argument was invalid type
 *
 * No Ruby usage (internal function)
 *
 * @param ary the array
 * @return the array that is converted type of argument object if needed
 * @throw TypeError
 */
VALUE
rm_check_ary_type(VALUE ary)
{
    VALUE checked = rb_check_array_type(ary);
    if (NIL_P(checked))
    {
        rb_raise(rb_eTypeError, "wrong argument type %"PRIsVALUE" was given. (must respond to :to_ary)", rb_obj_class(ary));
    }
    return checked;
}


/**
 * Raise an error if the image has been destroyed.
 *
 * No Ruby usage (internal function)
 *
 * @param obj the image
 * @return the C image structure for the image
 * @throw DestroyedImageError
 */
Image *
rm_check_destroyed(VALUE obj)
{
    Image *image;

    Data_Get_Struct(obj, Image, image);
    if (!image)
    {
        rb_raise(Class_DestroyedImageError, "destroyed image");
    }

    return image;
}


/**
 * Raise an error if the image has been destroyed or is frozen.
 *
 * No Ruby usage (internal function)
 *
 * @param obj the image
 * @return the C image structure for the image
 */
Image *
rm_check_frozen(VALUE obj)
{
    Image *image = rm_check_destroyed(obj);
    rb_check_frozen(obj);
    return image;
}


/**
 * Overrides freeze in classes that can't be frozen.
 *
 * No Ruby usage (internal function)
 *
 * @param obj the object of the class to override
 * @return 0
 * @throw TypeError
 */
VALUE
rm_no_freeze(VALUE obj)
{
    rb_raise(rb_eTypeError, "can't freeze %s", rb_class2name(CLASS_OF(obj)));
    return (VALUE)0;
}


/**
 * Return obj.to_s, or obj if obj is already a string.
 *
 * No Ruby usage (internal function)
 *
 * @param obj a Ruby object
 * @return a String representation of obj
 */
VALUE
rm_to_s(VALUE obj)
{

    if (TYPE(obj) != T_STRING)
    {
        return rb_funcall(obj, rm_ID_to_s, 0);
    }
    return obj;
}


/**
 * Supply our own version of the "obsolete" rb_str2cstr.
 *
 * No Ruby usage (internal function)
 *
 * @param str the Ruby string
 * @param len pointer to a long in which to store the number of characters
 * @return a C string version of str
 */
char *
rm_str2cstr(VALUE str, long *len)
{
    StringValue(str);
    if (len)
    {
        *len = RSTRING_LEN(str);
    }
    return RSTRING_PTR(str);
}


/**
 * Try to convert the argument to a double, raise an exception if fail.
 *
 * No Ruby usage (internal function)
 *
 * @param arg the argument
 * @return arg
 */
static VALUE
arg_is_number(VALUE arg)
{
    double d;
    d = NUM2DBL(arg);
    d = d;      // satisfy icc
    return arg;
}


/**
 * Called when `rb_str_to_str' raises an exception.
 *
 * No Ruby usage (internal function)
 *
 * @param arg the argument
 * @return 0
 * @throw TypeError
 */
static VALUE
rescue_not_str(VALUE arg)
{
    rb_raise(rb_eTypeError, "argument must be a number or a string in the form 'NN%%' (%s given)",
            rb_class2name(CLASS_OF(arg)));
    return (VALUE)0;
}


/**
 * Return a double between 0.0 and max (the second argument), inclusive. If the
 * argument is a number convert to a Float object, otherwise it's supposed to be
 * a string in the form * "NN%". Convert to a number and then to a Float.
 *
 * No Ruby usage (internal function)
 *
 * @param arg the argument
 * @param max the maximum allowed value
 * @return a double
 */
double
rm_percentage(VALUE arg, double max)
{
    double pct;
    long pct_long;
    char *pct_str, *end;
    int not_num;

    // Try to convert the argument to a number. If failure, sets not_num to non-zero.
    (void) rb_protect(arg_is_number, arg, &not_num);

    if (not_num)
    {
        arg = rb_rescue(rb_str_to_str, arg, rescue_not_str, arg);
        pct_str = StringValuePtr(arg);
        errno = 0;
        pct_long = strtol(pct_str, &end, 10);
        if (errno == ERANGE)
        {
            rb_raise(rb_eRangeError, "`%s' out of range", pct_str);
        }
        if (*end != '\0' && *end != '%')
        {
            rb_raise(rb_eArgError, "expected percentage, got `%s'", pct_str);
        }

        if (*end == '%' && pct_long != 0)
        {
            pct = (((double)pct_long) / 100.0) * max;
        }
        else
        {
            pct = (double) pct_long;
        }
        if (pct < 0.0)
        {
            rb_raise(rb_eArgError, "percentages may not be negative (got `%s')", pct_str);
        }
    }
    else
    {
        pct = NUM2DBL(arg);
        if (pct < 0.0)
        {
            rb_raise(rb_eArgError, "percentages may not be negative (got `%g')", pct);
        }
    }

    return pct;
}


/**
 * Return 0 if rb_num2dbl doesn't raise an exception.
 *
 * No Ruby usage (internal function)
 *
 * @param obj the object to convert to a double
 * @return 0
 */
static VALUE
check_num2dbl(VALUE obj)
{
    (void) rb_num2dbl(obj);
    return INT2FIX(1);
}


/**
 * Called if rb_num2dbl raises an exception.
 *
 * No Ruby usage (internal function)
 *
 * @param ignored a Ruby object (unused)
 * @return 0
 */
static VALUE
rescue_not_dbl(VALUE ignored)
{
    ignored = ignored;      // defeat gcc message
    return INT2FIX(0);
}


/**
 * Return 1 if the object can be converted to a double, 0 otherwise.
 *
 * No Ruby usage (internal function)
 *
 * @param obj the object
 * @return 1 or 0
 */
int
rm_check_num2dbl(VALUE obj)
{
    return FIX2INT(rb_rescue(check_num2dbl, obj, rescue_not_dbl, (VALUE)0));
}


/**
 * Given a string in the form NN% return the corresponding double.
 *
 * No Ruby usage (internal function)
 *
 * @param str the string
 * @return a double
 */
double
rm_str_to_pct(VALUE str)
{
    long pct;
    char *pct_str, *end;

    str = rb_rescue(rb_str_to_str, str, rescue_not_str, str);
    pct_str = StringValuePtr(str);
    errno = 0;
    pct = strtol(pct_str, &end, 10);

    if (errno == ERANGE)
    {
        rb_raise(rb_eRangeError, "`%s' out of range", pct_str);
    }
    if (*end != '%')
    {
        rb_raise(rb_eArgError, "expected percentage, got `%s'", pct_str);
    }
    if (pct < 0L)
    {
        rb_raise(rb_eArgError, "percentages may not be negative (got `%s')", pct_str);
    }

    return pct / 100.0;
}


/**
 * If the argument is a number, convert it to a double. Otherwise it's supposed
 * to be a string in the form 'NN%'.  Return a percentage of QuantumRange.
 *
 * No Ruby usage (internal function)
 *
 * @param fuzz_arg the fuzz argument
 * @return a double
 * @see Image_fuzz
 * @see Image_fuzz_eq
 */
double
rm_fuzz_to_dbl(VALUE fuzz_arg)
{
    double fuzz;
    char *fuzz_str, *end;
    int not_num;

    // Try to convert the argument to a number. If failure, sets not_num to non-zero.
    (void) rb_protect(arg_is_number, fuzz_arg, &not_num);

    if (not_num)
    {
        // Convert to string, issue error message if failure.
        fuzz_arg = rb_rescue(rb_str_to_str, fuzz_arg, rescue_not_str, fuzz_arg);
        fuzz_str = StringValuePtr(fuzz_arg);
        errno = 0;
        fuzz = strtod(fuzz_str, &end);
        if (errno == ERANGE)
        {
            rb_raise(rb_eRangeError, "`%s' out of range", fuzz_str);
        }
        if(*end == '%')
        {
            if (fuzz < 0.0)
            {
                rb_raise(rb_eArgError, "percentages may not be negative (got `%s')", fuzz_str);
            }
            fuzz = (fuzz * QuantumRange) / 100.0;
        }
        else if(*end != '\0')
        {
            rb_raise(rb_eArgError, "expected percentage, got `%s'", fuzz_str);
        }
    }
    else
    {
        fuzz = NUM2DBL(fuzz_arg);
        if (fuzz < 0.0)
        {
            rb_raise(rb_eArgError, "fuzz may not be negative (got `%g')", fuzz);
        }
    }

    return fuzz;
}


/**
 * Convert a application-supplied number to a Quantum. If the object is a Float,
 * truncate it before converting.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Ruby says that 2147483647.5 doesn't fit into an unsigned long. If you
 *     truncate it, it works.
 *   - Should use this only when the input value is possibly subject to this
 *     problem.
 *
 * @param obj the application-supplied number
 * @return a Quantum
 */
Quantum
rm_app2quantum(VALUE obj)
{
    VALUE v = obj;

    if (TYPE(obj) == T_FLOAT)
    {
        v = rb_funcall(obj, rm_ID_to_i, 0);
    }

    RB_GC_GUARD(v);

    return NUM2QUANTUM(v);
}


/**
 * Returns a pointer to an image structure initialized to default values
 *
 * No Ruby usage (internal function)
 *
 * @param info the info
 * @return the created image
 */
Image *
rm_acquire_image(ImageInfo *info)
{
    return AcquireImage(info);
}


/**
 * Send the "cur_image" method to the object. If 'img' is an ImageList, then
 * cur_image is self[\@scene]. If 'img' is an image, then cur_image is simply
 * 'self'.
 *
 * No Ruby usage (internal function)
 *
 * @param img the object
 * @return the return value from "cur_image"
 */
VALUE
rm_cur_image(VALUE img)
{
    return rb_funcall(img, rm_ID_cur_image, 0);
}


/**
 * Map the color intensity to a named color.
 *
 * No Ruby usage (internal function)
 *
 * @param image the image
 * @param color the color intensity as a PixelColor
 * @return the named color as a String
 * @see rm_pixelcolor_to_color_name_info
 */
VALUE
rm_pixelcolor_to_color_name(Image *image, PixelColor *color)
{
    char name[MaxTextExtent];
    ExceptionInfo *exception;

    exception = AcquireExceptionInfo();

    (void) QueryColorname(image, color, X11Compliance, name, exception);
    CHECK_EXCEPTION()
    (void) DestroyExceptionInfo(exception);

    return rb_str_new2(name);
}


/**
 * Map the color intensity to a named color.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Simply create an Image from the Info, call QueryColorname, and then
 *     destroy the Image.
 *   - The default depth is always used, and the matte value is set to False,
 *     which means "don't use the alpha channel".
 *
 * @param info the info
 * @param color the color intensity as a PixelColor
 * @return the named color as a String
 * @see rm_pixelcolor_to_color_name
 */
VALUE
rm_pixelcolor_to_color_name_info(Info *info, PixelColor *color)
{
    Image *image;
    VALUE color_name;

    image = rm_acquire_image(info);
    if (!image)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue.");
    }

    image->matte = MagickFalse;
    color_name = rm_pixelcolor_to_color_name(image, color);
    (void) DestroyImage(image);

    return color_name;
}

/**
 * Initializes the MagickPixel structure.
 *
 * No Ruby usage (internal function)
 *
 * @param image the image
 * @param pp the MagickPixel
 */
void
rm_init_magickpixel(const Image *image, MagickPixel *pp)
{
    GetMagickPixelPacket(image, pp);
}

/**
 * Initializes the MagickPixel structure to the specified color.
 *
 * No Ruby usage (internal function)
 *
 * @param pp the MagickPixel
 * @param color the color
 */
void
rm_set_magickpixel(MagickPixel *pp, const char *color)
{
    ExceptionInfo *exception;

    exception = AcquireExceptionInfo();
    (void) QueryMagickColor(color, pp, exception);
    // This exception is ignored because the color comes from places where we control
    // the value and it is very unlikely that an exception will be thrown.
    (void) DestroyExceptionInfo(exception);
}

/**
 * Write a temporary copy of the image to the IM registry.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - The `temp_name' argument must point to an char array of size
 *     MaxTextExtent.
 *
 * @param image the image
 * @param temp_name the temporary name to use
 * @return the "filename" of the registered image
 */
void
rm_write_temp_image(Image *image, char *temp_name)
{

#define TMPNAM_CLASS_VAR "@@_tmpnam_"

    MagickBooleanType okay;
    ExceptionInfo *exception;
    VALUE id_value;
    int id;

    exception = AcquireExceptionInfo();


    // 'id' is always the value of its previous use
    if (rb_cvar_defined(Module_Magick, rb_intern(TMPNAM_CLASS_VAR)) == Qtrue)
    {
        id_value = rb_cv_get(Module_Magick, TMPNAM_CLASS_VAR);
        id = FIX2INT(id_value);
    }
    else
    {
        id = 0;
        rb_cv_set(Module_Magick, TMPNAM_CLASS_VAR, INT2FIX(id));
    }

    id += 1;
    rb_cv_set(Module_Magick, TMPNAM_CLASS_VAR, INT2FIX(id));
    sprintf(temp_name, "mpri:%d", id);

    // Omit "mpri:" from filename to form the key
    okay = SetImageRegistry(ImageRegistryType, temp_name+5, image, exception);
    CHECK_EXCEPTION()
    DestroyExceptionInfo(exception);
    if (!okay)
    {
        rb_raise(rb_eRuntimeError, "SetImageRegistry failed.");
    }

    RB_GC_GUARD(id_value);
}


/**
 * Delete the temporary image from the registry.
 *
 * No Ruby usage (internal function)
 *
 * @param temp_name the name of temporary image in the registry.
 */
void
rm_delete_temp_image(char *temp_name)
{
    MagickBooleanType okay = DeleteImageRegistry(temp_name+5);

    if (!okay)
    {
        rb_warn("DeleteImageRegistry failed for `%s'", temp_name);
    }
}


/**
 * Raise NotImplementedError.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Called when a xMagick API is not available.
 *   - Replaces Ruby's rb_notimplement function.
 *
 * @throw NotImpError
 */
void
rm_not_implemented(void)
{

    rb_raise(rb_eNotImpError, "the `%s' method is not supported by ImageMagick "
            MagickLibVersionText, rb_id2name(rb_frame_this_func()));
}


/**
 * Create a new ImageMagickError object and raise an exception.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - This funky technique allows me to safely add additional information to
 *     the ImageMagickError object in both 1.6.8 and 1.8.0.
 *
 * @param msg the error mesage
 * @throw ImageMagickError
 * @see www.ruby_talk.org/36408.
 */
void
rm_magick_error(const char *msg)
{
    VALUE exc, mesg;

    mesg = rb_str_new2(msg);

    exc = rb_funcall(Class_ImageMagickError, rm_ID_new, 2, mesg, Qnil);
    (void) rb_funcall(rb_cObject, rb_intern("raise"), 1, exc);

    RB_GC_GUARD(exc);
    RB_GC_GUARD(mesg);
}


/**
 * Initialize a new ImageMagickError object - store the "loc" string in the
 * \@magick_location instance variable.
 *
 * Ruby usage:
 *   - @verbatim ImageMagickError#initialize(msg) @endverbatim
 *   - @verbatim ImageMagickError#initialize(msg, loc) @endverbatim
 *
 * Notes:
 *   - Default loc is nil
 *
 * @param argc number of input arguments
 * @param argv array of input arguments
 * @param self this object
 * @return self
 */
VALUE
ImageMagickError_initialize(int argc, VALUE *argv, VALUE self)
{
    VALUE super_argv[1] = {(VALUE)0};
    int super_argc = 0;
    VALUE extra = Qnil;

    switch(argc)
    {
        case 2:
            extra = argv[1];
        case 1:
            super_argv[0] = argv[0];
            super_argc = 1;
        case 0:
            break;
        default:
            rb_raise(rb_eArgError, "wrong number of arguments (%d for 0 to 2)", argc);
    }

    (void) rb_call_super(super_argc, (const VALUE *)super_argv);
    (void) rb_iv_set(self, "@"MAGICK_LOC, extra);

    RB_GC_GUARD(extra);

    return self;
}


/**
 * Backport GetImageProperty for pre-6.3.1 versions of ImageMagick.
 *
 * No Ruby usage (internal function)
 *
 * @param img the image
 * @param property the property name
 * @return the property value
 */
const char *
rm_get_property(const Image *img, const char *property)
{
    return GetImageProperty(img, property);
}


/**
 * Backport SetImageProperty for pre-6.3.1 versions of ImageMagick.
 *
 * No Ruby usage (internal function)
 *
 * @param image the image
 * @param property the property name 
 * @param value the property value
 * @return true if successful, otherwise false
 */
MagickBooleanType
rm_set_property(Image *image, const char *property, const char *value)
{
    return SetImageProperty(image, property, value);
}


/**
 * If a "user" option is present in the Info, assign its value to a "user"
 * artifact in each image.
 *
 * No Ruby usage (internal function)
 *
 * @param images a list of images
 * @param info the info
 */
void rm_set_user_artifact(Image *images, Info *info)
{
    Image *image;
    const char *value;

    value = GetImageOption(info, "user");
    if (value)
    {
        image = GetFirstImageInList(images);
        while (image)
        {
            (void) SetImageArtifact(image, "user", value);
            image = GetNextImageInList(image);
        }
    }
}


/**
 * Collect optional method arguments via Magick::OptionalMethodArguments.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Creates an instance of Magick::OptionalMethodArguments, then yields to a
 *     block in the context of the instance.
 *
 * @param img the image
 */
void
rm_get_optional_arguments(VALUE img)
{
    VALUE optional_method_arguments;
    VALUE opt_args;
    VALUE argv[1];

    // opt_args = Magick::OptionalMethodArguments.new(img)
    // opt_args.instance_eval { block }
    if (rb_block_given_p())
    {
        optional_method_arguments = rb_const_get_from(Module_Magick, rb_intern("OptionalMethodArguments"));
        argv[0] = img;
        opt_args = rb_class_new_instance(1, argv, optional_method_arguments);
        (void) rb_obj_instance_eval(0, NULL, opt_args);
    }

    RB_GC_GUARD(optional_method_arguments);
    RB_GC_GUARD(opt_args);

    return;
}


/**
 * Copy image options from the Info structure to the Image structure.
 *
 * No Ruby usage (internal function)
 *
 * @param image the Image structure to modify
 * @param info the Info structure
 */
static void copy_options(Image *image, Info *info)
{
    char property[MaxTextExtent];
    const char *value, *option;

    ResetImageOptionIterator(info);
    for (option = GetNextImageOption(info); option; option = GetNextImageOption(info))
    {
        value = GetImageOption(info,option);
        if (value)
        {
            strncpy(property, value, MaxTextExtent);
            property[MaxTextExtent-1] = '\0';
            (void) SetImageArtifact(image, property, value);
        }
    }
}


/**
 * Propagate ImageInfo values to the Image
 *
 * No Ruby usage (internal function)
 *
 * @param image the Image structure to modify
 * @param info the Info structure
 * @see SyncImageSettings in mogrify.c in ImageMagick
 */
void rm_sync_image_options(Image *image, Info *info)
{
    MagickStatusType flags;
    GeometryInfo geometry_info;
    const char *option;

    // The option strings will be set only when their attribute values were
    // set in the optional argument block.
    option = GetImageOption(info,"background");
    if (option)
    {
        image->background_color = info->background_color;
    }

    option = GetImageOption(info,"bordercolor");
    if (option)
    {
        image->border_color = info->border_color;
    }

    if (info->colorspace != UndefinedColorspace)
    {
        SetImageColorspace(image, info->colorspace);
    }

    if (info->compression != UndefinedCompression)
    {
        image->compression = info->compression;
    }

    option = GetImageOption(info, "delay");
    if (option)
    {
        image->delay = strtoul(option, NULL, 0);
    }

    if (info->density)
    {
        flags = ParseGeometry(info->density, &geometry_info);
        image->x_resolution = geometry_info.rho;
        image->y_resolution = geometry_info.sigma;
        if ((flags & SigmaValue) == 0)
        {
            image->y_resolution = image->x_resolution;
        }
    }

    if (info->depth != 0)
    {
        image->depth = info->depth;
    }

    option = GetImageOption(info, "dispose");
    if (option)
    {
        image->dispose = rm_dispose_to_enum(option);
    }

    if (info->extract)
    {
        ParseAbsoluteGeometry(info->extract, &image->extract_info);
    }

    if (info->fuzz != 0.0)
    {
        image->fuzz = info->fuzz;
    }

    option = GetImageOption(info, "gravity");
    if (option)
    {
        image->gravity = rm_gravity_to_enum(option);
    }

    if (info->interlace != NoInterlace)
    {
        image->interlace = info->interlace;
    }

    option = GetImageOption(info,"mattecolor");
    if (option)
    {
        image->matte_color = info->matte_color;
    }

    if (info->orientation != UndefinedOrientation)
    {
        image->orientation = info->orientation;
    }

    if (info->page)
    {
        (void)ParseAbsoluteGeometry(info->page, &image->page);
    }

    if (info->quality != 0UL)
    {
        image->quality = info->quality;
    }

    option = GetImageOption(info, "scene");
    if (option)
    {
        image->scene = info->scene;
    }

    option = GetImageOption(info, "tile-offset");
    if (option)
    {
        (void)ParseAbsoluteGeometry(option, &image->tile_offset);
    }

    option = GetImageOption(info, "transparent");
    if (option)
    {
        image->transparent_color = info->transparent_color;
    }

    if (info->type != UndefinedType)
    {
        image->type = info->type;
    }

    if (info->units != UndefinedResolution)
    {
        if (image->units != info->units)
        {
            switch (image->units)
            {
              case PixelsPerInchResolution:
              {
                if (info->units == PixelsPerCentimeterResolution)
                {
                    image->x_resolution /= 2.54;
                    image->y_resolution /= 2.54;
                }
                break;
              }
              case PixelsPerCentimeterResolution:
              {
                if (info->units == PixelsPerInchResolution)
                {
                    image->x_resolution *= 2.54;
                    image->y_resolution *= 2.54;
                }
                break;
              }
              default:
                break;
            }
        }

        image->units = info->units;
    }

    copy_options(image, info);
}


/**
 * Replicate old (ImageMagick < 6.3.2) EXIF:* functionality using
 * GetImageProperty by returning the exif entries as a single string, separated
 * by \n's.  Do this so that RMagick.rb works no matter which version of
 * ImageMagick is in use.
 *
 * No Ruby usage (internal function)
 *
 * @param image the image
 * @return string representation of exif properties
 * @see magick/identify.c in ImageMagick
 */
VALUE
rm_exif_by_entry(Image *image)
{
    const char *property, *value;
    char *str;
    size_t len = 0, property_l, value_l;
    VALUE v;

    (void) GetImageProperty(image, "exif:*");
    ResetImagePropertyIterator(image);
    property = GetNextImageProperty(image);

    // Measure the exif properties and values
    while (property)
    {
        // ignore properties that don't start with "exif:"
        property_l = strlen(property);
        if (property_l > 5 && rm_strncasecmp(property, "exif:", 5) == 0)
        {
            if (len > 0)
            {
                len += 1;   // there will be a \n between property=value entries
            }
            len += property_l - 5;
            value = GetImageProperty(image,property);
            if (value)
            {
                // add 1 for the = between property and value
                len += 1 + strlen(value);
            }
        }
        property = GetNextImageProperty(image);
    }

    if (len == 0)
    {
        return Qnil;
    }
    str = xmalloc(len);
    len = 0;

    // Copy the exif properties and values into the string.
    ResetImagePropertyIterator(image);
    property = GetNextImageProperty(image);

    while (property)
    {
        property_l = strlen(property);
        if (property_l > 5 && rm_strncasecmp(property, "exif:", 5) == 0)
        {
            if (len > 0)
            {
                str[len++] = '\n';
            }
            memcpy(str+len, property+5, property_l-5);
            len += property_l - 5;
            value = GetImageProperty(image,property);
            if (value)
            {
                value_l = strlen(value);
                str[len++] = '=';
                memcpy(str+len, value, value_l);
                len += value_l;
            }
        }
        property = GetNextImageProperty(image);
    }

    v = rb_str_new(str, len);
    xfree(str);

    RB_GC_GUARD(v);

    return v;
}


/**
 * Replicate old (ImageMagick < 6.3.2) EXIF:! functionality using
 * GetImageProperty by returning the exif entries as a single string, separated
 * by \n's. Do this so that RMagick.rb works no matter which version of
 * ImageMagick is in use.
 *
 * No Ruby usage (internal function)
 *
 * @param image the image
 * @return string representation of exif properties
 * @see magick/identify.c in ImageMagick
 */
VALUE
rm_exif_by_number(Image *image)
{
    const char *property, *value;
    char *str;
    size_t len = 0, property_l, value_l;
    VALUE v;

    (void) GetImageProperty(image, "exif:!");
    ResetImagePropertyIterator(image);
    property = GetNextImageProperty(image);

    // Measure the exif properties and values
    while (property)
    {
        // ignore properties that don't start with "#"
        property_l = strlen(property);
        if (property_l > 1 && property[0] == '#')
        {
            if (len > 0)
            {
                len += 1;   // there will be a \n between property=value entries
            }
            len += property_l;
            value = GetImageProperty(image,property);
            if (value)
            {
                // add 1 for the = between property and value
                len += 1 + strlen(value);
            }
        }
        property = GetNextImageProperty(image);
    }

    if (len == 0)
    {
        return Qnil;
    }
    str = xmalloc(len);
    len = 0;

    // Copy the exif properties and values into the string.
    ResetImagePropertyIterator(image);
    property = GetNextImageProperty(image);

    while (property)
    {
        property_l = strlen(property);
        if (property_l > 1 && property[0] == '#')
        {
            if (len > 0)
            {
                str[len++] = '\n';
            }
            memcpy(str+len, property, property_l);
            len += property_l;
            value = GetImageProperty(image,property);
            if (value)
            {
                value_l = strlen(value);
                str[len++] = '=';
                memcpy(str+len, value, value_l);
                len += value_l;
            }
        }
        property = GetNextImageProperty(image);
    }

    v = rb_str_new(str, len);
    xfree(str);

    RB_GC_GUARD(v);

    return v;
}


/**
 * Get the values from a Geometry object and return them in C variables.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - No return value: modifies x, y, width, height, and flag
 *
 * @param geom the Geometry object
 * @param x pointer to the x position of the start of the rectangle
 * @param y pointer to the y position of the start of the rectangle
 * @param width pointer to the width of the rectangle
 * @param height pointer to the height of the rectangle
 * @param flag pointer to the Geometry's flag
 */
void
rm_get_geometry(
    VALUE geom,
    long *x,
    long *y,
    unsigned long *width,
    unsigned long *height,
    int *flag)
{
    VALUE v;

    v = rb_funcall(geom, rm_ID_x, 0);
    *x = NUM2LONG(v);
    v = rb_funcall(geom, rm_ID_y, 0);
    *y = NUM2LONG(v);
    v = rb_funcall(geom, rm_ID_width, 0);
    *width = NUM2ULONG(v);
    v = rb_funcall(geom, rm_ID_height, 0);
    *height = NUM2ULONG(v);

    // Getting the flag field is a bit more difficult since it's
    // supposed to be an instance of the GeometryValue Enum class. We
    // may not know the VALUE for the GeometryValue class, and we
    // need to check that the flag field is an instance of that class.
    if (flag)
    {
        MagickEnum *magick_enum;

        v = rb_funcall(geom, rm_ID_flag, 0);
        if (!Class_GeometryValue)
        {
            Class_GeometryValue = rb_const_get(Module_Magick, rm_ID_GeometryValue);
        }
        if (CLASS_OF(v) != Class_GeometryValue)
        {
            rb_raise(rb_eTypeError, "wrong enumeration type - expected %s, got %s"
                        , rb_class2name(Class_GeometryValue),rb_class2name(CLASS_OF(v)));
        }
        Data_Get_Struct(v, MagickEnum, magick_enum);
        *flag = magick_enum->val;
    }

}


/**
 * Clone an image, handle errors.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - Don't trace creation - the clone may not be used as an Image object. Let
 *     the caller do the trace if desired.
 *
 * @param image the image to clone
 * @return the cloned image
 */
Image *
rm_clone_image(Image *image)
{
    Image *clone;
    ExceptionInfo *exception;

    exception = AcquireExceptionInfo();
    clone = CloneImage(image, 0, 0, MagickTrue, exception);
    if (!clone)
    {
        rb_raise(rb_eNoMemError, "not enough memory to continue");
    }
    rm_check_exception(exception, clone, DestroyOnError);
    (void) DestroyExceptionInfo(exception);

    return clone;
}


/**
 * SetImage(Info)ProgressMonitor exit.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - ImageMagick's "tag" argument is unused. We pass along the method name
 *     instead.
 *
 * @param tag ImageMagick argument (unused)
 * @param of the offset type
 * @param sp the size type
 * @param client_data pointer to the progress method to call
 * @return true if calling client_data returns a non-nil value, otherwise false
 */
MagickBooleanType
rm_progress_monitor(
    const char *tag,
    const MagickOffsetType of,
    const MagickSizeType sp,
    void *client_data)
{
    VALUE rval;
    VALUE method, offset, span;

// Default Ruby minimum stack size
#define RUBY_VM_THREAD_MACHINE_STACK_SIZE_MIN (  16 * 1024 * sizeof(VALUE)) /*   64 KB or  128 KB */

    // Check stack length manually instead of ruby_stack_check() for old Ruby.
    if (ruby_stack_length(NULL) > RUBY_VM_THREAD_MACHINE_STACK_SIZE_MIN)
    {
        // If there is not enough stack or the using stack size shows an abnormal value in Ruby,
        // skip the callback and continue ImageMagick process.
        return MagickTrue;
    }

    tag = tag;      // defeat gcc message

#if defined(HAVE_LONG_LONG)     // defined in Ruby's defines.h
    offset = rb_ll2inum(of);
    span = rb_ull2inum(sp);
#else
    offset = rb_int2big((long)of);
    span = rb_uint2big((unsigned long)sp);
#endif

    method = rb_id2str(rb_frame_this_func());

    rval = rb_funcall((VALUE)client_data, rm_ID_call, 3, method, offset, span);

    RB_GC_GUARD(rval);
    RB_GC_GUARD(method);
    RB_GC_GUARD(offset);
    RB_GC_GUARD(span);

    return RTEST(rval) ? MagickTrue : MagickFalse;
}


/**
 * Remove the ImageMagick links between images in an scene sequence.
 *
 * No Ruby usage (internal function)
 *
 * Notes:
 *   - The images remain grouped via the ImageList
 *
 * @param image the image
 */
void
rm_split(Image *image)
{

    if (!image)
    {
        rb_bug("RMagick FATAL: split called with NULL argument.");
    }
    while (image)
    {
        (void) RemoveFirstImageFromList(&image);
    }
}


/**
 * If an ExceptionInfo struct in a list of images indicates a warning, issue a
 * warning message. If an ExceptionInfo struct indicates an error, raise an
 * exception and optionally destroy the images.
 *
 * No Ruby usage (internal function)
 *
 * @param imglist the list of images
 * @param retention retention strategy in case of an error (either RetainOnError
 * or DestroyOnError)
 */
void
rm_check_image_exception(Image *imglist, ErrorRetention retention)
{
    ExceptionInfo *exception;
    Image *badboy = NULL;
    Image *image;

    if (imglist == NULL)
    {
        return;
    }

    exception = AcquireExceptionInfo();

    // Find the image with the highest severity
    image = GetFirstImageInList(imglist);
    while (image)
    {
        if (image->exception.severity != UndefinedException)
        {
            if (!badboy || image->exception.severity > badboy->exception.severity)
            {
                badboy = image;
                InheritException(exception, &badboy->exception);
            }

            ClearMagickException(&image->exception);
        }
        image = GetNextImageInList(image);
    }

    if (badboy)
    {
        rm_check_exception(exception, imglist, retention);
    }

    (void) DestroyExceptionInfo(exception);
}


#define ERROR_MSG_SIZE 1024
/**
 * Formats the exception into the message buffer
 *
 * No Ruby usage (internal function)
 *
 * @param severity information about the severity of the error
 * @param reason the reason for the error
 * @param description description of the error
 * @param msg the buffer where the exception message should be formated in
 */
static void
format_exception(const ExceptionType severity, const char *reason, const char *description, char *msg)
{
    int len;
    memset(msg, 0, sizeof(ERROR_MSG_SIZE));

#if defined(HAVE_SNPRINTF)
    len = snprintf(msg, ERROR_MSG_SIZE, "%s%s%s",
#else
    len = sprintf(msg, "%.500s%s%.500s",
#endif
        GetLocaleExceptionMessage(severity, reason),
        description ? ": " : "",
        description ? GetLocaleExceptionMessage(severity, description) : "");

    msg[len] = '\0';
}


/**
 * Call handle_exception if there is an exception to handle.
 *
 * No Ruby usage (internal function)
 *
 * @param exception information about the exception
 * @param imglist the images that caused the exception
 * @param retention retention strategy in case of an error (either RetainOnError
 * or DestroyOnError)
 */
void
rm_check_exception(ExceptionInfo *exception, Image *imglist, ErrorRetention retention)
{
    if (exception->severity == UndefinedException)
    {
        return;
    }

    handle_exception(exception, imglist, retention);
}



/**
 * Called from ImageMagick for a warning.
 *
 * No Ruby usage (internal function)
 *
 * @param severity information about the severity of the warning (ignored)
 * @param reason the reason for the warning
 * @param description description of the warning
 */
void
rm_warning_handler(const ExceptionType severity, const char *reason, const char *description)
{
    rb_warning("RMagick: %s%s%s",
        GetLocaleExceptionMessage(severity, reason),
        description ? ": " : "",
        description ? GetLocaleExceptionMessage(severity, description) : "");
}


/**
 * Called from ImageMagick for a error.
 *
 * No Ruby usage (internal function)
 *
 * @param severity information about the severity of the error
 * @param reason the reason for the error
 * @param description description of the error
 */
void
rm_error_handler(const ExceptionType severity, const char *reason, const char *description)
{
    char msg[ERROR_MSG_SIZE];

    format_exception(severity, reason, description, msg);

    rm_magick_error(msg);
}


/**
 * Called from ImageMagick for a fatal error.
 *
 * No Ruby usage (internal function)
 *
 * @param severity information about the severity of the error
 * @param reason the reason for the error
 * @param description description of the error
 * @throw FatalImageMagickError
 */
void
rm_fatal_error_handler(const ExceptionType severity, const char *reason, const char *description)
{
    rb_raise(Class_FatalImageMagickError, "%s%s%s",
        GetLocaleExceptionMessage(severity, reason),
        description ? ": " : "",
        description ? GetLocaleExceptionMessage(severity, description) : "");
}


/**
 * Called when rm_check_exception determines that we need to either issue a
 * warning message or raise an exception. This function allocates a bunch of
 * stack so we don't call it unless we have to.
 *
 * No Ruby usage (internal function)
 *
 * @param exception information about the exception
 * @param imglist the images that caused the exception
 * @param retention retention strategy in case of an error (either RetainOnError
 * or DestroyOnError)
 */
static void
handle_exception(ExceptionInfo *exception, Image *imglist, ErrorRetention retention)
{
    char msg[ERROR_MSG_SIZE];

    // Handle simple warning
    if (exception->severity < ErrorException)
    {
        rm_warning_handler(exception->severity, exception->reason, exception->description);

        // Caller deletes ExceptionInfo...

        return;
    }

    // Raise an exception. We're not coming back...


    // Newly-created images should be destroyed, images that are part
    // of image objects should be retained but split.
    if (imglist)
    {
        if (retention == DestroyOnError)
        {
            (void) DestroyImageList(imglist);
            imglist = NULL;
        }
        else
        {
            rm_split(imglist);
        }
    }

    format_exception(exception->severity, exception->reason, exception->description, msg);

    (void) DestroyExceptionInfo(exception);

    rm_magick_error(msg);
}


/**
 * RMagick expected a result. If it got NULL instead raise an exception.
 *
 * No Ruby usage (internal function)
 *
 * @param image the expected result
 * @throw RuntimeError
 */
void
rm_ensure_result(Image *image)
{
    if (!image)
    {
        rb_raise(rb_eRuntimeError, MagickPackageName " library function failed to return a result.");
    }
}


/**
 * Checks if an error should be raised for the exception.
 *
 * No Ruby usage (internal function)
 *
 * @param exception information about the exception
 * @param retention retention strategy for the exception in case there was no error
 */
MagickBooleanType
rm_should_raise_exception(ExceptionInfo *exception, const ExceptionRetention retention)
{
    if (exception->severity < ErrorException)
    {
        if (exception->severity != UndefinedException)
        {
            rm_warning_handler(exception->severity, exception->reason, exception->description);
        }

        if (retention == DestroyExceptionRetention)
        {
            (void) DestroyExceptionInfo(exception);
        }

        return MagickFalse;
    }

    return MagickTrue;
}


/**
 * Raises an exception.
 *
 * No Ruby usage (internal function)
 *
 * @param exception information about the exception
 */
void
rm_raise_exception(ExceptionInfo *exception)
{
    char msg[ERROR_MSG_SIZE];

    format_exception(exception->severity, exception->reason, exception->description, msg);

    (void) DestroyExceptionInfo(exception);

    rm_magick_error(msg);
}


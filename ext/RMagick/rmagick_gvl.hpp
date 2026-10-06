#ifndef _RMAGICK_GVL_HPP_
#define _RMAGICK_GVL_HPP_

extern void   rm_gvl_init_offload(void);
extern void   rm_gvl_check_readable(const void *);
extern void   rm_gvl_check_writable(const void *);
extern Image *rm_gvl_offload_image(gvl_function_t *, void *, VALUE, ExceptionInfo *, VALUE = Qnil);
extern Image *rm_gvl_offload_image_replacing(gvl_function_t *, void *, VALUE, ExceptionInfo *, bool);
extern Image *rm_gvl_offload_image_and_destroy(gvl_function_t *, void *, VALUE, ExceptionInfo *, Image *, bool);
extern void  *rm_gvl_offload_call(gvl_function_t *, void *, VALUE, ExceptionInfo *, Image *);
extern void  *rm_gvl_offload_update(gvl_function_t *, void *, VALUE, ExceptionInfo *, VALUE = Qnil);
extern void  *rm_gvl_offload_blob(gvl_function_t *, void *, VALUE, ExceptionInfo *, VALUE = Qnil);
#if defined(IMAGEMAGICK_7)
extern Image *rm_gvl_offload_masked_image(gvl_function_t *, void *, VALUE, ExceptionInfo *, Image *, ChannelType, VALUE = Qnil);
#endif

#endif

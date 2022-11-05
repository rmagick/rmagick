#ifndef _RMAGICK_GVL_H_
#define _RMAGICK_GVL_H_

#include "ruby/thread.h"

typedef void *(gvl_function_t)(void *);

#define GVL_FUNC(name)        name##_gvl
#define GVL_STRUCT_TYPE(name) name##_args_t
#define CALL_FUNC_WITHOUT_GVL(fp, args) \
    rb_thread_call_without_gvl(fp, args, RUBY_UBF_PROCESS, NULL)


#define DEFINE_GVL_STRUCT1(name, type1) \
    typedef struct { \
        type1 arg1; \
    } GVL_STRUCT_TYPE(name)
#define DEFINE_GVL_FUNC1(func_name, struct_name) \
    static void *func_name##_gvl(void *p) \
    { \
        GVL_STRUCT_TYPE(struct_name) *args = (GVL_STRUCT_TYPE(struct_name) *)p; \
        return (void *)func_name(args->arg1); \
    }

#define DEFINE_GVL_STUB1(name, type1) \
    DEFINE_GVL_STRUCT1(name, type1); \
    DEFINE_GVL_FUNC1(name, name)


#define DEFINE_GVL_STRUCT2(name, type1, type2) \
    typedef struct { \
        type1 arg1; \
        type2 arg2; \
    } GVL_STRUCT_TYPE(name)
#define DEFINE_GVL_FUNC2(func_name, struct_name) \
    static void *func_name##_gvl(void *p) \
    { \
        GVL_STRUCT_TYPE(struct_name) *args = (GVL_STRUCT_TYPE(struct_name) *)p; \
        return (void *)func_name(args->arg1, args->arg2); \
    }

#define DEFINE_GVL_STUB2(name, type1, type2) \
    DEFINE_GVL_STRUCT2(name, type1, type2); \
    DEFINE_GVL_FUNC2(name, name)


#define DEFINE_GVL_STRUCT3(name, type1, type2, type3) \
    typedef struct { \
        type1 arg1; \
        type2 arg2; \
        type3 arg3; \
    } GVL_STRUCT_TYPE(name)
#define DEFINE_GVL_FUNC3(func_name, struct_name) \
    static void *func_name##_gvl(void *p) \
    { \
        GVL_STRUCT_TYPE(struct_name) *args = (GVL_STRUCT_TYPE(struct_name) *)p; \
        return (void *)func_name(args->arg1, args->arg2, args->arg3); \
    }

#define DEFINE_GVL_STUB3(name, type1, type2, type3) \
    DEFINE_GVL_STRUCT3(name, type1, type2, type3); \
    DEFINE_GVL_FUNC3(name, name)


#define DEFINE_GVL_STRUCT4(name, type1, type2, type3, type4) \
    typedef struct { \
        type1 arg1; \
        type2 arg2; \
        type3 arg3; \
        type4 arg4; \
    } GVL_STRUCT_TYPE(name)
#define DEFINE_GVL_FUNC4(func_name, struct_name) \
    static void *func_name##_gvl(void *p) \
    { \
        GVL_STRUCT_TYPE(struct_name) *args = (GVL_STRUCT_TYPE(struct_name) *)p; \
        return (void *)func_name(args->arg1, args->arg2, args->arg3, args->arg4); \
    }

#define DEFINE_GVL_STUB4(name, type1, type2, type3, type4) \
    DEFINE_GVL_STRUCT4(name, type1, type2, type3, type4); \
    DEFINE_GVL_FUNC4(name, name)


#define DEFINE_GVL_STRUCT5(name, type1, type2, type3, type4, type5) \
    typedef struct { \
        type1 arg1; \
        type2 arg2; \
        type3 arg3; \
        type4 arg4; \
        type5 arg5; \
    } GVL_STRUCT_TYPE(name)
#define DEFINE_GVL_FUNC5(func_name, struct_name) \
    static void *func_name##_gvl(void *p) \
    { \
        GVL_STRUCT_TYPE(struct_name) *args = (GVL_STRUCT_TYPE(struct_name) *)p; \
        return (void *)func_name(args->arg1, args->arg2, args->arg3, args->arg4, args->arg5); \
    }
#define DEFINE_GVL_STUB5(name, type1, type2, type3, type4, type5) \
    DEFINE_GVL_STRUCT5(name, type1, type2, type3, type4, type5); \
    DEFINE_GVL_FUNC5(name, name)


#define DEFINE_GVL_STRUCT6(name, type1, type2, type3, type4, type5, type6) \
    typedef struct { \
        type1 arg1; \
        type2 arg2; \
        type3 arg3; \
        type4 arg4; \
        type5 arg5; \
        type6 arg6; \
    } GVL_STRUCT_TYPE(name)
#define DEFINE_GVL_FUNC6(func_name, struct_name) \
    static void *func_name##_gvl(void *p) \
    { \
        GVL_STRUCT_TYPE(struct_name) *args = (GVL_STRUCT_TYPE(struct_name) *)p; \
        return (void *)func_name(args->arg1, args->arg2, args->arg3, args->arg4, args->arg5, args->arg6); \
    }
#define DEFINE_GVL_STUB6(name, type1, type2, type3, type4, type5, type6) \
    DEFINE_GVL_STRUCT6(name, type1, type2, type3, type4, type5, type6); \
    DEFINE_GVL_FUNC6(name, name)


#define DEFINE_GVL_STRUCT7(name, type1, type2, type3, type4, type5, type6, type7) \
    typedef struct { \
        type1 arg1; \
        type2 arg2; \
        type3 arg3; \
        type4 arg4; \
        type5 arg5; \
        type6 arg6; \
        type7 arg7; \
    } GVL_STRUCT_TYPE(name)
#define DEFINE_GVL_FUNC7(func_name, struct_name) \
    static void *func_name##_gvl(void *p) \
    { \
        GVL_STRUCT_TYPE(struct_name) *args = (GVL_STRUCT_TYPE(struct_name) *)p; \
        return (void *)func_name(args->arg1, args->arg2, args->arg3, args->arg4, args->arg5, args->arg6, args->arg7); \
    }
#define DEFINE_GVL_STUB7(name, type1, type2, type3, type4, type5, type6, type7) \
    DEFINE_GVL_STRUCT7(name, type1, type2, type3, type4, type5, type6, type7); \
    DEFINE_GVL_FUNC7(name, name)


#define DEFINE_GVL_STRUCT8(name, type1, type2, type3, type4, type5, type6, type7, type8) \
    typedef struct { \
        type1 arg1; \
        type2 arg2; \
        type3 arg3; \
        type4 arg4; \
        type5 arg5; \
        type6 arg6; \
        type7 arg7; \
        type8 arg8; \
    } GVL_STRUCT_TYPE(name)
#define DEFINE_GVL_FUNC8(func_name, struct_name) \
    static void *func_name##_gvl(void *p) \
    { \
        GVL_STRUCT_TYPE(struct_name) *args = (GVL_STRUCT_TYPE(struct_name) *)p; \
        return (void *)func_name(args->arg1, args->arg2, args->arg3, args->arg4, args->arg5, args->arg6, args->arg7, args->arg8); \
    }
#define DEFINE_GVL_STUB8(name, type1, type2, type3, type4, type5, type6, type7, type8) \
    DEFINE_GVL_STRUCT8(name, type1, type2, type3, type4, type5, type6, type7, type8); \
    DEFINE_GVL_FUNC8(name, name)


#define DEFINE_GVL_STRUCT9(name, type1, type2, type3, type4, type5, type6, type7, type8, type9) \
    typedef struct { \
        type1 arg1; \
        type2 arg2; \
        type3 arg3; \
        type4 arg4; \
        type5 arg5; \
        type6 arg6; \
        type7 arg7; \
        type8 arg8; \
        type9 arg9; \
    } GVL_STRUCT_TYPE(name)
#define DEFINE_GVL_FUNC9(func_name, struct_name) \
    static void *func_name##_gvl(void *p) \
    { \
        GVL_STRUCT_TYPE(struct_name) *args = (GVL_STRUCT_TYPE(struct_name) *)p; \
        return (void *)func_name(args->arg1, args->arg2, args->arg3, args->arg4, args->arg5, args->arg6, args->arg7, args->arg8, args->arg9); \
    }
#define DEFINE_GVL_STUB9(name, type1, type2, type3, type4, type5, type6, type7, type8, type9) \
    DEFINE_GVL_STRUCT9(name, type1, type2, type3, type4, type5, type6, type7, type8, type9); \
    DEFINE_GVL_FUNC9(name, name)


#define DEFINE_GVL_VOID_FUNC2(func_name, struct_name) \
    static void *func_name##_gvl(void *p) \
    { \
        GVL_STRUCT_TYPE(struct_name) *args = (GVL_STRUCT_TYPE(struct_name) *)p; \
        func_name(args->arg1, args->arg2); \
        return NULL; \
    }
#define DEFINE_GVL_VOID_STUB2(name, type1, type2) \
    DEFINE_GVL_STRUCT2(name, type1, type2); \
    DEFINE_GVL_VOID_FUNC2(name, name)


#define DEFINE_GVL_VOID_FUNC3(func_name, struct_name) \
    static void *func_name##_gvl(void *p) \
    { \
        GVL_STRUCT_TYPE(struct_name) *args = (GVL_STRUCT_TYPE(struct_name) *)p; \
        func_name(args->arg1, args->arg2, args->arg3); \
        return NULL; \
    }
#define DEFINE_GVL_VOID_STUB3(name, type1, type2, type3) \
    DEFINE_GVL_STRUCT3(name, type1, type2, type3); \
    DEFINE_GVL_VOID_FUNC3(name, name)


#define DEFINE_GVL_VOID_FUNC6(func_name, struct_name) \
    static void *func_name##_gvl(void *p) \
    { \
        GVL_STRUCT_TYPE(struct_name) *args = (GVL_STRUCT_TYPE(struct_name) *)p; \
        func_name(args->arg1, args->arg2, args->arg3, args->arg4, args->arg5, args->arg6); \
        return NULL; \
    }
#define DEFINE_GVL_VOID_STUB6(name, type1, type2, type3, type4, type5, type6) \
    DEFINE_GVL_STRUCT6(name, type1, type2, type3, type4, type5, type6); \
    DEFINE_GVL_VOID_FUNC6(name, name)

#endif

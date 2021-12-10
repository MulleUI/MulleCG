#ifndef _mulle_cg_backend_h__
#define _mulle_cg_backend_h__

// TODO: unify with CG_GLES et al-
#define MULLE_CG_GL      1
#define MULLE_CG_GLES2   2
#define MULLE_CG_GLES3   3
//#define MULLE_CG_VULKAN  4

// change the "backend" to use
#ifndef MULLE_CG_GLVERSION
# define MULLE_CG_GLVERSION   MULLE_CG_GLES3
#endif


#if MULLE_CG_GLVERSION == MULLE_CG_GLES2
# define GLFW_INCLUDE_ES2
# ifdef DEFINE_NANOVG_GL_IMPLEMENTATION
#  define NANOVG_GLES2_IMPLEMENTATION
# endif
#endif

#if MULLE_CG_GLVERSION == MULLE_CG_GLES3
# define GLFW_INCLUDE_ES3
# ifdef DEFINE_NANOVG_GL_IMPLEMENTATION
#  define NANOVG_GLES3_IMPLEMENTATION
# endif
#endif

#if MULLE_CG_GLVERSION == MULLE_CG_GL
// GLFW_INCLUDE_... keep undefined for OpenGL3
// see: https://www.glfw.org/docs/latest/build_guide.html
# ifdef DEFINE_NANOVG_GL_IMPLEMENTATION
#  define NANOVG_GL3_IMPLEMENTATION
# endif
#endif

#endif

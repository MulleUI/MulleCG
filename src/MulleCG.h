#import "import.h"

#define MULLE_CG_VERSION   ((0 << 20) | (0 << 8) | 1)

#import "_MulleCG-export.h"

#include "_MulleCG-provide.h"


static inline char  *MulleCGBackendHeaderUTF8String( void)
{
   return(
#ifdef __APPLE__
   "Apple"
# if defined( MULLE_CG_USE_APPLE_MACROS)
   "+OpenGL+CGLMacro"
# else
#  if MULLE_CG_HAVE_DEPRECATED_OPENGL
   "+gl"
#  endif
#  if defined( MULLE_CG_USE_APPLE_GL_EXT)
   "+glext"
#  endif
#  if MULLE_CG_HAVE_MODERN_OPENGL
   "+gl3"
#  endif
# endif
#else
   "Generic"
# if MULLE_CG_GLVERSION == MULLE_CG_GL3_2 || MULLE_CG_GLVERSION == MULLE_CG_GL3
   "+gl3+glext"
# elif MULLE_CG_GLVERSION == MULLE_CG_GLES2
   "+gl2+gl2ext"
# elif MULLE_CG_GLVERSION == MULLE_CG_GLES3
   "+gl3+gl3ext"
# elif MULLE_CG_GLVERSION == MULLE_CG_GLES3_2
   "+gl32+gl3ext"
# elif MULLE_CG_GLVERSION == MULLE_CG_GLES3_2
   "???"
# endif
#endif
   );
}


#ifdef __has_include
# if __has_include( "_MulleCG-versioncheck.h")
#  include "_MulleCG-versioncheck.h"
# endif
#endif


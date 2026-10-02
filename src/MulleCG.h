//
//  MulleCG.h
//  MulleCG
//
//  Copyright (c) 2021 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#import "import.h"

#define HAVE_IMPORT__MULLE_CG

#define MULLE_CG_VERSION   ((0UL << 20) | (2 << 8) | 0)

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


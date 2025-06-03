//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


// In OpenGL a shader (vertex/fragment) is part of a "program",
// this is really what CGShaderID is..

@interface CGContext( OpenGLShader)

   // inconvenient interface (shaders will still be registered by name)
   // if compile/link didn't work you get 0 as an error
- (CGShaderID) _compileShaderWithShaderSources:(struct CGShaderUTF8Sources *) source;

- (void) _useShader:(CGShaderID) shaderID;

- (void) _deleteShader:(CGShaderID) shaderID;

- (char *) shaderHeaderUTF8String;

@end

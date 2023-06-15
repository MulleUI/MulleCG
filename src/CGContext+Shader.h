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

@interface CGContext( Shader)

// preferred interface. register sources globally and useShaders by
// their name  (if unknown returns 0)
- (CGShaderID) useShaderWithNameUTF8String:(char *) name;

// manually managing shaders might not be useful on a per-frame basis
- (void) deleteShaderWithNameUTF8String:(char *) name;
- (void) deleteShaders;

// inconvenient interface (shaders will still be registered by name)
// if compile/link didn't work you get 0 as an error
- (CGShaderID) compileShaderWithShaderSources:(struct CGShaderUTF8Sources *) source;
- (CGShaderID) compileShaderWithNameUTF8String:(char *) name;

// will compile on demand
- (CGShaderID) shaderWithNameUTF8String:(char *) name;
// will not compile on demand
- (CGShaderID) _shaderWithNameUTF8String:(char *) name;
- (void) useShader:(CGShaderID) shaderID;
- (void) deleteShader:(CGShaderID) shaderID;

- (char *) shaderHeaderUTF8String;

@end

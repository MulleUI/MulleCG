//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
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



//
//
+ (void) registerShaderSources:(struct CGShaderUTF8Sources *) sources;
+ (void) registerShaderSources:(struct CGShaderUTF8Sources *) sources
             forNameUTF8String:(char *) nameUTF8String;

- (struct CGShaderUTF8Sources *)
   registeredShaderSourcesForNameUTF8String:(char *) nameUTF8String;
@end


@interface CGContext( Future) < MulleObjCFuture>

- (char *) shaderHeaderUTF8String;

- (CGShaderID) _compileShaderWithShaderSources:(struct CGShaderUTF8Sources *) source;

- (void) _useShader:(CGShaderID) shaderID;

- (void) _deleteShader:(CGShaderID) shaderID;

- (char *) shaderHeaderUTF8String;

@end

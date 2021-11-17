//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


@interface CGContext( OpenGL)

- (NSUInteger) compileVertexShader:(char *) vertexShaderCode
                    fragmentShader:(char *) fragmentShaderCode
                    nameUTF8String:(char *) name;
                      
@end

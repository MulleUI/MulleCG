//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"



//
// This interface is for internal use of CGImage and CGLayer. The CGImage
// becomes a OpenGL texture via nanovg, which abstracts it into a handle
// which is the `textureID`. The `textureID´ can be converted into a `GPUTexture`
// for direct use with OpenGL. You wouldn't do this manually though, but use
// -bindImage:toTextureUnit: instead, if you were to draw with OpenGL directly.
// With nvg you use the CGTextureID.
//

@interface CGContext( Texture)

- (CGTextureID) textureIDWithBytes:(void *) bytes
                        bitmapSize:(struct MulleIntegerSize) size
                        imageFlags:(NSUInteger) imageFlags;
- (CGTextureID) textureIDWithFileCData:(struct mulle_data) fileCData
                            imageFlags:(NSUInteger) imageFlags;
- (CGTextureID) textureIDWithContentsOfFileCString:(char *) filename
                                      imageFlags:(NSUInteger) imageFlags;
- (CGTextureID) textureIDWithGPUTextureRGBA:(void *) gpuTexture
                                 bitmapSize:(struct MulleIntegerSize) size
                                 imageFlags:(NSUInteger) imageFlags;

- (void) deleteTextureID:(CGTextureID) textureID;

// used by shared textures only
- (void) forgetTextureID:(CGTextureID) textureID;


- (void) deleteFramebuffer:(void *) framebuffer;

@end

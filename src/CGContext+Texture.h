//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


// these typedef makes things a little easier to read
typedef void   *CGGPUTextureID;

// could also use a struct here, but then you meet sir castalot
typedef void    CGGPUFramebuffer;

//
// This interface is for internal use of CGImage and CGFramebuffer. The CGImage
// becomes a OpenGL texture via nanovg, which abstracts it into a handle
// which is the `textureID`. The `textureID´ can be converted into a `GPUTexture`
// for direct use with OpenGL. You wouldn't do this manually though, but use
// -bindImage:toTextureUnit: instead, if you were to draw with OpenGL directly.
// With nvg you use the CGTextureID.
//

//
// function will be implemented by +nanovg so this is a "future" @interface
//
@interface CGContext( TextureFuture) < MulleObjCFuture>

- (CGTextureID) textureIDWithRGBABytes:(void *) bytes
                        bitmapSize:(CGPixelSize) size
                      textureFlags:(NSUInteger) textureFlags;
- (CGTextureID) textureIDWithFileCData:(struct mulle_data) fileCData
                          textureFlags:(NSUInteger) textureFlags;
- (CGTextureID) textureIDWithContentsOfFileUTF8String:(char *) filename
                                    textureFlags:(NSUInteger) textureFlags;
- (CGTextureID) textureIDWithGPUTexture:(CGGPUTextureID) gpuTexture
                             bitmapSize:(CGPixelSize) size
                           textureFlags:(NSUInteger) textureFlags;

- (void) deleteTextureID:(CGTextureID) textureID;

// used by shared textures only
- (void) forgetTextureID:(CGTextureID) textureID;


- (void) deleteGPUFramebuffer:(CGGPUFramebuffer *) gpuFramebuffer;


- (CGGPUTextureID) gpuTextureForTextureID:(CGTextureID) textureID;

- (void) setRGBABytes:(void *) bytes
         forTextureID:(CGTextureID) textureID;

- (CGPixelSize) bitmapSizeForTextureID:(CGTextureID) textureID;

@end

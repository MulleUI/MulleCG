//
//  CGContext+Texture.h
//  MulleCG
//
//  Copyright (c) 2023 Nat! - Mulle kybernetiK.
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

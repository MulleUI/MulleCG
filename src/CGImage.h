#import "CGPaint.h"

#import "CGDrawable.h"

#import "CGContext.h" // needed for protocol

#import "CGContext+Texture.h" // needed for protocol

#include "microvg.h"

//
//                             .------------.
//                             | CGDrawable |
//                             '------------'
//  .---------.                       |
//  | CGImage |----------.            |
//  '---------'          |            |
//       |               |            |
//       |               |            |
//       |               |            |
//       |               v            |
//       |     .------------------.   |
//       |     | CGBitmapDrawable |<--'
//       |     '------------------'
//       |
//       v
//  .---------.
//  | CGLayer |
//  '---------'
//


//
// Container for the OpenGL textureID, it's merely used for retain
// counting. Therefore it must never be autoreleased!
//
@interface CGSharedGPUTexture : NSObject

@property( readonly, assign) void  *gpuTexture;

- (instancetype) initWithGPUTexture:(void *) gpuTexture;

@end


// Generally try to create CGImages with the functionality found in
// CGContext+CGImage, as you then don't have to worry about creating to many
// textures.
// -------
// This is a wrapper for all the nanovg image functionality. Because we use
// "image" also as CGImage, nanovg image handles are called here "textureID"
// and the underlying OpenGL texture is the "gpuTexture".
//
// Such a CGImage lives in the graphics context. The image bytes are not
// accessible. The image dies functionally at the very least, when the
// context dies (or when it gets finalized). You can not use it (by pointer)
// in another context. If you want to do more, use UIImage. You can only
// create CGImages when a context is active (i.e. rendering usually).
// It's tricky, so you are generally better off with UIImage for image
// management.
//
// You can keep a CGImage between render passes though. You can not use it in a
// different context!
//
// Textures (images) in NVG can be created with different flags, for example
// REPEAT_X and REPEAT_Y. When we are asking the CGContext for a textureID
// for an image this will create such a NVG texture. As the context caches the
// textureID for each MulleImage it's simplest to store the textureFlags here
// (readonly) and to clone CGImages for different flags. The actual image
// data can be shared w/o a problem. The default is 0:
//
@interface CGImage : CGPaint <CGBitmapDrawable, CGContextResource>

// usually don't use textureID, use nvgImageWithContext:textureFlags:
@property( readonly, assign) CGTextureID          textureID;
@property( readonly, assign) NSUInteger           textureFlags;
@property( readonly, assign) CGContext            *context;
@property( readonly, retain) CGSharedGPUTexture   *sharedGPUTexture;
@property NSUInteger                              debugEnabled;
@property char                                    *debugNameUTF8String;  // useful for debugging

// textureFlags in this call is "informative", it will not affect the image
// as it has been created already
- (instancetype) initWithTextureID:(CGTextureID) textureID
                      textureFlags:(NSUInteger) textureFlags
                           context:(CGContext *) context;

- (instancetype) initWithGPUTextureRGBA:(void *) gpuTexture
                       sharedGPUTexture:(CGSharedGPUTexture *) sharedGPUTexture
                             bitmapSize:(struct MulleIntegerSize) size
                           textureFlags:(NSUInteger) textureFlags
                                context:(CGContext *) context;

// these methods are germane to CGImage, subclasses may not support this
// I wanted to avoid inserting another class here
// textureFlags will affect the texture
- (instancetype) initWithContentsOfFileCString:(char *) filename
                                  textureFlags:(NSUInteger) textureFlags
                                       context:(CGContext *) context;

// data can be discarded after init
- (instancetype) initWithFileCData:(struct mulle_data) fileCData
                      textureFlags:(NSUInteger) textureFlags
                           context:(CGContext *) context;

// bytes are not retained, you can free them after init
- (instancetype) initWithRGBABytes:(void *) bytes
                        bitmapSize:(struct MulleIntegerSize) bitmapSize
                      textureFlags:(NSUInteger) textureFlags
                           context:(CGContext *) context;

// bitmap bytes are not retained, you can free them after init
- (instancetype) initWithBitmap:(struct CGBitmap) bitmap
                   textureFlags:(NSUInteger) textureFlags
                        context:(CGContext *) context;

//
// CGImage size is not mutable, if the bitmap size changes
// you need to create a new CGImage. The bytes can be freed by the
// caller afterwards. The bytes are pushed to the GPU immediately.
// This will affect all copies(!) of this CGImage!
//
- (void) setBytes:(void *) bytes;

- (struct MulleIntegerSize)  bitmapSize;

- (struct CGBitmap) RGBABytesBitmap:(struct mulle_allocator *) allocator;

- (void *) gpuTexture;

// multisample images can not be used as paint, use resolvedImage
- (BOOL) isMultiSample;

// always self, unless isMultiSample is set in which case this will abort
// only CGLayer actually has resolvedImage
- (CGImage *) resolvedImage;

//
// If otherContext is sharing textures with the CGImage context, we can
// share the texture by creating a nvg image copy in otherContext. otherContext
// needs to be active. May return nil, if the copying is not possible.
//
// Make sure that image is completely drawn by the GPU before calling this.
// (use [CGContext barrier])
- (id) shareWithContext:(id) otherContext;

@end

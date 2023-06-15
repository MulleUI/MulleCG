#import "CGDrawable.h"

#import "CGContext.h" // needed for protocol


#import "CGContext+Texture.h" // needed for protocol

#include "millivg.h"

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



//
// This is a wrapper for all the nanovg image functionality.
// Such an image lives in the graphics context. The image bytes are not
// accessible. The image dies functionally at the very least, when the
// context dies (or when it gets finalized). You can not share it with another
// context. If you want to do more, use UIImage. You can only create it
// during rendering! It's tricky, you are generally better off with UIImage
// for image management.
//
// You can keep it between render passes though. You can not use it in a
// different context!
//
// Textures (images) in NVG can be created with different flags, for example
// REPEAT_X and REPEAT_Y. When we are asking the CGContext for a textureID
// for an image this will create such a NVG texture. As the context cashes the
// textureID for each MulleImage it's simplest to store the imageFlags here
// (readonly) and to clone MulleImages for different flags. The actual image
// data can be shared w/o a problem. The default is 0:
//
// textureIDs are strictly ascending, create() -> 1; close(1); create() -> 2
// and aren't reused.
//
@interface CGImage : NSObject <CGBitmapDrawable, CGContextResource>

// usually don't use textureID, use nvgImageWithContext:imageFlags:
@property( readonly, assign) CGTextureID          textureID;
@property( readonly, assign) NSUInteger           imageFlags;       // rename sometime
@property( readonly, assign) CGContext            *context;
@property( readonly, retain) CGSharedGPUTexture   *sharedGPUTexture;


// imageFlags in this call is "informative", it will not affect the image
// as it has been created already
- (instancetype) initWithTextureID:(CGTextureID) textureID
                        imageFlags:(NSUInteger) imageFlags
                           context:(CGContext *) context;

- (instancetype) initWithGPUTextureRGBA:(void *) gpuTexture
                       sharedGPUTexture:(CGSharedGPUTexture *) sharedGPUTexture
                             bitmapSize:(struct MulleIntegerSize) size
                             imageFlags:(NSUInteger) imageFlags
                                context:(CGContext *) context;

// these methods are germane to CGImage, subclasses may not support this
// I wanted to avoid inserting another class here
// imageFlags will affect the texture
- (instancetype) initWithContentsOfFileCString:(char *) filename
                                    imageFlags:(NSUInteger) imageFlags
                                       context:(CGContext *) context;

// data can be discarded after init
- (instancetype) initWithFileCData:(struct mulle_data) fileCData
                        imageFlags:(NSUInteger) imageFlags
                           context:(CGContext *) context;

// bytes are not retained, you can free them after init
- (instancetype) initWithRGBABytes:(void *) bytes
                        bitmapSize:(struct MulleIntegerSize) bitmapSize
                        imageFlags:(NSUInteger) imageFlags
                           context:(CGContext *) context;

// bitmap bytes are not retained, you can free them after init
- (instancetype) initWithBitmap:(struct CGBitmap) bitmap
                     imageFlags:(NSUInteger) imageFlags
                        context:(CGContext *) context;

// CGImage size is not mutable, if the bitmap size changes
// you need to create a new CGImage. The bytes can be freed by the
// caller afterwards. The bytes are pushed to the GPU immediately.
//
- (void) setBytes:(void *) bytes;

- (struct MulleIntegerSize)  bitmapSize;

- (struct CGBitmap) RGBABytesBitmap:(struct mulle_allocator *) allocator;

- (void *) gpuTexture;

//
// If otherContext is sharing textures with the CGImage context, we can
// share the texture by creating a nvg image copy in otherContext. otherContext
// needs to be active. May return nil, if the copying is not possible.
//
// Make sure that image is completely drawn by the GPU before calling this.
// (use [CGContext barrier])
- (id) shareWithContext:(id) otherContext;

@end

#import "CGPaint.h"

#import "CGDrawable.h"

#import "CGContext.h" // needed for protocol

#import "CGContext+Texture.h" // needed for protocol

#include "nanowrap.h"

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
//  | CGFramebuffer |
//  '---------'
//


//
// Container for the OpenGL textureID, it's used for sharing textures across
// multiple contexts and threads.
//
@interface CGSharedGPUTexture : NSObject < MulleObjCThreadSafe >

@property( readonly, assign) CGGPUTextureID  gpuTexture;

- (instancetype) initWithGPUTexture:(CGGPUTextureID) gpuTexture;

@end


// Generally try to create CGImages with the functionality found in
// CGContext+CGImage, as you then don't have to worry about creating too many
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
@interface CGImage : CGPaint <CGBitmapDrawable, CGContextResource, MulleUINamedObject>

// usually don't use textureID, use nvgImageWithContext:textureFlags:
@property( readonly, assign) CGTextureID          textureID;
@property( readonly, assign) NSUInteger           textureFlags;
@property( readonly, assign) CGContext            *context;

//
// CGImage size is not mutable, if the bitmap size changes
// you need to create a new CGImage. The bytes can be freed by the
// caller afterwards. The bytes are pushed to the GPU immediately.
// This will affect all copies(!) of this CGImage!
//
@property( readonly, assign) CGPixelSize          bitmapSize;

// this will be nil, if the context has no shareID
@property( readonly, retain) CGSharedGPUTexture   *sharedGPUTexture;
@property( readonly, assign) NSUInteger           debuggingFlags   MULLE_OBJC_THREADSAFE_PROPERTY;

// this is only truely threadsafe if you set it just after init
// it can only be set once
@property( readonly) char                         *nameUTF8String  MULLE_OBJC_THREADSAFE_PROPERTY;  // useful for debugging


// Convenience constructors for texture ID initialization
+ (instancetype) imageWithTextureID:(CGTextureID) textureID
                         bitmapSize:(CGPixelSize) bitmapSize
                       textureFlags:(NSUInteger) textureFlags
                             context:(CGContext *) context;

// Convenience constructors for GPU texture initialization
+ (instancetype) imageWithGPUTexture:(CGGPUTextureID) gpuTexture
                          bitmapSize:(CGPixelSize) size
                        textureFlags:(NSUInteger) textureFlags
                             context:(CGContext *) context;

+ (instancetype) imageWithSharedGPUTexture:(CGSharedGPUTexture *) sharedGPUTexture
                                bitmapSize:(CGPixelSize) size
                              textureFlags:(NSUInteger) textureFlags
                                    context:(CGContext *) context;

// Convenience constructors for file-based initialization
+ (instancetype) imageWithContentsOfFileUTF8String:(char *) filename
                                      textureFlags:(NSUInteger) textureFlags
                                           context:(CGContext *) context;

// Convenience constructors for data-based initialization
+ (instancetype) imageWithFileCData:(struct mulle_data) fileCData
                       textureFlags:(NSUInteger) textureFlags
                            context:(CGContext *) context;

// Convenience constructors for byte-based initialization
+ (instancetype) imageWithRGBABytes:(void *) bytes
                        bitmapSize:(CGPixelSize) bitmapSize
                      textureFlags:(NSUInteger) textureFlags
                            context:(CGContext *) context;

// Convenience constructors for bitmap-based initialization
+ (instancetype) imageWithBitmap:(struct CGBitmap) bitmap
                    textureFlags:(NSUInteger) textureFlags
                         context:(CGContext *) context;

// textureFlags in this call is "informative", it will not affect the image
// as it has been created already
- (instancetype) initWithTextureID:(CGTextureID) textureID
                        bitmapSize:(CGPixelSize) bitmapSize
                      textureFlags:(NSUInteger) textureFlags
                    nameUTF8String:(char *) nameUTF8String
                           context:(CGContext *) context;

// use this for contexts with no sharing enabled. If sharing is enabled
// you can access a -sharedGPUTexture if sharing is enabled by the context
- (instancetype) initWithGPUTexture:(CGGPUTextureID) gpuTexture
                         bitmapSize:(CGPixelSize) size
                       textureFlags:(NSUInteger) textureFlags
                     nameUTF8String:(char *) nameUTF8String
                            context:(CGContext *) context;

// use this for contexts to share textures with another image
- (instancetype) initWithSharedGPUTexture:(CGSharedGPUTexture *) sharedGPUTexture
                               bitmapSize:(CGPixelSize) size
                             textureFlags:(NSUInteger) textureFlags
                           nameUTF8String:(char *) nameUTF8String
                                  context:(CGContext *) context;

// these methods are germane to CGImage, subclasses may not support this
// I wanted to avoid inserting another class here
// textureFlags will affect the texture
- (instancetype) initWithContentsOfFileUTF8String:(char *) filename
                                     textureFlags:(NSUInteger) textureFlags
                                   nameUTF8String:(char *) nameUTF8String
                                          context:(CGContext *) context;

- (instancetype) initWithContentsOfFileUTF8String:(char *) filename
                                     textureFlags:(NSUInteger) textureFlags
                                          context:(CGContext *) context;

// data can be discarded after init
- (instancetype) initWithFileCData:(struct mulle_data) fileCData
                      textureFlags:(NSUInteger) textureFlags
                    nameUTF8String:(char *) nameUTF8String
                           context:(CGContext *) context;

// bytes are not retained, you can free them after init
- (instancetype) initWithRGBABytes:(void *) bytes
                        bitmapSize:(CGPixelSize) bitmapSize
                      textureFlags:(NSUInteger) textureFlags
                    nameUTF8String:(char *) nameUTF8String
                           context:(CGContext *) context;

- (instancetype) initWithRGBABytes:(void *) bytes
                        bitmapSize:(CGPixelSize) bitmapSize
                      textureFlags:(NSUInteger) textureFlags
                           context:(CGContext *) context;

// bitmap bytes are not retained, you can free them after init
- (instancetype) initWithBitmap:(struct CGBitmap) bitmap
                   textureFlags:(NSUInteger) textureFlags
                 nameUTF8String:(char *) nameUTF8String
                        context:(CGContext *) context;

// convenience for many old demos
- (instancetype) initWithBitmap:(struct CGBitmap) bitmap
                   textureFlags:(NSUInteger) textureFlags
                        context:(CGContext *) context;

// just retains if CGImage
- (id) copy;

// creates a CGFramebuffer from CGImage
- (id) mutableCopy;


- (struct CGBitmap) RGBABytesBitmap:(struct mulle_allocator *) allocator;

// multisample images can not be used as paint, use resolvedImage
- (BOOL) isMultiSample        MULLE_OBJC_THREADSAFE_METHOD;

// always self, unless isMultiSample is set in which case this will abort
// only CGFramebuffer actually has resolvedImage
- (CGImage *) resolvedImage;

- (instancetype) shareWithContext:(CGContext *) context
                     textureFlags:(NSUInteger) textureFlags  MULLE_OBJC_THREADSAFE_METHOD;


@end

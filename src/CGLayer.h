#import "CGImage.h"


@class CGContext;
struct CGFrameInfo;

// TODO: rename this
// Better name: CGFramebufferImage ?

// TODO: memo handle PixelBufferObjects too ?

// This used to be called MulleTextureImage, which fits better, but the
// historic name is CGLayer. It has nothing to do with a CALayer though.
//
//
// An drawing rendered into a texture.
// In technical terms a wrapper for a texture created with
// nvgluCreateFramebuffer (usually). A texture can not be created during
// rendering. It has to be done before or after.
//
// The texture lives at most as long as the CGContext is active. If the context
// vanishes, the texture is invalid. So that means that when the context
// finalizes it also needs to finalize the texture.
//
// The CGContext keeps track of all texture images, but doesn't retain them.
// When the time comes, it calls -finalize on all texture images.
//
@interface CGLayer : CGImage

@property( readonly, assign) void   *framebuffer;
@property char                      *debugNameUTF8String;  // useful for debugging

+ (instancetype) layerWithIntegerSize:(struct MulleIntegerSize) size
                          imageFlags:(NSUInteger) imageFlags
                             context:(CGContext *) context;

- (instancetype) initWithIntegerSize:(struct MulleIntegerSize) size
                         imageFlags:(NSUInteger) imageFlags
                            context:(CGContext *) context;

// more or less for completeness... probably makes no sense
- (instancetype) initWithImage:(CGImage *) image
                    imageFlags:(NSUInteger) imageFlags
                       context:(CGContext *) context;


- (struct CGBitmap) RGBABytesBitmap:(struct mulle_allocator *) allocator;

@end


@interface CGLayer( CGContext)

// Use CGContext bindFramebuffer: to bind/unbind a layer, don't call directly
- (void) bindFramebuffer;
- (void) unbindFramebuffer;

@end



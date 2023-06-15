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
@property( assign, getter=isInitializedFramebuffer) BOOL   initializedFramebuffer;
@property char                      *debugNameUTF8String;  // useful for debugging

+ (instancetype) layerWithBitmapSize:(struct MulleIntegerSize) size
                          imageFlags:(NSUInteger) imageFlags
                             context:(CGContext *) context;

- (instancetype) initWithBitmapSize:(struct MulleIntegerSize) size
                         imageFlags:(NSUInteger) imageFlags
                            context:(CGContext *) context;

// more or less for completeness... probably makes no sense
- (instancetype) initWithImage:(CGImage *) image
                    imageFlags:(NSUInteger) imageFlags
                       context:(CGContext *) context;



- (struct CGBitmap) RGBABytesBitmap:(struct mulle_allocator *) allocator;

@end


//
// "conveniently" draw stuff into a CGLayer. Rendering to a bitmap is the core
// caching mechanism for more complex drawings.
//
@interface CGLayer( CGLayerRender)

struct CGLayerRenderInfo
{
   struct CGContextFramebuffer   framebuffer;
   struct CGFrameInfo            frameInfo;
};

// Use CGContext bindFramebuffer: to bind/unbind a layer, don't call directly
- (void) _bindToContext;
- (void) _unbindFromContext;

// these functions don't setup the view port or clear the CGLayer
- (void) _beginLayerRender:(struct CGLayerRenderInfo *) memo;
- (void) _endLayerRender:(struct CGLayerRenderInfo *) memo;

// Convenience routine clears and sets up the viewport and starts nvg frame.
// Feed the memo to endLayerRender when done
- (void) beginLayerRenderWithBackgroundColor:(CGColor) color
                            devicePixelRatio:(CGFloat) ratio
                             layerRenderInfo:(struct CGLayerRenderInfo *) memo;

- (void) endLayerRender:(struct CGLayerRenderInfo *) memo;

@end


#import "CGImage.h"


#import "CGContext+Texture.h"  // for CGGPUFramebuffer

struct CGFrameInfo;

// TODO: memo handle PixelBufferObjects too ?
//
// The historic name was CGLayer, but it has nothing to do with a CALayer. So
// it was renamed to CGFramebuffer. There is a typedef for CGLayer though.
//
//
// A drawing is rendered into a texture.
// In technical terms a wrapper for a texture created with
// nvgluCreateFramebuffer (usually). Such a texture can not be created during
// (main) rendering. It has to be done before or after.
//
// The texture lives at most as long as the CGContext is active. If the context
// vanishes, the texture is invalid. So that means that when the context
// finalizes it also needs to finalize the texture.
//
// The CGContext keeps track of all texture images, but doesn't retain them.
// When the time comes, it calls -finalize on all texture images.
//
// Where as the CGImage is immutable, the CGFramebuffer isn't
//
@interface CGFramebuffer : CGImage < NSCopying, MulleObjCThreadUnsafe>

@property( readonly, assign) CGGPUFramebuffer   *gpuFramebuffer;
// if the layer is multisample, it will be resolved into another
// image and this will be returned, otherwise it will just return self
// the image will be kept.
@property( readonly, retain) CGImage            *resolvedImage;

// as long as noone has drawn to it, this will be NO
@property( assign, getter=isInitializedFramebuffer) BOOL   initializedFramebuffer;
@property( assign) CGFloat                                 alpha;

+ (instancetype) framebufferWithBitmapSize:(CGPixelSize) size
                              textureFlags:(NSUInteger) textureFlags
                            nameUTF8String:(char *) nameUTF8String
                                   context:(CGContext *) context;

+ (instancetype) framebufferWithBitmapSize:(CGPixelSize) bitmapSize
                              textureFlags:(NSUInteger) textureFlags
                                   context:(CGContext *) context;

- (instancetype) initWithBitmapSize:(CGPixelSize) size
                       textureFlags:(NSUInteger) textureFlags
                     nameUTF8String:(char *) nameUTF8String
                            context:(CGContext *) context;

// more or less for completeness... probably makes no sense
- (instancetype) initWithImage:(CGImage *) image
                  textureFlags:(NSUInteger) textureFlags
                nameUTF8String:(char *) nameUTF8String
                       context:(CGContext *) context;


- (struct CGBitmap) RGBABytesBitmap:(struct mulle_allocator *) allocator;


@end


//
// "conveniently" draw stuff into a CGFramebuffer. Rendering to a bitmap is
// the core caching mechanism for more complex drawings.
//
@interface CGFramebuffer( CGLayerRender)

struct CGFramebufferRenderInfo
{
   struct CGContextFramebuffer   framebuffer;
   struct CGFrameInfo            frameInfo;
};

typedef void   CGFramebufferDrawFunction_t( CGContext *context,
                                            CGSize size,
                                            void *userinfo);
//
// the ultimate convenience renderer, give it a background and a draw
// function and paint into a freshly created layer. The context must be
// active for this function to work
//
+ (instancetype) framebufferWithBitmapSize:(CGPixelSize) size
                           backgroundColor:(CGColor) color
                              drawFunction:(CGFramebufferDrawFunction_t *) drawFunction
                                  userInfo:(void *) userInfo
                            nameUTF8String:(char *) nameUTF8String
                                   context:(CGContext *) context;


// Use CGContext bindFramebuffer: to bind/unbind a layer, don't call directly
- (void) _bindToContext;
- (void) _unbindFromContext;

// these functions don't setup the view port or clear the CGFramebuffer
- (void) _beginFBRender:(struct CGFramebufferRenderInfo *) memo;
- (void) _endFBRender:(struct CGFramebufferRenderInfo *) memo;

// Convenience routine clears and sets up the viewport and starts nvg frame.
// Feed the memo to endFBRender when done
- (void) beginFBRenderWithBackgroundColor:(CGColor) color
                         devicePixelRatio:(CGFloat) ratio
                          layerRenderInfo:(struct CGFramebufferRenderInfo *) memo;

- (void) endFBRender:(struct CGFramebufferRenderInfo *) memo;

@end


//@compatiblity_alias CGLayer CGFramebuffer;
typedef CGFramebuffer   CGLayer;

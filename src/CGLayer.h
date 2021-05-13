#import "CGImage.h"


@class CGContext;
struct MulleFrameInfo;

// This used to be called MulleTextureImage, which fits better, but the
// historic name is CGLayer. It has nothing to do with a CALayer though.

//
// An image rendered into a texture. In technical terms a wrapper for
// a texture created with nvgluCreateFramebuffer.
//
// The texture lives as long as the CGContext is active. But! If the context
// vanishes, the texture is invalid. So that means that when the context
// finalizes it also needs to finalize the texture. There is no reason, why
// a texture image can't be retained. So the lifetime of a MulleTextureImage
// shouldn't exceed that of the CGContext, but that can't be guaranteed.
// The CGContext keeps track of all texture images, but doesn't retain them.
// When the time comes, it calls -finalize on all texture images.
//
@interface CGLayer : NSObject < CGBitmapImage>

@property( readonly, assign) void                     *framebuffer;
@property( readonly, retain) CGContext                *context;
@property( readonly, assign) struct MulleBitmapInfo   bitmapInfo;
@property( readonly, assign) int                      nvgImageFlags;

//
// options is nvgImageFlags currently
//
- (instancetype) initWithBitmapInfo:(struct MulleBitmapInfo) size
                            context:(CGContext *) context
                            options:(NSUInteger) options;

- (int) textureIDWithContext:(CGContext *) context;

- (struct mulle_data) readRGBACData:(struct mulle_allocator *) allocator;


// binds the framebuffer and begins render of the context
// do your drawing after calling it (use -context for CGContext)
- (void) beginRenderWithFrameInfo:(struct MulleFrameInfo *) renderInfo;

// end render of the context and unbind the framebuffer
- (void) endRender;

@end


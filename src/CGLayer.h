#import "CGImage.h"


@class CGContext;
struct CGFrameInfo;

// Better name: CGFramebufferImage ?

// TODO: memo handle PixelBufferObjects too ?

// This used to be called MulleTextureImage, which fits better, but the
// historic name is CGLayer. It has nothing to do with a CALayer though.

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

+ (instancetype) layerWithBitmapSize:(struct CGBitmapSize) size
                         imageFlags:(NSUInteger) imageFlags
                            context:(CGContext *) context;

- (instancetype) initWithBitmapSize:(struct CGBitmapSize) size
                         imageFlags:(NSUInteger) imageFlags
                            context:(CGContext *) context;

- (void *) readRGBABytes:(struct mulle_allocator *) allocator;


//
// binds the framebuffer and begins render with the context.
// Do your drawing after calling it (use -context for CGContext)
// Use this outside of the render loop (you need to activate context before
// though)
// beginRender: does not clear the framebuffer
//
- (void) beginRender:(struct CGFrameInfo *) renderInfo;

// end render of the context and unbind the framebuffer
- (void) endRender;

// inside the render loop use this to bind buffers (be sure to have
// flushed previous render commands)
- (void) bindFramebuffer;

// better use [CGContext bindDefaultBuffer] when you are using retained windows
// which is the default
- (void) unbindFramebuffer;

@end


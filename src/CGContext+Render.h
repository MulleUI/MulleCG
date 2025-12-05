//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#import "CGContext.h"

#import "CGTypes.h"


@protocol CGRenderObject

- (void) renderInContext:(CGContext *) context;

@end


@interface CGContext( Render)

//
// The CGRenderObjects to render.
// They will be rendered front (0) to back (n).
// The objects will *NOT* be retained. The objects array will not be copied or
// kept.
//
- (void) renderObjects:(struct mulle_pointerarray *) layers;

- (void) beginRender:(struct CGFrameInfo *) info;
- (struct CGFrameInfo) bindRender:(struct CGFrameInfo *) info;

// if you do an offscreen render, the framebuffer will be stored via
// provideRenderedBuffer as a "in limbo" framebuffer to gotten either
// by acquire or repossess
- (void) endRender;

// if the context renders to an offscreen (custom) buffer, you will get
// the rendered framebuffer back here. Otherwise and usually nil
//
- (CGFramebuffer *) _endRender; // does not call suspendRender

// betweenbeginRender: and endRender:
- (BOOL) isRendering;

@end


// will be provided by +nanovg
@interface CGContext( RenderFuture)

+ (BOOL) supportsAntiAliasing;

//
// used to intermix OpenGL or other commands, this flushes commands
// cleans some font state and sets the viewport.
// (resumeRender is in OpenGL)
- (void) suspendRender;  // flushes and resets
- (void) flushRender;    // suspends and resumes
- (void) resumeRender;
- (void) changeRender:(struct CGFrameInfo *) info;
- (void) reset;


- (void *) gpuTextureForImageID:(NSInteger) textureID;
- (CGImage *) resolveMultiSampleImage:(CGImage *) image;

//
// framebuffer needs to be bound here, and context must be active
// you need to free the returned bitmap bytes
//
- (struct CGBitmap) readFramebufferBitmap:(CGPixelRect) rect
                    framebufferBitmapType:(CGFramebufferBitmapType) type
                                allocator:(struct mulle_allocator *) allocator;

//
- (struct CGBitmap) RGBABytesBitmapOfImage:(CGImage *) image
                                 allocator:(struct mulle_allocator *) allocator;

@end


// its here because i have no place for it
// rarely used so static inline is likely beneficial
static inline char   *CGTextMetricsUTF8String( CGTextMetrics metrics)
{
   char   *s;

   s = MulleObjC_asprintf( "{ ascender: %.2f, descender: %.2f, lineHeight: %.2f }",
                                    metrics.ascender,
                                    metrics.descender,
                                    metrics.lineHeight);
   return( s);
}


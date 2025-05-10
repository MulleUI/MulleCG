//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#import "CGContext.h"


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

- (void) changeRender:(struct CGFrameInfo *) info;

//
// used to intermix OpenGL or other commands, this flushes commands
// cleans some font state and sets the viewport.
// (resumeRender is in OpenGL)
- (void) suspendRender;  // flushes and resets
- (void) flushRender;    // suspends and resumes
- (void) resumeRender;

// betweenbeginRender: and endRender:
- (BOOL) isRendering;

@end

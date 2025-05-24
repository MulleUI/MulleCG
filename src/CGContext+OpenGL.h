//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"

#import "CGImage.h"


@interface CGContext( OpenGL)

// call this after beginRender, if you don't want to redraw the whole
// framebuffer, set clearFramebufferBits to taste. Uses backgroundColor
// to clear..
//
- (void) clearFramebufferBits:(NSUInteger) bits
                        color:(CGColor) color;

// acquire bits value for above call. If you can avoid clearing the color
// pixels, set flag to NO
- (NSUInteger) framebufferBitsWithColorBit:(BOOL) flag;

- (void) bindOpenGLFramebuffer:(void *) framebuffer;
- (void) bindDefaultOpenGLFramebuffer;

- (void) bindImage:(CGImage *) image
     toTextureUnit:(NSUInteger) index;
- (void) barrier;

// drawings should have completed...
- (struct CGBitmap) framebufferBitmap;

// private for CGContext+nanovg.m
- (void) _changeRenderOpenGL:(struct CGFrameInfo *) info;

@end


void   CGShaderUTF8SourcesParseUniforms( struct CGShaderUTF8Sources *sources,
                                         struct mulle_assoc *assoc);


struct CGContextFramebuffer
   CGContextCurrentOpenGLFramebuffer( CGContext *self);

// must be an OpenGL framebuffer
void   CGContextSetCurrentOpenGLFramebuffer( CGContext *self,
                                             struct CGContextFramebuffer fb);

typedef NS_ENUM( NSUInteger, CGContextFramebufferMode)
{
   CGContextFramebufferModeDefault = 0,
   CGContextFramebufferModeRead    = 1,
   CGContextFramebufferModeWrite   = 2,
   CGContextFramebufferModeDraw    = 2  // synonym
};

/*
 * The next functions are only available in OpenGLES 3 and OpenGL3
 */
void   _CGContextBindFramebuffer( CGContext *self,
                                  CGContextFramebufferMode type,
                                  struct CGContextFramebuffer fb);

void   CGContextBindFramebuffer( CGContext *self,
                                 struct CGContextFramebuffer fb);

// will bind to "dst"
void   _CGContextBlitFramebufferImage( CGContext *self,
                                       struct CGContextFramebuffer dst,
                                       CGRect rect,
                                       CGImage *src,
                                       BOOL interpolate);

// will bind to "dst"
void   _CGContextBlitFramebufferFramebuffer( CGContext *self,
                                             struct CGContextFramebuffer dst,
                                             CGRect rect,
                                             struct CGContextFramebuffer src,
                                             BOOL interpolate);

CGPixelSize
   _CGContextBitmapSizeOfOpenGLFramebuffer( CGContext *self,
                                            struct CGContextFramebuffer fb);


@interface CGImage ( OpenGL)

- (GLint) openGLSamplerType;

@end

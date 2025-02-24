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



@interface CGContext( OpenGL)

+ (NVGcontext *) createPathContext;

+ (CGContextNanoVGBackend) nanoVGBackend;
+ (char *) nanoVGBackendUTF8String;
- (char *) nanovgInfoUTF8String;

- (void *) gpuTextureForImageID:(NSInteger) textureID;



// context must be active
// read texture data, you need to free the returned bitmap bytes
- (struct CGBitmap) RGBABytesBitmapOfImage:(CGImage *) image
                                 allocator:(struct mulle_allocator *) allocator;

//
// framebuffer needs to be bound here, and context must be active
// you need to free the returned bitmap bytes
//
- (struct CGBitmap) readFramebufferBitmap:(CGPixelRect) rect
                    framebufferBitmapType:(CGFramebufferBitmapType) type
                                allocator:(struct mulle_allocator *) allocator;

//
// call this after beginRender, if you don't want to redraw the whole
// framebuffer, set clearFramebufferBits to taste. Uses backgroundColor
// to clear..
//
- (void) clearFramebufferBits:(NSUInteger) bits
                        color:(CGColor) color;

// acquire bits value for above call. If you can avoid clearing the color
// pixels, set flag to NO
- (NSUInteger) framebufferBitsWithColorBit:(BOOL) flag;



- (void) changeRender:(struct CGFrameInfo *) info;
- (void) resumeRender;

// called by -init / -finalize
- (void) _initNanoVGWithGraphicsOptions:(UIGraphicsOptions) options;

// retrieve openGLError if any, print and abort
- (void) assertNoBackendError:(char *) str;

- (void) bindOpenGLFramebuffer:(void *) framebuffer;
- (void) bindImage:(CGImage *) image
     toTextureUnit:(NSUInteger) index;
- (void) barrier;

// drawings should have completed...
- (struct CGBitmap) framebufferBitmap;

+ (BOOL) supportsAntiAliasing;

- (char *) nanovgInfoUTF8String;

- (CGImage *) resolveMultiSampleImage:(CGImage *) image;

@end


@interface CGLayoutContext ( OpenGL)

- (void) _initializeNanoVG:(NSUInteger) flags;
- (void) _finalizeNanoVG;

@end


void   CGShaderUTF8SourcesParseUniforms( struct CGShaderUTF8Sources *sources,
                                         struct mulle_assoc *assoc);

char   *CGNVGBackendErrorUTF8String( void);
char   *_CGNVGBackendErrorShortUTF8String( void *error);
char   *_CGNVGBackendErrorUTF8String( void *error);


void  _CGContextCheckBackendError( CGContext *ctxt, char *str);


static inline void   CGContextCheckBackendError( CGContext *ctxt, char *str)
{
#ifdef DEBUG
   _CGContextCheckBackendError( ctxt, str);
#endif
}

// cleans error state, returns YES if there were errors
BOOL   CGContextResetBackendError( CGContext *ctxt);


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
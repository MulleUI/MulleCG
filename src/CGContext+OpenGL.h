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

+ (enum CGContextBackend) backend;
+ (char *) backendUTF8String;

- (char *) shaderHeaderUTF8String;
- (void *) gpuTextureForImageID:(NSInteger) imageID;

- (NSUInteger) compileVertexShader:(char *) vertexShaderCode
                    fragmentShader:(char *) fragmentShaderCode
                    nameUTF8String:(char *) name;


// context must be active
// read texture data, you need to free the returned bitmap bytes
- (struct CGBitmap) RGBABytesBitmapOfImage:(CGImage *) image
                                 allocator:(struct mulle_allocator *) allocator;

//
// framebuffer needs to be bound here, and context must be active
// you need to free the returned bitmap bytes
//
- (struct CGBitmap) readFramebufferBitmap:(struct CGBitmapRect) rect
                    framebufferBitmapType:(enum CGFramebufferBitmapType) type
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
- (void) _initBackendWithEdgeAntialiasing:(BOOL) edgeAntialiasing
                        useStencilStrokes:(BOOL) useStencilStrokes;
- (void) _finalizeBackend;

- (void) useShader:(NSUInteger) shaderID;

// retrieve openGLError if any, print and abort
- (void) assertNoBackendError:(char *) str;

- (void) bindOpenGLFramebuffer:(void *) framebuffer;

- (void) barrier;

//
// TODO: remember under name as resource somehow
//
- (NSUInteger) compileVertexShader:(char *) vertexShaderCode
                    fragmentShader:(char *) fragmentShaderCode
                    nameUTF8String:(char *) name;

@end

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

//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


#import "CGLayoutContext+nanovg.h"


@interface CGContext( nanovg)

+ (CGContextNanoVGBackend) nanoVGBackend;
+ (char *) nanoVGBackendUTF8String;
+ (BOOL) supportsAntiAliasing;

- (char *) nanovgInfoUTF8String;

// called by -init / -finalize
- (void) _initNanoVGWithGraphicsOptions:(UIGraphicsOptions) options;

- (char *) nanovgInfoUTF8String;

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
//
// used to intermix OpenGL or other commands, this flushes commands
// cleans some font state and sets the viewport.
// (resumeRender is in OpenGL)
- (void) suspendRender;  // flushes and resets
- (void) flushRender;    // suspends and resumes
- (void) resumeRender;
- (void) changeRender:(struct CGFrameInfo *) info;

@end



@interface CGContextBase( nanovg)

+ (NVGcontext *) createPathContext;

@end


@interface CGLayoutContext ( OpenGL)

- (void) _initializeNanoVG:(NSUInteger) flags;
- (void) _finalizeNanoVG;

@end


@interface CGContext( Errors)

// this is here because nanovg sets the OpenGL version
- (void) assertNoBackendError:(char *) str;

@end




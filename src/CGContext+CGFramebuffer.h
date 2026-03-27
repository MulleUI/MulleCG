//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGContext.h"
#import "CGFramebuffer.h"

// we want "import.h" always anyway
#import "import.h"



@interface CGContext( CGFramebuffer)

- (struct CGContextFramebuffer) bindFramebuffer:(struct CGContextFramebuffer) fb;

- (struct CGContextFramebuffer) currentFramebuffer;


// to return to the "default" framebuffer, either the offscreen or the window
// one, if no offscreen exists
- (void) clearFramebuffer;
- (void) clearFramebufferWithHexColor:(NSUInteger) color;
- (void) clearFramebufferWithColor:(CGColor) color;

- (BOOL) needsFramebufferClear;

- (CGFramebuffer *) framebufferWithSize:(CGPixelSize) size
                           textureFlags:(NSUInteger) textureFlags
                         nameUTF8String:(char *) nameUTF8String;

//
// Once acquired its yours but its still only usable in the old CGContext.
// Now you can get at the shared GPUtexture and use this to create an image
// in your context. You should keep the CGFramebuffer around until your
// drawing has completed, because as soon as you return it, the framebuffer
// may be reused (and contents overwritten).
// If acquireRenderedFramebuffer returns nil (no new drawing ready yet) and
// you use it for refresh, you should reuse the kept layer. Otherwise recycle
// the old and use the new. Return after use with -recycleAcquiredRenderedFramebuffer:
// These methods are NOT to be called from the context active thread
//
- (id) acquireRenderedFramebuffer                         MULLE_OBJC_THREADSAFE_METHOD;
- (void) recycleAcquiredRenderedFramebuffer:(id) layer    MULLE_OBJC_THREADSAFE_METHOD;

// these are to be called from the context active thread only
- (id) repossessRenderedFramebuffer;
- (void) provideRenderedFramebuffer:(CGFramebuffer *) framebuffer;
- (void) recycleRenderedFramebuffer:(CGFramebuffer *) framebuffer;

// don't use these methods, use the methods above
- (void) queueRenderedFramebufferForDeletion:(CGFramebuffer *) framebuffer   MULLE_OBJC_THREADSAFE_METHOD;
- (void) deleteRenderedFramebuffers;

@end

MULLE_CG_GLOBAL
CGPixelSize
   CGContextBitmapSizeOfFramebuffer( CGContext *self,
                                     struct CGContextFramebuffer fb);


@interface CGContext( CGFramebufferFuture)

- (CGPixelSize) bitmapSizeOfFramebuffer:(struct CGContextFramebuffer) fb;

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


// provided by GPU backend (e.g. MulleCGNanoVG)
@interface CGContext( CGFramebufferGPU)

- (void) bindGPUFramebuffer:(void *) framebuffer;
- (void) bindDefaultGPUFramebuffer;
- (void) clearFramebufferBits:(NSUInteger) bits
                        color:(CGColor) color;
- (NSUInteger) framebufferBitsWithColorBit:(BOOL) flag;

@end
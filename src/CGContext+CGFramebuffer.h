//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif
#ifdef __has_include
# if __has_include( "CGFramebuffer.h")
#  import "CGFramebuffer.h"
# endif
#endif

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


// Once acquired its yours and its gone from CGContext. Now the window has
// contents to draw itself. It should keep the CGFramebuffer around for the next
// refresh. If acquireOffscreenFramebuffer returns nil (no new drawing
// ready yet), it should reuse that kept layer. Otherwise recycle the old
// and use the new.
//
- (id) acquireOffscreenFramebuffer        MULLE_OBJC_THREADSAFE_METHOD;

//
// Framebuffer presumably acquired through acquireFramebuffer, should be given
// back. For reuse or discarding
//
- (void) recycleFramebuffer:(id) layer    MULLE_OBJC_THREADSAFE_METHOD;

// get recycled framebuffer back
- (id) acquireRecycledFramebuffer         MULLE_OBJC_THREADSAFE_METHOD;

// don't use these, use the methods above
- (void) queueFramebufferForDeletion:(CGFramebuffer *) framebuffer   MULLE_OBJC_THREADSAFE_METHOD;
- (void) deleteFramebuffers                                          MULLE_OBJC_THREADSAFE_METHOD;

@end

CGPixelSize
   CGContextBitmapSizeOfFramebuffer( CGContext *self,
                                     struct CGContextFramebuffer fb);
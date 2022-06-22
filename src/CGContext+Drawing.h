//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


@interface CGContext( Drawing)

// only useable until the offscreen renderer hits again (?=)
- (void) drawBitmap:(struct CGBitmap *) fb;

// some very simple draw commands for debugging
- (void) fillRect:(CGRect) rect
            color:(CGColor) color;

- (void) strokeRect:(CGRect) rect
              color:(CGColor) color
              width:(CGFloat) width;

// used by UIWindow to blit...
- (void) drawRect:(CGRect) rect
            image:(id) image
            scale:(BOOL) scale;

- (void) drawAtPoint:(CGPoint) position
      textUTF8String:(char *) s
  fontNameUTF8String:(char *) fontNameUTF8String
            fontSize:(CGFloat) fontSize
               color:(CGColor) color;

@end


static inline void  CGContextDrawText( CGContext *self, CGFloat x, CGFloat y, char *s, CGFloat fontSize, CGColor color)
{
   [self drawAtPoint:CGPointMake( x, y)
      textUTF8String:s
  fontNameUTF8String:NULL
            fontSize:fontSize
               color:color];
}


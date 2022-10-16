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

struct CGPath;


@interface CGContext( Drawing)

// only useable until the offscreen renderer hits again (?=)
- (void) drawBitmap:(struct CGBitmap) fb;

- (void) setCompositionMode:(UIGraphicsCompositionMode) mode;

// some very simple draw commands 
- (void) fillRect:(CGRect) rect
            color:(CGColor) color;

- (void) strokeRect:(CGRect) rect
              color:(CGColor) color
              width:(CGFloat) width;

// used by UIWindow to blit...
- (void) drawRect:(CGRect) rect
            image:(id) image
            scale:(BOOL) scale;

- (void) fillCircleAtPoint:(CGPoint) point
                    radius:(CGFloat) radius
                      color:(CGColor) color;

- (void) strokeCircleAtPoint:(CGPoint) point
                      radius:(CGFloat) radius
                       width:(CGFloat) width
                       color:(CGColor) color;

- (void) fillPoint:(CGPoint) point 
             width:(CGFloat) width
             color:(CGColor) color;

- (void) strokeLineFromPoint:(CGPoint) from 
                     toPoint:(CGPoint) to
                       width:(CGFloat) strokeWidth
                       color:(CGColor) color;

- (void) fillPath:(struct CGPath *) path 
            color:(CGColor) color;

- (void) strokePath:(struct CGPath *) path 
              width:(CGFloat) strokeWidth
              color:(CGColor) color;

- (void) drawAtPoint:(CGPoint) position
      textUTF8String:(char *) s
  fontNameUTF8String:(char *) fontNameUTF8String
            fontSize:(CGFloat) fontSize
               color:(CGColor) color;

@end


static inline void  CGContextDrawText( CGContext *self, 
                                       CGFloat x, 
                                       CGFloat y, 
                                       char *s, 
                                       CGFloat fontSize, 
                                       CGColor color)
{
   [self drawAtPoint:CGPointMake( x, y)
      textUTF8String:s
  fontNameUTF8String:NULL
            fontSize:fontSize
               color:color];
}


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


@end

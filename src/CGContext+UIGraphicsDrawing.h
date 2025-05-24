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

//
// This is the UIGraphicsDrawing protocol. It probably would be better named
// UIGraphicsContextDrawing.Its used by UIPureWindow for blitting stuff
// and drawing simple debug graphics w/o knowledge about MulleCG
//

@interface CGContext( UIGraphicsDrawing) <UIGraphicsDrawing>

// this is not part of UIGraphicsDrawing
- (void) drawIcon:(mulle_utf32_t) icon
          atPoint:(CGPoint) rect;
@end

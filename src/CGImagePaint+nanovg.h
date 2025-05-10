//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
// prefer a local CGImagePaint over one in import.h
#ifdef __has_include
# if __has_include( "CGImagePaint.h")
#  import "CGImagePaint.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


@interface CGImagePaint( nanovg)

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                          alpha:(CGFloat) alpha
                     NVGcontext:(NVGcontext *) vg;
@end

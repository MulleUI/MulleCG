//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGBlendedPaint.h"

#import "import-private.h"

#import "CGPaint+nanovg.h"
#import "CGPaint+Drawing.h"
#import "CGImage.h"
#import "microvg.h"


@interface CGPaint( nanovg_Subclasses)

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                   paintOptions:(struct CGPaintOptions *) options
                        context:(CGContext *) context;

@end


@implementation CGBlendedPaint ( nanovg)

// we cant do much good here, because we need to paint our paint twice,
// which the user is circumventing, we could also abort here...

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                   paintOptions:(struct CGPaintOptions *) options
                        context:(CGContext *) context
{
   return( [_otherPaint NVGpaintWithBounds:rect
                              paintOptions:options
                                   context:context]);
}

@end


//
// Copyright (c) Nat!, Mulle kybernetiK
//
#import "CGBlendedPaint.h"
#import "CGPaintable.h"

#import "import-private.h"


@implementation CGBlendedPaint( CGPaintable)

- (void) fillWithBounds:(CGRect) rect
                options:(struct CGFillOptions *) options
                context:(CGContext *) context
{
   // delegate to otherPaint
   [[self otherPaint] fillWithBounds:rect
                             options:options
                             context:context];
}


- (void) strokeWithBounds:(CGRect) bounds
              strokeWidth:(CGFloat) strokeWidth
                  options:(struct CGStrokeOptions *) options
                  context:(CGContext *) context
{
   [[self otherPaint] strokeWithBounds:bounds
                           strokeWidth:strokeWidth
                               options:options
                               context:context];
}

@end

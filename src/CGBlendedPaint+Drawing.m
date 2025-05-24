//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGBlendedPaint.h"

#import "import-private.h"


#import "CGPaint+Drawing.h"


@implementation CGBlendedPaint ( Drawing)

- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
                    alpha:(CGFloat) alpha
                  context:(CGContext *) context
{
   CGFloat    blend;

   if( strokeWidth <= 0.0f)
      return;

   blend = (_paint == _otherPaint) ? 0.0f : _blend;
   [_paint strokeWithBounds:rect
                strokeWidth:strokeWidth
                      alpha:(1.0f - blend) * alpha
                    context:context];
   [_otherPaint strokeWithBounds:rect
                     strokeWidth:strokeWidth
                           alpha:blend * alpha
                         context:context];
}


- (void) fillWithBounds:(CGRect) rect
                  alpha:(CGFloat) alpha
                context:(CGContext *) context
{
   CGFloat    blend;

   blend = (_paint == _otherPaint) ? 0.0f : _blend;
   [_paint fillWithBounds:rect
                    alpha:(1.0f - blend) * alpha
                  context:context];
   [_otherPaint fillWithBounds:rect
                         alpha:blend * alpha
                       context:context];
}

@end

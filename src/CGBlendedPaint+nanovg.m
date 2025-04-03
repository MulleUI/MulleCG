//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGBlendedPaint+nanovg.h"

#import "import-private.h"

#import "CGPaint+nanovg.h"
#import "CGImage.h"
#import "microvg.h"


@implementation CGBlendedPaint ( nanovg)


- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                          alpha:(CGFloat) alpha
                     NVGcontext:(NVGcontext *) vg
{
//   CGFloat   blend;
//
//   blend = (_paint == _otherPaint) ? 0.0f : _blend;
   return( [_otherPaint NVGpaintWithBounds:rect
                                     alpha:1.0 * alpha
                                NVGcontext:vg]);
}


- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
                   alpha:(CGFloat) alpha
               NVGcontext:(NVGcontext *) vg
{
   CGFloat    blend;

   if( strokeWidth <= 0.0f)
      return;

   blend = (_paint == _otherPaint) ? 0.0f : _blend;
   [_paint strokeWithBounds:rect
                strokeWidth:strokeWidth
                      alpha:(1.0f - blend) * alpha
                 NVGcontext:vg];
   [_otherPaint strokeWithBounds:rect
                     strokeWidth:strokeWidth
                           alpha:blend * alpha
                      NVGcontext:vg];
}


- (void) fillWithBounds:(CGRect) rect
                  alpha:(CGFloat) alpha
             NVGcontext:(NVGcontext *) vg
{
   CGFloat    blend;

   blend = (_paint == _otherPaint) ? 0.0f : _blend;
   [_paint fillWithBounds:rect
                    alpha:(1.0f - blend) * alpha
               NVGcontext:vg];
   [_otherPaint fillWithBounds:rect
                         alpha:blend * alpha
                    NVGcontext:vg];
}

@end


//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGGradient+nanovg.h"

#import "import-private.h"

#include "microvg.h"
#include <math.h>

#import "CGContext.h"


@implementation CGGradient ( nanovg)

static NVGpaint
   CGGradientNVGpaintForRect( CGGradient *self, CGRect rect, NVGcontext *vg)
{
   CGFloat      radians;
   CGFloat      w, h;
   CGPoint      end;
   CGPoint      start;
   NVGpaint     paint;
   CARotation   rotation;

   rotation = [self rotation];
   radians  = CARotationToRadians( rotation);
   w        = rect.size.width  * cosf( radians);
   h        = rect.size.height * sinf( radians);
   start    = CGPointMake( rect.origin.x + rect.size.width / 2.0 - w / 2.0,
                           rect.origin.y + rect.size.height / 2.0 - h / 2.0);
   end      = CGPointMake( start.x + w, start.y + h);
   paint    = mvgLinearGradient( vg, start, end, [self startColor], [self endColor]);
   return( paint);
}


- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                     NVGcontext:(NVGcontext *) vg
{
   NVGpaint   paint;

   paint = CGGradientNVGpaintForRect( self, rect, vg);
   return( paint);
}


- (NVGpaint) linearGradientNVGpaintWithBounds:(CGRect) rect
                                   NVGcontext:(NVGcontext *) vg
{
   NVGpaint   paint;

   paint = CGGradientNVGpaintForRect( self, rect, vg);
   return( paint);
}


- (NVGpaint) boxGradientNVGpaintWithBounds:(CGRect) rect
                              cornerRadius:(CGFloat) radius
                                   feather:(CGFloat) feather
                                NVGcontext:(NVGcontext *) vg
{
   NVGpaint   paint;

   paint = mvgBoxGradient( vg,
                           rect,
                           radius,
                           feather,
                           [self startColor],
                           [self endColor]);
   return( paint);
}


- (NVGpaint) radialGradientNVGpaintWithCenter:(CGPoint) center
                                  innerRadius:(CGFloat) innerRadius
                                  outerRadius:(CGFloat) outerRadius
                                   NVGcontext:(NVGcontext *) vg
{
   NVGpaint   paint;

   paint = mvgRadialGradient( vg,
                              center,
                              innerRadius,
                              outerRadius,
                              [self startColor],
                              [self endColor]);
   return( paint);
}

@end



void   mvgFillCircleWithGradient( NVGcontext *vg,
                                  CGPoint center,
                                  CGFloat radius,
                                  CGGradient *gradient)
{
   mvgBeginPath( vg);
   {
      mvgCircle( vg, center, radius);
      mvgFillPaint( vg, [gradient radialGradientNVGpaintWithCenter:center
                                                       innerRadius:0.0
                                                       outerRadius:radius
                                                        NVGcontext:vg]);
   }
   mvgFill( vg);
}



void   mvgStrokeCircleWithGradient( NVGcontext *vg,
                                    CGPoint center,
                                    CGFloat radius,
                                    CGFloat strokeWidth,
                                    CGGradient *gradient)
{
   mvgBeginPath( vg);
   {
      mvgCircle( vg, center, radius);
      mvgStrokePaint( vg, [gradient radialGradientNVGpaintWithCenter:center
                                                         innerRadius:0.0
                                                         outerRadius:radius + strokeWidth / 2.0
                                                          NVGcontext:vg]);
      mvgStrokeWidth( vg, strokeWidth);
   }
   mvgStroke( vg);
}



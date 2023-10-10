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
   CGGradientNVGpaintForRect( CGGradient *self,
                              CGRect rect,
                              CARotation rotation,
                              CGFloat smoothness,
                              BOOL isRectangular,
                              NVGcontext *vg)
{
   CGFloat      radians;
   CGFloat      w, h;
   CGPoint      end;
   CGPoint      start;
   CGPoint      center;
   NVGpaint     paint;
   CGFloat      size;

   radians  = CARotationToRadians( rotation);
   if( isRectangular)
   {
      w     = rect.size.width * cosf( radians) * smoothness;
      h     = rect.size.height * sinf( radians) * smoothness;
   }
   else
   {
      size  = CGRectGetMinimumSize( rect);
      w     = size * cosf( radians) * smoothness;
      h     = size * sinf( radians) * smoothness;
   }

   center   = CGRectGetCenterPoint( rect);
   start    = CGPointMake( center.x - w / 2.0, center.y - h / 2.0);
   end      = CGPointMake( start.x + w, start.y + h);

   paint    = nvgLinearGradient( vg, start.x, start.y, end.x, end.y, [self startColor], [self endColor]);
   return( paint);
}


- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                     NVGcontext:(NVGcontext *) vg
{
   NVGpaint   paint;

   paint = CGGradientNVGpaintForRect( self, rect, [self rotation], 1.0f, YES, vg);
   return( paint);
}


- (NVGpaint) linearGradientNVGpaintWithBounds:(CGRect) rect
                                   NVGcontext:(NVGcontext *) vg
{
   NVGpaint   paint;

   paint = CGGradientNVGpaintForRect( self, rect, [self rotation], 1.0f, YES, vg);
   return( paint);
}


- (NVGpaint) linearGradientNVGpaintWithBounds:(CGRect) rect
                                   smoothness:(CGFloat) smoothness
                                   NVGcontext:(NVGcontext *) vg
{
   NVGpaint   paint;

   paint = CGGradientNVGpaintForRect( self, rect, [self rotation], smoothness, YES, vg);
   return( paint);
}


- (NVGpaint) rectangularLinearGradientNVGpaintWithBounds:(CGRect) rect
                                              smoothness:(CGFloat) smoothness
                                              NVGcontext:(NVGcontext *) vg
{
   NVGpaint   paint;

   paint = CGGradientNVGpaintForRect( self, rect, [self rotation], smoothness, NO, vg);
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
                           [self endColor],
                           radius,
                           feather,
                           [self startColor]);
   return( paint);
}


- (NVGpaint) radialGradientNVGpaintWithCircle:(CACircle) circle
                                  innerRadius:(CGFloat) innerRadius
                                   NVGcontext:(NVGcontext *) vg
{
   NVGpaint   paint;

   paint = mvgRadialGradient( vg,
                              circle,
                              [self startColor],
                              innerRadius,
                              [self endColor]);
   return( paint);
}

@end



void   mvgFillCircleWithGradient( NVGcontext *vg,
                                  CACircle circle,
                                  CGGradient *gradient)
{
   mvgBeginPath( vg);
   {
      mvgCircle( vg, circle);
      mvgFillPaint( vg, [gradient radialGradientNVGpaintWithCircle:circle
                                                       innerRadius:0.0
                                                        NVGcontext:vg]);
   }
   mvgFill( vg);
}



void   mvgStrokeCircleWithGradient( NVGcontext *vg,
                                    CACircle circle,
                                    CGFloat strokeWidth,
                                    CGGradient *gradient)
{
   if( strokeWidth <= 0.0f)
      return;

   mvgBeginPath( vg);
   {
      mvgCircle( vg, circle);
      circle = CACircleExtrude( circle, strokeWidth / 2.0);
      mvgStrokePaint( vg, [gradient radialGradientNVGpaintWithCircle:circle
                                                         innerRadius:0.0
                                                          NVGcontext:vg]);
      mvgStrokeWidth( vg, strokeWidth);
   }
   mvgStroke( vg);
}


void   mvgFillRoundedRectWithLinearGradient( NVGcontext *vg,
                                             CGRect rect,
                                             CGFloat cornerRadius,
                                             CGFloat smoothness,
                                             CGGradient *gradient)
{
   NVGpaint     paint;

   mvgBeginPath( vg);
   mvgRoundedRect( vg, rect, cornerRadius);

#ifdef NIL_PAINT_DRAWS_BLACK
   if( ! gradient)
   {
      mvgFillColor( vg, CGColorMakeBlack());
      mvgFill( vg);
      return;
   }
#endif

   paint = CGGradientNVGpaintForRect( gradient, rect, [gradient rotation], smoothness, YES, vg);

   mvgFillPaint( vg, paint);
   mvgFill( vg);
}


void   mvgFillRoundedRectWithRectangularLinearGradient( NVGcontext *vg,
                                                        CGRect rect,
                                                        CGFloat cornerRadius,
                                                        CGFloat smoothness,
                                                        CGGradient *gradient)
{
   NVGpaint     paint;

   mvgBeginPath( vg);
   mvgRoundedRect( vg, rect, cornerRadius);

#ifdef NIL_PAINT_DRAWS_BLACK
   if( ! gradient)
   {
      mvgFillColor( vg, CGColorMakeBlack());
      mvgFill( vg);
      return;
   }
#endif

   paint = CGGradientNVGpaintForRect( gradient, rect, [gradient rotation], smoothness, NO, vg);

   mvgFillPaint( vg, paint);
   mvgFill( vg);
}



void   mvgStrokeRoundedRectWithLinearGradient( NVGcontext *vg,
                                               CGRect rect,
                                               CGFloat cornerRadius,
                                               CGFloat strokeWidth,
                                               CGFloat smoothness,
                                               CGGradient *gradient)
{
   NVGpaint     paint;

   if( strokeWidth <= 0.0f)
      return;

   mvgBeginPath( vg);
   mvgRoundedRect( vg, rect, cornerRadius);

#ifdef NIL_PAINT_DRAWS_BLACK
   if( ! gradient)
   {
      mvgStrokeColor( vg, CGColorMakeBlack());
      mvgStroke( vg);
      return;
   }
#endif

   paint = CGGradientNVGpaintForRect( gradient, rect, [gradient rotation], smoothness, YES, vg);

   mvgStrokePaint( vg, paint);
   mvgStrokeWidth( vg, strokeWidth);
   mvgStroke( vg);
}


void   mvgStrokeRoundedRectWithRectangularLinearGradient( NVGcontext *vg,
                                                          CGRect rect,
                                                          CGFloat cornerRadius,
                                                          CGFloat strokeWidth,
                                                          CGFloat smoothness,
                                                          CGGradient *gradient)
{
   NVGpaint     paint;

   if( strokeWidth <= 0.0f)
      return;

   mvgBeginPath( vg);
   mvgRoundedRect( vg, rect, cornerRadius);

#ifdef NIL_PAINT_DRAWS_BLACK
   if( ! gradient)
   {
      mvgStrokeColor( vg, CGColorMakeBlack());
      mvgStroke( vg);
      return;
   }
#endif

   paint = CGGradientNVGpaintForRect( gradient, rect, [gradient rotation], smoothness, NO, vg);

   mvgStrokePaint( vg, paint);
   mvgStrokeWidth( vg, strokeWidth);
   mvgStroke( vg);
}


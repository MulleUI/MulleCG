//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGPaint+nanovg.h"

#import "import-private.h"

#import "CGContext.h"
#include "millivg.h"


@implementation CGPaint( nanovg)


- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
               NVGcontext:(NVGcontext *) vg
{
   NVGpaint     paint;

   rect  = CGRectExtrude( rect, strokeWidth / 2.0f, strokeWidth / 2.0f);
   paint = [self NVGpaintWithBounds:rect
                         NVGcontext:vg];
   mvgStrokePaint( vg, paint);
   mvgStrokeWidth( vg, strokeWidth);
   mvgStroke( vg);
}


- (void) fillWithBounds:(CGRect) rect
             NVGcontext:(NVGcontext *) vg
{
   NVGpaint     paint;

   paint = [self NVGpaintWithBounds:rect
                         NVGcontext:vg];
   mvgFillPaint( vg, paint);
   mvgFill( vg);
}

@end


static void   fillWithBoundsAndPaint( NVGcontext *vg,
                                      CGRect rect,
                                      CGPaint *paint)
{
   if( ! paint)
   {
      mvgFillColor( vg, CGColorMakeBlack());
      mvgFill( vg);
      return;
   }

   [paint fillWithBounds:rect
             NVGcontext:vg];

}


void   mvgFillRoundedRectWithPaint( NVGcontext *vg,
                                    CGRect rect,
                                    CGFloat cornerRadius,
                                    CGPaint *paint)
{
   mvgBeginPath( vg);
   mvgRoundedRect( vg, rect, cornerRadius);
   fillWithBoundsAndPaint( vg, rect, paint);
}



void   mvgFillRectWithPaint( NVGcontext *vg, CGRect rect, CGPaint *paint)
{
   mvgBeginPath( vg);
   mvgRect( vg, rect);
   fillWithBoundsAndPaint( vg, rect, paint);

}



void   mvgFillCircleWithPaint( NVGcontext *vg, 
                               CGPoint center, 
                               CGFloat radius, 
                               CGPaint *paint)
{
   CGRect   rect;

   mvgBeginPath( vg);
   mvgCircle( vg, center, radius);
   rect = CGRectMakeWithCenterPointAndInnerRadius( center, radius);
   fillWithBoundsAndPaint( vg, rect, paint);
}


static void   strokeWithBoundsAndPaint( NVGcontext *vg,
                                        CGRect rect,
                                        CGFloat strokeWidth,
                                        CGPaint *paint)
{
   if( ! paint)
   {
      mvgStrokeWidth( vg, strokeWidth);
      mvgStrokeColor( vg, CGColorMakeBlack());
      mvgStroke( vg);
      return;
   }

   [paint strokeWithBounds:rect
               strokeWidth:strokeWidth
                NVGcontext:vg];
}


void   mvgStrokeRoundedRectWithPaint( NVGcontext *vg,
                                      CGRect rect,
                                      CGFloat cornerRadius,
                                      CGFloat strokeWidth,
                                      CGPaint *paint)
{
   mvgBeginPath( vg);
   mvgRoundedRect( vg, rect, cornerRadius);
   strokeWithBoundsAndPaint( vg, rect, strokeWidth, paint);
}



void   mvgStrokeRectWithPaint( NVGcontext *vg,
                               CGRect rect,
                               CGFloat strokeWidth,
                               CGPaint *paint)
{
   mvgBeginPath( vg);
   mvgRect( vg, rect);
   strokeWithBoundsAndPaint( vg, rect, strokeWidth, paint);
}


void   mvgStrokeCircleWithPaint( NVGcontext *vg, 
                                 CGPoint center, 
                                 CGFloat radius, 
                                 CGFloat strokeWidth,
                                 CGPaint *paint)
{
   CGRect   rect;

   mvgBeginPath( vg);
   mvgCircle( vg, center, radius);
   rect = CGRectMakeWithCenterPointAndInnerRadius( center, radius);
   strokeWithBoundsAndPaint( vg, rect, strokeWidth, paint);
}  


void   mvgStrokeLineWithPaint( NVGcontext *vg, 
                               CGPoint start, 
                               CGPoint end, 
                               CGFloat strokeWidth,
                               CGPaint *paint)
{
   CGRect   rect;

   mvgBeginPath( vg);
   mvgMoveTo( vg, start);
   mvgLineTo( vg, end);
   rect = CGRectMakeWithPoints( start, end);
   strokeWithBoundsAndPaint( vg, rect, strokeWidth, paint);
}


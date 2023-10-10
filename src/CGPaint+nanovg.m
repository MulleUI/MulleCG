//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGPaint+nanovg.h"

#import "import-private.h"

#import "CGContext.h"
#include "microvg.h"

#import "CGGradient.h"
#import "CGPaint+Private.h"

// why is this good ?
// #define NIL_PAINT_DRAWS_BLACK


@implementation _CGMonoColor( nanovg)

- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
               NVGcontext:(NVGcontext *) vg
{
   if( strokeWidth <= 0.0f)
      return;

   mvgStrokeColor( vg, _color);
   mvgStrokeWidth( vg, strokeWidth);
   mvgStroke( vg);
}


- (void) fillWithBounds:(CGRect) rect
             NVGcontext:(NVGcontext *) vg
{
   mvgFillColor( vg, _color);
   mvgFill( vg);
}

@end



@implementation CGPaint( nanovg)

- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
               NVGcontext:(NVGcontext *) vg
{
   NVGpaint     paint;

   if( strokeWidth <= 0.0f)
      return;

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
#ifdef NIL_PAINT_DRAWS_BLACK
   if( ! paint)
   {
      mvgFillColor( vg, CGColorMakeBlack());
      mvgFill( vg);
      return;
   }
#endif
   [paint fillWithBounds:rect
             NVGcontext:vg];

}


void   mvgFillRoundedRectVaryingWithPaint( NVGcontext *vg,
                                           CGRect rect,
                                           MulleCornerInsets cornerInsets,
                                           CGPaint *paint)
{
   mvgBeginPath( vg);
   mvgRoundedRectVarying( vg, rect, cornerInsets);
   fillWithBoundsAndPaint( vg, rect, paint);
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
                               CACircle circle,
                               CGPaint *paint)
{
   CGRect   rect;

   mvgBeginPath( vg);
   mvgCircle( vg, circle);
   rect = CACircleGetOuterRect( circle);
   fillWithBoundsAndPaint( vg, rect, paint);
}


static void   strokeWithBoundsAndPaint( NVGcontext *vg,
                                        CGRect rect,
                                        CGFloat strokeWidth,
                                        CGPaint *paint)
{
   if( strokeWidth <= 0.0f)
      return;

#ifdef NIL_PAINT_DRAWS_BLACK
   if( ! paint)
   {
      mvgStrokeWidth( vg, strokeWidth);
      mvgStrokeColor( vg, CGColorMakeBlack());
      mvgStroke( vg);
      return;
   }
#endif

   [paint strokeWithBounds:rect
               strokeWidth:strokeWidth
                NVGcontext:vg];
}


void   mvgStrokeRoundedRectVaryingWithPaint( NVGcontext *vg,
                                             CGRect rect,
                                             MulleCornerInsets cornerInsets,
                                             CGFloat strokeWidth,
                                             CGPaint *paint)
{
   mvgBeginPath( vg);
   mvgRoundedRectVarying( vg, rect, cornerInsets);
   strokeWithBoundsAndPaint( vg, rect, strokeWidth, paint);
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
                                 CACircle circle,
                                 CGFloat strokeWidth,
                                 CGPaint *paint)
{
   CGRect   rect;

   mvgBeginPath( vg);
   mvgCircle( vg, circle);
   rect = CACircleGetOuterRect( circle);
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



void   mvgStrokeLineHWithPaint( NVGcontext *vg,
                                CGPoint start,
                                CGFloat width,
                                CGFloat strokeWidth,
                                CGPaint *paint)
{
   CGRect   rect;
   CGPoint  end;

   end = CGPointMake( start.x + width, start.y);
   mvgBeginPath( vg);
   mvgMoveTo( vg, start);
   mvgLineTo( vg, end);
   rect = CGRectMakeWithPoints( start, end);
   strokeWithBoundsAndPaint( vg, rect, strokeWidth, paint);
}


void   mvgStrokeLineVWithPaint( NVGcontext *vg,
                                CGPoint start,
                                CGFloat height,
                                CGFloat strokeWidth,
                                CGPaint *paint)
{
   CGRect   rect;
   CGPoint  end;

   end = CGPointMake( start.x, start.y + height);
   mvgBeginPath( vg);
   mvgMoveTo( vg, start);
   mvgLineTo( vg, end);
   rect = CGRectMakeWithPoints( start, end);
   strokeWithBoundsAndPaint( vg, rect, strokeWidth, paint);
}

//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGPaint+nanovg.h"

#import "import-private.h"

#import "CGContext.h"
#include "microvg.h"

#import "CGGradient.h"
#import "CGImage.h"
#import "CGPaint+Private.h"

// why is this good ?
// #define NIL_PAINT_DRAWS_BLACK


@implementation _CGMonoColor( nanovg)

- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
                    alpha:(CGFloat) alpha
               NVGcontext:(NVGcontext *) vg
{
   CGColor   color;

   if( strokeWidth <= 0.0f || alpha <= 0.0)
      return;

   color = alpha >= 1.0 ? _color : CGColorMultiplyAlpha( _color, alpha);
   mvgStrokeColor( vg, color);
   mvgStrokeWidth( vg, strokeWidth);
   mvgStroke( vg);
}


- (void) fillWithBounds:(CGRect) rect
                  alpha:(CGFloat) alpha
             NVGcontext:(NVGcontext *) vg
{
   CGColor   color;

   if( alpha <= 0.0)
      return;

   color = alpha >= 1.0 ? _color : CGColorMultiplyAlpha( _color, alpha);
   mvgFillColor( vg, color);
   mvgFill( vg);
}

@end



@implementation CGPaint( nanovg)

#ifndef NDEBUG
static void   assertImageInNVGcontext( CGImage *self, NVGcontext *vg)
{
   CGContext   *otherContext;
   NVGcontext  *otherVG;

   if( ! self)
      return;

   otherContext = [self context];
   // circumvent otherContext assert with underscpre function, because we want
   // our more descriptive text
   otherVG      = _CGContextGetNVGContext( otherContext);
   assert( vg == otherVG && "paint image should belong to same context");
}


static void   assertPaintInNVGcontext( CGPaint *self, NVGcontext *vg)
{
   assertImageInNVGcontext( [self image], vg);
   assertImageInNVGcontext( [self otherImage], vg);
}
#else
# define assertImageInNVGcontext( self, vg)
# define assertPaintInNVGcontext( self, vg)
#endif


- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
                    alpha:(CGFloat) alpha
               NVGcontext:(NVGcontext *) vg
{
   NVGpaint     paint;

   assertPaintInNVGcontext( self, vg);

   if( strokeWidth <= 0.0f)
      return;

   rect  = CGRectExtrude( rect, strokeWidth / 2.0f, strokeWidth / 2.0f);
   paint = [self NVGpaintWithBounds:rect
                              alpha:alpha
                         NVGcontext:vg];
   mvgStrokePaint( vg, paint);
   mvgStrokeWidth( vg, strokeWidth);
   mvgStroke( vg);
}


- (void) fillWithBounds:(CGRect) rect
                  alpha:(CGFloat) alpha
             NVGcontext:(NVGcontext *) vg
{
   NVGpaint     paint;

   assertPaintInNVGcontext( self, vg);

   paint = [self NVGpaintWithBounds:rect
                              alpha:alpha
                         NVGcontext:vg];
   mvgFillPaint( vg, paint);
   mvgFill( vg);
}


- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
               NVGcontext:(NVGcontext *) vg
{
   // convenience for subclasses
   [self strokeWithBounds:rect
              strokeWidth:strokeWidth
                    alpha:1.0f
               NVGcontext:vg];
}


- (void) fillWithBounds:(CGRect) rect
             NVGcontext:(NVGcontext *) vg
{
   // convenience for subclasses
   [self fillWithBounds:rect
                  alpha:1.0f
             NVGcontext:vg];
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
                   alpha:1.0f
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
                     alpha:1.0f
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

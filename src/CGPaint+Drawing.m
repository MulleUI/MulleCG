//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGPaint+Drawing.h"

#import "import-private.h"

#import "CGContext+Drawing.h"
#import "CGPaint+nanovg.h"
#import "CGGradient.h"
#import "CGPaint+Private.h"


@implementation CGPaint ( Drawing)

- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
                    alpha:(CGFloat) alpha
                  context:(CGContext *) context
{
   CGStrokeOptions   options;

   if( strokeWidth <= 0.0f)
      return;

   options = (struct CGStrokeOptions)
   {
      .paint    = CGPaintOptionsDefault,
      .relation = CGCover
   };
   options.paint.alpha = alpha;

   CGContextStrokePaintWithOptions( context, self, rect, strokeWidth, &options);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}


- (void) fillWithBounds:(CGRect) rect
                  alpha:(CGFloat) alpha
                context:(CGContext *) context
{
   CGFillOptions   options;

   options = (CGFillOptions)
   {
      .paint    = CGPaintOptionsDefault,
      .relation = CGCover
   };
   options.paint.alpha = alpha;

   CGContextFillPaintWithOptions( context, self, rect, &options);
   CGContextFill( context);
}


- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
                  context:(CGContext *) context
{
   // convenience for subclasses
   [self strokeWithBounds:rect
              strokeWidth:strokeWidth
                    alpha:1.0f
                  context:context];
}


- (void) fillWithBounds:(CGRect) rect
                context:(CGContext *) context
{
   // convenience for subclasses
   [self fillWithBounds:rect
                  alpha:1.0f
                context:context];
}

@end


@implementation _CGMonoColor( nanovg)

- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
                    alpha:(CGFloat) alpha
                  context:(CGContext *) context
{
   CGColor   color;

   if( strokeWidth <= 0.0f || alpha <= 0.0)
      return;

   // So in CGColor the alpha is already in the alpha channel
   // we are doing additional alpha here on request, maybe to fade in/out
   color = alpha >= 1.0 ? _color : CGColorMultiplyAlpha( _color, alpha);
   CGContextStrokeColor( context, color);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}


- (void) fillWithBounds:(CGRect) rect
                  alpha:(CGFloat) alpha
                context:(CGContext *) context
{
   CGColor   color;

   if( alpha <= 0.0)
      return;

   color = alpha >= 1.0 ? _color : CGColorMultiplyAlpha( _color, alpha);
   CGContextFillColor( context, color);
   CGContextFill( context);
}

@end


static void   fillWithBoundsAndPaint( CGContext *context,
                                      CGRect rect,
                                      CGPaint *paint)
{
#ifdef NIL_PAINT_DRAWS_BLACK
   if( ! paint)
   {
      CGContextFillColor( context, CGColorMakeBlack());
      CGContextFill( context);
      return;
   }
#endif
   [paint fillWithBounds:rect
                   alpha:1.0f
                 context:context];

}


void   CGContextFillRoundedRectVaryingWithPaint( CGContext *context,
                                                 CGRect rect,
                                                 MulleCornerInsets cornerInsets,
                                                 CGPaint *paint)
{
   CGContextBeginPath( context);
   CGContextRoundedRectVarying( context, rect, cornerInsets);
   fillWithBoundsAndPaint( context, rect, paint);
}


void   CGContextFillRoundedRectWithPaint( CGContext *context,
                                          CGRect rect,
                                          CGFloat cornerRadius,
                                          CGPaint *paint)
{
   CGContextBeginPath( context);
   CGContextRoundedRect( context, rect, cornerRadius);
   fillWithBoundsAndPaint( context, rect, paint);
}



void   CGContextFillRectWithPaint( CGContext *context, CGRect rect, CGPaint *paint)
{
   CGContextBeginPath( context);
   CGContextRect( context, rect);
   fillWithBoundsAndPaint( context, rect, paint);
}


void   CGContextFillCircleWithPaint( CGContext *context, 
                                     CACircle circle,
                                     CGPaint *paint)
{
   CGRect   rect;

   CGContextBeginPath( context);
   CGContextCircle( context, circle);
   rect = CACircleGetOuterRect( circle);
   fillWithBoundsAndPaint( context, rect, paint);
}


static void   strokeWithBoundsAndPaint( CGContext *context,
                                        CGRect rect,
                                        CGFloat strokeWidth,
                                        CGPaint *paint)
{
   if( strokeWidth <= 0.0f)
      return;

#ifdef NIL_PAINT_DRAWS_BLACK
   if( ! paint)
   {
      CGContextStrokeWidth( context, strokeWidth);
      CGContextStrokeColor( context, CGColorMakeBlack());
      CGContextStroke( context);
      return;
   }
#endif

   [paint strokeWithBounds:rect
               strokeWidth:strokeWidth
                     alpha:1.0f
                   context:context];
}


void   CGContextStrokeRoundedRectVaryingWithPaint( CGContext *context,
                                                   CGRect rect,
                                                   MulleCornerInsets cornerInsets,
                                                   CGFloat strokeWidth,
                                                   CGPaint *paint)
{
   CGContextBeginPath( context);
   CGContextRoundedRectVarying( context, rect, cornerInsets);
   strokeWithBoundsAndPaint( context, rect, strokeWidth, paint);
}


void   CGContextStrokeRoundedRectWithPaint( CGContext *context,
                                            CGRect rect,
                                            CGFloat cornerRadius,
                                            CGFloat strokeWidth,
                                            CGPaint *paint)
{
   CGContextBeginPath( context);
   CGContextRoundedRect( context, rect, cornerRadius);
   strokeWithBoundsAndPaint( context, rect, strokeWidth, paint);
}



void   CGContextStrokeRectWithPaint( CGContext *context,
                                     CGRect rect,
                                     CGFloat strokeWidth,
                                     CGPaint *paint)
{
   CGContextBeginPath( context);
   CGContextRect( context, rect);
   strokeWithBoundsAndPaint( context, rect, strokeWidth, paint);
}


void   CGContextStrokeCircleWithPaint( CGContext *context, 
                                       CACircle circle,
                                       CGFloat strokeWidth,
                                       CGPaint *paint)
{
   CGRect   rect;

   CGContextBeginPath( context);
   CGContextCircle( context, circle);
   rect = CACircleGetOuterRect( circle);
   strokeWithBoundsAndPaint( context, rect, strokeWidth, paint);
}  


void   CGContextStrokeLineWithPaint( CGContext *context, 
                                     CGPoint start, 
                                     CGPoint end, 
                                     CGFloat strokeWidth,
                                     CGPaint *paint)
{
   CGRect   rect;

   CGContextBeginPath( context);
   CGContextMoveTo( context, start);
   CGContextLineTo( context, end);
   rect = CGRectMakeWithPoints( start, end);
   strokeWithBoundsAndPaint( context, rect, strokeWidth, paint);
}



void   CGContextStrokeLineHWithPaint( CGContext *context,
                                      CGPoint start,
                                      CGFloat width,
                                      CGFloat strokeWidth,
                                      CGPaint *paint)
{
   CGRect   rect;
   CGPoint  end;

   end = CGPointMake( start.x + width, start.y);
   CGContextBeginPath( context);
   CGContextMoveTo( context, start);
   CGContextLineTo( context, end);
   rect = CGRectMakeWithPoints( start, end);
   strokeWithBoundsAndPaint( context, rect, strokeWidth, paint);
}


void   CGContextStrokeLineVWithPaint( CGContext *context,
                                      CGPoint start,
                                      CGFloat height,
                                      CGFloat strokeWidth,
                                      CGPaint *paint)
{
   CGRect   rect;
   CGPoint  end;

   end = CGPointMake( start.x, start.y + height);
   CGContextBeginPath( context);
   CGContextMoveTo( context, start);
   CGContextLineTo( context, end);
   rect = CGRectMakeWithPoints( start, end);
   strokeWithBoundsAndPaint( context, rect, strokeWidth, paint);
}

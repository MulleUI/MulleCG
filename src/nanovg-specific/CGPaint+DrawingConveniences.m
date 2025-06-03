//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGPaint+DrawingConveniences.h"

#import "import-private.h"

#import "CGContext+Drawing.h"
#import "CGContext+DrawingConveniences.h"



static void   fillWithBoundsAndPaintable( CGContext *context,
                                          CGRect rect,
                                          id <CGPaintable> paintable)
{
#ifdef NIL_PAINT_DRAWS_BLACK
   if( ! paintable)
   {
      CGContextFillColor( context, CGColorMakeBlack());
      CGContextFill( context);
      return;
   }
#endif
   CGContextFillPaintable( context, paintable);
   CGContextFill( context);   
}


void   CGContextFillRoundedRectVaryingWithPaintable( CGContext *context,
                                                     CGRect rect,
                                                     MulleCornerInsets cornerInsets,
                                                     id <CGPaintable> paintable)
{
   CGContextBeginPath( context);
   CGContextRoundedRectVarying( context, rect, cornerInsets);
   fillWithBoundsAndPaintable( context, rect, paintable);
}


void   CGContextFillRoundedRectWithPaintable( CGContext *context,
                                              CGRect rect,
                                              CGFloat cornerRadius,
                                              id <CGPaintable> paintable)
{
   CGContextBeginPath( context);
   CGContextRoundedRect( context, rect, cornerRadius);
   fillWithBoundsAndPaintable( context, rect, paintable);
}



void   CGContextFillRectWithPaintable( CGContext *context,
                                       CGRect rect,
                                       id <CGPaintable> paintable)
{
   CGContextBeginPath( context);
   CGContextRect( context, rect);
   fillWithBoundsAndPaintable( context, rect, paintable);
}


void   CGContextFillCircleWithPaintable( CGContext *context, 
                                         CACircle circle,
                                         id <CGPaintable> paintable)
{
   CGRect   rect;

   CGContextBeginPath( context);
   CGContextCircle( context, circle);
   rect = CACircleGetOuterRect( circle);
   fillWithBoundsAndPaintable( context, rect, paintable);
}


static void   strokeWithBoundsAndPaint( CGContext *context,
                                        CGRect rect,
                                        CGFloat strokeWidth,
                                        id <CGPaintable> paintable)
{
   if( strokeWidth <= 0.0f)
      return;

#ifdef NIL_PAINT_DRAWS_BLACK
   if( ! paintable)
   {
      CGContextStrokeWidth( context, strokeWidth);
      CGContextStrokeColor( context, CGColorMakeBlack());
      CGContextStroke( context);
      return;
   }
#endif

   CGContextStrokeWidth( context, strokeWidth);
   CGContextStrokePaintableOptions( context,
                                        paintable,
                                        rect,
                                        strokeWidth,
                                        NULL);
   CGContextStroke( context);
}


void   CGContextStrokeRoundedRectVaryingWithPaintable( CGContext *context,
                                                       CGRect rect,
                                                       MulleCornerInsets cornerInsets,
                                                       CGFloat strokeWidth,
                                                       id <CGPaintable> paintable)
{
   CGContextBeginPath( context);
   CGContextRoundedRectVarying( context, rect, cornerInsets);
   strokeWithBoundsAndPaint( context, rect, strokeWidth, paintable);
}


void   CGContextStrokeRoundedRectWithPaintable( CGContext *context,
                                                CGRect rect,
                                                CGFloat cornerRadius,
                                                CGFloat strokeWidth,
                                                id <CGPaintable> paintable)
{
   CGContextBeginPath( context);
   CGContextRoundedRect( context, rect, cornerRadius);
   strokeWithBoundsAndPaint( context, rect, strokeWidth, paintable);
}



void   CGContextStrokeRectWithPaintable( CGContext *context,
                                         CGRect rect,
                                         CGFloat strokeWidth,
                                         id <CGPaintable> paintable)
{
   CGContextBeginPath( context);
   CGContextRect( context, rect);
   strokeWithBoundsAndPaint( context, rect, strokeWidth, paintable);
}


void   CGContextStrokeCircleWithPaintable( CGContext *context, 
                                           CACircle circle,
                                           CGFloat strokeWidth,
                                           id <CGPaintable> paintable)
{
   CGRect   rect;

   CGContextBeginPath( context);
   CGContextCircle( context, circle);
   rect = CACircleGetOuterRect( circle);
   strokeWithBoundsAndPaint( context, rect, strokeWidth, paintable);
}  


void   CGContextStrokeLineWithPaintable( CGContext *context, 
                                         CGPoint start,
                                         CGPoint end,
                                         CGFloat strokeWidth,
                                         id <CGPaintable> paintable)
{
   CGRect   rect;

   CGContextBeginPath( context);
   CGContextMoveTo( context, start);
   CGContextLineTo( context, end);
   rect = CGRectMakeWithPoints( start, end);
   strokeWithBoundsAndPaint( context, rect, strokeWidth, paintable);
}



void   CGContextStrokeLineHWithPaintable( CGContext *context,
                                          CGPoint start,
                                          CGFloat width,
                                          CGFloat strokeWidth,
                                          id <CGPaintable> paintable)
{
   CGRect   rect;
   CGPoint  end;

   end = CGPointMake( start.x + width, start.y);
   CGContextBeginPath( context);
   CGContextMoveTo( context, start);
   CGContextLineTo( context, end);
   rect = CGRectMakeWithPoints( start, end);
   strokeWithBoundsAndPaint( context, rect, strokeWidth, paintable);
}


void   CGContextStrokeLineVWithPaintable( CGContext *context,
                                          CGPoint start,
                                          CGFloat height,
                                          CGFloat strokeWidth,
                                          id <CGPaintable> paintable)
{
   CGRect   rect;
   CGPoint  end;

   end = CGPointMake( start.x, start.y + height);
   CGContextBeginPath( context);
   CGContextMoveTo( context, start);
   CGContextLineTo( context, end);
   rect = CGRectMakeWithPoints( start, end);
   strokeWithBoundsAndPaint( context, rect, strokeWidth, paintable);
}


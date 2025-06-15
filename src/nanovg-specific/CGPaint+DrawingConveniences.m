//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGPaint+DrawingConveniences.h"

#import "import-private.h"

#import "CGContext+Drawing.h"
#import "CGContext+DrawingConveniences.h"


// this is kinda important for OpenGL. Where we need to clear, even if
// there is no _backgroundPaint being set. its not bad default.
#ifndef CG_NIL_PAINT_DRAWS_BLACK
#define CG_NIL_PAINT_DRAWS_BLACK 1
#endif


static void   fillWithPaintableInBounds( CGContext *context,
                                         id <CGPaintable> paintable,
                                         CGRect rect)
{
   if( ! paintable)
   {
#if CG_NIL_PAINT_DRAWS_BLACK
      CGContextFillColor( context, CGColorMakeBlack());
      CGContextFill( context);
#endif
      return;
   }
   CGContextFillPaintableOptions( context, paintable, rect, NULL);
   CGContextFill( context);   
}


void   CGContextFillRoundedRectVaryingWithPaintable( CGContext *context,
                                                     CGRect rect,
                                                     MulleCornerInsets cornerInsets,
                                                     id <CGPaintable> paintable)
{
   CGContextBeginPath( context);
   CGContextRoundedRectVarying( context, rect, cornerInsets);
   fillWithPaintableInBounds( context, paintable, rect);

}


void   CGContextFillRoundedRectWithPaintable( CGContext *context,
                                              CGRect rect,
                                              CGFloat cornerRadius,
                                              id <CGPaintable> paintable)
{
   CGContextBeginPath( context);
   CGContextRoundedRect( context, rect, cornerRadius);
   fillWithPaintableInBounds( context, paintable, rect);

}



void   CGContextFillRectWithPaintable( CGContext *context,
                                       CGRect rect,
                                       id <CGPaintable> paintable)
{
   CGContextBeginPath( context);
   CGContextRect( context, rect);
   fillWithPaintableInBounds( context, paintable, rect);
}


void   CGContextFillCircleWithPaintable( CGContext *context, 
                                         CACircle circle,
                                         id <CGPaintable> paintable)
{
   CGRect   rect;

   CGContextBeginPath( context);
   CGContextCircle( context, circle);
   rect = CACircleGetOuterRect( circle);
   fillWithPaintableInBounds( context, paintable, rect);
}


static void   strokeWithPaintableInBounds( CGContext *context,
                                           id <CGPaintable> paintable,
                                           CGRect rect,
                                           CGFloat strokeWidth)
{
   if( strokeWidth <= 0.0f)
      return;

   if( ! paintable)
   {
#if CG_NIL_PAINT_DRAWS_BLACK
      CGContextStrokeWidth( context, strokeWidth);
      CGContextStrokeColor( context, CGColorMakeBlack());
      CGContextStroke( context);
#endif
      return;
   }

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
   strokeWithPaintableInBounds( context, paintable, rect, strokeWidth);
}


void   CGContextStrokeRoundedRectWithPaintable( CGContext *context,
                                                CGRect rect,
                                                CGFloat cornerRadius,
                                                CGFloat strokeWidth,
                                                id <CGPaintable> paintable)
{
   CGContextBeginPath( context);
   CGContextRoundedRect( context, rect, cornerRadius);
   strokeWithPaintableInBounds( context, paintable, rect, strokeWidth);
}



void   CGContextStrokeRectWithPaintable( CGContext *context,
                                         CGRect rect,
                                         CGFloat strokeWidth,
                                         id <CGPaintable> paintable)
{
   CGContextBeginPath( context);
   CGContextRect( context, rect);
   strokeWithPaintableInBounds( context, paintable, rect, strokeWidth);
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
   strokeWithPaintableInBounds( context, paintable, rect, strokeWidth);
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
   strokeWithPaintableInBounds( context, paintable, rect, strokeWidth);
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
   strokeWithPaintableInBounds( context, paintable, rect, strokeWidth);
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
   strokeWithPaintableInBounds( context, paintable, rect, strokeWidth);
}


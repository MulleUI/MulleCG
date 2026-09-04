//
//  CGPaint+DrawingConveniences.m
//  MulleCG
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
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
   //CGContextFill( context);
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


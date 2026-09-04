//
//  CGPaint+UIGraphicsDrawing.m
//  MulleCG
//
//  Copyright (c) 2025 Nat! - Mulle kybernetiK.
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
#import "CGPaint+UIGraphicsDrawing.h"

#import "import-private.h"

#import "CGContext+Drawing.h"
#import "CGGradient.h"
#import "CGPaintable.h"
#import "CGPaint+Private.h"


@implementation CGPaint ( UIGraphicsDrawing)

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
      .relation = CGOverlap
   };
   options.paint.alpha = alpha;

   CGContextStrokePaintableOptions( context, self, rect, strokeWidth, &options);
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
      .relation = CGOverlap
   };
   options.paint.alpha = alpha;

   CGContextFillPaintableOptions( context, self, rect, &options);
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


@implementation _CGMonoColor( Drawing)

- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
                    alpha:(CGFloat) alpha
                  context:(CGContext *) context
{
   MULLE_C_UNUSED( rect);
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
   MULLE_C_UNUSED( rect);
   CGColor   color;

   if( alpha <= 0.0)
      return;

   color = alpha >= 1.0 ? _color : CGColorMultiplyAlpha( _color, alpha);
   CGContextFillColor( context, color);
   CGContextFill( context);
}

@end


void   CGContextFillRoundedRectWithGradientColors( CGContext *context,
                                                   CGRect rect,
                                                   CGFloat cornerRadius,
                                                   CGColor startColor,
                                                   CGColor endColor,
                                                   CARotation colorRotation)
{
   CGContextBeginPath( context);
   CGContextRoundedRect( context, rect, cornerRadius);
   CGContextFillGradientColors( context, rect, startColor, endColor, colorRotation);
   CGContextFill( context);
}


void   CGContextStrokeRoundedRectWithGradientColors( CGContext *context,
                                                     CGRect rect,
                                                     CGFloat cornerRadius,
                                                     CGColor startColor,
                                                     CGColor endColor,
                                                     CARotation colorRotation,
                                                     CGFloat strokeWidth)
{
   if( strokeWidth <= 0.0)
      return;

   CGContextBeginPath( context);
   CGContextRoundedRect( context, rect, cornerRadius);
   CGContextStrokeGradientColors( context, rect, startColor, endColor, colorRotation, strokeWidth);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}


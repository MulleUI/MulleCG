//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGPaint+UIGraphicsDrawing.h"

#import "import-private.h"

#import "CGContext+Drawing.h"
#import "CGPaint+Drawing.h"
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
      .relation = CGCover
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


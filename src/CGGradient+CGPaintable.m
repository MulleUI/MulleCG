//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGGradient.h"
#import "CGPaintable.h"
#import "CGContext+Drawing.h"

#import "import-private.h"

#include <math.h>


// helper: compute linear gradient endpoints from rotation + rect
static void   _linearGradientPoints( CGRect rect,
                                     CARotation rotation,
                                     CGFloat smoothness,
                                     BOOL isRectangular,
                                     CGPoint *start,
                                     CGPoint *end)
{
   CGFloat   radians;
   CGFloat   w, h;
   CGPoint   center;
   CGFloat   size;

   radians = CARotationToRadiansAsAngle( rotation);
   if( isRectangular)
   {
      w = rect.size.width * cosf( radians) * smoothness;
      h = rect.size.height * sinf( radians) * smoothness;
   }
   else
   {
      size = CGRectGetMinimumSize( rect);
      w    = size * cosf( radians) * smoothness;
      h    = size * sinf( radians) * smoothness;
   }

   center  = CGRectGetCenter( rect);
   *start  = CGPointMake( center.x - w / 2.0, center.y - h / 2.0);
   *end    = CGPointMake( start->x + w, start->y + h);
}


@implementation CGGradient( CGPaintable)

- (void) fillWithBounds:(CGRect) bounds
                options:(struct CGFillOptions *) options
                context:(CGContext *) context
{
   CGPoint   start, end;
   CGColor   startColor, endColor;
   CGFloat   alpha;

   assert( options);

#ifdef DEBUG
   if( isinf( bounds.origin.x))
   {
      mulle_fprintf( stderr, "The standard linear gradient must be used with"
                             "\"CGContextFillPaintableOptions\" and proper "
                             "bounds being specified\n");
      abort();
   }
#endif

   startColor = [self startColor];
   endColor   = [self endColor];
   alpha      = options->paint.alpha;
   if( alpha < 0.0)
      alpha = 0.0;
   startColor = CGColorMultiplyAlpha( startColor, alpha);
   endColor   = CGColorMultiplyAlpha( endColor, alpha);

   _linearGradientPoints( bounds,
                          options->paint.rotation + [self rotation],
                          options->paint.smoothness,
                          YES,
                          &start, &end);

   CGContextSetFillLinearGradient( context, start, end, startColor, endColor);
   CGContextFill( context);
}


- (void) strokeWithBounds:(CGRect) bounds
              strokeWidth:(CGFloat) strokeWidth
                  options:(struct CGStrokeOptions *) options
                  context:(CGContext *) context
{
   CGPoint   start, end;
   CGColor   startColor, endColor;
   CGFloat   alpha;

   assert( options);
   assert( strokeWidth > 0.0f);

   startColor = [self startColor];
   endColor   = [self endColor];
   alpha      = options->paint.alpha;
   if( alpha < 0.0)
      alpha = 0.0;
   startColor = CGColorMultiplyAlpha( startColor, alpha);
   endColor   = CGColorMultiplyAlpha( endColor, alpha);

   _linearGradientPoints( bounds,
                          options->paint.rotation + [self rotation],
                          options->paint.smoothness,
                          YES,
                          &start, &end);

   CGContextSetStrokeLinearGradient( context, start, end, startColor, endColor);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}

@end


@implementation CGLinearGradient( CGPaintable)

- (void) fillWithBounds:(CGRect) bounds
                options:(struct CGFillOptions *) options
                context:(CGContext *) context
{
   CGColor      startColor, endColor;
   CARotation   rotation;

   assert( options);

   startColor = CGColorMultiplyAlpha( [self startColor], options->paint.alpha);
   endColor   = CGColorMultiplyAlpha( [self endColor], options->paint.alpha);
   rotation   = options->paint.rotation + [self rotation];

   if( ! CGPointIsNull( [self startPoint]))
   {
      if( rotation == 0.0)
      {
         CGContextSetFillLinearGradient( context, [self startPoint], [self endPoint], startColor, endColor);
         CGContextFill( context);
         return;
      }
      bounds = CGRectMakeWithOriginAndSize( [self startPoint],
                  CGSizeMake( [self endPoint].x - [self startPoint].x,
                              [self endPoint].y - [self startPoint].y));
   }

   bounds = CGRectRotate( bounds, rotation);
   CGContextSetFillLinearGradient( context, CGRectGetOrigin( bounds), CGRectGetOpposite( bounds), startColor, endColor);
   CGContextFill( context);
}


- (void) strokeWithBounds:(CGRect) bounds
              strokeWidth:(CGFloat) strokeWidth
                  options:(struct CGStrokeOptions *) options
                  context:(CGContext *) context
{
   CGColor      startColor, endColor;
   CARotation   rotation;

   assert( options);
   assert( strokeWidth > 0.0f);

   startColor = CGColorMultiplyAlpha( [self startColor], options->paint.alpha);
   endColor   = CGColorMultiplyAlpha( [self endColor], options->paint.alpha);
   rotation   = options->paint.rotation + [self rotation];

   if( ! CGPointIsNull( [self startPoint]))
   {
      if( rotation == 0.0)
      {
         CGContextSetStrokeLinearGradient( context, [self startPoint], [self endPoint], startColor, endColor);
         CGContextStrokeWidth( context, strokeWidth);
         CGContextStroke( context);
         return;
      }
      bounds = CGRectMakeWithOriginAndSize( [self startPoint],
                  CGSizeMake( [self endPoint].x - [self startPoint].x,
                              [self endPoint].y - [self startPoint].y));
   }

   bounds = CGRectRotate( bounds, rotation);
   CGContextSetStrokeLinearGradient( context, CGRectGetOrigin( bounds), CGRectGetOpposite( bounds), startColor, endColor);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}

@end


@implementation CGBoxGradient( CGPaintable)

- (void) fillWithBounds:(CGRect) bounds
                options:(struct CGFillOptions *) options
                context:(CGContext *) context
{
   CGColor   startColor, endColor;

   assert( options);

   startColor = CGColorMultiplyAlpha( [self startColor], options->paint.alpha);
   endColor   = CGColorMultiplyAlpha( [self endColor], options->paint.alpha);

   if( ! CGRectIsNull( [self rect]))
      bounds = [self rect];

   CGContextSetFillBoxGradient( context, bounds, [self cornerRadius], startColor, [self feather], endColor);
   CGContextFill( context);
}


- (void) strokeWithBounds:(CGRect) bounds
              strokeWidth:(CGFloat) strokeWidth
                  options:(struct CGStrokeOptions *) options
                  context:(CGContext *) context
{
   CGColor   startColor, endColor;

   assert( options);
   assert( strokeWidth > 0.0f);

   startColor = CGColorMultiplyAlpha( [self startColor], options->paint.alpha);
   endColor   = CGColorMultiplyAlpha( [self endColor], options->paint.alpha);

   if( ! CGRectIsNull( [self rect]))
      bounds = [self rect];

   CGContextSetStrokeBoxGradient( context, bounds, [self cornerRadius], startColor, [self feather], endColor);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}

@end


@implementation CGRadialGradient( CGPaintable)

- (void) fillWithBounds:(CGRect) bounds
                options:(struct CGFillOptions *) options
                context:(CGContext *) context
{
   CGColor    startColor, endColor;
   CACircle   circle;

   assert( options);

   startColor = CGColorMultiplyAlpha( [self startColor], options->paint.alpha);
   endColor   = CGColorMultiplyAlpha( [self endColor], options->paint.alpha);

   circle = CACircleIsNull( [self circle]) ? CGRectGetOuterCircle( bounds) : [self circle];

   CGContextSetFillRadialGradient( context, circle, startColor, [self innerRadius], endColor);
   CGContextFill( context);
}


- (void) strokeWithBounds:(CGRect) bounds
              strokeWidth:(CGFloat) strokeWidth
                  options:(struct CGStrokeOptions *) options
                  context:(CGContext *) context
{
   CGColor    startColor, endColor;
   CACircle   circle;

   assert( options);
   assert( strokeWidth > 0.0f);

   startColor = CGColorMultiplyAlpha( [self startColor], options->paint.alpha);
   endColor   = CGColorMultiplyAlpha( [self endColor], options->paint.alpha);

   circle = CACircleIsNull( [self circle]) ? CGRectGetOuterCircle( bounds) : [self circle];

   CGContextSetStrokeRadialGradient( context, circle, startColor, [self innerRadius], endColor);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}

@end


void   CGContextFillLinearGradient( CGContext *context, CGPoint start, CGPoint end, CGColor startColor, CGColor endColor)
{
   CGContextSetFillLinearGradient( context, start, end, startColor, endColor);
}

void   CGContextStrokeLinearGradient( CGContext *context, CGPoint start, CGColor startColor, CGPoint end, CGColor endColor, CGFloat strokeWidth)
{
   CGContextSetStrokeLinearGradient( context, start, end, startColor, endColor);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}

void   CGContextFillBoxGradient( CGContext *context, CGRect rect, CGFloat cornerRadius, CGColor color, CGFloat feather, CGColor featherColor)
{
   CGContextSetFillBoxGradient( context, rect, cornerRadius, color, feather, featherColor);
}

void   CGContextStrokeBoxGradient( CGContext *context, CGRect rect, CGFloat cornerRadius, CGColor color, CGFloat feather, CGColor featherColor, CGFloat strokeWidth)
{
   rect = CGRectMakeStrokeRect( rect, strokeWidth, CGOutside);
   CGContextSetStrokeBoxGradient( context, rect, cornerRadius, color, feather, featherColor);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}

void   CGContextFillRadialGradient( CGContext *context, CACircle circle, CGColor color, CGFloat innerRadius, CGColor innerColor)
{
   CGContextSetFillRadialGradient( context, circle, color, innerRadius, innerColor);
}

void   CGContextStrokeRadialGradient( CGContext *context, CACircle circle, CGColor color, CGFloat innerRadius, CGColor innerColor, CGFloat strokeWidth)
{
   CGRect   rect;

   rect = CGRectMakeStrokeRect( CACircleGetOuterRect( circle), strokeWidth, CGOutside);
   CGContextSetStrokeRadialGradient( context, CGRectGetInnerCircle( rect), color, innerRadius, innerColor);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}

void   CGContextFillGradientColors( CGContext *context, CGRect rect, CGColor startColor, CGColor endColor, CGFloat colorRotation)
{
   CGPoint   start, end;

   _linearGradientPoints( rect, colorRotation, 1.0f, YES, &start, &end);
   CGContextSetFillLinearGradient( context, start, end, startColor, endColor);
}

void   CGContextStrokeGradientColors( CGContext *context, CGRect rect, CGColor startColor, CGColor endColor, CGFloat colorRotation, CGFloat strokeWidth)
{
   CGPoint   start, end;

   if( strokeWidth <= 0.0)
      return;
   rect = CGRectMakeStrokeRect( rect, strokeWidth, CGOutside);
   _linearGradientPoints( rect, colorRotation, 1.0f, YES, &start, &end);
   CGContextSetStrokeLinearGradient( context, start, end, startColor, endColor);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}

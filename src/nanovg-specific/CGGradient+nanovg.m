//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGGradient.h"

#import "import-private.h"

#include "nanowrap.h"
#include <math.h>

#import "CGContext.h"
#import "CGContext+Drawing.h"


@implementation CGGradient ( nanovg)

static NVGpaint
   _NVGpaintWithGradientValues( CGColor startColor,
                                CGColor endColor,
                                CARotation rotation,
                                CGRect rect,
                                CGFloat smoothness,
                                BOOL isRectangular,
                                NVGcontext *vg)
{
   CGFloat      radians;
   CGFloat      w, h;
   CGPoint      end;
   CGPoint      start;
   CGPoint      center;
   NVGpaint     paint;
   CGFloat      size;

   assert( vg);

   radians  = CARotationToRadiansAsAngle( rotation);
   if( isRectangular)
   {
      w     = rect.size.width * cosf( radians) * smoothness;
      h     = rect.size.height * sinf( radians) * smoothness;
   }
   else
   {
      size  = CGRectGetMinimumSize( rect);
      w     = size * cosf( radians) * smoothness;
      h     = size * sinf( radians) * smoothness;
   }

   center   = CGRectGetCenter( rect);
   start    = CGPointMake( center.x - w / 2.0, center.y - h / 2.0);
   end      = CGPointMake( start.x + w, start.y + h);

   paint    = nvgLinearGradient( vg, start.x, start.y, end.x, end.y, startColor, endColor);
   return( paint);
}


static inline NVGpaint
   CGGradientNVGpaintForRect( CGGradient *self,
                              CGRect rect,
                              CARotation rotation,
                              CGFloat smoothness,
                              CGFloat alpha,
                              BOOL isRectangular,
                              NVGcontext *vg)
{
   CGColor   startColor;
   CGColor   endColor;

   assert( vg);

   startColor = [self startColor];
   endColor   = [self endColor];

   if( alpha < 0.0)
      alpha = 0.0;

   startColor = CGColorMultiplyAlpha( startColor, alpha);
   endColor   = CGColorMultiplyAlpha( endColor, alpha);

   return( _NVGpaintWithGradientValues( startColor, endColor, rotation, rect, smoothness, isRectangular, vg));
}



- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                   paintOptions:(struct CGPaintOptions *) options
                        context:(CGContext *) context
{
   NVGpaint   paint;

   assert( options);

#ifdef DEBUG
   if( isinf( rect.origin.x))
   {
      mulle_fprintf( stderr, "The standard linear gradient must be used with"
                             "\"CGContextFillPaintableOptions\" and proper "
                             "bounds being specified\n");
      abort();
   }
#endif

   paint = CGGradientNVGpaintForRect( self,
                                      rect,
                                      options->rotation + _rotation,
                                      options->smoothness,
                                      options->alpha,
                                      YES,
                                      CGContextGetNVGContext( context));
   return( paint);
}

@end


@implementation CGLinearGradient ( nanovg)

- (NVGpaint) NVGpaintWithBounds:(CGRect) bounds
                   paintOptions:(struct CGPaintOptions *) options
                        context:(CGContext *) context
{
   NVGpaint     paint;
   NVGcontext   *vg;
   CGColor      startColor;
   CGColor      endColor;
   CARotation   rotation;

   assert( options);
   assert( options->alpha >= 0.0 && options->alpha <= 1.0);

   startColor = CGColorMultiplyAlpha( _startColor, options->alpha);
   endColor   = CGColorMultiplyAlpha( _endColor, options->alpha);

   // we ignore the incoming rect as we have a rect already

   vg       = CGContextGetNVGContext( context);
   rotation = options->rotation + _rotation;
   if( ! CGPointIsNull( _startPoint))
   {
      if( rotation == 0.0)
      {
         paint  = mvgLinearGradient( vg, _startPoint, startColor,
                                         _endPoint, endColor);
         return( paint);
      }
      // Fix: Use CGRectMakeWithOriginAndSize instead of CGRectMakeWithOriginAndOpposite
      bounds = CGRectMakeWithOriginAndSize( _startPoint, CGSizeMake( _endPoint.x - _startPoint.x, _endPoint.y - _startPoint.y));
   }

   bounds = CGRectRotate( bounds, rotation);
   paint  = mvgLinearGradient( vg, CGRectGetOrigin( bounds), startColor,
                                   CGRectGetOpposite( bounds), endColor);
   return( paint);
}

@end


@implementation CGBoxGradient ( nanovg)

- (NVGpaint) NVGpaintWithBounds:(CGRect) bounds
                   paintOptions:(struct CGPaintOptions *) options
                        context:(CGContext *) context
{
   NVGpaint     paint;
   NVGcontext   *vg;
   CGColor      startColor;
   CGColor      endColor;

   assert( options);
   assert( options->alpha >= 0.0 && options->alpha <= 1.0);

   startColor = CGColorMultiplyAlpha( _startColor, options->alpha);
   endColor   = CGColorMultiplyAlpha( _endColor, options->alpha);

   if( ! CGRectIsNull( _rect))
      bounds = _rect;

   vg    = CGContextGetNVGContext( context);
   paint = mvgBoxGradient( vg, bounds,
                               _cornerRadius,
                               startColor,
                               _feather,
                               endColor);
   return( paint);
}

@end


@implementation CGRadialGradient( nanovg)

- (NVGpaint) NVGpaintWithBounds:(CGRect) bounds
                   paintOptions:(struct CGPaintOptions *) options
                        context:(CGContext *) context
{
   NVGpaint     paint;
   NVGcontext   *vg;
   CACircle     circle;
   CGColor      startColor;
   CGColor      endColor;

   assert( options);
   assert( options->alpha >= 0.0 && options->alpha <= 1.0);

   startColor = CGColorMultiplyAlpha( _startColor, options->alpha);
   endColor   = CGColorMultiplyAlpha( _endColor, options->alpha);

   if( CACircleIsNull( _circle))
      circle = CGRectGetOuterCircle( bounds);
   else
      circle = _circle;

   vg     = CGContextGetNVGContext( context);
   paint  = nvgRadialGradient( vg, circle.center.x,
                                   circle.center.y,
                                   _innerRadius,
                                   circle.radius,
                                   startColor,
                                   endColor);
   return( paint);
}

@end


void   CGContextFillLinearGradient( CGContext *context,
                                    CGPoint start,
                                    CGColor startColor,
                                    CGPoint end,
                                    CGColor endColor)
{
   NVGpaint     paint;
   NVGcontext   *vg;

   vg    = CGContextGetNVGContext( context);
   paint = mvgLinearGradient( vg, start, startColor, end, endColor);
   mvgFillPaint( vg, paint);
}


void   CGContextStrokeLinearGradient( CGContext *context,
                                      CGPoint start,
                                      CGColor startColor,
                                      CGPoint end,
                                      CGColor endColor,
                                      CGFloat strokeWidth)
{
   NVGpaint     paint;
   NVGcontext   *vg;

   vg    = CGContextGetNVGContext( context);
   paint = mvgLinearGradient( vg, start, startColor, end, endColor);
   mvgStrokePaint( vg, paint);
}



void   CGContextFillBoxGradient( CGContext *context,
                                 CGRect rect,
                                 CGFloat cornerRadius,
                                 CGColor color,
                                 CGFloat feather,
                                 CGColor featherColor)
{
   NVGpaint     paint;
   NVGcontext   *vg;

   vg    = CGContextGetNVGContext( context);
   paint = mvgBoxGradient( vg, rect, cornerRadius, color, feather, featherColor);
   mvgFillPaint( vg, paint);
}


void   CGContextStrokeBoxGradient( CGContext *context,
                                   CGRect rect,
                                   CGFloat cornerRadius,
                                   CGColor color,
                                   CGFloat feather,
                                   CGColor featherColor,
                                   CGFloat strokeWidth)
{
   NVGpaint     paint;
   NVGcontext   *vg;

   vg    = CGContextGetNVGContext( context);
   rect  = CGRectMakeStrokeRect( rect, strokeWidth, CGOutside);
   paint = mvgBoxGradient( vg, rect, cornerRadius, color, feather, featherColor);
   mvgStrokePaint( vg, paint);
}


void   CGContextFillRadialGradient( CGContext *context,
                                    CACircle circle,
                                    CGColor color,
                                    CGFloat innerRadius,
                                    CGColor innerColor)
{
   NVGpaint     paint;
   NVGcontext   *vg;

   vg    = CGContextGetNVGContext( context);
   paint = mvgRadialGradient( vg, circle, color, innerRadius, innerColor);
   mvgFillPaint( vg, paint);
}


void   CGContextStrokeRadialGradient( CGContext *context,
                                      CACircle circle,
                                      CGColor color,
                                      CGFloat innerRadius,
                                      CGColor innerColor,
                                      CGFloat strokeWidth)
{
   NVGpaint     paint;
   NVGcontext   *vg;
   CGRect       rect;

   vg    = CGContextGetNVGContext( context);
   rect  = CGRectMakeStrokeRect( CACircleGetOuterRect( circle), strokeWidth, CGOutside);
   paint = mvgRadialGradient( vg, CGRectGetInnerCircle( rect), color, innerRadius, innerColor);
   mvgFillPaint( vg, paint);
}


void   CGContextFillGradientColors( CGContext *context,
                                    CGRect rect,
                                    CGColor startColor,
                                    CGColor endColor,
                                    CGFloat colorRotation)
{
   NVGpaint     nvgPaint;
   NVGcontext   *vg;

   vg       = CGContextGetNVGContext( context);
   nvgPaint = _NVGpaintWithGradientValues( startColor, endColor,
                                           colorRotation,
                                           rect,
                                           1.0f,
                                           YES,
                                           vg);
   nvgFillPaint( vg, nvgPaint);
}


void   CGContextStrokeGradientColors( CGContext *context,
                                      CGRect rect,
                                      CGColor startColor,
                                      CGColor endColor,
                                      CGFloat colorRotation,
                                      CGFloat strokeWidth)
{
   NVGpaint     nvgPaint;
   NVGcontext   *vg;

   if( strokeWidth <= 0.0)
      return;

   vg       = CGContextGetNVGContext( context);
   rect     = CGRectMakeStrokeRect( rect, strokeWidth, CGOutside);
   nvgPaint = _NVGpaintWithGradientValues( startColor, endColor,
                                           colorRotation,
                                           rect,
                                           1.0f,
                                           YES,
                                           vg);
   nvgStrokePaint( vg, nvgPaint);
}

//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGGradient+nanovg.h"

#import "import-private.h"

#include "microvg.h"
#include <math.h>

#import "CGContext.h"
#import "CGContext+Drawing.h"


@implementation CGGradient ( nanovg)

static NVGpaint
   _NVGpaintWithGradientValues( CGColor startColor,
                                CGColor endColor,
                                CGRect rect,
                                CARotation rotation,
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

   radians  = CARotationToRadians( rotation);
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

   center   = CGRectGetCenterPoint( rect);
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

   return( _NVGpaintWithGradientValues( startColor, endColor, rect, rotation, smoothness, isRectangular, vg));
}



- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                   paintOptions:(struct CGPaintOptions *) options
                        context:(CGContext *) context
{
   NVGpaint   paint;

   assert( options);

   paint = CGGradientNVGpaintForRect( self,
                                      rect,
                                      options->rotation,
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
   CGFloat      rotation;

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
      bounds = CGRectMakeWithOriginAndOpposite( _startPoint, _endPoint);
   }

   bounds = CGRectRotate( bounds, rotation);
   paint  = mvgLinearGradient( vg, CGRectGetOriginPoint( bounds), startColor,
                                   CGRectGetOppositePoint( bounds), endColor);
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


// will use radialGradient!
void   CGContextFillCircleWithGradientColors( CGContext *context,
                                              CACircle circle,
                                              CGColor outerColor,
                                              CGColor innerColor)
{
   NVGpaint     nvgPaint;
   NVGcontext   *vg;

   vg        = CGContextGetNVGContext( context);
   nvgPaint  = nvgRadialGradient( vg, circle.center.x,
                                      circle.center.y,
                                      0.0,
                                      circle.radius,
                                      outerColor,
                                      innerColor);
   nvgFillPaint( vg, nvgPaint);
   nvgFill( vg);
}


void   CGContextStrokeCircleWithGradientColors( CGContext *context,
                                                CACircle circle,
                                                CGFloat strokeWidth,
                                                CGColor outerColor,
                                                CGColor innerColor)
{
   NVGpaint     nvgPaint;
   NVGcontext   *vg;

   if( strokeWidth <= 0.0)
      return;

   vg        = CGContextGetNVGContext( context);
   nvgPaint  = nvgRadialGradient( vg, circle.center.x,
                                      circle.center.y,
                                      0.0,
                                      circle.radius - strokeWidth / 2.0,  // guess
                                      outerColor,
                                      innerColor);
   nvgStrokePaint( vg, nvgPaint);
   nvgStrokeWidth( vg, strokeWidth);
   nvgStroke( vg);
}



void   CGContextFillRoundedRectWithGradientColors( CGContext *context,
                                                   CGRect rect,
                                                   CGFloat cornerRadius,
                                                   CGFloat feather,
                                                   CGColor startColor,
                                                   CGColor endColor,
                                                   CGFloat rotation)
{
   NVGpaint     nvgPaint;
   NVGcontext   *vg;

   vg       = CGContextGetNVGContext( context);
   nvgPaint = _NVGpaintWithGradientValues( startColor, endColor,
                                           rect,
                                           rotation,
                                           1.0f,
                                           YES,
                                           vg);
   nvgFillPaint( vg, nvgPaint);
   nvgFill( vg);
}


void   CGContextStrokeRectWithGradientColors( CGContext *context,
                                              CGRect rect,
                                              CGFloat strokeWidth,
                                              CGColor startColor,
                                              CGColor endColor,
                                              CGFloat rotation)
{
   NVGpaint     nvgPaint;
   NVGcontext   *vg;

   if( strokeWidth <= 0.0)
      return;

   rect     = CGRectMakeStrokeRect( rect, strokeWidth, CGOutside);
   vg       = CGContextGetNVGContext( context);
   nvgPaint = _NVGpaintWithGradientValues( startColor, endColor,
                                           rect,
                                           rotation,
                                           1.0f,
                                           YES,
                                           vg);
   nvgStrokePaint( vg, nvgPaint);
   nvgStrokeWidth( vg, strokeWidth);
   nvgStroke( vg);
}



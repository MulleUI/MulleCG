//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>
#include <time.h>


#include "bitmap2.inc"



static void   draw_triangle_with_centroid( CGContext *context,
                                           CGPoint center,
                                           CGSize  size,
                                           CARotation rotation,
                                           CGPaint *paint,
                                           CGFloat centroidRadius,
                                           CGPaint *centroidPaint,
                                           int rotateAroundCentroid)
{
   static CGPoint  points[ 3] =
   {
      CGPointData(  0.0, -0.5),
      CGPointData( -0.5,  0.5),
      CGPointData(  0.5,  0.5)
   };
   CGAffineTransform   xform;
   CGRect              rect;
   CGFloat             scale;
   CGPoint             massCenter;
   CGPoint             translated;
   CACircle            circle;

   scale = CGSizeGetMaximum( size);
   CGContextSave( context);
   {
      massCenter = CGPointTriangleGetCentroid( points[ 0], points[ 1], points[ 2]);

      // STEPS are all applied in reverse to the path

      // 5. move center of scaled triangle to destination
      CGContextTranslate( context, center);

      // 4. scale (still center at 0.0)
      CGContextScale( context, CGVectorMake( size.width, size.height));

      // 3. move "unity" triangle back down if needed
//      if( rotateAroundCentroid)
//         CGContextTranslate( context, CGPointMake( +massCenter.x, // Converted from mvgTranslate
//                                         +massCenter.y));

      // 2. rotate around center
      CGContextRotate( context, rotation);

      // 1. move "unity" triangle up if needed
      if( rotateAroundCentroid)
      CGContextTranslate( context, CGPointNegate( massCenter));
      CGContextBeginPath( context);
      CGContextMoveTo( context, points[ 0]);
      CGContextLineTo( context, points[ 1]);
      CGContextLineTo( context, points[ 2]);
      CGContextClosePath( context);

      rect = CGRectMakeWithCenterAndSize( CGPointZero, CGSizeMake( 1.0, 1.0));
      [paint fillWithBounds:rect
                    context:context];


      xform      = CGContextCurrentTransform( context);
      translated = CGPointApplyAffineTransform( massCenter, xform);
   }
   CGContextRestore( context);

   circle = CACircleMakeWithCenterAndRadius( translated, centroidRadius);
   CGContextFillCircleWithPaint( context, circle, centroidPaint);
}



static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   NSUInteger   frameNr;
   CARotation   rotation;
   CGRect       canvas;
   CGRect       rect;
   // Delete: NVGcontext   *vg;
   CGRect       rects[ 2][ 2];
   NSUInteger   i, j;
   CGPaint      *paint;
   CGPaint      *centroidPaint;
   CGPoint      center;
   CGSize       size;

   frameNr  = [context numberOfFrames] % 240;
//   rotation = frameNr > 120
//              ? (frameNr % 120) / 120.0f + 0.25
//              : 0.25f;
//
   rotation = (frameNr % 120) / 120.0f + 0.25;

   canvas   = [layer canvas];
   // Delete: vg       = CGContextGetNVGContext( context);

   CGRectPartition2x2( CGRectInset( canvas, 10, 10),
                       CGSizeMake( 10, 10),
                       rects);

   for( j = 0; j < 2; j++)
   {
      if( j == 1)
      {
         paint = [[[CGImage alloc] initWithRGBABytes:bitmap2
                                       bitmapSize:CGPixelSizeMake( 32, 32)
                                     textureFlags:NVG_IMAGE_REPEATX|NVG_IMAGE_REPEATY  // NVG_IMAGE_REPEATX
                                          context:context] autorelease];
      }
      else
         paint = [CGPaint paintWithStartColor:CGColorMakeIndigo()
                                     endColor:CGColorMakeBlue()];

      centroidPaint = [CGPaint paintWithColor:CGColorMakeWhite()];
      for( i = 0; i < 2; i++)
      {
         rect   = rects[ j][ i];
         center = CGRectGetCenter( rect);
         size   = CGSizeMake( rect.size.width * 2.0 / 3.0,
                              rect.size.height * 2.0 / 3.0);

         CGContextStrokeRectWithColor( context, CGRectMakeWithCenterAndSize( center, size), 1.0, CGColorMakeOrange());

         draw_triangle_with_centroid( context, center, size, rotation, paint, 5.0, centroidPaint, i == 1);

         CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( center, 3.0), CGColorMakeOrange());
      }
   }
   return( YES);
}

int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 200, 200),
                                           NULL,
                                           30.0f));
}

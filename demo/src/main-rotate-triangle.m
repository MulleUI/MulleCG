#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>
#include <time.h>


#include "bitmap2.inc"



static void   draw_triangle_with_centroid( NVGcontext *vg,
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
   float      xform[ 6];
   CGRect     rect;
   CGFloat    scale;
   CGPoint    massCenter;
   CACircle   circle;
   float      xy[ 2];

   scale = CGSizeGetMaximum( size);
   mvgSave( vg);
   {
      massCenter = CGPointTriangleGetCentroid( points[ 0], points[ 1], points[ 2]);

      // STEPS are all applied in reverse to the path

      // 5. move center of scaled triangle to destination
      mvgTranslate( vg, center);

      // 4. scale (still center at 0.0)
      mvgScale( vg, CGVectorMake( size.width, size.height));

      // 3. move "unity" triangle back down if needed
//      if( rotateAroundCentroid)
//         mvgTranslate( vg, CGPointMake( +massCenter.x,
//                                        +massCenter.y));

      // 2. rotate around center
      mvgRotate( vg, rotation);

      // 1. move "unity" triangle up if needed
      if( rotateAroundCentroid)
         mvgTranslate( vg, CGPointMake( -massCenter.x,
                                        -massCenter.y));

      mvgBeginPath( vg);
      mvgMoveTo( vg, points[ 0]);
      mvgLineTo( vg, points[ 1]);
      mvgLineTo( vg, points[ 2]);
      mvgClosePath( vg);

      rect = CGRectMakeWithCenterPointAndSize( CGPointZero, CGSizeMake( 1.0, 1.0));
      [paint fillWithBounds:rect
                 NVGcontext:vg];


      mvgCurrentTransform( vg, xform);
      nvgTransformPoint( &xy[ 0], &xy[ 1], xform, massCenter.x, massCenter.y);
   }
   mvgRestore( vg);

   circle = CACircleMake( CGPointMake( xy[ 0], xy[ 1]), centroidRadius);
   mvgFillCircleWithPaint( vg, circle, centroidPaint);
}



static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   NSUInteger   frameNr;
   CARotation   rotation;
   CGRect       canvas;
   CGRect       rect;
   NVGcontext   *vg;
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
   vg       = CGContextGetNVGContext( context);

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
         center = CGRectGetCenterPoint( rect);
         size   = CGSizeMake( rect.size.width * 2.0 / 3.0,
                              rect.size.height * 2.0 / 3.0);

         mvgStrokeRectWithColor( vg, CGRectMakeWithCenterPointAndSize( center, size), 1.0, CGColorMakeOrange());

         draw_triangle_with_centroid( vg, center, size, rotation, paint, 5.0, centroidPaint, i == 1);

         mvgFillCircleWithColor( vg, CACircleMake( center, 3.0), CGColorMakeOrange());
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





//
//                           ,╓≤æKª╨╙╙▓█D"╙╙╙*╨¥W▄╓,
//                      ╓▄ª╙└╧▓        █           ⁿ▓▓ª╦w
//                  ╓#╜^*█⌐   `╕       █           ╓▌    `╙%w
//               ╓ΦΓ      █    ╙⌐     ,█,,,Φ      ╓▌         ╙¥▄
//            ,▄▀ █▄       █µ,╓╝,╓≤╗≡≡ª╨╨╨¥≡∞╗w╓,ª█,  ,       ]▄▀V,
//          ,Φ└   ║"▀▄     ,▄▀╨"                 "╙¥▓▓       ▄▀  º▄¥,
//        ,#▌Φ▓▄╓  Φ `█Q▄M╙                           ╙¥▄ ,▄▀ ╙▄⌐`  `Φ
//       ▄▀   `V,"▀▀¼╓╩└                                 ╙¥▓╗ ,       ╙▄
//      Φ       `¥═▄▀                            ╒          ▀▄          ▓
//    .▓         ╓▓]V▄H       ▓                 ,Å            ▀,         ▀
//    █      ,-ª▓╛  `██▀½      "▄  ,╓╓╓╓;╓▄▄▄▄╗▄█,             ╙▄         ▀
//   █  `██▄   ▓. - Φ█═.~     ,≤█▄▀-      `   █└"▀▀▀▀▄╓╓╓╓       ▌    ██▄, █
//  ║⌐  " ▀   ▓╨⌐   }▀`      ,█  `           █      .█▀▄▄███▄     ▌  ` ▀    ▌
//  ▌        ▐M A   '┴      ▌                ▀        ╙█▌████▌    ╙▄        ║⌐
// ║⌐        █⌐'║▄ Γr2«    ║▀                 ▄▄▄      ╙▌▄███      █         ▌
// █]     ,▄▐H  ██████═ª  ╓` ▄█▀▀▀▀█▄        ████     ╓███` `╙╙║█  ▐H        █
// █ "% ,▄▀ ║░╠K█═╣███^   ╛╓█▀      ▐█         ,╓╓═ª╙└   █      ╙█▄▐▌▓######▌╫
// █║▄▄▄█▄▄▄║H:  "╙▀███▄╓▄,█▌╓▄,,▄∩  ██p$ΦΦ▀▀▀▀▀ΦΦΦR≡≥▄╓ ║▄       ╙j▌` ▄▀╙╗ `╫
// █"      ╙▐H-═M ▄███████¥█H "^╙    '█, ,«^``     `     ║▌        ▐M▄▀    "Φ█
// ║        !█▄▄████≤═^`╓█ █▌╓▀╦▄▀█   ╙█⌐               ╓█▌        ▓ `       █
//  ▌      ,▄██╫██ ▄█═╜" █▌▐█╣Hj⌐ █    █▌╙¥w,           ██▄       ╓▌        ▐M
//  ╢"▄▄#▀▀╙╟█Ü███▀`▀█  ║██J█▄▌jH █    ██    ╙▀W▄;    ,██  `╙w,   █▄     ,╓ █
//   █╙     ▐███▌▀█w ▀█ ╠██████j▌║█▌   ▀██▄       `╙▓██▀w,     ╙╗█'`"▀█▀╙"`║`
//   ╙▌     Φ████████▄██ ███████████    ═██▀W▄,   ╓█▀└         ╓▀ "    ╙▄ ╓▀
//    ╙▄     ╙▀███╙█▄▐██▄,╙▀█████▄▀▄▀▄   ,█M╗ ▀▄██▀╙""*ⁿ═─≈-,,▄▌,        ▄▀
//     `▌╙µ,▄Φ▀x███▄██████████▀V███▀╙└ ,▄#▌████▀`"*«,      .█▀▄▀▄,      ▄╛
//       ▀Ö█  ;▓████████▄▄█▀▄╙W "V▄██▀▀│▄███▀└ ▀╦     "*═╥▄▀ ║,  ║▀▄  ,▓
//        ╙W▀ '█████╨▀▀█████████   "▀▀████└      ╙▄   ,▄▀'   `▀▀╣H ▐▀▄▀
//          ╙▄  ▀▀Γ╓▌  ▄▀ⁿ`╙▀███      ██▌         ╓█R▀▄A█        ▀▀▄▀
//            ╙W,Φ╙  ║█        ▄╙╙ª%≡╦██≤≤╗╗≡≡╜▀▀   ╣▌   █╕     ,▄▀
//              `▀▄M█┘        ║▀▌   ╫"    *Φ▄  █       Φ` ▀▌, ▄M╙
//                 "▀╦,       M ╙▌  ▀       `█W▐▌       wæQ▄▀╙
//                     ╙▀W╥,╓╣   ╙█║        ╫M  █    ,╓▄╝╙`
//                          ╙╙▀%▄▄▄▌,≤▄_▄≡,▐▓▓▄▄#ª▀"`



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
                                           BOOL rotateAroundCentroid)
{
   static CGPoint  points[ 3] =
   {
      CGPointData(  0.0, -0.5),
      CGPointData( -0.5,  0.5),
      CGPointData(  0.5,  0.5)
   };

   CGRect   rect;
   CGFloat  scale;
   CGPoint  massCenter;

   scale = CGSizeGetMinimum( size);
   mvgSave( vg);
   {
      massCenter = CGPointTriangleGetCentroid( points[ 0], points[ 1], points[ 2]);

      if( rotateAroundCentroid)
         mvgTranslate( vg, CGPointMake( massCenter.x * scale,
                                        massCenter.y * scale));

      mvgTranslate( vg, center);
      mvgRotate( vg, rotation);

      if( rotateAroundCentroid)
         mvgTranslate( vg, CGPointMake( -massCenter.x * scale,
                                        -massCenter.y * scale));
      mvgScale( vg, CGVectorMake( scale, scale));


      mvgBeginPath( vg);
      mvgMoveTo( vg, points[ 0]);
      mvgLineTo( vg, points[ 1]);
      mvgLineTo( vg, points[ 2]);
      mvgClosePath( vg);

      rect = CGRectMakeWithCenterPointAndSize( CGPointZero, CGSizeMake( 1.0, 1.0));
      [paint fillWithBounds:rect
                 NVGcontext:vg];

      mvgFillCircleWithPaint( vg, CACircleMake( massCenter, centroidRadius / scale), centroidPaint);
   }
   mvgRestore( vg);
}


static inline void   draw_triangle( NVGcontext *vg,
                                    CGPoint center,
                                    CGSize  size,
                                    CARotation rotation,
                                    CGPaint *paint)
{
   draw_triangle_with_centroid( vg, center, size, rotation, paint, 0.0, nil, YES);
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

      for( i = 0; i < 2; i++)
      {
         rect   = rects[ j][ i];
         center = CGRectGetCenterPoint( rect);
         size   = CGSizeMake( rect.size.width * 2.0 / 3.0,
                              rect.size.height * 2.0 / 3.0);

         if( i == 0)
         {
            draw_triangle( vg, center, size, rotation, paint);
         }
         else
            draw_triangle_with_centroid( vg, center,
                                             size,
                                             rotation,
                                             paint,
                                             3.0,
                                             [CGPaint paintWithColor:CGColorMakeWhite()],
                                             i == 1);

         mvgFillCircleWithColor( vg, CACircleMake( center, 5.0), CGColorMakeOrange());
         mvgStrokeRectWithColor( vg, CGRectMakeWithCenterPointAndSize( center, size), 1.0, CGColorMakeOrange());

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



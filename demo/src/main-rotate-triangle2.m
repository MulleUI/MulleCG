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
   CGContextSave( context);
   {
      massCenter = CGPointTriangleGetCentroid( points[ 0], points[ 1], points[ 2]);

      if( rotateAroundCentroid)
      CGContextTranslate( context, CGPointMake( massCenter.x * scale,
                massCenter.y * scale));

      CGContextTranslate( context, center);
      CGContextRotate( context, rotation);

      if( rotateAroundCentroid)
      CGContextTranslate( context, CGPointMake( -massCenter.x * scale,
                -massCenter.y * scale));
      CGContextScale( context, CGVectorMake( scale, scale));


      CGContextBeginPath( context);
      CGContextMoveTo( context, points[ 0]);
      CGContextLineTo( context, points[ 1]);
      CGContextLineTo( context, points[ 2]);
      CGContextClosePath( context);

      rect = CGRectMakeWithCenterAndSize( CGPointZero, CGSizeMake( 1.0, 1.0));
      [paint fillWithBounds:rect
                    context:context];

      CGContextFillCircleWithPaintable( context, CACircleMakeWithCenterAndRadius( massCenter, centroidRadius / scale), centroidPaint);
   }
   CGContextRestore( context);
}


static inline void   draw_triangle( CGContext *context,
                                    CGPoint center,
                                    CGSize  size,
                                    CARotation rotation,
                                    CGPaint *paint)
{
   draw_triangle_with_centroid( context, center, size, rotation, paint, 0.0, nil, YES);
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
                                     textureFlags:CGImageFlagRepeatX|CGImageFlagRepeatY  // CGImageFlagRepeatX
                                          context:context] autorelease];
      }
      else
         paint = [CGPaint paintWithStartColor:CGColorMakeIndigo()
                                     endColor:CGColorMakeBlue()];

      for( i = 0; i < 2; i++)
      {
         rect   = rects[ j][ i];
         center = CGRectGetCenter( rect);
         size   = CGSizeMake( rect.size.width * 2.0 / 3.0,
                              rect.size.height * 2.0 / 3.0);

         if( i == 0)
         {
            draw_triangle( context, center, size, rotation, paint);
         }
         else
            draw_triangle_with_centroid( context, center,
                  size,
                  rotation,
                  paint,
                  3.0,
                  [CGPaint paintWithColor:CGColorMakeWhite()],
                  i == 1);

         CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( center, 5.0), CGColorMakeOrange());
         CGContextStrokeRectWithColor( context, CGRectMakeWithCenterAndSize( center, size), 1.0, CGColorMakeOrange());

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



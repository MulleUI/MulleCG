#define _GNU_SOURCE

#import "import-private.h"


static BOOL   drawStuff( CALayer *layer, CGContext *context)
{
   struct NVGcontext   *vg;
   CGRect              canvas;
   CGRect              rects[ 2][ 2];
   CGRect              rect;
   CGRect              gradientRect;
   NVGpaint            paint;
   CGFloat             feather;
   CGFloat             radius;
   NSUInteger          frameNr;
   CGFloat             x;
   BOOL                drawHelpers;

   drawHelpers = NO;
   frameNr     = [context numberOfFrames];

   vg     = CGContextGetNVGContext( context);
   canvas = [layer canvas];

   CGRectPartitionIntoRowsAndColumns( CGRectInset( canvas, 10, 10),
                                      CGSizeMake( 10, 10),
                                      2,
                                      2,
                                      (CGRect *) rects);

   // NVGpaint nvgLinearGradient(NVGcontext* ctx, float sx, float sy, float ex, float ey,
   //                  NVGcolor icol, NVGcolor ocol);
   rect = rects[ 0][ 0];


   x       = (frameNr % 1000) / 999.0;
   feather = rect.size.height / 2.0 * (1.0 - _CAQuadraticGetValue( CAQuadraticEaseIn, x));
//   fprintf( stderr, "feather : %g (%g)\n", feather, x);
//   feather = 20.0;

   gradientRect  = CGRectInset( rect, feather / 4.0, feather / 4.0);
   paint         = nvgBoxGradient( vg, gradientRect.origin.x,
                                       gradientRect.origin.y,
                                       gradientRect.size.width,
                                       gradientRect.size.height,
                                       0.0,
                                       feather,
                                       CGColorMakeYellow(),
                                       CGColorMakeBlue());
   mvgFillRectWithNVGpaint( vg, rect, paint);

   if( drawHelpers)
   {
      mvgFillCircleWithColor( vg, CACircleMake( CGRectGetCenterPoint( rect), 3.0), CGColorMakeBlack());
      mvgStrokeRectWithColor( vg, gradientRect, 1.0, CGColorMakeWithRGBA( 1.0, 0.0, 0.0, 0.66));
      mvgStrokeRectWithColor( vg, CGRectExtrude( gradientRect,
                                        feather / 2.0,
                                        feather / 2.0),
                                  1.0,
                                  CGColorMakeWithRGBA( 0.5, 0.5, 0.5, 0.5));
   }

   rect  = rects[ 0][ 1];
   paint = mvgBoxGradient( vg, rect,
                               CGColorMakeBlue(),
                               0.0,
                               feather,
                               CGColorMakeYellow());
   mvgFillRectWithNVGpaint( vg, rect, paint);

   if( drawHelpers)
   {
      mvgFillCircleWithColor( vg, CACircleMake( CGRectGetCenterPoint( rect), 3.0), CGColorMakeBlack());

      mvgStrokeWidth( vg, 1.0);
      mvgStrokeRectWithColor( vg, gradientRect, 1.0, CGColorMakeWithRGBA( 1.0, 0.0, 0.0, 0.66));
      mvgStrokeRectWithColor( vg, CGRectExtrude( gradientRect,
                                                 feather / 2.0,
                                                 feather / 2.0),
                                  1.0f,
                                  CGColorMakeWithRGBA( 0.5, 0.5, 0.5, 0.5));

   }

   rect  = rects[ 1][ 0];
   paint = mvgLinearGradient( vg, rect,
                                  CGColorMakeYellow(),
                                  CGColorMakeBlue());
   mvgFillRectWithNVGpaint( vg, rect, paint);

   if( drawHelpers)
   {
      mvgFillCircleWithColor( vg, CACircleMake( CGRectGetCenterPoint( rect), 3.0), CGColorMakeBlack());
   }

   rect   = rects[ 1][ 1];
   radius = CGRectGetOuterRadius( rect);
   radius = radius * _CAQuadraticGetValue( CAQuadraticEaseOut, x);
   paint  = mvgRadialGradient( vg, CACircleMake( CGRectGetCenterPoint( rect), radius),
                                   CGColorMakeYellow(),
                                   0.0,
                                   CGColorMakeBlue());
   mvgFillRectWithNVGpaint( vg, rect, paint);

   if( drawHelpers)
   {
      mvgFillCircleWithColor( vg, CACircleMake( CGRectGetCenterPoint( rect), 3.0), CGColorMakeBlack());
   }
   return( YES);
}


int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CALayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 200, 200),
                                           NULL,
                                           60.0f));
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


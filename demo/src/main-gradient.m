#define _GNU_SOURCE

#import "import-private.h"


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect              canvas;
   CGRect              rects[ 2][ 2];
   CGRect              rect;
   CGRect              gradientRect;
   CGPaint             *paint;
   CGFloat             feather;
   CGFloat             radius;
   NSUInteger          frameNr;
   CGFloat             x;
   BOOL                drawHelpers;

   drawHelpers = NO;
   frameNr     = [context numberOfFrames];
   canvas      = [layer canvas];

   CGRectPartitionIntoRowsAndColumns( CGRectInset( canvas, 10, 10),
                                      CGSizeMake( 10, 10),
                                      2,
                                      2,
                                      (CGRect *) rects);

   // NVGpaint nvgLinearGradient(NVGcontext* ctx, float sx, float sy, float ex, float ey,
   //                  NVGcolor icol, NVGcolor ocol);
   rect = rects[ 0][ 0];
   x       = (frameNr % 1000) / 999.0;
   feather = rect.size.height / 2.0 * (1.0 - _CACubicGetValue( CACubicEaseIn, x));
//   fprintf( stderr, "feather : %g (%g)\n", feather, x);
//   feather = 20.0;

   gradientRect  = CGRectInset( rect, feather / 4.0, feather / 4.0);
   paint         = [CGGradient boxGradientWithRoundedRect:gradientRect // Converted from nvgBoxGradient
                                             cornerRadius:0.0
                                                    color:CGColorMakeYellow()
                                                  feather:feather
                                             featherColor:CGColorMakeBlue()];

   CGContextFillRectWithPaintable( context, rect, paint);

   if( drawHelpers)
   {
      CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( CGRectGetCenter( rect), 3.0), CGColorMakeBlack()); // Already CGContext
      CGContextStrokeRectWithColor( context, gradientRect, 1.0, CGColorMakeWithRGBA( 1.0, 0.0, 0.0, 0.66)); // Already CGContext
      CGContextStrokeRectWithColor( context, CGRectExtrude( gradientRect, // Already CGContext
                                        feather / 2.0,
                                        feather / 2.0),
                                  1.0,
                                  CGColorMakeWithRGBA( 0.5, 0.5, 0.5, 0.5));
   }

   rect  = rects[ 0][ 1];
   paint = [CGGradient boxGradientWithRoundedRect:rect // Converted from nvgBoxGradient
                              cornerRadius:0.0
                                     color:CGColorMakeBlue()
                                   feather:feather
                              featherColor:CGColorMakeYellow()];

   CGContextFillRectWithPaintable( context, rect, paint);

   if( drawHelpers)
   {
      CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( CGRectGetCenter( rect), 3.0), CGColorMakeBlack()); // Already CGContext
      CGContextStrokeWidth( context, 1.0); // Already CGContext
      CGContextStrokeRectWithColor( context, gradientRect, 1.0, CGColorMakeWithRGBA( 1.0, 0.0, 0.0, 0.66)); // Already CGContext
      CGContextStrokeRectWithColor( context, CGRectExtrude( gradientRect, // Already CGContext
                                                 feather / 2.0,
                                                 feather / 2.0),
                                  1.0f,
                                  CGColorMakeWithRGBA( 0.5, 0.5, 0.5, 0.5));
   }

   rect  = rects[ 1][ 0];
   paint = [CGGradient linearGradientWithRect:rect // Converted from nvgLinearGradient
                                   startColor:CGColorMakeYellow()
                                     endColor:CGColorMakeBlue()
                                     rotation:0.0f];

   CGContextFillRectWithPaintable( context, rect, paint);

   if( drawHelpers)
   {
      CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( CGRectGetCenter( rect), 3.0), CGColorMakeBlack()); // Already CGContext
   }

   rect   = rects[ 1][ 1];
   radius = CGRectGetOuterRadius( rect);
   radius = radius * _CACubicGetValue( CACubicEaseOut, x);
   paint  = [CGGradient radialGradientWithCircle:CACircleMakeWithCenterAndRadius( CGRectGetCenter( rect), radius) // Converted from nvgRadialGradient
                                           color:CGColorMakeBlue()
                                     innerRadius:0.0
                                      innerColor:CGColorMakeBlue()];

   CGContextFillRectWithPaintable( context, rect, paint);

   if( drawHelpers)
   {
      CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( CGRectGetCenter( rect), 3.0), CGColorMakeBlack()); // Already CGContext
   }

   return( YES);
}

int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
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

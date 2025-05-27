#define _GNU_SOURCE

#import "import-private.h"



#include "bitmap2.inc"


#define COLS  4
#define ROWS  2


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect       canvas;
   CGRect       rect;
   CGRect       rects[ ROWS][ COLS];
   CGPaint      *paint;
   NSUInteger   i, j;
   CGFloat      strokeWidth;

   canvas = [layer canvas];
   canvas = CGRectInset( canvas, 5.0, 5.0);

   CGRectPartitionIntoRowsAndColumns( canvas, CGSizeMake( 5, 5), ROWS, COLS, (CGRect *) rects);

   strokeWidth = 4.0;

   switch( [context numberOfFrames] % 6)
   {
   case 0 :
      paint = [CGGradient gradientWithStartColor:CGColorMakeYellow()
                                        endColor:CGColorMakeBlue()
                                        rotation:[context numberOfFrames] / 20.0];
      break;

   case 1 :
      paint = [[[CGImage alloc] initWithRGBABytes:bitmap2
                                       bitmapSize:CGPixelSizeMake( 32, 32)
                                     textureFlags:0  // NVG_IMAGE_REPEATX
                                          context:context] autorelease];
      break;

   case 2 :
      paint = [CGPaint paintWithColor:CGColorMakeBlack()];
      break;

   case 3 :
      paint = [CGGradient linearGradientWithRect:canvas
                                      startColor:CGColorMakeYellow()
                                        endColor:CGColorMakeBlue()
                                        rotation:[context numberOfFrames] / 20.0];
      break;

   case 4 :
      paint = [CGGradient boxGradientWithRoundedRect:canvas
                                        cornerRadius:20.0
                                               color:CGColorMakeYellow()
                                             feather:20.0
                                        featherColor:CGColorMakeBlue()];
      break;

   case 5 :
      paint = [CGGradient radialGradientWithCircle:CGRectGetOuterCircle( canvas)
                                             color:CGColorMakeYellow()
                                       innerRadius:20.0
                                        innerColor:CGColorMakeBlue()];
      break;
   }

   for( j = 0; j < ROWS; j++)
   {
      for( i = 0; i < COLS; i++)
      {
         rect = CGRectIntegral( rects[ j][ i]);

         switch( j * COLS + i)
         {
         case 0  : CGContextStrokeRectWithPaint( context, rect, strokeWidth, paint); break;
         case 1  : CGContextStrokeRoundedRectWithPaint( context, rect, 3.0, strokeWidth, paint); break;
         case 2  : CGContextStrokeCircleWithPaint( context, CGRectGetInnerCircle( rect), strokeWidth, paint); break;
         case 3  : CGContextStrokeLineWithPaint( context, CGRectGetTopLeft( rect), CGRectGetBottomRight( rect), strokeWidth, paint); break;

         case 4  : CGContextFillRectWithPaint( context, rect, paint); break;
         case 5  : CGContextFillRoundedRectWithPaint( context, rect, 3.0, paint); break;
         case 6  : CGContextFillCircleWithPaint( context, CGRectGetInnerCircle( rect), paint); break;
         case 7  : break;
         }
      }
   }
   return( YES);
}



int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;

   app = [UIApplication sharedInstance];

   window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 150, 150)];
   [window setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];
   [window setBackgroundColor:CGColorMakeWhite()];
   [window setFrameRateHz:0.5];
   [app addWindow:window];

   return( [app runApp]);
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

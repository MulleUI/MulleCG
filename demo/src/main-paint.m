#define _GNU_SOURCE

#import "import-private.h"



#include "bitmap2.inc"


#define COLS  4
#define ROWS  4


static void   drawStuff( CALayer *layer, CGContext *context)
{
   struct NVGcontext    *vg;
   CGRect               canvas;
   CGRect               rect;
   CGRect               rects[ ROWS][ COLS];
   CGPaint              *paint;
   NSUInteger           i, j;
   CGFloat              strokeWidth;

   vg     = CGContextGetNVGContext( context);

   canvas = [layer canvas];
   canvas = CGRectInset( canvas, 5.0, 5.0);

   CGRectPartitionIntoRowsAndColumns( canvas, CGSizeMake( 5, 5), ROWS, COLS, (CGRect *) rects);

   strokeWidth = 1.0;
   for( j = 0; j < ROWS; j++)
   {
      switch( [context numberOfFrames] % 3)
      {
      case 0 :
         paint = [CGGradient gradientWithStartColor:CGColorMakeYellow()
                                           endColor:CGColorMakeBlue()];
         break;

      case 1 :
         paint = [[[CGImage alloc] initWithRGBABytes:bitmap2
                                          bitmapSize:MulleIntegerSizeMake( 32, 32)
                                          imageFlags:0  // NVG_IMAGE_REPEATX
                                             context:context] autorelease];
         break;

      case 2 :
         paint = [CGPaint paintWithColor:CGColorMakeBlack()];
         break;
      }

      for( i = 0; i < COLS; i++)
      {
         rect = CGRectIntegral( rects[ j][ i]);

         switch( j * COLS + i)
         {
         case 0  : mvgStrokeRectWithPaint( vg, rect, strokeWidth, paint); break;
         case 1  : mvgStrokeRoundedRectWithPaint( vg, rect, 3.0, strokeWidth, paint); break;
         case 2  : mvgStrokeCircleWithPaint( vg, CGRectGetCenterPoint( rect), CGRectGetInnerRadius( rect), strokeWidth, paint); break;
         case 3  : mvgStrokeLineWithPaint( vg, CGRectGetTopLeftPoint( rect), CGRectGetBottomRightPoint( rect), strokeWidth, paint); break;

         case 4  : mvgFillRectWithPaint( vg, rect, paint); break;
         case 5  : mvgFillRoundedRectWithPaint( vg, rect, 3.0, paint); break;
         case 6  : mvgFillCircleWithPaint( vg, CGRectGetCenterPoint( rect), CGRectGetInnerRadius( rect), paint); break;
         case 7  : break;
         }

         if( [paint isTexture])
         {
            switch( j * COLS + i)
            {
            case 8  : mvgStrokeRectWithImage( vg, rect, strokeWidth, (CGImage *) paint); break;
            case 9  : mvgStrokeRoundedRectWithImage( vg, rect, 3.0, strokeWidth, (CGImage *) paint); break;
            case 10 : mvgStrokeCircleWithImage( vg, CGRectGetCenterPoint( rect), CGRectGetInnerRadius( rect), strokeWidth, (CGImage *) paint); break;
            case 11 : mvgStrokeLineWithImage( vg, CGRectGetTopLeftPoint( rect), CGRectGetBottomRightPoint( rect), strokeWidth, (CGImage *) paint); break;

            case 12 : mvgFillRectWithImage( vg, rect, (CGImage *) paint); break;
            case 13 : mvgFillRoundedRectWithImage( vg, rect, 3.0, (CGImage *) paint); break;
            case 14 : mvgFillCircleWithImage( vg, CGRectGetCenterPoint( rect), CGRectGetInnerRadius( rect), (CGImage *) paint); break;
            case 15 : break;
            }
         }
         else
         {
            switch( j * COLS + i)
            {
            case 8  : mvgStrokeRectWithGradient( vg, rect, strokeWidth, (CGGradient *) paint); break;
            case 9  : mvgStrokeRoundedRectWithGradient( vg, rect, 3.0, strokeWidth, (CGGradient *) paint); break;
            case 10 : mvgStrokeCircleWithGradient( vg, CGRectGetCenterPoint( rect), CGRectGetInnerRadius( rect), strokeWidth, (CGGradient *) paint); break;
            case 11 : mvgStrokeLineWithGradient( vg, CGRectGetTopLeftPoint( rect), CGRectGetBottomRightPoint( rect), strokeWidth, (CGGradient *) paint); break;

            case 12 : mvgFillRectWithGradient( vg, rect, (CGGradient *) paint); break;
            case 13 : mvgFillRoundedRectWithGradient( vg, rect, 3.0, (CGGradient *) paint); break;
            case 14 : mvgFillCircleWithGradient( vg, CGRectGetCenterPoint( rect), CGRectGetInnerRadius( rect), (CGGradient *) paint); break;
            case 15 : break;
            }
         }
      }
   }
}



int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;

   app = [UIApplication sharedInstance];

   window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 150, 150)];
   [window setDrawCallback:(CALayerDrawCallback_t *) drawStuff];
   [window setBackgroundColor:CGColorMakeWhite()];
   [window setFrameRateHz:0.5];
   [app addWindow:window];

   return( [app run]);
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

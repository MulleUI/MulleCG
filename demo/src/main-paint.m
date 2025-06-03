#define _GNU_SOURCE

#import "import-private.h"



#include "bitmap2.inc"


#define COLS  4
#define ROWS  2



static void   drawRectBehindText( CGContext *context, CGRect canvas, char *label)
{
   struct CGTextBoundsInfo   info;

   // BUG: The visually is needed to "remove" the descender space. What is not
   //      super clear here is, that NVG_ALIGN_TOP | NVG_ALIGN_LEFT will be
   //      working on descender and ascender lineHeight, which is spitting
   //      in the soup again.
   CGContextFontFace( context, "sans");
   CGContextFontSize( context, 10.0f);

   info = CGContextTextBoundsOptions( context, label, (size_t) -1,
                                                   CGRectInset( canvas, 8, 8),
                                                   CGContentModeBottomLeft,
                                                   CGTextOptionAlignVisually);

   CGContextFillRoundedRectWithColor( context,
                                      CGRectExtrude( info.bounds, 6, 6),
                                      6.0,
                                      CGColorBySettingAlpha( CGColorMakeBlack(), 0.5));

   CGContextTextColor( context, CGColorMakeWhite());
   CGContextTextBackgroundColor( context, CGColorMakeGray());

   CGContextTextAlign( context, NVG_ALIGN_LEFT | NVG_ALIGN_TOP);
   CGContextText( context, info.bounds.origin, label, (size_t) -1);
}



static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect       canvas;
   CGRect       rect;
   CGRect       rects[ ROWS][ COLS];
   CGPaint      *paint;
   NSUInteger   i, j;
   CGFloat      strokeWidth;
   char         *label;

   canvas = [layer canvas];
   CGRectPartitionIntoRowsAndColumns( CGRectInset( canvas, 5.0, 5.0),
                                      CGSizeMake( 5, 5),
                                      ROWS,
                                      COLS,
                                      (CGRect *) rects);

   strokeWidth = 4.0;
   label       = "???";

   switch( [context numberOfFrames] % 6)
   {
   case 0 :
      paint = [CGGradient gradientWithStartColor:CGColorMakeYellow()
                                        endColor:CGColorMakeBlue()
                                        rotation:[context numberOfFrames] / 20.0];
      label = "yellow/blue gradient";
      break;

   case 1 :
      paint = [CGImage imageWithRGBABytes:bitmap2
                               bitmapSize:CGPixelSizeMake( 32, 32)
                             textureFlags:CGImageFlagRepeatX|CGImageFlagRepeatY
                                  context:context];
      label = "bitmap fill";
      break;

   case 2 :
      paint = [CGPaint paintWithColor:CGColorMakeGreen()];
      label = "green color fill";
      break;

   case 3 :
      paint = [CGGradient linearGradientWithRect:canvas
                                      startColor:CGColorMakePapaya()
                                        endColor:CGColorMakeChartreuse()
                                        rotation:[context numberOfFrames] / 20.0];
      label = "papaya/chartreuse linear gradient";
      break;

   case 4 :
      paint = [CGGradient boxGradientWithRoundedRect:canvas
                                        cornerRadius:20.0
                                               color:CGColorMakeOlive()
                                             feather:20.0
                                        featherColor:CGColorMakePurple()];
      label = "olive/purple box gradient";
      break;

   case 5 :
      paint = [CGGradient radialGradientWithCircle:CGRectGetOuterCircle( canvas)
                                             color:CGColorMakeOrange()
                                       innerRadius:20.0
                                        innerColor:CGColorMakeRed()];
      label = "orange/red radial gradient";
      break;
   }

   for( j = 0; j < ROWS; j++)
   {
      for( i = 0; i < COLS; i++)
      {
         rect = CGRectIntegral( rects[ j][ i]);

         switch( j * COLS + i)
         {
         case 0  : CGContextStrokeRectWithPaintable( context, rect, strokeWidth, paint); break;
         case 1  : CGContextStrokeRoundedRectWithPaintable( context, rect, 3.0, strokeWidth, paint); break;
         case 2  : CGContextStrokeCircleWithPaintable( context, CGRectGetInnerCircle( rect), strokeWidth, paint); break;
         case 3  : CGContextStrokeLineWithPaintable( context, CGRectGetTopLeft( rect), CGRectGetBottomRight( rect), strokeWidth, paint); break;

         case 4  : CGContextFillRectWithPaintable( context, rect, paint); break;
         case 5  : CGContextFillRoundedRectWithPaintable( context, rect, 3.0, paint); break;
         case 6  : CGContextFillCircleWithPaintable( context, CGRectGetInnerCircle( rect), paint); break;
         case 7  : break;
         }
      }
   }

   drawRectBehindText( context, canvas, label);

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

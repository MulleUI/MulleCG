#define _GNU_SOURCE

#import "import-private.h"
#define COLS  3
#define ROWS  3

static void   drawRectBehindText( CGContext *context,
                                  CGRect canvas,
                                  char *label,
                                  CGContentMode contentMode)
{
   struct CGTextBoundsInfo   info;

   CGContextFontFace( context, "sans");
   CGContextFontSize( context, 8.0f);

   info = CGContextTextBoundsOptions( context, label, (size_t) -1,
                                               CGRectInset( canvas, 4, 4),
                                               contentMode,
                                               CGTextOptionAlignVisually);

   CGContextFillRoundedRectWithColor( context,
                                      CGRectExtrude( info.bounds, 4, 4),
                                      4.0,
                                      CGColorBySettingAlpha( CGColorMakeBlack(), 0.5));

   CGContextTextColor( context, CGColorMakeWhite());
   CGContextTextBackgroundColor( context, CGColorMakeGray());

   CGContextCombinedTextAlignment( context, CGTextAlignLeft | CGTextAlignTop);
   CGContextText( context, info.bounds.origin, label, (size_t) -1);
}
#define SPACE  20.0

static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect            canvas;
   CGRect            rect;
   CGRect            fillRect;
   CGRect            strokeRect;
   CGRect            rects[ ROWS][ COLS];
   CGPaint           *fillPaint;
   CGPaint           *strokePaint;
   NSUInteger        i, j;
   CGFloat           strokeWidth;
   CGFillOptions     fillOptions;
   CGStrokeOptions   strokeOptions;

   canvas = [layer canvas];

   CGRectPartitionIntoRowsAndColumns( CGRectInset( canvas, SPACE, SPACE),
                                      CGSizeMake( SPACE, SPACE),
                                      ROWS,
                                      COLS,
                                      (CGRect *) rects);

   strokeWidth = (SPACE - 4.0) / 2.0;
   fillPaint   = [CGGradient linearGradientWithRect:canvas
                                         startColor:CGColorBySettingAlpha( CGColorMakePapaya(), 0.5)
                                           endColor:CGColorBySettingAlpha( CGColorMakeChartreuse(), 0.5)
                                           rotation:0.125];
   strokePaint = [CGGradient linearGradientWithRect:canvas
                                         startColor:CGColorBySettingAlpha( CGColorMakeDodgerBlue(), 0.5)
                                           endColor:CGColorBySettingAlpha( CGColorMakeYellow(), 0.5)
                                           rotation:0.25];

   for( j = 0; j < ROWS; j++)
   {
      for( i = 0; i < COLS; i++)
      {
         rect                    = CGRectIntegral( rects[ j][ i]);

         // make 
         strokeRect = CGRectMakeStrokeRect( rect, 1.0, CGOverlap);
         CGContextBeginPath( context);
         CGContextRect( context, strokeRect);
         CGContextStrokeColor( context, CGColorMakeRed());
         CGContextStrokeWidth( context, 1.0f);
         CGContextStroke( context);

         fillOptions             = CGFillOptionsDefault;
         fillOptions.strokeWidth = strokeWidth;
         fillOptions.relation    = i;

         strokeOptions           = CGStrokeOptionsDefault;
         strokeOptions.relation  = j;

         //
         //
         strokeRect = CGRectMakeStrokeRect( rect, strokeWidth, strokeOptions.relation);
         fillRect   = CGRectMakeFillRect( strokeRect, strokeWidth, fillOptions.relation);

         CGContextBeginPath( context);
         CGContextRect( context, fillRect);
         CGContextFillPaintableOptions( context,
                                        fillPaint,
                                        rect,
                                        &fillOptions);
         CGContextFill( context);
         CGContextBeginPath( context);
         CGContextRect( context, strokeRect);
         CGContextStrokePaintableOptions( context,
                                          strokePaint,
                                          rect,
                                          strokeWidth,
                                          &strokeOptions);
         CGContextStrokeWidth( context, strokeWidth);
         CGContextStroke( context);

         //
         drawRectBehindText( context, rect, CGRelationUTF8String( i), CGContentModeCenterPoint);
         drawRectBehindText( context, rect, CGRelationUTF8String( j), CGContentModeTopLeft);
      }
   }

   return( YES);
}

int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;

   app = [UIApplication sharedInstance];

   window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 640, 400)];
   [window setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];
   [window setBackgroundColor:CGColorMakeWhite()];
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

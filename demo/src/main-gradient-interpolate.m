#define _GNU_SOURCE

#import "import-private.h"
#define ROWS   8
#define COLS   10
static void   drawGridInRect( CGContext  *context, CGRect rect)
{
#define B   { 0xF8, 0xF8, 0xF8, 0xFF }
#define G   { 0xC2, 0xC2, 0xC2, 0xFF }

   static uint8_t   imagedata[ 8][ 8][ 4] =
   {
       { B, B, B, B,  G, G, G, G },
       { B, B, B, B,  G, G, G, G },
       { B, B, B, B,  G, G, G, G },
       { B, B, B, B,  G, G, G, G },

       { G, G, G, G,  B, B, B, B },
       { G, G, G, G,  B, B, B, B },
       { G, G, G, G,  B, B, B, B },
       { G, G, G, G,  B, B, B, B },
   };
   CGImage   *image;

   image = [[[CGImage alloc] initWithRGBABytes:imagedata
                                    bitmapSize:CGPixelSizeMake( 8, 8)
                                  textureFlags:CGImageFlagRepeatX|CGImageFlagRepeatY
                                       context:context] autorelease];
   [image drawRect:rect
           options:NULL
           context:context];
}
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect              canvas;
   CGRect              rows[ ROWS];
   CGRect              subrows[ 3];
   CGRect              subsubrows[ 4];
   CGRect              grid[ ROWS][ COLS];
   NSUInteger          x, y;
   CGRect              rect;
   CGGradient          *gradient[ 2];
   CGGradient          *interpolated[ 4];
   NSUInteger          i;
   NSUInteger          j;
   CGColor             colors[ 2];
   CGImage             *image;
   canvas = [layer canvas];

   drawGridInRect( context, canvas);

   canvas = CGRectInset( canvas, 5.0f, 5.0f);
   CGRectPartitionVertically( canvas, 5.0, ROWS, rows);

   for( y = 0; y < ROWS; y++)
   {
      CGRectPartitionHorizontally( rows[ y], 5.0, COLS, grid[ y]);
      for( x = 0; x < COLS; x++)
      {
         for( j = 0; j < 2; j++)
         {
            for( i = 0; i < 2; i++)
            {
               colors[ i] = CGColorMakeWithHSBA( CGFloatMakeRandom(),
                                                 CGFloatMakeRandom(),
                                                 CGFloatMakeRandom(),
                                                 CGFloatMakeAbnormalDistribution());
            }
            gradient[ j] = [CGGradient gradientWithStartColor:colors[ 0]
                                                     endColor:colors[ 1]];
         }

         for( j = 0; j < 4 ; j++)
            interpolated[ j] = [gradient[ 0] interpolateTo:gradient[ 1]
                                                    factor:1.0 / 5.0 + j * 1.0 / 5.0
                                                  additive:NO];

         rect = grid[ y][ x];
         rect = CGRectIntegral( rect);
         CGContextFillRectWithColor( context, rect, CGColorMakeWithRGBA( 1.0, 1.0, 1.0, 0.5));

         CGRectPartitionVertically( rect, 0.0, 3, subrows);
         CGContextFillRectWithPaintable( context, CGRectInset( CGRectIntegral( subrows[ 0]), 1.0, 1.0), gradient[ 0]);
         CGRectPartitionVertically( CGRectInset( CGRectIntegral( subrows[ 1]), 1.0, 1.0), 0.0, 4, subsubrows);
         CGContextShapeAntiAlias( context, NO);
         for( j = 0; j < 4; j++)
            CGContextFillRectWithPaintable( context, subsubrows[ j], interpolated[ j]);
         CGContextShapeAntiAlias( context, YES);
         CGContextFillRectWithPaintable( context, CGRectInset( CGRectIntegral( subrows[ 2]), 1.0, 1.0), gradient[ 1]);
      }
   }
   return( YES);
}
int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 800, 600),
                                           NULL, 
                                           0.1f));   
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

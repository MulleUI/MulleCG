#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>
#include <time.h>


//
// This demo was used to debug CGGradientNVGpaintForRect, so that the
// rotation of the linear gradient looks smooth
//
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CAAngle             angle;
   CARotation          rotation;
   CGGradient          *gradient;
   CGRect              canvas;
   CGRect              rect;
   CGRect              rects[ 3][ 3];
   char                buf[ 128];
   NVGpaint            paint;
   unsigned int        i, j;
   NSUInteger          frameNr;
   double              x;
   CGStrokeOptions     options;

   // directions as we want the texture rotated in each rectangle
   static CAAngle   directions[ 9] =
   {
      CAAngleNW,
      CAAngleN,
      CAAngleNE,

      CAAngleW,
      NAN,
      CAAngleE,

      CAAngleSW,
      CAAngleS,
      CAAngleSE
   };

   frameNr  = [context numberOfFrames] % 240;
   rotation = 0.25;
   if( frameNr > 120)
   {
      x         = (frameNr % 120) / 119.0f;
      rotation += x;
//      rotation += _CAQuadraticGetValue( ((struct CAQuadratic) {  0.0, 0.010f, 0.990f, 1.0f }), x);
   }

   canvas = [layer canvas];
   // Delete: vg     = CGContextGetNVGContext( context);

   CGContextBeginPath( context); // Converted from nvgBeginPath
   {
      CGContextRect( context, canvas); // Converted from mvgRect
      CGContextStrokeWidth( context, 8); // Converted from mvgStrokeWidth
      CGContextStrokeColor( context, CGColorMakeWithHexColor( 0x8020A0FF)); // Converted from mvgStrokeColor
   }
   CGContextStroke( context); // Converted from nvgStroke

   CGRectPartition3x3( CGRectInset( canvas, 50, 50), CGSizeMake( 75, 75), rects);

   gradient = [CGGradient gradientWithStartColor:CGColorMakeYellow()
                                        endColor:CGColorMakeMagenta()
                                        rotation:rotation];

   options                  = CGStrokeOptionsDefault;
   options.paint.smoothness = 0.25;

   for( j = 0; j < 3; j++)
   {
      for( i = 0; i < 3; i++)
      {
         angle = directions[ i + j * 3];
         if( isnan( angle))
            continue;

         rect = CGRectIntegral( rects[ j][ i]);
         CGContextStrokeRectWithColor( context, rect, 0.5, CGColorMakeWhite()); // Converted from mvgStrokeRectWithColor

         CGContextSave( context); // Converted from mvgSave
         {
            angle = CAAngleRotate( angle, CARotation90);

            CGContextTranslate( context, CGRectGetCenter( rect)); // Converted from mvgTranslate
            CGContextRotate( context, CAAngleToRotation( angle)); // Converted from mvgRotate
            CGContextTranslate( context, CGPointNegate( CGRectGetCenter( rect))); // Converted from mvgTranslate

            CGContextBeginPath( context); // Converted from mvgBeginPath
            CGContextRect( context, rect); // Converted from mvgRect

            CGContextStrokeWidth( context, 8.0); // Converted from mvgStrokeWidth
            CGContextStrokePaintableOptions( context, gradient, rect, 8.0, &options);
            CGContextStroke( context); // Converted from mvgStroke

            CGContextFontFace( context,"sans");
            CGContextFontSize( context, 12); // Converted from mvgFontSize
            CGContextTextColor( context, CGColorMakeWhite()); // Converted from mvgTextColor
            CGContextTextBackgroundColor( context, CGColorMakeWithRGBA( 0.33, 0.33, 0.33, 1.0)); // Converted from mvgTextBackgroundColor
            sprintf( buf, "%.1f°", CAAngleToDegrees( angle));
            CGContextTextInRect( context, buf, (size_t) -1, rect, CGContentModeLeft, CGTextOptionAlignVisually); // Converted from mvgTextInRect
         }
         CGContextRestore( context); // Converted from mvgRestore
      }
   }
   return( YES);
}


void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame  = [[window contentView] contentRect];
   view   = [UIView viewWithFrame:frame];
   [view setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];
   [[window contentView] addSubview:view];
}


int   main( int argc, char *argv[])
{
   UIWindow         *window;
   UIApplication    *app;

   app = [UIApplication sharedInstance];
   @autoreleasepool
   {
      window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 600, 400)
                                titleUTF8String:"Demo"
                                      styleMask:UIWindowStyleMaskDefault & ~UIWindowStyleRetained] autorelease];

      assert( window);
      [window setBackgroundColor:CGColorMakeWithRGBA( 0.33, 0.33, 0.33, 1.0)];
      [window setFrameRateHz:60.0];
      setupScene( window);
      [app addWindow:window];
   }
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

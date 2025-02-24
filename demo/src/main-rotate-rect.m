#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>
#include <time.h>


static CABasicAnimation   *animation;

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
   struct NVGcontext   *vg;
   unsigned int        i, j;
   NSUInteger          frameNr;

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
   rotation = frameNr > 120
              ? (frameNr % 120) / 120.0f + 0.25
              : 0.25f;

   canvas = [layer canvas];
   vg     = CGContextGetNVGContext( context);

   nvgBeginPath( vg);
   {
      mvgRect( vg, canvas);
      mvgStrokeWidth( vg, 8);
      mvgStrokeColor( vg, CGColorMakeWithHexColor( 0x8020A0FF));
   }
   nvgStroke( vg);

   CGRectPartition3x3( CGRectInset( canvas, 50, 50), CGSizeMake( 100, 100), rects);

   gradient = [CGGradient gradientWithStartColor:CGColorMakeIndigo()
                                        endColor:CGColorMakeBrown()
                                        rotation:rotation];

   for( j = 0; j < 3; j++)
   {
      for( i = 0; i < 3; i++)
      {
         angle = directions[ i + j * 3];
         if( isnan( angle))
            continue;

         rect = CGRectIntegral( rects[ j][ i]);
         mvgStrokeRectWithColor( vg, rect, 0.5, CGColorMakeWhite());

         mvgSave( vg);
         {
            angle = CAAngleRotate( angle, CARotation90);
            paint = [gradient linearGradientNVGpaintWithBounds:rect
                                                    NVGcontext:vg];


            mvgTranslate( vg, CGRectGetCenterPoint( rect));
            mvgRotate( vg, CAAngleToRotation( angle));
            mvgTranslate( vg, CGPointNegate( CGRectGetCenterPoint( rect)));

            mvgBeginPath( vg);
            mvgRect( vg, rect);
            mvgFillPaint( vg, paint);
            mvgFill( vg);

            [context useFontWithNameUTF8String:"sans"];
            mvgFontSize( vg, 12);
            mvgTextColor( vg, CGColorMakeWhite());
            mvgTextBackgroundColor( vg, CGColorMakeBrown());
            sprintf( buf, "%.1f°", CAAngleToDegrees( angle));
            mvgTextInRect( vg, buf, (size_t) -1, rect, CGContentModeLeft, MVGTextAlignVisually);
         }
         mvgRestore( vg);
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



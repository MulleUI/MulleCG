#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>
#include <time.h>


#define R   0xFF, 0x00, 0x00, 0xFF
#define G   0x00, 0xFF, 0x00, 0xFF
#define B   0x00, 0x00, 0xFF, 0xFF
#define Y   0xFF, 0xFF, 0x00, 0xFF
#define W   0xFF, 0xFF, 0xFF, 0xFF
#define _   0x00, 0x00, 0x00, 0xFF


static unsigned char    bitmap2[ 4 * 32 * 32] =
{
   W, _, W, _,  W, _, W, _,  W, _, W, _,  W, _, W, _,  W, _, W, _,  W, _, W, _,  W, _, W, _,  W, _, W, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,

   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, _, _,  _, _, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, _, _,  _, _, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, _, _,  _, _, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, _, _,  _, _, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,

   W, B, B, B,  B, B, B, B,  R, R, R, R,  _, _, _, _,  _, _, _, _,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, _, _, _,  _, _, _, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, _, _,  _, _, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, _,  _, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,

   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, W, _, W,  _, W, _, W,  _, W, _, W,  _, W, _, W,  _, W, _, W,  _, W, _, W,  _, W, _, W,  _, W, _, W
};


static void   drawStuff( CALayer *layer, CGContext *context)
{
   CGDrawableOptions   options;
   CGRect              canvas;
   CGRect              rects[ 3][ 3];
   CGImage             *image;
   struct NVGcontext   *vg;
   CGRect              area;

   canvas = [layer canvas];

   vg = CGContextGetNVGContext( context);

   // gray rectangle so we know something is drawn...
   nvgBeginPath( vg);
   {
      nvgRect( vg, canvas.origin.x, canvas.origin.y, canvas.size.width, canvas.size.height);
      nvgStrokeWidth( vg, 8);
      nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x8020A0FF));
   }
   nvgStroke( vg);


   // if we immediately reclaim the image (via release) after drawing it
   // is too early, and the texture is gone too soon
   image   = [[[CGImage alloc] initWithRGBABytes:bitmap2
                                      bitmapSize:CGBitmapSizeMake( 32, 32)
                                      imageFlags:0  // NVG_IMAGE_REPEATX
                                         context:context] autorelease];
   assert( image);


   canvas    = CGRectInset( canvas, 4, 4);

   // get a rectangle inside canvas thats centered and as large as possible
   area.size = CGSizeAspectFitToSize( CGSizeMake( 1, 1), canvas.size);
   area      = CGSizePlaceInRect( area.size, canvas, CGContentModeCenterPoint);

   // subdivide into 3x3
   CGRectPartition3x3( canvas, CGSizeMake( 4, 4), rects);


#define SCALE     CGScaleToFit // CGScaleNone
#define OFFSET    180
   // knob in texture is at angle 180. So 12:00 is acually offset - 180

#if 1
   options = CGDrawableOptionsMake( 1.0,
                                    0.0,
                                    CAAngleDegreesToRadians( 0 - OFFSET),
                                    SCALE,
                                    CGFlipNone,
                                    CGRepeatNone,
                                    CGContentModeCenterPoint);
   [image drawRect:rects[ 0][ 1]
           options:&options
           context:context];
#endif
#if 1
   options = CGDrawableOptionsMake( 1.0,
                                    0.0,
                                    CAAngleDegreesToRadians( 45 - OFFSET),
                                    SCALE,
                                    CGFlipNone,
                                    CGRepeatNone,
                                    CGContentModeCenterPoint);
   [image drawRect:rects[ 0][ 2]
           options:&options
           context:context];

   options = CGDrawableOptionsMake( 1.0,
                                    0.0,
                                    CAAngleDegreesToRadians( 90 - OFFSET),
                                    SCALE,
                                    CGFlipNone,
                                    CGRepeatNone,
                                    CGContentModeCenterPoint);
   [image drawRect:rects[ 1][ 2]
           options:&options
           context:context];

   options = CGDrawableOptionsMake( 1.0,
                                    0.0,
                                    CAAngleDegreesToRadians( 135 - OFFSET),
                                    SCALE,
                                    CGFlipNone,
                                    CGRepeatNone,
                                    CGContentModeCenterPoint);
   [image drawRect:rects[ 2][ 2]
           options:&options
           context:context];
#endif
   // row
   options = CGDrawableOptionsMake( 1.0,
                                    0.0,
                                    CAAngleDegreesToRadians( 180 - OFFSET),
                                    SCALE,
                                    CGFlipNone,
                                    CGRepeatNone,
                                    CGContentModeCenterPoint);
   [image drawRect:rects[ 2][ 1]
           options:&options
           context:context];
#if 1
   options = CGDrawableOptionsMake( 1.0,
                                    0.0,
                                    CAAngleDegreesToRadians( 225 - OFFSET),
                                    SCALE,
                                    CGFlipNone,
                                    CGRepeatNone,
                                    CGContentModeCenterPoint);
   [image drawRect:rects[ 2][ 0]
           options:&options
           context:context];

   options = CGDrawableOptionsMake( 1.0,
                                    0.0,
                                    CAAngleDegreesToRadians( 270 - OFFSET),
                                    SCALE,
                                    CGFlipNone,
                                    CGRepeatNone,
                                    CGContentModeCenterPoint);
   [image drawRect:rects[ 1][ 0]
           options:&options
           context:context];

   options = CGDrawableOptionsMake( 1.0,
                                    0.0,
                                    CAAngleDegreesToRadians( 315 - OFFSET),
                                    SCALE,
                                    CGFlipNone,
                                    CGRepeatNone,
                                    CGContentModeCenterPoint);
   [image drawRect:rects[ 0][ 0]
           options:&options
           context:context];
#endif
}


void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame  = [[window contentPlane] contentRect];
   view   = [UIView viewWithFrame:frame];
   [[window contentPlane] setDrawCallback:drawStuff];
   [[window contentPlane] addSubview:view];
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
      [window setBackgroundColor:CGColorMakeRGBA( 0.5, 0.5, 0.5, 1.0)];
      setupScene( window);
      [app addWindow:window];
   }
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



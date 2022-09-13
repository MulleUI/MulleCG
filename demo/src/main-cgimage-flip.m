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

static unsigned char    bitmap[4 * 8*8] =
{
   B, B, B, B,  R, R, R, R,
   B, B, B, B,  R, R, R, R,
   B, B, _, _,  R, R, R, R,
   B, B, _, _,  _, R, R, R,

   Y, Y, Y, _,  _, _, G, G,
   Y, Y, Y, Y,  _, _, G, G,
   Y, Y, Y, Y,  G, G, G, G,
   Y, Y, Y, Y,  G, G, G, G
};


static void   drawStuff( CALayer *layer, CGContext *context)
{
   CGDrawableOptions   options;
   CGRect              canvas;
   CGRect              rects[ 2][ 2];
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
   image   = [[[CGImage alloc] initWithRGBABytes:bitmap
                                      bitmapSize:MulleIntegerSizeMake( 8, 8)
                                      imageFlags:0  // NVG_IMAGE_REPEATX
                                         context:context] autorelease];
   assert( image);


   canvas    = CGRectInset( canvas, 4, 4);

   // get a rectangle inside canvas thats centered and as large as possible
   area.size = CGSizeAspectFillToSize( CGSizeMake( 1, 1), canvas.size);
   area      = CGSizePlaceInRect( area.size, canvas, CGContentModeCenterPoint);

   // subdivide into 2x2
   CGRectPartition2x2( area, CGSizeMake( 4, 4), rects);

   options = CGDrawableOptionsMake( 1.0,
                                    0.0,
                                    CGRotationNone,
                                    CGScaleToFit,
                                    CGFlipNone,
                                    CGRepeatNone,
                                    CGContentModeCenterPoint);
   [image drawRect:rects[ 0][ 0]
           options:&options
           context:context];

   options = CGDrawableOptionsMake( 1.0,
                                    0.0,
                                    CGRotationNone,
                                    CGScaleToFit,
                                    CGFlipHorizontally,
                                    CGRepeatNone,
                                    CGContentModeCenterPoint);
   [image drawRect:rects[ 0][ 1]
           options:&options
           context:context];

   options = CGDrawableOptionsMake( 1.0,
                                    0.0,
                                    CGRotationNone,
                                    CGScaleToFit,
                                    CGFlipVertically,
                                    CGRepeatNone,
                                    CGContentModeCenterPoint);
   [image drawRect:rects[ 1][ 0]
           options:&options
           context:context];

   options = CGDrawableOptionsMake( 1.0,
                                    0.0,
                                    CGRotationNone,
                                    CGScaleToFit,
                                    CGFlipBoth,
                                    CGRepeatNone,
                                    CGContentModeCenterPoint);
   [image drawRect:rects[ 1][ 1]
           options:&options
           context:context];
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
      window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 200, 200)
                                   titleUTF8String:"Demo"
                                         styleMask:UIWindowStyleMaskDefault & ~UIWindowStyleRetained] autorelease];

      assert( window);
      [window setBackgroundColor:CGColorMakeWithRGBA( 0.5, 0.5, 0.5, 1.0)];
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



#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>


// this is a "reenactment" of MulleGraphics/main-catextlayer.m just with
// plain nanovg to check if it looks the same

//
// Problem: nanovg hat eine atlas grösse von 512, wenn der Font nicht rein
//          passt muss der atlas resized werden. Das macht nanovg aber 
//          scheinz nicht automatisch.
//
// Problem 2: Man kann "freetype2" nicht aufzwingen wieviele Pixel es 
//          generieren soll. Wenn man eine Fontgrösse von 32 pixel angibt
//          können auch 34 rauskommen. Die Lösung ist vermutlich, daß man
//          als CALayer nicht clipt. wenn man Text macht. ? 

// static void   setupSceneInWindow( UIWindow *window)
// {
//    CATextLayer     *layer;
//    CGRect          frame;
//    UIView          *view;
//    UIWindowPlane   *contentPlane;
// 
//    contentPlane = [window contentPlane];
//    frame        = [contentPlane contentRect];
//    frame        = UIEdgeInsetsInsetRect( frame, UIEdgeInsetsMake( 10, 10, 10, 10));
// 
//    layer = [CATextLayer layerWithFrame:frame];
//    [layer setBorderWidth:1.0];
//    [layer setBorderColor:CGColorMakeOrange()];
//    [layer setTextColor:CGColorMakeWhite()];
//    [layer setTextBackgroundColor:CGColorMakeWithRGBA( 0.5, 0.5, 0.5, 1.0)];
//    [layer setTextUTF8String:"|y|"];
//    view  = [UIView viewWithLayer:layer];
//    [contentPlane addSubview:view];
// }


static void   drawStuff( CALayer *layer, CGContext *context)
{
   struct NVGcontext  *vg;
   CGFont             *font;
   CGRect             canvas;

   vg     = CGContextGetNVGContext( context);
   font   = [context fontWithNameUTF8String:"sans"];
   canvas = [layer canvas];

   mvgStrokeRect( vg, canvas, CGColorMakeOrange());
   nvgFontSize( vg, canvas.size.height);
   nvgTextColor( vg, CGColorMakeWhite(), CGColorMakeWithRGBA( 0.5, 0.5, 0.5, 1.0));
   nvgTextAlign( vg, NVG_ALIGN_CENTER|NVG_ALIGN_BOTTOM);
   nvgText( vg, CGRectGetMidX( canvas), CGRectGetMaxY( canvas), "|y|", NULL);   
}


void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame = [[window contentPlane] contentRect];
   frame = UIEdgeInsetsInsetRect( frame, UIEdgeInsetsMake( 10, 10, 10, 10));

   view  = [UIView viewWithFrame:frame];
   [view setClipsToBounds:NO];
   [view setMasksToBounds:NO];
   [view setDrawCallback:(CALayerDrawCallback_t *) drawStuff];
   [[window contentPlane] addSubview:view];
}


int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
   NSUInteger      styleMask;

   app = [UIApplication sharedInstance];

   @autoreleasepool
   {
      styleMask = UIWindowStyleMaskDefault;
      styleMask = UIWindowsStyleMaskBySetting( styleMask, UIWindowStyleResizable, YES);
      styleMask = UIWindowsStyleMaskBySetting( styleMask, UIWindowStyleRetained, NO);

      // TODO: if window > 512 + 20, then initially nanovg will fail
      window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 800, 500)
                         titleUTF8String:"Demo"
                               styleMask:styleMask];
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


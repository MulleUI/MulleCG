#define _GNU_SOURCE

#import "import-private.h"
#include "draw-flag.inc"


//
// A somewhat more conveniently coded version of main-cglayer.m
// using: -beginFBRenderWithBackgroundColor: / -endFBRender:
//
// this demo does the simple stripes stuff, except that
// we render into a CGFramebuffer first. Then draw that into the original
// layer. Technically that makes little sense, but it shows
// CGFramebuffer working...
//
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGFramebuffer                       *cgLayer;
   CGRect                              canvas;
   CGRect                              originalCanvas;
   CGRect                              rect;
   CGRect                              rects[ 2][ 2];
   NSUInteger                          i, j;
   struct CGFramebufferRenderInfo      memo;

   @autoreleasepool
   {
      originalCanvas = [layer canvas];

      // draw a little square "conventionally"
      rect = CGRectCenterInRect( CGRectMake( 0, 0, 40, 40), originalCanvas);

      CGContextBeginPath( context);
      CGContextRect( context, rect);
      CGContextFillColor( context, CGColorMakeWithRGBA( 0.7, 0.5, 0.7, 1.0));
      CGContextFill( context);
#if 1
      // we want to draw the flag four times. We render it once into a CGFramebuffer
      // and then draw the CGFramebuffer. This may or may not be better than drawing
      // the flags immediately, but this is just a demo to show how its done.

      //
      // 2. create a CGFramebuffer where we want to draw to. Size is fairly arbitrary.
      //    as it will be used as texture.
      //
      canvas.origin = CGPointZero;
      canvas.size   = CGSizeMake( originalCanvas.size.height / 2.0, originalCanvas.size.width / 2.0);
      cgLayer       = [CGFramebuffer framebufferWithBitmapSize:CGPixelSizeMakeWithSize( canvas.size)
                                                  textureFlags:0
                                                       context:context];
      [cgLayer beginFBRenderWithBackgroundColor:CGColorMakeGray()
                               devicePixelRatio:1.0
                                layerRenderInfo:&memo];
      drawRedWhiteBlueFlag( context, CGRectInset( canvas, 2.0, 2.0)); // Updated function call
      [cgLayer endFBRender:&memo];

      CGRectPartition2x2( originalCanvas, CGSizeMake( 8.0, 8.0), rects);
      for( i = 0; i < 2; i++)
         for( j = 0; j < 2; j++)
         {
            [cgLayer drawRect:rects[ j][ i]
                      options:&CGDrawableOptionsScaleToFit
                      context:context];

            rect = CGRectExtrude( rects[ j][ i], 1, 1);
            CGContextBeginPath( context);
            CGContextRect( context, rect);
            CGContextStrokeColor( context, CGColorMakeGreen());
            CGContextStrokeWidth( context, 2.0);
            CGContextStroke( context);
         }

      // CGFramebuffer must remain until actual render end or flush
      [context flushRender];
#endif
   }
   return( YES);
}


int   main( int argc, char *argv[])
{
   NSUInteger      styleMask;
   UIApplication   *app;
   UIWindow        *window;
   CGFloat         fps = UIWindowFrameRateAsync;
   int             i;

   styleMask  = UIWindowStyleMaskDefault;
   styleMask &= ~UIWindowStylePlanes;
   styleMask &= ~UIWindowStyleAntiAlias;

   for( i = 1; i < argc; i++)
   {
      if( ! strcmp( argv[ i], "-f") && i + 1 < argc)
         fps = 1.0 / atof( argv[ ++i]);
      else if( ! strcmp( argv[ i], "-msaa"))
         styleMask |= UIWindowStyleAntiAlias;
      else if( ! strcmp( argv[ i], "-h") || ! strcmp( argv[ i], "--help"))
      {
         mulle_fprintf( stderr, "Usage: cglayer-convenient [-f <fps>] [-nomsaa]\n");
         return( 0);
      }
   }

   fprintf( stderr, "%s\n", [CGContext backendUTF8String]);

   app = [UIApplication sharedInstance];

   window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 200, 200)
                      titleUTF8String:"Demo"
                            styleMask:styleMask];
   [window setFrameRate:fps];  // run with low frequency to detect texture leaks
   [window setDrawCallback:drawStuff];
   // turning this on boosts from 1100 to 1400! (with -O0 sic!)
   [window setKeepOSGraphicsContextActive:YES];

   [window setFrameDelegate:[MulleUIPerf instance]];

   return( [app runWindow:window]);
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


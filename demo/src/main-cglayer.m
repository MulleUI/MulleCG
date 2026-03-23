#define _GNU_SOURCE

#import "import-private.h"
#include "draw-flag.inc"
//
// this demo does the simple stripes stuff, except that
// we render into a CGFramebuffer first. Then draw that into the original
// layer. Technically that makes little sense, but it shows
// CGFramebuffer working...
//
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *_context)
{
   CGContext                     *context = _context;
   CGFramebuffer                       *cgLayer;
   CGRect                        canvas;
   CGRect                        originalCanvas;
   CGRect                        rect;
   struct CGBitmapInfo           bitmapInfo;
   struct CGContextFramebuffer   previous;
   struct CGFrameInfo            frameInfo;
   struct CGFrameInfo            oldFrameInfo;
   CGRect                        rects[ 2][ 2];
   NSUInteger                    i, j;

   @autoreleasepool
   {
      originalCanvas = [layer canvas];
      // draw a little square "conventionally"
      rect = CGRectCenterInRect( CGRectMake( 0, 0, 40, 40), originalCanvas);

      CGContextBeginPath( context);
      CGContextRect( context, rect);
      CGContextFillColor( context, CGColorMakeWithRGBA( 0.7, 0.5, 0.7, 1.0));
      CGContextFill( context);

      // we want to draw the flag four times. We render it once into a CGFramebuffer
      // and then draw the CGFramebuffer. This may or may not be better than drawing
      // the flags immediately, but this is just a demo to show how its done.

      // 1. remember current drawing environment
      [context getCurrentFrameInfo:&oldFrameInfo];
      cgLayer = nil;
      //
      // 2. create a CGFramebuffer where we want to draw to. Size is fairly arbitrary.
      //    as it will be used as texture.
      //
      canvas.origin = CGPointZero;
      canvas.size   = CGSizeMake( originalCanvas.size.height / 2.0, originalCanvas.size.width / 2.0);
      cgLayer        = [CGFramebuffer framebufferWithBitmapSize:CGPixelSizeMakeWithSize( canvas.size)
                                       textureFlags:0
                                            context:context];
      // 3. flush drawings so they don't appear in our framebuffer
      [context flushRender];

      // 4. now set the drawing destination to the CGFramebuffer framebuffer
      previous = [context bindFramebuffer:CGContextFramebufferMakeWithFramebuffer( cgLayer)];

      // 5. tell CGContext about the new dimensions
      frameInfo = CGFrameInfoFBMake( CGPixelSizeMakeWithSize( canvas.size), 1.0, 1.0);
      [context changeRender:&frameInfo];
      drawRedWhiteBlueFlag( context, canvas);

      // 6. flush all draw commands to our framebuffer
      [context flushRender];
      // [cgLayer writeToPNGUTF8String:"hein.png"];

      // 7. rebind to previous
      [context bindFramebuffer:previous];

      // 8. restore render to what was before (and done)
      [context changeRender:&oldFrameInfo];

      CGRectPartition2x2( originalCanvas, CGSizeMake( 8.0, 8.0), rects);
      for( i = 0; i < 2; i++)
         for( j = 0; j < 2; j++)
         {
            [cgLayer drawRect:rects[ j][ i]
                      options:NULL
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
   }
//   [UIApp requestTerminate];
   return( YES);
}
int   main( int argc, char *argv[])
{
   NSUInteger      styleMask;
   UIApplication   *app;
   UIWindow        *window;

   fprintf( stderr, "%s\n", [CGContext backendUTF8String]);

   app = [UIApplication sharedInstance];

   styleMask  = UIWindowStyleMaskDefault;
   styleMask &= ~UIWindowStyleRetained;

   window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 200, 200)
                      titleUTF8String:"Demo"
                            styleMask:styleMask];
   // [window setFrameRateHz:100.0];  // run with high frequency to detect leaks
   [window setDrawCallback:drawStuff];

   return( UIApplicationRunWindow( window));
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


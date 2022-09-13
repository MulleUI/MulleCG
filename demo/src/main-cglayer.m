#define _GNU_SOURCE

#import "import-private.h"


//
// this demo does the simple stripes stuff, except that
// we render into a CGLayer first. Then draw that into the original
// layer. Technically that makes little sense, but it shows
// CGLayer working...
//
static void   drawStuff( CALayer *layer, CGContext *context)
{
   struct NVGcontext             *vg;
   CGRect                        originalCanvas;
   CGLayer                       *cgLayer;
   CGRect                        canvas;
   struct CGBitmapInfo           bitmapInfo;
   struct CGFrameInfo            frameInfo;
   struct CGFrameInfo            oldFrameInfo;
   CGRect                        rect;
   struct CGContextFramebuffer   previous;

   originalCanvas = [layer canvas];

   vg = CGContextGetNVGContext( context);

   // draw a little square "conventionally"
   rect = CGRectCenterInRect( CGRectMake( 0, 0, 40, 40), originalCanvas);

   nvgBeginPath( vg);
   nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
   nvgFillColor( vg, nvgRGBAf( 0.7, 0.5, 0.7, 1.0));
   nvgFill( vg);

   // we want to draw the flag four times. We render it once into a CGLayer
   // and then draw the CGLayer. This may or may not be better than drawing
   // the flags immediately, but this is just a demo to show how its done.

   // 1. remember current drawing environment
   [context getCurrentFrameInfo:&oldFrameInfo];

   //
   // 2. create a CGLayer where we want to draw to. Size is fairly arbitrary.
   //    as it will be used as texture.
   //
   canvas.origin = CGPointZero;
   canvas.size   = CGSizeMake( originalCanvas.size.height / 2.0, originalCanvas.size.width / 2.0);

   cgLayer = [CGLayer layerWithIntegerSize:CGSizeGetIntegerSize( canvas.size)
                               imageFlags:0
                                  context:context];

   // 3. flush drawings so they don't appear in out framebuffer
   [context flushRender];

   // 4. now set the drawing destination to the CGLayer framebuffer
   previous = [context  bindFramebuffer:CGContextFramebufferMakeWithLayer( cgLayer)];

   // 5. tell CGContext about the new dimensions
   frameInfo = CGFrameInfoFBMake( CGSizeGetIntegerSize( canvas.size), 1.0, 1.0);
   [context changeRender:&frameInfo];

   // drawing code as such is unchanged from main-draw-simple.m
   {
      canvas.size.height  /= 3.0;

      vg = CGContextGetNVGContext( context);
      // draw red stripe first then suspend and resume
      // pixels...
      // red stripe
      nvgBeginPath( vg);
      nvgRect( vg, canvas.origin.x,
                   canvas.origin.y,
                   canvas.size.width,
                   canvas.size.height);
      nvgFillColor( vg, nvgRGBAf( 0.95, 0.0, 0.0, 1.0));
      nvgFill( vg);

      // add this point the drawing should have been flushed to the
      // framebuffer, so now we should be able to read it...

      // white stripe
      nvgBeginPath( vg);
      nvgRect( vg, canvas.origin.x,
                   canvas.origin.y + canvas.size.height * 1,
                   canvas.size.width,
                   canvas.size.height);
      nvgFillColor( vg, nvgRGBAf( 1.0, 1.0, 1.0, 1.0));
      nvgFill( vg);

      // blue stripe
      nvgBeginPath( vg);
      nvgRect( vg, canvas.origin.x,
                   canvas.origin.y + canvas.size.height * 2,
                   canvas.size.width,
                   canvas.size.height);
      nvgFillColor( vg, nvgRGBAf( 0.0, 0.0, 1.0, 1.0));
      nvgFill( vg);

      canvas.size.height  *= 3.0;
   }

   // 6. flush all draw commands to our framebuffer
   [context flushRender];

   // 7. unbind to default. You can only do `unbindFramebuffer` with a
   // UIWindowStyleRenderNonRetainedOnly window! It's better to let the
   // context do it with `bindDefaultFramebuffer`
   // [cgLayer unbindFramebuffer];
   [context bindFramebuffer:previous];

   // 8. restore render to what was before (and done)
   [context changeRender:&oldFrameInfo];


   {
      CGRect       rows[ 2];
      CGRect       columns[ 2];
      NSUInteger   i, j;

      CGRectPartitionVertically( originalCanvas,
                                 8.0,
                                 2,
                                 rows);
      for( i = 0; i < 2; i++)
      {
         CGRectPartitionHorizontally( rows[ i],
                                      8.0,
                                      2,
                                      columns);
         for( j = 0; j < 2; j++)
         {
            [cgLayer drawRect:columns[ j]
                      options:NULL
                      context:context];
         }
      }
   }
}



int   main( int argc, char *argv[])
{
   NSUInteger      styleMask;
   UIApplication   *app;
   UIWindow        *window;

   fprintf( stderr, "%s\n", [CGContext nanoVGBackendUTF8String]);

   app = [UIApplication sharedInstance];
   @autoreleasepool
   {
      styleMask = (UIWindowStyleMaskDefault & ~UIWindowStyleRetained);

      window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 200, 200)
                         titleUTF8String:"Demo"
                               styleMask:styleMask];
      [window setFrameRateHz:100.0];
      [[window contentPlane] setDrawCallback:drawStuff];
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


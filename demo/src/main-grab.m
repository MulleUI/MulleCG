#define _GNU_SOURCE

#import "import-private.h"

#include <assert.h>



static void   drawFramebufferBitmap( UIWindow *window,
                                     struct CGFramebufferBitmap *fb)
{
   CGContext            *context;
   struct CGFrameInfo   info;

   context = [window activateWindowGraphicsContext];
   assert( context);

   {
      [window getFrameInfo:&info];
      [context beginRender:&info];
      {
         [context clearFramebuffer];
         [context drawFramebufferBitmap:fb];
      }
      [context endRender];
   }
   [window deactivateWindowGraphicsContext:context];

   [window swapBuffers];
}


static char   *title[] =
{
   "Drawing",
   "Colors",
   "Stencil",
   "Depth"
};


int   main( int argc, char *argv[])
{
   UIApplication                *app;
   UIWindow                     *window[ 4];
   CGRect                       rows[ 2];
   CGRect                       frame[ 4];
   CGContext                    *context;
   NSUInteger                   i;
   struct CGFramebufferBitmap   fb;
   struct CGFrameInfo           info;
   struct NVGcontext            *vg;
   NSUInteger                   styleMask;

   // the usual first step
   app = [UIApplication sharedInstance];
   @autoreleasepool
   {

      // figure out window placements
      CGRectPartitionVertically( CGRectMake( 0, 0, 400, 400),
                                 16.0,
                                 2,
                                 rows);
      for( i = 0; i < 2; i++)
         CGRectPartitionHorizontally( rows[ i],
                                      4.0,
                                      2,
                                      &frame[ i * 2]);
      //
      // create windows, we use non-retained because it's easier
      // TODO: write version with different stylemask (or set option)
      //
      for( i = 0; i < 4; i++)
      {
         styleMask  = (UIWindowStyleMaskDefault & ~UIWindowStyleRetained);
         window[ i] = [UIWindow windowWithFrame:frame[ i]
                                titleUTF8String:title[ i]
                                      styleMask:styleMask];
         [app addWindow:window[ i]];
      }

      // our self made renderloop
      for(;;)
      {
         //
         // build scene in window #1
         // as we are not doing anything with UIViews, we forego the usual
         // renderUpToNumberOfFrames:1 but do everything manually
         context = [window[ 0] activateWindowGraphicsContext];
         {
            [window [0] getFrameInfo:&info];
            [context beginRender:&info];
            {
               [context clearFramebuffer];

               vg = CGContextGetNVGContext( context);
               nvgBeginPath( vg);
               {
                  nvgRect( vg, 20, 20, 40, 40);
               }
               nvgFillColor( vg, CGColorMakeWithUnsignedInteger( 0xA05030FF));
               nvgFill( vg);
            }
            [context endRender];
         }
         [window[ 0] deactivateWindowGraphicsContext:context];
         [window[ 0] swapBuffers];

         // grab color info of window[ 0], display in window[ 1]
         fb  = [window[ 0] lastRenderedFramebufferBitmapType:CGFramebufferRGBABytes
                                                    inFlight:NO
                                                   allocator:NULL];
         drawFramebufferBitmap( window[ 1], &fb);
         CGFramebufferBitmapDone( &fb);

         // grab stencil info of window[ 0], display in window[ 2]
         fb  = [window[ 0] lastRenderedFramebufferBitmapType:CGFramebufferStencilFloats
                                                    inFlight:NO
                                                   allocator:NULL];
         drawFramebufferBitmap( window[ 2], &fb);
         CGFramebufferBitmapDone( &fb);

         // grab depth info of window[ 0], display in window[ 3]
         fb  = [window[ 0] lastRenderedFramebufferBitmapType:CGFramebufferDepthFloats
                                                    inFlight:NO
                                                   allocator:NULL];
         drawFramebufferBitmap( window[ 3], &fb);
         CGFramebufferBitmapDone( &fb);

         [UIEvent waitForEventsHz:INFINITY];
         if( [window[ 0] shouldClose])
            break;
      }
   }
   [app terminate];
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


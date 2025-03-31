#define _GNU_SOURCE

#import "import-private.h"


//
// This demo shows how CGContext draws into a offscreen buffer first and
// this buffer is shared with another window[ 0]s. For "fun", both window[ 0]s
// run with different framerates.
//
static void   drawStuff( CGRect canvas,
                         NSUInteger counter,
                         CGColor leftColor,
                         CGColor middleColor,
                         CGColor rightColor,
                         CGContext *context)
{
   struct NVGcontext   *vg;
   auto char           buf[ 64];
   CGFont              *font;

   vg = CGContextGetNVGContext( context);

   canvas.size.width  /= 3.0;

   // red stripe
   nvgBeginPath( vg);
   nvgRect( vg, canvas.origin.x,
                canvas.origin.y,
                canvas.size.width,
                canvas.size.height);
   nvgFillColor( vg, leftColor);
   nvgFill( vg);

   // white stripe
   nvgBeginPath( vg);
   nvgRect( vg, canvas.origin.x + canvas.size.width * 1,
                canvas.origin.y,
                canvas.size.width,
                canvas.size.height);
   nvgFillColor( vg, middleColor);
   nvgFill( vg);

   // blue stripe
   nvgBeginPath( vg);
   nvgRect( vg, canvas.origin.x + canvas.size.width * 2,
                canvas.origin.y,
                canvas.size.width,
                canvas.size.height);
   nvgFillColor( vg, rightColor);
   nvgFill( vg);

   sprintf( buf, "%td", counter);

   font = [context fontWithNameUTF8String:"sans"];
   [context useFont:font];

   canvas.size.width  *= 3.0;

   nvgFontSize( vg, 32);
   nvgTextAlign( vg, NVG_ALIGN_CENTER | NVG_ALIGN_MIDDLE);
   nvgTextColor( vg, CGColorMakeWithHexColor( 0x0000000FF));
   nvgTextBackgroundColor( vg, middleColor);
   nvgText( vg, CGRectGetMidX( canvas), CGRectGetMidY( canvas), buf, NULL);
}


@interface MyWindow : GLFWOSWindow <UIOSWindow>

@property( retain) CGContext    *context;

@property( assign) CGColor      leftColor;
@property( assign) CGColor      middleColor;
@property( assign) CGColor      rightColor;

@property( assign) NSUInteger   counter;

@end

@implementation MyWindow

- (NSUInteger) incrementCounter
{
   return( ++_counter);
}

+ (UIGraphicsBackend) defaultBackend
{
   return( UIGraphicsBackendDefault);
}

@end


static UIWindowDisplayBits   display_0( id <UIOSWindow> *window_in)
{
   MyWindow         *window = MULLE_OBJC_CLASS_CAST( MyWindow, window_in);
   CGRect           canvas;
   CGContext        *context;
   CGFrameInfo      frameInfo;
   CGLayer          *layer;
   CGLayer          *check;
   static CGLayer   *previous;

   canvas.origin = CGPointZero;
   canvas.size   = [window os_windowSize];
   context       = [window context];

   [window os_activateGraphicsContext];
   {
      frameInfo = CGFrameInfoSFMake( canvas, [window os_framebufferSize], 1.0);

      // tell the context to render offscreen
      [context setRendersOffScreen:YES];
      [context beginRender:&frameInfo];
      {
         drawStuff( canvas, [window incrementCounter],
                            [window leftColor],
                            [window middleColor],
                            [window rightColor],
                            context);
      }
      [context endRender];

      // now we should have it
      layer = [context acquireOffscreenFramebuffer];
      assert( layer);

      // should be gone from context
      check = [context acquireOffscreenFramebuffer];
      assert( ! check);

      if( previous != layer)
         fprintf( stderr, "new offscreen framebuffer (should only be seen on init and resize)\n");

      // draw layer in window[ 0] framebuffer
      [context setRendersOffScreen:NO];
      [context beginRender:&frameInfo];
      {
         [context clearFramebuffer];
         [layer drawRect:CGRectInset( canvas, 10, 10)
                 options:NULL
                 context:context];
      }
      [context endRender];

      [context recycleFramebuffer:layer];

      // should still be gone, since we don't pick the trashcan
      check = [context acquireOffscreenFramebuffer];
      assert( ! check);

      // remember it, and check next time that it's been reused
      previous = layer;
   }
   [window os_deactivateGraphicsContext];
   return( 1);
}


static UIWindowDisplayBits  display_1( id <UIOSWindow> *window_in)
{
   MyWindow         *window = MULLE_OBJC_CLASS_CAST( MyWindow, window_in);
   CGRect           canvas;
   CGContext        *context;
   CGFrameInfo      frameInfo;
   CGLayer          *layer;
   CGLayer          *check;
   static CGLayer   *previous;

   canvas.origin = CGPointZero;
   canvas.size   = [window os_windowSize];
   context       = [window context];

   [window os_activateGraphicsContext];
   {
      frameInfo = CGFrameInfoSFMake( canvas, [window os_framebufferSize], 1.0);

      // tell the context to render offscreen
      [context setRendersOffScreen:YES];
      [context beginRender:&frameInfo];
      {
         drawStuff( canvas, [window incrementCounter],
                            [window leftColor],
                            [window middleColor],
                            [window rightColor],
                            context);
      }
      [context endRender];

      // now we should have it
      layer = [context acquireOffscreenFramebuffer];
      assert( layer);

      // should be gone from context
      check = [context acquireOffscreenFramebuffer];
      assert( ! check);

      if( previous != layer)
         fprintf( stderr, "new offscreen framebuffer (should only be seen on init and resize)\n");

      // draw layer in window[ 0] framebuffer
      [context setRendersOffScreen:NO];
      [context beginRender:&frameInfo];
      {
         [context clearFramebuffer];
         [layer drawRect:CGRectInset( canvas, 10, 10)
                 options:NULL
                 context:context];
      }
      [context endRender];

      [context recycleFramebuffer:layer];

      // should still be gone, since we don't pick the trashcan
      check = [context acquireOffscreenFramebuffer];
      assert( ! check);

      // remember it, and check next time that it's been reused
      previous = layer;
   }
   [window os_deactivateGraphicsContext];

   retuzrn( 1);
}


static MyWindow   *create_window( unsigned int i,
                                  MyWindow *sharingWindow,
                                  void  (*display_f)( GLFWOSWindow *),
                                  double frameRate)
{
   MyWindow      *window;
   NSUInteger    hints;
   CGContext     *context;


   hints = GLFW_DEFAULT_CONTEXT;
   switch( [MyWindow defaultBackend])
   {
   case UIGraphicsBackendGL3   : hints = GLFW_GL3_CONTEXT; break;
   case UIGraphicsBackendGL3_2 : hints = GLFW_GL3_2_CONTEXT; break;
   case UIGraphicsBackendGLES2 : hints = GLFW_GLES2_CONTEXT; break;
   case UIGraphicsBackendGLES3 : hints = GLFW_GLES3_CONTEXT; break;
   }

   window = [[[MyWindow alloc] initWithFrame:CGRectMake( 200 + 200 * i, 200, 200, 200)
                             titleUTF8String:"Demo"
                                   styleMask:GLFWOSWindowStyleMaskDefault|UIWindowStyleResizable
                               graphicsHints:hints
                               sharingWindow:sharingWindow] autorelease];

   [window os_activateGraphicsContext];
   {
      context = [[[CGContext alloc] initWithOSGraphicsContext:window
                                                      shareID:[window shareID]
                                                      options:UIGraphicsDefaultOptions] autorelease];      // have to do this manually, because the context is created manually

      // remember context for "display" callback
      [window setContext:context];
      [window setFrameCallback:display_0];
      [window setFrameRate:frameRate];

      [window setLeftColor:CGColorMakeWithHexColor( 0x008C45FF)];
      [window setMiddleColor:CGColorMakeWithHexColor( 0xF4F5F0FF)];
      [window setRightColor:CGColorMakeWithHexColor( 0xCD212AFF)];
   }
   [window os_deactivateGraphicsContext];

   return( window);
}


int   main( int argc, char *argv[])
{
   UIApplication            *app;
   MyWindow                 *window[ 2];

   app = [UIApplication sharedInstance];
   @autoreleasepool
   {
      window[ 0] = create_window( 0, nil, display_0, 30.0);
      [app addWindow:window[ 0]];

      window[ 1] = create_window( 1, window[ 0], display_1, 60.0);
      [app addWindow:window[ 1]];
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


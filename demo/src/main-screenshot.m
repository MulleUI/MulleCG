#import <MulleUICore/MulleUICore.h>

#import <string.h>

#define HAVE_SCREENSHOT_VIEW     1

#define BUFFER    GL_FRONT // GL_BACK

static CGImage   *image;


void   screenshot( UIWindow *window)
{
   struct CGFramebufferBitmap   fb;
   CGContext                    *context;

   context = [window activateWindowContext];
   assert( [context isActive]);

   [image mullePerformFinalize];
   [image release];

   fb    = [context lastRenderedFramebuffer];
   image = [[CGImage alloc] initWithRGBABytes:fb.bytes
                                   bitmapSize:fb.info.size
                                   imageFlags:0 // NVG_IMAGE_REPEATX
                                      context:context];
   [window deactivateWindowContext:context];

   assert( image);
}


static void   drawSmall( CALayer *layer, CGContext *context)
{
   CGDrawableOptions   options;
   NVGcontext          *vg;

   options = CGDrawableOptionsMake( 0.0, 1.0, 0.0, YES);

   vg = CGContextGetNVGContext( context);

   nvgSave( vg);

   //
   // theory: the green flicker can "only" be explained by
   // reading transparent pixels from the screen sometimes and then sometimes
   // not.
   //
   nvgGlobalCompositeOperation( vg, NVG_COPY); // ignore alpha
   [image drawRect:[layer canvas]
           options:&options
           context:context];
   nvgRestore( vg);
}


static void  drawLarge( CALayer *layer, CGContext *context)
{
   CGRect       rect;
   CGRect       shape;
   CGRect       circle;
   NVGcontext   *vg;
   CGFrameInfo  *info;
   CGFloat      radius;
   NSUInteger   frameNumber;

   frameNumber = [context numberOfRenderedFrames];

   vg    = CGContextGetNVGContext( context);

   rect  = [layer canvas];
   shape = CGRectInset( rect, 60, 60);

   info  = [context currentFrameInfo];

   nvgTranslate( vg, CGRectGetMidX( shape), CGRectGetMidY( shape));
   nvgRotate( vg, 3.141 * 2 * (frameNumber % 360) / 360);
   nvgTranslate( vg, -CGRectGetMidX( shape), -CGRectGetMidY( shape));

   nvgBeginPath( vg);
   {
      nvgRect( vg, shape.origin.x, shape.origin.y, shape.size.width, shape.size.height);
      nvgFillColor( vg, CGColorMakeRGBA( (frameNumber % 360) / 359.0, 0.6, 0.8, 1.0));
   }
   nvgFill( vg);

   circle = CGRectInset( shape, 5, 5);
   if( circle.size.width < circle.size.height)
      radius = circle.size.width / 4.0 / 2.0;
   else
      radius = circle.size.height / 4.0 / 2.0;

   circle.size.width  = radius * 2.0;
   circle.size.height = radius * 2.0;
   nvgBeginPath( vg);
   {
      nvgCircle( vg, CGRectGetMidX( circle), CGRectGetMidY( circle), radius);
      nvgStrokeColor( vg, [UIColor darkGrayColor]);
      nvgStrokeWidth( vg, 3.0);
   }
   nvgStroke( vg);
}


void   setupScene( UIWindow *window)
{
   UIView   *view;
   UIView   *contentPlane;
   CGRect   rect1;
   CGRect   rect2;

   contentPlane = [window contentPlane];
   rect1        = [contentPlane contentRect];
   rect1        = CGRectInset( rect1, 40, 40);

   view = [UIView viewWithFrame:rect1];
   [view setBackgroundColor:[UIColor darkGrayColor]];
   [view setBorderColor:[UIColor whiteColor]];
   [view setBorderWidth:4.0];
   [view setDrawCallback:drawLarge];
   [contentPlane addSubview:view];

#if HAVE_SCREENSHOT_VIEW
   rect2 = [contentPlane contentRect];
   rect2 = CGRectInset( rect2, 20, 20);

   rect2.size.width  /= 2.0;
   rect2.size.height /= 2.0;
   view = [UIView viewWithFrame:rect2];
   [view setBorderColor:[UIColor lightGrayColor]];
   [view setBorderWidth:2.0];
   [view setBackgroundColor:[UIColor greenColor]];
   [view setDrawCallback:drawSmall];
   [contentPlane addSubview:view];
#endif
}


int   main( int argc, char *argv[])
{
   UIWindow       *window;
   UIApplication  *app;
   CGFloat        frameRateHz;

   /*
    * window and app
    */
   app    = [UIApplication sharedInstance];
   window = [UIWindow windowWithFrame:CGRectMake( 0.0f, 0.0f, 640.0f, 400.0f)];
   [window setBackgroundColor:CGColorMakeRGBA( 0.0, 0.0, 0.0, 1.0)];
   [app addWindow:window];

   setupScene( window);

   // Without screenshot, behaviour on resize:
   //
   // 5hz: super stable
   // 10hz: super stable
   // 30hz: flickers madly
   // 60hz: flickers a little
   // 100hz: super stable
   // 500hz: super stable
   //
   // MEMO: could apparently fix this somewhat with _needsWindowRefresh being set
   // by the window refresh event and preempting event processing. Does not
   // cure green flicker though. Reduces 30Hz flicker to rare.

   // With screenshot, behaviour on resize:
   //
   // 5hz: rare green redraw on small view
   // 10hz: rare green redraw on small view
   // 30hz: green redraw on small view
   // 60hz: green redraw on small view
   // 100hz: pronounced green redraw on small view
   // 500hz: small green redraw on small view
   //
   // MEMO: frequencyRate makes no big difference
   //       fetching from GL_BACK makes no difference
   //       Setting global operation to COPY fixes this, but why is the
   //       buffer somtimes copied with alpha and sometimes not ?
   //       Setting back to GL_FRONT now seems to fix it.
   //
   frameRateHz = 0.0;
   if( argc >= 2)
      frameRateHz = atof( argv[ 1]);
   if( frameRateHz == 0.0)
      frameRateHz = 60.0;
   printf( "%.1fHz\n", frameRateHz);
   [window setFrameRateHz:frameRateHz];

   // TODO: don't work because the context is gone

#if HAVE_SCREENSHOT_VIEW
   if( BUFFER == GL_FRONT)
   {
      [window setDidSwapCallback:screenshot];
   }
   else
      [window setWillSwapCallback:screenshot];
#endif

   [window renderLoop];

   [app terminate];
   return( 0);
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


#import "import.h"

#import <string.h>


#define HAVE_TEXTURE

#ifdef HAVE_TEXTURE

static CGLayer   *texture;

//
// In this example, we use nvg to draw something into a CGLayer (aka texture).
// Then we use this CGLayer as paint (texture) for a rectangle.
// The drawing of the texture must be done outside of the main window render
// loop.
//
static void   drawTexture( CGContext *context, CGSize size)
{
   CGFloat      radius;
   NVGcontext   *vg;

   vg = CGContextGetNVGContext( context);

   nvgBeginPath( vg);
   {
      nvgRect( vg, 0, 0, size.width, size.height);
      nvgFillColor( vg, CGColorMakeWithHexColor( 0xFFFF20FF));
   }
   nvgFill( vg);

   nvgBeginPath( vg);
   {
      radius  = size.width < size.height ? size.width : size.height;
      radius -= 4.0;
      radius /= 2.0;

      nvgCircle( vg, size.width / 2.0, size.height / 2.0, radius);
      nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x2040FFFF));
      nvgStrokeWidth( vg, 4.0);
   }
   nvgStroke( vg);
}


static void  createTexture( CGContext *context,
                            CGFloat pixelRatio,
                            NSUInteger imageFlags)
{
   CGFrameInfo                   *info;
   CGFloat                       radius;
   struct CGBitmapInfo           bitmapInfo;
   struct CGFrameInfo            frameInfo;
   struct CGFrameInfo            oldFrameInfo;
   struct CGContextFramebuffer   oldFramebuffer;

   assert( pixelRatio > 0.0);

   // we create small 32x32 texture

   texture = [CGLayer layerWithBitmapSize:MulleIntegerSizeMake( 32, 32)
                               imageFlags:imageFlags
                                  context:context];
   assert( texture);

   frameInfo      = CGFrameInfoFBMake( MulleIntegerSizeMake( 32, 32), pixelRatio, 1.0);

   //
   // with the push functionality, we should be able to run this also inside
   // an active render.
   //
   oldFramebuffer = [context bindFramebuffer:CGContextFramebufferMakeWithLayer( texture)];
   oldFrameInfo   = [context bindRender:&frameInfo];
   {
      drawTexture( context, CGFrameInfoGetFrameSize( &frameInfo));
   }
   [context bindRender:&oldFrameInfo];
   [context bindFramebuffer:oldFramebuffer];
}

#endif


static void  drawStuff( CALayer *layer, CGContext *context)
{
   CGFloat      angle;
   CGRect       rect;
   CGRect       shape;
   MullePaint   *paint;
   NSUInteger   frameNumber;
   NVGcontext   *vg;

   frameNumber = [context numberOfFrames];

   rect  = [layer canvas];
   shape = CGRectInset( rect, 60, 60);

   vg    = CGContextGetNVGContext( context);
   angle = 3.141 * 2 * (frameNumber % 360) / 360;

   nvgTranslate( vg, CGRectGetMidX( shape), CGRectGetMidY( shape));
   nvgRotate( vg, angle);
   nvgTranslate( vg, -CGRectGetMidX( shape), -CGRectGetMidY( shape));

   nvgBeginPath( vg);
   {
      nvgRect( vg, shape.origin.x, shape.origin.y, shape.size.width, shape.size.height);
      // ugliness fix this, this need not be an object

#ifdef HAVE_TEXTURE
      paint = [[[MullePaint alloc] initPatternWithImage:texture
                                                   rect:CGRectMake( 0, 0, 32, 32)
                                                  angle:angle
                                                  alpha:1.0
                                                context:context] autorelease];
      nvgFillPaint( vg, [paint nvgPaint]);
#else
      nvgFillColor( vg, CGColorMakeWithHexColor( 0xFFFF00FF));
#endif
   }
   nvgFill( vg);
}


void   setupScene( UIWindow *window)
{
   UIView      *view;
   UIView      *contentPlane;
   CGRect      rect;
   CGContext   *context;

   contentPlane = [window contentPlane];
   rect         = [contentPlane contentRect];
   rect         = CGRectInset( rect, 40, 40);

   view = [UIView viewWithFrame:rect];
   [view setBackgroundColor:[UIColor darkGrayColor]];
   [view setBorderColor:[UIColor whiteColor]];
   [view setBorderWidth:4.0];
   [view setDrawCallback:drawStuff];
   [contentPlane addSubview:view];

#ifdef HAVE_TEXTURE
   //
   // We want to do drawing outside of the render, so we
   // need to get an activated context from the window.
   //
   context = [window activateWindowGraphicsContext];
   createTexture( context,
                  [window pixelRatio],
                  NVG_IMAGE_REPEATX|NVG_IMAGE_REPEATY);
   [window deactivateGraphicsContext:context];
#endif
}


int   main( int argc, char *argv[])
{
   UIWindow        *window;
   UIApplication   *app;
   NSUInteger      styleMask;

   /*
    * window and app
    */
   app = [UIApplication sharedInstance];

   styleMask = UIWindowStyleMaskDefault;
   styleMask = UIWindowsStyleMaskBySetting( styleMask, UIWindowStyleResizable, YES);
   styleMask = UIWindowsStyleMaskBySetting( styleMask, UIWindowStyleRetained, NO);

   window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 640.0f, 600.0f)
                             titleUTF8String:"Demo"
                                   styleMask:styleMask] autorelease];

   [window setBackgroundColor:CGColorMakeWithRGBA( 0.0, 0.0, 0.0, 1.0)];
   [window setFrameRateHz:60.0f];
   setupScene( window);

   [app addWindow:window];

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


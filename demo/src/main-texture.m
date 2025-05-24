#import "import.h"

#import <string.h>


#define HAVE_TEXTURE

#ifdef HAVE_TEXTURE

static CGFramebuffer   *texture;

//
// In this example, we use nvg to draw something into a CGFramebuffer (aka texture).
// Then we use this CGFramebuffer as paint (texture) for a rectangle.
// The drawing of the texture must be done outside of the main window render
// loop. (why ? Apparently because at the time of writing this there was
// no way to "stack" framebuffer bindings.
// TODO: update the code to stack...)
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


static CGFramebuffer  *createTexture( CGContext *context,
                                      CGFloat pixelRatio,
                                      NSUInteger textureFlags)
{
   CGFrameInfo                   *info;
   CGFloat                       radius;
   struct CGBitmapInfo           bitmapInfo;
   struct CGFrameInfo            frameInfo;
   struct CGFrameInfo            oldFrameInfo;
   struct CGContextFramebuffer   oldFramebuffer;
   CGFramebuffer                 *texture;

   assert( pixelRatio > 0.0);

   // we create a small 32x32 texture

   texture = [[CGFramebuffer framebufferWithBitmapSize:CGPixelSizeMake( 32, 32)
                              textureFlags:textureFlags
                                   context:context] retain];
   assert( texture);

   frameInfo      = CGFrameInfoFBMake( CGPixelSizeMake( 32, 32), pixelRatio, 1.0);

   //
   // with the push functionality, we should be able to run this also inside
   // an active render.
   //
   oldFramebuffer = [context bindFramebuffer:CGContextFramebufferMakeWithFramebuffer( texture)];
   oldFrameInfo   = [context bindRender:&frameInfo];
   {
      drawTexture( context, CGFrameInfoGetFrameSize( &frameInfo));
   }
   [context bindRender:&oldFrameInfo];
   [context bindFramebuffer:oldFramebuffer];
   return( texture);
}

#endif


static void  drawStuff( CALayer *layer, CGContext *context)
{
   CGFloat      angle;
   CGRect       rect;
   CGRect       shape;
   CGFloat      rotation;
   NVGpaint     paint;
   NSUInteger   frameNumber;
   NVGcontext   *vg;

   frameNumber = [context numberOfFrames];

   rect     = [layer canvas];
   shape    = CGRectInset( rect, 60, 60);

   vg       = CGContextGetNVGContext( context);
   rotation = (frameNumber % 360) / 360.0;

   nvgTranslate( vg, CGRectGetMidX( shape), CGRectGetMidY( shape));
   nvgRotate( vg, CARotationToAngle( rotation));
   nvgTranslate( vg, -CGRectGetMidX( shape), -CGRectGetMidY( shape));

   nvgBeginPath( vg);
   {
      mvgRect( vg, shape);
      // ugliness fix this, this need not be an object

#ifdef HAVE_TEXTURE
      paint = mvgImagePattern( vg, CGRectMake( 0, 0, 32, 32),
                                   rotation,
                                   [texture textureID],
                                   1.0);
      nvgFillPaint( vg, paint);
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

   contentPlane = [window contentView];
   rect         = [contentPlane contentRect];
   rect         = CGRectInset( rect, 40, 40);

   view = [UIView viewWithFrame:rect];
   [view setBackgroundColor:[UIColor darkGrayColor]];
   [view setBorderColor:[UIColor whiteColor]];
   [view setBorderWidth:4.0];
   [view setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];
   [contentPlane addSubview:view];

#ifdef HAVE_TEXTURE
   //
   // We want to do drawing outside of the render, so we
   // need to get an activated context from the window.
   //
   context = (CGContext *) [window activateWindowGraphicsContext];
   @autoreleasepool
   {
      texture = createTexture( context,
                               [window pixelRatio],
                               NVG_IMAGE_REPEATX|NVG_IMAGE_REPEATY);
      [[texture bitmapImage] writeToPNGUTF8String:"debug.png"];
   }
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

   // different styleMask just for fun
   styleMask = UIWindowStyleMaskDefault;
   styleMask = UIWindowStyleMaskBySetting( styleMask, UIWindowStyleResizable, YES);
   styleMask = UIWindowStyleMaskBySetting( styleMask, UIWindowStyleRetained, NO);

   [CGContext setDebuggingFlags:YES];

   window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 640.0f, 600.0f)
                             titleUTF8String:"Demo"
                                   styleMask:styleMask] autorelease];

   [window setBackgroundColor:CGColorMakeWithRGBA( 0.0, 0.0, 0.0, 1.0)];
   [window setFrameRateHz:60.0f];
   setupScene( window);

   [app addWindow:window];

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


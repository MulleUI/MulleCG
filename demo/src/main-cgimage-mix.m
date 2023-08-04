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

#define IW   8
#define IH   8


static unsigned char    bitmap[4 * IH * IW] =
{
   B, W, B, B,  R, R, W, R,
   W, B, B, B,  R, R, R, W,
   B, B, _, _,  R, R, R, R,
   B, B, _, _,  _, R, R, R,

   Y, Y, Y, _,  W, _, G, G,
   Y, Y, Y, Y,  _, W, G, G,
   W, Y, Y, Y,  G, G, G, W,
   Y, W, Y, Y,  G, G, W, G
};


#define ROWS     10
#define COLUMNS  10

static void  drawRotated( struct NVGcontext *vg, CGImage *image, CGRect rect, NSInteger y, NSInteger x)
{
   NVGpaint   imgPaint;

   CGPoint        relativePoint;
   CAPolarPoint   rotatedPolarPoint;
   CAPolarPoint   centerPolarPoint;
   CGPoint        rotatedPoint;
   // texture is at 0.0, we calc the "scaled" texture point
   CGPoint        centerPoint;
   CGPoint        diffPoint;
   CAAngle        angle;
   CGFloat        scale;

   angle             = CADegreesToAngle( y * 36 + x * 36.0 / 10);
   scale             = 4.0;

   // calculate position independent the amout of rotation for the
   // center point
   centerPoint       = CGPointMake( rect.size.width / 2.0 / scale,  rect.size.height / 2.0 / scale);
   centerPolarPoint  = CAPolarPointMakeWithPoint( centerPoint);
   rotatedPolarPoint = CAPolarPointAddRadians( centerPolarPoint, angle);
   rotatedPoint      = CGPointMakeWithPolarPoint( rotatedPolarPoint);
   diffPoint         = CGPointMake( (rotatedPoint.x - centerPoint.x),
                                    (rotatedPoint.y - centerPoint.y));
   diffPoint.x      -= rect.size.width / scale;
   diffPoint.y      -= rect.size.height / scale;

   fprintf( stderr, "%.2f : %s -> %s -> %s\n",
                        angle,
                        CGPointUTF8String( centerPoint),
                        CGPointUTF8String( diffPoint),
                        CGPointUTF8String( rotatedPoint));

   imgPaint = nvgImagePattern( vg, rect.origin.x - diffPoint.x,
                                   rect.origin.y - diffPoint.y,
                                   rect.size.width / scale, // * (x / 10.0), // - (rect.size.width  / 4 * (y - 1)),
                                   rect.size.height / scale, // * (y / 10.0), // - (rect.size.height / 4 * (y - 1)),
                                   angle,
                                   [image textureID],
                                   1.0);
   nvgBeginPath( vg);
   nvgRect( vg, rect.origin.x,
                rect.origin.y,
                rect.size.width,
                rect.size.height);
   nvgFillPaint( vg, imgPaint);
   nvgFill( vg);
}



static void  drawUnscaled( struct NVGcontext *vg, CGImage *image, CGRect rect, NSInteger y, NSInteger x)
{
   NVGpaint   imgPaint;
   CGPoint    centerPoint;
   CGPoint    diffPoint;
   CGSize     size;
   CGSize     step;

   diffPoint = CGPointMake( x, y);
   size      = [image size];

   // center texture

   centerPoint    = CGRectGetCenterPoint( rect);
   centerPoint.x -= (rect.size.width - size.width) / 2.0;
   centerPoint.y -= (rect.size.height - size.height) / 2.0;

   step      = CGSizeMake( rect.size.width / COLUMNS, rect.size.height / ROWS);
   imgPaint  = nvgImagePattern( vg, rect.origin.x - (COLUMNS / 2 - x) * step.width,
                                    rect.origin.y - (ROWS / 2 - y) * step.height,
                                    size.width * 4, // * (x / 10.0), // - (rect.size.width  / 4 * (y - 1)),
                                    size.height * 4, // * (y / 10.0), // - (rect.size.height / 4 * (y - 1)),
                                    0.0,
                                    [image textureID],
                                    1.0);
   nvgBeginPath( vg);
   nvgRect( vg, rect.origin.x,
                rect.origin.y,
                rect.size.width,
                rect.size.height);
   nvgFillPaint( vg, imgPaint);
   nvgFill( vg);
}


static void  drawShifted( struct NVGcontext *vg, CGImage *image, CGRect rect, NSInteger y, NSInteger x)
{
   NVGpaint   imgPaint;
   CGSize     size;
   CGPoint    point;
   CGPoint    final;
   CGSize     scale;


   scale = CGSizeMake( 0.5, 0.5);

   size  = CGSizeMake( rect.size.width * scale.width / IW, rect.size.height * scale.height / IH);

   point = CGPointMake( (COLUMNS / 2 - x) * size.width,
                        (ROWS / 2 - y) * size.height);
   final = CGPointAdd( rect.origin, point);

   fprintf( stderr, "[x=%td/y=%td] %s : s=%s -> p=%s -> f=%s\n",
                        x, y,
                        CGPointUTF8String( rect.origin),
                        CGSizeUTF8String( size),
                        CGPointUTF8String( point),
                        CGPointUTF8String( final));

   imgPaint  = nvgImagePattern( vg, final.x,
                                    final.y,
                                    rect.size.width / scale.width, // * (x / 10.0), // - (rect.size.width  / 4 * (y - 1)),
                                    rect.size.height / scale.height, // * (y / 10.0), // - (rect.size.height / 4 * (y - 1)),
                                    0.0,
                                    [image textureID],
                                    1.0);
   nvgBeginPath( vg);
   nvgRect( vg, rect.origin.x,
                rect.origin.y,
                rect.size.width,
                rect.size.height);
   nvgFillPaint( vg, imgPaint);
   nvgFill( vg);
}


static BOOL   drawStuff( CALayer *layer, CGContext *context)
{
   CGDrawableOptions   options;
   CGRect              canvas;
   CGRect              rects[ ROWS][ COLUMNS];
   CGImage             *image;
   struct NVGcontext   *vg;
   CGRect              area;
   NSInteger           x, y;

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
                                      bitmapSize:MulleIntegerSizeMake( IW, IH)
                                    textureFlags:0  // NVG_IMAGE_REPEATX
                                         context:context] autorelease];
   assert( image);


   canvas    = CGRectInset( canvas, 4, 4);

   // get a rectangle inside canvas thats centered and as large as possible
   area.size = CGSizeAspectFillToSize( CGSizeMake( 1, 1), canvas.size);
   area      = CGSizePlaceInRect( area.size, canvas, CGContentModeCenterPoint);

   // subdivide into 1010
   CGRectPartitionIntoRowsAndColumns( area, CGSizeMake( 4, 4), 10, 10, (CGRect *) rects);


   // row#
   for( y = 0; y < 10; y++)
      for( x = 0; x < 10; x++)
      {
         drawShifted( vg, image, rects[ y][ x], y, x);
         // drawTransformed( vg, image, rects[ y][ x], y, x);
         // drawRotated( vg, image, rects[ y][ x], y, x);
         //drawUnscaled( vg, image, rects[ y][ x], y, x);
      }

   return( YES);
}


void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame  = [[window contentPlane] contentRect];
   view   = [UIView viewWithFrame:frame];
   [[window contentPlane] setDrawCallback:(CALayerDrawCallback_t *) drawStuff];
   [[window contentPlane] addSubview:view];
}


int   main( int argc, char *argv[])
{
   UIWindow         *window;
   UIApplication    *app;

   app = [UIApplication sharedInstance];
   @autoreleasepool
   {
      window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 800, 800)
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



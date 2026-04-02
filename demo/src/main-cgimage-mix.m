#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>
#include <time.h>


// MEMO: this demo used to work at some time, currently in bad state
//       also not sure what it was supposed to show really

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
#define SPACING  4

static void  drawRotated( CGContext *context, CGImage *image, CGRect rect, NSInteger y, NSInteger x)
{
   // Delete: Remove CGImagePaint variable
   // CGImagePaint   *imgPaint = [[[CGImagePaint alloc] initWithImage:image] autorelease];

   CAPolarPoint      centerPolarPoint;
   CAPolarPoint      rotatedPolarPoint;
   CGPoint           relativePoint;
   CGPoint           rotatedPoint;
   // texture is at 0.0, we calc the "scaled" texture point
   CAAngle           angle;
   CGDrawableOptions options; // Add: Declare CGDrawableOptions
   CGFloat           scale;
   CGPoint           centerPoint;
   CGPoint           diffPoint;
   CGRect            imageRect;

   angle             = CADegreesToAngle( y * 36 + x * 36.0 / COLUMNS);
   scale             = 4.0;

   // calculate position independent the amout of rotation for the
   // center point
   centerPoint       = CGPointMake( rect.size.width / 2.0 / scale,
                                    rect.size.height / 2.0 / scale);
   centerPolarPoint  = CAPolarPointMakeWithPoint( centerPoint);
   rotatedPolarPoint = CAPolarPointAddRadians( centerPolarPoint, CAAngleToRadians( angle));
   rotatedPoint      = CGPointMakeWithPolarPoint( rotatedPolarPoint);
   diffPoint         = CGPointMake( (rotatedPoint.x - centerPoint.x),
                                    (rotatedPoint.y - centerPoint.y));
   diffPoint.x      -= rect.size.width / scale;
   diffPoint.y      -= rect.size.height / scale;

//   fprintf( stderr, "%.2f : %s -> %s -> %s\n",
//                        angle,
//                        CGPointUTF8String( centerPoint),
//                        CGPointUTF8String( diffPoint),
//                        CGPointUTF8String( rotatedPoint));

   // Update: Construct CGDrawableOptions and call drawRect:options:context:
   options = CGDrawableOptionsMakeWithCornerRadius( 0.0, // cornerRadius
                                                    1.0, // alpha
                                                    angle, // rotation
                                                    CGScaleNone, // scale (use CGScaleNone as we are setting size explicitly)
                                                    CGFlipNone, // flip
                                                    CGRepeatNone, // repeat
                                                    CGContentModeCenterPoint); // contentMode

   // The drawRect:options:context: method handles the drawing with the specified options
   imageRect = CGRectMake( rect.origin.x - diffPoint.x,
                           rect.origin.y - diffPoint.y,
                           rect.size.width / scale,
                           rect.size.height / scale);
   [image drawRect:imageRect
           options:&options
           context:context];
}



static void  drawUnscaled( CGContext *context, CGImage *image, CGRect rect, NSInteger y, NSInteger x)
{
   // Delete: Remove CGImagePaint variable
   // CGImagePaint   *imgPaint = [[[CGImagePaint alloc] initWithImage:image] autorelease];
   CGPoint             centerPoint;
   CGPoint             diffPoint;
   CGSize              size;
   CGSize              step;
   CGDrawableOptions   options; // Add: Declare CGDrawableOptions
   CGRect              imageRect;


   diffPoint = CGPointMake( x, y);
   size      = [image size];

   // center texture

   centerPoint    = CGRectGetCenter( rect);
   centerPoint.x -= (rect.size.width - size.width) / 2.0;
   centerPoint.y -= (rect.size.height - size.height) / 2.0;

   step    = CGSizeMake( rect.size.width / COLUMNS, rect.size.height / ROWS);

   // Update: Construct CGDrawableOptions and call drawRect:options:context:
   options = CGDrawableOptionsMakeWithCornerRadius( 0.0, // cornerRadius
                                                    1.0, // alpha
                                                    CGRotationNone, // rotation
                                                    CGScaleNone, // scale (use CGScaleNone as we are setting size explicitly)
                                                    CGFlipNone, // flip
                                                    CGRepeatNone, // repeat
                                                    CGContentModeCenterPoint); // contentMode

   imageRect = CGRectMake( rect.origin.x - (COLUMNS / 2 - x) * step.width,
                           rect.origin.y - (ROWS / 2 - y) * step.height,
                           size.width * 4,
                           size.height * 4);
   [image drawRect:imageRect
           options:&options
           context:context];
}


static void  drawShifted( CGContext *context, CGImage *image, CGRect rect, NSInteger y, NSInteger x)
{
   // Delete: Remove CGImagePaint variable
   // CGImagePaint   *imgPaint = [[[CGImagePaint alloc] initWithImage:image] autorelease];
   CGSize              size;
   CGPoint             point;
   CGPoint             final;
   CGSize              scale;
   CGRect              imageRect;
   CGDrawableOptions   options; // Add: Declare CGDrawableOptions


   scale = CGSizeMake( 0.5, 0.5);

   size  = CGSizeMake( rect.size.width * scale.width / IW, rect.size.height * scale.height / IH);

   point = CGPointMake( (COLUMNS / 2 - x) * size.width,
                        (ROWS / 2 - y) * size.height);
   final = CGPointAdd( rect.origin, point);

//   fprintf( stderr, "[x=%td/y=%td] %s : s=%s -> p=%s -> f=%s\n",
//                        x, y,
//                        CGPointUTF8String( rect.origin),
//                        CGSizeUTF8String( size),
//                        CGPointUTF8String( point),
//                        CGPointUTF8String( final));

   // Update: Construct CGDrawableOptions and call drawRect:options:context:
   options = CGDrawableOptionsMakeWithCornerRadius( 0.0, // cornerRadius
                                                    1.0, // alpha
                                                    CGRotationNone, // rotation
                                                    CGScaleNone, // scale (use CGScaleNone as we are setting size explicitly)
                                                    CGFlipNone, // flip
                                                    CGRepeatNone, // repeat
                                                    CGContentModeCenterPoint); // contentMode
   imageRect = CGRectMake( final.x,
                           final.y,
                           rect.size.width / scale.width,
                           rect.size.height / scale.height);
   [image drawRect:imageRect
           options:&options
           context:context];
}


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGDrawableOptions   options;
   CGRect              canvas;
   CGRect              rects[ ROWS][ COLUMNS];
   CGImage             *image;
   CGRect              area;
   NSInteger           x, y;
   NSInteger           onOff;

   canvas = [layer canvas];


   // if we immediately reclaim the image (via release) after drawing it
   // is too early, and the texture is gone too soon
   image   = [[[CGImage alloc] initWithRGBABytes:bitmap
                                      bitmapSize:CGPixelSizeMake( IW, IH)
                                    textureFlags:0  // CGImageFlagRepeatX
                                         context:context] autorelease];
   assert( image);


   canvas    = CGRectInset( canvas, SPACING, SPACING);

   // get a square inside canvas that is centered and as large as possible
   area.size = CGSizeAspectFillToSize( CGSizeMake( 1, 1), canvas.size);
   area      = CGSizePlaceInRect( area.size, canvas, CGContentModeCenterPoint);

   // subdivide into 10x10
   CGRectPartitionIntoRowsAndColumns( area, CGSizeMake( SPACING, SPACING), ROWS, COLUMNS, (CGRect *) rects);

   // draw some kind of grid
   for( y = 0; y < ROWS; y++)
      for( x = 0; x < COLUMNS; x++)
         CGContextFillRectWithColor( context, rects[ y][ x], CGColorMakeWhite());


   // row#
   for( y = 0; y < ROWS; y++)
   {
      onOff = y & 0x1;
      for( x = 0; x < COLUMNS; x++)
      {
         onOff = ! onOff;
         if( onOff)
         {
         // drawShifted( context, image, rects[ y][ x], y, x);
         // drawTransformed( context, image, rects[ y][ x], y, x);
         // drawRotated( context, image, rects[ y][ x], y, x);
            drawUnscaled( context, image, rects[ y][ x], y, x);
         }
      }
   }

   // draw area just for fun or in case of bugs and nothing gets drawn by
   // above code
   CGContextStrokeRectWithColor( context, area, 1, CGColorMakeRed());

   return( YES);
}


void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame  = [[window contentView] contentRect];
   view   = [UIView viewWithFrame:frame];
   [[window contentView] setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];
   [[window contentView] addSubview:view];
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
// ║⌐        █⌐'║▄ Γr2«    ║▀                 ▄▄▄      ╙███` `╙╙║█  ▐H        █
// █]     ,▄▐H  ██████═ª  ╓` ▄█▀▀▀▀█▄        ████     ╓███` `╙╙║█  ▐H        █
// █ "% ,▄▀ ║░╠K█═╣███^   ╛╓█▀      ▐█         ,╓╓═ª╙└   █      ╙█▄▐▌▓######▌╫
// █"      ╙▐H-═M ▄███████¥█H "^╙    '█, ,«^``     `     ║▌        ▐M▄▀    "Φ█
// ║        !█▄▄████≤═^`╓█ █▌╓▀╦▄▀█   ╙█⌐               ╓█▌        ▓ `       █
//  ▌      ,▄██╫██ ▄█═╜" █▌▐█╣Hj⌐ █    █▌╙¥w,           ██▄       ╓▌        ▐M
//  ╢"▄▄#▀▀╙╟█Ü███▀`▀█  ╠██████j▌║█▌   ▀██▄       `╙▓██▀w,     ╙╗█'`"▀█▀╙"`║`
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

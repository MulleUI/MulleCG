#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>
#include <time.h>


CGAffineTransform   CGRectReverseImageMapperTransform( CGRect rect,
                                                       CGFloat angle,
                                                       CGSize extent,
                                                       CGSize imageSize);


CGPoint  CGRectGetOriginToTexturePointForAngleAndExtent( CGRect rect,
                                                         CGPoint texturePoint,
                                                         CAAngleRadians angle,
                                                         CGSize extent);

void  CGBitmapDrawableDrawRect( id <CGBitmapDrawable> self,
                                CGRect rect,
                                CGPoint origin,
                                CGSize extent,
                                CGDrawableOptions *options,
                                CGContext *context);

@implementation CGImage ( Hacky)

- (void) drawRect:(CGRect) rect
         fromRect:(CGRect) fromRect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context
{
   NSInteger           imageID;
   NSInteger           imageFlags;
   NVGcontext          *vg;
   NVGpaint            imgPaint;
   CGSize              imageSize;
   CGPoint             origin;
   CGSize              size;
   CGSize              extent;
   CGRect              tmp;
   CGRect              sectionRect;
   CGPoint             sectionOrigin;
   CGImage             *image;
   CGAffineTransform   xform;
   CGPoint             texturePoint;

   if( ! options)
      options = &CGDrawableOptionsDefault;

   fprintf( stderr, "rect=%s fromRect=%s\n",
         CGRectUTF8String( rect), 
         CGRectUTF8String( fromRect));


   xform       = CGRectReverseImageMapperTransform( rect, options->rotation, rect.size, [self size]);
   // if fromRect is { CGPointZero, [self size] }, then sectionRect should be
   // exactly rect, otherwise we get a subsection of rect
   sectionRect = CGRectApplyAffineTransform( fromRect, xform);
   fprintf( stderr, "sectionRect     : %s\n", CGRectUTF8String( sectionRect));

//
//  +----------+
//  |          |  
//  |  +       |
//  |          |
//  |          | 
//  +----------+
//
   // reduce extent to fromRect.size
   extent.width  = rect.size.width  * (rect.size.width / sectionRect.size.width);
   extent.height = rect.size.height * (rect.size.height / sectionRect.size.height);
   fprintf( stderr, "extent          : %s\n", CGSizeUTF8String( extent));

   assert( options->scale == CGScaleToFit);
   assert( options->flags.repeat      == CGRepeatNone);
   assert( options->flags.contentMode == CGContentModeCenterPoint);

   // get fromOrigin texture coordinate
   texturePoint.x = (CGRectGetMidX( sectionRect) - rect.origin.x) / rect.size.width;
   texturePoint.y = (CGRectGetMidY( sectionRect) - rect.origin.y) / rect.size.height;

   fprintf( stderr, "texturePoint    : %s\n", CGPointUTF8String( texturePoint));
   origin = CGRectGetOriginToTexturePointForAngleAndExtent( rect, texturePoint, options->rotation, extent);

   // punkt: 

   fprintf( stderr, "origin          : %s\n", CGPointUTF8String( origin));

   CGBitmapDrawableDrawRect( self, rect, origin, extent, options, context);
}

@end 


#define R   0xFF, 0x00, 0x00, 0xFF
#define G   0x00, 0xFF, 0x00, 0xFF
#define B   0x00, 0x00, 0xFF, 0xFF
#define Y   0xFF, 0xFF, 0x00, 0xFF
#define W   0xFF, 0xFF, 0xFF, 0xFF
#define _   0x00, 0x00, 0x00, 0xFF


static unsigned char    bitmap2[ 4 * 32 * 32] =
{
   W, _, W, _,  W, _, W, _,  W, _, W, _,  W, _, W, _,  W, _, W, _,  W, _, W, _,  W, _, W, _,  W, _, W, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  B, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, G,  G, G, G, G,  G, G, G, W,

   W, B, B, B,  B, B, B, B,  B, R, R, R,  W, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, G,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  _, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  B, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  G, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, _, _,  _, _, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, _, _,  _, _, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, _, _,  _, _, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, _, _,  _, _, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,

   W, B, B, B,  B, B, B, B,  R, R, R, R,  _, _, _, _,  _, _, _, _,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, _, _, _,  _, _, _, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, _, _,  _, _, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, _,  _, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  G, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  B, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  _, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  B, R, R, R,  W, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, G,  G, G, G, G,  G, G, G, W,

   W, B, B, B,  B, B, B, B,  B, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, G,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, W, _, W,  _, W, _, W,  _, W, _, W,  _, W, _, W,  _, W, _, W,  _, W, _, W,  _, W, _, W,  _, W, _, W
};


#define ROWS    3
#define COLUMNS 4

static void   drawStuff( CALayer *layer, CGContext *context)
{
   CGDrawableOptions   options;
   CGRect              canvas;
   CGRect              rects[ ROWS][ COLUMNS];
   CGRect              sections[ 3][ 3];
   CGImage             *image;
   struct NVGcontext   *vg;
   CGRect              area;
   NSUInteger          x, y;

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
   image   = [[[CGImage alloc] initWithRGBABytes:bitmap2
                                      bitmapSize:CGBitmapSizeMake( 32, 32)
                                      imageFlags:0  // NVG_IMAGE_REPEATX
                                         context:context] autorelease];
   assert( image);


   canvas    = CGRectInset( canvas, 4, 4);

   CGRectPartitionIntoRowsAndColumns( canvas, CGSizeMake( 4, 4), ROWS, COLUMNS, (CGRect *) rects);

   CGRectPartitionIntoRowsAndColumns( CGRectMake( 0, 0, 32, 32), CGSizeMake( 0, 0), 3, 3, (CGRect *) sections);


   options = CGDrawableOptionsMake( 1.0,
                                    0.0,
                                    CGRotationNone,
                                    CGScaleToFit,
                                    CGFlipNone,
                                    CGRepeatNone,
                                    CGContentModeCenterPoint);

   assert( COLUMNS == 4);
   for( y = 0; y < ROWS; y++)
   {
      rects[ y][ 1] = CGRectUnion( rects[ y][ 1], rects[ y][ 2]);
      rects[ y][ 2] = rects[ y][ 3];
   }

   for( y = 0; y < ROWS; y++)
      for( x = 0; x < 3; x++)
         [image drawRect:rects[ y][ x]
                fromRect:sections[ y][ x]
                 options:&options
                 context:context];
}


void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame  = [[window contentPlane] contentRect];
   view   = [UIView viewWithFrame:frame];
   [[window contentPlane] setDrawCallback:drawStuff];
   [[window contentPlane] addSubview:view];
}


int   main( int argc, char *argv[])
{
   UIWindow         *window;
   UIApplication    *app;

   app = [UIApplication sharedInstance];
   @autoreleasepool
   {
      window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 600, 400)
                                titleUTF8String:"Demo"
                                      styleMask:UIWindowStyleMaskDefault & ~UIWindowStyleRetained] autorelease];

      assert( window);
      [window setBackgroundColor:CGColorMakeRGBA( 0.5, 0.5, 0.5, 1.0)];
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



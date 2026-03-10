#define _GNU_SOURCE

#import <MulleUI/MulleUI.h>



// just a stupid demo for me to figure out what nanovg does for open
// and selfintersecting fills

static CGPath   *createSineWavePath( CGRect bounds, BOOL close, BOOL hole)
{
   CGFloat          amplitude;
   CGFloat          frequency;
   CGFloat          height;
   int              i;
   CGPath           *path;
   CGPoint          point;
   CGPoint          startPoint;
   CGFloat          width;
   CGFloat          x;
   CGFloat          y;

   path      = CGPathCreate( NULL);
   width     = CGRectGetWidth( bounds);
   height    = CGRectGetHeight( bounds);
   amplitude = height * 0.3f;
   frequency = 2.0f;

   startPoint = CGPointMake( bounds.origin.x, bounds.origin.y + height/2.0f);
   CGPathMoveToPoint( path, startPoint);

   for( i = 1; i <= 100; i++)
   {
      x     = bounds.origin.x + (width * i / 100.0f);
      y     = bounds.origin.y + height/2.0f + amplitude * sinf( frequency * M_PI_f * i / 100.0f);
      point = CGPointMake( x, y);

      CGPathAddLineToPoint( path, point);
   }

   // Close the path explicitly to create a filled shape
   if( close)
      CGPathCloseSubpath( path);
   CGPathSetSubpathFillStyle( path, hole ? CGPathFillStyleHole : CGPathFillStyleSolid);

   return( path);
}


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
  CGRect              canvas;
  CGRect              rect;
  CGRect              imageRect;
  CGRect              rotatedBbox;
  CGRect              targetRect;
  CGAffineTransform   xform;
  CGPath              *path;
  CGPath              *rotatedPath;
  CGFloat             length;
  CGFloat             rotatedLength;
  CGFloat             fraction;
  CGPoint             center;
  CGPoint             strokePoint;
  CGColor             strokeColor;
  CGColor             fillColor;
  CGPoint             mouseLocation;
  NSUInteger          index;
  CGRect              rects[ 2][ 2];
  NSUInteger          i;
  NSUInteger          j;
  BOOL                clockwise;
  BOOL                solid;
  CGAffineTransform   transformation;
  CARotation          rotation;
  NSUInteger          frameNr;
  NVGcontext          *nvg;

  mulle_fprintf( stderr, "\n\n\n\n>>>>=== DRAWSTUFF %td ===<<<\n", [context numberOfFrames]);
  nvg           = CGContextGetNVGContext( context);
  nvgTrace( nvg, stderr);

  canvas        = [layer canvas];

  CGRectPartition2x2( CGRectInset( canvas, 8, 8), CGSizeMake( 8, 8), rects);
  for( i = 0; i < 2; i++)
  {
      clockwise = ! i;
      for( j = 0; j < 2; j++)
      {
         solid = ! j;
         rect  = rects[ i][ j];
         rect  = CGRectInset( rect, 10, 10);
         path  = createSineWavePath( rect, solid, clockwise);


         frameNr        = [context numberOfFrames] % 240;
         rotation       = (frameNr % 120) / 120.0f ;
         transformation = CGAffineTransformMakeRotationAroundPoint( CGRectGetCenter( rect), rotation);
         rotatedPath    = CGPathByApplyingTransform( path, transformation, NULL);
         rotatedBbox    = CGPathGetBounds( rotatedPath);

         // Apply to your drawing context
         CGContextStrokeRectWithColor( context, rotatedBbox, 0.5f, CGColorMakeRed());

         fillColor = CGColorMakeWithHSB( (i + j * 2) / 4.0, 1.0, 1.0);
         fillColor = CGColorBySettingAlpha( fillColor, 0.5f);

         CGContextBeginPath( context);
         CGContextAddCGPath( context, rotatedPath);
         CGContextFillColor( context, fillColor);
         CGContextFill( context);

         strokeColor = CGColorMakePapaya();
         strokeColor = CGColorBySettingAlpha( strokeColor, 0.5f);

         CGContextStrokeColor( context, strokeColor);
         CGContextStrokeWidth( context, 6.0f);
         CGContextStroke( context);

         CGPathDestroy( rotatedPath);
         CGPathDestroy( path);
      }
   }

  return( YES);
}


int   main( int argc, char *argv[])
{
     UIApplication   *app;
     UIWindow        *window;
     CGSize          imageSize;
     NSUInteger      styleMask;

     app       = [UIApplication sharedInstance];

     styleMask = UIWindowStyleMaskDefault;
     styleMask = UIWindowStyleMaskBySetting( styleMask, UIWindowStylePlanes, NO);
     styleMask = UIWindowStyleMaskBySetting( styleMask, UIWindowStyleRetained, NO);
     window    = [UIWindow windowWithFrame:CGRectMake( 0, 0, 640, 400)
                           titleUTF8String:"Demo"
                                 styleMask:styleMask];

     [window setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];
     [window setBackgroundColor:CGColorMakeWhite()];
     //[window setFrameRateHz:30.0];
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
// █"      ╙▐H-═M ▄███████¥█H "^╙    '█, ,«^``     `     ║▌        ▓ `       █
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

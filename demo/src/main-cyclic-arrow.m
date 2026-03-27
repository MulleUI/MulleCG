#define _GNU_SOURCE

#import "import-private.h"




static void   drawCycleIconInContext( CGContext *context,
                                      CGPoint center,
                                      CGFloat radius,
                                      CGFloat rotation,
                                      CGFloat gap,
                                      CGFloat strokeWidth)
{
   CACircle  arrowInnerCircle;
   CACircle  arrowOuterCircle;
   CACircle  arrowTipCircle;
   CACircle  innerCircle;
   CACircle  outerCircle;
   CGFloat   endAngle;
   CGFloat   startAngle;
   CGPoint   arrowInner;
   CGPoint   arrowOuter;
   CGPoint   arrowTip;
   CGPoint   innerStart;
   CGPoint   outerStart;

   // Apply rotation (0.0 to 1.0 maps to 0 to 2*PI)
   // this part is vibecoded...
   startAngle       = CARotationToAngle( 0.1 + rotation);
   endAngle         = CAAngleRotate( startAngle, 0.75);

   arrowTipCircle   = CACircleMake( center.x, center.y, radius);
   innerCircle      = CACircleInset( arrowTipCircle, gap / 2.0);
   arrowInnerCircle = CACircleInset( innerCircle, gap / 2.0);

   outerCircle      = CACircleExtrude( arrowTipCircle, gap / 2.0);
   arrowOuterCircle = CACircleExtrude( outerCircle, gap / 2.0);

   CGContextStrokeCircleWithColor( context, arrowTipCircle, 1.0, CGColorMakePapaya());
   CGContextStrokeCircleWithColor( context, innerCircle, 1.0, CGColorMakeDodgerBlue());
   CGContextStrokeCircleWithColor( context, outerCircle, 1.0, CGColorMakeBlue());
   CGContextStrokeCircleWithColor( context, arrowInnerCircle, 1.0, CGColorMakeOrange());
   CGContextStrokeCircleWithColor( context, arrowOuterCircle, 1.0, CGColorMakeYellow());

   // Calculate all points using CACircle API
   outerStart = CACirclePointAtAngle( outerCircle,      startAngle);
   innerStart = CACirclePointAtAngle( innerCircle,      endAngle);
   arrowOuter = CACirclePointAtAngle( arrowOuterCircle, endAngle);
   arrowInner = CACirclePointAtAngle( arrowInnerCircle, endAngle);

   // follow the curve
#ifdef FOLLOW_THE_CURVE
   arrowTip   = CACirclePointAtAngle( arrowTipCircle,   CACircleAngleByAddingDistance( arrowTipCircle,
                                                                                       endAngle,
                                                                                       gap,
                                                                                       CARotationDirectionClockWise));
#else
   arrowTip   = CGEdgeMidpointAtDistance( arrowOuter, arrowInner, gap, CARotationDirectionClockWise);
#endif

   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( outerStart, 8),
                                          CGColorMakeBlue());
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( arrowOuter, 8),
                                          CGColorMakeYellow());
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( arrowInner, 8),
                                          CGColorMakeOrange());
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( arrowTip, 8),
                                          CGColorMakePapaya());
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( innerStart, 8),
                                          CGColorMakeDodgerBlue());

   // Draw everything as one path
   CGContextBeginPath( context);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStrokeColor( context, CGColorMakeWithGrayAlpha(0.3, 0.9));

   CGContextMoveTo( context, outerStart);    // Blue

   CGContextArc( context, outerCircle, startAngle, 0.75);

   CGContextLineTo( context, arrowOuter);    // Yellow
   CGContextLineTo( context, arrowTip);      // Papaya
   CGContextLineTo( context, arrowInner);    // Orange
   CGContextLineTo( context, innerStart);    // Orange

   CGContextArc( context, innerCircle, endAngle, -0.75);

   CGContextClosePath( context);

   CGContextStroke(context);
}



static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect         canvas;
   CGRect         rects[ 2][ 2];
   CGRect         rect;
   unsigned int   i, j;

   canvas = [layer canvas];

   CGRectPartition2x2( CGRectInset( canvas, 8, 8), CGSizeMake( 8, 8), rects);
   for( i = 0; i < 2; i++)
   {
      for( j = 0; j < 2; j++)
      {
         rect  = rects[ i][ j];
         rect  = CGRectInset( rect, 10, 10);

         drawCycleIconInContext( context, CGRectGetCenterPoint( rect),
                                          CGRectGetInnerCircle( rect).radius * 0.8,
                                          (i * 2 + j) / 4.0,
                                          32.0,
                                          4.0);
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

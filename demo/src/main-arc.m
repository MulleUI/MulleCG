#define _GNU_SOURCE

#import "import-private.h"


// this demo looks peculiar, but it's just the same as the HTML5 demo...
// see arc-demo.html

static void   drawArc( CGContext *context,
                       CGRect rect,
                       CGColor color)
{
   // insets are flipped, because rect is flipped!
   CGPoint             p0, p1, p2;
   CAPolarPoint        x1, x2;
   CGFloat             r;
   CGFloat             factor;
   NSUInteger          frameNr;

   frameNr = [context numberOfFrames] % 240;
   if( frameNr >= 120)
      factor = 1.0 - (frameNr - 120) / 119.0;
   else
      factor = frameNr / 119.0;

   factor = _CACubicGetValue( ((struct CACubic) { 0.0f, 0.010f, 0.990f, 1.0f }), factor);

   r  = CGRectGetHeight( rect);
   p0 = CGRectGetTop( rect);                                                // RED
   x1 = CAPolarPointMakeWithAngle( r, CADegreesToAngle( 0.0 + 90.0 * factor));           // BLUE
   x2 = CAPolarPointMakeWithAngle( r, CADegreesToAngle( (90.0 + 90.0) - 90.0 * factor));  // LIME

   p1 = CGPointAddPolarPoint( p0, x1);
   p2 = CGPointAddPolarPoint( p0, x2);

   {
      CGContextBeginPath( context);
      CGContextMoveTo( context, p1);
      CGContextArcTo( context, p0, p2, r);
      CGContextStrokeWidth( context, 3.0);
      CGContextStrokeColor( context, CGColorMakeBlack());
      CGContextStroke( context);
#if 1
      CGContextBeginPath( context);
      CGContextMoveTo( context, p1);
      CGContextArcTo( context, p2, p0, r);
      CGContextStrokeWidth( context, 1.0);
      CGContextStrokeColor( context, CGColorMakeIndigo());
      CGContextStroke( context);

      CGContextBeginPath( context);
      CGContextMoveTo( context, p0);
      CGContextArcTo( context, p1, p2, r);
      CGContextStrokeWidth( context, 1.0);
      CGContextStrokeColor( context, CGColorMakeOlive());
      CGContextStroke( context);

      CGContextBeginPath( context);
      CGContextMoveTo( context, p0);
      CGContextArcTo( context, p2, p1, r);
      CGContextStrokeWidth( context, 1.0);
      CGContextStrokeColor( context, CGColorMakeSalmon());
      CGContextStroke( context);

      CGContextBeginPath( context);
      CGContextMoveTo( context, p2);
      CGContextArcTo( context, p0, p1, r);
      CGContextStrokeWidth( context, 2.0);
      CGContextStrokeColor( context, CGColorMakeOrange());
      CGContextStroke( context);

      CGContextBeginPath( context);
      CGContextMoveTo( context, p2);
      CGContextArcTo( context, p1, p0, r);
      CGContextStrokeWidth( context, 2.0);
      CGContextStrokeColor( context, CGColorMakeDodgerBlue());
      CGContextStroke( context);
#endif

      CGContextStrokeLineWithColor( context, p0, p1, 0.5, CGColorMakeBlack());
      CGContextStrokeLineWithColor( context, p0, p2, 0.5, CGColorMakeBlack());

      CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( p0, 5.0), CGColorMakeRed());
      CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( p1, 5.0), CGColorMakeBlue());
      CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( p2, 5.0), CGColorMakeLime());
   }
}


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *_context)
{
   CGContext           *context = _context;
   CGRect              canvas;
   CGRect              rect;

   rect   = CGRectIntegral( [layer canvas]);
   CGContextFillRectWithColor( context, rect, CGColorMake( 1.0, 1.0, 1.0, 1.0));

   canvas = CGSizePlaceInRect( CGSizeMake( 200, 100), [layer canvas], CGContentModeCenterPoint);
   rect   = CGRectIntegral( canvas);
   CGContextStrokeRectWithColor( context, rect, 3.0, CGColorMake( 0.0, 0.0, 0.0, 0.2));

   drawArc( context, rect, CGColorMakeDodgerBlue());

   return( YES);
}


int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 600, 400),
                                           NULL,
                                           60.0f));
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

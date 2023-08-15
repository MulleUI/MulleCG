#define _GNU_SOURCE

#import "import-private.h"


static void   drawArc( CGContext *context,
                       CGRect rect,
                       CGColor color)
{
   // insets are flipped, because rect is flipped!
   CGPoint             p0, p1, p2;
   CAPolarPoint        x0, x1, x2;
   CGFloat             r;
   CGFloat             factor;
   struct NVGcontext   *vg;
   NSUInteger          frameNr;

   vg      = CGContextGetNVGContext( context);
   frameNr = [context numberOfFrames] % 240;
   if( frameNr >= 120)
      factor = 1.0 - (frameNr - 120) / 119.0;
   else
      factor = frameNr / 119.0;

   factor = _CAQuadraticGetValue( ((struct CAQuadratic) { 0.0f, 0.010f, 0.990f, 1.0f }), factor);

   r  = CGRectGetHeight( rect);
   p0 = CGRectGetTopPoint( rect);                                                // RED
   x1 = CAPolarPointMakeWithAngle( r, CADegreesToAngle( 0.0 + 90.0 * factor));           // BLUE
   x2 = CAPolarPointMakeWithAngle( r, CADegreesToAngle( (90.0 + 90.0) - 90.0 * factor));  // LIME

   p1 = CGPointAddPolarPoint( p0, x1);
   p2 = CGPointAddPolarPoint( p0, x2);

   {
      mvgBeginPath( vg);
      mvgMoveTo( vg, p1);
      mvgArcTo( vg, p0, p2, r);
      mvgStrokeWidth( vg, 3.0);
      mvgStrokeColor( vg, CGColorMakeBlack());
      mvgStroke( vg);
#if 0
      mvgBeginPath( vg);
      mvgMoveTo( vg, p1);
      mvgArcTo( vg, p2, p0, r);
      mvgStrokeWidth( vg, 1.0);
      mvgStrokeColor( vg, CGColorMakeIndigo());
      mvgStroke( vg);

      mvgBeginPath( vg);
      mvgMoveTo( vg, p0);
      mvgArcTo( vg, p1, p2, r);
      mvgStrokeWidth( vg, 1.0);
      mvgStrokeColor( vg, CGColorMakeOlive());
      mvgStroke( vg);

      mvgBeginPath( vg);
      mvgMoveTo( vg, p0);
      mvgArcTo( vg, p2, p1, r);
      mvgStrokeWidth( vg, 1.0);
      mvgStrokeColor( vg, CGColorMakeSalmon());
      mvgStroke( vg);

      mvgBeginPath( vg);
      mvgMoveTo( vg, p2);
      mvgArcTo( vg, p0, p1, r);
      mvgStrokeWidth( vg, 2.0);
      mvgStrokeColor( vg, CGColorMakeOrange());
      mvgStroke( vg);

      mvgBeginPath( vg);
      mvgMoveTo( vg, p2);
      mvgArcTo( vg, p1, p0, r);
      mvgStrokeWidth( vg, 2.0);
      mvgStrokeColor( vg, CGColorMakeDodgerBlue());
      mvgStroke( vg);
#endif

      mvgStrokeLineWithColor( vg, p0, p1, 0.5, CGColorMakeBlack());
      mvgStrokeLineWithColor( vg, p0, p2, 0.5, CGColorMakeBlack());

      mvgFillCircleWithColor( vg, CACircleMake( p0, 5.0), CGColorMakeRed());
      mvgFillCircleWithColor( vg, CACircleMake( p1, 5.0), CGColorMakeBlue());
      mvgFillCircleWithColor( vg, CACircleMake( p2, 5.0), CGColorMakeLime());
   }
}


static BOOL   drawStuff( CALayer *layer, void *_context)
{
   CGContext           *context = _context;
   struct NVGcontext   *vg;
   CGRect              canvas;
   CGRect              rect;

   vg     = CGContextGetNVGContext( context);
   canvas = CGSizePlaceInRect( CGSizeMake( 200, 100), [layer canvas], CGContentModeCenterPoint);
   rect   = CGRectIntegral( canvas);
   mvgStrokeRectWithColor( vg, rect, 3.0, CGColorMake( 0.0, 0.0, 0.0, 0.2));

   drawArc( context, rect, CGColorMakeDodgerBlue());

   return( YES);
}



int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CALayerDrawCallback_t *) drawStuff,
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

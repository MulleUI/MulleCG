#define _GNU_SOURCE

#import "import-private.h"


static void   drawArcTo( CGContext *context,
                         CGRect rect,
                         CGContentMode contentMode,
                         CGColor color)
{
   // insets are flipped, because rect is flipped!
   CGPoint             p0, p1, p2;
   CGFloat             r;
   CGFloat             factor;
   struct NVGcontext   *vg;

   vg     = CGContextGetNVGContext( context);

   factor = ([context numberOfFrames] % 120) / 119.0;
   factor = _CAQuadraticGetValue( ((struct CAQuadratic) { 0.0f, 0.010f, 0.990f, 1.0f }), factor);

   mvgSave( vg);
   {
//      mvgIntersectScissor( vg, CGRectExtrude( rect, 2.0, 2.0));

      r  = CGRectGetWidth( rect) / 2;
      p0 = CGRectGetTopLeftPoint( rect);
      p1 = CGRectGetRightPoint( rect);
      p2 = CGRectGetBottomLeftPoint( rect);

      p1.x -= r * factor;
      r    += r * factor * factor;

      switch( contentMode)
      {
      default :
         return;

      case CGContentModeTopLeft :
         // Top Left arc
         r  = CGFloatMinimum( CGRectGetWidth( rect), CGRectGetHeight( rect)) / 2.0;
         p0 = CGRectGetLeftPoint( rect);
         p1 = CGRectGetTopLeftPoint( rect);
         p2 = CGRectGetTopPoint( rect);

         p0.y += r * factor;
         p2.x += r * factor;
         r    += r * factor;
         break;

      case CGContentModeTopRight :
         r  = CGFloatMinimum( CGRectGetWidth( rect), CGRectGetHeight( rect)) / 2.0;
         p0 = CGRectGetRightPoint( rect);
         p1 = CGRectGetTopRightPoint( rect);
         p2 = CGRectGetTopPoint( rect);

         p0.y += r * factor;
         p2.x -= r * factor;
         r    += r * factor;
         break;

      case CGContentModeBottomLeft :
         r  = CGFloatMinimum( CGRectGetWidth( rect), CGRectGetHeight( rect)) / 2.0;
         p0 = CGRectGetLeftPoint( rect);
         p1 = CGRectGetBottomLeftPoint( rect);
         p2 = CGRectGetBottomPoint( rect);

         p0.y -= r * factor;
         p2.x += r * factor;
         r    += r * factor;
         break;

      case CGContentModeBottomRight :
         r  = CGFloatMinimum( CGRectGetWidth( rect), CGRectGetHeight( rect)) / 2.0;
         p0 = CGRectGetRightPoint( rect);
         p1 = CGRectGetBottomRightPoint( rect);
         p2 = CGRectGetBottomPoint( rect);

         p0.y -= r * factor;
         p2.x -= r * factor;
         r    += r * factor;
         break;
      }

      mvgStrokeCircleWithColor( vg, p1, r, 0.5, CGColorMakeOrange());
//      mvgStrokeLineHWithColor( vg, p1, r, 0.5, CGColorMakeRed());

      mvgStrokeLineWithColor( vg, p0, p1, 0.5, CGColorMakeGreen());
      mvgStrokeLineWithColor( vg, p1, p2, 0.5, CGColorMakeBlue());

      nvgBeginPath( vg);

      mvgMoveTo( vg, p0);
      mvgArcTo( vg, p1, p2, r);

      mvgStrokeWidth( vg, 3.0);
      mvgStrokeColor( vg, color);
      mvgStroke( vg);

      mvgFillCircleWithColor( vg, p0, 2.0, CGColorMakeRed());
      mvgFillCircleWithColor( vg, p1, 2.0, CGColorMakeBlue());
      mvgFillCircleWithColor( vg, p2, 2.0, CGColorMakeLime());
   }
   mvgRestore( vg);
}


static BOOL   drawStuff( CALayer *layer, void *_context)
{
   CGContext           *context = _context;
   struct NVGcontext   *vg;
   CGRect              canvas;
   CGRect              rect;
   CGFloat             factor;

   vg     = CGContextGetNVGContext( context);
   canvas = CGSizePlaceInRect( CGSizeMake( 200, 100), [layer canvas], CGContentModeCenterPoint);
   rect   = CGRectIntegral( canvas);
   mvgStrokeRectWithColor( vg, rect, 3.0, CGColorMake( 0.0, 0.0, 0.0, 0.2));

   // the nvgArcTo command is fairly inscrutable
   drawArcTo( context, rect, CGContentModeTopLeft, CGColorMakeDodgerBlue());
   drawArcTo( context, rect, CGContentModeTopRight, CGColorMakeLimeGreen());
   drawArcTo( context, rect, CGContentModeBottomLeft, CGColorMakeSalmon());
   drawArcTo( context, rect, CGContentModeBottomRight, CGColorMakeIndigo());

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

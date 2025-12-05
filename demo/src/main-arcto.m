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

   factor = ([context numberOfFrames] % 120) / 119.0;
   factor = _CACubicGetValue( ((struct CACubic) { 0.0f, 0.010f, 0.990f, 1.0f }), factor);

   CGContextSave( context);
   {
//      CGContextIntersectScissor( context, CGRectExtrude( rect, 2.0, 2.0));

      r  = CGRectGetWidth( rect) / 2;
      p0 = CGRectGetTopLeft( rect);
      p1 = CGRectGetRight( rect);
      p2 = CGRectGetBottomLeft( rect);

      p1.x -= r * factor;
      r    += r * factor * factor;

      switch( contentMode)
      {
      default :
         return;

      case CGContentModeTopLeft :
         // Top Left arc
         r  = CGFloatMinimum( CGRectGetWidth( rect), CGRectGetHeight( rect)) / 2.0;
         p0 = CGRectGetLeft( rect);
         p1 = CGRectGetTopLeft( rect);
         p2 = CGRectGetTop( rect);

         p0.y += r * factor;
         p2.x += r * factor;
         r    += r * factor;
         break;

      case CGContentModeTopRight :
         r  = CGFloatMinimum( CGRectGetWidth( rect), CGRectGetHeight( rect)) / 2.0;
         p0 = CGRectGetRight( rect);
         p1 = CGRectGetTopRight( rect);
         p2 = CGRectGetTop( rect);

         p0.y += r * factor;
         p2.x -= r * factor;
         r    += r * factor;
         break;

      case CGContentModeBottomLeft :
         r  = CGFloatMinimum( CGRectGetWidth( rect), CGRectGetHeight( rect)) / 2.0;
         p0 = CGRectGetLeft( rect);
         p1 = CGRectGetBottomLeft( rect);
         p2 = CGRectGetBottom( rect);

         p0.y -= r * factor;
         p2.x += r * factor;
         r    += r * factor;
         break;

      case CGContentModeBottomRight :
         r  = CGFloatMinimum( CGRectGetWidth( rect), CGRectGetHeight( rect)) / 2.0;
         p0 = CGRectGetRight( rect);
         p1 = CGRectGetBottomRight( rect);
         p2 = CGRectGetBottom( rect);

         p0.y -= r * factor;
         p2.x -= r * factor;
         r    += r * factor;
         break;
      }

      CGContextStrokeCircleWithColor( context, CACircleMakeWithCenterAndRadius( p1, r), 0.5, CGColorMakeOrange());
//      CGContextStrokeLineHWithColor( context, p1, r, 0.5, CGColorMakeRed());

      CGContextStrokeLineWithColor( context, p0, p1, 0.5, CGColorMakeGreen());
      CGContextStrokeLineWithColor( context, p1, p2, 0.5, CGColorMakeBlue());

      CGContextBeginPath( context);

      CGContextMoveTo( context, p0);
      CGContextArcTo( context, p1, p2, r);

      CGContextStrokeWidth( context, 3.0);
      CGContextStrokeColor( context, color);
      CGContextStroke( context);

      CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( p0, 2.0), CGColorMakeRed());
      CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( p1, 2.0), CGColorMakeBlue());
      CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( p2, 2.0), CGColorMakeLime());
   }
   CGContextRestore( context);
}


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *_context)
{
   CGContext           *context = _context;
   CGRect              canvas;
   CGRect              rect;
   CGFloat             factor;

   rect   = CGRectIntegral( [layer canvas]);
   CGContextFillRectWithColor( context, rect, CGColorMake( 1.0, 1.0, 1.0, 1.0));

   canvas = CGSizePlaceInRect( CGSizeMake( 200, 100), [layer canvas], CGContentModeCenterPoint);
   rect   = CGRectIntegral( canvas);
   CGContextStrokeRectWithColor( context, rect, 3.0, CGColorMake( 0.0, 0.0, 0.0, 0.2));

   // the nvgArcTo command is fairly inscrutable
   drawArcTo( context, rect, CGContentModeTopLeft, CGColorMakeDodgerBlue());
   drawArcTo( context, rect, CGContentModeTopRight, CGColorMakeLimeGreen());
   drawArcTo( context, rect, CGContentModeBottomLeft, CGColorMakeSalmon());
   drawArcTo( context, rect, CGContentModeBottomRight, CGColorMakeIndigo());

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
// ║⌐        █⌐'║▄ Γr2«    ║▀                 ▄▄▄      ╙███` `╙╙║█  ▐H        █
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

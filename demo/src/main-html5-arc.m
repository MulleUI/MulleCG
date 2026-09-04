#define _GNU_SOURCE

#import "import-private.h"
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *_context)
{
   CGContext           *context = _context;
   CGFloat             factor;
   NSUInteger          frameNr;
   CGFloat             r;

   frameNr = [context numberOfFrames] % 240;
   if( frameNr >= 120)
      factor = 1.0 - (frameNr - 120) / 119.0;
   else
      factor = frameNr / 119.0;
   factor = _CACubicGetValue( ((struct CACubic) { 0.0f, 0.010f, 0.990f, 1.0f }), factor);

   CGPoint   p0 = { 200, 20  };
   CGPoint   p1 = { 200, 130 };
   CGPoint   p2 = { 50, 0    };

   p2.y += 300 * factor;

   r  = 50;

   CGContextTranslate( context, CGPointMake( 100, 50));

   CGContextBeginPath( context); // Converted from mvgBeginPath
   CGContextStrokeColor( context, CGColorMakeGray()); // Converted from mvgStrokeColor
   CGContextMoveTo( context, p0); // Converted from mvgMoveTo
   CGContextLineTo( context, p1); // Converted from mvgLineTo
   CGContextLineTo( context, p2); // Converted from mvgLineTo
   CGContextStrokeWidth( context, 1.0); // Converted from mvgStrokeWidth
   CGContextStroke( context); // Converted from mvgStroke

// Arc
   CGContextBeginPath( context); // Converted from mvgBeginPath
   CGContextStrokeColor( context, CGColorMakeWhite()); // Converted from mvgStrokeColor
   CGContextMoveTo( context, p0); // Converted from mvgMoveTo
   CGContextArcTo( context, p1, p2, r); // Converted from mvgArcTo
   CGContextStrokeWidth( context, 5.0); // Converted from mvgStrokeWidth
   CGContextStroke( context); // Converted from mvgStroke

   CGContextBeginPath( context); // Converted from mvgBeginPath
   CGContextCircle( context, CACircleMakeWithCenterAndRadius( p0, 5)); // Converted from mvgCircle
   CGContextFillColor( context, CGColorMakeBlue()); // Converted from mvgFillColor
   CGContextFill( context); // Converted from mvgFill

   CGContextBeginPath( context); // Converted from mvgBeginPath
   CGContextCircle( context, CACircleMakeWithCenterAndRadius( p1, 5)); // Converted from mvgCircle
   CGContextFillColor( context, CGColorMakeRed()); // Converted from mvgFillColor
   CGContextFill( context); // Converted from mvgFill

   CGContextBeginPath( context); // Converted from mvgBeginPath
   CGContextCircle( context, CACircleMakeWithCenterAndRadius( p2, 5)); // Converted from mvgCircle
   CGContextFill( context); // Converted from mvgFill

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

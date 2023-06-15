#define _GNU_SOURCE

#import "import-private.h"

#include "draw-flag.inc"


/* To check for leaks uncomment the requestTerminate and run with:
n
   MULLE_OBJC_PEDANTIC_EXIT=YES \
   MULLE_OBJC_EPHEMERAL_SINGLEON=YES \
   MULLE_TESTALLOCATOR=YES \
   MULLE_TESTALLOCATOR_TRACE=3 \
   MULLE_OBJC_TRACE_INSTANCE=YES \
   MULLE_OBJC_TRACE_METHOD_CALL=YES ./kitchen/Debug/draw-simple
 */

CAAngleRadians   directions[ 16];


static void   drawStuff( CALayer *layer, CGContext *context)
{
   struct NVGcontext   *vg;
   CGRect              canvas;
   CGFloat             radius;
   CGPoint             tangentPoints[ 2];
   CGPoint             p1;
   CGPoint             p2;
   CGPoint             tmp;
   unsigned int        i;


   vg     = CGContextGetNVGContext( context);
   canvas = [layer canvas];
   nvgTranslate( vg, canvas.origin.x + canvas.size.width / 2.0,
                     canvas.origin.y + canvas.size.height / 2.0);

   radius = 90.0;
   for( i = 0; i < 15; i++)
   {
      nvgBeginPath( vg);
      nvgArc( vg, 0, 0, radius, directions[ i], directions[ i + 1], NVG_CW);
      nvgStrokeColor( vg, CGColorMakeWithHSLA( 0.1 + 0.9 * i / 15.0, 1.0, 0.5, 1.0));
      nvgStrokeWidth( vg, 4);
      nvgStroke( vg);
   }

   // last segment
   {
      nvgBeginPath( vg);
      nvgArc( vg, 0, 0, radius, directions[ 15], directions[ 0], NVG_CW);
      nvgStrokeColor( vg, CGColorMakeWithHSLA( 0.1 + 0.9 * 15 / 15.0, 1.0, 0.5, 1.0));
      nvgStrokeWidth( vg, 4);
      nvgStroke( vg);
   }

   nvgBeginPath( vg);
   nvgCircle( vg, 0, 0, radius);

   for( i = 0; i < 16; i++)
   {
      tmp = CGPointMakeWithPolarPoint( CAPolarPointMake( radius + 4, directions[ i]));
      nvgMoveTo( vg, tmp.x, tmp.y);
      tmp = CGPointMakeWithPolarPoint( CAPolarPointMake( radius - 4, directions[ i]));
      nvgLineTo( vg, tmp.x, tmp.y);
   }
   nvgStrokeColor( vg, CGColorMakeGray());
   nvgStrokeWidth( vg, 1);
   nvgStroke( vg);

}



int   main( int argc, char *argv[])
{
   auto CAAngleRadians  tmp[ 16] =
   {
      CGWindDirectionNNE,
      CGWindDirectionNE ,
      CGWindDirectionENE,
      CGWindDirectionE  ,
      CGWindDirectionESE,
      CGWindDirectionSE ,
      CGWindDirectionSSE,
      CGWindDirectionS  ,
      CGWindDirectionSSW,
      CGWindDirectionSW ,
      CGWindDirectionWSW,
      CGWindDirectionW  ,
      CGWindDirectionWNW,
      CGWindDirectionNW ,
      CGWindDirectionNNW,
      CGWindDirectionN
   };
   memcpy( directions, tmp, sizeof( directions));
   return( UIApplicationRunDrawCallbackHz( (CALayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 200, 200),
                                           NULL,
                                           0.0f));
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


#define _GNU_SOURCE

#import "import-private.h"

//
// just shows that the pixel center is 0.5
//

static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect              canvas;
   CGRect              rect;
   CGPoint             point;

   canvas = [layer canvas];
   CGContextFillRectWithColor( context, canvas, CGColorMakeBlack());

   // inviso
   CGContextStrokeLineHWithColor( context, CGPointMake( 0 * canvas.size.width / 3, -1.0), canvas.size.width / 3, 2.0, CGColorMakeRed());

   // semiviso
   CGContextStrokeLineHWithColor( context, CGPointMake( 1 * canvas.size.width / 3, -0.0), canvas.size.width / 3, 2.0, CGColorMakeGreen());

   // viso
   CGContextStrokeLineHWithColor( context, CGPointMake( 2 * canvas.size.width / 3, +1.0), canvas.size.width / 3, 2.0, CGColorMakeBlue());

   rect = CGRectInset( canvas, 50, 50);

   CGContextShapeAntiAlias( context, YES);
   point = CGPointMake( rect.origin.x + 0 * (rect.size.width / 4), rect.origin.y);
   CGContextStrokeLineHWithColor( context, point, rect.size.width / 4, 1.0, CGColorMakeWhite());
   point = CGPointMake( rect.origin.x + 1 * (rect.size.width / 4), rect.origin.y + 0.5);
   CGContextStrokeLineHWithColor( context, point, rect.size.width / 4, 1.0, CGColorMakeWhite());

   CGContextShapeAntiAlias( context, NO);
   point = CGPointMake( rect.origin.x + 2 * (rect.size.width / 4), rect.origin.y);
   CGContextStrokeLineHWithColor( context, point, rect.size.width / 4, 1.0, CGColorMakeWhite());
   point = CGPointMake( rect.origin.x + 3 * (rect.size.width / 4), rect.origin.y + 0.5);
   CGContextStrokeLineHWithColor( context, point, rect.size.width / 4, 1.0, CGColorMakeWhite());

   CGContextShapeAntiAlias( context, YES);
   point = CGPointMake( rect.origin.x, rect.origin.y + 0 * (rect.size.height / 4));
   CGContextStrokeLineVWithColor( context, point, rect.size.height / 4, 1.0, CGColorMakeWhite());
   point = CGPointMake( rect.origin.x + 0.5, rect.origin.y + 1 * (rect.size.height / 4));
   CGContextStrokeLineVWithColor( context, point, rect.size.height / 4, 1.0, CGColorMakeWhite());

   CGContextShapeAntiAlias( context, NO);
   point = CGPointMake( rect.origin.x, rect.origin.y + 2 * (rect.size.height / 4));
   CGContextStrokeLineVWithColor( context, point, rect.size.height / 4, 1.0, CGColorMakeWhite());
   point = CGPointMake( rect.origin.x + 0.5, rect.origin.y + 3 * (rect.size.height / 4));
   CGContextStrokeLineVWithColor( context, point, rect.size.height / 4, 1.0, CGColorMakeWhite());

   return( NO);
}


int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 400, 300),
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

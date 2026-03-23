//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>
static void   drawTextOverRect( CGContext *context, CGRect canvas)
{
   CGRect   rect;
   CGRect   textRect;

   rect= CGSizePlaceInRect( CGSizeMake( 200, 80), canvas, CGContentModeCenterPoint);
   CGContextFillRoundedRectWithColor( context, rect, 8.0, CGColorBySettingAlpha( CGColorMakeWhite(), 0.5));

   textRect = CGRectInset( rect, 4.0, 0.0);
   CGContextTextColor( context, CGColorMakeBlack());
   CGContextTextBackgroundColor( context, CGColorMakeGray());
   CGContextTextInRect( context, "VfL Bochum 1848", (size_t) -1, textRect, CGContentModeScaleAspectFit, 0); // CGTextOptionNoClip);
}
static void   drawRectBehindText( CGContext *context, CGRect canvas)
{
   CGRect                    rect;
   CGRect                    nopadRect;
   CGFloat                   fontSize;
   CGRect                    textRect;
   CGRect                    backgroundRect;
   CGFloat                   pad;
   struct CGTextMetrics      metrics;
   struct CGTextBoundsInfo   info;

   // BUG: The visually is needed to "remove" the descender space. What is not
   //      super clear here is, that CGTextAlignTop | CGTextAlignLeft will be
   //      working on descender and ascender lineHeight, which is spitting
   //      in the soup again.
   pad       = 6.0f;
   rect      = CGSizePlaceInRect( CGSizeMake( 200, 80), canvas, CGContentModeCenterPoint);
   nopadRect = CGRectInset( rect, pad, pad);
   info      = CGContextTextBoundsOptions( context, "VfL Bochum 1848", (size_t) -1,
                                                        nopadRect,
                                                        CGContentModeScaleAspectFit,
                                                        CGTextOptionAlignVisually);
   if( info.size == 0.0f)
      return;
   if( ! isnan( info.size))
      CGContextFontSize( context, info.size);

   textRect       = CGSizePlaceInRect( info.bounds.size, rect, CGContentModeCenterPoint);
   backgroundRect = CGRectExtrude( textRect, pad, pad);
   CGContextFillRoundedRectWithColor( context, backgroundRect, 8.0, CGColorBySettingAlpha( CGColorMakeWhite(), 0.5));

   CGContextTextColor( context, CGColorMakeBlack());
   CGContextTextBackgroundColor( context, CGColorMakeGray());

   // For CGTextOptionAlignVisually
   // only BASELINE, LEFT does not do anything
   metrics            = CGContextTextMetrics( context);
   textRect.origin.y += metrics.ascender;
   CGContextCombinedTextAlignment( context, CGTextAlignBaseline | CGTextAlignLeft);
   CGContextText( context, textRect.origin, "VfL Bochum 1848", (size_t) -1);
}
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect   canvas;
   CGRect   rects[ 2][ 2];

   canvas = [layer canvas];

   CGRectPartition2x2( CGRectInset( canvas, 8, 8), CGSizeMake( 8, 8), rects);

   CGContextFillRectWithGradientColors( context, rects[ 0][ 0], CGColorMakePapaya(), CGColorMakeChartreuse(), CAAngleToRotation( CAAngleSouthWest));
   drawRectBehindText( context, rects[ 0][ 0]);

   CGContextFillRectWithGradientColors( context, rects[ 1][ 1], CGColorMakePapaya(), CGColorMakeChartreuse(), CAAngleToRotation( CAAngleNorthEast));
   drawTextOverRect( context, rects[ 1][ 1]);

   return( YES);
}
int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
   NSUInteger      styleMask;

   app = [UIApplication sharedInstance];

   @autoreleasepool
   {
      styleMask = UIWindowStyleMaskDefault;
      styleMask = UIWindowStyleMaskBySetting( styleMask, UIWindowStyleResizable, YES);

      window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 640, 400)
                         titleUTF8String:"Demo"
                               styleMask:styleMask];
      assert( window);
      [window setBackgroundColor:CGColorMakeBlue()];
      [[window contentView] setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];

      [app addWindow:window];
   }
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

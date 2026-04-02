#import "import.h"

#import <string.h>
#define FONT_SIZE   10

//
// Text placement and CGTextOptionAlignVisually
// =============================================
//
// CGContextTextInRect / CGContextFormatInRect place text inside a rect
// using a content mode (TopLeft, BottomRight, Center, ScaleAspectFit, etc.)
// and clip to that rect with a scissor.
//
// Without CGTextOptionAlignVisually, text bounds come from font metrics
// (ascender, descender, line height). These are consistent across strings
// but don't reflect the actual ink. With NVG_ALIGN_TOP, the draw point is
// at the top of the line — but the actual glyph ink can start a few pixels
// below that. The font metrics bounds report origin.y ≈ 0, so the text is
// placed right at the rect edge.
//
// Problem: CGContextTextInRect sets a scissor to the text rect. If the
// glyph ink extends above the draw point (anti-aliasing fringe, or glyphs
// like "0" whose ink starts at the very top of the em square), the scissor
// clips those top pixels. At small font sizes this is very visible — the
// tops of zeros and other tall glyphs get cut off.
//
// With CGTextOptionAlignVisually, text bounds come from the actual rendered
// glyph outlines (CGContextTextVisualBounds). The origin reflects where
// the ink really starts, and CGContextTextInRect compensates by shifting
// the draw point so the ink fits inside the rect. This avoids the clipping.
//
// Rule of thumb: when placing text at edges (TopLeft, BottomRight, etc.)
// and you care about pixel-perfect rendering, use CGTextOptionAlignVisually.
// Without it, you get consistent metric-based placement (good for multi-line
// layout) but risk clipping at rect boundaries.
//

static BOOL   drawStuff( CGGraphicsLayer *self, CGContext *context)
{
   CGRect              rect;
   CGRect              textRect;

   [context useFontWithNameUTF8String:"mono"];
   rect = CGRectMake( 100, 100, FONT_SIZE * 10, FONT_SIZE * 10);
   rect = CGRectIntegral( rect);

   CGContextBeginPath( context);
   CGContextRect( context, rect);
   CGContextFillColor( context, CGColorMakeBlack());
   CGContextFill( context);

   CGContextSave( context); // Converted from mvgSave
   {
      CGContextIntersectScissor( context, rect); // Converted from mvgIntersectScissor

      CGContextTextColor( context, CGColorMakeWhite()); // Converted from mvgTextColor
      CGContextTextBackgroundColor( context,  CGColorMakeBlack()); // Converted from mvgTextBackgroundColor

      textRect = CGRectInset( rect, 4.0, 4.0);
      CGContextFontSize( context, FONT_SIZE);
      CGContextFormatInRect( context, textRect, CGContentModeLeft|CGContentModeTop, CGTextOptionAlignVisually, "%s", CGPointUTF8String( rect.origin));
      CGContextFormatInRect( context, textRect, CGContentModeRight|CGContentModeBottom, CGTextOptionAlignVisually, "%s", CGSizeUTF8String( rect.size));
   }
   CGContextRestore( context); // Converted from mvgRestore
   return( YES);
}

int   main()
{
   UIWindow        *window;
   UIApplication   *app;
   UIView          *view;

   /*
    * window and app
    */
   app = [UIApplication sharedInstance];
   @autoreleasepool
   {
      window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 800.0, 600.0)];
      [window setBackgroundColor:CGColorMakeGray()];

      view  = [window contentView];
      [view setDrawCallback:drawStuff];
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

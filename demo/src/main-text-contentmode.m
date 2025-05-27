//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>


static char  *fontName; // can be null

static char  *nvgHAlignmentUTF8String( int alignment)
{
   switch( alignment & (CGTextAlignLeft | CGTextAlignCenter | CGTextAlignRight)) // Converted from NVG_ALIGN_LEFT | NVG_ALIGN_CENTER | NVG_ALIGN_RIGHT
   {
   case CGTextAlignLeft   : return( "CGTextAlignLeft"); // Converted from NVG_ALIGN_LEFT
   case CGTextAlignCenter : return( "CGTextAlignCenter"); // Converted from NVG_ALIGN_CENTER
   case CGTextAlignRight  : return( "CGTextAlignRight"); // Converted from NVG_ALIGN_RIGHT
   default               : return( "*invalid*");
   }
}


static char  *nvgVAlignmentUTF8String( int alignment)
{
   switch( alignment & (CGTextAlignTop | CGTextAlignMiddle | CGTextAlignBottom | CGTextAlignBaseline)) // Converted from NVG_ALIGN_TOP | NVG_ALIGN_MIDDLE | NVG_ALIGN_BOTTOM | NVG_ALIGN_BASELINE
   {
   case CGTextAlignTop      : return( "CGTextAlignTop"); // Converted from NVG_ALIGN_TOP
   case CGTextAlignMiddle   : return( "CGTextAlignMiddle"); // Converted from NVG_ALIGN_MIDDLE
   case CGTextAlignBottom   : return( "CGTextAlignBottom"); // Converted from NVG_ALIGN_BOTTOM
   case CGTextAlignBaseline : return( "CGTextAlignBaseline"); // Converted from NVG_ALIGN_BASELINE
   default                 : return( "*invalid*");
   }
}


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   // Delete: struct NVGcontext    *vg;
   CGRect               canvas;
   CGRect               rects[ 3][ 3];
   NSUInteger           x, y;
   CGRect               rect;
   char                 *s;
   //float                ascender, descender, lineh;
   char                 buf[ 256];
   float                textBounds[ 4];
   float                visualBounds[ 4];
   float                glyphBounds[ 4];
   float                bounds[ 4];
   CGPoint              origin;
   NVGglyphPosition     positions[ 32];
   int                  i;
   int                  nGlyphs;
   CGPoint              adjust;
   int                  alignment;
   NSUInteger           frameNr;
   CGContentMode        contentMode;

   frameNr   = [context numberOfFrames];
   alignment = CGTextAlignCenter | CGTextAlignMiddle; // Converted from NVG_ALIGN_CENTER | NVG_ALIGN_MIDDLE

   // Delete: vg     = CGContextGetNVGContext( context);

   CGContextFontFace( context, fontName);
   CGContextFontSize( context, 32.0); // Converted from nvgFontSize

   canvas = [layer canvas];
   canvas = CGRectInset( canvas, 4, 4);

   CGRectPartition3x3( canvas, CGSizeMake( 4, 4), rects);

   s = "Yay! Yay! Yay! Yay! Yay! Yay! Yay!";

   for( y = 0; y < 3; y++)
   {
      for( x = 0; x < 3; x++)
      {
         rect = rects[ y][ x];
         CGContextStrokeRectWithColor( context, rect, 1.0, CGColorMakeGray()); // Converted from mvgStrokeRectWithColor

         CGContextSave( context); // Converted from nvgSave
         {
            CGContextScissor( context, rect); // Converted from nvgScissor

            rect = CGRectInset( rect, 2, 2);

            CGContextTextAlign( context, alignment); // Converted from nvgTextAlign

            switch( y * 3 + x)
            {
            case 0 : contentMode = CGContentModeTopLeft; break;
            case 1 : contentMode = CGContentModeTop; break;
            case 2 : contentMode = CGContentModeTopRight; break;

            case 3 : contentMode = CGContentModeLeft; break;
            case 4 : contentMode = CGContentModeCenter; break;
            case 5 : contentMode = CGContentModeRight; break;

            case 6 : contentMode = CGContentModeBottomLeft; break;
            case 7 : contentMode = CGContentModeBottom; break;
            case 8 : contentMode = CGContentModeBottomRight; break;
            }

            CGContextTextColor( context, CGColorMakeWithHSVA( (y * 3 + x) / 9.0, 1.0, 1.0, 1.0)); // Converted from nvgTextColor
            CGContextTextBackgroundColor( context, CGColorMakeWhite()); // Converted from nvgTextBackgroundColor
            CGContextTextInRect( context, s, (size_t) -1, rect, contentMode, CGTextOptionAlignVisually); // Converted from mvgTextInRect
         }
         CGContextRestore( context); // Converted from nvgRestore
      }
   }
   return( YES);
}


void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame  = [[window contentView] contentRect];

   view  = [UIView viewWithFrame:frame];
   [view setAutoresizingMask:UIViewAutoresizingScaleToFill];
   [view setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff]; // drawStuff1];
   [[window contentView] addSubview:view];
}


int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
   NSUInteger      styleMask;

   app = [UIApplication sharedInstance];

   if( argc > 1)
      fontName = argv[ 1];

   @autoreleasepool
   {
      styleMask = UIWindowStyleMaskDefault;
      styleMask = UIWindowStyleMaskBySetting( styleMask, UIWindowStyleResizable, YES);
      styleMask = UIWindowStyleMaskBySetting( styleMask, UIWindowStyleRetained, NO);

      window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 1000, 600)
                         titleUTF8String:"Demo"
                               styleMask:styleMask];

      assert( window);
      [window setBackgroundColor:CGColorMakeWhite()];
      setupScene( window);
      [window setFrameRate:UIWindowFrameRateUnsynced];
      [window setFrameDelegate:[MulleUIPerf object]];

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

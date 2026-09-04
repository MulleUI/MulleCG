//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>
static char  *CGHAlignmentUTF8String( int alignment)
{
   switch( alignment & (CGTextAlignLeft | CGTextAlignCenter | CGTextAlignRight)) // Converted from CGTextAlignLeft | CGTextAlignCenter | CGTextAlignRight
   {
   case CGTextAlignLeft   : return( "CGTextAlignLeft"); // Converted from CGTextAlignLeft
   case CGTextAlignCenter : return( "CGTextAlignCenter"); // Converted from CGTextAlignCenter
   case CGTextAlignRight  : return( "CGTextAlignRight"); // Converted from CGTextAlignRight
   default                : return( "*invalid*");
   }
}
static char  *CGVAlignmentUTF8String( int alignment)
{
   switch( alignment & (CGTextAlignTop | CGTextAlignMiddle | CGTextAlignBottom | CGTextAlignBaseline)) // Converted from CGTextAlignTop | CGTextAlignMiddle | CGTextAlignBottom | CGTextAlignBaseline
   {
   case CGTextAlignTop      : return( "CGTextAlignTop"); // Converted from CGTextAlignTop
   case CGTextAlignMiddle   : return( "CGTextAlignMiddle"); // Converted from CGTextAlignMiddle
   case CGTextAlignBottom   : return( "CGTextAlignBottom"); // Converted from CGTextAlignBottom
   case CGTextAlignBaseline : return( "CGTextAlignBaseline"); // Converted from CGTextAlignBaseline
   default                  : return( "*invalid*");
   }
}

#define N_ALIGNMENTS  (sizeof( alignments) / sizeof( alignments[ 0]))
static void   CGContextStrokeGlyphPosition( CGContext *context, struct UIGlyphPosition *position, CGColor color) // Converted from CGContext *context
{
   CGContextBeginPath( context);
   CGContextRect( context, CGRectMake( position->minx,
                                       position->miny,
                                       position->maxx - position->minx,
                                       position->maxy - position->miny));
   CGContextStrokeColor( context, color);
   CGContextStrokeWidth( context, 1.0);
   CGContextStroke( context);
}
static void   strokeBounds( CGContext *context, float bounds[ 4], CGColor color) // Converted from CGContext *context
{
   CGContextBeginPath( context);
   CGContextRect( context, CGRectMake( bounds[0], bounds[1], bounds[2] - bounds[0], bounds[3] - bounds[1]));
   CGContextStrokeColor( context, color);
   CGContextStrokeWidth( context, 1.0);
   CGContextStroke( context);
}
static void  strokeBoundsInRect( CGContext *context, float bounds[ 4], CGRect rect, CGColor color) // Converted from CGContext *context
{
   CGPoint   point;

   point = CGPointMirrorInRectH( CGPointMake( bounds[ 0], 0), rect);
   CGContextStrokeLineVWithColor( context, CGPointMake( bounds[ 0], CGRectGetMinY( rect)), CGRectGetHeight( rect) / 2.0, 1.0, color); // Converted from mvgStrokeLineVWithColor
   CGContextStrokeLineVWithColor( context, CGPointMake( point.x,    CGRectGetMidY( rect)), CGRectGetHeight( rect), 1.0, color); // Converted from mvgStrokeLineVWithColor
   CGContextStrokeLineVWithColor( context, CGPointMake( bounds[ 2], CGRectGetMinY( rect)), CGRectGetHeight( rect) / 2.0, 1.0, color); // Converted from mvgStrokeLineVWithColor

//   point = CGPointMirrorInRectH( CGPointMake( bounds[ 2], 0), rect);
//   CGContextStrokeLineVWithColor( context, bounds[ 2], CGRectGetMinY( rect), CGRectGetMidY( rect), 1.0, color); // Converted from mvgStrokeLineVWithColor
//   CGContextStrokeLineVWithColor( context, point.x, CGRectGetMidY( rect), CGRectGetMaxY( rect), 1.0, color); // Converted from mvgStrokeLineVWithColor

//   CGContextStrokeLineHWithColor( context, CGRectGetMinX( rect), CGRectGetMidX( rect), bounds[ 1], 1.0, color); // Converted from mvgStrokeLineHWithColor
//   CGContextStrokeLineHWithColor( context, CGRectGetMinX( rect), CGRectGetMidX( rect), bounds[ 3], 1.0, color); // Converted from mvgStrokeLineHWithColor
}

static void __attribute__((unused))  strokeBoundsInRect2( CGContext *context, float bounds[ 4], CGRect rect, CGColor color) // Converted from CGContext *context
{
   CGPoint   point;

   point = CGPointMirrorInRectH( CGPointMake( bounds[ 0], 0), rect);
   CGContextStrokeLineVWithColor( context, CGPointMake( bounds[ 0], CGRectGetMaxY( rect)), CGRectGetHeight( rect) / 2.0, 1.0, color); // Converted from mvgStrokeLineVWithColor
   CGContextStrokeLineVWithColor( context, CGPointMake( point.x,    CGRectGetMidY( rect)), CGRectGetHeight( rect), 1.0, color); // Converted from mvgStrokeLineVWithColor
   CGContextStrokeLineVWithColor( context, CGPointMake( bounds[ 2], CGRectGetMaxY( rect)), CGRectGetHeight( rect) / 2.0, 1.0, color); // Converted from mvgStrokeLineVWithColor

//   point = CGPointMirrorInRectH( CGPointMake( bounds[ 2], 0), rect);
//   CGContextStrokeLineVWithColor( context, bounds[ 2], CGRectGetMinY( rect), CGRectGetMidY( rect), 1.0, color); // Converted from mvgStrokeLineVWithColor
//   CGContextStrokeLineVWithColor( context, point.x, CGRectGetMidY( rect), CGRectGetMaxY( rect), 1.0, color); // Converted from mvgStrokeLineVWithColor

//   CGContextStrokeLineHWithColor( context, CGRectGetMinX( rect), CGRectGetMidX( rect), bounds[ 1], 1.0, color); // Converted from mvgStrokeLineHWithColor
//   CGContextStrokeLineHWithColor( context, CGRectGetMinX( rect), CGRectGetMidX( rect), bounds[ 3], 1.0, color); // Converted from mvgStrokeLineHWithColor
}
NSUInteger   alignments[] =
{
   CGTextAlignLeft   | CGTextAlignTop, // Converted from CGTextAlignLeft | CGTextAlignTop
   CGTextAlignCenter | CGTextAlignTop, // Converted from CGTextAlignCenter | CGTextAlignTop
   CGTextAlignRight  | CGTextAlignTop, // Converted from CGTextAlignRight  | CGTextAlignTop

   CGTextAlignLeft   | CGTextAlignMiddle, // Converted from CGTextAlignLeft   | CGTextAlignMiddle
   CGTextAlignCenter | CGTextAlignMiddle, // Converted from CGTextAlignCenter | CGTextAlignMiddle
   CGTextAlignRight  | CGTextAlignMiddle, // Converted from CGTextAlignRight  | CGTextAlignMiddle

   CGTextAlignLeft   | CGTextAlignBottom, // Converted from CGTextAlignLeft   | CGTextAlignBottom
   CGTextAlignCenter | CGTextAlignBottom, // Converted from CGTextAlignCenter | CGTextAlignBottom
   CGTextAlignRight  | CGTextAlignBottom, // Converted from CGTextAlignRight  | CGTextAlignBottom

   CGTextAlignLeft   | CGTextAlignBaseline, // Converted from CGTextAlignLeft   | CGTextAlignBaseline
   CGTextAlignCenter | CGTextAlignBaseline, // Converted from CGTextAlignCenter | CGTextAlignBaseline
   CGTextAlignRight  | CGTextAlignBaseline // Converted from CGTextAlignRight  | CGTextAlignBaseline
};
#define N_ALIGNMENTS  (sizeof( alignments) / sizeof( alignments[ 0]))
static CGPoint   textOriginForAlignment( CGRect  rect, int alignment)
{
   CGPoint  origin;

   switch( alignment & (CGTextAlignLeft | CGTextAlignCenter | CGTextAlignRight)) // Converted from CGTextAlignLeft | CGTextAlignCenter | CGTextAlignRight
   {
   default                : origin.x = CGRectGetMinX( rect); break;
   case CGTextAlignCenter : origin.x = CGRectGetMidX( rect); break; // Converted from CGTextAlignCenter
   case CGTextAlignRight  : origin.x = CGRectGetMaxX( rect); break; // Converted from CGTextAlignRight
   }

   // not sure what to do with baseline
   switch( alignment & (CGTextAlignTop | CGTextAlignMiddle | CGTextAlignBottom | CGTextAlignBaseline)) // Converted from CGTextAlignTop | CGTextAlignMiddle | CGTextAlignBottom | CGTextAlignBaseline
   {
   case CGTextAlignTop    : origin.y = CGRectGetMinY( rect); break; // Converted from CGTextAlignTop
   case CGTextAlignMiddle : origin.y = CGRectGetMidY( rect); break; // Converted from CGTextAlignMiddle
   default                : origin.y = CGRectGetMaxY( rect); break;
   }

   return( origin);
}

#define USE_OLD_CODE
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect               canvas;
   CGRect               rects[ 4];
   NSUInteger           y;
   CGRect               rect;
   char                 *s;
   //float                ascender, descender, lineh;
   char                 buf[ 256];
   float                textBounds[ 4];
   float                visualBounds[ 4];
   CGPoint              origin;
   struct UIGlyphPosition     positions[ 32];
   int                  i;
   int                  nGlyphs;
   CGPoint              adjust;
   int                  alignment;
   NSUInteger           frameNr;

   frameNr   = [context numberOfFrames];
   alignment = alignments[ frameNr % N_ALIGNMENTS];

   [context useFontWithNameUTF8String:"sans"];

   CGContextFontSize( context, 80.0);

   canvas = [layer canvas];
   canvas = CGRectInset( canvas, 20, 20);

   CGRectPartitionVertically( canvas, 20, 4, rects);

   for( y = 0; y < 4; y++)
   {
      switch( y)
      {
      case 0 : s = "VfL Bochum 1848"; break;
      case 1 : s = "Ascend _y_ Descend"; break;
      case 2 : s = "  Space around  "; break;
      case 3 : s = "nox suarv zemnx"; break;
      }

      rect = rects[ y];
      CGContextSave( context);
      {
         CGContextStrokeRectWithColor( context, rect, 1.0, CGColorMakeGray()); // Converted from mvgStrokeRectWithColor

         CGContextFontSize( context, 80.0);
//         CGContextTextColor( context, CGColorMakeWithRGB( 0.5, 0.5, 0.5));
 // TODO: use textColor
//         CGContextText( context, origin, s, (size_t) -1);

         CGContextStrokeLineHWithColor( context, CGRectGetTopLeft( rect), CGRectGetWidth( rect), 1.0, CGColorMakeGray()); // Converted from mvgStrokeLineHWithColor
         CGContextStrokeLineVWithColor( context, CGRectGetTopLeft( rect), CGRectGetHeight( rect), 1.0, CGColorMakeGray()); // Converted from mvgStrokeLineVWithColor

         strokeBoundsInRect( context, textBounds, rect, CGColorMakeWithRGBA( 1, 0, 0, 0.666)); // Updated function call
         strokeBounds( context, visualBounds, CGColorMakeGreen()); // Updated function call

         // to draw little rectangles around each glyph, we need more detailed
         // information (untranslated)
         CGContextFontSize( context, 80.0);
         CGContextTextColor( context, CGColorMakeBlack());
         CGContextTextBackgroundColor( context, CGColorMakeWhite());
 // TODO: use textColor

         origin = textOriginForAlignment( rect, alignment);
         adjust = CGContextTLAdjustmentForVisualBounds( context, s, (size_t) -1, alignment, CGTextOptionAlignVisually); // Converted from _mvgTLAdjustmentForVisualBounds
         CGContextText( context, CGPointMake( origin.x + adjust.x, origin.y + adjust.y), s, (size_t) -1);

         nGlyphs = CGContextTextGlyphPositions( context, CGPointMake( origin.x + adjust.x, origin.y + adjust.y), s, (size_t) -1, positions, 32);
         for( i = 0; i < nGlyphs; i++)
            CGContextStrokeGlyphPosition( context, &positions[ i], CGColorMakeGray()); // Updated function call

         // write info line
         CGContextFontSize( context, 12);
         CGContextCombinedTextAlignment( context, CGTextAlignLeft|CGTextAlignBottom);
         sprintf( buf, "align: %s | %s",
                     CGHAlignmentUTF8String( alignment),
                     CGVAlignmentUTF8String( alignment));
         CGContextTextColor( context, CGColorMakeBlack());
         CGContextTextBackgroundColor( context, CGColorMakeWhite());
 // TODO: use textColor
         CGContextText( context, CGPointMake( CGRectGetMinX( rect) + 2, CGRectGetMaxY( rect) - 2), buf, (size_t) -1);
      }
      CGContextRestore( context);
   }
   return( YES);
}
void   setupScene( UIWindow *window)
{
   UIView        *view;
   CGRect         frame;

   frame  = [[window contentView] contentRect];

   view  = [UIView viewWithFrame:frame];
   [view setAutoresizingMask:UIViewAutoresizingScaleToFill];
   [view setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];
   [[window contentView] addSubview:view];
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
      styleMask = UIWindowStyleMaskBySetting( styleMask, UIWindowStyleRetained, NO);

      window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 1000, 600)
                         titleUTF8String:"Demo"
                               styleMask:styleMask];
      assert( window);
      [window setBackgroundColor:CGColorMakeWithRGBA( 1.0, 1.0, 1.0, 1.0)];
      setupScene( window);
      [window setFrameRate:2.0];

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
// █]     ,▄▐H  ██████═ª  ╓` ▄█▀▀▀▀█▄        ██p$ΦΦ▀▀▀▀▀ΦΦΦR≡≥▄╓ ║▄       ╙j▌` ▄▀╙╗ `╫
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

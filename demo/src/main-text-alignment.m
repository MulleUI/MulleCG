//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>


NSUInteger   alignments[] =
{
   CGTextAlignLeft   | CGTextAlignTop, // Converted from NVG_ALIGN_LEFT | NVG_ALIGN_TOP
   CGTextAlignCenter | CGTextAlignTop, // Converted from NVG_ALIGN_CENTER | NVG_ALIGN_TOP
   CGTextAlignRight  | CGTextAlignTop, // Converted from NVG_ALIGN_RIGHT  | NVG_ALIGN_TOP

   CGTextAlignLeft   | CGTextAlignMiddle, // Converted from NVG_ALIGN_LEFT   | NVG_ALIGN_MIDDLE
   CGTextAlignCenter | CGTextAlignMiddle, // Converted from NVG_ALIGN_CENTER | NVG_ALIGN_MIDDLE
   CGTextAlignRight  | CGTextAlignMiddle, // Converted from NVG_ALIGN_RIGHT  | NVG_ALIGN_MIDDLE

   CGTextAlignLeft   | CGTextAlignBottom, // Converted from NVG_ALIGN_LEFT   | NVG_ALIGN_BOTTOM
   CGTextAlignCenter | CGTextAlignBottom, // Converted from NVG_ALIGN_CENTER | NVG_ALIGN_BOTTOM
   CGTextAlignRight  | CGTextAlignBottom, // Converted from NVG_ALIGN_RIGHT  | NVG_ALIGN_BOTTOM

   CGTextAlignLeft   | CGTextAlignBaseline, // Converted from NVG_ALIGN_LEFT   | NVG_ALIGN_BASELINE
   CGTextAlignCenter | CGTextAlignBaseline, // Converted from NVG_ALIGN_CENTER | NVG_ALIGN_BASELINE
   CGTextAlignRight  | CGTextAlignBaseline // Converted from NVG_ALIGN_RIGHT  | NVG_ALIGN_BASELINE
};

#define N_ALIGNMENTS  (sizeof( alignments) / sizeof( alignments[ 0]))


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

static void   nvgStrokeGlyphPosition( CGContext *context, NVGglyphPosition *position, CGColor color) // Converted from NVGcontext *vg
{
   CGContextBeginPath( context); // Converted from nvgBeginPath
   CGContextRect( context, CGRectMake( position->minx, // Converted from nvgRect
                position->miny,
                position->maxx - position->minx,
                position->maxy - position->miny));
   CGContextStrokeColor( context, color); // Converted from nvgStrokeColor
   CGContextStrokeWidth( context, 1.0); // Converted from nvgStrokeWidth
   CGContextStroke( context); // Converted from nvgStroke
}


static void   strokeBounds( CGContext *context, float bounds[ 4], CGColor color) // Converted from NVGcontext *vg
{
   CGContextBeginPath( context); // Converted from nvgBeginPath
   CGContextRect( context, CGRectMake( bounds[0], bounds[1], bounds[2] - bounds[0], bounds[3] - bounds[1])); // Converted from nvgRect
   CGContextStrokeColor( context, color); // Converted from nvgStrokeColor
   CGContextStrokeWidth( context, 1.0); // Converted from nvgStrokeWidth
   CGContextStroke( context); // Converted from nvgStroke
}


static void  strokeBoundsInRect( CGContext *context, float bounds[ 4], CGRect rect, CGColor color) // Converted from NVGcontext *vg
{
   CGPoint   point;
   CGFloat   halfRectHeight = CGRectGetHeight( rect) / 2.0;
   CGFloat   midRectX = CGRectGetMidX( rect); // Assuming this was the intent for width of H lines

   point = CGPointMirrorInRectH( CGPointMake( bounds[ 0], 0), rect);
   CGContextStrokeLineVWithColor( context, CGPointMake( bounds[ 0], CGRectGetMinY( rect)), halfRectHeight, 1.0, color);
   CGContextStrokeLineVWithColor( context, CGPointMake( point.x,    CGRectGetMidY( rect) - halfRectHeight), CGRectGetHeight(rect), 1.0, color); // Corrected Y for full height centered on MidY

   // Corrected calls for CGContextStrokeLineHWithColor
   // Assumes line from (CGRectGetMinX(rect), bounds[1]) with width (midRectX - CGRectGetMinX(rect))
   CGContextStrokeLineHWithColor( context, CGPointMake( CGRectGetMinX( rect), bounds[ 1]), midRectX - CGRectGetMinX(rect), 1.0, color);
   CGContextStrokeLineHWithColor( context, CGPointMake( CGRectGetMinX( rect), bounds[ 3]), midRectX - CGRectGetMinX(rect), 1.0, color);
}

static void  strokeBoundsInRect2( CGContext *context, float bounds[ 4], CGRect rect, CGColor color) // Converted from NVGcontext *vg
{
   CGPoint   point;
   CGFloat   halfRectHeight = CGRectGetHeight( rect) / 2.0;
   CGFloat   midRectX = CGRectGetMidX( rect); // Assuming this was the intent for width of H lines

   point = CGPointMirrorInRectH( CGPointMake( bounds[ 0], 0), rect);
   CGContextStrokeLineVWithColor( context, CGPointMake( bounds[ 0], CGRectGetMaxY( rect) - halfRectHeight), halfRectHeight, 1.0, color); // Corrected Y for V-line starting from bottom
   CGContextStrokeLineVWithColor( context, CGPointMake( point.x,    CGRectGetMidY( rect) - halfRectHeight), CGRectGetHeight(rect), 1.0, color); // Corrected Y for full height centered on MidY

   // Corrected calls for CGContextStrokeLineHWithColor
   CGContextStrokeLineHWithColor( context, CGPointMake( CGRectGetMinX( rect), bounds[ 1]), midRectX - CGRectGetMinX(rect), 1.0, color);
   CGContextStrokeLineHWithColor( context, CGPointMake( CGRectGetMinX( rect), bounds[ 3]), midRectX - CGRectGetMinX(rect), 1.0, color);
}


static CGPoint   textOriginForAlignment( CGRect  rect, int alignment)
{
   CGPoint  origin;

   switch( alignment & (CGTextAlignLeft | CGTextAlignCenter | CGTextAlignRight))
   {
   default               : origin.x = CGRectGetMinX( rect); break;
   case CGTextAlignCenter : origin.x = CGRectGetMidX( rect); break;
   case CGTextAlignRight  : origin.x = CGRectGetMaxX( rect); break;
   }

   // not sure what to do with baseline
   switch( alignment & (CGTextAlignTop | CGTextAlignMiddle | CGTextAlignBottom | CGTextAlignBaseline))
   {
   case CGTextAlignTop    : origin.y = CGRectGetMinY( rect); break;
   case CGTextAlignMiddle : origin.y = CGRectGetMidY( rect); break;
   default               : origin.y = CGRectGetMaxY( rect); break;
   }

   return( origin);
}



#define USE_OLD_CODE


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   // Delete: struct NVGcontext    *vg;
   CGFont               *font;
   CGRect               canvas;
   CGRect               rects[ 9][ N_ALIGNMENTS]; // Corrected array size based on usage
   NSUInteger           x, y;
   CGRect               rect;
   // CGRect               centeredRect; // Unused
   // CGPoint              point; // Unused
   char                 *s;
   // float                ascender, descender, lineh; // Unused
   char                 buf[ 256];
   float                textBoundsArr[ 4];  // Renamed to avoid conflict with CGRect
   float                visualBoundsArr[ 4]; // Renamed to avoid conflict with CGRect
   float                glyphBounds[ 4];
   // float                bounds[ 4]; // Unused
   CGPoint              origin;
   struct UIGlyphPosition  positions[ 32];
   int                  i;
   int                  nGlyphs;
// #ifdef USE_OLD_CODE // This block is empty or contains unused variables
//    CGPoint              offset; // Unused
// #endif
   // CGPoint              adjust; // Unused
   int                  currentAlignment; // Renamed from alignment to avoid confusion
   NSUInteger           frameNr;
   char                 *text; // Added declaration for text

   frameNr   = [context numberOfFrames];
   currentAlignment = alignments[ frameNr % N_ALIGNMENTS]; // Uses local currentAlignment

   // Delete: vg     = CGContextGetNVGContext( context);
   font   = [context fontWithNameUTF8String:"sans"]; // Sets font in context

   CGContextFontSize( context, 32.0); // Converted from nvgFontSize

   canvas = [layer canvas];
   canvas = CGRectInset( canvas, 4, 4);

   CGRectPartitionIntoRowsAndColumns( canvas, CGSizeMake( 4, 4), 9, N_ALIGNMENTS, (CGRect *) rects);

   text = "Yay! Yay! Yay! Yay! Yay! Yay! Yay!";

   for( y = 0; y < 9; y++)
   {
      for( x = 0; x < N_ALIGNMENTS; x++)
      {
         memcpy( buf, &text[ x + y], 4);
         buf[ 4] = 0;
         s       = buf;

         rect = rects[ y][ x];
         CGContextStrokeRectWithColor( context, rect, 1.0, CGColorMakeGray()); // Converted from mvgStrokeRectWithColor

         CGContextSave( context); // Converted from nvgSave
         {
            CGContextScissor( context, rect); // Converted from nvgScissor

            rect = CGRectInset( rect, 2, 2);

            CGContextTextAlign( context, alignments[ x]); // Converted from nvgTextAlign

            switch( y)
            {
            case 0 : origin = CGPointMake( CGRectGetMinX( rect), CGRectGetMinY( rect)); break;
            case 1 : origin = CGPointMake( CGRectGetMidX( rect), CGRectGetMinY( rect)); break;
            case 2 : origin = CGPointMake( CGRectGetMaxX( rect), CGRectGetMinY( rect)); break;
            case 3 : origin = CGPointMake( CGRectGetMinX( rect), CGRectGetMidY( rect)); break;
            case 4 : origin = CGPointMake( CGRectGetMidX( rect), CGRectGetMidY( rect)); break;
            case 5 : origin = CGPointMake( CGRectGetMaxX( rect), CGRectGetMidY( rect)); break;
            case 6 : origin = CGPointMake( CGRectGetMinX( rect), CGRectGetMaxY( rect)); break;
            case 7 : origin = CGPointMake( CGRectGetMidX( rect), CGRectGetMaxY( rect)); break;
            case 8 : origin = CGPointMake( CGRectGetMaxX( rect), CGRectGetMaxY( rect)); break;
            default: origin = CGPointZero; break; // Should not happen
            }

            CGRect tempRectForTextBounds;
            CGContextGetTextBounds( context, origin, s, (size_t) -1, &tempRectForTextBounds);
            textBoundsArr[0] = tempRectForTextBounds.origin.x;
            textBoundsArr[1] = tempRectForTextBounds.origin.y;
            textBoundsArr[2] = tempRectForTextBounds.origin.x + tempRectForTextBounds.size.width;
            textBoundsArr[3] = tempRectForTextBounds.origin.y + tempRectForTextBounds.size.height;

            CGContextBeginPath( context); // Converted from nvgBeginPath
            CGContextRect( context, CGRectMake( textBoundsArr[0], textBoundsArr[1], textBoundsArr[2] - textBoundsArr[0], textBoundsArr[3] - textBoundsArr[1])); // Converted from nvgRect
            CGContextStrokeColor( context, CGColorMakeWithRGBA( 1, 0, 0, 0.333)); // Converted from nvgStrokeColor
            CGContextStrokeWidth( context, 1.0); // Converted from nvgStrokeWidth
            CGContextStroke( context); // Converted from nvgStroke

            CGRect tempRectForVisualBounds;

            tempRectForVisualBounds = CGContextTextVisualBounds( context, origin, s, (size_t) -1);
            visualBoundsArr[0] = tempRectForVisualBounds.origin.x;
            visualBoundsArr[1] = tempRectForVisualBounds.origin.y;
            visualBoundsArr[2] = tempRectForVisualBounds.origin.x + tempRectForVisualBounds.size.width;
            visualBoundsArr[3] = tempRectForVisualBounds.origin.y + tempRectForVisualBounds.size.height;

            CGContextBeginPath( context); // Converted from nvgBeginPath
            CGContextRect( context, CGRectMake( visualBoundsArr[0], visualBoundsArr[1], visualBoundsArr[2] - visualBoundsArr[0], visualBoundsArr[3] - visualBoundsArr[1])); // Converted from nvgRect
            CGContextStrokeColor( context, CGColorMakeWithRGBA( 0, 1, 0, 0.333)); // Converted from nvgStrokeColor
            CGContextStrokeWidth( context, 1.0); // Converted from nvgStrokeWidth
            CGContextStroke( context); // Converted from nvgStroke

            nGlyphs = CGContextTextGlyphPositions( context, origin, s, (size_t) -1, positions, 32); // Converted from nvgTextGlyphPositions
            if( nGlyphs)
            {
               glyphBounds[ 0] = positions[ 0].minx;
               glyphBounds[ 1] = positions[ 0].miny;
               glyphBounds[ 2] = positions[ 0].maxx;
               glyphBounds[ 3] = positions[ 0].maxy;
            }
            else // Initialize glyphBounds if no glyphs, to avoid using uninitialized values
            {
                glyphBounds[0] = glyphBounds[1] = glyphBounds[2] = glyphBounds[3] = 0.0f;
            }

            for( i = 1; i < nGlyphs; i++)
            {
               glyphBounds[ 0] = positions[ i].minx < glyphBounds[ 0] ? positions[ i].minx : glyphBounds[ 0]; // Also update minx
               glyphBounds[ 1] = positions[ i].miny < glyphBounds[ 1] ? positions[ i].miny : glyphBounds[ 1];
               glyphBounds[ 2] = positions[ i].maxx > glyphBounds[ 2] ? positions[ i].maxx : glyphBounds[ 2]; // Also update maxx based on >
               glyphBounds[ 3] = positions[ i].maxy > glyphBounds[ 3] ? positions[ i].maxy : glyphBounds[ 3];
            }
            CGContextBeginPath( context); // Converted from nvgBeginPath
            CGContextRect( context, CGRectMake( glyphBounds[0], glyphBounds[1], glyphBounds[2] - glyphBounds[0], glyphBounds[3] - glyphBounds[1])); // Converted from nvgRect
            CGContextStrokeColor( context, CGColorMakeWithRGBA( 0, 0, 1, 0.333)); // Converted from nvgStrokeColor
            CGContextStrokeWidth( context, 1.0); // Converted from nvgStrokeWidth
            CGContextStroke( context); // Converted from nvgStroke

            CGContextTextColor( context, CGColorMakeWithHSVA( x / (CGFloat) N_ALIGNMENTS, 1.0, 1.0, 1.0)); // Converted from nvgTextColor
            CGContextTextBackgroundColor( context, CGColorMakeWhite()); // Converted from nvgTextBackgroundColor
            CGContextText( context, origin, s, (size_t) -1); // Converted from nvgText
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

      [app addWindow:window];
   }

   return( [app runApp]);
}


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
// ║        !█▄▄████≤═^`╓█ █▌▐█╣Hj⌐ █    █▌╙¥w,           ██▄       ╓▌        ▐M
//  ▌      ,▄██╫██ ▄█═╜" █▌▐█╣Hj⌐ █    ██    ╙▀W▄;    ,██  `╙w,   █▄     ,╓ █
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

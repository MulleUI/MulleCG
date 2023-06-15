#ifndef millivg_h__
#define millivg_h__

#include "include.h"

#include <stdint.h>

// almost all nanovg functions are wrapped here for use with mulle-gfx
// geometry. Some functions with pointer parameter return values are changed
// to return structs now..

#include "millivg-nanowrap.h"

enum MulleTextOption
{
   MVGTextDefault       = 0x0,
   MVGTextAlignVisually = 0x1,
   MVGTextAlignBaseline = 0x2,
   MVGTextNoClip        = 0x4,
   MVGTextFill          = 0x8
};

typedef uintptr_t     MulleTextOptions;

// #define RENDER_DEBUG


struct MulleTextMetrics
{
   CGFloat   ascender;
   CGFloat   descender;
   CGFloat   lineHeight;
};


static inline struct MulleTextMetrics
    MulleTextMetricsMake( CGFloat ascender, CGFloat descender, CGFloat lineHeight)
{
   return( (struct MulleTextMetrics) { .ascender = ascender,
                                       .descender = descender,
                                       .lineHeight = lineHeight});
}



// Returns the vertical metrics based on the current text style.
// Measured values are returned in local coordinate space.
static inline struct MulleTextMetrics   mvgTextMetrics( NVGcontext *vg)
{
   float   ascender;
   float   descender;
   float   lineh;

   ascender = descender = lineh = NAN;
   nvgTextMetrics( vg, &ascender, &descender, &lineh);
   return( MulleTextMetricsMake( ascender, descender, lineh));
}


struct MulleCornerInsets
{
   float   tl;
   float   tr;
   float   br;
   float   bl;
};

#define MulleCornerInsetsData( tl, tr, br, bl)  { (tl), (tr), (br), (bl) }



static inline struct MulleCornerInsets
   MulleCornerInsetsMakeLRTD( float topLeft, float topRight, float bottomLeft, float bottomRight)
{
   return( (struct MulleCornerInsets) { .tl = topLeft, .tr = topRight, .br = bottomRight, .bl = bottomLeft });
}


static inline struct MulleCornerInsets
   MulleCornerInsetsMake( float topLeft, float topRight, float bottomRight, float bottomLeft)
{
   return( (struct MulleCornerInsets) { .tl = topLeft, .tr = topRight, .br = bottomRight, .bl = bottomLeft });
}


static inline void   mvgRoundedRectVarying( NVGcontext *vg, CGRect rect, struct MulleCornerInsets corners)
{
   nvgRoundedRectVarying( vg, rect.origin.x,
                              rect.origin.y,
                              rect.size.width,
                              rect.size.height,
                              corners.tl,
                              corners.tr,
                              corners.br,
                              corners.bl);
}


/*
 * Conveniences
 */

// Creates a new rectangle path and fills it with the given color.
void   mvgFillRoundedRect( NVGcontext *vg, CGRect rect, CGFloat cornerRadius, CGColor color);

void   mvgPaintRoundedRect( NVGcontext *vg, CGRect rect, CGFloat cornerRadius, NVGpaint paint);

// Creates a new rectangle path and fills it with the given color.
void   mvgFillRect( NVGcontext *vg, CGRect rect, CGColor color);

void   mvgPaintRect( NVGcontext *vg, CGRect rect, NVGpaint paint);


void   mvgFillCircle( NVGcontext *vg, CGPoint center, CGFloat radius, CGColor color);

void   mvgPaintCircle( NVGcontext *vg, CGPoint center, CGFloat radius, NVGpaint paint);


// Creates a new rectangle path and strokes it with the given color.
void   mvgStrokeRoundedRect( NVGcontext *vg, CGRect rect, CGFloat cornerRadius, CGColor color);

// Creates a new rectangle path and strokes it with the given color.
void   mvgStrokeRect( NVGcontext *vg, CGRect rect, CGColor color);

// Creates a line and strokes it with the color.
void   mvgStrokeLine( NVGcontext *vg, CGPoint start, CGPoint end, CGColor color);

void   mvgStrokeCircle( NVGcontext *vg, CGPoint center, CGFloat radius, CGColor color);



struct MulleShadow
{
   struct MulleEdgeInsets   extrudes;
   CGColor                  innerColor;
   CGColor                  outerColor;
   CGFloat                  blur;
   char                     hole;
};


#define MulleShadowDefaultValues  (struct MulleShadow)                     \
{                                                                          \
   .extrudes   = { .top = 0.5, .left = 0.5, .bottom = 4.0, .right = 2.0 }, \
   .innerColor = CGColorDataWithRGBA( 0, 0, 0, 0.5),                       \
   .outerColor = CGColorDataWithRGBA( 0, 0, 0, 0),                         \
   8.0,                                                                    \
   1                                                                       \
}


static inline struct MulleShadow
   MulleShadowMake( CGPoint offset, CGFloat blur, CGColor color)
{
   struct MulleShadow   shadow;

  // the blur / 4.0 value is experimentally determined
   shadow.extrudes = (struct MulleEdgeInsets)
                     {
                       .top    = offset.y,
                       .bottom = offset.y,
                       .left   = offset.x,
                       .right  = offset.x
                     };
   shadow.innerColor = color;
   shadow.outerColor = CGColorMakeTransparent();
   shadow.blur       = blur;   // guesstimate
   shadow.hole       = 1;
   return( shadow);
}


//
// this a drop shadow for a "rect", the space covered by the shadow is
// usually larger (insets/blur)
//
void   mvgFillRoundedShadow( struct NVGcontext *vg,
                             CGRect rect,
                             CGFloat cornerRadius,
                             struct MulleShadow *shadow);
//
// Draws text inside a rect. The text is clipped to the rect unless,
// the option MVGTextNoClip is given. The position within in the rect is
// determined by contentMode (see: mulle-layout) e.g. CGContentModeTopLeft.
// With MVGTextAlignVisually the will layout the text visually more pleasing,
// if the text contains no asencders or descenders or lacks both.
//
// Option MVGTextAlignBaseline will use the fonts baseline for positioning.
// With option MVGTextFill the text is layouted according to contentMode
// CGContentModeAspectFit and the result is then positioned within the rect
// with contentMode.
//
void   mvgTextInRect( NVGcontext *vg,
                      char *s,
                      char *end,
                      CGRect rect,
                      CGContentMode contentMode,
                      MulleTextOptions options);


//
// Calculate change to origin needed to properly place the string.
// The only recognized MulleTextOptions is MVGTextAlignVisually.
//
CGPoint   _mvgTLAdjustmentForVisualBounds( struct NVGcontext *vg,
                                           char *s,
                                           char *end,
                                           int alignment,
                                           MulleTextOptions options);

//
// workhorse function for mvgText, will set state to alignment
//
void   _mvgExtendedAlignedText( struct NVGcontext *vg,
                                char *s,
                                char *end,
                                CGPoint origin,
                                int alignment,
                                MulleTextOptions options);

//
// Draws text string at specified location. If end is specified only the
// sub-string up to the end is drawn. The only recognized MulleTextOptions
// is MVGTextAlignVisually. This will layout the text visually more pleasing,
// if the text contains no ascenders or descenders or lacks both.
//
static inline void   mvgExtendedAlignedText( struct NVGcontext *vg,
                                             char *s,
                                             char *end,
                                             CGPoint origin,
                                             int alignment,
                                             MulleTextOptions options)
{
   int   halign;

   halign = alignment & (NVG_ALIGN_LEFT | NVG_ALIGN_CENTER | NVG_ALIGN_RIGHT);
   if( halign != NVG_ALIGN_LEFT || (options & MVGTextAlignVisually))
   {
      // general idea: often the alignment and options are given
      // as a constant and the compiler can simplify the if away
      mvgTextAlign( vg, alignment);
      mvgText( vg, origin, s, end);
   }
   else
   {
      _mvgExtendedAlignedText( vg, s, end, origin, alignment, options);
   }
}


static inline void   mvgAssertFont( struct NVGcontext *vg)
{
#ifndef NDEBUG
   float   lineh;

   // in error case nvg, does not clear lineh!
   lineh = INFINITY;
   nvgTextMetrics( vg, NULL, NULL, &lineh);
   if( isinf( lineh))
   {
      fprintf( stderr, "No font has been loaded yet!\n");
      abort();
   }
#endif
}

#endif 

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


#ifndef microvg_h__
#define microvg_h__

#include "include.h"

#include <stdint.h>

// almost all nanovg functions are wrapped here for use with mulle-gfx
// geometry. Some functions with pointer parameter return values are changed
// to return structs now..

#include "microvg-nanowrap.h"

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


/*
 * Conveniences
 */

//     p.x         w
//   p.y ---------------------------
//
//
// Draw a horizontal line of width 'w' from p.x rightwards (if w > 0).
//
void   mvgStrokeLineHWithColor( NVGcontext *vg, CGPoint p, CGFloat w, CGFloat strokeWidth, NVGcolor color);
void   mvgStrokeLineHWithNVGpaint( NVGcontext *vg, CGPoint p, CGFloat w, CGFloat strokeWidth, NVGpaint paint);


//   p.x
//   | p.y
//   |
//   | h
//   |
//   |
//   |
//
// Draw a vertical line of height 'h' from p.y downwards (if h > 0).
//
void   mvgStrokeLineVWithColor( NVGcontext *vg, CGPoint p, CGFloat h, CGFloat strokeWidth, NVGcolor color);
void   mvgStrokeLineVWithNVGpaint( NVGcontext *vg, CGPoint p, CGFloat h, CGFloat strokeWidth, NVGpaint paint);


// Creates a new rectangle path and fills it with the given color.
void   mvgFillRoundedRectWithColor( NVGcontext *vg, CGRect rect, CGFloat cornerRadius, CGColor color);
void   mvgFillRoundedRectWithNVGpaint( NVGcontext *vg, CGRect rect, CGFloat cornerRadius, NVGpaint paint);

// Creates a new rectangle path and fills it with the given color.
void   mvgFillRectWithColor( NVGcontext *vg, CGRect rect, CGColor color);
void   mvgFillRectWithNVGpaint( NVGcontext *vg, CGRect rect, NVGpaint paint);


void   mvgFillCircleWithColor( NVGcontext *vg, CACircle circle, CGColor color);
void   mvgFillCircleWithNVGpaint( NVGcontext *vg, CACircle circle, NVGpaint paint);


// Creates a new rectangle path and strokes it with the given color.
void   mvgStrokeRoundedRectWithColor( NVGcontext *vg,
                                      CGRect rect,
                                      CGFloat cornerRadius,
                                      CGFloat strokeWidth,
                                      CGColor color);

//
// does not stroke outside of the rect bounds, i.e. corrects for strokeWidth
//
void   mvgStrokeInsideOfRoundedRectWithColor( NVGcontext *vg,
                                              CGRect rect,
                                              CGFloat cornerRadius,
                                              CGFloat strokeWidth,
                                              CGColor color);

// Creates a new rectangle path and strokes it with the given color.
void   mvgStrokeRectWithColor( NVGcontext *vg,
                               CGRect rect,
                               CGFloat strokeWidth,
                               CGColor color);

//
// does not stroke outside of the rect bounds, i.e. corrects for strokeWidth
//
void   mvgStrokeInsideOfRectWithColor( NVGcontext *vg,
                                       CGRect rect,
                                       CGFloat strokeWidth,
                                       CGColor color);


// Creates a line and strokes it with the color.
void   mvgStrokeLineWithColor( NVGcontext *vg,
                               CGPoint start,
                               CGPoint end,
                               CGFloat strokeWidth,
                               CGColor color);

void   mvgStrokeCircleWithColor( NVGcontext *vg,
                                 CACircle circle,
                                 CGFloat strokeWidth,
                                 CGColor color);


struct CGShadow
{
   struct MulleEdgeInsets   extrudes;
   CGColor                  innerColor;
   CGColor                  outerColor;
   CGFloat                  blur;
   char                     hole;
};


#define CGShadowDefaultValues  (struct CGShadow)                           \
{                                                                          \
   .extrudes   = { .top = 0.5, .left = 0.5, .bottom = 4.0, .right = 2.0 }, \
   .innerColor = CGColorDataWithRGBA( 0, 0, 0, 0.5),                       \
   .outerColor = CGColorDataWithRGBA( 0, 0, 0, 0),                         \
   8.0,                                                                    \
   1                                                                       \
}


static inline struct CGShadow
   CGShadowMake( CGPoint offset, CGFloat blur, CGColor color)
{
   struct CGShadow   shadow;

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
                             struct CGShadow *shadow);
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
// As above, but uses printf formatting for more convenience
// Don't use '\n' at the end
//
void   mvgFormatInRect( struct NVGcontext *vg,
                        CGRect rect,
                        CGContentMode contentMode,
                        MulleTextOptions options,
                        char *format,
                        ...);

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


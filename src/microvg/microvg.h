#ifndef microvg_h__
#define microvg_h__

#include "include.h"

#include <stdint.h>


#include "microvg-nanowrap.h"

#import "CGTypes.h"


/*
 * Conveniences
 */

void   mvgFillWithColor( NVGcontext *vg, CGColor color);
void   mvgFillWithNVGpaint( NVGcontext *vg, NVGpaint paint);

void   mvgStrokeWithColor( NVGcontext *vg, CGFloat strokeWidth, CGColor color);
void   mvgStrokeWithNVGpaint( NVGcontext *vg, CGFloat strokeWidth, NVGpaint paint);



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

   shadow.extrudes = (struct MulleEdgeInsets)
                     {
                       .top    = offset.y,
                       .bottom = offset.y,
                       .left   = offset.x,
                       .right  = offset.x
                     };
   shadow.innerColor = color;
   shadow.outerColor = CGColorMakeTransparent();
   shadow.blur       = blur;
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
// the option CGTextOptionNoClip is given. The position within in the rect is
// determined by contentMode (see: mulle-layout) e.g. CGContentModeTopLeft.
// With CGTextOptionAlignVisually the will layout the text visually more pleasing,
// if the text contains no ascenders or descenders or lacks both.
//
// Option CGTextOptionAlignBaseline will use the fonts baseline for positioning.
// With option CGTextOptionFill the text is layouted according to contentMode
// CGContentModeAspectFit and the result is then positioned within the rect
// with contentMode.
//
void   mvgTextInRect( NVGcontext *vg,
                      char *s,
                      size_t length,
                      CGRect rect,
                      CGContentMode contentMode,
                      CGTextOptions options);


//
// As above, but uses printf formatting for more convenience
// Don't use '\n' at the end
//
void   mvgFormatInRect( struct NVGcontext *vg,
                        CGRect rect,
                        CGContentMode contentMode,
                        CGTextOptions options,
                        char *format,
                        ...);


// more like nvgText but with a format
void   mvgFormat( struct NVGcontext *vg,  CGPoint point, char *format, ...);

//
// Calculate change to origin needed to properly place the string.
// The only recognized CGTextOptions is CGTextOptionAlignVisually.
//
CGPoint   _mvgTLAdjustmentForVisualBounds( struct NVGcontext *vg,
                                           char *s,
                                           size_t length,
                                           int alignment,
                                           CGTextOptions options);

//
// workhorse function for mvgText, will set state to alignment
//
void   _mvgExtendedAlignedText( struct NVGcontext *vg,
                                char *s,
                                size_t length,
                                CGPoint origin,
                                int alignment,
                                CGTextOptions options);

//
// Draws text string at specified location. If end is specified only the
// sub-string up to the end is drawn. The only recognized CGTextOptions
// is CGTextOptionAlignVisually. This will layout the text visually more pleasing,
// if the text contains no ascenders or descenders or lacks both.
//
static inline void   mvgExtendedAlignedText( struct NVGcontext *vg,
                                             char *s,
                                             size_t length,
                                             CGPoint origin,
                                             int alignment,
                                             CGTextOptions options)
{
   int   halign;

   halign = alignment & (NVG_ALIGN_LEFT | NVG_ALIGN_CENTER | NVG_ALIGN_RIGHT);
   if( halign != NVG_ALIGN_LEFT || (options & CGTextOptionAlignVisually))
   {
      // general idea: often the alignment and options are given
      // as a constant and the compiler can simplify the if away
      mvgTextAlign( vg, alignment);
      mvgText( vg, origin, s, length);
   }
   else
   {
      _mvgExtendedAlignedText( vg, s, length, origin, alignment, options);
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


#ifndef millivg_h__
#define millivg_h__

#include "include.h"

#include <stdint.h>


enum MVGTextOption
{
   MVGTextDefault       = 0x0,
   MVGTextAlignVisually = 0x1,
   MVGTextAlignBaseline = 0x2,
   MVGTextNoClip        = 0x4,
   MVGTextFill          = 0x8
};

typedef uintptr_t     MVGTextOptions;

// #define RENDER_DEBUG

// Creates a new rectangle path and fills it with the given color.
void   mvgFillRect( NVGcontext *vg, CGRect rect, CGColor color);

// Creates a new rectangle path and strokes it with the given color.
void   mvgStrokeRect( NVGcontext *vg, CGRect rect, CGColor color);

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
                      MVGTextOptions options);


//
// Calculate change to origin needed to properly place the string.
// The only recognized MVGTextOptions is MVGTextAlignVisually. 
//
CGPoint   _mvgTLAdjustmentForVisualBounds( struct NVGcontext *vg,
                                           char *s,
                                           char *end,
                                           int alignment,
                                           MVGTextOptions options);

//
// workhorse function for mvgText, will set state to alignment
//
void   _mvgText( struct NVGcontext *vg,
                 char *s,
                 char *end,
                 CGPoint origin,
                 int alignment,
                 MVGTextOptions options);

//
// Draws text string at specified location. If end is specified only the
// sub-string up to the end is drawn. The only recognized MVGTextOptions
// is MVGTextAlignVisually. This will layout the text visually more pleasing,
// if the text contains no asencders or descenders or lacks both.
//
static inline void   mvgText( struct NVGcontext *vg,
                              char *s,
                              char *end,
                              CGPoint origin,
                              int alignment,
                              MVGTextOptions options)
{
   int   halign;

   halign = alignment & (NVG_ALIGN_LEFT | NVG_ALIGN_CENTER | NVG_ALIGN_RIGHT);
   if( halign != NVG_ALIGN_LEFT || (options & MVGTextAlignVisually))
   {
      // general idea: often the alignment and options are given
      // as a constant and the compiler can simplify the if away
      nvgTextAlign( vg, alignment);
      nvgText( vg, origin.x, origin.y, s, end);
   }
   else
   {
      _mvgText( vg, s, end, origin, alignment, options);
   }
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


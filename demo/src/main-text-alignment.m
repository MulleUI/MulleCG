#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>


NSUInteger   alignments[] =
{
   NVG_ALIGN_LEFT   | NVG_ALIGN_TOP,
   NVG_ALIGN_CENTER | NVG_ALIGN_TOP,
   NVG_ALIGN_RIGHT  | NVG_ALIGN_TOP,

   NVG_ALIGN_LEFT   | NVG_ALIGN_MIDDLE,
   NVG_ALIGN_CENTER | NVG_ALIGN_MIDDLE,
   NVG_ALIGN_RIGHT  | NVG_ALIGN_MIDDLE,

   NVG_ALIGN_LEFT   | NVG_ALIGN_BOTTOM,
   NVG_ALIGN_CENTER | NVG_ALIGN_BOTTOM,
   NVG_ALIGN_RIGHT  | NVG_ALIGN_BOTTOM,

   NVG_ALIGN_LEFT   | NVG_ALIGN_BASELINE,
   NVG_ALIGN_CENTER | NVG_ALIGN_BASELINE,
   NVG_ALIGN_RIGHT  | NVG_ALIGN_BASELINE
};

#define N_ALIGNMENTS  (sizeof( alignments) / sizeof( alignments[ 0]))


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   struct NVGcontext    *vg;
   CGFont               *font;
   CGRect               canvas;
   CGRect               rects[ 9][ N_ALIGNMENTS];
   NSUInteger           x, y;
   CGRect               rect;
   char                 *s;
   float                ascender, descender, lineh;
   char                 buf[ 256];
   float                bounds[ 6];
   CGPoint              origin;
   NVGglyphPosition     positions[ 32];
   int                  i;
   int                  nGlyphs;
   char                 *text;

   vg     = CGContextGetNVGContext( context);
   font   = [context fontWithNameUTF8String:"sans"];

   nvgFontSize( vg, 32.0);

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
         mvgStrokeRectWithColor( vg, rect, 1.0, CGColorMakeGray());

         nvgSave( vg);
         {
            nvgScissor( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

            rect = CGRectInset( rect, 2, 2);

            nvgTextAlign( vg, alignments[ x]);

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
            }
            nvgTextBounds(vg, origin.x, origin.y, s, NULL, bounds);

            nvgBeginPath(vg);
            nvgRect( vg, bounds[0], bounds[1], bounds[2] - bounds[0], bounds[3] - bounds[1]);
            nvgStrokeColor( vg, CGColorMakeWithRGBA( 1, 0, 0, 0.333));
            nvgStrokeWidth( vg, 1.0);
            nvgStroke( vg);

            nvgTextVisualBounds(vg, origin.x, origin.y, s, NULL, bounds);

            nvgBeginPath(vg);
            nvgRect( vg, bounds[0], bounds[1], bounds[2] - bounds[0], bounds[3] - bounds[1]);
            nvgStrokeColor( vg, CGColorMakeWithRGBA( 0, 1, 0, 0.333));
            nvgStrokeWidth( vg, 1.0);
            nvgStroke( vg);

            nGlyphs = nvgTextGlyphPositions( vg, origin.x, origin.y, s, NULL, positions, 32);
            if( nGlyphs)
            {
               bounds[ 0] = positions[ 0].minx;
               bounds[ 1] = positions[ 0].miny;
               bounds[ 2] = positions[ 0].maxx;
               bounds[ 3] = positions[ 0].maxy;
            }
            for( i = 1; i < nGlyphs; i++)
            {
               bounds[ 1] = positions[ i].miny < bounds[ 1] ? positions[ i].miny : bounds[ 1];
               bounds[ 2] = positions[ i].maxx;
               bounds[ 3] = positions[ i].maxy > bounds[ 3] ? positions[ i].maxy : bounds[ 3];
            }
            nvgBeginPath(vg);
            nvgRect( vg, bounds[0], bounds[1], bounds[2] - bounds[0], bounds[3] - bounds[1]);
            nvgStrokeColor( vg, CGColorMakeWithRGBA( 0, 0, 1, 0.333));
            nvgStrokeWidth( vg, 1.0);
            nvgStroke( vg);

            nvgTextColor( vg, CGColorMakeWithHSVA( x / (CGFloat) N_ALIGNMENTS, 1.0, 1.0, 1.0));
            nvgTextBackgroundColor( vg, CGColorMakeWhite());
            nvgText( vg, origin.x, origin.y, s, NULL);
         }
         nvgRestore( vg);
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


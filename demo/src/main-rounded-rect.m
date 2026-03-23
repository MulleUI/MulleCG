//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#define _GNU_SOURCE

#import "import-private.h"

#if 0

static float nvg__absf(float a)  { return a >= 0.0f ? a : -a; }
static float nvg__minf(float a, float b) { return a < b ? a : b; }
#define 0.5522847493f 0.5522847493f   // Length proportional to radius of a cubic bezier handle for 90deg arcs.
void xxnvgRoundedRectVarying(CGContext *context, float x, float y, float w, float h,
                                            float radTopLeft, float radTopRight,
                                            float radBottomRight, float radBottomLeft)
{
   float halfw = nvg__absf(w)*0.5f;
   float halfh = nvg__absf(h)*0.5f;

   // this is in the order on how its' drawn (almost)
   float rxTL = nvg__minf( nvg__absf( radTopLeft), halfw);
   float ryTL = nvg__minf( nvg__absf( radTopLeft), halfh);
   float rxBL = nvg__minf( nvg__absf( radBottomLeft), halfw);
   float ryBL = nvg__minf( nvg__absf( radBottomLeft), halfh);
   float rxBR = nvg__minf( nvg__absf( radBottomRight), halfw);
   float ryBR = nvg__minf( nvg__absf( radBottomRight), halfh);
   float rxTR = nvg__minf( nvg__absf( radTopRight), halfw);
   float ryTR = nvg__minf( nvg__absf( radTopRight), halfh);

   float kappaTL = (radTopLeft < 0) ? 0.5522847493f : 1-0.5522847493f;
   float kappaBL = (radBottomLeft < 0) ? 0.5522847493f : 1-0.5522847493f;
   float kappaBR = (radBottomRight < 0) ? 0.5522847493f : 1-0.5522847493f;
   float kappaTR = (radTopRight < 0) ? 0.5522847493f : 1-0.5522847493f;

   CGPoint   c1;
   CGPoint   c2;
   CGPoint   p;

   // draw top left (end) to bottom left (start)

   CGContextBeginPath( context);

   p = CGPointMake( x,
                    y + h - ryBL);
   mvgMoveTo( context, p);

   // draw bottom left corner
   if( radBottomLeft < 0.0)
   {
      c1 = CGPointMake( x + rxBL * kappaBL,
                        y + h - ryBL);
      c2 = CGPointMake( x + rxBL,
                        y + h - ryBL * kappaBL);
   }
   else
   {
      c1 = CGPointMake( x,
                        y + h - ryBL * kappaBL);
      c2 = CGPointMake( x + rxBL * kappaBL,
                        y + h);
   }
   p  = CGPointMake( x + rxBL,
                     y + h);

   mvgBezierTo(  vg, c1, c2, p);

   // draw bottom left to bottom right corner

   p = CGPointMake( x + w - rxBR, y + h);
   mvgLineTo(    vg, p);

   // draw bottom right corner

   if( radBottomRight < 0.0)
   {
      c1 = CGPointMake( x + w - rxBR,
                        y + h - ryBR * kappaBR);
      c2 = CGPointMake( x + w - rxBR * kappaBR,
                        y + h - ryBR);
   }
   else
   {
      c1 = CGPointMake( x + w - rxBR * kappaBR,
                        y + h);
      c2 = CGPointMake( x + w,
                        y + h - ryBR * kappaBR);
   }
   p  = CGPointMake( x + w,
                     y + h - ryBR);

   mvgBezierTo(  vg, c1, c2, p);

   // draw bottom right to top right line
   p  = CGPointMake( x + w, y + ryTR);
   mvgLineTo(    vg, p);

   if( radTopRight < 0.0)
   {
      c1 = CGPointMake( x + w - rxTR * kappaTR,
                        y + ryTR);
      c2 = CGPointMake( x + w - rxTR,
                        y + ryTR * kappaTR);
   }
   else
   {
      c1 = CGPointMake( x + w,
                        y + ryTR * kappaTR);
      c2 = CGPointMake( x + w - rxTR * kappaTR,
                        y);
   }
   p  = CGPointMake( x + w - rxTR, y);

   mvgBezierTo( context, c1, c2, p);

   // draw top right to top left line
   p  = CGPointMake( x + rxTL, y);
   mvgLineTo(    vg, p);

   // draw top left corner
   if( radTopLeft < 0.0)
   {
      c1 = CGPointMake( x + rxTL,
                        y + ryTL * kappaTL);
      c2 = CGPointMake( x + rxTL * kappaTL,
                        y + ryTL);
   }
   else
   {
      c1 = CGPointMake( x + rxTL * kappaTL,
                        y);
      c2 = CGPointMake( x,
                        y + ryTL * kappaTL);
   }
   p  = CGPointMake( x, y + rxTL);

   mvgBezierTo( context, c1, c2, p);

   mvgClosePath( context);

}

static inline void   xmvgRoundedRectVarying( CGContext *context,
                                             CGRect rect,
                                             struct MulleCornerInsets corners)
{
   CGContextStrokeWidth( context, 2.0);
   xxCGContextRoundedRectVarying( context, rect.origin.x,
                                rect.origin.y,
                                rect.size.width,
                                rect.size.height,
                                corners.tl,
                                corners.tr,
                                corners.br,
                                corners.bl);
   CGContextStrokeColor( context, CGColorMakeWithHexColor( 0x808080FF));
   CGContextStroke( context);//   CGContextFillColor( context, CGColorMakeRed());
}

#endif
#if 0
void xxnvgRoundedRectVarying(CGContext *context, float x, float y, float w, float h,
                                             float radTopLeft, float radTopRight,
                                             float radBottomRight, float radBottomLeft)
{
   float halfw = nvg__absf(w)*0.5f;
   float halfh = nvg__absf(h)*0.5f;

   // this is in the order on how its' drawn (almost)
   float rxTL = nvg__minf( nvg__absf( radTopLeft), halfw);
   float ryTL = nvg__minf( nvg__absf( radTopLeft), halfh);
   float rxBL = nvg__minf( nvg__absf( radBottomLeft), halfw);
   float ryBL = nvg__minf( nvg__absf( radBottomLeft), halfh);
   float rxBR = nvg__minf( nvg__absf( radBottomRight), halfw);
   float ryBR = nvg__minf( nvg__absf( radBottomRight), halfh);
   float rxTR = nvg__minf( nvg__absf( radTopRight), halfw);
   float ryTR = nvg__minf( nvg__absf( radTopRight), halfh);

   float kappaTL = (radTopLeft < 0) ? 0.5522847493f : 1-0.5522847493f;
   float kappaBL = (radBottomLeft < 0) ? 0.5522847493f : 1-0.5522847493f;
   float kappaBR = (radBottomRight < 0) ? 0.5522847493f : 1-0.5522847493f;
   float kappaTR = (radTopRight < 0) ? 0.5522847493f : 1-0.5522847493f;

   CGPoint   c1;
   CGPoint   c2;
   CGPoint   p;

   // draw top left (end) to bottom left (start)

   CGContextBeginPath( context);
   p = CGPointMake( x,
                    y + ryTL);
   mvgMoveTo( context, p);
   p = CGPointMake( x,
                    y + h - ryBL);
   mvgLineTo( context, p);
   CGContextStrokeColor( context, CGColorMakeWithHexColor( 0xF02020FF));
   CGContextStroke( context);

   // draw bottom left corner
   CGContextBeginPath( context);
   mvgMoveTo( context, p);

   if( radBottomLeft < 0.0)
   {
      c1 = CGPointMake( x + rxBL * kappaBL,
                        y + h - ryBL);
      c2 = CGPointMake( x + rxBL,
                        y + h - ryBL * kappaBL);
   }
   else
   {
      c1 = CGPointMake( x,
                        y + h - ryBL * kappaBL);
      c2 = CGPointMake( x + rxBL * kappaBL,
                        y + h);
   }
   p  = CGPointMake( x + rxBL,
                     y + h);

   mvgBezierTo(  vg, c1, c2, p);
   CGContextStrokeColor( context, CGColorMakeWithHexColor( 0xF08020FF));
   CGContextStroke( context);

   mvgFillCircleWithColor( context, c1, 2.0, CGColorMakeRed());
   mvgFillCircleWithColor( context, c2, 2.0, CGColorMakeGreen());

   // draw bottom left to bottom right corner

   CGContextBeginPath( context);
   mvgMoveTo(    vg, p);
   p = CGPointMake( x + w - rxBR, y + h);
   mvgLineTo(    vg, p);
   CGContextStrokeColor( context, CGColorMakeWithHexColor( 0x20F020FF));
   CGContextStroke( context);

   // draw bottom right corner
   CGContextBeginPath( context);
   mvgMoveTo(    vg, p);

   if( radBottomRight < 0.0)
   {
      c1 = CGPointMake( x + w - rxBR,
                        y + h - ryBR * kappaBR);
      c2 = CGPointMake( x + w - rxBR * kappaBR,
                        y + h - ryBR);
   }
   else
   {
      c1 = CGPointMake( x + w - rxBR * kappaBR,
                        y + h);
      c2 = CGPointMake( x + w,
                        y + h - ryBR * kappaBR);
   }
   p  = CGPointMake( x + w,
                     y + h - ryBR);

   mvgBezierTo(  vg, c1, c2, p);
   CGContextStrokeColor( context, CGColorMakeWithHexColor( 0xF080F0FF));
   CGContextStroke( context);

   mvgFillCircleWithColor( context, c1, 2.0, CGColorMakeRed());
   mvgFillCircleWithColor( context, c2, 2.0, CGColorMakeGreen());

   // draw bottom right to top right line
   CGContextBeginPath( context);
   mvgMoveTo(    vg, p);
   p  = CGPointMake( x + w, y + ryTR);
   mvgLineTo(    vg, p);
   CGContextStrokeColor( context, CGColorMakeWithHexColor( 0x2020F0FF));
   CGContextStroke( context);

   // draw top right corner
   CGContextBeginPath( context);
   mvgMoveTo(    vg, p);

   if( radTopRight < 0.0)
   {
      c1 = CGPointMake( x + w - rxTR * kappaTR,
                        y + ryTR);
      c2 = CGPointMake( x + w - rxTR,
                        y + ryTR * kappaTR);
   }
   else
   {
      c1 = CGPointMake( x + w,
                        y + ryTR * kappaTR);
      c2 = CGPointMake( x + w - rxTR * kappaTR,
                        y);
   }
   p  = CGPointMake( x + w - rxTR, y);

   mvgBezierTo( context, c1, c2, p);
   CGContextStrokeColor( context, CGColorMakeWithHexColor( 0x404060FF));
   CGContextStroke( context);

   mvgFillCircleWithColor( context, c1, 2.0, CGColorMakeRed());
   mvgFillCircleWithColor( context, c2, 2.0, CGColorMakeGreen());
   // draw top right to top left line
   CGContextBeginPath( context);
   mvgMoveTo(    vg, p);
   p  = CGPointMake( x + rxTL, y);
   mvgLineTo(    vg, p);
   CGContextStrokeColor( context, CGColorMakeWithHexColor( 0xF080F0FF));
   CGContextStroke( context);

   // draw top left corner
   CGContextBeginPath( context);
   mvgMoveTo(    vg, p);

   if( radTopLeft < 0.0)
   {
      c1 = CGPointMake( x + rxTL,
                        y + ryTL * kappaTL);
      c2 = CGPointMake( x + rxTL * kappaTL,
                        y + ryTL);
   }
   else
   {
      c1 = CGPointMake( x + rxTL * kappaTL,
                        y);
      c2 = CGPointMake( x,
                        y + ryTL * kappaTL);
   }
   p  = CGPointMake( x, y + rxTL);

   mvgBezierTo( context, c1, c2, p);
   CGContextStrokeColor( context, CGColorMakeWithHexColor( 0x404060FF));
   CGContextStroke( context);

   mvgFillCircleWithColor( context, c1, 2.0, CGColorMakeRed());
   mvgFillCircleWithColor( context, c2, 2.0, CGColorMakeGreen());
}
#endif

static void   drawRoundedRect( CGContext *context, CGRect canvas, struct MulleCornerInsets insets) // Converted from struct CGContext *context
{
   CGRect    rect;

   rect = CGRectInset( canvas, fabsf( insets.topLeft), fabsf( insets.bottomRight));

   // insets are flipped, because rect is flipped!

   CGContextBeginPath( context);
   CGContextRoundedRectVarying( context, rect, insets);
   CGContextStrokeWidth( context, 8);
   CGContextStrokeColor( context, CGColorMakeWithHexColor( 0xF0C0C0FF));
   CGContextStroke( context);//   CGContextFillColor( context, CGColorMakeRed());, nvgFillColor
   CGContextBeginPath( context); // Converted from mvgBeginPath
   CGContextRoundedRectVarying( context, rect, insets); // Converted from mvgRoundedRectVarying
   CGContextStrokeWidth( context, 2); // Converted from mvgStrokeWidth
   CGContextStrokeColor( context, CGColorMakeWithHexColor( 0x808080FF)); // Converted from mvgStrokeColor
   CGContextStroke( context);//   CGContextFillColor( context, CGColorMakeRed()); // Converted from mvgStroke, nvgFillColor

//   CGContextFill( context);

//   CGContextStrokeRectWithColor( context, rect, 1.0, CGColorMakeGray()); // Converted from mvgStrokeRectWithColor
}
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *_context)
{
   CGContext                  *context = _context;
   CGRect                     canvas;
   CGRect                     rect;
   struct MulleCornerInsets   insets;
   CGFloat                    value;
   CGRect                     rects[ 2][ 2];
   int                        i, j;

   canvas = [layer canvas];
   canvas = CGRectInset( canvas, 10, 10);
   CGRectPartition2x2( canvas, CGSizeMake( 10, 10), rects);
   for( j = 0; j < 2; j++)
      for( i = 0; i < 2; i++)
      {
         rect   = CGRectIntegral( rects[ j][ i]);
         value  = CGRectGetMinimumSize( rect) / 6;
         if( i == 0)
            insets = MulleCornerInsetsMakeWithCornerRadius( -value);
         else
            insets = MulleCornerInsetsMakeWithCornerRadius( value);
//         if( j == 1)
//            rect = CGRectMake( CGRectGetMaxX( rect),
//                               CGRectGetMaxY( rect),
//                               -CGRectGetWidth( rect),
//                               -CGRectGetHeight( rect));
         drawRoundedRect( context, rect, insets); // Updated function call
      }
   return( YES);
}

int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;

   app = [UIApplication sharedInstance];

   window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 600, 600)];
   [[window contentView] setDrawCallback:drawStuff];
   [app addWindow:window];

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


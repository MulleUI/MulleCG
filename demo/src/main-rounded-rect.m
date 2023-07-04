#define _GNU_SOURCE

#import "import-private.h"

static float nvg__absf(float a)  { return a >= 0.0f ? a : -a; }
static float nvg__signf(float a) { return a >= 0.0f ? 1.0f : -1.0f; }
static float nvg__minf(float a, float b) { return a < b ? a : b; }
static float nvg__maxf(float a, float b) { return a > b ? a : b; }


#define NVG_KAPPA90 0.5522847493f   // Length proportional to radius of a cubic bezier handle for 90deg arcs.


void xnvgRoundedRectVarying(NVGcontext* vg, float x, float y, float w, float h, float radTopLeft, float radTopRight, float radBottomRight, float radBottomLeft)
{
   float halfw = nvg__absf(w)*0.5f;
   float halfh = nvg__absf(h)*0.5f;
//   float rxBL = nvg__minf( nvg__absf( radBottomLeft), halfw) * nvg__signf(w),  ryBL = nvg__minf( nvg__absf( radBottomLeft), halfh) * nvg__signf(h);
//   float rxBR = nvg__minf( nvg__absf( radBottomRight), halfw) * nvg__signf(w), ryBR = nvg__minf( nvg__absf( radBottomRight), halfh) * nvg__signf(h);
//   float rxTR = nvg__minf( nvg__absf( radTopRight), halfw) * nvg__signf(w),    ryTR = nvg__minf( nvg__absf( radTopRight), halfh) * nvg__signf(h);
//   float rxTL = nvg__minf( nvg__absf( radTopLeft), halfw) * nvg__signf(w),     ryTL = nvg__minf( nvg__absf( radTopLeft), halfh) * nvg__signf(h);

//   float ctrlPointOffsetTL = radTopLeft < 0 ? nvg__absf(radTopLeft) / NVG_KAPPA90 : 0;
//   float ctrlPointOffsetTR = radTopRight < 0 ? nvg__absf(radTopRight) / NVG_KAPPA90 : 0;
//   float ctrlPointOffsetBR = radBottomRight < 0 ? nvg__absf(radBottomRight) / NVG_KAPPA90 : 0;
//   float ctrlPointOffsetBL = radBottomLeft < 0 ? nvg__absf(radBottomLeft) / NVG_KAPPA90 : 0;

//   float ctrlPointOffsetTL = radTopLeft < 0 ? -nvg__absf(radTopLeft) / 0.552284749831 : nvg__absf(radTopLeft) / 0.552284749831;
//   float ctrlPointOffsetTR = radTopRight < 0 ? -nvg__absf(radTopRight) / 0.552284749831 : nvg__absf(radTopRight) / 0.552284749831;
//   float ctrlPointOffsetBR = radBottomRight < 0 ? -nvg__absf(radBottomRight) / 0.552284749831 : nvg__absf(radBottomRight) / 0.552284749831;
//   float ctrlPointOffsetBL = radBottomLeft < 0 ? -nvg__absf(radBottomLeft) / 0.552284749831 : nvg__absf(radBottomLeft) / 0.552284749831;


//   float ctrlPointOffsetTL = radTopLeft < 0 ? nvg__absf(radTopLeft) : 0;
//   float ctrlPointOffsetTR = radTopRight < 0 ? nvg__absf(radTopRight) : 0;
//   float ctrlPointOffsetBR = radBottomRight < 0 ? nvg__absf(radBottomRight) : 0;
//   float ctrlPointOffsetBL = radBottomLeft < 0 ? nvg__absf(radBottomLeft) : 0;

    float rxBL = nvg__minf( nvg__absf( radBottomLeft), halfw) * nvg__signf(w) * nvg__signf(radBottomLeft);
    float ryBL = nvg__minf( nvg__absf( radBottomLeft), halfh) * nvg__signf(h) * nvg__signf(radBottomLeft);
    float rxBR = nvg__minf( nvg__absf( radBottomRight), halfw) * nvg__signf(w) * nvg__signf(radBottomRight);
    float ryBR = nvg__minf( nvg__absf( radBottomRight), halfh) * nvg__signf(h) * nvg__signf(radBottomRight);
    float rxTR = nvg__minf( nvg__absf( radTopRight), halfw) * nvg__signf(w) * nvg__signf(radTopRight);
    float ryTR = nvg__minf( nvg__absf( radTopRight), halfh) * nvg__signf(h) * nvg__signf(radTopRight);
    float rxTL = nvg__minf( nvg__absf( radTopLeft), halfw) * nvg__signf(w) * nvg__signf(radTopLeft);
    float ryTL = nvg__minf( nvg__absf( radTopLeft), halfh) * nvg__signf(h) * nvg__signf(radTopLeft);

        float kappaTL = (radTopLeft < 0) ? NVG_KAPPA90 : 1-NVG_KAPPA90;
        float kappaTR = (radTopRight < 0) ? NVG_KAPPA90 : 1-NVG_KAPPA90;
        float kappaBR = (radBottomRight < 0) ? NVG_KAPPA90 : 1-NVG_KAPPA90;
        float kappaBL = (radBottomLeft < 0) ? NVG_KAPPA90 : 1-NVG_KAPPA90;

        CGPoint   c1;
        CGPoint   c2;
        CGPoint   p;

   nvgStrokeWidth( vg, 2.0);

   // draw top left (end) to bottom left (start)

   nvgBeginPath( vg);
   p = CGPointMake( x, y + nvg__absf( ryTL));
   mvgMoveTo(    vg, p);
   p = CGPointMake( x, y + h - nvg__absf( ryBL));
   mvgLineTo(    vg, p);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xF02020FF));
   nvgStroke( vg);

   // draw bottom left corner
   nvgBeginPath( vg);
   mvgMoveTo(    vg, p);

   if( radBottomLeft < 0.0)
   {
      c1 = CGPointMake( x + nvg__absf( rxBL) * kappaBL,
                        y + h  - nvg__absf( ryBL));
      c2 = CGPointMake( x + nvg__absf( rxBL),
                        y + h - nvg__absf( ryBL) * kappaBL);
   }
   else
   {
      c1 = CGPointMake( x,
                        y + h - nvg__absf( ryBL) * kappaBL);
      c2 = CGPointMake( x + nvg__absf( rxBL) * kappaBL,
                        y + h);
   }
   p  = CGPointMake( x + nvg__absf( rxBL),
                     y + h);

   mvgBezierTo(  vg, c1, c2, p);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xF08020FF));
   nvgStroke( vg);

   mvgFillCircleWithColor( vg, c1, 2.0, CGColorMakeRed());
   mvgFillCircleWithColor( vg, c2, 2.0, CGColorMakeGreen());

   // draw bottom left to bottom right corner

   nvgBeginPath( vg);
   nvgMoveTo(    vg, x + nvg__absf( rxBL), y + h);
   nvgLineTo(    vg, x + w - nvg__absf( rxBR), y + h);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x20F020FF));
   nvgStroke( vg);

   // draw bottom right corner
   nvgBeginPath( vg);
   nvgMoveTo(    vg, x + w - nvg__absf( rxBR), y + h);

   if( radBottomRight < 0.0)
   {
      c1 = CGPointMake( x + w - nvg__absf( rxBR),
                        y + h - nvg__absf( ryBR) * kappaBR);
      c2 = CGPointMake( x + w - nvg__absf( rxBR) * kappaBR,
                        y + h - nvg__absf( ryBR));
   }
   else
   {
      c1 = CGPointMake( x + w - nvg__absf( rxBR) * kappaBR,
                        y + h);
      c2 = CGPointMake( x + w,
                        y + h - nvg__absf( ryBR) * kappaBR);
   }
   p  = CGPointMake( x + w,
                     y + h - nvg__absf( ryBR));

   mvgBezierTo(  vg, c1, c2, p);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xF080F0FF));
   nvgStroke( vg);

   mvgFillCircleWithColor( vg, c1, 2.0, CGColorMakeRed());
   mvgFillCircleWithColor( vg, c2, 2.0, CGColorMakeGreen());

   // draw bottom right to top right line
   nvgBeginPath( vg);
   mvgMoveTo(    vg, p);
   p  = CGPointMake( x + w, y + nvg__absf( ryTR));
   mvgLineTo(    vg, p);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x2020F0FF));
   nvgStroke( vg);

   // draw top right corner
   nvgBeginPath( vg);
   mvgMoveTo(    vg, p);

   if( radTopRight < 0.0)
   {
      c1 = CGPointMake( x + w - nvg__absf( rxTR) * kappaTR,
                        y + nvg__absf( ryTR));
      c2 = CGPointMake( x + w - nvg__absf( rxTR),
                        y + nvg__absf( ryTR) * kappaTR);
   }
   else
   {
      c1 = CGPointMake( x + w,
                        y + nvg__absf( ryTR) * kappaTR);
      c2 = CGPointMake( x + w - nvg__absf( rxTR) * kappaTR,
                        y);
   }
   p  = CGPointMake( x + w - nvg__absf( rxTR), y);

   mvgBezierTo( vg, c1, c2, p);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x404060FF));
   nvgStroke( vg);

   mvgFillCircleWithColor( vg, c1, 2.0, CGColorMakeRed());
   mvgFillCircleWithColor( vg, c2, 2.0, CGColorMakeGreen());


   // draw top right to top left line
   nvgBeginPath( vg);
   mvgMoveTo(    vg, p);
   p  = CGPointMake( x + nvg__absf( rxTL), y);
   mvgLineTo(    vg, p);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xF080F0FF));
   nvgStroke( vg);

   // draw top left corner
   nvgBeginPath( vg);
   mvgMoveTo(    vg, p);

   if( radTopLeft < 0.0)
   {
      c1 = CGPointMake( x + nvg__absf( rxTL),
                        y + nvg__absf( ryTL) * kappaTL);
      c2 = CGPointMake( x + nvg__absf( rxTL) * kappaTL,
                        y + nvg__absf( ryTL));
   }
   else
   {
      c1 = CGPointMake( x + nvg__absf( rxTL) * kappaTL,
                        y);
      c2 = CGPointMake( x,
                        y + nvg__absf( ryTL) * kappaTL);
   }
   p  = CGPointMake( x, y + nvg__absf( rxTL));

   mvgBezierTo( vg, c1, c2, p);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x404060FF));
   nvgStroke( vg);

   mvgFillCircleWithColor( vg, c1, 2.0, CGColorMakeRed());
   mvgFillCircleWithColor( vg, c2, 2.0, CGColorMakeGreen());

//   nvgLineTo(    vg, x + w, y + h - ryBR);
//   nvgLineTo(    vg, x + w, y + ryTR);
//   nvgLineTo(    vg, x + w - rxTR, y);
//   nvgLineTo(    vg, x + rxTL, y);
//   nvgLineTo(    vg, x, y + ryTL);
//   nvgClosePath( vg);
}


static inline void   xmvgRoundedRectVarying( NVGcontext *vg,
                                             CGRect rect,
                                             struct MulleCornerInsets corners)
{
   xnvgRoundedRectVarying( vg, rect.origin.x,
                              rect.origin.y,
                              rect.size.width,
                              rect.size.height,
                              corners.tl,
                              corners.tr,
                              corners.br,
                              corners.bl);
}



static void   drawStuff( CALayer *layer, CGContext *context)
{
   struct NVGcontext          *vg;
   CGRect                     canvas;
   CGRect                     rect;
   struct MulleCornerInsets   insets;
   CGFloat                    value;

   vg     = CGContextGetNVGContext( context);
   canvas = [layer canvas];
   value  = CGRectGetMinimumSize( canvas) / 6;
   rect   = CGRectInset( canvas, value, value);
   value  = -CGRectGetMinimumSize( rect) / 3;
   insets = MulleCornerInsetsMake( value, value, value, value);
   nvgBeginPath( vg);
   xmvgRoundedRectVarying( vg, rect, insets);
//   nvgFillColor( vg, CGColorMakeRed());
//   nvgFill( vg);

//   mvgStrokeRectWithColor( vg, rect, 1.0, CGColorMakeGray());
}



int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;

   app = [UIApplication sharedInstance];

   window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 300, 200)];
   [[window contentPlane] setDrawCallback:drawStuff];
   [app addWindow:window];

   return( [app run]);
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

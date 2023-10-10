#define _GNU_SOURCE

#import "import-private.h"

#if 0

static float nvg__absf(float a)  { return a >= 0.0f ? a : -a; }
static float nvg__minf(float a, float b) { return a < b ? a : b; }


#define NVG_KAPPA90 0.5522847493f   // Length proportional to radius of a cubic bezier handle for 90deg arcs.


void xxnvgRoundedRectVarying(NVGcontext* vg, float x, float y, float w, float h,
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

   float kappaTL = (radTopLeft < 0) ? NVG_KAPPA90 : 1-NVG_KAPPA90;
   float kappaBL = (radBottomLeft < 0) ? NVG_KAPPA90 : 1-NVG_KAPPA90;
   float kappaBR = (radBottomRight < 0) ? NVG_KAPPA90 : 1-NVG_KAPPA90;
   float kappaTR = (radTopRight < 0) ? NVG_KAPPA90 : 1-NVG_KAPPA90;

   CGPoint   c1;
   CGPoint   c2;
   CGPoint   p;

   // draw top left (end) to bottom left (start)

   nvgBeginPath( vg);

   p = CGPointMake( x,
                    y + h - ryBL);
   mvgMoveTo( vg, p);

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

   mvgBezierTo( vg, c1, c2, p);

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

   mvgBezierTo( vg, c1, c2, p);

   mvgClosePath( vg);

}

static inline void   xmvgRoundedRectVarying( NVGcontext *vg,
                                             CGRect rect,
                                             struct MulleCornerInsets corners)
{
   nvgStrokeWidth( vg, 2.0);
   xxnvgRoundedRectVarying( vg, rect.origin.x,
                                rect.origin.y,
                                rect.size.width,
                                rect.size.height,
                                corners.tl,
                                corners.tr,
                                corners.br,
                                corners.bl);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x808080FF));
   nvgStroke( vg);//   nvgFillColor( vg, CGColorMakeRed());
}

#endif


#if 0
void xxnvgRoundedRectVarying(NVGcontext* vg, float x, float y, float w, float h,
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

   float kappaTL = (radTopLeft < 0) ? NVG_KAPPA90 : 1-NVG_KAPPA90;
   float kappaBL = (radBottomLeft < 0) ? NVG_KAPPA90 : 1-NVG_KAPPA90;
   float kappaBR = (radBottomRight < 0) ? NVG_KAPPA90 : 1-NVG_KAPPA90;
   float kappaTR = (radTopRight < 0) ? NVG_KAPPA90 : 1-NVG_KAPPA90;

   CGPoint   c1;
   CGPoint   c2;
   CGPoint   p;

   // draw top left (end) to bottom left (start)

   nvgBeginPath( vg);
   p = CGPointMake( x,
                    y + ryTL);
   mvgMoveTo( vg, p);
   p = CGPointMake( x,
                    y + h - ryBL);
   mvgLineTo( vg, p);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xF02020FF));
   nvgStroke( vg);

   // draw bottom left corner
   nvgBeginPath( vg);
   mvgMoveTo( vg, p);

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
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xF08020FF));
   nvgStroke( vg);

   mvgFillCircleWithColor( vg, c1, 2.0, CGColorMakeRed());
   mvgFillCircleWithColor( vg, c2, 2.0, CGColorMakeGreen());

   // draw bottom left to bottom right corner

   nvgBeginPath( vg);
   mvgMoveTo(    vg, p);
   p = CGPointMake( x + w - rxBR, y + h);
   mvgLineTo(    vg, p);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x20F020FF));
   nvgStroke( vg);

   // draw bottom right corner
   nvgBeginPath( vg);
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
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xF080F0FF));
   nvgStroke( vg);

   mvgFillCircleWithColor( vg, c1, 2.0, CGColorMakeRed());
   mvgFillCircleWithColor( vg, c2, 2.0, CGColorMakeGreen());

   // draw bottom right to top right line
   nvgBeginPath( vg);
   mvgMoveTo(    vg, p);
   p  = CGPointMake( x + w, y + ryTR);
   mvgLineTo(    vg, p);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x2020F0FF));
   nvgStroke( vg);

   // draw top right corner
   nvgBeginPath( vg);
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

   mvgBezierTo( vg, c1, c2, p);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x404060FF));
   nvgStroke( vg);

   mvgFillCircleWithColor( vg, c1, 2.0, CGColorMakeRed());
   mvgFillCircleWithColor( vg, c2, 2.0, CGColorMakeGreen());


   // draw top right to top left line
   nvgBeginPath( vg);
   mvgMoveTo(    vg, p);
   p  = CGPointMake( x + rxTL, y);
   mvgLineTo(    vg, p);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xF080F0FF));
   nvgStroke( vg);

   // draw top left corner
   nvgBeginPath( vg);
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

   mvgBezierTo( vg, c1, c2, p);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x404060FF));
   nvgStroke( vg);

   mvgFillCircleWithColor( vg, c1, 2.0, CGColorMakeRed());
   mvgFillCircleWithColor( vg, c2, 2.0, CGColorMakeGreen());
}
#endif



static void   drawRoundedRect( struct NVGcontext *vg, CGRect canvas, struct MulleCornerInsets insets)
{
   CGRect    rect;

   rect = CGRectInset( canvas, fabsf( insets.topLeft), fabsf( insets.bottomRight));

   // insets are flipped, because rect is flipped!

   nvgBeginPath( vg);
   nvgRoundedRectVarying( vg, rect.origin.x,
                              rect.origin.y,
                              rect.size.width,
                              rect.size.height,
                              insets.topLeft,
                              insets.topRight,
                              insets.bottomRight,
                              insets.bottomLeft);
   nvgStrokeWidth( vg, 8);
   nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xF0C0C0FF));
   nvgStroke( vg);//   nvgFillColor( vg, CGColorMakeRed());


   mvgBeginPath( vg);
   mvgRoundedRectVarying( vg, rect, insets);
   mvgStrokeWidth( vg, 2);
   mvgStrokeColor( vg, CGColorMakeWithHexColor( 0x808080FF));
   mvgStroke( vg);//   nvgFillColor( vg, CGColorMakeRed());

//   nvgFill( vg);

//   mvgStrokeRectWithColor( vg, rect, 1.0, CGColorMakeGray());
}


static BOOL   drawStuff( CALayer *layer, void *_context)
{
   CGContext                  *context = _context;
   struct NVGcontext          *vg;
   CGRect                     canvas;
   CGRect                     rect;
   struct MulleCornerInsets   insets;
   CGFloat                    value;
   CGRect                     rects[ 2][ 2];
   int                        i, j;

   vg     = CGContextGetNVGContext( context);
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
         drawRoundedRect( vg, rect, insets);
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

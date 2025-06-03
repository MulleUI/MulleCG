// this file will be included in nanovg.c
// with help of the NANOVG_EXTENSION_SOURCE define, which is set in the
// CMakeLists.txt file.
//
// Contains additional functions and functionality for nanovg, that needs
// to know about internal state.
//
void nvgRoundedRectVarying_alternative( NVGcontext *ctx,
                                        float x, float y, float w, float h,
                                        float radTopLeft, float radTopRight,
                                        float radBottomRight, float radBottomLeft)
{
   float absRTL = nvg__absf( radTopLeft);
   float absRTR = nvg__absf( radTopRight);
   float absRBR = nvg__absf( radBottomRight);
   float absRBL = nvg__absf( radBottomLeft);

   if( absRTL < 0.1f && absRTR < 0.1f && absRBR < 0.1f && absRBL < 0.1f)
   {
      nvgRect( ctx, x, y, w, h);
      return;
   }

   float halfw   = nvg__absf(w)*0.5f;
   float halfh   = nvg__absf(h)*0.5f;

   float rxTL    = nvg__minf( absRTL, halfw);
   float ryTL    = nvg__minf( absRTL, halfh);
   float rxTR    = nvg__minf( absRTR, halfw);
   float ryTR    = nvg__minf( absRTR, halfh);
   float rxBR    = nvg__minf( absRBR, halfw);
   float ryBR    = nvg__minf( absRBR, halfh);
   float rxBL    = nvg__minf( absRBL, halfw);
   float ryBL    = nvg__minf( absRBL, halfh);

   float kappaTL = (radTopLeft < 0)     ? NVG_KAPPA90 : 1 - NVG_KAPPA90;
   float kappaTR = (radTopRight < 0)    ? NVG_KAPPA90 : 1 - NVG_KAPPA90;
   float kappaBL = (radBottomLeft < 0)  ? NVG_KAPPA90 : 1 - NVG_KAPPA90;
   float kappaBR = (radBottomRight < 0) ? NVG_KAPPA90 : 1 - NVG_KAPPA90;

   // 9 cmds (1 moveto + 2, 4 bezierto + 6, 3 lineto + 2, 1 close +0)
   //      NVG_MOVETO, x, y + ryTL,
   //      NVG_BEZIERTO, x, y + h - ryBL*(1 - NVG_KAPPA90), x + rxBL*(1 - NVG_KAPPA90), y + h, x + rxBL, y + h,
   //      NVG_LINETO, x + w - rxBR, y + h,
   //      NVG_BEZIERTO, x + w - rxBR*(1 - NVG_KAPPA90), y + h, x + w, y + h - ryBR*(1 - NVG_KAPPA90), x + w, y + h - ryBR,
   //      NVG_LINETO, x + w, y + ryTR,
   //      NVG_BEZIERTO, x + w, y + ryTR*(1 - NVG_KAPPA90), x + w - rxTR*(1 - NVG_KAPPA90), y, x + w - rxTR, y,
   //      NVG_LINETO, x + rxTL, y,
   //      NVG_BEZIERTO, x + rxTL*(1 - NVG_KAPPA90), y, x, y + ryTL*(1 - NVG_KAPPA90), x, y + ryTL,
   //      NVG_CLOSE
   float   vals[ 9 + 1 * 2 + 3 * 2 + 4 * 6 + 1 * 0];
   float   *q;

   q    = vals;
   // draw top left (end) to bottom left (start)

   *q++ = NVG_MOVETO;
   *q++ = x;
   *q++ = y + h - ryBL;

   // draw bottom right corner
   *q++ = NVG_BEZIERTO;

   if( radBottomLeft < 0.0)
   {
      *q++ = x + rxBL * kappaBL;
      *q++ = y + h - ryBL;
      *q++ = x + rxBL;
      *q++ = y + h - ryBL * kappaBL;
   }
   else
   {
      *q++ = x;
      *q++ = y + h - ryBL * kappaBL;
      *q++ = x + rxBL * kappaBL;
      *q++ = y + h;
   }

   *q++ = x + rxBL;
   *q++ = y + h;

   // draw bottom left to bottom right corner

   *q++ = NVG_LINETO;
   *q++ = x + w - rxBR;
   *q++ = y + h;

   // draw bottom right corner
   *q++ = NVG_BEZIERTO;

   if( radBottomRight < 0.0)
   {
      *q++ = x + w - rxBR;
      *q++ = y + h - ryBR * kappaBR;
      *q++ = x + w - rxBR * kappaBR;
      *q++ = y + h - ryBR;
   }
   else
   {
      *q++ = x + w - rxBR * kappaBR;
      *q++ = y + h;
      *q++ = x + w;
      *q++ = y + h - ryBR * kappaBR;
   }

   *q++ = x + w;
   *q++ = y + h - ryBR;

   // draw bottom right to top right line

   *q++ = NVG_LINETO;
   *q++ = x + w;
   *q++ = y + ryTR;

   // draw bottom right to top right line
   *q++ = NVG_BEZIERTO;

   if( radTopRight < 0.0)
   {
      *q++ = x + w - rxTR * kappaTR;
      *q++ = y + ryTR;
      *q++ = x + w - rxTR;
      *q++ = y + ryTR * kappaTR;
   }
   else
   {
      *q++ = x + w;
      *q++ = y + ryTR * kappaTR;
      *q++ = x + w - rxTR * kappaTR;
      *q++ = y;
   }

   *q++ = x + w - rxTR;
   *q++ = y;

   // draw top right to top left line
   *q++ = NVG_LINETO;
   *q++ = x + rxTL;
   *q++ = y;

   // draw top left corner
   *q++ = NVG_BEZIERTO;

   if( radTopLeft < 0.0)
   {
      *q++ = x + rxTL;
      *q++ = y + ryTL * kappaTL;
      *q++ = x + rxTL * kappaTL;
      *q++ = y + ryTL;
   }
   else
   {
      *q++ = x + rxTL * kappaTL;
      *q++ = y;
      *q++ = x;
      *q++ = y + ryTL * kappaTL;
   }

   *q++ = x;
   *q++ = y + rxTL;

   *q++ = NVG_CLOSE;

   assert( q == &vals[ NVG_COUNTOF(vals)]);

   nvg__appendCommands(ctx, vals, NVG_COUNTOF(vals));
}

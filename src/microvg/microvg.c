#define _GNU_SOURCE

#include "microvg.h"


void   mvgStrokeLineHWithColor( NVGcontext *vg, CGPoint p, CGFloat w, CGFloat strokeWidth, NVGcolor color)
{
   nvgBeginPath(vg);
   {
      nvgMoveTo( vg, p.x, p.y);
      nvgLineTo( vg, p.x + w, p.y);
      nvgStrokeColor( vg, color);
      nvgStrokeWidth( vg, strokeWidth);
   }
   nvgStroke( vg);
}


void   mvgStrokeLineHWithNVGPaint( NVGcontext *vg, CGPoint p, CGFloat w, CGFloat strokeWidth, NVGpaint paint)
{
   nvgBeginPath(vg);
   {
      nvgMoveTo( vg, p.x, p.y);
      nvgLineTo( vg, p.x + w, p.y);
      nvgStrokePaint( vg, paint);
      nvgStrokeWidth( vg, strokeWidth);
   }
   nvgStroke( vg);
}


void   mvgStrokeLineVWithColor( NVGcontext *vg, CGPoint p, CGFloat h, CGFloat strokeWidth, NVGcolor color)
{
   nvgBeginPath( vg);
   {
      nvgMoveTo( vg, p.x, p.y);
      nvgLineTo( vg, p.x, p.y + h);
      nvgStrokeColor( vg, color);
      nvgStrokeWidth( vg, strokeWidth);
   }
   nvgStroke( vg);
}


void   mvgStrokeLineVWithNVGPaint( NVGcontext *vg, CGPoint p, CGFloat h, CGFloat strokeWidth, NVGpaint paint)
{
   nvgBeginPath( vg);
   {
      nvgMoveTo( vg, p.x, p.y);
      nvgLineTo( vg, p.x, p.y + h);
      nvgStrokePaint( vg, paint);
      nvgStrokeWidth( vg, strokeWidth);
   }
   nvgStroke( vg);
}



void   mvgFillRoundedRectWithColor( NVGcontext *vg,
                                    CGRect rect,
                                    CGFloat cornerRadius,
                                    CGColor color)
{
   mvgBeginPath( vg);
   {
      mvgRoundedRect( vg, rect, cornerRadius);
      mvgFillColor( vg, color);
   }
   mvgFill( vg);
}


void   mvgFillRoundedRectWithNVGpaint( NVGcontext *vg,
                                       CGRect rect,
                                       CGFloat cornerRadius,
                                       NVGpaint paint)
{
   mvgBeginPath( vg);
   {
      mvgRoundedRect( vg, rect, cornerRadius);
      mvgFillPaint( vg, paint);
   }
   mvgFill( vg);
}


/***/

void   mvgFillRectWithColor( NVGcontext *vg, CGRect rect, CGColor color)
{
   mvgBeginPath( vg);
   {
      mvgRect( vg, rect);
      mvgFillColor( vg, color);
   }
   mvgFill( vg);
}


void   mvgFillRectWithNVGpaint( NVGcontext *vg, CGRect rect, NVGpaint paint)
{
   mvgBeginPath( vg);
   {
      mvgRect( vg, rect);
      mvgFillPaint( vg, paint);
   }
   mvgFill( vg);
}


/***/
void   mvgFillCircleWithColor( NVGcontext *vg, CACircle circle, CGColor color)
{
   mvgBeginPath( vg);
   {
      mvgCircle( vg, circle);
      mvgFillColor( vg, color);
   }
   mvgFill( vg);
}


void   mvgFillCircleWithNVGpaint( NVGcontext *vg, CACircle circle, NVGpaint paint)
{
   mvgBeginPath( vg);
   {
      mvgCircle( vg, circle);
      mvgFillPaint( vg, paint);
   }
   mvgFill( vg);
}


/***/
void   mvgStrokeRoundedRectWithColor( NVGcontext *vg,
                                      CGRect rect,
                                      CGFloat cornerRadius,
                                      CGFloat strokeWidth,
                                      CGColor color)
{
   mvgBeginPath( vg);
   {
      mvgRoundedRect( vg, rect, cornerRadius);
      mvgStrokeColor( vg, color);
      mvgStrokeWidth( vg, strokeWidth);
   }
   mvgStroke( vg);
}


void   mvgStrokeInsideOfRoundedRectWithColor( NVGcontext *vg,
                                              CGRect rect,
                                              CGFloat cornerRadius,
                                              CGFloat strokeWidth,
                                              CGColor color)
{
   mvgBeginPath( vg);
   {
      rect = CGRectInset( rect, strokeWidth / 2.0f, strokeWidth / 2.0f);

      mvgRoundedRect( vg, rect, cornerRadius);
      mvgStrokeColor( vg, color);
      mvgStrokeWidth( vg, strokeWidth);
   }
   mvgStroke( vg);
}



void   mvgStrokeRectWithColor( NVGcontext *vg,
                               CGRect rect,
                               CGFloat strokeWidth,
                               CGColor color)
{
   mvgBeginPath( vg);
   {
      mvgRect( vg, rect);
      mvgStrokeColor( vg, color);
      mvgStrokeWidth( vg, strokeWidth);
   }
   mvgStroke( vg);
}


void   mvgStrokeInsideOfRectWithColor( NVGcontext *vg,
                                       CGRect rect,
                                       CGFloat strokeWidth,
                                       CGColor color)
{
   mvgBeginPath( vg);
   {
      rect = CGRectInset( rect, strokeWidth / 2.0f, strokeWidth / 2.0f);

      mvgRect( vg, rect);
      mvgStrokeColor( vg, color);
      mvgStrokeWidth( vg, strokeWidth);
   }
   mvgStroke( vg);
}


void   mvgStrokeCircleWithColor( NVGcontext *vg,
                                 CACircle circle,
                                 CGFloat strokeWidth,
                                 CGColor color)
{
   mvgBeginPath( vg);
   {
      mvgCircle( vg, circle);
      mvgStrokeColor( vg, color);
      mvgStrokeWidth( vg, strokeWidth);
   }
   mvgStroke( vg);
}


void   mvgStrokeLineWithColor( NVGcontext *vg,
                               CGPoint start,
                               CGPoint end,
                               CGFloat strokeWidth,
                               CGColor color)
{
   mvgBeginPath( vg);
   {
      mvgMoveTo( vg, start);
      mvgLineTo( vg, end);
      mvgStrokeColor( vg, color);
      mvgStrokeWidth( vg, strokeWidth);
   }
   mvgStroke( vg);
}


static struct CGShadow   defaultShadow = CGShadowDefaultValues;


void   mvgFillRoundedShadow( struct NVGcontext *vg,
                             CGRect rect,
                             CGFloat cornerRadius,
                             struct CGShadow *shadow)
{
   CGRect     shadowRect;
   CGRect     gradientRect;
   NVGpaint   shadowPaint;
   CGFloat    feather;

   shadow         = shadow ? shadow : &defaultShadow;
   // calculate feather from blur value
   feather        = shadow->blur;
   gradientRect   = CGRectExtrude( rect, feather / 2.0, feather / 2.0);
   shadowPaint    = nvgBoxGradient( vg, gradientRect.origin.x,
                                        gradientRect.origin.y,
                                        gradientRect.size.width,
                                        gradientRect.size.height,
                                        cornerRadius,
                                        feather,
                                        shadow->innerColor,
                                        shadow->outerColor);
  // Draw the drop shadow
   shadowRect = CGRectExtrude( rect, feather * 2, feather * 2);
//   shadowRect = CGRectExtrudeUsingEdgeInsets( extendedRect, shadow->extrudes);
   mvgBeginPath(vg);
   mvgRoundedRect( vg, shadowRect, cornerRadius);
   if( shadow->hole)
   {
      mvgRoundedRect( vg, rect, cornerRadius);
      mvgPathWinding( vg, NVG_HOLE);
   }
   mvgFillPaint(vg, shadowPaint);
   mvgFill(vg);
}


//
// TODO: The parts that scale in a horiziontal line and those that are fixed
//       is deterministic. So we don't technically _need_ a binary search,
//       if we knew how to compute the width.
//
static float   mvgSearchFontSizeForText( struct NVGcontext *vg,
                                         char *s,
                                         char *end,
                                         float maxFontSize,
                                         CGFloat width,
                                         float bounds[ 6])
{
   CGFloat   actualW;
   CGFloat   diff;
   int       oldFontSize;
   int       newFontSize;
   int       step;

   assert( end);

   newFontSize  = (int) (maxFontSize / 2.0 * 10.0f);
   step         = newFontSize;

   //
   // just do it 10 times at most, we can't totally guarantee that
   // the font info is stable or ?
   //
   for(;;)
   {
      nvgFontSize( vg, (newFontSize / 10.0f) > 5.0 ? (newFontSize / 10.0f) : 5.0);
      nvgTextVisualBounds( vg, 0.0f, 0.0f, s, end, bounds);
      actualW = bounds[ 2] - bounds[ 0];
      diff    = width - actualW;

      oldFontSize = newFontSize;
      if( diff >= 0)
         newFontSize += step;
      else
         newFontSize -= step;
      step /= 2;

      if( oldFontSize == newFontSize)
         return( newFontSize / 10.0f);
   }
}


static inline float  round_to_one_tenth( float v)
{
   assert( v >= 0.0);

   return( (float) ((int) round( v * 10.0f) / 10.0f));
}

#define REFERENCE_FONTSIZE 100.0f



// why is that not a CGContext function ?
// Because we are taking part in the implicit states of nvg, like textColor,
// fontID etc.
//
// will envgFontSize
void   mvgTextInRect( struct NVGcontext *vg,
                      char *s,
                      char *end,
                      CGRect rect,
                      CGContentMode contentMode,
                      MulleTextOptions options)
{
   float                     bounds[ 6];
   CGPoint                   origin;
   CGRect                    coverage;
   CGFloat                   hfactor;
   CGFloat                   vfactor;
   CGFloat                   factor;
   CGFloat                   maxFactor;
   CGFloat                   fontSize;
   int                       binSearch;
   CGContentMode             fillContentMode;
   struct MulleTextMetrics   metrics;

   if( ! s)
      return;

   if( ! end)
   {
      end = &s[ strlen( s)];
      if( end == s)
         return;
   }

   mvgAssertFont( vg);

   nvgSave( vg);
   do
   {
      // center, right is broken so do it ourselves
      nvgTextAlign( vg, NVG_ALIGN_LEFT | NVG_ALIGN_TOP);

      fillContentMode = CGContentModeLeft;
      if( options & MVGTextFill)
      {
         if( contentMode > CGContentModeScaleAspectFill)
            fillContentMode = contentMode;
         contentMode = CGContentModeScaleToFill;
      }

      switch( contentMode)
      {
      case CGContentModeScaleToFill     :
      case CGContentModeScaleAspectFill :
      case CGContentModeScaleAspectFit  :
         nvgFontSize( vg, REFERENCE_FONTSIZE); // need large font for precision
      }
      nvgTextVisualBounds( vg, 0, 0, s, end, bounds);

      if( options & MVGTextAlignVisually)
         coverage = CGRectMake( bounds[ 0], bounds[ 1], bounds[ 2] - bounds[ 0], bounds[ 3] - bounds[ 1]);
      else
         coverage = CGRectMake( 0, 0, bounds[ 2] - bounds[ 0], bounds[ 5] - bounds[ 4]);

#ifdef RENDER_DEBUG
      nvgSave( vg);
      {
         nvgTranslate( vg, rect.origin.x, rect.origin.y);
         mvgFillRectWithColor( vg, coverage, CGColorMakeWithRGBA( 1.0, 0.0, 0.0, 0.25));
      }
      nvgRestore( vg);
#endif

      // horizontal size changes fluctuate, so need to binary search those
      binSearch = 0;
      factor    = 1.0;

      switch( contentMode)
      {
      case CGContentModeScaleToFill     : // scale to fit text horizontally
         hfactor = rect.size.width / coverage.size.width;
         vfactor = rect.size.height / coverage.size.height;
         if( hfactor > vfactor)
         {
            factor    = hfactor;
            maxFactor = vfactor;
            binSearch = 1;
         }
         else
            factor = vfactor;
         contentMode = fillContentMode;
         break;

      case CGContentModeScaleAspectFit : // scale so everything fits
         hfactor = rect.size.width / coverage.size.width;
         vfactor = rect.size.height / coverage.size.height;
         if( hfactor < vfactor)
         {
            factor    = hfactor;
            maxFactor = vfactor;
            binSearch = 1;
         }
         else
            factor = vfactor;
         contentMode = CGContentModeCenterPoint;
         break;

      case CGContentModeScaleAspectFill  : // scale font so either w or h fits
         hfactor = rect.size.width / coverage.size.width;
         vfactor = rect.size.height / coverage.size.height;
         if( hfactor > vfactor)
         {
            factor    = hfactor;
            maxFactor = vfactor;
            binSearch = 1;
         }
         else
            factor = vfactor;
         contentMode = CGContentModeCenterPoint;
         break;
      }

      // change fontSize and recalc boundaries
      // a problem, is that internally fontsize is an integer divided by 10
      // so we can't get more precision
      if( factor != 1.0f)
      {
         if( binSearch)
         {
            // we pass the max we gonna accept
            fontSize = round_to_one_tenth( REFERENCE_FONTSIZE * maxFactor);
            fontSize = mvgSearchFontSizeForText( vg, s, end, fontSize, rect.size.width, bounds);
            // this is the size we get for hor, but is if it's too much use maxFactor
         }
         else
         {
            fontSize = round_to_one_tenth( REFERENCE_FONTSIZE * factor);
            nvgFontSize( vg, fontSize);
            nvgTextVisualBounds( vg, 0, 0, s, end, bounds);
         }

         if( fontSize < 5.0f)
            break;

#ifdef RENDER_DEBUG
         nvgSave( vg);
         {
            char  buf[ 256];

            sprintf( buf, "fontSize: %g  lineh: %g", fontSize, bounds[ 5] - bounds[ 4]);
            nvgFontSize( vg, 16.0);
            nvgText( vg, 0, 0, buf, NULL);
         }
         nvgRestore( vg);
#endif

         if( options & MVGTextAlignVisually)
            coverage = CGRectMake( bounds[ 0], bounds[ 1], bounds[ 2] - bounds[ 0], bounds[ 3] - bounds[ 1]);
         else
            coverage = CGRectMake( 0, 0, bounds[ 2] - bounds[ 0], bounds[ 5] - bounds[ 4]);
      }

#ifdef RENDER_DEBUG
      mvgSave( vg);
      {
         mvgTranslate( vg, rect.origin.x, rect.origin.y);
         mvgFillRectWithColor( vg, coverage, CGColorMakeWithRGBA( 0.0, 0.0, 1.0, 0.25));
      }
      mvgRestore( vg);
#endif

      origin    = CGSizePlaceInRect( coverage.size, rect, contentMode).origin;
      origin.x -= coverage.origin.x;
      origin.y -= coverage.origin.y;

      if( options & MVGTextAlignBaseline)
      {
         metrics = mvgTextMetrics( vg);
         switch( contentMode)
         {
         case CGContentModeTopLeft     :
         case CGContentModeTop         :
         case CGContentModeTopRight    : origin.y -= metrics.ascender; break;

         case CGContentModeLeft        :
         case CGContentModeCenterPoint :
         case CGContentModeRight       : origin.y = CGRectGetMidY( rect) - metrics.ascender; break;

         case CGContentModeBottomLeft  :
         case CGContentModeBottom      :
         case CGContentModeBottomRight : origin.y -= metrics.descender; break;
         }
      }

      if( options & MVGTextNoClip)
      {
         mvgText( vg, origin, s, end);
      }
      else
      {
         mvgScissor( vg, rect);
         mvgText( vg, origin, s, end);
      }
   }
   while( 0);

   nvgRestore( vg);
}


void   mvgFormatInRect( struct NVGcontext *vg,
                        CGRect rect,
                        CGContentMode contentMode,
                        MulleTextOptions options,
                        char *format,
                        ...)
{
   auto char   tmp[ 256];
   va_list     args;
   char        *s;
   size_t      len;

   if( ! format)
      return;

   va_start( args, format);

   mulle_buffer_do_flexible( buffer, tmp, sizeof( tmp))
   {
      mulle_buffer_vsprintf( buffer, format, args);
      len = mulle_buffer_get_length( buffer);
      s   = mulle_buffer_get_bytes( buffer);
      mvgTextInRect( vg, s, &s[ len], rect, contentMode, options);
   }
   va_end( args);
}


CGPoint   _mvgTLAdjustmentForVisualBounds( struct NVGcontext *vg,
                                           char *s,
                                           char *end,
                                           int alignment,
                                           MulleTextOptions options)
{
   int      halign;
   int      valign;
   float    ascender;
   float    lineh;
   float    bounds[ 6];
   CGRect   coverage;
   CGPoint  adjust;

   adjust = CGPointZero;
   if( ! s)
      return( adjust);

   end = &s[ strlen( s)];
   if( end == s)
      return( adjust);

   halign = alignment & (NVG_ALIGN_LEFT | NVG_ALIGN_CENTER | NVG_ALIGN_RIGHT);
   valign = alignment & (NVG_ALIGN_BASELINE | NVG_ALIGN_TOP | NVG_ALIGN_MIDDLE | NVG_ALIGN_BOTTOM);

   // center, right is broken so do we always draw LEFT/TOP and calculate
   // for ourselves
   nvgTextAlign( vg, NVG_ALIGN_LEFT | NVG_ALIGN_TOP);
   nvgTextVisualBounds( vg, 0, 0, s, end, bounds);

   if( options & MVGTextAlignVisually)
   {
      coverage = CGRectMake( bounds[ 0],
                             bounds[ 1],
                             bounds[ 2] - bounds[ 0],
                             bounds[ 3] - bounds[ 1]);
   }
   else
   {
      coverage = CGRectMake( bounds[ 0],
                             bounds[ 1],
                             bounds[ 2] - bounds[ 0],
                             bounds[ 5] - bounds[ 4]);
   }
   lineh = bounds[ 5] - bounds[ 4];

#ifdef RENDER_DEBUG
   nvgSave( vg);
   {
      nvgTranslate( vg, origin.x, origin.y);
      mvgFillRectWithColor( vg, coverage, CGColorMakeWithRGBA( 0.5, 0.5, 0.5, 0.5));
   }
   nvgRestore( vg);

   nvgSave( vg);
   {
      nvgFontSize( vg, 14);
      nvgText( vg, 0, 0, CGRectUTF8String( coverage), NULL);
   }
   nvgRestore( vg);
#endif

   if( options & MVGTextAlignVisually)
   {
      switch( valign)
      {
      case NVG_ALIGN_TOP      : adjust.y += -CGRectGetMinY( coverage); break;
      case NVG_ALIGN_MIDDLE   : adjust.y += -CGRectGetMinY( coverage) - (coverage.size.height / 2.0);
                                break;
      case NVG_ALIGN_BOTTOM   : adjust.y += -CGRectGetMinY( coverage) - coverage.size.height; break;
      case NVG_ALIGN_BASELINE : nvgTextMetrics( vg, &ascender, NULL, NULL);
                                adjust.y += -CGRectGetMinY( coverage) + ascender;
                                break;
      }
   }
   else
   {
      switch( valign)
      {
      case NVG_ALIGN_TOP      : break;
      case NVG_ALIGN_MIDDLE   : adjust.y -= lineh / 2.0; break;
      case NVG_ALIGN_BOTTOM   : adjust.y -= lineh; break;
      case NVG_ALIGN_BASELINE : nvgTextMetrics( vg, &ascender, NULL, NULL);
                                adjust.y -= ascender; break;
      }
   }

   switch( halign)
   {
   case NVG_ALIGN_LEFT     : break;
   case NVG_ALIGN_CENTER   : adjust.x -= (coverage.size.width / 2.0); break;
   case NVG_ALIGN_RIGHT    : adjust.x -= coverage.size.width; break;
   }

   return( adjust);
}


void   _mvgExtendedAlignedText( struct NVGcontext *vg,
                                char *s,
                                char *end,
                                CGPoint origin,
                                int alignment,
                                MulleTextOptions options)
{
   CGPoint   adjust;

   mvgAssertFont( vg);

   adjust = _mvgTLAdjustmentForVisualBounds( vg, s, end, alignment, options);

   // already done by _mvgAdjustmentForVisualBounds
   // nvgTextAlign( vg, NVG_ALIGN_LEFT | NVG_ALIGN_TOP);
   nvgText( vg, origin.x + adjust.x, origin.y + adjust.y, s, end);

   // make state expected
   nvgTextAlign( vg, alignment);
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


//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGContext+Drawing.h"

#import "import-private.h"

#import "CGDrawable.h"
#import "CGImage.h"



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


//
// this a drop shadow for a "rect", the space covered by the shadow is
// usually larger (insets/blur)
//
static void   mvgFillRoundedShadow( struct NVGcontext *vg,
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
static void   mvgTextInRect( NVGcontext *vg,
                             char *s,
                             size_t length,
                             CGRect rect,
                             CGContentMode contentMode,
                             CGTextOptions options);

//
// Calculate change to origin needed to properly place the string.
// The only recognized CGTextOptions is CGTextOptionAlignVisually.
//
static CGPoint   _mvgTLAdjustmentForVisualBounds( struct NVGcontext *vg,
                                                  char *s,
                                                  size_t length,
                                                  int alignment,
                                                  CGTextOptions options);

//
// workhorse function for mvgText, will set state to alignment
//
static void   _mvgExtendedAlignedText( struct NVGcontext *vg,
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
      nvgTextAlign( vg, alignment);
      nvgText( vg, origin.x, origin.y, s, &s[ length]);
   }
   else
   {
      _mvgExtendedAlignedText( vg, s, length, origin, alignment, options);
   }
}



//
// Conveniences
//
void   CGContextFillWithColor( CGContext *context, CGColor color)
{
   NVGcontext   *vg = CGContextGetNVGContext( context);

   nvgFillColor( vg, color);
   nvgFill( vg);
}


void   CGContextStrokeWithColor( CGContext *context,
                                 CGFloat strokeWidth,
                                 CGColor color)
{
   NVGcontext   *vg = CGContextGetNVGContext( context);

   nvgStrokeColor( vg, color);
   nvgStrokeWidth( vg, strokeWidth);
   nvgStroke( vg);
}


void   CGContextStrokeLineHWithColor( CGContext *context,
                                      CGPoint p,
                                      CGFloat w,
                                      CGFloat strokeWidth,
                                      CGColor color)
{
   NVGcontext   *vg = CGContextGetNVGContext( context);

   nvgBeginPath(vg);
   {
      nvgMoveTo( vg, p.x, p.y);
      nvgLineTo( vg, p.x + w, p.y);
      nvgStrokeColor( vg, color);
      nvgStrokeWidth( vg, strokeWidth);
   }
   nvgStroke( vg);
}


void   CGContextStrokeLineVWithColor( CGContext *context,
                                      CGPoint p,
                                      CGFloat h,
                                      CGFloat strokeWidth,
                                      CGColor color)
{
   NVGcontext   *vg = CGContextGetNVGContext( context);

   nvgBeginPath( vg);
   {
      nvgMoveTo( vg, p.x, p.y);
      nvgLineTo( vg, p.x, p.y + h);
      nvgStrokeColor( vg, color);
      nvgStrokeWidth( vg, strokeWidth);
   }
   nvgStroke( vg);
}


void   CGContextFillRoundedRectWithColor( CGContext *context,
                                          CGRect rect,
                                          CGFloat cornerRadius,
                                          CGColor color)
{
   NVGcontext   *vg = CGContextGetNVGContext( context);

   mvgBeginPath( vg); // mvgBeginPath is a wrapper around nvgBeginPath, should be CGContextBeginPath
   {
      mvgRoundedRect( vg, rect, cornerRadius); // mvgRoundedRect should be CGContextRoundedRect
      mvgFillColor( vg, color); // mvgFillColor should be CGContextFillColor (or nvgFillColor directly)
   }
   mvgFill( vg); // mvgFill should be CGContextFill
}


/***/

void   CGContextFillRectWithColor( CGContext *context,
                                   CGRect rect,
                                   CGColor color)
{
   NVGcontext   *vg = CGContextGetNVGContext( context);

   mvgBeginPath( vg);
   {
      mvgRect( vg, rect);
      mvgFillColor( vg, color);
   }
   mvgFill( vg);
}


/***/
void   CGContextFillCircleWithColor( CGContext *context,
                                     CACircle circle,
                                     CGColor color)
{
   NVGcontext   *vg = CGContextGetNVGContext( context);

   mvgBeginPath( vg);
   {
      mvgCircle( vg, circle);
      mvgFillColor( vg, color);
   }
   mvgFill( vg);
}


/***/
void   CGContextStrokeRoundedRectWithColor( CGContext *context,
                                            CGRect rect,
                                            CGFloat cornerRadius,
                                            CGFloat strokeWidth,
                                            CGColor color)
{
   NVGcontext   *vg = CGContextGetNVGContext( context);

   mvgBeginPath( vg);
   {
      mvgRoundedRect( vg, rect, cornerRadius);
      mvgStrokeColor( vg, color);
      mvgStrokeWidth( vg, strokeWidth);
   }
   mvgStroke( vg);
}


void   CGContextStrokeInsideOfRoundedRectWithColor( CGContext *context,
                                                    CGRect rect,
                                                    CGFloat cornerRadius,
                                                    CGFloat strokeWidth,
                                                    CGColor color)
{
   NVGcontext   *vg = CGContextGetNVGContext( context);

   mvgBeginPath( vg);
   {
      rect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside);

      mvgRoundedRect( vg, rect, cornerRadius);
      mvgStrokeColor( vg, color);
      mvgStrokeWidth( vg, strokeWidth);
   }
   mvgStroke( vg);
}



void   CGContextStrokeRectWithColor( CGContext *context,
                                     CGRect rect,
                                     CGFloat strokeWidth,
                                     CGColor color)
{
   NVGcontext   *vg = CGContextGetNVGContext( context);

   mvgBeginPath( vg);
   {
      mvgRect( vg, rect);
      mvgStrokeColor( vg, color);
      mvgStrokeWidth( vg, strokeWidth);
   }
   mvgStroke( vg);
}


void   CGContextStrokeInsideOfRectWithColor( CGContext *context,
                                             CGRect rect,
                                             CGFloat strokeWidth,
                                             CGColor color)
{
   NVGcontext   *vg = CGContextGetNVGContext( context);

   mvgBeginPath( vg);
   {
      rect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside);

      mvgRect( vg, rect);
      mvgStrokeColor( vg, color);
      mvgStrokeWidth( vg, strokeWidth);
   }
   mvgStroke( vg);
}


void   CGContextStrokeCircleWithColor( CGContext *context,
                                       CACircle circle,
                                       CGFloat strokeWidth,
                                       CGColor color)
{
   NVGcontext   *vg = CGContextGetNVGContext( context);

   mvgBeginPath( vg);
   {
      mvgCircle( vg, circle);
      mvgStrokeColor( vg, color);
      mvgStrokeWidth( vg, strokeWidth);
   }
   mvgStroke( vg);
}


void   CGContextStrokeLineWithColor( CGContext *context,
                                     CGPoint start,
                                     CGPoint end,
                                     CGFloat strokeWidth,
                                     CGColor color)
{
   NVGcontext   *vg = CGContextGetNVGContext( context);

   mvgBeginPath( vg);
   {
      mvgMoveTo( vg, start);
      mvgLineTo( vg, end);
      mvgStrokeColor( vg, color);
      mvgStrokeWidth( vg, strokeWidth);
   }
   mvgStroke( vg);
}


// will use radialGradient!
void   CGContextFillCircleWithGradientColors( CGContext *context,
                                              CACircle circle,
                                              CGColor outerColor,
                                              CGColor innerColor)
{
   NVGpaint     nvgPaint;
   NVGcontext   *vg;

   vg        = CGContextGetNVGContext( context);
   nvgPaint  = nvgRadialGradient( vg, circle.center.x,
                                      circle.center.y,
                                      0.0,
                                      circle.radius,
                                      outerColor,
                                      innerColor);
   nvgFillPaint( vg, nvgPaint);
   nvgFill( vg);
}


void   CGContextStrokeCircleWithGradientColors( CGContext *context,
                                                CACircle circle,
                                                CGColor outerColor,
                                                CGColor innerColor,
                                                CGFloat strokeWidth)
{
   NVGpaint     nvgPaint;
   NVGcontext   *vg;

   if( strokeWidth <= 0.0)
      return;

   vg       = CGContextGetNVGContext( context);
   nvgPaint = nvgRadialGradient( vg, circle.center.x,
                                     circle.center.y,
                                     0.0,
                                     circle.radius - strokeWidth / 2.0,  // guess
                                     outerColor,
                                     innerColor);
   nvgStrokePaint( vg, nvgPaint);
   nvgStrokeWidth( vg, strokeWidth);
   nvgStroke( vg);
}



// Format text in rect
void   CGContextFormatInRect( CGContext *context,
                              CGRect rect,
                              CGContentMode contentMode,
                              CGTextOptions options,
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
     mvgTextInRect( CGContextGetNVGContext( context),
                    s,
                    len,
                    rect,
                    contentMode,
                    options);
   }
   va_end( args);
}


// Format text at point
void   CGContextFormat( CGContext *context, CGPoint point, char *format, ...)
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
     mvgText( CGContextGetNVGContext( context), point, s, len);
   }
   va_end( args);
}



//////// former microvg

static struct CGShadow   defaultShadow = CGShadowDefaultValues;


static void   mvgFillRoundedShadow( struct NVGcontext *vg,
                                    CGRect rect,
                                    CGFloat cornerRadius,
                                    struct CGShadow *shadow)
{
   CGRect     shadowRect;
   CGRect     gradientRect;
   NVGpaint   shadowPaint;
   CGFloat    feather;

   shadow       = shadow ? shadow : &defaultShadow;
   // calculate feather from blur value
   feather      = shadow->blur;
   gradientRect = CGRectExtrude( rect, feather / 2.0, feather / 2.0);
   shadowPaint  = nvgBoxGradient( vg, gradientRect.origin.x,
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
// TODO: The parts that scale in a horizontal line and those that are fixed
//       is deterministic. So we don't technically _need_ a binary search,
//       if we knew how to compute the width.
//
static float   mvgSearchFontSizeForTextFittingWidth( struct NVGcontext *vg,
                                                     char *s,
                                                     size_t length,
                                                     float maxFontSize,
                                                     CGFloat width)
{
   CGFloat   diff;
   int       oldFontSize;
   int       newFontSize;
   int       step;
   CGRect    vbounds;
   float     actual;

   assert( s);

   newFontSize = (int) (maxFontSize / 2.0 * 10.0f);
   step        = newFontSize;

   //
   // just do it 10 times at most, we can't totally guarantee that
   // the font info is stable or ?
   //
   for(;;)
   {
      actual  = mvgFontSize( vg, (newFontSize / 10.0f) > 5.0 ? (newFontSize / 10.0f) : 5.0);
      vbounds = mvgTextVisualBounds( vg, CGPointZero, s, length);
      diff    = width - vbounds.size.width;

      oldFontSize = newFontSize;
      if( diff >= 0)
         newFontSize += step;
      else
         newFontSize -= step;
      step /= 2;

      if( oldFontSize == newFontSize)
         return( actual);
   }
}


//static inline float  round_to_one_tenth( float v)
//{
//   assert( v >= 0.0);
//
//   return( (float) ((int) round( v * 10.0f) / 10.0f));
//}
//
#define REFERENCE_FONTSIZE 100.0f

static CGTextBoundsInfo   _mvgComputeTextRect( struct NVGcontext *vg,
                                               char *s,
                                               size_t length,
                                               CGRect rect,
                                               CGContentMode contentMode,
                                               CGTextOptions options)
{
   CGRect             vbounds;
   CGRect             coverage;
   CGFloat            hfactor;
   float              ascender;
   CGFloat            vfactor;
   CGFloat            factor;
   CGFloat            maxFactor;
   float              lineHeight;
   int                binSearch;
   CGContentMode      fillContentMode;
   CGTextBoundsInfo   result;
   float              fontSize;

   assert( s);
   assert( length != (size_t) -1);
   mvgAssertFont( vg);

   result = CGTextBoundsInfoNull;

   // too small to draw (could draw gray blob though, should I ?)
   if( rect.size.width < 1.0 || rect.size.height < 1.0)
      return( result);

   mvgSave( vg);
   do
   {
      // center, right is broken so do it ourselves
      // only left and baseline do not factor in broken ascender, descender
      // values so we should probably go with this
      nvgTextAlign( vg, NVG_ALIGN_LEFT | NVG_ALIGN_TOP);

      fillContentMode = CGContentModeLeft;
      if( options & CGTextOptionFill)
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
         fontSize = mvgFontSize( vg, REFERENCE_FONTSIZE); // need large font for precision
         break;

      default :
         fontSize = NAN;
         break;
      }

      if( options & CGTextOptionAlignVisually)
         coverage = mvgTextVisualBounds( vg, CGPointZero, s, length);
      else
         coverage = mvgTextBounds( vg, CGPointZero, s, length).bounds;

      // horizontal size changes fluctuate, so need to binary search those
      // we don't know the "current" fontSize so set to NAN
      binSearch = 0;
      factor    = 1.0;

      switch( contentMode)
      {
      case CGContentModeScaleToFill     : // scale to fit text horizontally
         contentMode = fillContentMode;
         hfactor     = fabsf( rect.size.width / coverage.size.width);
         vfactor     = fabsf( rect.size.height / coverage.size.height);
         if( hfactor > vfactor)
         {
            factor    = hfactor;
            maxFactor = vfactor;
            binSearch = 1;
         }
         else
            factor = vfactor;
         break;

      case CGContentModeScaleAspectFit : // scale so everything fits
         contentMode = CGContentModeCenter;
         hfactor     = fabsf( rect.size.width / coverage.size.width);
         vfactor     = fabsf( rect.size.height / coverage.size.height);
         if( hfactor < vfactor)
         {
            factor    = hfactor;
            maxFactor = vfactor;
            binSearch = 1;
         }
         else
            factor = vfactor;
         break;

      case CGContentModeScaleAspectFill  : // scale font so either w or h fits
         contentMode = CGContentModeCenter;
         hfactor     = fabsf( rect.size.width / coverage.size.width);
         vfactor     = fabsf( rect.size.height / coverage.size.height);
         if( hfactor > vfactor)
         {
            factor    = hfactor;
            maxFactor = vfactor;
            binSearch = 1;
         }
         else
            factor = vfactor;
         break;
      }

      // change fontSize and recalc boundaries
      // a problem, is that internally fontsize is an integer divided by 10
      // so we can't get more precision
      if( factor != 1.0f)
      {
         fontSize = REFERENCE_FONTSIZE * maxFactor;
         if( binSearch)
            fontSize = mvgSearchFontSizeForTextFittingWidth( vg, s, length, fontSize, rect.size.width);
         fontSize = mvgFontSize( vg, fontSize);

         nvgTextMetrics( vg, &ascender, NULL, &lineHeight);
         if( options & CGTextOptionAlignVisually)
         {
            vbounds            = mvgTextVisualBounds( vg, CGPointZero, s, length);
            coverage           = vbounds;
            coverage.origin.y += ascender;
         }
         else
         {
            coverage = CGRectMake( 0, 0, rect.size.width, lineHeight);
         }
      }

      coverage = CGSizePlaceInRect( coverage.size, rect, contentMode);
      result   = CGTextBoundsInfoMake( coverage, fontSize);
   }
   while( 0);
   mvgRestore( vg);

   return( result);
}



// why is that not a CGContext function ?
// Because we are taking part in the implicit states of nvg, like textColor,
// fontID etc.
//
// will envgFontSize
static void   mvgTextInRect( struct NVGcontext *vg,
                             char *s,
                             size_t length,
                             CGRect rect,
                             CGContentMode contentMode,
                             CGTextOptions options)
{
   CGPoint               origin;
   float                 ascender;
   float                 descender;
   CGTextBoundsInfo  info;
   if( ! vg || ! s)
      return;

   if( length == (size_t) -1)
      length = strlen( s);
   // this will change
   info     = _mvgComputeTextRect( vg, s, length, rect, contentMode, options);
   if( CGRectIsNull( info.bounds))
      return;

   mvgSave( vg);
   {
      origin = info.bounds.origin;

      nvgTextAlign( vg, NVG_ALIGN_LEFT | NVG_ALIGN_TOP);
      if( ! isnan( info.size))
         nvgFontSize( vg, info.size);

      if( options & CGTextOptionAlignBaseline)
      {
         nvgTextMetrics( vg, &ascender, &descender, NULL);

         switch( contentMode)
         {
         case CGContentModeTopLeft     :
         case CGContentModeTop         :
         case CGContentModeTopRight    : origin.y -= ascender; break;

         case CGContentModeLeft        :
         case CGContentModeCenter :
         case CGContentModeRight       : origin.y = CGRectGetMidY( rect) - ascender; break;

         case CGContentModeBottomLeft  :
         case CGContentModeBottom      :
         case CGContentModeBottomRight : origin.y -= descender; break;
         }
      }

      if( ! (options & CGTextOptionNoClip))
         mvgScissor( vg, rect); // CGRectIntegral( rect));
      mvgText( vg, origin, s, length);
   }
   mvgRestore( vg);
}


static CGPoint   _mvgTLAdjustmentForVisualBounds( struct NVGcontext *vg,
                                                  char *s,
                                                  size_t length,
                                                  int alignment,
                                                  CGTextOptions options)
{
   int       halign;
   int       valign;
   float     ascender;
   float     lineh;
   float     bounds[ 6];
   CGRect    coverage;
   CGPoint   adjust;

   adjust = CGPointZero;
   if( ! s)
      return( adjust);

   if( length == (size_t) -1)
      length = strlen( s);
   if( ! length)
      return( adjust);

   halign = alignment & (NVG_ALIGN_LEFT | NVG_ALIGN_CENTER | NVG_ALIGN_RIGHT);
   valign = alignment & (NVG_ALIGN_BASELINE | NVG_ALIGN_TOP | NVG_ALIGN_MIDDLE | NVG_ALIGN_BOTTOM);

   // center, right is broken so do we always draw LEFT/TOP and calculate
   // for ourselves
   nvgTextAlign( vg, NVG_ALIGN_LEFT | NVG_ALIGN_TOP);
   nvgTextVisualBounds( vg, 0, 0, s, &s[ length], bounds);

   if( options & CGTextOptionAlignVisually)
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

   if( options & CGTextOptionAlignVisually)
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
   case NVG_ALIGN_LEFT        : break;
   case NVG_ALIGN_CENTER      : adjust.x -= (coverage.size.width / 2.0); break;
   case NVG_ALIGN_RIGHT       : adjust.x -= coverage.size.width; break;
   }

   return( adjust);
}


static void   _mvgExtendedAlignedText( struct NVGcontext *vg,
                                       char *s,
                                       size_t length,
                                       CGPoint origin,
                                       int alignment,
                                       CGTextOptions options)
{
   CGPoint   adjust;

   mvgAssertFont( vg);

   if( s)
   {
      if( length == (size_t) -1)
         length = strlen( s);

      adjust = _mvgTLAdjustmentForVisualBounds( vg, s, length, alignment, options);

      // already done by _mvgAdjustmentForVisualBounds
      // nvgTextAlign( vg, NVG_ALIGN_LEFT | NVG_ALIGN_TOP);
      nvgText( vg, origin.x + adjust.x, origin.y + adjust.y, s, &s[ length]);
   }

   // make state expected
   nvgTextAlign( vg, alignment);
}



//\\\\\\ former microvg

CGPoint   CGContextTLAdjustmentForVisualBounds( CGLayoutContext *context,
                                                char *s,
                                                size_t length,
                                                int alignment,
                                                CGTextOptions options)
{
   if( context && s)
      return _mvgTLAdjustmentForVisualBounds( CGLayoutContextGetNVGContext( context),
                                              s,
                                              length,
                                              alignment,
                                              options);
   return CGPointZero;
}


// Fill rounded shadow
void CGContextFillRoundedShadow( CGContext *context,
                                 CGRect rect,
                                 CGFloat cornerRadius,
                                 struct CGShadow *shadow)
{
   if( context)
      mvgFillRoundedShadow( CGContextGetNVGContext(context),
                            rect,
                            cornerRadius,
                            shadow);
}




// Extended aligned text
void   CGContextExtendedAlignedText( CGContext *context,
                                     char *s,
                                     size_t length,
                                     CGPoint origin,
                                     int alignment,
                                     CGTextOptions options)
{
   if( context)
      mvgExtendedAlignedText( CGContextGetNVGContext(context),
                              s,
                              length,
                              origin,
                              alignment,
                              options);
}


// Extended aligned text (internal implementation)
void   CGContext_ExtendedAlignedText( CGContext *context,
                                      char *s,
                                      size_t length,
                                      CGPoint origin,
                                      int alignment,
                                      CGTextOptions
                                      options)
{
   if( context)
      _mvgExtendedAlignedText( CGContextGetNVGContext( context),
                               s,
                               length,
                               origin,
                               alignment,
                               options);
}


CGTextBoundsInfo   CGContextTextBoundsOptions( CGContext *context,
                                                       char *s,
                                                       size_t length,
                                                       CGRect rect,
                                                       CGContentMode contentMode,
                                                       CGTextOptions options)
{
   if( ! context || ! s)
      return( CGTextBoundsInfoNull);

   if( length == (size_t) -1)
      length = strlen( s);

   return( _mvgComputeTextRect( CGContextGetNVGContext( context),
                                s, length,
                                rect,
                                contentMode,
                                options));
}

// Draw text inside a rect
void   CGContextTextInRect( CGContext *context,
                            char *s,
                            size_t length,
                            CGRect rect,
                            CGContentMode contentMode,
                            CGTextOptions options)
{
   if( context)
      mvgTextInRect( CGContextGetNVGContext(context),
                     s,
                     length,
                     rect,
                     contentMode,
                     options);
}

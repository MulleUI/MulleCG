//
// CGContext+DrawingConveniences.m
// Pure CGContext convenience functions - no backend dependencies
//
#import "CGContext+DrawingConveniences.h"
#import "CGContext+Drawing.h"

#import "import-private.h"

#include <string.h>
#include <math.h>


void   CGContextFillWithColor( CGContext *context, CGColor color)
{
   CGContextFillColor( context, color);
   CGContextFill( context);
}


void   CGContextStrokeWithColor( CGContext *context,
                                 CGFloat strokeWidth,
                                 CGColor color)
{
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStrokeColor( context, color);
   CGContextStroke( context);
}


void   CGContextStrokeLineHWithColor( CGContext *context,
                                      CGPoint p,
                                      CGFloat w,
                                      CGFloat strokeWidth,
                                      CGColor color)
{
   CGContextBeginPath( context);
   CGContextMoveTo( context, p);
   CGContextLineTo( context, CGPointMake( p.x + w, p.y));
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStrokeColor( context, color);
   CGContextStroke( context);
}


void   CGContextStrokeLineVWithColor( CGContext *context,
                                      CGPoint p,
                                      CGFloat h,
                                      CGFloat strokeWidth,
                                      CGColor color)
{
   CGContextBeginPath( context);
   CGContextMoveTo( context, p);
   CGContextLineTo( context, CGPointMake( p.x, p.y + h));
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStrokeColor( context, color);
   CGContextStroke( context);
}


void   CGContextFillRoundedRectWithColor( CGContext *context,
                                          CGRect rect,
                                          CGFloat cornerRadius,
                                          CGColor color)
{
   CGContextBeginPath( context);
   CGContextRoundedRect( context, rect, cornerRadius);
   CGContextFillColor( context, color);
   CGContextFill( context);
}


void   CGContextFillRectWithColor( CGContext *context,
                                   CGRect rect,
                                   CGColor color)
{
   CGContextBeginPath( context);
   CGContextRect( context, rect);
   CGContextFillColor( context, color);
   CGContextFill( context);
}


void   CGContextFillCircleWithColor( CGContext *context,
                                     CACircle circle,
                                     CGColor color)
{
   CGContextBeginPath( context);
   CGContextCircle( context, circle);
   CGContextFillColor( context, color);
   CGContextFill( context);
}


void   CGContextStrokeRoundedRectWithColor( CGContext *context,
                                            CGRect rect,
                                            CGFloat cornerRadius,
                                            CGFloat strokeWidth,
                                            CGColor color)
{
   CGContextBeginPath( context);
   CGContextRoundedRect( context, rect, cornerRadius);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStrokeColor( context, color);
   CGContextStroke( context);
}


void   CGContextStrokeInsideOfRoundedRectWithColor( CGContext *context,
                                                    CGRect rect,
                                                    CGFloat cornerRadius,
                                                    CGFloat strokeWidth,
                                                    CGColor color)
{
   CGRect   insetRect;

   insetRect = CGRectInset( rect, strokeWidth / 2.0, strokeWidth / 2.0);
   CGContextBeginPath( context);
   CGContextRoundedRect( context, insetRect, cornerRadius);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStrokeColor( context, color);
   CGContextStroke( context);
}


void   CGContextStrokeRectWithColor( CGContext *context,
                                     CGRect rect,
                                     CGFloat strokeWidth,
                                     CGColor color)
{
   CGContextBeginPath( context);
   CGContextRect( context, rect);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStrokeColor( context, color);
   CGContextStroke( context);
}


void   CGContextStrokeInsideOfRectWithColor( CGContext *context,
                                             CGRect rect,
                                             CGFloat strokeWidth,
                                             CGColor color)
{
   CGRect   insetRect;

   insetRect = CGRectInset( rect, strokeWidth / 2.0, strokeWidth / 2.0);
   CGContextBeginPath( context);
   CGContextRect( context, insetRect);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStrokeColor( context, color);
   CGContextStroke( context);
}


void   CGContextStrokeCircleWithColor( CGContext *context,
                                       CACircle circle,
                                       CGFloat strokeWidth,
                                       CGColor color)
{
   CGContextBeginPath( context);
   CGContextCircle( context, circle);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStrokeColor( context, color);
   CGContextStroke( context);
}


void   CGContextStrokeLineWithColor( CGContext *context,
                                     CGPoint start,
                                     CGPoint end,
                                     CGFloat strokeWidth,
                                     CGColor color)
{
   CGContextBeginPath( context);
   CGContextMoveTo( context, start);
   CGContextLineTo( context, end);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStrokeColor( context, color);
   CGContextStroke( context);
}


void   CGContextFillCircleWithGradientColors( CGContext *context,
                                              CACircle circle,
                                              CGColor outerColor,
                                              CGColor innerColor)
{
   CGContextBeginPath( context);
   CGContextCircle( context, circle);
   CGContextSetFillRadialGradient( context, circle, outerColor, 0, innerColor);
   CGContextFill( context);
}


void   CGContextStrokeCircleWithGradientColors( CGContext *context,
                                                CACircle circle,
                                                CGColor outerColor,
                                                CGColor innerColor,
                                                CGFloat strokeWidth)
{
   CGContextBeginPath( context);
   CGContextCircle( context, circle);
   CGContextSetStrokeRadialGradient( context, circle, outerColor, 0, innerColor);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}


static struct CGShadow   defaultShadow = CGShadowDefaultValues;


void   CGContextFillRoundedShadow( CGContext *context,
                                   CGRect rect,
                                   CGFloat cornerRadius,
                                   struct CGShadow *shadow)
{
   CGRect    shadowRect;
   CGRect    gradientRect;
   CGFloat   feather;

   if( ! context)
      return;

   shadow       = shadow ? shadow : &defaultShadow;
   feather      = shadow->blur;
   gradientRect = CGRectExtrude( rect, feather / 2.0, feather / 2.0);

   CGContextSetFillBoxGradient( context,
                                gradientRect,
                                cornerRadius,
                                shadow->innerColor,
                                feather,
                                shadow->outerColor);

   shadowRect = CGRectExtrude( rect, feather * 2, feather * 2);
   CGContextBeginPath( context);
   CGContextRoundedRect( context, shadowRect, cornerRadius);
   if( shadow->hole)
   {
      CGContextRoundedRect( context, rect, cornerRadius);
      CGContextPathWinding( context, CGPathFillStyleHole);
   }
   CGContextFill( context);
}


static CGTextBoundsInfo   _computeTextRect( CGContext *context,
                                            char *s,
                                            size_t length,
                                            CGRect rect,
                                            CGContentMode contentMode,
                                            CGTextOptions options)
{
   CGContentMode      fillContentMode;
   CGFloat            factor;
   CGFloat            hfactor;
   CGFloat            maxFactor;
   CGFloat            vfactor;
   CGRect             coverage;
   CGRect             vbounds;
   CGTextBoundsInfo   result;
   CGTextMetrics      metrics;
   float              fontSize;

   assert( s);
   assert( length != (size_t) -1);

   result = CGTextBoundsInfoNull;

   if( rect.size.width < 1.0 || rect.size.height < 1.0)
      return( result);

   CGContextSave( context);
   do
   {
      CGContextCombinedTextAlignment( context, CGTextAlignLeft | CGTextAlignTop);

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
         CGContextFontSize( context, 100.0f);
         break;

      default :
         break;
      }

      if( options & CGTextOptionAlignVisually)
         coverage = CGContextTextVisualBounds( context, CGPointZero, s, length);
      else
         coverage = CGContextTextBoundsInfo( context, CGPointZero, s, length).bounds;

      // binSearch  = 0;
      factor     = 1.0;
      maxFactor  = 1.0;
      fontSize   = NAN;

      switch( contentMode)
      {
      case CGContentModeScaleToFill     :
         contentMode = fillContentMode;
         hfactor     = fabsf( rect.size.width / coverage.size.width);
         vfactor     = fabsf( rect.size.height / coverage.size.height);
         if( hfactor > vfactor)
         {
            factor    = hfactor;
            maxFactor = vfactor;
            // binSearch = 1;
         }
         else
            factor = vfactor;
         break;

      case CGContentModeScaleAspectFit :
         contentMode = CGContentModeCenterPoint;
         hfactor     = fabsf( rect.size.width / coverage.size.width);
         vfactor     = fabsf( rect.size.height / coverage.size.height);
         if( hfactor < vfactor)
         {
            factor    = hfactor;
            maxFactor = vfactor;
            // binSearch = 1;
         }
         else
            factor = vfactor;
         break;

      case CGContentModeScaleAspectFill  :
         contentMode = CGContentModeCenterPoint;
         hfactor     = fabsf( rect.size.width / coverage.size.width);
         vfactor     = fabsf( rect.size.height / coverage.size.height);
         if( hfactor > vfactor)
         {
            factor    = hfactor;
            maxFactor = vfactor;
            // binSearch = 1;
         }
         else
            factor = vfactor;
         break;
      }

      if( factor != 1.0f)
      {
         fontSize = 100.0f * factor;
         // TODO: binary search for font size fitting width if binSearch
         CGContextFontSize( context, fontSize);

         metrics = CGContextTextMetrics( context);
         if( options & CGTextOptionAlignVisually)
         {
            vbounds            = CGContextTextVisualBounds( context, CGPointZero, s, length);
            coverage           = vbounds;
         }
         else
         {
            coverage = CGRectMake( 0, 0, rect.size.width, metrics.lineHeight);
         }
      }

      result    = CGTextBoundsInfoMake( coverage, fontSize);
   }
   while( 0);
   CGContextRestore( context);

   return( result);
}


void   CGContextTextInRect( CGContext *context,
                            char *s,
                            size_t length,
                            CGRect rect,
                            CGContentMode contentMode,
                            CGTextOptions options)
{
   CGPoint            origin;
   CGTextBoundsInfo   info;
   CGTextMetrics      metrics;

   if( ! context || ! s)
      return;

   if( length == (size_t) -1)
      length = strlen( s);

   info = _computeTextRect( context, s, length, rect, contentMode, options);
   if( CGRectIsNull( info.bounds))
      return;

   CGContextSave( context);
   {
      origin    = CGSizePlaceInRect( info.bounds.size, rect, contentMode).origin;
      origin.x -= info.bounds.origin.x;
      origin.y -= info.bounds.origin.y;

      CGContextCombinedTextAlignment( context, CGTextAlignLeft | CGTextAlignTop);
      if( ! isnan( info.size))
         CGContextFontSize( context, info.size);

      if( options & CGTextOptionAlignBaseline)
      {
         metrics = CGContextTextMetrics( context);

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

      if( ! (options & CGTextOptionNoClip))
         CGContextScissor( context, rect);
      CGContextText( context, origin, s, length);
   }
   CGContextRestore( context);
}


static CGPoint   _tlAdjustmentForVisualBounds( CGContext *context,
                                               char *s,
                                               size_t length,
                                               int alignment,
                                               CGTextOptions options)
{
   CGPoint       adjust;
   CGRect        coverage;
   CGTextMetrics metrics;
   CGFloat       lineh;
   int           halign;
   int           valign;

   adjust = CGPointZero;
   if( ! s)
      return( adjust);

   if( length == (size_t) -1)
      length = strlen( s);
   if( ! length)
      return( adjust);

   halign = alignment & (CGTextAlignLeft | CGTextAlignCenter | CGTextAlignRight);
   valign = alignment & (CGTextAlignBaseline | CGTextAlignTop | CGTextAlignMiddle | CGTextAlignBottom);

   CGContextCombinedTextAlignment( context, CGTextAlignLeft | CGTextAlignTop);

   if( options & CGTextOptionAlignVisually)
      coverage = CGContextTextVisualBounds( context, CGPointZero, s, length);
   else
   {
      CGTextBoundsInfo   boundsInfo;

      boundsInfo = CGContextTextBoundsInfo( context, CGPointZero, s, length);
      coverage   = boundsInfo.bounds;
   }

   metrics = CGContextTextMetrics( context);
   lineh   = metrics.lineHeight;

   if( options & CGTextOptionAlignVisually)
   {
      switch( valign)
      {
      case CGTextAlignTop      : adjust.y += -CGRectGetMinY( coverage); break;
      case CGTextAlignMiddle   : adjust.y += -CGRectGetMinY( coverage) - (coverage.size.height / 2.0);
                                 break;
      case CGTextAlignBottom   : adjust.y += -CGRectGetMinY( coverage) - coverage.size.height; break;
      case CGTextAlignBaseline : adjust.y += -CGRectGetMinY( coverage) + metrics.ascender;
                                 break;
      }
   }
   else
   {
      switch( valign)
      {
      case CGTextAlignTop      : break;
      case CGTextAlignMiddle   : adjust.y -= lineh / 2.0; break;
      case CGTextAlignBottom   : adjust.y -= lineh; break;
      case CGTextAlignBaseline : adjust.y -= metrics.ascender; break;
      }
   }

   switch( halign)
   {
   case CGTextAlignLeft   : break;
   case CGTextAlignCenter : adjust.x -= (coverage.size.width / 2.0); break;
   case CGTextAlignRight  : adjust.x -= coverage.size.width; break;
   }

   return( adjust);
}


CGPoint   CGContextTLAdjustmentForVisualBounds( CGLayoutContext *context,
                                                char *s,
                                                size_t length,
                                                int alignment,
                                                CGTextOptions options)
{
   if( context && s)
      return( _tlAdjustmentForVisualBounds( (CGContext *) context,
                                            s,
                                            length,
                                            alignment,
                                            options));
   return( CGPointZero);
}


static void   _extendedAlignedText( CGContext *context,
                                    char *s,
                                    size_t length,
                                    CGPoint origin,
                                    int alignment,
                                    CGTextOptions options)
{
   CGPoint   adjust;

   if( s)
   {
      if( length == (size_t) -1)
         length = strlen( s);

      adjust = _tlAdjustmentForVisualBounds( context, s, length, alignment, options);
      CGContextText( context, CGPointMake( origin.x + adjust.x, origin.y + adjust.y), s, length);
   }

   CGContextCombinedTextAlignment( context, alignment);
}


void   CGContextExtendedAlignedText( CGContext *context,
                                     char *s,
                                     size_t length,
                                     CGPoint origin,
                                     int alignment,
                                     CGTextOptions options)
{
   int   halign;

   if( ! context)
      return;

   halign = alignment & (CGTextAlignLeft | CGTextAlignCenter | CGTextAlignRight);
   if( halign != CGTextAlignLeft || (options & CGTextOptionAlignVisually))
   {
      CGContextCombinedTextAlignment( context, alignment);
      CGContextText( context, origin, s, length);
   }
   else
   {
      _extendedAlignedText( context, s, length, origin, alignment, options);
   }
}


void   CGContext_ExtendedAlignedText( CGContext *context,
                                     char *s,
                                     size_t length,
                                     CGPoint origin,
                                     int alignment,
                                     CGTextOptions options)
{
   if( context)
      _extendedAlignedText( context, s, length, origin, alignment, options);
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

   return( _computeTextRect( context, s, length, rect, contentMode, options));
}


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
     CGContextTextInRect( context, s, len, rect, contentMode, options);
   }
   va_end( args);
}


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
     CGContextText( context, point, s, len);
   }
   va_end( args);
}

//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#include "CGTypes.h"
#include "CGFunctionTable.h"
#include "CGFontFunctionTable.h"
#include "CGBackendFunctionTable.h"
#import "CGContextBase.h"
#import "CGContext.h"
#import "CGLayoutContext.h"

// Dispatch a drawing call through the function table.
// Works for CGContext *, CGLayoutContext *, CGContextBase * — all cast to CGContext.
// _cgBackend lives in CGContext, so we use @defs(CGContext) for direct struct access.
#define CGContextVG( ctx)        (((struct{ @defs( CGContext); } *)(ctx))->_cgBackend.context)
#define CGContextFN( ctx)        (&((struct{ @defs( CGContext); } *)(ctx))->_cgBackend.functions)
#define CGContextBFN( ctx)       (&((struct{ @defs( CGContext); } *)(ctx))->_cgBackend.backendFunctions)
// Font context and function table for CGLayoutContext font/measurement operations
// These use @defs(CGLayoutContext) and are safe for both CGLayoutContext and CGContext objects.
#define CGContextFontVG( ctx)    (((struct{ @defs( CGLayoutContext); } *)(ctx))->_fontContext)
#define CGContextFontFN( ctx)    (&((struct{ @defs( CGLayoutContext); } *)(ctx))->_fontFunctions)


// ###
// Functions that forward to the backend via function table
// ###

static inline void   CGContextBeginFrame( CGContext *context, CGSize windowSize, CGFloat devicePixelRatio)
{
   if( context)
      CGContextFN(context)->beginFrame( CGContextVG(context), windowSize, devicePixelRatio);
}

static inline void   CGContextCancelFrame( CGContext *context)
{
   if( context)
      CGContextFN(context)->cancelFrame( CGContextVG(context));
}

static inline void   CGContextEndFrame( CGContext *context)
{
   if( context)
      CGContextFN(context)->endFrame( CGContextVG(context));
}

static inline void   CGContextGlobalCompositeOperation( CGContext *context, NSInteger op)
{
   if( context)
      CGContextFN(context)->globalCompositeOperation( CGContextVG(context), op);
}

static inline void   CGContextGlobalCompositeBlendFunc( CGContext *context,
                                                        NSUInteger sfactor,
                                                        NSUInteger dfactor)
{
   if( context)
      CGContextFN(context)->globalCompositeBlendFunc( CGContextVG(context), sfactor, dfactor);
}


static inline void   CGContextGlobalCompositeBlendFuncSeparate( CGContext *context,
                                                                NSUInteger srcRGB,
                                                                NSUInteger dstRGB,
                                                                NSUInteger srcAlpha,
                                                                NSUInteger dstAlpha)
{
   if( context)
      CGContextFN(context)->globalCompositeBlendFuncSeparate( CGContextVG(context),
                                           srcRGB, dstRGB, srcAlpha, dstAlpha);
}


static inline void   CGLayoutContextSave( CGLayoutContext *context)
{
   void   *fontVG;

   if( ! context)
      return;
   fontVG = CGContextFontVG( context);
   if( fontVG)
      CGContextFontFN( context)->save( fontVG);
}


static inline void   CGLayoutContextRestore( CGLayoutContext *context)
{
   void   *fontVG;

   if( ! context)
      return;
   fontVG = CGContextFontVG( context);
   if( fontVG)
      CGContextFontFN( context)->restore( fontVG);
}


static inline void   CGLayoutContextReset( CGLayoutContext *context)
{
   void   *fontVG;

   if( ! context)
      return;
   fontVG = CGContextFontVG( context);
   if( fontVG && CGContextFontFN( context)->reset)
      CGContextFontFN( context)->reset( fontVG);
}


static inline void   CGContextSave( CGContext *context)
{
   void   *fontVG;
   void   *drawVG;

   if( ! context)
      return;
   fontVG = CGContextFontVG( context);
   if( fontVG)
      CGContextFontFN( context)->save( fontVG);
   // Draw save only when there is a separate draw backend (CGContext with distinct vg)
   drawVG = CGContextVG( context);
   if( drawVG != fontVG && drawVG)
      CGContextFN( context)->save( drawVG);
}


static inline void   CGContextRestore( CGContext *context)
{
   void   *fontVG;
   void   *drawVG;

   if( ! context)
      return;

   fontVG = CGContextFontVG( context);
   if( fontVG)
      CGContextFontFN( context)->restore( fontVG);
   drawVG = CGContextVG( context);
   if( drawVG != fontVG && drawVG)
      CGContextFN( context)->restore( drawVG);
}


static inline void   CGContextReset( CGContext *context)
{
   void   *fontVG;
   void   *drawVG;

   if( ! context)
      return;
   fontVG = CGContextFontVG( context);
   if( fontVG && CGContextFontFN( context)->reset)
      CGContextFontFN( context)->reset( fontVG);
   drawVG = CGContextVG( context);
   if( drawVG && drawVG != fontVG && CGContextFN( context)->reset)
      CGContextFN( context)->reset( drawVG);
}


static inline void   CGContextShapeAntiAlias( CGContext *context, BOOL enable)
{
   if( context)
      CGContextFN(context)->shapeAntiAlias( CGContextVG(context), enable);
}

static inline void   CGContextBezierTessellation( CGContext *context, CGTessellation mode)
{
   if( context)
      CGContextFN(context)->bezierTessellation( CGContextVG(context), mode);
}

static inline void   CGContextStrokeColor( CGContext *context, CGColor color)
{
   if( context)
      CGContextFN(context)->strokeColor( CGContextVG(context), color);
}

static inline void   CGContextFillColor( CGContext *context, CGColor color)
{
   if( context)
      CGContextFN(context)->fillColor( CGContextVG(context), color);
}

static inline void   CGContextMiterLimit( CGContext *context, CGFloat limit)
{
   if( context)
      CGContextFN(context)->miterLimit( CGContextVG(context), limit);
}

static inline void   CGContextStrokeWidth( CGContext *context, CGFloat size)
{
   if( context)
      CGContextFN(context)->strokeWidth( CGContextVG(context), size);
}

static inline void   CGContextLineCap( CGContext *context, NSInteger cap)
{
   if( context)
      CGContextFN(context)->lineCap( CGContextVG(context), cap);
}

static inline void   CGContextLineJoin( CGContext *context, NSInteger join)
{
   if( context)
      CGContextFN(context)->lineJoin( CGContextVG(context), join);
}

static inline void   CGContextGlobalAlpha( CGContext *context, CGFloat alpha)
{
   if( context)
      CGContextFN(context)->globalAlpha( CGContextVG(context), alpha);
}

static inline void   CGContextResetTransform( CGLayoutContext *context)
{
   if( context)
      CGContextFN(context)->resetTransform( CGContextVG(context));
}

static inline void   CGContextTransform( CGLayoutContext *context,
                                         CGAffineTransform *xform)
{
   if( context)
      CGContextFN(context)->transform( CGContextVG(context), xform);
}

static inline void   CGContextTranslate( CGContext *context, CGPoint p)
{
   if( context)
      CGContextFN(context)->translate( CGContextVG(context), p);
}

static inline void   CGContextRotate( CGContext *context, CARotation rotation)
{
   if( context)
      CGContextFN(context)->rotate( CGContextVG(context), rotation);
}

static inline void   CGContextSkewX( CGContext *context, CAAngle angle)
{
   if( context)
      CGContextFN(context)->skewX( CGContextVG(context), angle);
}

static inline void   CGContextSkewY( CGContext *context, CAAngle angle)
{
   if( context)
      CGContextFN(context)->skewY( CGContextVG(context), angle);
}

static inline void   CGContextScale( CGContext *context, CGVector v)
{
   if( context)
      CGContextFN(context)->scale( CGContextVG(context), v);
}

static inline CGAffineTransform   CGContextCurrentTransform( CGContext *context)
{
   if( context)
      return( CGContextFN(context)->currentTransform( CGContextVG(context)));
   return( CGAffineTransformMakeIdentityInline());
}

static inline CGTextureID CGContextCreateImage( CGContext *context,
                                                char *filename,
                                                NSUInteger textureFlags)
{
   if( context)
      return CGContextFN(context)->createImage( CGContextVG(context), filename, textureFlags);
   return CGTextureIDInvalid;
}

static inline CGTextureID   CGContextCreateImageMem( CGContext *context,
                                                     NSInteger textureFlags,
                                                     void *data,
                                                     size_t ndata)
{
   if( context)
      return CGContextFN(context)->createImageMem( CGContextVG(context), textureFlags, data, ndata);
   return CGTextureIDInvalid;
}

static inline CGTextureID CGContextCreateImageRGBA( CGContext *context,
                                                    struct CGPixelSize size,
                                                    NSUInteger textureFlags,
                                                    void *data)
{
   if( context)
      return CGContextFN(context)->createImageRGBA( CGContextVG(context),
                                 size.width,
                                 size.height,
                                 textureFlags,
                                 data);
   return( CGTextureIDInvalid);
}

static inline void   CGContextUpdateImage( CGContext *context, CGTextureID image, void *data)
{
   if( context)
      CGContextFN(context)->updateImage( CGContextVG(context), image, data);
}

static inline CGPixelSize CGContextImageSize( CGContext *context, CGTextureID image)
{
   if( context)
      return CGContextFN(context)->imageSize( CGContextVG(context), image);
   return( CGPixelSizeZero);
}

static inline void   CGContextDeleteImage( CGContext *context, CGTextureID image)
{
   if( context)
      CGContextFN(context)->deleteImage( CGContextVG(context), image);
}

static inline void   CGContextScissor( CGContext *context, CGRect rect)
{
   if( context)
      CGContextFN(context)->scissor( CGContextVG(context), rect);
}

static inline void   CGContextIntersectScissor( CGContext *context, CGRect rect)
{
   if( context)
      CGContextFN(context)->intersectScissor( CGContextVG(context), rect);
}

static inline void   CGContextResetScissor( CGContext *context)
{
   if( context)
      CGContextFN(context)->resetScissor( CGContextVG(context));
}

static inline void   CGContextBeginPath( CGContext *context)
{
   if( context)
      CGContextFN(context)->beginPath( CGContextVG(context));
}

static inline void   CGContextMoveTo( CGContext *context, CGPoint point)
{
   if( context)
      CGContextFN(context)->moveTo( CGContextVG(context), point);
}

static inline void   CGContextLineTo( CGContext *context, CGPoint point)
{
   if( context)
      CGContextFN(context)->lineTo( CGContextVG(context), point);
}

static inline void   CGContextBezierTo( CGContext *context, CGPoint control1, CGPoint control2, CGPoint point)
{
   if( context)
      CGContextFN(context)->bezierTo( CGContextVG(context), control1, control2, point);
}

static inline void   CGContextQuadTo( CGContext *context, CGPoint control, CGPoint point)
{
   if( context)
      CGContextFN(context)->quadTo( CGContextVG(context), control, point);
}

static inline void   CGContextArcTo( CGContext *context, CGPoint tangent1, CGPoint tangent2, CGFloat radius)
{
   if( context)
      CGContextFN(context)->arcTo( CGContextVG(context), tangent1, tangent2, radius);
}

static inline void   CGContextClosePath( CGContext *context)
{
   if( context)
      CGContextFN(context)->closePath( CGContextVG(context));
}

static inline void   CGContextPathWinding( CGContext *context,
                                           CGPathFillStyle style)
{
   if( context)
   {
      CGContextFN(context)->pathWinding( CGContextVG(context), style);
   }
}

static inline void   CGContextArc( CGContext *context,
                                   CACircle circle,
                                   CAAngle angle,
                                   CARotation rotation)
{
   if( context)
   {
      CGContextFN(context)->arc( CGContextVG(context), circle, angle, rotation);
   }
}

// Draw arc from startAngle to endAngle in the given direction.
// This is the natural two-angle form: no manual rotation calculation needed.
// Uses arcRadians directly to avoid precision loss from rotation round-trip.
static inline void   CGContextArcFromAngleToAngle( CGContext *context,
                                                   CACircle circle,
                                                   CAAngle startAngle,
                                                   CAAngle endAngle,
                                                   CARotationDirection dir)
{
   if( context)
      CGContextFN(context)->arcRadians( CGContextVG(context), circle,
                                        CAAngleToRadians( startAngle),
                                        CAAngleToRadians( endAngle),
                                        dir);
}

// hackish for old demos that pass raw radians
static inline void   CGContextArcRadians( CGContext *context,
                                          CACircle circle,
                                          CGFloat radians1,
                                          CGFloat radians2,
                                          CARotationDirection dir)
{
   if( context)
   {
      CGContextFN(context)->arcRadians( CGContextVG(context), circle, radians1, radians2, dir);
   }
}

static inline void   CGContextRect( CGContext *context, CGRect rect)
{
   if( context)
      CGContextFN(context)->rect( CGContextVG(context), rect);
}

static inline void   CGContextRoundedRectVarying( CGContext *context, CGRect rect, struct MulleCornerInsets insets)
{
   if( context)
      CGContextFN(context)->roundedRectVarying( CGContextVG(context), rect, insets);
}

static inline void   CGContextRoundedRect( CGContext *context, CGRect rect, CGFloat r)
{
   if( context)
      CGContextFN(context)->roundedRect( CGContextVG(context), rect, r);
}

static inline void   CGContextEllipse( CGContext *context, CGPoint center, CGFloat rx, CGFloat ry)
{
   if( context)
      CGContextFN(context)->ellipse( CGContextVG(context), center, rx, ry);
}

// circle is just ellipse with equal radii — no vtable entry needed
static inline void   CGContextCircle( CGContext *context, CACircle circle)
{
   if( context)
      CGContextFN(context)->ellipse( CGContextVG(context),
                                     CACircleGetCenter( circle),
                                     CACircleGetRadius( circle),
                                     CACircleGetRadius( circle));
}

static inline void   CGContextFill( CGContext *context)
{
   if( context)
      CGContextFN(context)->fill( CGContextVG(context));
}

static inline void   CGContextStroke( CGContext *context)
{
   if( context)
      CGContextFN(context)->stroke( CGContextVG(context));
}


// ***
// Begin of CGLayoutContext
// ***

static inline CGFontID CGContextCreateFont( CGLayoutContext *context, char *name, char *filename)
{
   if( context)
      return CGContextFontFN(context)->createFont( CGContextFontVG(context), name, filename);
   return( CGFontIDInvalid);
}

static inline CGFontID CGContextCreateFontMem( CGLayoutContext *context, char *name, void *data, size_t length, BOOL freeData)
{
   if( context)
      return CGContextFontFN(context)->createFontMem( CGContextFontVG(context), name, data, length, freeData);
   return( CGFontIDInvalid);
}

static inline CGFontID CGContextFindFont( CGLayoutContext *context, char *name)
{
   if( context)
      return CGContextFontFN(context)->findFont( CGContextFontVG(context), name);
   return( CGFontIDInvalid);
}

static inline CGFontID CGContextAddFallbackFontId( CGLayoutContext *context, CGFontID baseFont, CGFontID fallbackFont)
{
   if( context)
      return CGContextFontFN(context)->addFallbackFontId( CGContextFontVG(context), baseFont, fallbackFont);
   return( CGFontIDInvalid);
}

static inline CGFontID CGContextAddFallbackFont( CGLayoutContext *context, char *baseFont, char *fallbackFont)
{
   if( context)
      return CGContextFontFN(context)->addFallbackFont( CGContextFontVG(context), baseFont, fallbackFont);
   return( CGFontIDInvalid);
}

static inline void   CGContextResetFallbackFontsId( CGLayoutContext *context, NSInteger baseFont)
{
   if( context)
      CGContextFontFN(context)->resetFallbackFontsId( CGContextFontVG(context), baseFont);
}

static inline void   CGContextResetFallbackFonts( CGLayoutContext *context, char *baseFont)
{
   if( context)
      CGContextFontFN(context)->resetFallbackFonts( CGContextFontVG(context), baseFont);
}

static inline void   CGContextFontSize( CGLayoutContext *context, CGFloat size)
{
   if( context)
      CGContextFontFN(context)->fontSize( CGContextFontVG(context), size);
}

static inline void   CGContextFontBlur( CGLayoutContext *context, CGFloat blur)
{
   if( context)
      CGContextFontFN(context)->fontBlur( CGContextFontVG(context), blur);
}

static inline void   CGContextTextLetterSpacing( CGLayoutContext *context,
                                                 CGFloat spacing)
{
   if( context)
      CGContextFontFN(context)->textLetterSpacing( CGContextFontVG(context), spacing);
}

static inline void   CGContextTextLineHeight( CGLayoutContext *context,
                                              CGFloat lineHeight)
{
   if( context)
      CGContextFontFN(context)->textLineHeight( CGContextFontVG(context), lineHeight);
}

static inline void   CGContextCombinedTextAlignment( CGLayoutContext *context,
                                                CGCombinedTextAlign align)
{
   if( context)
      CGContextFontFN(context)->textAlign( CGContextFontVG(context), align);
}

static inline void   CGContextTextAlignment( CGLayoutContext *context,
                                             UITextAlignment alignment)
{
   CGCombinedTextAlign   align;

   if( ! context)
      return;

   switch( alignment)
   {
   default                    : align = CGTextAlignLeft   | CGTextAlignBaseline; break;
   case UITextAlignmentRight  : align = CGTextAlignRight  | CGTextAlignBaseline; break;
   case UITextAlignmentCenter : align = CGTextAlignCenter | CGTextAlignBaseline; break;
   }
   CGContextFontFN(context)->textAlign( CGContextFontVG(context), align);
}

static inline void   CGContextFontFaceId( CGLayoutContext *context, CGFontID fontID)
{
   if( context)
      CGContextFontFN(context)->fontFaceId( CGContextFontVG(context), fontID);
}

static inline void   CGContextClearType( CGLayoutContext *context, BOOL enable)
{
   if( context)
      CGContextFontFN(context)->clearType( CGContextFontVG(context), enable);
}

static inline void   CGContextTextColor( CGLayoutContext *context, CGColor color)
{
   if( context)
      CGContextFontFN(context)->textColor( CGContextFontVG(context), color);
}

static inline void   CGContextTextBackgroundColor( CGLayoutContext *context, CGColor color)
{
   if( context)
      CGContextFontFN(context)->textBackgroundColor( CGContextFontVG(context), color);
}

static inline CGTextBoundsInfo   CGContextTextBoundsInfo( CGLayoutContext *context,
                                                          CGPoint point,
                                                          char *s,
                                                          size_t length)
{
   return( CGContextFontFN(context)->textBounds( CGContextFontVG(context), point, s, length));
}

static inline CGRect   CGContextTextVisualBounds( CGLayoutContext *context,
                                                  CGPoint point,
                                                  char *s,
                                                  size_t length)
{
   CGRect   vbounds = CGRectNull;

   if( context)
      vbounds = CGContextFontFN(context)->textVisualBounds( CGContextFontVG(context), point, s, length);
   return( vbounds);
}

static inline CGRect   CGContextTextBoxBounds( CGLayoutContext *context,
                                               CGPoint point,
                                               char *s,
                                               size_t length,
                                               CGFloat breakRowWidth)
{
   CGRect   bbox = CGRectNull;

   if( context)
      CGContextFontFN(context)->textBoxBounds( CGContextFontVG(context), point, s, length, breakRowWidth, &bbox);
   return( bbox);
}

static inline NSUInteger   CGContextTextGlyphPositions( CGLayoutContext *context,
                                                        CGPoint point,
                                                        char *s,
                                                        size_t length,
                                                        struct UIGlyphPosition *positions,
                                                        NSInteger maxPositions)
{
   if( ! context)
      return 0;

   return( CGContextFontFN(context)->textGlyphPositions( CGContextFontVG(context),
                                  point,
                                  s,
                                  length,
                                  positions,
                                  maxPositions));
}

static inline NSUInteger   CGContextTextBreakLines( CGLayoutContext *context,
                                                    char *s,
                                                    size_t length,
                                                    CGFloat breakRowWidth,
                                                    struct UITextRow* rows,
                                                    NSInteger maxRows,
                                                    size_t UITextRowSize)
{
   if( ! context)
      return( 0);

   return( CGContextFontFN(context)->textBreakLines( CGContextFontVG(context), s, length, breakRowWidth, rows, maxRows, UITextRowSize));
}

static inline CGTextMetrics   CGContextTextMetrics( CGLayoutContext *context)
{
   CGTextMetrics   metrics = { 0 };

   if( context)
      metrics = CGContextFontFN(context)->textMetrics( CGContextFontVG(context));
   return( metrics);
}

static inline void   *CGContextGetFontHandle( CGLayoutContext* context, int font)
{
   if( context)
      return( CGContextFontFN(context)->getFontHandle( CGContextFontVG(context), font));
   return( NULL);
}

// ***
// End of CGLayoutContext
// ***


static inline CGFloat   CGContextText( CGContext *context,
                                       CGPoint point,
                                       char *s,
                                       size_t length)
{
   if( context && s)
      return( CGContextFontFN(context)->text( CGContextFontVG(context), point, s, length));
   return( 0.0);
}

static inline void   CGContextTextBox( CGContext *context,
                                       CGPoint point,
                                       CGFloat breakRowWidth,
                                       char *s,
                                       size_t length)
{
   if( context && s)
      CGContextFontFN(context)->textBox( CGContextFontVG(context), point, breakRowWidth, s, length);
}

static inline CGFloat   CGContextAttributedText( CGContext *context,
                                                 CGPoint point,
                                                 char *s,
                                                 size_t length,
                                                 struct CGTextAttribute *attributes,
                                                 int nAttributes)
{
   if( context && s && CGContextFontFN(context)->attributedText)
      return( CGContextFontFN(context)->attributedText( CGContextFontVG(context), point, s, length, attributes, nAttributes));
   return( 0.0);
}

static inline void   CGContextAddCGPath( CGContext *context, CGPathRef path)
{
   if( context)
      CGContextFN(context)->addCGPath( CGContextVG(context), path);
}

static inline void   CGContextCopyPath( CGContext *context, CGContext *src)
{
   if( context && src && CGContextFN(context)->copyPath)
      CGContextFN(context)->copyPath( CGContextVG(context), CGContextVG(src));
}

static inline void   CGContextPrecompilePath( CGContext *context)
{
   if( context && CGContextFN(context)->precompilePath)
      CGContextFN(context)->precompilePath( CGContextVG(context));
}


// Paint style setters (call before fill/stroke)

static inline void   CGContextSetFillLinearGradient( CGContext *context, CGPoint start, CGPoint end, CGColor startColor, CGColor endColor)
{
   if( context)
      CGContextFN(context)->setFillLinearGradient( CGContextVG(context), start, end, startColor, endColor);
}

static inline void   CGContextSetStrokeLinearGradient( CGContext *context, CGPoint start, CGPoint end, CGColor startColor, CGColor endColor)
{
   if( context)
      CGContextFN(context)->setStrokeLinearGradient( CGContextVG(context), start, end, startColor, endColor);
}

static inline void   CGContextSetFillBoxGradient( CGContext *context, CGRect rect, CGFloat cornerRadius, CGColor color, CGFloat feather, CGColor featherColor)
{
   if( context)
      CGContextFN(context)->setFillBoxGradient( CGContextVG(context), rect, cornerRadius, color, feather, featherColor);
}

static inline void   CGContextSetStrokeBoxGradient( CGContext *context, CGRect rect, CGFloat cornerRadius, CGColor color, CGFloat feather, CGColor featherColor)
{
   if( context)
      CGContextFN(context)->setStrokeBoxGradient( CGContextVG(context), rect, cornerRadius, color, feather, featherColor);
}

static inline void   CGContextSetFillRadialGradient( CGContext *context, CACircle circle, CGColor outerColor, CGFloat innerRadius, CGColor innerColor)
{
   if( context)
      CGContextFN(context)->setFillRadialGradient( CGContextVG(context), circle, outerColor, innerRadius, innerColor);
}

static inline void   CGContextSetStrokeRadialGradient( CGContext *context, CACircle circle, CGColor outerColor, CGFloat innerRadius, CGColor innerColor)
{
   if( context)
      CGContextFN(context)->setStrokeRadialGradient( CGContextVG(context), circle, outerColor, innerRadius, innerColor);
}

// TODO: use CGImage instead of CGTextureID
static inline void   CGContextSetFillImagePattern( CGContext *context, CGTextureID textureID, CGRect rect, CARotation rotation, CGFloat alpha)
{
   if( context)
      CGContextFN(context)->setFillImagePattern( CGContextVG(context), textureID, rect, rotation, alpha);
}

// TODO: use CGImage instead of CGTextureID
static inline void   CGContextSetStrokeImagePattern( CGContext *context, CGTextureID textureID, CGRect rect, CARotation rotation, CGFloat alpha)
{
   if( context)
      CGContextFN(context)->setStrokeImagePattern( CGContextVG(context), textureID, rect, rotation, alpha);
}

static inline void   CGContextTrace( CGContext *context, FILE *fp)
{
   if( context && CGContextFN(context)->trace)
      CGContextFN(context)->trace( CGContextVG(context), fp);
}



#define _CGContextDo( context, name)                    \
   for( int name ## __j = (CGContextSave( context), 0); \
        ! name ## __j;                                  \
        name ## __j  = (CGContextRestore( context), 1)) \
      MULLE_C_CONFINED_LOOP                             \
      for( int  name ## __i = 0;                        \
           ! name ## __i;                               \
           name ## __i = 1)

#define _CGContextDo_PASTE(context, line)  _CGContextDo( context, cgcontext__ ## line)
#define _CGContextDo_LINE(context, line)   _CGContextDo_PASTE( context, line)
#define CGContextDo( context)              _CGContextDo_LINE( context, __LINE__)

//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#include "CGTypes.h"
#include "CGFunctionTable.h"
#include "CGBackendFunctionTable.h"
#import "CGContextBase.h"
#import "CGContext.h"
#import "CGLayoutContext.h"

// Dispatch a drawing call through the function table.
// Works for CGContext *, CGLayoutContext *, CGContextBase * — all cast to base.
#define CGContextVG( ctx)        (_CGContextBaseGetBackendContext( (CGContextBase *)(ctx)))
#define CGContextFN( ctx)        (_CGContextBaseGetFunctionTable( (CGContextBase *)(ctx)))
#define CGContextBFN( ctx)       (_CGContextBaseGetBackendFunctionTable( (CGContextBase *)(ctx)))


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

static inline void   CGContextSave( CGLayoutContext *context)
{
   if( context)
      CGContextFN(context)->save( CGContextVG(context));
}

static inline void   CGContextRestore( CGLayoutContext *context)
{
   if( context)
      CGContextFN(context)->restore( CGContextVG(context));
}

static inline void   CGContextReset( CGContextBase *context)
{
   if( context)
      CGContextFN(context)->reset( CGContextVG(context));
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
      return CGContextFN(context)->createFont( CGContextVG(context), name, filename);
   return( CGFontIDInvalid);
}

static inline CGFontID CGContextCreateFontMem( CGLayoutContext *context, char *name, void *data, size_t length, BOOL freeData)
{
   if( context)
      return CGContextFN(context)->createFontMem( CGContextVG(context), name, data, length, freeData);
   return( CGFontIDInvalid);
}

static inline CGFontID CGContextFindFont( CGLayoutContext *context, char *name)
{
   if( context)
      return CGContextFN(context)->findFont( CGContextVG(context), name);
   return( CGFontIDInvalid);
}

static inline CGFontID CGContextAddFallbackFontId( CGLayoutContext *context, CGFontID baseFont, CGFontID fallbackFont)
{
   if( context)
      return CGContextFN(context)->addFallbackFontId( CGContextVG(context), baseFont, fallbackFont);
   return( CGFontIDInvalid);
}

static inline CGFontID CGContextAddFallbackFont( CGLayoutContext *context, char *baseFont, char *fallbackFont)
{
   if( context)
      return CGContextFN(context)->addFallbackFont( CGContextVG(context), baseFont, fallbackFont);
   return( CGFontIDInvalid);
}

static inline void   CGContextResetFallbackFontsId( CGLayoutContext *context, NSInteger baseFont)
{
   if( context)
      CGContextFN(context)->resetFallbackFontsId( CGContextVG(context), baseFont);
}

static inline void   CGContextResetFallbackFonts( CGLayoutContext *context, char *baseFont)
{
   if( context)
      CGContextFN(context)->resetFallbackFonts( CGContextVG(context), baseFont);
}

static inline void   CGContextFontSize( CGLayoutContext *context, CGFloat size)
{
   if( context)
      CGContextFN(context)->fontSize( CGContextVG(context), size);
}

static inline void   CGContextFontBlur( CGLayoutContext *context, CGFloat blur)
{
   if( context)
      CGContextFN(context)->fontBlur( CGContextVG(context), blur);
}

static inline void   CGContextTextLetterSpacing( CGLayoutContext *context,
                                                 CGFloat spacing)
{
   if( context)
      CGContextFN(context)->textLetterSpacing( CGContextVG(context), spacing);
}

static inline void   CGContextTextLineHeight( CGLayoutContext *context,
                                              CGFloat lineHeight)
{
   if( context)
      CGContextFN(context)->textLineHeight( CGContextVG(context), lineHeight);
}

static inline void   CGContextCombinedTextAlignment( CGLayoutContext *context,
                                                CGCombinedTextAlign align)
{
   if( context)
      CGContextFN(context)->textAlign( CGContextVG(context), align);
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
   CGContextFN(context)->textAlign( CGContextVG(context), align);
}

static inline void   CGContextFontFaceId( CGLayoutContext *context, CGFontID fontID)
{
   if( context)
      CGContextFN(context)->fontFaceId( CGContextVG(context), fontID);
}

static inline void   CGContextClearType( CGLayoutContext *context, BOOL enable)
{
   if( context)
      CGContextFN(context)->clearType( CGContextVG(context), enable);
}

static inline void   CGContextTextColor( CGLayoutContext *context, CGColor color)
{
   if( context)
      CGContextFN(context)->textColor( CGContextVG(context), color);
}

static inline void   CGContextTextBackgroundColor( CGLayoutContext *context, CGColor color)
{
   if( context)
      CGContextFN(context)->textBackgroundColor( CGContextVG(context), color);
}

static inline CGTextBoundsInfo   CGContextTextBoundsInfo( CGLayoutContext *context,
                                                          CGPoint point,
                                                          char *s,
                                                          size_t length)
{
   return( CGContextFN(context)->textBounds( CGContextVG(context), point, s, length));
}

static inline CGRect   CGContextTextVisualBounds( CGLayoutContext *context,
                                                  CGPoint point,
                                                  char *s,
                                                  size_t length)
{
   CGRect   vbounds = CGRectNull;

   if( context)
      vbounds = CGContextFN(context)->textVisualBounds( CGContextVG(context), point, s, length);
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
      CGContextFN(context)->textBoxBounds( CGContextVG(context), point, s, length, breakRowWidth, &bbox);
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

   return( CGContextFN(context)->textGlyphPositions( CGContextVG(context),
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

   return( CGContextFN(context)->textBreakLines( CGContextVG(context), s, length, breakRowWidth, rows, maxRows, UITextRowSize));
}

static inline CGTextMetrics   CGContextTextMetrics( CGLayoutContext *context)
{
   CGTextMetrics   metrics = { 0 };

   if( context)
      metrics = CGContextFN(context)->textMetrics( CGContextVG(context));
   return( metrics);
}

static inline void   *CGContextGetFontHandle( CGLayoutContext* context, int font)
{
   if( context)
      return( CGContextFN(context)->getFontHandle( CGContextVG(context), font));
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
      return( CGContextFN(context)->text( CGContextVG(context), point, s, length));
   return( 0.0);
}

static inline void   CGContextTextBox( CGContext *context,
                                       CGPoint point,
                                       CGFloat breakRowWidth,
                                       char *s,
                                       size_t length)
{
   if( context && s)
      CGContextFN(context)->textBox( CGContextVG(context), point, breakRowWidth, s, length);
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

static inline void   CGContextSetFillImagePattern( CGContext *context, CGTextureID textureID, CGRect rect, CARotation rotation, CGFloat alpha)
{
   if( context)
      CGContextFN(context)->setFillImagePattern( CGContextVG(context), textureID, rect, rotation, alpha);
}

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

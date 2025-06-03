//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
// we want "import.h" always anyway
#import "import.h"

#include "CGTypes.h"
#include "CGPath+nanovg.h"
#import "CGContext+nanovg.h"


#include "nanowrap.h"
#import "CGContext+UIGraphicsDrawing.h"




//
// IDEAS...
//
// Ideally everything that is concerned with drawing is using CGContext
// functions, that abstracts somewhat from nanovg. The idea is that you can
// could have another UIDrawingContext maybe based on skia (google ?) and
// you would not need to change anything in the layers code. Hmmm...
// But that's not really the case, since CGContext is pretty much wedded to
// nanovg, and a different drawing library would use a different CGContext
// (not named CGContext alltogether) most likely...
//
// microvg style interface
//
// These are supposed to be the primary drawing methods for UI code.
// Try to abstract all internal types from nanovg away....
//
// Newest idea: Rename say CGContextDrawText to UIDrawText, make it basically
// a list of functions that are by convention bound to "UIGraphicsContext",
// and the CGContext is one of them.
// e.g.
// static inline void   CGContextCancelFrame( CGContext *context)
// becomes
// static inline void   UICancelFrame( id <UIGraphicsContext> context)
//
// immediate problem. UIGraphicsContext is not known to CGContext...
// So we need a UIDrawingContext protocol also...


// ###
// Functions that forward to mvg
// ###

// Begin drawing a new frame
static inline void   CGContextBeginFrame( CGContext *context, CGSize windowSize, CGFloat devicePixelRatio)
{
   if( context)
      mvgBeginFrame( CGContextGetNVGContext( context), windowSize, devicePixelRatio);
}

// Cancels drawing the current frame.
static inline void   CGContextCancelFrame( CGContext *context)
{
   if( context)
      mvgCancelFrame( CGContextGetNVGContext( context));
}

// Ends drawing flushing remaining render state.
static inline void   CGContextEndFrame( CGContext *context)
{
   if( context)
      mvgEndFrame( CGContextGetNVGContext( context));
}

// Sets the composite operation. The op parameter should be one of NVGcompositeOperation.
static inline void   CGContextGlobalCompositeOperation( CGContext *context, NSInteger op)
{
   if( context)
      mvgGlobalCompositeOperation( CGContextGetNVGContext( context), op);
}

// Composite operation with custom pixel arithmetic.
static inline void   CGContextGlobalCompositeBlendFunc( CGContext *context,
                                                        NSUInteger sfactor,
                                                        NSUInteger dfactor)
{
   if( context)
      mvgGlobalCompositeBlendFunc( CGContextGetNVGContext( context), sfactor, dfactor);
}

// Composite operation with custom pixel arithmetic for RGB and alpha components separately.
static inline void   CGContextGlobalCompositeBlendFuncSeparate( CGContext *context,
                                                                NSUInteger srcRGB,
                                                                NSUInteger dstRGB,
                                                                NSUInteger srcAlpha,
                                                                NSUInteger dstAlpha)
{
   if( context)
      mvgGlobalCompositeBlendFuncSeparate( CGContextGetNVGContext( context),
                                           srcRGB, dstRGB, srcAlpha, dstAlpha);
}

// Pushes and saves the current render state into a state stack.
static inline void   CGContextSave( CGLayoutContext *context)
{
   if( context)
      mvgSave( CGLayoutContextGetNVGContext( context));
}

// Pops and restores the current render state from the state stack.
static inline void   CGContextRestore( CGLayoutContext *context)
{
   if( context)
      mvgRestore( CGLayoutContextGetNVGContext( context));
}

// Resets current render state to default values. Does not affect the render state stack.
static inline void   CGContextReset( CGContextBase *context)
{
   if( context)
      mvgReset( CGContextBaseGetNVGContext( context));
}

// Sets whether to draw antialias for nvgStroke() and nvgFill().
// It is enabled by default.
static inline void   CGContextShapeAntiAlias( CGContext *context, BOOL enable)
{
   if( context)
      mvgShapeAntiAlias( CGContextGetNVGContext( context), enable);
}

// Sets the stroke style.
static inline void   CGContextStrokeColor( CGContext *context, CGColor color)
{
   if( context)
      mvgStrokeColor( CGContextGetNVGContext( context), color);
}


// Sets the fill style.
static inline void   CGContextFillColor( CGContext *context, CGColor color)
{
   if( context)
      mvgFillColor( CGContextGetNVGContext( context), color);
}


// Sets the miter limit of the stroke style.
static inline void   CGContextMiterLimit( CGContext *context, CGFloat limit)
{
   if( context)
      mvgMiterLimit( CGContextGetNVGContext( context), limit);
}

// Sets the stroke width of the stroke style.
static inline void   CGContextStrokeWidth( CGContext *context, CGFloat size)
{
   if( context)
      mvgStrokeWidth( CGContextGetNVGContext( context), size);
}

// Sets the line cap of the stroke style.
static inline void   CGContextLineCap( CGContext *context, NSInteger cap)
{
   if( context)
      mvgLineCap( CGContextGetNVGContext( context), cap);
}

// Sets the line join of the stroke style.
static inline void   CGContextLineJoin( CGContext *context, NSInteger join)
{
   if( context)
      mvgLineJoin( CGContextGetNVGContext( context), join);
}

// Sets the transparency applied to all rendered shapes.
static inline void   CGContextGlobalAlpha( CGContext *context, CGFloat alpha)
{
   if( context)
      mvgGlobalAlpha( CGContextGetNVGContext( context), alpha);
}

// Sets the global transform matrix to the result of current render target.
static inline void   CGContextResetTransform( CGLayoutContext *context)
{
   if( context)
      mvgResetTransform( CGLayoutContextGetNVGContext( context));
}

// Premultiplies current coordinate system by specified matrix.
static inline void   CGContextTransform( CGLayoutContext *context,
                                         CGAffineTransform *xform)
{
   if( context)
      mvgTransform( CGLayoutContextGetNVGContext( context), xform);
}

// Translates current coordinate system.
static inline void   CGContextTranslate( CGContext *context, CGPoint p)
{
   if( context)
      mvgTranslate( CGContextGetNVGContext( context), p);
}

// Rotates current coordinate system.
static inline void   CGContextRotate( CGContext *context, CARotation rotation)
{
   if( context)
      mvgRotate( CGContextGetNVGContext( context), rotation);
}

// Skews the current coordinate system along X axis.
static inline void   CGContextSkewX( CGContext *context, CAAngle angle)
{
   if( context)
      mvgSkewX( CGContextGetNVGContext( context), angle);
}

// Skews the current coordinate system along Y axis.
static inline void   CGContextSkewY( CGContext *context, CAAngle angle)
{
   if( context)
      mvgSkewY( CGContextGetNVGContext( context), angle);
}

// Scales the current coordinate system.
static inline void   CGContextScale( CGContext *context, CGVector v)
{
   if( context)
      mvgScale( CGContextGetNVGContext( context), v);
}

// Stores the top part (a-f) of the current transformation matrix in to the specified buffer.
static inline CGAffineTransform   CGContextCurrentTransform( CGContext *context)
{
   if( context)
      return( mvgCurrentTransform( CGContextGetNVGContext( context)));
   return( CGAffineTransformMakeIdentityInline());
}

// Creates image by loading it from the disk from specified file name.
static inline CGTextureID CGContextCreateImage( CGContext *context,
                                                char *filename,
                                                NSUInteger textureFlags)
{
   if( context)
      return mvgCreateImage( CGContextGetNVGContext( context), filename, textureFlags);
   return CGTextureIDInvalid;
}

// Creates image by loading it from the specified chunk of memory.
static inline CGTextureID   CGContextCreateImageMem( CGContext *context,
                                                     NSInteger textureFlags,
                                                     void *data,
                                                     size_t ndata)
{
   if( context)
      return mvgCreateImageMem( CGContextGetNVGContext( context), textureFlags, data, ndata);
   return CGTextureIDInvalid;
}

// Creates image from specified image data.
static inline CGTextureID CGContextCreateImageRGBA( CGContext *context,
                                                    struct CGPixelSize size,
                                                    NSUInteger textureFlags,
                                                    void *data)
{
   if( context)
      return mvgCreateImageRGBA( CGContextGetNVGContext( context),
                                 size.width,
                                 size.height,
                                 textureFlags,
                                 data);
   return CGTextureIDInvalid;
}

// Updates image data specified by image handle.
static inline void   CGContextUpdateImage( CGContext *context, CGTextureID image, void *data)
{
   if( context)
      mvgUpdateImage( CGContextGetNVGContext( context), image, data);
}

// Returns the dimensions of a created image.
static inline CGPixelSize CGContextImageSize( CGContext *context, CGTextureID image)
{
   if( context)
      return mvgImageSize( CGContextGetNVGContext( context), image);
   return CGPixelSizeZero;
}

// Deletes created image.
static inline void   CGContextDeleteImage( CGContext *context, CGTextureID image)
{
   if( context)
      mvgDeleteImage( CGContextGetNVGContext( context), image);
}


// Sets the current scissor rectangle.
static inline void   CGContextScissor( CGContext *context, CGRect rect)
{
   if( context)
      mvgScissor( CGContextGetNVGContext( context), rect);
}

// Intersects current scissor rectangle with the specified rectangle.
static inline void   CGContextIntersectScissor( CGContext *context, CGRect rect)
{
   if( context)
      mvgIntersectScissor( CGContextGetNVGContext( context), rect);
}

// Reset and disables scissoring.
static inline void   CGContextResetScissor( CGContext *context)
{
   if( context)
      mvgResetScissor( CGContextGetNVGContext( context));
}

// Clears the current path and sub-path
static inline void   CGContextBeginPath( CGContext *context)
{
   if( context)
      mvgBeginPath( CGContextGetNVGContext( context));
}

// Starts new sub-path with specified point as first point.
static inline void   CGContextMoveTo( CGContext *context, CGPoint point)
{
   if( context)
      mvgMoveTo( CGContextGetNVGContext( context), point);
}

// Adds line segment from the last point in the path to the specified point.
static inline void   CGContextLineTo( CGContext *context, CGPoint point)
{
   if( context)
      mvgLineTo( CGContextGetNVGContext( context), point);
}

// Adds cubic bezier segment from last point in the path via two control points to the specified point.
static inline void   CGContextBezierTo( CGContext *context, CGPoint control1, CGPoint control2, CGPoint point)
{
   if( context)
      mvgBezierTo( CGContextGetNVGContext( context), control1, control2, point);
}

// Adds quadratic bezier segment from last point in the path via a control point to the specified point.
static inline void   CGContextQuadTo( CGContext *context, CGPoint control, CGPoint point)
{
   if( context)
      mvgQuadTo( CGContextGetNVGContext( context), control, point);
}

// Adds an arc segment at the corner defined by the last path point, and two specified points.
static inline void   CGContextArcTo( CGContext *context, CGPoint tangent1, CGPoint tangent2, CGFloat radius)
{
   if( context)
      mvgArcTo( CGContextGetNVGContext( context), tangent1, tangent2, radius);
}

// Closes current sub-path with a line segment.
static inline void   CGContextClosePath( CGContext *context)
{
   if( context)
      mvgClosePath( CGContextGetNVGContext( context));
}

// Sets the current sub-path winding.
static inline void   CGContextPathWinding( CGContext *context, NSInteger dir)
{
   if( context)
      mvgPathWinding( CGContextGetNVGContext( context), dir);
}

// Creates new circle arc shaped sub-path
static inline void   CGContextArc( CGContext *context,
                                   CACircle circle,
                                   CAAngle a0,
                                   CAAngle a1,
                                   NSInteger dir)
{
   if( context)
      mvgArc( CGContextGetNVGContext( context), circle, a0, a1, dir);
}

// Creates new rectangle shaped sub-path.
static inline void   CGContextRect( CGContext *context, CGRect rect)
{
   if( context)
      mvgRect( CGContextGetNVGContext( context), rect);
}

// Creates new rounded rectangle with varying corner radii.
static inline void   CGContextRoundedRectVarying( CGContext *context, CGRect rect, struct MulleCornerInsets insets)
{
   if( context)
      mvgRoundedRectVarying( CGContextGetNVGContext( context), rect, insets);
}

// Creates new rounded rectangle shaped sub-path.
static inline void   CGContextRoundedRect( CGContext *context, CGRect rect, CGFloat r)
{
   if( context)
      mvgRoundedRect( CGContextGetNVGContext( context), rect, r);
}

// Creates new ellipse shaped sub-path.
static inline void   CGContextEllipse( CGContext *context, CGPoint center, CGFloat rx, CGFloat ry)
{
   if( context)
      mvgEllipse( CGContextGetNVGContext( context), center, rx, ry);
}

// Creates new circle shaped sub-path.
static inline void   CGContextCircle( CGContext *context, CACircle circle)
{
   if( context)
      mvgCircle( CGContextGetNVGContext( context), circle);
}

// Fills the current path with current fill style.
static inline void   CGContextFill( CGContext *context)
{
   if( context)
      mvgFill( CGContextGetNVGContext( context));
}

// Fills the current path with current stroke style.
static inline void   CGContextStroke( CGContext *context)
{
   if( context)
      mvgStroke( CGContextGetNVGContext( context));
}


// ***
// Begin of CGLayoutContext
// ***


// Creates font by loading it from the disk from specified file name.
static inline CGFontID CGContextCreateFont( CGLayoutContext *context, char *name, char *filename)
{
   if( context)
      return mvgCreateFont( CGLayoutContextGetNVGContext( context), name, filename);
   return( CGFontIDInvalid);
}


// Creates font by loading it from the specified memory chunk.
static inline CGFontID CGContextCreateFontMem( CGLayoutContext *context, char *name, void *data, size_t length, BOOL freeData)
{
   if( context)
      return mvgCreateFontMem( CGLayoutContextGetNVGContext( context), name, data, length, freeData);
   return( CGFontIDInvalid);
}

// Finds a loaded font of specified name, and returns handle to it, or -1 if the font is not found.
static inline CGFontID CGContextFindFont( CGLayoutContext *context, char *name)
{
   if( context)
      return mvgFindFont( CGLayoutContextGetNVGContext( context), name);
   return( CGFontIDInvalid);
}

// Adds a fallback font by handle.
static inline CGFontID CGContextAddFallbackFontId( CGLayoutContext *context, CGFontID baseFont, CGFontID fallbackFont)
{
   if( context)
      return mvgAddFallbackFontId( CGLayoutContextGetNVGContext( context), baseFont, fallbackFont);
   return( CGFontIDInvalid);
}

// Adds a fallback font by name.
static inline CGFontID CGContextAddFallbackFont( CGLayoutContext *context, char *baseFont, char *fallbackFont)
{
   if( context)
      return mvgAddFallbackFont( CGLayoutContextGetNVGContext( context), baseFont, fallbackFont);
   return( CGFontIDInvalid);
}

// Resets fallback fonts by handle.
static inline void   CGContextResetFallbackFontsId( CGLayoutContext *context, NSInteger baseFont)
{
   if( context)
      mvgResetFallbackFontsId( CGLayoutContextGetNVGContext( context), baseFont);
}

// Resets fallback fonts by name.
static inline void   CGContextResetFallbackFonts( CGLayoutContext *context, char *baseFont)
{
   if( context)
      mvgResetFallbackFonts( CGLayoutContextGetNVGContext( context), baseFont);
}

// Sets the font size of current text style.
static inline void   CGContextFontSize( CGLayoutContext *context, CGFloat size)
{
   if( context)
      mvgFontSize( CGLayoutContextGetNVGContext( context), size);
}

// Sets the blur of current text style.
static inline void   CGContextFontBlur( CGLayoutContext *context, CGFloat blur)
{
   if( context)
      mvgFontBlur( CGLayoutContextGetNVGContext( context), blur);
}

// Sets the letter spacing of current text style.
static inline void   CGContextTextLetterSpacing( CGLayoutContext *context, CGFloat spacing)
{
   if( context)
      mvgTextLetterSpacing( CGLayoutContextGetNVGContext( context), spacing);
}

// Sets the line height of current text style.
static inline void   CGContextTextLineHeight( CGLayoutContext *context, CGFloat lineHeight)
{
   if( context)
      mvgTextLineHeight( CGLayoutContextGetNVGContext( context), lineHeight);
}

// Sets the text align of current text style.
static inline void   CGContextTextAlign( CGLayoutContext *context, NSUInteger align)
{
   if( context)
      mvgTextAlign( CGLayoutContextGetNVGContext( context), align);
}

// Sets the font face based on specified id(font handle).
static inline void   CGContextFontFaceId( CGLayoutContext *context, CGFontID fontID)
{
   if( context)
      mvgFontFaceId( CGLayoutContextGetNVGContext( context), fontID);
}

// Enable/disable ClearType text rendering
static inline void   CGContextClearType( CGLayoutContext *context, BOOL enable)
{
   if( context)
      mvgClearType( CGLayoutContextGetNVGContext( context), enable);
}

// Set text color
static inline void   CGContextTextColor( CGLayoutContext *context, CGColor color)
{
   if( context)
      mvgTextColor( CGLayoutContextGetNVGContext( context), color);
}

// Set text background color
static inline void   CGContextTextBackgroundColor( CGLayoutContext *context, CGColor color)
{
   if( context)
      mvgTextBackgroundColor( CGLayoutContextGetNVGContext( context), color);
}

// Measures the specified text string.
static inline CGTextBoundsInfo   CGContextTextBoundsInfo( CGLayoutContext *context,
                                                          CGPoint point,
                                                          char *s,
                                                          size_t length)
{
   return( mvgTextBounds( CGLayoutContextGetNVGContext( context), point, s, length));
}

// Get visual bounds of text
static inline CGRect   CGContextTextVisualBounds( CGLayoutContext *context,
                                                  CGPoint point,
                                                  char *s,
                                                  size_t length)
{
   CGRect   vbounds = CGRectNull;

   if( context)
      vbounds = mvgTextVisualBounds( CGLayoutContextGetNVGContext( context), point, s, length);
   return( vbounds);
}

// Measures the specified multi-text string.
static inline CGRect   CGContextTextBoxBounds( CGLayoutContext *context,
                                               CGPoint point,
                                               char *s,
                                               size_t length,
                                               CGFloat breakRowWidth)
{
   CGRect   bbox = CGRectNull;

   if( context)
      mvgTextBoxBounds( CGLayoutContextGetNVGContext( context), point, s, length, breakRowWidth, &bbox);
   return( bbox);
}

// Calculates the glyph x positions of the specified text.
static inline NSUInteger   CGContextTextGlyphPositions( CGLayoutContext *context,
                                                        CGPoint point,
                                                        char *s,
                                                        size_t length,
                                                        struct UIGlyphPosition *positions,
                                                        NSInteger maxPositions)
{
   if( context)
      return mvgTextGlyphPositions( CGLayoutContextGetNVGContext( context),
                                    point,
                                    s,
                                    length,
                                    positions,
                                    maxPositions);
   return 0;
}

// Breaks the specified text into lines.
static inline NSInteger   CGContextTextBreakLines( CGLayoutContext *context,
                                                   char *s,
                                                   size_t length,
                                                   CGFloat breakRowWidth,
                                                   struct UITextRow* rows,
                                                   NSInteger maxRows)
{
   if( context)
      return mvgTextBreakLines( CGLayoutContextGetNVGContext( context), s, length, breakRowWidth, rows, maxRows);
   return 0;
}

// Get text metrics
// Returns the vertical metrics based on the current text style.
// Measured values are returned in local coordinate space.
// When you call nvgFontSize(ctx, 12):
//
// *  NanoVG stores 12 as the font size
// *  When text needs to be rendered, it scales this by the transformation and
//    device pixel ratio
// *  With unity transformation and standard DPI, it passes 12 to fontstash
// *  Fontstash calls FT_Set_Char_Size(font, 0, 12*64, 0, 0)
// *  FreeType renders each glyph at 12 points (which is 12 pixels at 72 DPI)
// *  The resulting bitmap dimensions are in pixels
// *  These bitmaps are copied into the atlas texture
// *  When rendering text, NanoVG uses the glyph metrics to position each
//    character
//
// The mvgTextLineHeight, which is used to vertically space lines when using
// multiline text output, is not part of the font metric lineHeight.
//
static inline CGTextMetrics   CGContextTextMetrics( CGLayoutContext *context)
{
   CGTextMetrics   metrics = { 0 };

   if( context)
   {
      nvgTextMetrics( CGLayoutContextGetNVGContext( context),
                      &metrics.ascender,
                      &metrics.descender,
                      &metrics.lineHeight);

      metrics.ascender  = fabsf( metrics.ascender);
      metrics.descender = fabsf( metrics.descender);
   }
   return( metrics);
}


// Get the FT_Face as a void * or stbtt_fontinfo * for the a font. If the font
// is -1, the current font is used. This function can be useful, if you want to
// do more intricate font handling. If NULL is returned you haven't set up the
// font yet. Once you get the font handle, changes in font state like
// nvgFontSize, nvgTextAlign and so forth will not affect the font (!), until
// you call nvgGetFontHandle or any other font querying function like
// nvgTextMetrics or nvgText.
static inline void   *CGContextGetFontHandle( CGLayoutContext* context, int font)
{
   if( context)
      return( nvgGetFontHandle( CGLayoutContextGetNVGContext( context), font));
   return( NULL);
}


// ***
// End of CGLayoutContext
// ***



// Draws text string at specified location.
static inline CGFloat   CGContextText( CGContext *context,
                                       CGPoint point,
                                       char *s,
                                       size_t length)
{
   if( context && s)
      return( mvgText( CGContextGetNVGContext( context), point, s, length));
   return( 0.0);
}


static inline void   CGContextTextBox( CGContext *context,
                                       CGPoint point,
                                       CGFloat breakRowWidth,
                                       char *s,
                                       size_t length)
{
   if( context && s)
      mvgTextBox( CGContextGetNVGContext( context), point, breakRowWidth, s, length);
}




//
// MEMO: these functions are likely duplicates of our CGAffineTransform ones
//

static inline void   CGContextAddCGPath( CGContext *context, CGPathRef path)
{
   if( context)
      mvgAddCGPath( CGContextGetNVGContext( context), path);
}





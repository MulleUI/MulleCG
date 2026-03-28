//
// CGFunctionTable.h
// MulleCG
//
// Function pointer vtable for the drawing backend.
// The nanovg implementation is in MulleCGNanoVG/CGFunctionTable+nanovg.m.
//
#ifndef cgfunctiontable_h__
#define cgfunctiontable_h__

#import "import.h"


#include "CGTypes.h"

struct CGPath;
struct UIGlyphPosition;
struct UITextRow;

typedef struct CGFunctionTable
{
   // Frame management
   void        (*beginFrame)( void *vg, CGSize windowSize, CGFloat devicePixelRatio);
   void        (*cancelFrame)( void *vg);
   void        (*endFrame)( void *vg);

   // State management
   void        (*save)( void *vg);
   void        (*restore)( void *vg);
   void        (*reset)( void *vg);

   // Composite operations
   void        (*globalCompositeOperation)( void *vg, NSInteger op);
   void        (*globalCompositeBlendFunc)( void *vg, NSUInteger sfactor, NSUInteger dfactor);
   void        (*globalCompositeBlendFuncSeparate)( void *vg, NSUInteger srcRGB, NSUInteger dstRGB, NSUInteger srcAlpha, NSUInteger dstAlpha);

   // Transform operations
   void        (*resetTransform)( void *vg);
   void        (*transform)( void *vg, CGAffineTransform *xform);
   CGAffineTransform (*currentTransform)( void *vg);
   void        (*translate)( void *vg, CGPoint p);
   void        (*rotate)( void *vg, CARotation rotation);
   void        (*scale)( void *vg, CGVector v);
   void        (*skewX)( void *vg, CAAngle angle);
   void        (*skewY)( void *vg, CAAngle angle);

   // Image operations
   CGTextureID (*createImage)( void *vg, char *filename, NSUInteger textureFlags);
   CGTextureID (*createImageMem)( void *vg, NSInteger textureFlags, void *data, size_t ndata);
   CGTextureID (*createImageRGBA)( void *vg, NSInteger w, NSInteger h, NSUInteger textureFlags, void *data);
   void        (*updateImage)( void *vg, CGTextureID image, void *data);
   CGPixelSize (*imageSize)( void *vg, CGTextureID image);
   void        (*deleteImage)( void *vg, CGTextureID image);

   // Scissor operations
   void        (*scissor)( void *vg, CGRect rect);
   void        (*intersectScissor)( void *vg, CGRect rect);
   void        (*resetScissor)( void *vg);

   // Render style
   void        (*shapeAntiAlias)( void *vg, BOOL enable);
   void        (*bezierTessellation)( void *vg, CGTessellation mode);
   void        (*strokeColor)( void *vg, CGColor color);
   void        (*fillColor)( void *vg, CGColor color);
   void        (*miterLimit)( void *vg, CGFloat limit);
   void        (*strokeWidth)( void *vg, CGFloat size);
   void        (*lineCap)( void *vg, NSInteger cap);
   void        (*lineJoin)( void *vg, NSInteger join);
   void        (*globalAlpha)( void *vg, CGFloat alpha);

   // Path operations
   void        (*beginPath)( void *vg);
   void        (*moveTo)( void *vg, CGPoint point);
   void        (*lineTo)( void *vg, CGPoint point);
   void        (*bezierTo)( void *vg, CGPoint control1, CGPoint control2, CGPoint point);
   void        (*quadTo)( void *vg, CGPoint control, CGPoint point);
   void        (*arcTo)( void *vg, CGPoint tangent1, CGPoint tangent2, CGFloat radius);
   void        (*closePath)( void *vg);
   void        (*pathWinding)( void *vg, CGPathFillStyle style);

   // Shape operations
   void        (*rect)( void *vg, CGRect rect);
   void        (*roundedRect)( void *vg, CGRect rect, CGFloat r);
   void        (*roundedRectVarying)( void *vg, CGRect rect, struct MulleCornerInsets insets);
   void        (*ellipse)( void *vg, CGPoint center, CGFloat rx, CGFloat ry);
   void        (*arc)( void *vg, CACircle circle, CAAngle angle, CARotation rotation);
   void        (*arcRadians)( void *vg, CACircle circle, CGFloat radians1, CGFloat radians2, CARotationDirection dir);
   void        (*fill)( void *vg);
   void        (*stroke)( void *vg);
   void        (*addCGPath)( void *vg, struct CGPath *path);
   void        (*copyPath)( void *vg, void *src_vg);
   void        (*precompilePath)( void *vg);

   // Paint style (set before fill/stroke)
   void        (*setFillLinearGradient)( void *vg, CGPoint start, CGPoint end, CGColor startColor, CGColor endColor);
   void        (*setStrokeLinearGradient)( void *vg, CGPoint start, CGPoint end, CGColor startColor, CGColor endColor);
   void        (*setFillBoxGradient)( void *vg, CGRect rect, CGFloat cornerRadius, CGColor color, CGFloat feather, CGColor featherColor);
   void        (*setStrokeBoxGradient)( void *vg, CGRect rect, CGFloat cornerRadius, CGColor color, CGFloat feather, CGColor featherColor);
   void        (*setFillRadialGradient)( void *vg, CACircle circle, CGColor outerColor, CGFloat innerRadius, CGColor innerColor);
   void        (*setStrokeRadialGradient)( void *vg, CACircle circle, CGColor outerColor, CGFloat innerRadius, CGColor innerColor);
   void        (*setFillImagePattern)( void *vg, CGTextureID textureID, CGRect rect, CARotation rotation, CGFloat alpha);
   void        (*setStrokeImagePattern)( void *vg, CGTextureID textureID, CGRect rect, CARotation rotation, CGFloat alpha);

   // Font operations
   CGFontID    (*createFont)( void *vg, char *name, char *filename);
   CGFontID    (*createFontMem)( void *vg, char *name, void *data, size_t length, BOOL freeData);
   CGFontID    (*findFont)( void *vg, char *name);
   CGFontID    (*addFallbackFontId)( void *vg, CGFontID baseFont, CGFontID fallbackFont);
   CGFontID    (*addFallbackFont)( void *vg, char *baseFont, char *fallbackFont);
   void        (*resetFallbackFontsId)( void *vg, NSInteger baseFont);
   void        (*resetFallbackFonts)( void *vg, char *baseFont);

   // Text style
   CGFloat     (*fontSize)( void *vg, CGFloat size);
   void        (*fontBlur)( void *vg, CGFloat blur);
   void        (*textLetterSpacing)( void *vg, CGFloat spacing);
   void        (*textLineHeight)( void *vg, CGFloat lineHeight);
   void        (*textAlign)( void *vg, CGCombinedTextAlign align);
   void        (*fontFaceId)( void *vg, CGFontID fontID);
   void        (*fontFace)( void *vg, char *fontname);
   void        (*textColor)( void *vg, CGColor color);
   void        (*textBackgroundColor)( void *vg, CGColor color);
   void        (*clearType)( void *vg, BOOL enable);

   // Text drawing / measurement
   CGFloat     (*text)( void *vg, CGPoint point, char *s, size_t length);
   void        (*textBox)( void *vg, CGPoint point, CGFloat breakRowWidth, char *s, size_t length);
   CGTextBoundsInfo (*textBounds)( void *vg, CGPoint point, char *s, size_t length);
   CGRect      (*textVisualBounds)( void *vg, CGPoint point, char *s, size_t length);
   void        (*textBoxBounds)( void *vg, CGPoint point, char *s, size_t length, CGFloat breakRowWidth, CGRect *bbox);
   NSUInteger  (*textGlyphPositions)( void *vg, CGPoint point, char *s, size_t length, struct UIGlyphPosition *positions, NSInteger maxPositions);
   NSUInteger  (*textBreakLines)( void *vg, char *s, size_t length, CGFloat breakRowWidth, struct UITextRow *rows, NSUInteger maxRows, size_t textRowSize);
   CGTextMetrics (*textMetrics)( void *vg);
   void          *(*getFontHandle)( void *vg, int font);

   // Debugging
   void        (*trace)( void *vg, FILE *fp);

} CGFunctionTable;

#endif

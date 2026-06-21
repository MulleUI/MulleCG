//
// CGFontFunctionTable.h
// MulleCG
//
// Function pointer vtable for font/text backend operations only.
// The nanovg implementation is in MulleCGNanoVG/CGFunctionTable+nanovg.m.
//
#ifndef cgfontfunctiontable_h__
#define cgfontfunctiontable_h__

#import "import.h"

#include "CGTypes.h"

struct UIGlyphPosition;
struct UITextRow;

// MEMO: In the future the CGFontFunctions will provide an "atlas", which the
//       drawing functions can then use to render glyphs.
typedef struct CGFontFunctionTable
{
   // State management (font state only)
   void        (*save)( void *vg);
   void        (*restore)( void *vg);
   void        (*reset)( void *vg);

   // Font management
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

   // Attributed text
   CGFloat     (*attributedText)( void *vg, CGPoint point, char *s, size_t length,
                                  struct CGTextAttribute *attributes, int nAttributes);

} CGFontFunctionTable;

#endif

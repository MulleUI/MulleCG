//
//  CGFontFunctionTable.h
//  MulleCG
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
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

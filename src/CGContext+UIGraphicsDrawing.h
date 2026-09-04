//
//  CGContext+UIGraphicsDrawing.h
//  MulleCG
//
//  Copyright (c) 2025 Nat! - Mulle kybernetiK.
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
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


// because this is CGTypes is a "C" header, and UITextAlignment is in "ObjC"
// we have this here
static inline CGCombinedTextAlign   UITextAlignmentToTextAlign( UITextAlignment alignment)
{
   switch( alignment)
   {
   default                    : return( CGTextAlignLeft   | CGTextAlignBaseline);
   case UITextAlignmentRight  : return( CGTextAlignRight  | CGTextAlignBaseline);
   case UITextAlignmentCenter : return( CGTextAlignCenter | CGTextAlignBaseline);
   }
}




//
// This is the UIGraphicsDrawing protocol. It probably would be better named
// UIGraphicsContextDrawing.Its used by UIPureWindow for blitting stuff
// and drawing simple debug graphics w/o knowledge about MulleCG
//

@interface CGContext( UIGraphicsDrawing) <UIGraphicsDrawing>

// this is not part of UIGraphicsDrawing
- (void) drawIcon:(mulle_utf32_t) icon
          atPoint:(CGPoint) rect;
@end




static inline void  CGContextDrawText( CGContext *self,
                                       CGFloat x,
                                       CGFloat y,
                                       char *s,
                                       CGFloat fontSize,
                                       CGColor color)
{
   [self drawAtPoint:CGPointMake( x, y)
     textUTF8String:s
  fontNameUTF8String:NULL
         fontSize:fontSize
         hexColor:CGHexColorMakeWithColor( color)];
}


static inline void   CGContextDrawIconInRect( CGContext *self,
                                              mulle_utf32_t icon,
                                              CGRect rect)
{
   [self drawIcon:icon
          atPoint:CGRectGetCenter( rect)];
}


// ###
// Functions that actually "value add" on top of the mvg/nanovg functions
// ###

// Sets the font face based on specified name.
static inline void   CGContextFontFace( CGLayoutContext *context, char *fontname)
{
    [context useFontWithNameUTF8String:fontname];
}

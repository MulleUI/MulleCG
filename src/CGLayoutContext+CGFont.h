//
//  CGLayoutContext+CGFont.h
//  MulleCG
//
//  Copyright (c) 2023 Nat! - Mulle kybernetiK.
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
# if __has_include( "CGLayoutContext.h")
#  import "CGLayoutContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"

#import "CGFont.h"


@interface CGLayoutContext( CGFont)

- (CGFont *) fallbackFont;
- (CGFont *) fontWithNameUTF8String:(char *) s;
- (CGFont *) defaultFont;

//
// these will return either a FT_Face as a void * or a pointer to stbtt_fontinfo
//
- (void *) internalFontHandle;  // current font if set
- (void *) internalFontHandleOfFont:(CGFont *) font;


- (void) _initFontCache;
- (void) _doneFontCache;
- (void) _resetFontCache;

- (void) mulleGainAccessToFontsWithUniquingSet:(struct mulle_pointerset *) uniquing        MULLE_OBJC_THREADSAFE_METHOD;
- (void) mulleRelinquishAccessToFontsWithUniquingSet:(struct mulle_pointerset *) uniquing  MULLE_OBJC_THREADSAFE_METHOD;

@end


//
// implemented by nanovg-specifics
//
@interface CGLayoutContext( CGFontFuture) < MulleObjCFuture>

/*
 * Fill fontCache with fonts, preferably don't use during draws as it does I/O
 * though once loaded the font is cached by the CGContext
 */

- (CGFont *) fontWithCData:(struct mulle_data) data
        fontNameUTF8String:(char *) name;

- (CGFont *) fontWithContentsOfFileWithFileRepresentationString:(char *) filename
                                             fontNameUTF8String:(char *) name;
// useFont: is obsolete
- (void) useFont:(CGFont *) font;

@end


CGFont  *CGLayoutContextUseFontWithNameUTF8String( CGLayoutContext *context,
                                                   char *name);




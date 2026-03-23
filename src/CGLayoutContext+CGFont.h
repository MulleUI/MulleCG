//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
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
@interface CGLayoutContext( CGFontFuture)

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




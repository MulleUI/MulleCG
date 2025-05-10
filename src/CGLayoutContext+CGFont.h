//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"

#import "CGFont.h"


@interface CGLayoutContext( CGFont)

- (CGFont *) fallbackFont;
- (CGFont *) fontWithNameUTF8String:(char *) s;
- (CGFont *) defaultFont;

/*
 * Fill fontCache with fonts, preferably don't use during draws as it does I/O
 * though once loaded the font is cached by the CGContext
 */
- (CGFont *) fontWithContentsOfFileWithFileRepresentationString:(char *) filename
                                             fontNameUTF8String:(char *) name;
- (CGFont *) fontWithCData:(struct mulle_data) data
        fontNameUTF8String:(char *) name;

// useFont: is obsolete
- (void) useFont:(CGFont *) font;

//
// these will return either a FT_Face as a void * or a pointer to stbtt_fontinfo
//
- (void *) internalFontHandle;  // current font if set
- (void *) internalFontHandleOfFont:(CGFont *) font;


- (void) _initFontCache;
- (void) _doneFontCache;
- (void) _resetFontCache;

- (void) mulleGainAccessToFonts           MULLE_OBJC_THREADSAFE_METHOD;
- (void) mulleRelinquishAccessToFonts     MULLE_OBJC_THREADSAFE_METHOD;

@end




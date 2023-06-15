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


@interface CGContext( CGFont)

- (void) setFont:(CGFont *) font;

- (CGFont *) fallbackFont;
- (CGFont *) fontWithNameUTF8String:(char *) s;
- (CGFloat) fontScale;
- (CGFont *) defaultFont;

- (void) _initFontCache;
- (void) _doneFontCache;
- (void) _resetFontCache;

- (void) useFontWithNameUTF8String:(char *) name;
- (void) useDefaultFont;

/*
 * Fill fontCache with fonts, don't use during draws as it does I/O
 */
- (void) addFontWithContentsOfFileWithFileRepresentationString:(char *) filename
                                            fontNameUTF8String:(char *) name;
- (void) addFontWithCData:(struct mulle_data) data
       fontNameUTF8String:(char *) name;


//
// these will return either a FT_Face as a void * or a pointer to stbtt_fontinfo
//
- (void *) internalFontHandle;  // current font if set
- (void *) internalFontHandleOfFont:(CGFont *) font;

@end




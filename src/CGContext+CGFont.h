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


@interface CGContext( CGFont)

- (void) setFont:(CGFont *) font;

- (CGFont *) fallbackFont;
- (CGFont *) fontWithNameUTF8String:(char *) s;
- (CGFloat) fontScale;

- (void) _initFontCache;
- (void) _doneFontCache;
- (void) _resetFontCache;

- (void) useFontWithNameUTF8String:(char *) name;

/*
 * Fill fontCache with fonts, don't use during draws as it does I/O
 */
- (void) addFontWithContentsOfFileWithFileRepresentationString:(char *) filename
                                            fontNameUTF8String:(char *) name;
- (void) addFontWithCData:(struct mulle_data) data
       fontNameUTF8String:(char *) name;
@end




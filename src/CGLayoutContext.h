//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "CGContextBase.h")
#  import "CGContextBase.h"
# endif
#endif

#import "import.h"

// TODO: need to map NANOVG aligns to our own UI enum

@class CGFont;

@interface CGLayoutContext : CGContextBase < UILayoutContext>
{
   struct mulle_map   _fontMap;
   BOOL               _hasLoadedFont;
   char               *_defaultFontName; // will be "sans" will not be freed
}

- (BOOL) hasLoadedFont;

- (CGFloat) fontSizeThatFitsIntoSize:(CGSize) size;
- (BOOL) useFontWithNameUTF8String:(char *) name;

- (struct CGTextMetrics) visualTextMetrics;

@end



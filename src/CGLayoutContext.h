//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "CGContextBase.h")
#  import "CGContextBase.h"
# endif
#endif

#import "import.h"
#include "CGFontFunctionTable.h"

// TODO: need to map NANOVG aligns to our own UI enum

@class CGFont;

@interface CGLayoutContext : CGContextBase < UILayoutContext>
{
   void                          *_fontContext;     // nanovg (or other) font context; may equal _cgBackend.context
   struct CGFontFunctionTable    _fontFunctions;    // function table for font operations
   struct mulle_map              _fontMap;
   BOOL                          _ownsFontContext;  // YES if we created _fontContext (standalone case)
   BOOL                          _hasLoadedFont;
   char                          *_defaultFontName; // will be "sans" will not be freed
}

- (BOOL) hasLoadedFont;

- (CGFloat) fontSizeThatFitsIntoSize:(CGSize) size;
- (BOOL) useFontWithNameUTF8String:(char *) name;

- (struct CGTextMetrics) visualTextMetrics;

@property( assign, getter=isTracingDrawCalls) BOOL   traceDrawCalls MULLE_OBJC_THREADSAFE_METHOD;

@end



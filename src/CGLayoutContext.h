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

- (struct UITextMetrics) visualTextMetrics;

@end


//
// use these functions, during rendering where we assume self->_vg is not
// suddenly changed by someone
//
MULLE_C_CONST_RETURN
static inline struct NVGcontext   *CGLayoutContextGetNVGContext( CGLayoutContext *self)
{
   if( ! self)
      return( NULL);
   return( ((struct{ @defs( CGLayoutContext); } *) self)->_vg);
}


MULLE_C_CONST_RETURN
static inline struct NVGcontext   *_CGLayoutContextGetNVGContext( CGLayoutContext *self)
{
   return( ((struct{ @defs( CGLayoutContext); } *) self)->_vg);
}


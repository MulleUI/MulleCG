//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "CGContextBase.h")
#  import "CGContextBase.h"
# endif
#endif

#import "import.h"


@interface CGLayoutContext : CGContextBase < UILayoutContext>
{
   struct mulle_map   _fontMap;
   BOOL               _hasLoadedFont;
   char               *_defaultFontName; // will be "sans" will not be freed
}

- (BOOL) hasLoadedFont;

@end


static inline struct NVGcontext   *CGLayoutContextGetNVGContext( CGLayoutContext *self)
{
   if( ! self)
      return( NULL);
   return( ((struct{ @defs( CGLayoutContext); } *) self)->_vg);
}


static inline struct NVGcontext   *_CGLayoutContextGetNVGContext( CGLayoutContext *self)
{
   return( ((struct{ @defs( CGLayoutContext); } *) self)->_vg);
}

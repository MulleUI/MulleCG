//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "CGLayoutContext.h")
#  import "CGLayoutContext.h"
# endif
#endif

#import "import.h"

@interface CGLayoutContext( nanovg)

- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) context
                            nameUTF8String:(char *) nameUTF8String;
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


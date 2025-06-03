//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
// prefer a local CGFramebuffer over one in import.h
#ifdef __has_include
# if __has_include( "CGFramebuffer.h")
#  import "CGFramebuffer.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


@interface CGFramebuffer( OpenGL)

// @property( assign) NSUInteger  value;
// @property( retain) id          other;

// - (id) method:(id) other;

@end

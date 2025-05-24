//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

#import "import.h"

// we want "import.h" always anyway
#import "CGDrawable.h"

void  CGContextDrawBitmapDrawableInRect( CGContext *context,
                                         id <CGBitmapDrawable> drawable,
                                         CGRect rect,
                                         CGRect patternRect,
                                         CGDrawableOptions *options);

//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
// prefer a local CGBitmap over one in import.h
#ifdef __has_include
# if __has_include( "CGBitmap.h")
#  import "CGBitmap.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"

char   *CGBitmapPointUTF8String(struct CGBitmapPoint point);
char   *CGBitmapRectUTF8String( struct CGBitmapRect rect);


static inline char   *CGBitmapSizeUTF8String( struct CGBitmapSize size)
{
   return( CGBitmapPointUTF8String( * (struct CGBitmapPoint *) &size));
}

//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
#import "CGBitmap+UTF8String.h"

#import "import-private.h"


char   *CGBitmapPointUTF8String(struct CGBitmapPoint point)
{
   auto char  *s;

   s = MulleObjC_asprintf( "%td %td", point.x, point.y);
   return( s);
}


char   *CGBitmapRectUTF8String( struct CGBitmapRect rect)
{
   auto char  *s;

   s = MulleObjC_asprintf( "%td %td %td %td",
            rect.origin.x,
            rect.origin.y,
            rect.size.width,
            rect.size.height);
   return( s);
}

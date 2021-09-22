#include "CGGeometry+CString.h"

#include "include-private.h"

#include "MulleCG_asprintf.h"

//
// todo: use MulleCG_asprintf here
//
char   *CGPointUTF8String( CGPoint point)
{
   auto char  *s;

   s = MulleCG_asprintf( "%.2f %.2f", point.x, point.y);
   return( s);
}


char   *CGRectUTF8String( CGRect rect)
{
   auto char  *s;

   s = MulleCG_asprintf( "%.2f %.2f %.2f %.2f",
            rect.origin.x,
            rect.origin.y,
            rect.size.width,
            rect.size.height);
   return( s);
}

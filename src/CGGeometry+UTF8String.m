#import "CGGeometry+UTF8String.h"

#import "import-private.h"

char   *CGPointUTF8String( CGPoint point)
{
   auto char  *s;

   s = MulleObjC_asprintf( "%.2f %.2f", point.x, point.y);
   return( s);
}


char   *CGRectUTF8String( CGRect rect)
{
   auto char  *s;

   s = MulleObjC_asprintf( "%.2f %.2f %.2f %.2f",
            rect.origin.x,
            rect.origin.y,
            rect.size.width,
            rect.size.height);
   return( s);
}

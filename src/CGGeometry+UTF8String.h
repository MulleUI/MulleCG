#include "include.h"

char   *CGRectUTF8String( CGRect rect);
char   *CGPointUTF8String( CGPoint point);


static inline char   *CGVectorUTF8String( CGVector point)
{
   return( CGPointUTF8String( * (CGPoint *) &point));
}


static inline char   *CGSizeUTF8String( CGSize size)
{
   return( CGPointUTF8String( * (CGPoint *) &size));
}


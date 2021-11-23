#ifndef cg_bitmap_geometry_h__
#define cg_bitmap_geometry_h__

#include "include.h"

#include <math.h>


static inline struct CGSize    CGBitmapSizeGetSize( struct CGBitmapSize a)
{
   return( CGSizeMake( a.width, a.height));
}

static inline struct CGBitmapSize    CGSizeGetBitmapSize(CGSize a)
{
   return( CGBitmapSizeMake( roundf( a.width), roundf( a.height)));  // round or floor ?
}

static inline CGPoint   CGBitmapPointGetPoint( struct CGBitmapPoint a)
{
   return( CGPointMake( a.x, a.y));
}


static inline struct CGBitmapPoint    CGPointGetBitmapPoint( struct CGPoint a)
{
   return( CGBitmapPointMake( (NSInteger) a.x, (NSInteger) a.y));
}

static inline CGRect   CGBitmapRectGetRect( struct CGBitmapRect a)
{
   return( CGRectMake( a.origin.x, a.origin.y, a.size.width, a.size.height));
}


#endif


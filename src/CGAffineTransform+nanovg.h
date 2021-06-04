#include "CGAffineTransform.h"


typedef float   _NVGtransform[ 6];

//
// "conversion" or rather casting between CGAffineTransform and _NVGtransform
// which is float[ 6]
//
static inline float   *CGAffineTransformRefAs_NVGtransform( CGAffineTransform *xform)
{
   assert( sizeof( float) == sizeof( CGFloat));
   return( &xform->a);
}


static inline CGAffineTransform  *_NVGtransformAsCGAffineTransformRef( _NVGtransform xform)
{
   assert( sizeof( float) == sizeof( CGFloat));
   return( (CGAffineTransform *) xform);
}

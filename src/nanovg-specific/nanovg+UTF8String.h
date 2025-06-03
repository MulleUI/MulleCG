#ifndef nanovg_utf8string_h__
#define nanovg_utf8string_h__

#include "include.h"

#include "CGAffineTransform+nanovg.h"


char   *NVGscissorUTF8String( _NVGtransform value);

static inline char   *_NVGtransformUTF8String( _NVGtransform xform)
{
   return( CGAffineTransformUTF8String( _NVGtransformAsCGAffineTransform( xform)));
}

#endif

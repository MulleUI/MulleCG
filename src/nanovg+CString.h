#import "CGAffineTransform+nanovg.h"

#import "CGAffineTransform+CString.h"


char   *NVGscissorCStringDescription( _NVGtransform value);

static inline char   *_NVGtransformCStringDescription( _NVGtransform xform)
{
   return( CGAffineTransformRefCStringDescription( _NVGtransformAsCGAffineTransformRef( xform)));
}

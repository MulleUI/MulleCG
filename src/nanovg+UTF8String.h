#import "CGAffineTransform+nanovg.h"

#import "CGAffineTransform+UTF8String.h"


char   *NVGscissorUTF8String( _NVGtransform value);

static inline char   *_NVGtransformUTF8String( _NVGtransform xform)
{
   return( CGAffineTransformRefUTF8String( _NVGtransformAsCGAffineTransformRef( xform)));
}

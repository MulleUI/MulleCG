#import "nanovg+CString.h"

#import "import-private.h"

#import "MulleCG_asprintf.h"


char   *NVGscissorUTF8String( _NVGtransform value)
{
   char   *s;

   s = MulleCG_asprintf( "%f %f %f %f %f %f (%f %f)",
            value[ 0], value[ 1], value[ 2],
            value[ 3], value[ 4], value[ 5],
            value[ 6], value[ 7]);
   return( s);
}

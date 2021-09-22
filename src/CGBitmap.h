#import "import.h"


// these definitions are for "framebuffer" bitmaps
struct CGBitmapPoint
{
   NSUInteger   x;
   NSUInteger   y;
};

static inline struct CGBitmapPoint    CGBitmapPointMake(NSUInteger x, NSUInteger y)
{
   return( (struct CGBitmapPoint){ .x = x, .y = y });
}

#define CGBitmapPointZero   CGBitmapPointMake( 0, 0)


static inline CGPoint   CGBitmapPointGetPoint( struct CGBitmapPoint a)
{
   return( CGPointMake( a.x, a.y));
}


struct CGBitmapSize
{
   NSUInteger   width;
   NSUInteger   height;
};

static inline struct CGBitmapSize    CGBitmapSizeMake(NSUInteger w, NSUInteger h)
{
   return( (struct CGBitmapSize){ .width = w, .height = h });
}


static inline CGSize   CGBitmapSizeGetSize( struct CGBitmapSize a)
{
   return( CGSizeMake( a.width, a.height));
}


#define CGBitmapSizeZero  CGBitmapSizeMake( 0, 0)


static inline int   CGBitmapSizeEqualToSize( struct CGBitmapSize a, 
                                             struct CGBitmapSize b) 
{
    return( a.width == b.width && a.height == b.height);
}

struct CGBitmapRect
{
   struct CGBitmapPoint   origin;
   struct CGBitmapSize    size;
};

static inline struct CGBitmapRect    CGBitmapRectMake( NSUInteger x, 
                                                       NSUInteger y,
                                                       NSUInteger w, 
                                                       NSUInteger h)
{
   return( (struct CGBitmapRect){ .origin.x = x, 
                                  .origin.y = y, 
                                  .size.width = w, 
                                  .size.height = h 
                                });
}


static inline CGRect   CGBitmapRectGetRect( struct CGBitmapRect a)
{
   return( CGRectMake( a.origin.x, a.origin.y, a.size.width, a.size.height));
}


#define CGBitmapRectZero   CGBitmapRectMake( 0, 0, 0, 0)


// this is a a mulle addition
// MulleCG can only do CGBitmapEncodingRGBABytes and
// CGBitmapEncodingFlipYRGBABytes
//
// but for MulleUI we will add more encodings...
//
// make it so the lowest bit encodes FP or integer

// fffffffffffonnnbbbt
// t: 0 integer 1: FP
// b: 0: char/float  1:int16_t,double  2:int32_t, 3: int64_t
// n: color count 0-7
// o: 0 not flipped, 1 flipped
// f: 0 RGB(A)
// f: 1 HSV

#define  CGBitmapEncodingMake( f, o, n, b, t) \
   ((f << 8) | (o << 7) | (n << 4) | (b << 1) | t)


enum CGBitmapEncoding
{
   CGBitmapEncodingRGBABytes      = CGBitmapEncodingMake( 0, 0, 4, 0, 0),
   CGBitmapEncodingFlipYRGBABytes = CGBitmapEncodingMake( 0, 1, 4, 0, 0),

   CGBitmapEncodingRGBBytes       = CGBitmapEncodingMake( 0, 0, 3, 0, 0),
};


static inline int  CGBitmapEncodingGetNumberOfColorComponents( enum CGBitmapEncoding e)
{
   return( (e >> 4) & 0x7);
}

static inline int  CGBitmapEncodingIsFlipped( enum CGBitmapEncoding e)
{
   return( (e >> 7) & 0x1);
}


static inline int  CGBitmapEncodingByFlipping( enum CGBitmapEncoding e)
{
   return( e ^ 0x80);
}


static inline int  CGBitmapEncodingIsFP( enum CGBitmapEncoding e)
{
   return( e & 0x1);
}

static inline int  CGBitmapEncodingGetColorSpace( enum CGBitmapEncoding e)
{
   return( e >> 8);
}




// this is a a mulle addition
struct CGBitmapInfo
{
   struct CGBitmapSize     size;
   enum CGBitmapEncoding   encoding;
};


static inline struct CGBitmapInfo
   CGBitmapInfoMake( struct CGBitmapSize size,
                     enum CGBitmapEncoding encoding)
{
   return( (struct CGBitmapInfo){ .size = size,
                                  .encoding = encoding});
}


// simplistic for now, should be smarter later on
static inline NSUInteger   CGBitmapInfoGetSizeInBytes( struct CGBitmapInfo info)
{
   NSUInteger   nPixels;

   nPixels  = info.size.width * info.size.height;
   nPixels *= CGBitmapEncodingGetNumberOfColorComponents( info.encoding);
   return( nPixels);
}


static inline NSUInteger   CGBitmapInfoGetLineLength( struct CGBitmapInfo info)
{
   NSUInteger   nPixels;

   nPixels  = info.size.width;
   nPixels *= CGBitmapEncodingGetNumberOfColorComponents( info.encoding);
   return( nPixels);
}

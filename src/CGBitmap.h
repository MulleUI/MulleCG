#import "import.h"


//
// these definitions are for "framebuffer" bitmaps
// for algorithms its often easier to have point and width as signed
// so for example for a small width (w = 1) something like i <  w - 2
// doesn't suddenly overflow
//
struct CGBitmapPoint
{
   NSInteger   x;
   NSInteger   y;
};

static inline struct CGBitmapPoint    CGBitmapPointMake( NSInteger x, NSInteger y)
{
   return( (struct CGBitmapPoint){ .x = x, .y = y });
}

#define CGBitmapPointZero   CGBitmapPointMake( 0, 0)


static inline CGPoint   CGBitmapPointGetPoint( struct CGBitmapPoint a)
{
   return( CGPointMake( a.x, a.y));
}


static inline struct CGBitmapPoint    CGPointGetBitmapPoint( struct CGPoint a)
{
   return( CGBitmapPointMake( (NSInteger) a.x, (NSInteger) a.y));
}


struct CGBitmapSize
{
   NSInteger   width;
   NSInteger   height;
};

static inline struct CGBitmapSize    CGBitmapSizeMake(NSInteger w, NSInteger h)
{
   assert( w >= 0);
   assert( h >= 0);

   return( (struct CGBitmapSize){ .width = w, .height = h });
}

#define CGBitmapSizeZero  CGBitmapSizeMake( 0, 0)


static inline int   CGBitmapSizeEqualToSize( struct CGBitmapSize a,
                                             struct CGBitmapSize b)
{
    return( a.width == b.width && a.height == b.height);
}


static inline struct CGSize    CGBitmapSizeGetSize( struct CGBitmapSize a)
{
   return( CGSizeMake( a.width, a.height));
}

static inline struct CGBitmapSize    CGSizeGetBitmapSize(CGSize a)
{
   return( CGBitmapSizeMake( roundf( a.width), roundf( a.height)));  // round or floor ?
}



struct CGBitmapRect
{
   struct CGBitmapPoint   origin;
   struct CGBitmapSize    size;
};

static inline struct CGBitmapRect    CGBitmapRectMake( NSInteger x,
                                                       NSInteger y,
                                                       NSInteger w,
                                                       NSInteger h)
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

// ffffobbbtnnn
// ------------
// 109876543210
// 110000000000
// n: color count 0-7
// t: 0 integer 1: FP
// b: 0: char/float  1:int16_t,double  2:int32_t, 3: int64_t
// o: 0 not flipped, 1 flipped
// f: 0 RGB(A)
// f: 1 HSV

#define  CGBitmapEncodingMake( f, o, b, t, n) \
   (((f & 0xF) << 8) | ((o & 0x1) << 7) | ((b & 0x7) << 4) | ((t & 0x1) << 3) | (n & 0x7))


enum CGBitmapEncoding
{
   CGBitmapEncodingRGBABytes      = CGBitmapEncodingMake( 0, 0, 0, 0, 4),
   CGBitmapEncodingFlipYRGBABytes = CGBitmapEncodingMake( 0, 1, 0, 0, 4),

   CGBitmapEncodingRGBBytes       = CGBitmapEncodingMake( 0, 0, 0, 0, 3),
};


static inline int  CGBitmapEncodingGetNumberOfColorComponents( enum CGBitmapEncoding e)
{
   return( e & 0x7);
}

// for now, as we don't have float and other representations
static inline size_t  CGBitmapEncodingGetSizeOfPixel( enum CGBitmapEncoding e)
{
   return( CGBitmapEncodingGetNumberOfColorComponents( e));
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
   return( (e >> 3) & 0x1);
}


static inline int  CGBitmapEncodingGetColorSpace( enum CGBitmapEncoding e)
{
   return( e >> 8);
}


// this is a a mulle addition
struct CGBitmapInfo
{
   struct CGBitmapSize     size;
   NSInteger               stride;
   enum CGBitmapEncoding   encoding;
};


static inline struct CGBitmapInfo
   CGBitmapInfoMake( struct CGBitmapSize size,
                     NSInteger stride,
                     enum CGBitmapEncoding encoding)
{
   return( (struct CGBitmapInfo){ .size = size,
                                  .stride = stride
                                                ? stride
                                                : size.width * CGBitmapEncodingGetSizeOfPixel( encoding),
                                  .encoding = encoding});
}



static inline struct CGBitmapSize   CGBitmapInfoGetSize( struct CGBitmapInfo info)
{
   return( info.size);
}

static inline NSInteger   CGBitmapInfoGetStride( struct CGBitmapInfo info)
{
   return( info.stride);
}

static inline enum CGBitmapEncoding   CGBitmapInfoGetEncoding( struct CGBitmapInfo info)
{
   return( info.encoding);
}

static inline NSUInteger   CGBitmapInfoGetAllocationSize( struct CGBitmapInfo info)
{
   NSInteger   size;

   size = info.stride * info.size.height;
   return( size < 0 ? -size : size);
}

//
// This is always less or equal to stride. Stride could have some padding
// pixels.
//
static inline NSInteger   CGBitmapInfoGetLineLength( struct CGBitmapInfo info)
{
   NSInteger   nPixels;

   nPixels  = info.size.width;
   nPixels *= CGBitmapEncodingGetSizeOfPixel( info.encoding);
   return( nPixels);
}


static inline NSInteger   CGBitmapInfoGetLineByteOffset( struct CGBitmapInfo info,
                                                         NSInteger y)
{
   return( info.stride * y);
}


static inline NSInteger   CGBitmapInfoGetByteOffset( struct CGBitmapInfo info, CGPoint point)
{
   assert( info.size.width > 0);
   assert( info.size.height > 0);
   assert( point.x < info.size.width);
   assert( point.y < info.size.height);

   return( info.stride * point.y + point.x * CGBitmapEncodingGetSizeOfPixel( info.encoding));
}



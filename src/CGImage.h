#import "import.h"


@class CGContext;

// If you have a bitmap image, you have a certain extent of bytes in
// x and y axis, starting at 0.0. Easy, that's the size. The "canvas"
// is "{{ 0, 0 } size }". Asuming we have an algorithm that calculates how
// many transparent pixels on the outside, we can also calculate the "bounds".
// For an opaque bitmap image, that just the same as the canvas. Otherwise
// the bounds are a smaller rect in the canvas.
//
// canvas.origin (0,0)
//       .------------.
//    bounds.origin   |
//       |  .------.  |
//       |  | ABCD |  |
//       |  | ABCD |  |
//       |  | ABCD |  |
//       |  '------'  |
//       |   bounds.size
//       '------------'
//              canvas.size
//
// For vector graphics things are different as you can easily draw into
// negative coordinates. But a file format like SVG has a concept of width
// and height. We keep it same, same. The canvas is "{{ 0, 0 } size }",
// the bounds specify the actual drawing space covered (including stroke
// extent (but no aliasing pixel space)
//
//
//      canvas.origin (0,0)
//            .------------.
// bounds.origin           |
//       .-------------.   |
//       | ABCDEFGHIJK |   |
//       | ABCDEFGHIJK |   |
//       | ABCDEFGHIJK |   |
//       '-------------'   |
//            |  bounds.size
//            '------------'
//                    canvas.size
//
PROTOCOLCLASS_INTERFACE0( CGImage)

//
// Derive an image, that supports the given NVGflags. If the value can not be
// supported by the MulleImage subclass, this will return nil.
//
// Textures (images) in NVG can be created with different flags, for example
// REPEAT_X andREPEAT_Y. When we are asking the CGContext for a textureID
// for an image this will create such a NVG texture. As the context cashes the
// textureID for each MulleImage it's simplest to store the nvgImageFlags here
// (readonly) and to clone MulleImages for different flags. The actual image
// data can be shared w/o a problem. The default is 0:
//
//
- (id <CGImage>) imageWithNVGImageFlags:(int) flags;
- (CGSize) size;


//
// rect is the canvas to draw to
// corneradius is used for bitmap images only
// shade is used with bitmap for alpha and vector images
- (void) drawRect:(CGRect) rect
     cornerRadius:(CGFloat) radius
            alpha:(CGFloat) alpha
          context:(CGContext *) context;

@optional
- (NSUInteger) nvgImageFlags; // default 0
- (CGRect) canvas;   // always 0,0, size
- (CGRect) bounds;   // usually same as canvas for bitmaps

PROTOCOLCLASS_END()



@protocol CGVectorImage <CGImage>
@end


// make it so the lowest bit encodes FP or integer
// fffffffffffnnnnt
// next bits is size-1 * char for
// t: 0 integer, 1: FP
//    n: 0 char      n:0 float
// f: 0 RGBA


enum MulleBitmapEncoding
{
   MulleBitmapEncodingRGBABytes = ((0 << 5) | 0 | 0)  // only one we know ATM
};


struct MulleBitmapSize
{
   NSUInteger   width;
   NSUInteger   height;
};


struct MulleBitmapInfo
{
   struct MulleBitmapSize     size;
   NSUInteger                 nColorComponents;  // this is 0-4 of bytes
   enum MulleBitmapEncoding   encoding;
};


static inline NSUInteger   MulleBitmapInfoGetSizeInBytes( struct MulleBitmapInfo info)
{
   switch( info.encoding)
   {
   case MulleBitmapEncodingRGBABytes :
      return( info.size.width * info.size.height * info.nColorComponents);
   }
}

//
// The base _CGBitmapImage does not let access you bytes, as it is also used
// for CGLayer, which has a texture that resides on the GPU so not in our
// addresspace.
//
PROTOCOLCLASS_INTERFACE( _CGBitmapImage, CGImage)

- (struct MulleBitmapInfo) bitmapInfo;

@optional
- (struct MulleBitmapSize) bitmapSize;  // just integer value of size
- (void) drawRect:(CGRect) rect
     cornerRadius:(CGFloat) radius
            alpha:(CGFloat) alpha
          context:(CGContext *) context;
- (int) textureIDWithContext:(CGContext *) context;


PROTOCOLCLASS_END()


//
// this is a bitmap image we can access bytes
//
PROTOCOLCLASS_INTERFACE( CGBitmapImage, _CGBitmapImage)

- (void *) bytes;

PROTOCOLCLASS_END()


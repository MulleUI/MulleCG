#import "import.h"


// The whole "drawable" concept doesn't exist in CoreGraphics

//
//                                             .------------.
//                                             | CGDrawable |--------.
//                                             '------------'        |
//   .---------.                                      |              |
//   | CGImage |------------------------.             |              |
//   '---------'          |             |             |              |
//        |               |             |             |              |
//        |               |             |             |              |
//        |               |             |             |              |
//        |               |             v             |              |
//        |               |   .------------------.    |              |
//        |               |   | CGBitmapDrawable |<---'              |
//        |               |   '------------------'                   |
//        |               |                                          |
//        |               |                                          |
//        v               v                                          |
//   .---------. .----------------.                                  |
//   | CGLayer | | CGTextureImage |                                  v
//   '---------' '----------------'                        .------------------.
//                                                         | CGVectorDrawable |
//                                                         '------------------'
//                 .---------.         .---------------.             ^
//               .-| UIImage |-------->| UISVGImage |-------------'
//               | '---------'         '---------------'
//               |
//               |
//               v
//     .------------------.
//     | UIBitmapImage |
//     '------------------'
//
//
// Drawable is the common base for vector drawings and bitmap drawings.
//
// If you have a bitmap image, you have a certain extent of bytes in
// x and y axis, starting at 0.0. Easy, that's the size. The "canvas"
// is "{{ 0, 0 }, size }". Asuming we have an algorithm that calculates how
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
// and height. We keep it same, same. The canvas is "{{ 0, 0 }, size }",
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


@class CGContext;


typedef struct CGDrawableOptions
{
   CGFloat   cornerRadius;
   CGFloat   alpha;
   CGFloat   rotation;      // 0 means no rotation
   BOOL      scale;
} CGDrawableOptions;


static inline CGDrawableOptions   CGDrawableOptionsMake( CGFloat cornerRadius,
                                                         CGFloat alpha,
                                                         CGFloat rotation,
                                                         BOOL scale)
{
   return( (CGDrawableOptions) { .cornerRadius = cornerRadius,
                                 .alpha        = alpha,
                                 .rotation     = rotation,
                                 .scale        = scale });
}


//
// A CGDrawable can draw itself in a context. In case of a vector image, this
// is likely just a series of draw commands. This kind of drawable can be used
// in multiple contexts without problem. A bitmap drawable has to be transferred
// to a nvg texture first. This texture is context dependent. The most simple
// CGTextureImage has a 1:1 connection with a context. You can not copy it
// to another context.
//

PROTOCOLCLASS_INTERFACE0( CGDrawable)

- (CGSize) size;


//
// rect is the canvas to draw to
// corneradius is used for bitmap images only
// shade is used with bitmap for alpha and vector images
- (void) drawRect:(CGRect) rect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context;

@optional
- (CGRect) canvas;   // always 0,0, size
- (CGRect) bounds;   // usually same as canvas for bitmaps

PROTOCOLCLASS_END()


// somewhat superflous
@protocol CGVectorDrawable <CGDrawable>
@end



//
// The base CGBitmapDrawable does not let access you bytes, as it is also used
// by textures that resides on the GPU so not in our addresspace.
//
//
PROTOCOLCLASS_INTERFACE( CGBitmapDrawable, CGDrawable)

- (NSInteger) nvgImageWithContext:(CGContext *) context
                       imageFlags:(NSUInteger) imageFlags;

- (struct CGBitmapInfo) bitmapInfo;

@optional
- (struct CGBitmapSize) bitmapSize;  // just integer value of size
- (void) drawRect:(CGRect) rect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context;

- (void) drawRect:(CGRect) rect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context
          imageID:(NSInteger) imageID
       imageFlags:(NSUInteger) imageFlags;

// -1, then it didn't work
- (NSInteger) imageFlags; // default 0


// default returns NULL, for images which aren't accessible
- (void *) bytes;

PROTOCOLCLASS_END()

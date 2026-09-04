//
//  CGDrawable.h
//  MulleCG
//
//  Copyright (c) 2021 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#import "import.h"


// The whole "drawable" concept doesn't exist in CoreGraphics
//
//
//                                             .------------.
//                                             | CGDrawable |--------.
//                                             '------------'        |
//   .---------.                                      |              |
//   | CGImage |------------------------.             |              |
//   '---------'                        |             |              |
//        |                             v             |              |
//        |                   .------------------.    |              |
//        |                   | CGBitmapDrawable |<---'              |
//        |                   '------------------'                   |
//        v                                                          |
//   .---------------.                                               |
//   | CGFramebuffer |                                               v
//   '---------------'                                     .------------------.
//                                                         | CGVectorDrawable |
//                                                         '------------------'
//                 .---------.         .-------------.             ^
//               .-| UIImage |-------->| UISVGImage  |-------------'
//               | '---------'         '-------------'
//               |
//               v
//     .---------------.
//     | UIBitmapImage |
//     '---------------'
//
// CGDrawable is the common base for vector drawings (CGVectorDrawable) and
// bitmap drawings (CGBitmapDrawable). UIImage is the base for off-GPU images,
// vector style (UISVGImage) or bitmap style (UIBitmapImage). CGImage is the
// base for on-GPU images (e.g. textures).
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

typedef NS_ENUM( NSUInteger, CGFlip)
{
   CGFlipNone         = 0x0,
   CGFlipHorizontally = 0x1,
   CGFlipVertically   = 0x2,
   CGFlipBoth         = 0x3
};

typedef NS_ENUM( NSUInteger, CGRepeat)
{
   CGRepeatAsIs         = 0x0,  // repeat if indicated by textureFlags
   CGRepeatHorizontally = 0x1,
   CGRepeatVertically   = 0x2,
   CGRepeatBoth         = 0x3,
   CGRepeatNone         = 0x4
};


#define CGScaleToFit    0.0
#define CGScaleNone     1.0

#define CGRotationNone  0.0


typedef struct CGDrawableOptions
{
   CGFloat             alpha;
   MulleCornerInsets   cornerInsets;  // cornerInsets are used for bitmap images only
   CARotation          rotation;      // 0 means no rotation
   CGFloat             scale;         // 0.0 means scale to fit,
   struct
   {
      unsigned int   flip             : 3;
      unsigned int   repeat           : 3;
      unsigned int   contentMode      : 4;
      unsigned int   textureOverreach : 1;  // disables drawRect:fromRect: fix
   } flags;
} CGDrawableOptions;


extern CGDrawableOptions   CGDrawableOptionsDefault;
extern CGDrawableOptions   CGDrawableOptionsScaleToFit;


static inline CGDrawableOptions   CGDrawableOptionsMakeWithCornerRadius( CGFloat cornerRadius,
                                                                         CGFloat alpha,
                                                                         CARotation rotation,
                                                                         CGFloat scale,
                                                                         CGFlip flip,
                                                                         CGRepeat repeat,
                                                                         CGContentMode contentMode)
{
   return( (CGDrawableOptions) {
                                 .alpha                    = alpha,
                                 .cornerInsets.topLeft     = cornerRadius,
                                 .cornerInsets.topRight    = cornerRadius,
                                 .cornerInsets.bottomLeft  = cornerRadius,
                                 .cornerInsets.bottomRight = cornerRadius,
                                 .rotation                 = rotation,
                                 .scale                    = scale,
                                 .flags.flip               = flip,
                                 .flags.repeat             = repeat,
                                 .flags.contentMode        = contentMode
                              });
}


static inline CGDrawableOptions   CGDrawableOptionsMake( MulleCornerInsets cornerInsets,
                                                         CGFloat alpha,
                                                         CARotation rotation,
                                                         CGFloat scale,
                                                         CGFlip flip,
                                                         CGRepeat repeat,
                                                         CGContentMode contentMode)
{
   return( (CGDrawableOptions) {
                                 .alpha             = alpha,
                                 .cornerInsets      = cornerInsets,
                                 .rotation          = rotation,
                                 .scale             = scale,
                                 .flags.flip        = flip,
                                 .flags.repeat      = repeat,
                                 .flags.contentMode = contentMode
                              });
}


static inline CGDrawableOptions   CGDrawableOptionsMakeDefault( void)
{
   return( CGDrawableOptionsMakeWithCornerRadius( 0.0f,
                                                  1.0f,
                                                  CGRotationNone,
                                                  CGScaleNone,
                                                  CGFlipNone,
                                                  CGRepeatAsIs,
                                                  CGContentModeCenterPoint));
}


static inline CGDrawableOptions   CGDrawableOptionsMakeScaleToFit( void)
{
   return( CGDrawableOptionsMakeWithCornerRadius( 0.0f,
                                                  1.0f,
                                                  CGRotationNone,
                                                  CGScaleToFit,
                                                  CGFlipNone,
                                                  CGRepeatAsIs,
                                                  CGContentModeCenterPoint));
}                



//
// A CGDrawable can draw itself in a context. In case of a vector image, this
// is likely just a series of draw commands. This kind of drawable can be used
// in multiple contexts without problem. A bitmap drawable has to be transferred
// to a CGDrawableImage first. This CGDrawableImage is context dependent.
// The most simple CGDrawableImage has a 1:1 connection with the context.
// You can not copy it to another context.
//

@protocol CGDrawable

- (CGSize) size;

//
// rect is the canvas to draw to.
//
- (void) drawRect:(CGRect) rect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context;

- (CGRect) canvas;      // always 0,0, size
- (CGRect) bounds;      // usually same as canvas for bitmaps
- (BOOL) isRepeating;   // ususually NO, used by repeating bitmaps

@end


@class CGImage;
//
// The base CGBitmapDrawable does not let access you bytes, as it is also used
// by textures that resides on the GPU so not in our addresspace.
//
//
@mixin CGBitmapDrawable < CGDrawable>

@required
// this is called by drawRect to get a texture from the desired options.
// The textureFlags in CGImage are not necessarily identical to
// the passed in value, but reflect the actual image settings.Mostly this
// means that a texture may be requested as flipped, but it is already, so
// the textureFlags for FLIP_X are off
- (CGImage *) cgImageWithContext:(CGContext *) context
                    textureFlags:(NSUInteger) textureFlags;

- (struct CGBitmapInfo) bitmapInfo;

@optional
- (CGPixelSize) bitmapSize;  // just integer value of size

//
// this calls drawRect:options:context:drawableBitmapImage: after calling
// cgImageWithContext:textureFlags:
// A bitmap drawing is always centered, to make scaling and rotation
// more useful.
//
- (void) drawRect:(CGRect) rect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context;

// TODO: vector code could just clip I guess ?
- (void) drawRect:(CGRect) rect
         fromRect:(CGRect) fromRect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context;

// default returns NULL, for images which aren't accessible
- (void *) bytes;

- (NSUInteger) textureFlags;

@end



@mixin CGVectorDrawable < CGDrawable>

@optional

- (CGRect) canvas;      // always 0,0, size
- (CGRect) bounds;      // usually same as canvas for bitmaps
- (BOOL) isRepeating;   // ususually NO, used by repeating bitmaps

@end


MULLE_CG_GLOBAL
CGPoint  CGRectGetCenterAtAngle( CGRect patternRect, CAAngle angle);

MULLE_CG_GLOBAL
CGPoint  CGRectGetCenterAtAngleWithScaling( CGRect patternRect,
                                                 CAAngle rotation,
                                                 CGVector scaleFactor);

MULLE_CG_GLOBAL
CGSize   CGBitmapDrawableGetBitmapExtent( id <CGBitmapDrawable> self,
                                          CGSize size,
                                          CGSize bitmapSize,
                                          CGDrawableOptions *options);


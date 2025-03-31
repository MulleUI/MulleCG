//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "CGPaint.h")
#  import "CGPaint.h"
# endif
#endif

#import "import.h"


typedef NS_ENUM( NSUInteger, CGImagePaintBlendStyle)
{
   CGImagePaintBlendAlpha = 0
};


@class CGImage;


//
// this paint exists for the sake of animation, you have two images and
// can interpolate between both with "blend". Currently only alpha blending
// is supported.
//
@interface CGImagePaint : CGPaint

@property( readonly) CGFloat   blend;
//@property( assign) CGImagePaintBlendStyle   blendStyle;
@property( readonly) CGFloat   rotation;
@property( readonly) CGImage   *image;
@property( readonly) CGImage   *otherImage;

+ (instancetype) imagePaintWithImage:(CGImage *) image
                          otherImage:(CGImage *) otherImage
                               blend:(CGFloat) blend
                            rotation:(CGFloat) angle;

- (instancetype) initWithImage:(CGImage *) image
                    otherImage:(CGImage *) otherImage
                         blend:(CGFloat) blend
                      rotation:(CGFloat) rotation;

@end

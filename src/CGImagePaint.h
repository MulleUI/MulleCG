//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "CGPaint.h")
#  import "CGPaint.h"
# endif
#endif

#import "import.h"


@class CGImage;

//
// if you want to rotate or "add" alpha to an image and want to use
// nanovg drawing functions (maybe better not, prefer CGDrawable interface
// for easier rotation) then use a CGImagePaint.
//
@interface CGImagePaint : CGPaint

@property( readonly, retain) CGImage   *image;
@property( readonly) CGFloat           alpha;
@property( readonly) CARotation        rotation;

- (instancetype) initWithImage:(CGImage *) image
                      rotation:(CARotation) rotation
                         alpha:(CGFloat) alpha;

@end


@interface CGPaint( CGImagePaint)

+ (instancetype) paintWithImage:(CGImage *) image
                       rotation:(CARotation) rotation
                          alpha:(CGFloat) alpha;

@end

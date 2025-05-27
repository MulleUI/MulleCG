//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "CGPaint.h")
#  import "CGPaint.h"
# endif
#endif

#import "import.h"

typedef NS_ENUM( NSUInteger, CGBlendedPaintBlendStyle)
{
   CGBlendedPaintBlendAlpha = 0
};


//
// this paint exists for the sake of animation, you have two paints and
// can interpolate between both with "blend". Currently only alpha blending
// is supported.
//
@interface CGBlendedPaint : CGPaint

@property( readonly) CGFloat     blend;
//@property( assign) CGBlendedPaintBlendStyle   blendStyle;
@property( readonly) CARotation  rotation;
@property( readonly) CGPaint     *paint;
@property( readonly) CGPaint     *otherPaint;

- (instancetype) initWithPaint:(CGPaint *) paint
                    otherPaint:(CGPaint *) otherPaint
                         blend:(CGFloat) blend
                      rotation:(CARotation) rotation;

@end


// class clustering... :)
@interface CGPaint( CGBlendedPaint)

+ (instancetype) paintWithPaint:(CGPaint *) paint
                     otherPaint:(CGPaint *) otherPaint
                          blend:(CGFloat) blend
                       rotation:(CARotation) rotation;

@end

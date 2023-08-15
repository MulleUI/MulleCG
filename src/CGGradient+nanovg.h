//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
// prefer a local CGGradient over one in import.h
#ifdef __has_include
# if __has_include( "CGGradient.h")
#  import "CGGradient.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


#import "CGPaint+nanovg.h"


@interface CGGradient( nanovg)

- (NVGpaint) linearGradientNVGpaintWithBounds:(CGRect) rect
                                   NVGcontext:(NVGcontext *) vg;

//
// Use this usually for rotating a gradient around a shape
// smoothness is usually 1.0f, unless you want a harder gradient
// rotation is usually 0.0f to 1.0f
//
// An easy way to get more than just two color gradients, use two gradients
// with color alphas of 0.5 and fill twice (or fallback on OpenGL)
//
- (NVGpaint) linearGradientNVGpaintWithBounds:(CGRect) rect
                                   smoothness:(CGFloat) smoothness
                                   NVGcontext:(NVGcontext *) vg;

// this will rotate the gradient as if it was a giant rectangle
- (NVGpaint) rectangularLinearGradientNVGpaintWithBounds:(CGRect) rect
                                              smoothness:(CGFloat) smoothness
                                              NVGcontext:(NVGcontext *) vg;

//
// A box gradient is just a linear two color gradient with the "feather"
// It's prime use is shadows...
//
- (NVGpaint) boxGradientNVGpaintWithBounds:(CGRect) rect
                              cornerRadius:(CGFloat) radius
                                   feather:(CGFloat) feather
                                NVGcontext:(NVGcontext *) vg;

- (NVGpaint) radialGradientNVGpaintWithCircle:(CACircle) circle
                                  innerRadius:(CGFloat) innerRadius
                                   NVGcontext:(NVGcontext *) vg;

@end


// will use radialGradient!
void   mvgFillCircleWithGradient( NVGcontext *vg,
                                  CACircle circle,
                                  CGGradient *gradient);
// will use radialGradient!
void   mvgStrokeCircleWithGradient( NVGcontext *vg,
                                    CACircle circle,
                                    CGFloat strokeWidth,
                                    CGGradient *gradient);


static inline void   mvgFillRoundedRectWithGradient( NVGcontext *vg,
                                                     CGRect rect,
                                                     CGFloat cornerRadius,
                                                     CGGradient *gradient)
{
   mvgFillRoundedRectWithPaint( vg, rect, cornerRadius, gradient);
}


MULLE_CG_EXTERN_GLOBAL
void   mvgFillRoundedRectWithLinearGradient( NVGcontext *vg,
                                             CGRect rect,
                                             CGFloat cornerRadius,
                                             CGFloat smoothness,
                                             CGGradient *gradient);

MULLE_CG_EXTERN_GLOBAL
void   mvgFillRoundedRectWithRectangularLinearGradient( NVGcontext *vg,
                                                        CGRect rect,
                                                        CGFloat cornerRadius,
                                                        CGFloat smoothness,
                                                        CGGradient *gradient);

MULLE_CG_EXTERN_GLOBAL
void   mvgStrokeRoundedRectWithLinearGradient( NVGcontext *vg,
                                               CGRect rect,
                                               CGFloat cornerRadius,
                                               CGFloat strokeWidth,
                                               CGFloat smoothness,
                                               CGGradient *gradient);

MULLE_CG_EXTERN_GLOBAL
void   mvgStrokeRoundedRectWithRectangularLinearGradient( NVGcontext *vg,
                                                          CGRect rect,
                                                          CGFloat cornerRadius,
                                                          CGFloat strokeWidth,
                                                          CGFloat smoothness,
                                                          CGGradient *gradient);


static inline void   mvgFillRectWithGradient( NVGcontext *vg,
                                              CGRect rect,
                                              CGGradient *gradient)
{
   mvgFillRectWithPaint( vg, rect, gradient);
}



static inline void   mvgStrokeRoundedRectWithGradient( NVGcontext *vg,
                                                       CGRect rect,
                                                       CGFloat cornerRadius,
                                                       CGFloat strokeWidth,
                                                       CGGradient *gradient)
{
   mvgStrokeRoundedRectWithPaint( vg, rect, cornerRadius, strokeWidth, gradient);
}


static inline void    mvgStrokeRectWithGradient( NVGcontext *vg,
                                                 CGRect rect,
                                                 CGFloat strokeWidth,
                                                 CGGradient *gradient)
{
   mvgStrokeRectWithPaint( vg, rect, strokeWidth, gradient);
}



static inline void   mvgStrokeLineWithGradient( NVGcontext *vg,
                                                CGPoint start,
                                                CGPoint end,
                                                CGFloat strokeWidth,
                                                CGGradient *gradient)
{
   mvgStrokeLineWithPaint( vg, start, end, strokeWidth, gradient);
}


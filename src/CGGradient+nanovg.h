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

- (NVGpaint) boxGradientNVGpaintWithBounds:(CGRect) rect
                              cornerRadius:(CGFloat) radius
                                   feather:(CGFloat) feather
                                NVGcontext:(NVGcontext *) vg;

- (NVGpaint) radialGradientNVGpaintWithCenter:(CGPoint) center
                                  innerRadius:(CGFloat) innerRadius
                                  outerRadius:(CGFloat) outerRadius
                                   NVGcontext:(NVGcontext *) vg;

@end


// will use radialGradient!
void   mvgFillCircleWithGradient( NVGcontext *vg,
                                  CGPoint center,
                                  CGFloat radius,
                                  CGGradient *gradient);
// will use radialGradient!
void   mvgStrokeCircleWithGradient( NVGcontext *vg,
                                    CGPoint center,
                                    CGFloat radius,
                                    CGFloat strokeWidth,
                                    CGGradient *gradient);


static inline void   mvgFillRoundedRectWithGradient( NVGcontext *vg,
                                                     CGRect rect,
                                                     CGFloat cornerRadius,
                                                     CGGradient *gradient)
{
   mvgFillRoundedRectWithPaint( vg, rect, cornerRadius, gradient);
}



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


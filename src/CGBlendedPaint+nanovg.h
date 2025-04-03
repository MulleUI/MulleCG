//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
// prefer a local CGBlendedPaint over one in import.h
#ifdef __has_include
# if __has_include( "CGBlendedPaint.h")
#  import "CGBlendedPaint.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


#import "CGPaint+nanovg.h"


@interface CGBlendedPaint( nanovg)
@end

// MEMO: not super sure why we need this ?
static inline void   mvgFillRoundedRectWithBlendedPaint( NVGcontext *vg,
                                                         CGRect rect,
                                                         CGFloat cornerRadius,
                                                         CGBlendedPaint *blendedPaint)
{
   mvgFillRoundedRectWithPaint( vg, rect, cornerRadius, blendedPaint);
}


static inline void   mvgFillRectWithBlendedPaint( NVGcontext *vg,
                                                  CGRect rect,
                                                  CGBlendedPaint *blendedPaint)
{
   mvgFillRectWithPaint( vg, rect, blendedPaint);
}


static inline void   mvgFillCircleWithBlendedPaint( NVGcontext *vg,
                                                    CACircle circle,
                                                    CGBlendedPaint *blendedPaint)
{
   mvgFillCircleWithPaint( vg, circle, blendedPaint);
}


static inline void   mvgStrokeRoundedRectWithBlendedPaint( NVGcontext *vg,
                                                           CGRect rect,
                                                           CGFloat cornerRadius,
                                                           CGFloat strokeWidth,
                                                           CGBlendedPaint *blendedPaint)
{
   mvgStrokeRoundedRectWithPaint( vg, rect, cornerRadius, strokeWidth, blendedPaint);
}


static inline void   mvgStrokeRectWithBlendedPaint( NVGcontext *vg,
                                                    CGRect rect,
                                                    CGFloat strokeWidth,
                                                    CGBlendedPaint *blendedPaint)
{
   mvgStrokeRectWithPaint( vg, rect, strokeWidth, blendedPaint);
}


static inline void   mvgStrokeCircleWithBlendedPaint( NVGcontext *vg,
                                                      CACircle circle,
                                                      CGFloat strokeWidth,
                                                      CGBlendedPaint *blendedPaint)
{
   mvgStrokeCircleWithPaint( vg, circle, strokeWidth, blendedPaint);
}


static inline void   mvgStrokeLineWithBlendedPaint( NVGcontext *vg,
                                                    CGPoint start,
                                                    CGPoint end,
                                                    CGFloat strokeWidth,
                                                    CGBlendedPaint *blendedPaint)
{
   mvgStrokeLineWithPaint( vg, start, end, strokeWidth, blendedPaint);
}


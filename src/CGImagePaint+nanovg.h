//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
// prefer a local CGImagePaint over one in import.h
#ifdef __has_include
# if __has_include( "CGImagePaint.h")
#  import "CGImagePaint.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


#import "CGPaint+nanovg.h"


@interface CGImagePaint( nanovg)
@end


static inline void   mvgFillRoundedRectWithImagePaint( NVGcontext *vg,
                                                       CGRect rect,
                                                       CGFloat cornerRadius,
                                                       CGImagePaint *imagePaint)
{
   mvgFillRoundedRectWithPaint( vg, rect, cornerRadius, imagePaint);
}


static inline void   mvgFillRectWithImagePaint( NVGcontext *vg,
                                                CGRect rect,
                                                CGImagePaint *imagePaint)
{
   mvgFillRectWithPaint( vg, rect, imagePaint);
}


static inline void   mvgFillCircleWithImagePaint( NVGcontext *vg,
                                                  CGPoint center,
                                                  CGFloat radius,
                                                  CGImagePaint *imagePaint)
{
   mvgFillCircleWithPaint( vg, center, radius, imagePaint);
}


static inline void   mvgStrokeRoundedRectWithImagePaint( NVGcontext *vg,
                                                         CGRect rect,
                                                         CGFloat cornerRadius,
                                                         CGFloat strokeWidth,
                                                         CGImagePaint *imagePaint)
{
   mvgStrokeRoundedRectWithPaint( vg, rect, cornerRadius, strokeWidth, imagePaint);
}


static inline void   mvgStrokeRectWithImagePaint( NVGcontext *vg,
                                                  CGRect rect,
                                                  CGFloat strokeWidth,
                                                  CGImagePaint *imagePaint)
{
   mvgStrokeRectWithPaint( vg, rect, strokeWidth, imagePaint);
}


static inline void   mvgStrokeCircleWithImagePaint( NVGcontext *vg,
                                                    CGPoint center,
                                                    CGFloat radius,
                                                    CGFloat strokeWidth,
                                                    CGImagePaint *imagePaint)
{
   mvgStrokeCircleWithPaint( vg, center, radius, strokeWidth, imagePaint);
}


static inline void   mvgStrokeLineWithImagePaint( NVGcontext *vg,
                                                  CGPoint start,
                                                  CGPoint end,
                                                  CGFloat strokeWidth,
                                                  CGImagePaint *imagePaint)
{
   mvgStrokeLineWithPaint( vg, start, end, strokeWidth, imagePaint);
}


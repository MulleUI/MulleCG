//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
// prefer a local CGImage over one in import.h
#ifdef __has_include
# if __has_include( "CGImage.h")
#  import "CGImage.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


#import "CGPaint+nanovg.h"


@interface CGImage( nanovg)
@end


static inline void   mvgFillRoundedRectWithImage( NVGcontext *vg,
                                                  CGRect rect,
                                                  CGFloat cornerRadius,
                                                  CGImage *image)
{
   mvgFillRoundedRectWithPaint( vg, rect, cornerRadius, image);
}


static inline void   mvgFillRectWithImage( NVGcontext *vg,
                                           CGRect rect,
                                           CGImage *image)
{
   mvgFillRectWithPaint( vg, rect, image);
}


static inline void   mvgFillCircleWithImage( NVGcontext *vg,
                                             CGPoint center,
                                             CGFloat radius,
                                             CGImage *image)
{
   mvgFillCircleWithPaint( vg, center, radius, image);
}


static inline void   mvgStrokeRoundedRectWithImage( NVGcontext *vg,
                                                    CGRect rect,
                                                    CGFloat cornerRadius,
                                                    CGFloat strokeWidth,
                                                    CGImage *image)
{
   mvgStrokeRoundedRectWithPaint( vg, rect, cornerRadius, strokeWidth, image);
}


static inline void   mvgStrokeRectWithImage( NVGcontext *vg,
                                             CGRect rect,
                                             CGFloat strokeWidth,
                                             CGImage *image)
{
   mvgStrokeRectWithPaint( vg, rect, strokeWidth, image);
}


static inline void   mvgStrokeCircleWithImage( NVGcontext *vg,
                                               CGPoint center,
                                               CGFloat radius,
                                               CGFloat strokeWidth,
                                               CGImage *image)
{
   mvgStrokeCircleWithPaint( vg, center, radius, strokeWidth, image);
}


static inline void   mvgStrokeLineWithImage( NVGcontext *vg,
                                             CGPoint start,
                                             CGPoint end,
                                             CGFloat strokeWidth,
                                             CGImage *image)
{
   mvgStrokeLineWithPaint( vg, start, end, strokeWidth, image);
}


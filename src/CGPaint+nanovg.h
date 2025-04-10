//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
// prefer a local CGPaint over one in import.h
#ifdef __has_include
# if __has_include( "CGPaint.h")
#  import "CGPaint.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"



//
// this is still low-level nanovg, if you want to use a rotated image
// for your paint, good luck. (Preferably use [CGImage drawRect:options:context])
//
@interface CGPaint( nanovg)

- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
                    alpha:(CGFloat) alpha
               NVGcontext:(NVGcontext *) context;

- (void) fillWithBounds:(CGRect) rect
                  alpha:(CGFloat) alpha
             NVGcontext:(NVGcontext *) context;

// conveniences, preferably use alpha methods..
- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
               NVGcontext:(NVGcontext *) context;

- (void) fillWithBounds:(CGRect) rect
             NVGcontext:(NVGcontext *) context;

@end


@interface CGPaint( nanovg_Subclasses)

// a linear gradient if a gradient
- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                          alpha:(CGFloat) alpha
                     NVGcontext:(NVGcontext *) vg;

@end


void   mvgFillRoundedRectVaryingWithPaint( NVGcontext *vg,
                                           CGRect rect,
                                           MulleCornerInsets cornerInsets,
                                           CGPaint *paint);

void   mvgFillRoundedRectWithPaint( NVGcontext *vg,
                                    CGRect rect,
                                    CGFloat cornerRadius,
                                    CGPaint *paint);
void   mvgFillRectWithPaint( NVGcontext *vg, CGRect rect, CGPaint *paint);
// will use linear Gradient!
void   mvgFillCircleWithPaint( NVGcontext *vg,
                               CACircle circle,
                               CGPaint *paint);
void   mvgFillLineWithPaint( NVGcontext *vg,
                             CGPoint start,
                             CGPoint end,
                             CGPaint *paint);


void   mvgStrokeRoundedRectVaryingWithPaint( NVGcontext *vg,
                                             CGRect rect,
                                             MulleCornerInsets cornerInsets,
                                             CGFloat strokeWidth,
                                             CGPaint *paint);

void   mvgStrokeRoundedRectWithPaint( NVGcontext *vg,
                                      CGRect rect,
                                      CGFloat cornerRadius,
                                      CGFloat strokeWidth,
                                      CGPaint *paint);
void   mvgStrokeRectWithPaint( NVGcontext *vg,
                               CGRect rect,
                               CGFloat strokeWidth,
                               CGPaint *paint);
// will use linear Gradient!
void   mvgStrokeCircleWithPaint( NVGcontext *vg,
                                 CACircle circle,
                                 CGFloat strokeWidth,
                                 CGPaint *paint);
void   mvgStrokeLineWithPaint( NVGcontext *vg,
                               CGPoint start,
                               CGPoint end,
                               CGFloat strokeWidth,
                               CGPaint *paint);

void   mvgStrokeLineHWithPaint( NVGcontext *vg,
                                CGPoint point,
                                CGFloat width,
                                CGFloat strokeWidth,
                                CGPaint *paint);

void   mvgStrokeLineVWithPaint( NVGcontext *vg,
                                CGPoint start,
                                CGFloat height,
                                CGFloat strokeWidth,
                                CGPaint *paint);

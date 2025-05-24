//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
// prefer a local CGPaint over one in import.h
#ifdef __has_include
# if __has_include( "CGPaint.h")
#  import "CGPaint.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


@interface CGPaint( Drawing)

- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
                    alpha:(CGFloat) alpha
                  context:(CGContext *) context;

- (void) fillWithBounds:(CGRect) rect
                  alpha:(CGFloat) alpha
                context:(CGContext *) context;

// conveniences, preferably use alpha methods..
- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
                  context:(CGContext *) context;

- (void) fillWithBounds:(CGRect) rect
                context:(CGContext *) context;

@end


void   CGContextFillRoundedRectVaryingWithPaint( CGContext *context,
                                                 CGRect rect,
                                                 MulleCornerInsets cornerInsets,
                                                 CGPaint *paint);

void   CGContextFillRoundedRectWithPaint( CGContext *context,
                                          CGRect rect,
                                          CGFloat cornerRadius,
                                          CGPaint *paint);
void   CGContextFillRectWithPaint( CGContext *context, CGRect rect, CGPaint *paint);
// will use linear Gradient!
void   CGContextFillCircleWithPaint( CGContext *context,
                                     CACircle circle,
                                     CGPaint *paint);
void   CGContextFillLineWithPaint( CGContext *context,
                                   CGPoint start,
                                   CGPoint end,
                                   CGPaint *paint);


void   CGContextStrokeRoundedRectVaryingWithPaint( CGContext *context,
                                                   CGRect rect,
                                                   MulleCornerInsets cornerInsets,
                                                   CGFloat strokeWidth,
                                                   CGPaint *paint);

void   CGContextStrokeRoundedRectWithPaint( CGContext *context,
                                            CGRect rect,
                                            CGFloat cornerRadius,
                                            CGFloat strokeWidth,
                                            CGPaint *paint);
void   CGContextStrokeRectWithPaint( CGContext *context,
                                     CGRect rect,
                                     CGFloat strokeWidth,
                                     CGPaint *paint);
// will use linear Gradient!
void   CGContextStrokeCircleWithPaint( CGContext *context,
                                       CACircle circle,
                                       CGFloat strokeWidth,
                                       CGPaint *paint);
void   CGContextStrokeLineWithPaint( CGContext *context,
                                     CGPoint start,
                                     CGPoint end,
                                     CGFloat strokeWidth,
                                     CGPaint *paint);
      
void   CGContextStrokeLineHWithPaint( CGContext *context,
                                      CGPoint point,
                                      CGFloat width,
                                      CGFloat strokeWidth,
                                      CGPaint *paint);

void   CGContextStrokeLineVWithPaint( CGContext *context,
                                      CGPoint start,
                                      CGFloat height,
                                      CGFloat strokeWidth,
                                      CGPaint *paint);

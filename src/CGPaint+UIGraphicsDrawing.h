//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "CGPaint.h")
#  import "CGPaint.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


@interface CGPaint( UIGraphicsDrawing)

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



//
// will use linear gradients, these functions may be somewhat
// cheaper than using a CGGradient
//
void   CGContextFillGradientColors( CGContext *context,
                                    CGRect rect,
                                    CGColor startColor,
                                    CGColor endColor,
                                    CGFloat colorRotation);

void   CGContextStrokeGradientColors( CGContext *context,
                                      CGRect rect,
                                      CGColor startColor,
                                      CGColor endColor,
                                      CGFloat colorRotation,
                                      CGFloat strokeWidth);

void   CGContextFillRoundedRectWithGradientColors( CGContext *context,
                                                   CGRect rect,
                                                   CGFloat cornerRadius,
                                                   CGColor startColor,
                                                   CGColor endColor,
                                                   CARotation colorRotation);

void   CGContextStrokeRoundedRectWithGradientColors( CGContext *context,
                                                     CGRect rect,
                                                     CGFloat cornerRadius,
                                                     CGColor startColor,
                                                     CGColor endColor,
                                                     CARotation colorRotation,
                                                     CGFloat strokeWidth);


static inline void   CGContextFillRectWithGradientColors( CGContext *context,
                                                          CGRect rect,
                                                          CGColor startColor,
                                                          CGColor endColor,
                                                          CGFloat colorRotation)
{
   CGContextFillRoundedRectWithGradientColors( context, rect,
                                                        0.0f,
                                                        startColor,
                                                        endColor,
                                                        colorRotation);
}


static inline void   CGContextStrokeRectWithGradientColors( CGContext *context,
                                                            CGRect rect,
                                                            CGColor startColor,
                                                            CGColor endColor,
                                                            CGFloat colorRotation,
                                                            CGFloat strokeWidth)
{
   CGContextStrokeRoundedRectWithGradientColors( context, rect,
                                                          0.0f,
                                                          startColor,
                                                          endColor,
                                                          colorRotation,
                                                          strokeWidth);
}


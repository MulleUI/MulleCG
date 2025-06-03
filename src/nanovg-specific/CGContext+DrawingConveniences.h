//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
// we want "import.h" always anyway
#import "import.h"

#import "CGContext+Drawing.h"
// we want "import.h" always anyway
#import "CGDrawable.h"



// these convenience build on CGContext+Drawing.h
// CGContext calls, no nanovg or microvg



// Fill with color
void   CGContextFillWithColor( CGContext *context, CGColor color);


// Stroke with color
void   CGContextStrokeWithColor( CGContext *context,
                                 CGFloat strokeWidth,
                                 CGColor color);


// Stroke horizontal line with color
void   CGContextStrokeLineHWithColor( CGContext *context,
                                      CGPoint p,
                                      CGFloat w,
                                      CGFloat strokeWidth,
                                      CGColor color);

// Stroke vertical line with color
void   CGContextStrokeLineVWithColor( CGContext *context,
                                      CGPoint p,
                                      CGFloat h,
                                      CGFloat strokeWidth,
                                      CGColor color);

// Fill rounded rect with color
void   CGContextFillRoundedRectWithColor( CGContext *context,
                                          CGRect rect,
                                          CGFloat cornerRadius,
                                          CGColor color);

// Fill rect with color
void   CGContextFillRectWithColor( CGContext *context,
                                   CGRect rect,
                                   CGColor color);

// Fill rect with NVGpaint
void   CGContextFillRectWithNVGpaint( CGContext *context,
                                      CGRect rect,
                                      NVGpaint paint);

// Fill circle with color
void   CGContextFillCircleWithColor( CGContext *context,
                                     CACircle circle,
                                     CGColor color);

// Fill circle with NVGpaint
void   CGContextFillCircleWithNVGpaint( CGContext *context,
                                        CACircle circle,
                                        NVGpaint paint);

// Stroke rounded rect with color
void   CGContextStrokeRoundedRectWithColor( CGContext *context,
                                            CGRect rect,
                                            CGFloat cornerRadius,
                                            CGFloat strokeWidth,
                                            CGColor color);

// Stroke inside of rounded rect with color
void   CGContextStrokeInsideOfRoundedRectWithColor( CGContext *context,
                                                    CGRect rect,
                                                    CGFloat cornerRadius,
                                                    CGFloat strokeWidth,
                                                    CGColor color);

// Stroke rect with color
void   CGContextStrokeRectWithColor( CGContext *context,
                                     CGRect rect,
                                     CGFloat strokeWidth,
                                     CGColor color);

// Stroke inside of rect with color
void   CGContextStrokeInsideOfRectWithColor( CGContext *context,
                                             CGRect rect,
                                             CGFloat strokeWidth,
                                             CGColor color);

// Stroke line with color
void   CGContextStrokeLineWithColor( CGContext *context,
                                     CGPoint start,
                                     CGPoint end,
                                     CGFloat strokeWidth,
                                     CGColor color);

// Stroke circle with color
void   CGContextStrokeCircleWithColor( CGContext *context,
                                       CACircle circle,
                                       CGFloat strokeWidth,
                                       CGColor color);


// will use radialGradient!
void   CGContextFillCircleWithGradientColors( CGContext *context,
                                              CACircle circle,
                                              CGColor outerColor,
                                              CGColor innerColor);

void   CGContextStrokeCircleWithGradientColors( CGContext *context,
                                                CACircle circle,
                                                CGColor outerColor,
                                                CGColor innerColor,
                                                CGFloat strokeWidth);


// Text conveniences and additions
// Format text in rect
void   CGContextFormatInRect( CGContext *context,
                              CGRect rect,
                              CGContentMode contentMode,
                              CGTextOptions options,
                              char *format,
                              ...);

// Format text at point
void   CGContextFormat( CGContext *context, CGPoint point, char *format, ...);



// Calculate adjustment for visual bounds
CGPoint   CGContextTLAdjustmentForVisualBounds( CGLayoutContext *context,
                                                char *s,
                                                size_t length,
                                                int alignment,
                                                CGTextOptions options);
///
void   CGContextFillRoundedShadow( CGContext *context,
                                   CGRect rect,
                                   CGFloat cornerRadius,
                                   struct CGShadow *shadow);

// Draw text inside a rect
void   CGContextTextInRect( CGContext *context,
                            char *s,
                            size_t length,
                            CGRect rect,
                            CGContentMode contentMode,
                            CGTextOptions options);


// if( isnan( fontSize)) on return, then keep the current fontSize of the
// context as is.


struct CGTextBoundsInfo   CGContextTextBoundsOptions( CGContext *context,
                                                          char *s,
                                                          size_t length,
                                                          CGRect rect,
                                                          CGContentMode contentMode,
                                                          CGTextOptions options);

// Extended aligned text
void   CGContextExtendedAlignedText( CGContext *context,
                                     char *s,
                                     size_t length,
                                     CGPoint origin,
                                     int alignment,
                                     CGTextOptions options);

// Extended aligned text (internal implementation)
void   CGContext_ExtendedAlignedText( CGContext *context,
                                      char *s,
                                      size_t length,
                                      CGPoint origin,
                                      int alignment,
                                      CGTextOptions options);
//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#import "CGContext+Drawing.h"
#import "CGDrawable.h"


// these convenience build on CGContext+Drawing.h
// CGContext calls, no nanovg or microvg

void   CGContextFillWithColor( CGContext *context, CGColor color);
void   CGContextStrokeWithColor( CGContext *context, CGFloat strokeWidth, CGColor color);
void   CGContextStrokeLineHWithColor( CGContext *context, CGPoint p, CGFloat w, CGFloat strokeWidth, CGColor color);
void   CGContextStrokeLineVWithColor( CGContext *context, CGPoint p, CGFloat h, CGFloat strokeWidth, CGColor color);
void   CGContextFillRoundedRectWithColor( CGContext *context, CGRect rect, CGFloat cornerRadius, CGColor color);
void   CGContextFillRectWithColor( CGContext *context, CGRect rect, CGColor color);
void   CGContextFillCircleWithColor( CGContext *context, CACircle circle, CGColor color);
void   CGContextStrokeRoundedRectWithColor( CGContext *context, CGRect rect, CGFloat cornerRadius, CGFloat strokeWidth, CGColor color);
void   CGContextStrokeInsideOfRoundedRectWithColor( CGContext *context, CGRect rect, CGFloat cornerRadius, CGFloat strokeWidth, CGColor color);
void   CGContextStrokeRectWithColor( CGContext *context, CGRect rect, CGFloat strokeWidth, CGColor color);
void   CGContextStrokeInsideOfRectWithColor( CGContext *context, CGRect rect, CGFloat strokeWidth, CGColor color);
void   CGContextStrokeLineWithColor( CGContext *context, CGPoint start, CGPoint end, CGFloat strokeWidth, CGColor color);
void   CGContextStrokeCircleWithColor( CGContext *context, CACircle circle, CGFloat strokeWidth, CGColor color);
void   CGContextFillCircleWithGradientColors( CGContext *context, CACircle circle, CGColor outerColor, CGColor innerColor);
void   CGContextStrokeCircleWithGradientColors( CGContext *context, CACircle circle, CGColor outerColor, CGColor innerColor, CGFloat strokeWidth);
void   CGContextFormatInRect( CGContext *context, CGRect rect, CGContentMode contentMode, CGTextOptions options, char *format, ...);
void   CGContextFormat( CGContext *context, CGPoint point, char *format, ...);
CGPoint   CGContextTLAdjustmentForVisualBounds( CGLayoutContext *context, char *s, size_t length, int alignment, CGTextOptions options);
void   CGContextFillRoundedShadow( CGContext *context, CGRect rect, CGFloat cornerRadius, struct CGShadow *shadow);
void   CGContextTextInRect( CGContext *context, char *s, size_t length, CGRect rect, CGContentMode contentMode, CGTextOptions options);
struct CGTextBoundsInfo   CGContextTextBoundsOptions( CGContext *context, char *s, size_t length, CGRect rect, CGContentMode contentMode, CGTextOptions options);
void   CGContextExtendedAlignedText( CGContext *context, char *s, size_t length, CGPoint origin, int alignment, CGTextOptions options);
void   CGContext_ExtendedAlignedText( CGContext *context, char *s, size_t length, CGPoint origin, int alignment, CGTextOptions options);

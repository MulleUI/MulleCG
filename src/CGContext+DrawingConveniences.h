//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#import "CGContext+Drawing.h"
#import "CGDrawable.h"


// these convenience build on CGContext+Drawing.h
// CGContext calls, no nanovg or microvg

MULLE_CG_GLOBAL
void   CGContextFillWithColor( CGContext *context, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeWithColor( CGContext *context, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeLineHWithColor( CGContext *context, CGPoint p, CGFloat w, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeLineVWithColor( CGContext *context, CGPoint p, CGFloat h, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextFillRoundedRectWithColor( CGContext *context, CGRect rect, CGFloat cornerRadius, CGColor color);
MULLE_CG_GLOBAL
void   CGContextFillRectWithColor( CGContext *context, CGRect rect, CGColor color);
MULLE_CG_GLOBAL
void   CGContextFillCircleWithColor( CGContext *context, CACircle circle, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeRoundedRectWithColor( CGContext *context, CGRect rect, CGFloat cornerRadius, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeInsideOfRoundedRectWithColor( CGContext *context, CGRect rect, CGFloat cornerRadius, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeRectWithColor( CGContext *context, CGRect rect, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeInsideOfRectWithColor( CGContext *context, CGRect rect, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeLineWithColor( CGContext *context, CGPoint start, CGPoint end, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeCircleWithColor( CGContext *context, CACircle circle, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextFillCircleWithGradientColors( CGContext *context, CACircle circle, CGColor outerColor, CGColor innerColor);
MULLE_CG_GLOBAL
void   CGContextStrokeCircleWithGradientColors( CGContext *context, CACircle circle, CGColor outerColor, CGColor innerColor, CGFloat strokeWidth);
MULLE_CG_GLOBAL
void   CGContextFormatInRect( CGContext *context, CGRect rect, CGContentMode contentMode, CGTextOptions options, char *format, ...);
MULLE_CG_GLOBAL
void   CGContextFormat( CGContext *context, CGPoint point, char *format, ...);
MULLE_CG_GLOBAL
CGPoint   CGContextTLAdjustmentForVisualBounds( CGLayoutContext *context, char *s, size_t length, int alignment, CGTextOptions options);
MULLE_CG_GLOBAL
void   CGContextFillRoundedShadow( CGContext *context, CGRect rect, CGFloat cornerRadius, struct CGShadow *shadow);
MULLE_CG_GLOBAL
void   CGContextTextInRect( CGContext *context, char *s, size_t length, CGRect rect, CGContentMode contentMode, CGTextOptions options);
MULLE_CG_GLOBAL
struct CGTextBoundsInfo   CGContextTextBoundsOptions( CGContext *context, char *s, size_t length, CGRect rect, CGContentMode contentMode, CGTextOptions options);
MULLE_CG_GLOBAL
void   CGContextExtendedAlignedText( CGContext *context, char *s, size_t length, CGPoint origin, int alignment, CGTextOptions options);
MULLE_CG_GLOBAL
void   CGContext_ExtendedAlignedText( CGContext *context, char *s, size_t length, CGPoint origin, int alignment, CGTextOptions options);

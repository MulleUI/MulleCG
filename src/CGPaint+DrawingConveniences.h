//
// Copyright (c) Nat!, Mulle kybernetiK
//
#import "CGPaintable.h"
#import "import.h"


void   CGContextFillRoundedRectVaryingWithPaintable( CGContext *context, CGRect rect, MulleCornerInsets cornerInsets, id <CGPaintable> paint);
void   CGContextFillRoundedRectWithPaintable( CGContext *context, CGRect rect, CGFloat cornerRadius, id <CGPaintable> paint);
void   CGContextFillRectWithPaintable( CGContext *context, CGRect rect, id <CGPaintable> paint);
void   CGContextFillCircleWithPaintable( CGContext *context, CACircle circle, id <CGPaintable> paint);
void   CGContextFillLineWithPaintable( CGContext *context, CGPoint start, CGPoint end, id <CGPaintable> paint);
void   CGContextStrokeRoundedRectVaryingWithPaintable( CGContext *context, CGRect rect, MulleCornerInsets cornerInsets, CGFloat strokeWidth, id <CGPaintable> paint);
void   CGContextStrokeRoundedRectWithPaintable( CGContext *context, CGRect rect, CGFloat cornerRadius, CGFloat strokeWidth, id <CGPaintable> paint);
void   CGContextStrokeRectWithPaintable( CGContext *context, CGRect rect, CGFloat strokeWidth, id <CGPaintable> paint);
void   CGContextStrokeCircleWithPaintable( CGContext *context, CACircle circle, CGFloat strokeWidth, id <CGPaintable> paint);
void   CGContextStrokeLineWithPaintable( CGContext *context, CGPoint start, CGPoint end, CGFloat strokeWidth, id <CGPaintable> paint);
void   CGContextStrokeLineHWithPaintable( CGContext *context, CGPoint point, CGFloat width, CGFloat strokeWidth, id <CGPaintable> paint);
void   CGContextStrokeLineVWithPaintable( CGContext *context, CGPoint start, CGFloat height, CGFloat strokeWidth, id <CGPaintable> paint);

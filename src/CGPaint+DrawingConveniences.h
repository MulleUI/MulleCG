//
// Copyright (c) Nat!, Mulle kybernetiK
//
#import "import.h"

#import "CGPaintable.h"


MULLE_CG_GLOBAL
void   CGContextFillRoundedRectVaryingWithPaintable( CGContext *context, CGRect rect, MulleCornerInsets cornerInsets, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextFillRoundedRectWithPaintable( CGContext *context, CGRect rect, CGFloat cornerRadius, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextFillRectWithPaintable( CGContext *context, CGRect rect, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextFillCircleWithPaintable( CGContext *context, CACircle circle, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextFillLineWithPaintable( CGContext *context, CGPoint start, CGPoint end, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextStrokeRoundedRectVaryingWithPaintable( CGContext *context, CGRect rect, MulleCornerInsets cornerInsets, CGFloat strokeWidth, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextStrokeRoundedRectWithPaintable( CGContext *context, CGRect rect, CGFloat cornerRadius, CGFloat strokeWidth, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextStrokeRectWithPaintable( CGContext *context, CGRect rect, CGFloat strokeWidth, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextStrokeCircleWithPaintable( CGContext *context, CACircle circle, CGFloat strokeWidth, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextStrokeLineWithPaintable( CGContext *context, CGPoint start, CGPoint end, CGFloat strokeWidth, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextStrokeLineHWithPaintable( CGContext *context, CGPoint point, CGFloat width, CGFloat strokeWidth, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextStrokeLineVWithPaintable( CGContext *context, CGPoint start, CGFloat height, CGFloat strokeWidth, id <CGPaintable> paint);

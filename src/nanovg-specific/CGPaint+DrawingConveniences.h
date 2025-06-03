//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
// prefer a local CGPaint over one in import.h
#ifdef __has_include
# if __has_include( "CGPaint+Drawing.h")
#  import "CGPaint+Drawing.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


// Conveniences:

//
// MEMO: these are conveniences
//       idea make these CGPaint functions instead of CGContext
//
void   CGContextFillRoundedRectVaryingWithPaintable( CGContext *context,
                                                     CGRect rect,
                                                     MulleCornerInsets cornerInsets,
                                                     id <CGPaintable> paint);

void   CGContextFillRoundedRectWithPaintable( CGContext *context,
                                          CGRect rect,
                                          CGFloat cornerRadius,
                                          id <CGPaintable> paint);
void   CGContextFillRectWithPaintable( CGContext *context, CGRect rect, id <CGPaintable> paint);
// will use linear Gradient!
void   CGContextFillCircleWithPaintable( CGContext *context,
                                     CACircle circle,
                                     id <CGPaintable> paint);
void   CGContextFillLineWithPaintable( CGContext *context,
                                   CGPoint start,
                                   CGPoint end,
                                   id <CGPaintable> paint);


void   CGContextStrokeRoundedRectVaryingWithPaintable( CGContext *context,
                                                   CGRect rect,
                                                   MulleCornerInsets cornerInsets,
                                                   CGFloat strokeWidth,
                                                   id <CGPaintable> paint);

void   CGContextStrokeRoundedRectWithPaintable( CGContext *context,
                                            CGRect rect,
                                            CGFloat cornerRadius,
                                            CGFloat strokeWidth,
                                            id <CGPaintable> paint);
void   CGContextStrokeRectWithPaintable( CGContext *context,
                                     CGRect rect,
                                     CGFloat strokeWidth,
                                     id <CGPaintable> paint);
// will use linear Gradient!
void   CGContextStrokeCircleWithPaintable( CGContext *context,
                                       CACircle circle,
                                       CGFloat strokeWidth,
                                       id <CGPaintable> paint);
void   CGContextStrokeLineWithPaintable( CGContext *context,
                                     CGPoint start,
                                     CGPoint end,
                                     CGFloat strokeWidth,
                                     id <CGPaintable> paint);
      
void   CGContextStrokeLineHWithPaintable( CGContext *context,
                                      CGPoint point,
                                      CGFloat width,
                                      CGFloat strokeWidth,
                                      id <CGPaintable> paint);

void   CGContextStrokeLineVWithPaintable( CGContext *context,
                                      CGPoint start,
                                      CGFloat height,
                                      CGFloat strokeWidth,
                                      id <CGPaintable> paint);

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
#import "CGTypes.h"


void   CGContextFillPaintWithOptions( CGContext *context,
                                      CGPaint *paint,
                                      CGRect  bounds,
                                      CGFillOptions *options);

void   CGContextStrokePaintWithOptions( CGContext *context,
                                        CGPaint *paint,
                                        CGRect  bounds,
                                        CGFloat strokeWidth,
                                        CGStrokeOptions *options);


static inline void   CGContextFillPaint( CGContext *context, CGPaint *paint)
{
   CGContextFillPaintWithOptions( context,
                                  paint,
                                  CGRectMake( -INFINITY, -INFINITY, INFINITY, INFINITY),
                                  NULL);
}


static inline void   CGContextStrokePaint( CGContext *context, CGPaint *paint, CGFloat strokeWidth)
{
   CGContextStrokePaintWithOptions( context,
                                    paint,
                                    CGRectMake( -INFINITY, -INFINITY, INFINITY, INFINITY),
                                    strokeWidth,
                                    NULL);
}


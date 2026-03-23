//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#import "CGTypes.h"
#import "CGPaint.h"


@class CGContext;
@class CGImage;


PROTOCOLCLASS_INTERFACE0( CGPaintable)

@optional
- (void) fillWithBounds:(CGRect) rect
                options:(struct CGFillOptions *) options
                context:(CGContext *) context;

- (void) strokeWithBounds:(CGRect) bounds
              strokeWidth:(CGFloat) strokeWidth
                  options:(struct CGStrokeOptions *) options
                  context:(CGContext *) context;

- (CGImage *) image;
- (CGImage *) otherImage;

PROTOCOLCLASS_END()


@interface CGPaint( CGPaintable)  < CGPaintable>
@end


void   CGContextFillPaintableOptions( CGContext *context,
                                      id <CGPaintable> paint,
                                      CGRect  bounds,
                                      CGFillOptions *options);

void   CGContextStrokePaintableOptions( CGContext *context,
                                        id <CGPaintable> paint,
                                        CGRect  bounds,
                                        CGFloat strokeWidth,
                                        CGStrokeOptions *options);


static inline void   CGContextFillPaintable( CGContext *context, id <CGPaintable> paint)
{
   CGContextFillPaintableOptions( context,
                                  paint,
                                  CGRectMake( -INFINITY, -INFINITY, INFINITY, INFINITY),
                                  NULL);
}


static inline void   CGContextStrokePaintable( CGContext *context, id <CGPaintable> paint, CGFloat strokeWidth)
{
   CGContextStrokePaintableOptions( context,
                                    paint,
                                    CGRectMake( -INFINITY, -INFINITY, INFINITY, INFINITY),
                                    strokeWidth,
                                    NULL);
}

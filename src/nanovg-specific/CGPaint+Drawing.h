//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#ifndef cgpaint_drawing_h__
#define cgpaint_drawing_h__

#import "CGTypes.h"
#import "CGDrawable.h"
#import "CGPaint.h"

@class CGContext;
@class CGImage;


@protocol CGPaintable

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                   paintOptions:(struct CGPaintOptions *) options
                        context:(CGContext *) context;

- (CGImage *) image;
- (CGImage *) otherImage;

@end 


@interface CGPaint( CGPaintable)  < CGPaintable>
@end


//
// functions defined in the various: CG*+nanovg.m implementations
//


// CGGradient+nanovg.m

void   CGContextFillLinearGradient( CGContext *context,
                                    CGPoint start,
                                    CGColor startColor,
                                    CGPoint end,
                                    CGColor endColor);

void   CGContextStrokeLinearGradient( CGContext *context,
                                      CGPoint start,
                                      CGColor startColor,
                                      CGPoint end,
                                      CGColor endColor,
                                      CGFloat strokeWidth);

void   CGContextFillBoxGradient( CGContext *context,
                                 CGRect rect,
                                 CGFloat cornerRadius,
                                 CGColor color,
                                 CGFloat feather,
                                 CGColor featherColor);


void   CGContextStrokeBoxGradient( CGContext *context,
                                   CGRect rect,
                                   CGFloat cornerRadius,
                                   CGColor color,
                                   CGFloat feather,
                                   CGColor featherColor,
                                   CGFloat strokeWidth);


void   CGContextFillRadialGradient( CGContext *context,
                                    CACircle circle,
                                    CGColor color,
                                    CGFloat innerRadius,
                                    CGColor innerColor);


void   CGContextStrokeRadialGradient( CGContext *context,
                                      CACircle circle,
                                      CGColor color,
                                      CGFloat innerRadius,
                                      CGColor innerColor,
                                      CGFloat strokeWidth);


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

// CGImage+nanovg.m

void   CGContextFillImageOptions( CGContext *context,
                                      CGImage *image,
                                      CGRect rect,
                                      CGFillOptions *options);


void   CGContextStrokeImageOptions( CGContext *context,
                                        CGImage *image,
                                        CGRect rect,
                                        CGFloat strokeWidth,
                                        CGStrokeOptions *options);


//
// paint often carry the "rect" within them, so this is the easy way...
//
static inline void   CGContextFillImage( CGContext *context, CGImage *image)
{
   CGContextFillImageOptions( context,
                                  image,
                                  CGRectNull,
                                  NULL);
}


static inline void   CGContextStrokeImage( CGContext *context, CGImage *image, CGFloat strokeWidth)
{
   CGContextStrokeImageOptions( context,
                                    image,
                                    CGRectNull,
                                    strokeWidth,
                                    NULL);
}


void  CGContextDrawBitmapDrawableInRect( CGContext *context,
                                         id <CGBitmapDrawable> drawable,
                                         CGRect rect,
                                         CGRect patternRect,
                                         CGDrawableOptions *options);


// CGPaint+nanovg.m

void   CGContextFillPaintableOptions( CGContext *context,
                                      id <CGPaintable> paintable,
                                      CGRect  bounds,
                                      CGFillOptions *options);

void   CGContextStrokePaintableOptions( CGContext *context,
                                        id <CGPaintable> paint,
                                        CGRect  bounds,
                                        CGFloat strokeWidth,
                                        CGStrokeOptions *options);

//
// paint often carry the "rect" within them, so this is the easy way...
//
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


void  CGContextDrawBitmapDrawableInRect( CGContext *context,
                                         id <CGBitmapDrawable> drawable,
                                         CGRect rect,
                                         CGRect patternRect,
                                         CGDrawableOptions *options);





#endif

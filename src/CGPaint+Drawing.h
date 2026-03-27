//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "import.h"

#import "CGPaintable.h"


@class CGContext;
@class CGImage;



//
// functions defined in the various: CG*+nanovg.m implementations
//


// CGGradient+nanovg.m

MULLE_CG_GLOBAL
void   CGContextFillLinearGradient( CGContext *context,
                                    CGPoint start,
                                    CGColor startColor,
                                    CGPoint end,
                                    CGColor endColor);

MULLE_CG_GLOBAL
void   CGContextStrokeLinearGradient( CGContext *context,
                                      CGPoint start,
                                      CGColor startColor,
                                      CGPoint end,
                                      CGColor endColor,
                                      CGFloat strokeWidth);

MULLE_CG_GLOBAL
void   CGContextFillBoxGradient( CGContext *context,
                                 CGRect rect,
                                 CGFloat cornerRadius,
                                 CGColor color,
                                 CGFloat feather,
                                 CGColor featherColor);


MULLE_CG_GLOBAL
void   CGContextStrokeBoxGradient( CGContext *context,
                                   CGRect rect,
                                   CGFloat cornerRadius,
                                   CGColor color,
                                   CGFloat feather,
                                   CGColor featherColor,
                                   CGFloat strokeWidth);


MULLE_CG_GLOBAL
void   CGContextFillRadialGradient( CGContext *context,
                                    CACircle circle,
                                    CGColor color,
                                    CGFloat innerRadius,
                                    CGColor innerColor);


MULLE_CG_GLOBAL
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

MULLE_CG_GLOBAL
void   CGContextStrokeGradientColors( CGContext *context,
                                      CGRect rect,
                                      CGColor startColor,
                                      CGColor endColor,
                                      CGFloat colorRotation,
                                      CGFloat strokeWidth);


MULLE_CG_GLOBAL
void   CGContextFillImageOptions( CGContext *context,
                                      CGImage *image,
                                      CGRect rect,
                                      CGFillOptions *options);


MULLE_CG_GLOBAL
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


MULLE_CG_GLOBAL
void  CGContextDrawBitmapDrawableInRect( CGContext *context,
                                         id <CGBitmapDrawable> drawable,
                                         CGRect rect,
                                         CGRect patternRect,
                                         CGDrawableOptions *options);

MULLE_CG_GLOBAL
void  CGContextDrawBitmapDrawableInRect( CGContext *context,
                                         id <CGBitmapDrawable> drawable,
                                         CGRect rect,
                                         CGRect patternRect,
                                         CGDrawableOptions *options);


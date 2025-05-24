//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
// prefer a local CGGradient over one in import.h
#ifdef __has_include
# if __has_include( "CGGradient.h")
#  import "CGGradient.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


#import "CGContext.h"
#import "CGPaint+nanovg.h"
#import "microvg-nanowrap.h"


// will use radialGradient!
void   CGContextFillCircleWithGradientColors( CGContext *context,
                                              CACircle circle,
                                              CGColor outerColor,
                                              CGColor innerColor);

void   CGContextStrokeCircleWithGradientColors( CGContext *context,
                                                CACircle circle,
                                                CGFloat strokeWidth,
                                                CGColor outerColor,
                                                CGColor innerColor);

//
// will use linear gradients, these functions may be somewhat
// cheaper than using a CGGradient
//
void   CGContextFillRoundedRectWithGradientColors( CGContext *context,
                                                   CGRect rect,
                                                   CGFloat cornerRadius,
                                                   CGFloat feather,
                                                   CGColor startColor,
                                                   CGColor endColor,
                                                   CGFloat rotation);

void   CGContextStrokeRectWithGradientColors( CGContext *context,
                                              CGRect rect,
                                              CGFloat strokeWidth,
                                              CGColor startColor,
                                              CGColor endColor,
                                              CGFloat rotation);



// some helper functions to avoid having to create a CGGradient object

static inline void   CGContextFillLinearGradient( CGContext *context,
                                                  CGPoint start,
                                                  CGColor startColor,
                                                  CGPoint end,
                                                  CGColor endColor)
{
   NVGpaint     paint;
   NVGcontext   *vg;

   vg    = CGContextGetNVGContext( context);
   paint = mvgLinearGradient( vg, start, startColor, end, endColor);
   mvgFillPaint( vg, paint);
}


static inline void   CGContextStrokeLinearGradient( CGContext *context,
                                                    CGPoint start,
                                                    CGColor startColor,
                                                    CGPoint end,
                                                    CGColor endColor)
{
   NVGpaint     paint;
   NVGcontext   *vg;

   vg    = CGContextGetNVGContext( context);
   paint = mvgLinearGradient( vg, start, startColor, end, endColor);
   mvgStrokePaint( vg, paint);
}



static inline void   CGContextFillBoxGradient( CGContext *context,
                                               CGRect rect,
                                               CGFloat cornerRadius,
                                               CGColor color,
                                               CGFloat feather,
                                               CGColor featherColor)
{
   NVGpaint     paint;
   NVGcontext   *vg;

   vg    = CGContextGetNVGContext( context);
   paint = mvgBoxGradient( vg, rect, cornerRadius, color, feather, featherColor);
   mvgFillPaint( vg, paint);
}


static inline void   CGContextStrokeBoxGradient( CGContext *context,
                                                 CGRect rect,
                                                 CGFloat cornerRadius,
                                                 CGColor color,
                                                 CGFloat feather,
                                                 CGColor featherColor)
{
   NVGpaint     paint;
   NVGcontext   *vg;

   vg    = CGContextGetNVGContext( context);
   paint = mvgBoxGradient( vg, rect, cornerRadius, color, feather, featherColor);
   mvgStrokePaint( vg, paint);
}


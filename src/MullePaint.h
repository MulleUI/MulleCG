//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "import.h"

#import "CGColor.h"
#import "CGContext.h"



// Paint is either a gradient or a texture. Actually behind the scenes
// its a texture anyway :)

@interface MullePaint : NSObject
{
   struct NVGpaint     _paint;
}

@property( readonly, assign) CGContext           *context;
@property( readonly, retain) NSObject <CGImage>  *image;

- (instancetype) initWithNVGpaint:(struct NVGpaint) paint
                          context:(CGContext *) context;

// the paint is valid for the NVGcontext only, but the nvg context is
// not kept, and the nvgContext doesnt keep the paint
- (instancetype) initLinearGradientWithStartPoint:(CGPoint) start
                                         endPoint:(CGPoint) end
                                       innerColor:(CGColorRef) innerColor
                                       outerColor:(CGColorRef) outerColor
                                          context:(CGContext *) context;

- (instancetype) initImagePatternWithImage:(id <CGImage>) image
                                    origin:(CGPoint) origin
                                       end:(CGPoint) end
                                     angle:(CGFloat) angle
                                     alpha:(CGFloat) alpha
                                   context:(CGContext *) context;

- (CGColorRef) innerColor;
- (CGColorRef) outerColor;
- (CGFloat) radius;
- (CGFloat) feather;

- (struct NVGpaint) nvgPaint;

@end

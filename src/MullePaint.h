//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "import.h"

#import "CGColor.h"


@class CGImage;
@class CGContext;

// Paint is either a gradient or a texture. Actually behind the scenes
// its a texture anyway :)
//
// The image handle (imageID) is managed by nanovg though.
// It will not be available via the context. Therefore a paint can only
// exist in one context currently. TODO: make this more like UIImage so
// we can use it in multiple contexts. (otherwise its fairly useless)
//
//
// Todo: assign a "name" to the gradient and store it in context ?
//       maybe MullePaint is a bad idea and should be dropped. Gradients
//       are meant to be created on the fly..
//
@interface MullePaint : NSObject
{
   struct NVGpaint   _paint;
   CGImage           *_image;
}

@property( readonly, assign) CGContext   *context;

// TODO: revert to C, don't keep it around as an object

+ (instancetype) linearGradientWithRect:(CGRect) rect
                             innerColor:(CGColor) innerColor
                             outerColor:(CGColor) outerColor
                                context:(CGContext *) context;
+ (instancetype) radialGradientCenterPoint:(CGPoint) point
                               innerRadius:(CGFloat) innerRadius
                               outerRadius:(CGFloat) outerRadius
                                innerColor:(CGColor) innerColor
                                outerColor:(CGColor) outerColor
                                   context:(CGContext *) context;
+ (instancetype) boxGradientWithRect:(CGRect) point
                        cornerRadius:(CGFloat) cornerRadius
                             feather:(CGFloat) feather
                          innerColor:(CGColor) innerColor
                          outerColor:(CGColor) outerColor
                             context:(CGContext *) context;
+ (instancetype) patternWithImage:(CGImage *) image
                             rect:(CGRect) rect
                            angle:(CGFloat) angle
                            alpha:(CGFloat) alpha
                          context:(CGContext *) context;

// the paint is valid for the NVGcontext only, but the nvg context is
// not kept, and the nvgContext doesnt keep the paint
- (instancetype) initLinearGradientWithRect:(CGRect) rect
                                 innerColor:(CGColor) innerColor
                                 outerColor:(CGColor) outerColor
                                    context:(CGContext *) context;

- (instancetype) initRadialGradientWithCenterPoint:(CGPoint) point
                                       innerRadius:(CGFloat) innerRadius
                                       outerRadius:(CGFloat) outerRadius
                                        innerColor:(CGColor) innerColor
                                        outerColor:(CGColor) outerColor
                                           context:(CGContext *) context;
- (instancetype) initBoxGradientWithRect:(CGRect) point
                            cornerRadius:(CGFloat) cornerRadius
                                 feather:(CGFloat) feather
                              innerColor:(CGColor) innerColor
                              outerColor:(CGColor) outerColor
                                 context:(CGContext *) context;

// it's not necessary to keep the image i believe (so we don't)
- (instancetype) initPatternWithImage:(CGImage *) image
                                 rect:(CGRect) rect
                                angle:(CGFloat) angle
                                alpha:(CGFloat) alpha
                              context:(CGContext *) context;


- (CGColor) innerColor;
- (CGColor) outerColor;
- (CGFloat) radius;
- (CGFloat) feather;

- (struct NVGpaint) nvgPaint;

@end

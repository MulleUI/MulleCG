//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGPaint.h"


#import "import.h"


//
// The CGGradient currently is just two colors, though the interface allows
// more, due to limitations in nanovg. To get more color stops, break up the
// drawing into concentric circles or rects. Circles need a little overlap
// to avoid ugliness.
//
@interface CGGradient : CGPaint < MulleObjCClassCluster, NSCopying, MulleObjCValueProtocols>

@property( readonly) CGFloat   rotation;

+ (instancetype) gradientWithStartColor:(CGColor) startColor
                               endColor:(CGColor) endColor
                               rotation:(CARotation) rotation;

+ (instancetype) gradientWithColors:(CGColor *) colors
                          locations:(CGFloat *) locations
                              count:(NSUInteger) count
                           rotation:(CARotation) rotation;

- (instancetype) initWithStartColor:(CGColor) startColor
                           endColor:(CGColor) endColor
                           rotation:(CARotation) rotation;

- (instancetype) initWithColors:(CGColor *) colors
                      locations:(CGFloat *) locations
                          count:(NSUInteger) count
                       rotation:(CARotation) rotation;


// conveniences with angle CAAngleRadiansE (L->R) use CAAngleRadiansN for
// Top Down

+ (instancetype) gradientWithStartColor:(CGColor) startColor
                               endColor:(CGColor) endColor;

+ (instancetype) gradientWithColors:(CGColor *) colors
                          locations:(CGFloat *) locations
                              count:(NSUInteger) count;

- (instancetype) initWithStartColor:(CGColor) startColor
                           endColor:(CGColor) endColor;

- (instancetype) initWithColors:(CGColor *) colors
                      locations:(CGFloat *) locations
                          count:(NSUInteger) count;

// or reversed ?
- (CGGradient *) reversedGradient; // rotated 180 degrees
- (CGGradient *) rotatedGradient:(CARotation) rotation;
- (CGGradient *) brightenedGradient:(CGFloat) brighten;
- (CGGradient *) dimmedGradient:(CGFloat) dim;
- (CGGradient *) transparentGradient:(CGFloat) alpha;

// fator from 0.0 to 1.0: 0.0 no desaturation/saturation
- (CGGradient *) desaturatedGradient:(CGFloat) factor;
- (CGGradient *) saturatedGradient:(CGFloat) factor;


- (CGGradient *) desaturatedGradient:(CGFloat) factor;
- (CGGradient *) gradientByChangingColorsWithFunction:(CGColor (*)( CGColor, void *)) f
                                             userInfo:(void *) userInfo;

- (BOOL) __isCGGradient    MULLE_OBJC_THREADSAFE_METHOD;

@end

//
@interface CGGradient( Subclasses)

- (CGColor) startColor;
- (CGColor) endColor;

- (CARotation) rotation;

- (NSUInteger) numberOfColors;
// location[ 0] is always 0.0
// location[ n -1] is always 1.0
- (CGFloat) locationAtIndex:(NSUInteger) i;
- (CGColor) colorAtIndex:(NSUInteger) i;
- (void) getColors:(CGColor *) colors;
- (void) getLocations:(CGFloat *) locations;

@end



MULLE_CG_EXTERN_GLOBAL
CGGradient  *CGGradientCreateWithRotation( CGColor startColor,
                                           CGColor endColor,
                                           CARotation rotation);


static inline 
CGGradient  *CGGradientCreate( CGColor startColor, CGColor endColor)
{
   return( CGGradientCreateWithRotation( startColor, endColor, 0.0f));
}

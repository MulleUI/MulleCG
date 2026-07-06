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

@property( readonly) CARotation   rotation;

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



MULLE_CG_GLOBAL
CGGradient  *CGGradientCreateWithRotation( CGColor startColor,
                                           CGColor endColor,
                                           CARotation rotation);


static inline 
CGGradient  *CGGradientCreate( CGColor startColor, CGColor endColor)
{
   return( CGGradientCreateWithRotation( startColor, endColor, 0.0f));
}


//
// base class, don't use directly, use CGGradient to construct it
//
@interface CGTwoColorGradient : CGGradient

@property( readonly) CGColor   startColor;
@property( readonly) CGColor   endColor;

@end


//
// these gradients have a concept of a rectangle or circle, which they
// inhabit
//
@interface CGLinearGradient : CGTwoColorGradient

@property( readonly) CGPoint            startPoint;
@property( readonly) CGPoint            endPoint;

@end

// can't be rotated
@interface CGBoxGradient : CGTwoColorGradient

@property( readonly) CGRect             rect;
@property( readonly) CGFloat            cornerRadius;
@property( readonly) CGFloat            feather;
@property( dynamic, readonly) CGColor   featherColor;
@property( dynamic, readonly) CGColor   color;

@end

// can't be rotated
@interface CGRadialGradient : CGTwoColorGradient

@property( readonly) CACircle           circle;
@property( dynamic, readonly) CGColor   outerColor;
@property( readonly) CGFloat            innerRadius;
@property( dynamic, readonly) CGColor   innerColor;

@end


@interface CGGradient( CGGradientSubclasses)

+ (instancetype) linearGradientWithStartPoint:(CGPoint) startPoint
                                   startColor:(CGColor) startColor
                                     endPoint:(CGPoint) endPoint
                                     endColor:(CGColor) endColor;

+ (instancetype) linearGradientWithRect:(CGRect) rect
                             startColor:(CGColor) startColor
                               endColor:(CGColor) endColor
                               rotation:(CARotation) rotation;

+ (instancetype) boxGradientWithRoundedRect:(CGRect) rect
                               cornerRadius:(CGFloat) cornerRadius
                                      color:(CGColor) color
                                    feather:(CGFloat) feather
                               featherColor:(CGColor) endColor;

+ (instancetype) radialGradientWithCircle:(CACircle) circle
                                    color:(CGColor) outerColor
                              innerRadius:(CGFloat) innerRadius
                               innerColor:(CGColor) innerColor;

+ (instancetype) radialGradientWithRect:(CGRect) circle
                                  color:(CGColor) outerColor
                            innerRadius:(CGFloat) innerRadius
                             innerColor:(CGColor) innerColor;

@end


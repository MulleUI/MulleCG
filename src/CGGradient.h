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
@interface CGGradient : CGPaint < MulleObjCClassCluster, NSCopying>

@property( readonly) CGFloat   rotation;

+ (instancetype) gradientWithStartColor:(CGColor) startColor
                               endColor:(CGColor) endColor
                               rotation:(CGFloat) rotation;

+ (instancetype) gradientWithColors:(CGColor *) colors
                          locations:(CGFloat *) locations
                              count:(NSUInteger) count
                           rotation:(CGFloat) rotation;

- (instancetype) initWithStartColor:(CGColor) startColor
                           endColor:(CGColor) endColor
                           rotation:(CGFloat) rotation;

- (instancetype) initWithColors:(CGColor *) colors
                      locations:(CGFloat *) locations
                          count:(NSUInteger) count
                       rotation:(CGFloat) rotation;


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
- (CGGradient *) rotatedGradient:(CGFloat) rotation;

@end

//
@interface CGGradient( Subclasses)

- (CGColor) startColor;
- (CGColor) endColor;

- (CGFloat) rotation;

- (NSUInteger) numberOfColors;
// location[ 0] is always 0.0
// location[ n -1] is always 1.0
- (CGFloat) locationAtIndex:(NSUInteger) i;
- (CGColor) colorAtIndex:(NSUInteger) i;
- (void) getColors:(CGColor *) colors;
- (void) getLocations:(CGFloat *) locations;

@end


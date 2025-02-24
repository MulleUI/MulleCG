//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "import.h"



@class CGContext;


// In UIViews and UILayers it's convenient to abstract CGColor, CGGradient *
// and CGImage * away, into CGPaint *. That way you can easily change "CSS"
// like the appearance and be animatable.
//
// CGPaint is either a gradient or a texture. A gradient can also be just
// a one color gradient (i.e. a color). CGPaint could be just a protocol,
// but its kind of convenient to have this as a base class for CGGradient
// and CGImage as it involves less typing.
//
// All CGPaint classes are immutable.
//
@interface CGPaint : NSObject < NSCopying, MulleObjCValueProtocols>

+ (CGPaint *) paintWithColor:(CGColor) color;
+ (CGPaint *) paintWithHexColor:(CGHexColor) color;
+ (CGPaint *) paintWithStartColor:(CGColor) startColor
                         endColor:(CGColor) endColor;
+ (CGPaint *) paintWithStartColor:(CGColor) startColor
                         endColor:(CGColor) endColor
                         rotation:(CGFloat) rotation;


//
// for textures this will be gray, for gradients its the middleColor between
// start and end
//
- (CGColor) mainColor;

// this is either "white" or "black", which to draw upon self
- (CGColor) suggestedTextColor;

- (BOOL) isTexture;  // default: YES
- (BOOL) isGradient;  // default: NO (mono color gradient says also NO)
- (BOOL) isMonochrome;
- (BOOL) isOpaque;
- (CGFloat) alpha;   // default: 1.0
- (BOOL) needsBounds;  // mono color, does not need it others do

// for mono colors, this will return just self (guaranteed)
- (CGPaint *) rotatedPaint:(CGFloat) rotation;

// when a paint incorporates a stroke, this is strokeWidth / 2, that will
// overdraw on a fill! (default 0)
- (CGFloat) overdraw;

@end


// subclasses must implement these
@interface CGPaint( Subclasses)

- (CGFloat) rotation;  // default 0.0

@end

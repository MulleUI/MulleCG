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
@interface CGPaint : NSObject < NSCopying>

+ (CGPaint *) paintWithColor:(CGColor) color;

//
// for textures this will be gray, for gradients its the middleColor between
// start and end
//
- (CGColor) mainColor;
- (BOOL) isTexture;  // default: YES
- (CGFloat) alpha;   // default: 1.0

@end


// subclasses must implement these
@interface CGPaint( Subclasses)

- (CGFloat) angle;  // default 0.0

@end

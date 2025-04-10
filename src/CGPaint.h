//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "import.h"



@class CGContext;
@class CGImage;


// In UIViews and UILayers it's convenient to abstract CGColor, CGGradient *
// and CGImage * away, into CGPaint *. That way you can easily change "CSS"
// like the appearance and be animatable.
//
// CGPaint is either a gradient or a texture. A gradient can also be just
// a one color gradient (i.e. a color). CGPaint could be just a protocol,
// but its kind of convenient to have this as a base class for CGGradient
// and CGImage as it involves less typing.
//
// There is no paintWithCGImage: as CGImage is a CGPaint.
// 
// Never transfer a CGPaint in mulleGainAccess or mulleRelinquishAccess as
// it's either threadsafe anyway or already a resource which will have been
// transferred already (or will be)
//
// TODO:
// All CGPaint classes are supposed to be immutable. Exception is CGFramebuffer 
// which is a CGImage and therefore the assumption falls flat... We probably 
// should derive an immutable CGImage from CGFramebuffer instead and put the 
// base CGImage stuff into a separate base class or protocolclass ?
//
@interface CGPaint : NSObject < MulleObjCValueProtocols>

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

- (CGImage *) image;
- (CGImage *) otherImage;

@end


// subclasses must implement these
@interface CGPaint( Subclasses)

@property( readonly) CGFloat   rotation;

@end

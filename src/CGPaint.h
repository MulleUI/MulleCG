//
//  CGPaint.h
//  MulleCG
//
//  Copyright (c) 2023 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
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
// it's either threadsafe anyway or its a resource which will have been
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
                         rotation:(CARotation) rotation;


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
- (CGFloat) alpha;    // default: 1.0
- (BOOL) needsBounds;  // mono color, does not need it others do

// for mono colors, this will return just self (guaranteed)
- (CGPaint *) brightenedPaint:(CGFloat) brighten;
- (CGPaint *) desaturatedPaint:(CGFloat) factor;
- (CGPaint *) dimmedPaint:(CGFloat) dim;
- (CGPaint *) reversedPaint; // rotated 180 degrees
- (CGPaint *) rotatedPaint:(CARotation) rotation;
- (CGPaint *) saturatedPaint:(CGFloat) factor;
- (CGPaint *) transparentPaint:(CGFloat) alpha;

// when a paint incorporates a stroke, this is strokeWidth / 2, that will
// overdraw on a fill! (default 0)
- (CGFloat) overdraw;

- (CGImage *) image;
- (CGImage *) otherImage;

@end


// subclasses must implement these
@interface CGPaint( Subclasses)

@property( readonly) CARotation   rotation;

@end

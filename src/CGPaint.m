//
//  CGPaint.m
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
#import "CGPaint.h"

#import "import-private.h"

#import "CGContext.h"
#import "CGColor+UTF8String.h"
#import "CGImage.h"
#import "CGGradient.h"
#import "CGPaint+Private.h"


@implementation _CGMonoColor

+ (instancetype) newWithColor:(CGColor) color
{
   _CGMonoColor   *obj;

   obj = NSAllocateObject( self, 0, NULL);
   obj->_color = color;
   return( obj);
}


- (CGColor) startColor
{
   return( _color);
}


- (CGColor) endColor
{
   return( _color);
}


- (CGColor) mainColor
{
   return( _color);
}


- (BOOL) needsBounds
{
   return( NO);
}


- (CGFloat) alpha
{
   return( CGColorGetAlpha( _color));
}


- (BOOL) isMonochrome
{
   return( YES);
}


- (NSUInteger) numberOfColors
{
   return( 1);
}


- (CGFloat) locationAtIndex:(NSUInteger) i
{
   assert( ! i);
   return( 0.0);
}


- (CGColor) colorAtIndex:(NSUInteger) i
{
   assert( ! i);
   return( _color);
}


- (void) getColors:(CGColor *) colors
{
   assert( colors);
   *colors = _color;
}


- (void) getLocations:(CGFloat *) locations
{
   assert( locations);
   *locations = 0.0;  // or what ?
}

- (char *) nonLockingUTF8String
{
   return( CGColorUTF8String( _color));
}

@end



//
// gradients in nanovg are somewhat ephemeral, you create them on the fly and
// you don't have to dispose of them. As a CGPaint they are more sticky, but
// don't keep the NVGpaint, which is still generated on the fly.
//
@implementation CGPaint

//
// TODO: could cache most recent 32 colors I guess
//
+ (CGPaint *) paintWithColor:(CGColor) color
{
   return( [[_CGMonoColor newWithColor:color] autorelease]);
}


+ (CGPaint *) paintWithHexColor:(CGHexColor) hexColor
{
   return( [self paintWithColor:CGColorMakeWithHexColor( hexColor)]);
}


+ (CGPaint *) paintWithStartColor:(CGColor) startColor
                         endColor:(CGColor) endColor
{
   if( CGColorEqualToColor( startColor, endColor))
      return( [[_CGMonoColor newWithColor:startColor] autorelease]);

   return( [CGGradient gradientWithStartColor:startColor
                                     endColor:endColor]);
}

+ (CGPaint *) paintWithStartColor:(CGColor) startColor
                         endColor:(CGColor) endColor
                         rotation:(CARotation) rotation
{
   if( rotation == 0.0 && CGColorEqualToColor( startColor, endColor))
      return( [[_CGMonoColor newWithColor:startColor] autorelease]);

   return( [CGGradient gradientWithStartColor:startColor
                                     endColor:endColor
                                     rotation:rotation]);
}


//// avoid warning, this is actually superflous
//- (id) copy 
//{
//   return( [self retain]);
//}


- (CGColor) mainColor
{
   return( CGColorMakeGray());
}


- (BOOL) needsBounds
{
   return( YES);
}


- (BOOL) isNo
{
   return( NO);
}

@method_implementation -isMonochrome = -isNo;
@method_implementation -isGradient = -isNo;
@method_implementation -isTexture = -isNo;


- (BOOL) isOpaque
{
   return( [self alpha] == 1.0);
}


- (CARotation) rotation
{
   return( 0.0);
}


- (CGFloat) alpha
{
   return( 1.0);
}


- (CGPaint *) samePaint:(CGFloat) factor
{
   MULLE_C_UNUSED( factor);
   return( self);
}


@method_implementation -brightenedPaint: = -samePaint:;
@method_implementation -desaturatedPaint: = -samePaint:;
@method_implementation -rotatedPaint: = -samePaint:;
@method_implementation -dimmedPaint: = -samePaint:;
@method_implementation -saturatedPaint: = -samePaint:;
@method_implementation -transparentPaint: = -samePaint:;

- (CGPaint *) reversedPaint // rotated 180 degrees
{
   return( [self rotatedPaint:0.5]);
}


- (CGFloat) overdraw
{
   return( 0.0);
}


- (CGImage *) image
{
   return( nil);
}


@method_implementation -otherImage = -image;


- (CGColor) suggestedTextColor
{
   CGColor   color;

   color = [self mainColor];
   color = CGColorSuggestTextColor( color);
   return( color);
}

@end

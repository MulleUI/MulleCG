//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "CGPaint.h"

#import "import-private.h"

#import "CGContext.h"
#import "CGImage.h"
#import "CGGradient.h"


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
   if( CGColorIsTransparent( color))
      return( nil);

   return( [CGGradient gradientWithColor:color]);
}


- (CGColor) mainColor
{
   return( CGColorMakeGray());
}


- (BOOL) isTexture
{
   return( YES);
}


- (id) copy
{
   return( [self retain]);
}


- (CAAngleRadians) angle
{
   return( 0.0);
}


- (CGFloat) alpha
{
   return( 1.0);
}


@end

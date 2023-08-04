//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "CGPaint.h"

#import "import-private.h"

#import "CGContext.h"
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


- (BOOL) isTexture
{
   return( NO);
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
   if( CGColorIsTransparent( color))
      return( nil);

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
      return( [self paintWithColor:startColor]);
   return( [CGGradient gradientWithStartColor:startColor
                                     endColor:endColor]);
}

+ (CGPaint *) paintWithStartColor:(CGColor) startColor
                         endColor:(CGColor) endColor
                         rotation:(CGFloat) rotation
{
   if( rotation == 0.0 && CGColorEqualToColor( startColor, endColor))
      return( [self paintWithColor:startColor]);
   return( [CGGradient gradientWithStartColor:startColor
                                     endColor:endColor
                                     rotation:rotation]);
}


- (CGColor) mainColor
{
   return( CGColorMakeGray());
}


- (BOOL) needsBounds
{
   return( YES);
}


- (BOOL) isTexture
{
   return( YES);
}


- (BOOL) isGradient
{
   return( NO);
}  // default: NO (mono color gradient says also NO)


- (id) copy
{
   return( [self retain]);
}


- (CGFloat) rotation
{
   return( 0.0);
}


- (CGFloat) alpha
{
   return( 1.0);
}


- (CGPaint *) rotatedPaint:(CGFloat) rotation
{
   return( self);
}

- (CGFloat) overdraw
{
   return( 0.0);
}

@end

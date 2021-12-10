#import "import.h"  // want NSUInteger

#include <math.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>


typedef NVGcolor   CGColor;      // actually a little struct we have this
                                 // misnomer for compatibility
typedef void       *CGColorSpace;  // unsure yet, probably an enum later on

typedef NSUInteger    CGHexColor;

// superflous make-pretend cast helper
static inline CGHexColor   CGUnsignedIntegerAsHexColor( NSUInteger color)
{
   return( (CGHexColor) color);
}

// superflous make-pretend cast helper
static inline NSUInteger   CGHexColorAsUnsignedInteger( CGHexColor color)
{
   return( (NSUInteger) color);
}


static inline CGHexColor   CGHexColorMakeWithRGBA( float r, float g, float b, float a)
{
   assert( r >= 0.0 && r <= 1.0);
   assert( g >= 0.0 && g <= 1.0);
   assert( b >= 0.0 && b <= 1.0);
   assert( a >= 0.0 && a <= 1.0);

   return( ((uint32_t) (0xFF * r) << 24) |
           ((uint32_t) (0xFF * g) << 16) |
           ((uint32_t) (0xFF * b) << 8) |
           ((uint32_t) (0xFF * a)));
}


// NVGColor is a float[ 4] in reality
// MEMO: called "With" because we are not creating an unsigndInteger
static inline CGColor   CGColorMakeWithUnsignedInteger( NSUInteger color)
{
	return nvgRGBA(
		(color >> 24) & 0xff,
		(color >> 16) & 0xff,
		(color >> 8) & 0xff,
		(color >> 0) & 0xff);
}

static inline CGColor   CGColorMakeWithHexColor( CGHexColor color)
{
   return( CGColorMakeWithUnsignedInteger( (NSUInteger) color));
}

// MEMO: NOT called "With" because we are making a gray color
static inline CGColor   CGColorMakeGray( CGFloat gray, CGFloat alpha)
{
   assert( gray >= 0.0 && gray <= 1.0);

   return( nvgRGBAf( 0.2125f * gray, 0.7154f * gray, 0.0721f * gray, alpha));
}


static inline CGColor   CGColorMakeGrayOpaque( CGFloat gray)
{
   assert( gray >= 0.0 && gray <= 1.0);

   return( nvgRGB( 0.2125f * gray, 0.7154f * gray, 0.0721f * gray));
}


static inline CGColor   CGColorMakeRGBA( CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
   assert( r >= 0.0 && r <= 1.0);
   assert( g >= 0.0 && g <= 1.0);
   assert( b >= 0.0 && b <= 1.0);
   assert( a >= 0.0 && a <= 1.0);

   return( nvgRGBAf( r, g, b, a));
}


static inline CGColor   CGColorMakeRGB( CGFloat r, CGFloat g, CGFloat b)
{
   assert( r >= 0.0 && r <= 1.0);
   assert( g >= 0.0 && g <= 1.0);
   assert( b >= 0.0 && b <= 1.0);

   return( nvgRGBf( r, g, b));
}


// Returns color value specified by hue, saturation and lightness.
// HSL values are all in range [0..1], alpha will be set to 1.0.
static inline CGColor   CGColorMakeHSL( CGFloat h, CGFloat s, CGFloat l)
{
   assert( h >= 0.0 && h <= 1.0);
   assert( s >= 0.0 && s <= 1.0);
   assert( l >= 0.0 && l <= 1.0);

   return( nvgHSL( h, s, l));
}

// here alpha is not like nvg 0-255 but 0-1
static inline CGColor
   CGColorMakeHSLA( CGFloat h, CGFloat s, CGFloat l, CGFloat a)
{
   assert( h >= 0.0 && h <= 1.0);
   assert( s >= 0.0 && s <= 1.0);
   assert( l >= 0.0 && l <= 1.0);
   assert( a >= 0.0 && a <= 1.0);

   return( nvgHSLA( h, s, l, a * 255.0));
}

// this is additonal code, not found in nanoVG
// hue is 0-1 (not 0-360)
CGColor   CGColorMakeHSVA( CGFloat h, CGFloat s, CGFloat v, CGFloat a);

// HSL values are all in range [0..1], alpha will be set to 1.0.
static inline CGColor
   CGColorMakeHSV( CGFloat h, CGFloat s, CGFloat l)
{
   return( CGColorMakeHSVA( h, s, l, 1.0));
}

// just convenience for same color, different name
static inline CGColor   CGColorMakeHSBA( CGFloat h, CGFloat s, CGFloat l, CGFloat a)
{
   return( CGColorMakeHSVA( h, s, l, a));
}

static inline CGColor   CGColorMakeHSB( CGFloat h, CGFloat s, CGFloat l)
{
   return( CGColorMakeHSVA( h, s, l, 1.0));
}


static inline CGColor   CGColorMakeRandom( NSUInteger color, NSUInteger mask)
{
   color &= ~mask;
   color |= ((NSUInteger) rand()) & mask;
   return( CGColorMakeWithUnsignedInteger( color));
}


static inline CGColor   CGColorMakeRandomOpaque( void)
{
   return( CGColorMakeRandom( 0xFF, 0xFFFFFF00));
}


static inline int    CGColorGetNumberOfComponents( CGColor color)
{
   return( 4);
}


static inline void   CGColorGetComponents( CGColor color, CGFloat *components)
{
   components[ 0] = color.r;
   components[ 1] = color.g;
   components[ 2] = color.b;
   components[ 3] = color.a;
}


static inline NSUInteger   CGColorGetUnsignedInteger( CGColor color)
{
   return( ((uint32_t) (color.r * 0xFF) << 24)
           | ((uint32_t) (color.g * 0xFF) << 16)
           | ((uint32_t) (color.b * 0xFF) << 8)
           | ((uint32_t) (color.a * 0xFF)) );
}


static inline CGHexColor   CGColorGetHexColor( CGColor color)
{
   return( (CGHexColor) CGColorGetUnsignedInteger( color));
}


static inline CGFloat   CGColorGetGray( CGColor color)
{
   return( ((0.2125f * color.r) + (0.7154f * color.b) + (0.0721f * color.g)) * color.a);
}




void  CGColorGetHSLAComponents( CGColor color, CGFloat *components);

// this is the same as HSBA, third parameter is weird brightness :)
// Lossless back and forth conversion between RGBA and HSBA is not possible.
// Nanovg only works with RGBA. It's best to keep HSBA separate operate on
// it and then convert to RGBA for actual drawing.
//
void  CGColorGetHSVAComponents( CGColor color, CGFloat *components);

// HSL values are all in range [0..1], alpha will be set to 255.
static inline void
   CGColorGetHSBAComponents( CGColor color, CGFloat *components)
{
   CGColorGetHSVAComponents( color, components);
}


static inline CGFloat   CGColorGetAlpha( CGColor color)
{
   return( color.a);
}


static inline CGColor   CGColorDim( CGColor color, CGFloat factor)
{
   assert( factor > 0.0 && factor < 1.0);
   color.a = color.a * factor;
   return( color);
}

static inline int   CGAlphaIsTransparent( CGFloat a)
{
   return( a < 0.5 / 32767.0);  // assume rounding up and 16 bit color depth
}


static inline int   CGAlphaIsOpaque( CGFloat a)
{
   return( a >= 1.0 - 0.5 / 32767.0);  // assume rounding up and 16 bit color depth
}



static inline int   CGColorIsTransparent( CGColor color)
{
   return( CGAlphaIsTransparent( color.a));  // assume rounding up and 16 bit color depth
}


static inline int   CGColorIsOpaque( CGColor color)
{
   return( CGAlphaIsOpaque( color.a));
}


static inline int   CGColorEqualToColor( CGColor color, CGColor other)
{
   // CGColor is not really a ref..
   return( ! memcmp( &color, &other, sizeof( CGColor)));
}


CGColor   CGColorMakeWithUTF8String( char *s);

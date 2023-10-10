//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGGradient.h"

#import "import-private.h"

#include <assert.h>


#import "CGPaint+Private.h"
#import "CGGradient+Private.h"
#include "CGColorDiff.h"


@implementation _CGTwoColorGradient

+ (instancetype) newWithStartColor:(CGColor) startColor
                          endColor:(CGColor) endColor
                          rotation:(CARotation) rotation
{
   _CGTwoColorGradient   *obj;

   obj = NSAllocateObject( self, 0, NULL);
   obj->_startColor = startColor;
   obj->_endColor   = endColor;
   obj->_rotation   = rotation;
   return( obj);
}


- (NSUInteger) numberOfColors
{
   return( 2);
}


- (CGFloat) locationAtIndex:(NSUInteger) i
{
   assert( i >= 0 && i <= 1);
   return( ! i ? 0.0 : 1.0);
}


- (CGColor) colorAtIndex:(NSUInteger) i
{
   assert( i >= 0 && i <= 1);
   return( ! i ? _startColor : _endColor);
}


- (void) getColors:(CGColor *) colors
{
   assert( colors);
   *colors++ = _startColor;
   *colors   = _endColor;
}


- (void) getLocations:(CGFloat *) locations
{
   assert( locations);
   *locations++ = 0.0;
   *locations   = 1.0;
}


- (CGFloat) alpha
{
   return( CGColorGetAlpha( _startColor) + CGColorGetAlpha( _endColor) / 2.0);
}


- (CGGradient *) rotatedGradient:(CARotation) rotation
{
   return( [_CGTwoColorGradient newWithStartColor:_startColor
                                         endColor:_endColor
                                         rotation:_rotation + rotation]);
}

@end



@implementation _CGMultiColorGradient

+ (instancetype) newWithColors:(CGColor *) colors
                     locations:(CGFloat *) locations
                         count:(NSUInteger) count
                      rotation:(CARotation) rotation
{
   float                    *p_location;
   float                    location;
   NSUInteger               i;
   NSUInteger               last;
   struct mulle_allocator   *allocator;
   CGColor                  *p_color;
   _CGMultiColorGradient    *obj;

   assert( count >= 2);

   obj = NSAllocateObject( self, 0, NULL);

   obj->_rotation = rotation;
   allocator      = MulleObjCClassGetAllocator( self);

   _mulle__floatarray_init( &obj->_locations, 0, allocator);
   _mulle__structarray_init( &obj->_colors, sizeof( CGColor), alignof( CGColor), 0, allocator);

   p_color = _mulle__structarray_advance( &obj->_colors, count, allocator);

   memcpy( p_color, colors, sizeof( CGColor) * count);

   p_location = _mulle__floatarray_advance( &obj->_locations, count - 2, allocator);
   last       = count - 1;
   for( i = 1; i < last; i++)
   {
      if( locations)
      {
         location = locations[ i];
         assert( location >= 0.0 && location <= 1.0);
         assert( location >= p_location[ -1]);
      }
      else
         location = (double) i / (count - 1);
      *p_location++ = location;
   }
   return( obj);
}


- (void) dealloc
{
   struct mulle_allocator   *allocator;

   allocator = MulleObjCInstanceGetAllocator( self);

   _mulle__floatarray_done( &_locations, allocator);
   _mulle__structarray_done( &_colors, allocator);

   [super dealloc];
}


- (CGColor) startColor
{
   return( *(CGColor *) _mulle__structarray_get( &_colors, 0));
}


- (CGColor) endColor
{
   return( *(CGColor *) _mulle__structarray_get_last( &_colors));
}


- (NSUInteger) numberOfColors
{
   return( _mulle__structarray_get_count( &_colors));
}


- (CGFloat) locationAtIndex:(NSUInteger) i
{
   NSUInteger  n;

   if( i == 0)
      return( 0.0);
   n = _mulle__structarray_get_count( &_colors);
   if( i == n - 1)
      return( 1.0);
   if( i >= n)
      abort();
   return( _mulle__floatarray_get( &_locations, i - 1));
}


- (CGColor) colorAtIndex:(NSUInteger) i
{
   if( i >= _mulle__structarray_get_count( &_colors))
      abort();
   return( *(CGColor *) _mulle__structarray_get( &_colors, i));
}


- (void) getColors:(CGColor *) colors
{
   unsigned int  n;

   assert( colors);

   n = _mulle__structarray_get_count( &_colors);
   memcpy( colors,
           _mulle__structarray_get( &_colors, 0),
           sizeof( CGColor) * n);
}


- (void) getLocations:(CGFloat *) locations
{
   unsigned int  i, n;

   *locations++ = 0.0;
   n = _mulle__floatarray_get_count( &_locations);
   for( i = 0; i < n; i++)
      *locations++ = _mulle__floatarray_get( &_locations, i);
   *locations++ = 1.0;
}


- (CGFloat) alpha
{
   unsigned int  i, n;
   CGFloat       alpha;

   alpha = 0.0;
   n     = _mulle__structarray_get_count( &_colors);
   for( i = 0; i < n; i++)
      alpha += CGColorGetAlpha( * (CGColor *) _mulle__structarray_get( &_colors, i));
   alpha /= n;
   return( alpha);
}

@end


@implementation CGGradient



static id   CGGradientNewWithStartColorAndEndColor(
                                        CGColor startColor,
                                        CGColor endColor,
                                        CARotation rotation)
{
   if( CGColorEqualToColor( startColor, endColor))
      return( [_CGMonoColor newWithColor:startColor]);

   return( [_CGTwoColorGradient newWithStartColor:startColor
                                         endColor:endColor
                                         rotation:rotation]);
}


static id   CGGradientNewWithColors( CGColor *colors,
                                     CGFloat *locations,
                                     NSUInteger count,
                                     CARotation rotation)
{
   // basic simplification, could do more though
   if( count == 2 && CGColorEqualToColor( colors[ 0], colors[ 1]))
      count = 1;

   switch( count)
   {
   case 0  : return( nil);
   case 1  : return( [_CGMonoColor newWithColor:colors[ 0]]);
   case 2  : return( [_CGTwoColorGradient newWithStartColor:colors[ 0]
                                                   endColor:colors[ 1]
                                                   rotation:rotation]);
   default : return( [_CGMultiColorGradient newWithColors:colors
                                                 locations:locations
                                                     count:count
                                                  rotation:rotation]);
   }
}


+ (instancetype) gradientWithColors:(CGColor *) colors
                          locations:(CGFloat *) locations
                              count:(NSUInteger) count
                           rotation:(CARotation) rotation
{
   return( [CGGradientNewWithColors( colors, locations, count, rotation) autorelease]);
}


+ (instancetype) gradientWithColors:(CGColor *) colors
                          locations:(CGFloat *) locations
                              count:(NSUInteger) count
{
   return( [CGGradientNewWithColors( colors, locations, count, 0.0f) autorelease]);
}


+ (instancetype) gradientWithStartColor:(CGColor) startColor
                               endColor:(CGColor) endColor
                               rotation:(CARotation) rotation
{
   return( [CGGradientNewWithStartColorAndEndColor( startColor,
                                                    endColor,
                                                    rotation) autorelease]);
}


+ (instancetype) gradientWithStartColor:(CGColor) startColor
                               endColor:(CGColor) endColor
{
   return( [CGGradientNewWithStartColorAndEndColor( startColor, endColor, 0.0f) autorelease]);
}


- (instancetype) initWithColors:(CGColor *) colors
                      locations:(CGFloat *) locations
                          count:(NSUInteger) count
                       rotation:(CARotation) rotation
{
   return( CGGradientNewWithColors( colors, locations, count, rotation));
}


- (instancetype) initWithStartColor:(CGColor) startColor
                           endColor:(CGColor) endColor
                           rotation:(CARotation) rotation
{
   return( CGGradientNewWithStartColorAndEndColor( startColor,
                                                   endColor,
                                                   rotation));
}


- (instancetype) initWithStartColor:(CGColor) startColor
                           endColor:(CGColor) endColor
{
   return( CGGradientNewWithStartColorAndEndColor( startColor,
                                                   endColor,
                                                   0.0f));
}


- (instancetype) initWithColors:(CGColor *) colors
                      locations:(CGFloat *) locations
                          count:(NSUInteger) count
{
   return( CGGradientNewWithColors( colors, locations, count, 0.0f));
}


// init w/o colors makes no sense
- (instancetype) init
{
   [self release];
   return( nil);
}



- (id) copy 
{
   return( [self retain]);
}


- (CGColor) mainColor
{
   return( CGColorInterpolate( [self startColor], [self endColor], 0.5));
}


- (BOOL) isTexture
{
   return( NO);
}


- (BOOL) isGradient
{
   return( YES);
}  // default: NO (mono color gradient says also NO)


- (char *) UTF8String
{
   char         *name;
   char         *s;
   NSUInteger   i, n;
   CGColor      color;
   CGFloat      location;

   mulle_buffer_do_string( buffer, NULL, s)
   {
      name = MulleObjCClassGetNameUTF8String( NSClassFromObject( self));
      mulle_buffer_sprintf( buffer, "<%s %p [ ", name, self);

      n = [self numberOfColors];
      i = 0;
      for(;;)
      {
         location = [self locationAtIndex:i];
         color    = [self colorAtIndex:i];
         name     = CGColorGetCommonName( color);
         if( name)
            mulle_buffer_add_string( buffer, name);
         else
            mulle_buffer_sprintf( buffer, "0x%08x", CGColorGetHexColor( color));
         if( n == 1)
            break;
         mulle_buffer_sprintf( buffer, " (%.2f)", location);
         if( ++i == n)
            break;
         mulle_buffer_add_string( buffer, ", ");
      }
      mulle_buffer_add_string( buffer, "]>");
   }

   return( MulleObjCAutoreleaseAllocation( s, NULL));
}



- (CGGradient *) rotatedGradient:(CAAngle) rotation
{
   NSUInteger   count;
   CGGradient   *gradient;

   count = [self numberOfColors];
   mulle_flexarray_do( tmp_locations, float, 8, count)
   {
      [self getLocations:tmp_locations];
      mulle_flexarray_do( tmp_colors, CGColor, 8, count)
      {
         [self getColors:tmp_colors];
         gradient = [CGGradient gradientWithColors:tmp_colors
                                         locations:tmp_locations
                                             count:count
                                          rotation:_rotation + rotation];
      }
   }
   return( gradient);
}


- (CGPaint *) rotatedPaint:(CARotation) rotation
{
   return( [self rotatedGradient:rotation]);
}


- (CGGradient *) reversedGradient // rotated 180 degrees
{
   return( [self rotatedGradient:0.5f]);
}


- (CGGradient *) gradientByChangingColorsWithFunction:(CGColor (*)( CGColor, void *)) f
                                             userInfo:(void *) userInfo
{
   NSUInteger   count;
   CGGradient   *gradient;
   NSUInteger   i;

   count = [self numberOfColors];
   mulle_flexarray_do( tmp_locations, float, 8, count)
   {
      [self getLocations:tmp_locations];
      mulle_flexarray_do( tmp_colors, CGColor, 8, count)
      {
         [self getColors:tmp_colors];
         for( i = 0; i < count; i++)
            tmp_colors[ i] = (*f)( tmp_colors[ i], userInfo);

         gradient = [CGGradient gradientWithColors:tmp_colors
                                         locations:tmp_locations
                                             count:count
                                          rotation:_rotation];
      }
   }
   return( gradient);
}


static CGColor   dimmer( CGColor color, void *dim_p)
{
   CGFloat   dim = *(CGFloat *) dim_p;

   return( CGColorDim( color, dim));
}


- (CGGradient *) brightenedGradient:(CGFloat) brighten
{
   brighten = -brighten;
   return( [self gradientByChangingColorsWithFunction:dimmer
                                             userInfo:&brighten]);
}


- (CGGradient *) dimmedGradient:(CGFloat) dim
{
   return( [self gradientByChangingColorsWithFunction:dimmer
                                             userInfo:&dim]);
}



static CGColor   alphizer( CGColor color, void *alpha_p)
{
   CGFloat   alpha = *(CGFloat *) alpha_p;

   return( CGColorBySettingAlpha( color, alpha));
}


- (CGGradient *) transparentGradient:(CGFloat) alpha
{
   return( [self gradientByChangingColorsWithFunction:alphizer
                                             userInfo:&alpha]);
}


@end


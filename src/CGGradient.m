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
                          rotation:(CGFloat) rotation
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


- (CGGradient *) rotatedGradient:(CGFloat) rotation
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
                      rotation:(CGFloat) rotation
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


+ (instancetype) gradientWithStartColor:(CGColor) startColor
                               endColor:(CGColor) endColor
                                  rotation:(CGFloat) rotation
{
   return( [[_CGTwoColorGradient newWithStartColor:startColor
                                          endColor:endColor
                                          rotation:rotation] autorelease]);
}


+ (instancetype) gradientWithColors:(CGColor *) colors
                          locations:(CGFloat *) locations
                              count:(NSUInteger) count
                           rotation:(CGFloat) rotation
{
   if( count < 2)
      return( nil);

   return( [[_CGMultiColorGradient newWithColors:colors
                                       locations:locations
                                           count:count
                                        rotation:rotation] autorelease]);
}



+ (instancetype) gradientWithStartColor:(CGColor) startColor
                               endColor:(CGColor) endColor
{
   return( [self gradientWithStartColor:startColor
                               endColor:endColor
                               rotation:0.0]);
}


+ (instancetype) gradientWithColors:(CGColor *) colors
                          locations:(CGFloat *) locations
                              count:(NSUInteger) count
{
   return( [self gradientWithColors:colors
                          locations:locations
                              count:count
                           rotation:0.0]);
}


- (instancetype) initWithStartColor:(CGColor) startColor
                           endColor:(CGColor) endColor
                           rotation:(CGFloat) rotation
{
   return( [_CGTwoColorGradient newWithStartColor:startColor
                                         endColor:endColor
                                        rotation:rotation]);
}


- (instancetype) initWithColors:(CGColor *) colors
                      locations:(CGFloat *) locations
                          count:(NSUInteger) count
                       rotation:(CGFloat) rotation
{
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


- (instancetype) initWithStartColor:(CGColor) startColor
                           endColor:(CGColor) endColor
{
   return( [_CGTwoColorGradient newWithStartColor:startColor
                                         endColor:endColor
                                         rotation:0.0]);
}



- (instancetype) initWithColors:(CGColor *) colors
                      locations:(CGFloat *) locations
                          count:(NSUInteger) count
{
   return( [self initWithColors:colors
                      locations:locations
                          count:count
                       rotation:0.0]);
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


- (CGPaint *) rotatedPaint:(CGFloat) rotation
{
   return( [self rotatedGradient:rotation]);
}


- (CGGradient *) reversedGradient // rotated 180 degrees
{
   return( [self rotatedGradient:0.5]);
}

@end


//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGBlendedPaint.h"

#import "import-private.h"

#import "CGPaint.h"

#include <mulle-objc-runtime/mulle-metaabi-call.h>

#ifndef mulle_metaabi_call
# define mulle_metaabi_call   mulle_metaabi_object_call
#endif


@implementation CGPaint( CGBlendedPaint)

+ (instancetype) paintWithPaint:(CGPaint *) paint
                     otherPaint:(CGPaint *) otherPaint
                          blend:(CGFloat) blend
                       rotation:(CARotation) rotation
{
   CGBlendedPaint   *blended;

   blended = [CGBlendedPaint alloc];
   blended = [blended initWithPaint:paint
                         otherPaint:otherPaint
                              blend:blend
                           rotation:rotation];
   blended = [blended autorelease];
   return( blended);
}

@end


@implementation CGBlendedPaint

- (instancetype) initWithPaint:(CGPaint *) paint
                    otherPaint:(CGPaint *) otherPaint
                         blend:(CGFloat) blend
                      rotation:(CARotation) rotation
 {
   if( ! paint && ! otherPaint)
   {
      [self release];
      return( nil);
   }

   _paint = [paint copy];
   // for "rotation" only animation, this isn't unlikely
   if( ! otherPaint || otherPaint == paint)
      _otherPaint = [_paint retain]; // retain out copy
   else
      _otherPaint = [otherPaint copy];

   _blend    = blend;
   _rotation = rotation;

   return( self);
}


- (void) dealloc
{
   [_paint release];
   [_otherPaint release];

   [super dealloc];
}



// guess
- (BOOL) isTexture
{
   return( [_paint isTexture] || [_otherPaint isTexture]);
}



- (CGPaint *) colorChangedPaint:(CGFloat) value
                       selector:(SEL) sel
{
   CGPaint   *first;
   CGPaint   *second;

   mulle_metaabi_call( &first, _paint, sel, value);
   mulle_metaabi_call( &second, _otherPaint, sel, value);
   if( first == _paint && second == _otherPaint)
      return( self);

   return( [CGBlendedPaint paintWithPaint:first
                               otherPaint:second
                                    blend:_blend
                                 rotation:_rotation]);
}

- (CGPaint *) brightenedPaint:(CGFloat) brighten
{
   return( [self colorChangedPaint:brighten
                          selector:_cmd]);
}

@method_implementation -desaturatedPaint: = -brightenedPaint:;
@method_implementation -dimmedPaint:      = -brightenedPaint:;
@method_implementation -saturatedPaint:   = -brightenedPaint:;
@method_implementation -transparentPaint: = -brightenedPaint:;


- (CGPaint *) rotatedPaint:(CARotation) rotation
{
   if( rotation == 0.0)
      return( self);

   return( [CGBlendedPaint paintWithPaint:_paint
                               otherPaint:_otherPaint
                                    blend:_blend
                                 rotation:rotation + _rotation]);
}


@end

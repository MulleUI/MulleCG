//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGBlendedPaint.h"

#import "import-private.h"

#import "CGPaint.h"


@implementation CGPaint( CGBlendedPaint)

+ (instancetype) paintWithPaint:(CGPaint *) paint
                     otherPaint:(CGPaint *) otherPaint
                          blend:(CGFloat) blend
                       rotation:(CGFloat) rotation
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
                      rotation:(CGFloat) rotation
 {
   if( ! paint && ! otherPaint)
   {
      [self release];
      return( nil);
   }

   _paint = [paint copy];
   // for "rotation" only animation, this isn't unlikely
   if( ! otherPaint || otherPaint == paint)
      _otherPaint = [paint retain];
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


// MEMO: never do this for paints
// - (void) mulleGainAccess
// {
//    [super mulleGainAccess];
//    [self->_paint mulleGainAccess];  
//    [self->_otherPaint mulleGainAccess];  
// }
// 
// 
// - (void) mulleRelinquishAccess
// {
//    [self->_otherPaint mulleRelinquishAccess];  
//    [self->_paint mulleRelinquishAccess];  
//    [super mulleRelinquishAccess];
// }
// 


- (CGPaint *) rotatedPaint:(CGFloat) rotation
{
   if( rotation == 0.0)
      return( self);

   return( [CGBlendedPaint paintWithPaint:_paint
                               otherPaint:_otherPaint
                                    blend:_blend
                                 rotation:rotation + _rotation]);
}

// guess
- (BOOL) isTexture
{
   return( [_paint isTexture] || [_otherPaint isTexture]);
}

@end

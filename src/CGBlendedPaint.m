//
//  CGBlendedPaint.m
//  MulleCG
//
//  Copyright (c) 2025 Nat! - Mulle kybernetiK.
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

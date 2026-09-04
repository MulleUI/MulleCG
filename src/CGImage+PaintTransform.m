//
//  CGImage+PaintTransform.m
//  MulleCG
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
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
// CGImage+PaintTransform.m
// MulleCG
//
// CGImage overrides for paint transform methods.
// Returns CGImagePaint instances with the appropriate effect parameters.
//
#import "CGImage.h"
#import "CGImagePaint.h"

#import "import-private.h"


@implementation CGImage( PaintTransform)

- (CGPaint *) rotatedPaint:(CARotation) rotation
{
   if( rotation == 0.0)
      return( self);

   return( [[[CGImagePaint alloc] initWithImage:self
                                      rotation:rotation
                                         alpha:1.0
                                    saturation:1.0
                                    brightness:0.0] autorelease]);
}


- (CGPaint *) transparentPaint:(CGFloat) alpha
{
   return( [[[CGImagePaint alloc] initWithImage:self
                                      rotation:0.0
                                         alpha:alpha
                                    saturation:1.0
                                    brightness:0.0] autorelease]);
}


- (CGPaint *) desaturatedPaint:(CGFloat) factor
{
   return( [[[CGImagePaint alloc] initWithImage:self
                                      rotation:0.0
                                         alpha:1.0
                                    saturation:1.0 - factor
                                    brightness:0.0] autorelease]);
}


- (CGPaint *) saturatedPaint:(CGFloat) factor
{
   return( [[[CGImagePaint alloc] initWithImage:self
                                      rotation:0.0
                                         alpha:1.0
                                    saturation:1.0 + factor
                                    brightness:0.0] autorelease]);
}


- (CGPaint *) brightenedPaint:(CGFloat) brighten
{
   return( [[[CGImagePaint alloc] initWithImage:self
                                      rotation:0.0
                                         alpha:1.0
                                    saturation:1.0
                                    brightness:brighten] autorelease]);
}


- (CGPaint *) dimmedPaint:(CGFloat) dim
{
   return( [[[CGImagePaint alloc] initWithImage:self
                                      rotation:0.0
                                         alpha:1.0
                                    saturation:1.0
                                    brightness:-dim] autorelease]);
}

@end

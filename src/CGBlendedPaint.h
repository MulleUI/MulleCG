//
//  CGBlendedPaint.h
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
#ifdef __has_include
# if __has_include( "CGPaint.h")
#  import "CGPaint.h"
# endif
#endif

#import "import.h"

typedef NS_ENUM( NSUInteger, CGBlendedPaintBlendStyle)
{
   CGBlendedPaintBlendAlpha = 0
};


//
// this paint exists for the sake of animation, you have two paints and
// can interpolate between both with "blend". Currently only alpha blending
// is supported.
//
@interface CGBlendedPaint : CGPaint

@property( readonly) CGPaint     *paint;
@property( readonly) CGPaint     *otherPaint;
@property( readonly) CGFloat     blend;
//@property( assign) CGBlendedPaintBlendStyle   blendStyle;
@property( readonly) CARotation  rotation;

- (instancetype) initWithPaint:(CGPaint *) paint
                    otherPaint:(CGPaint *) otherPaint
                         blend:(CGFloat) blend
                      rotation:(CARotation) rotation;

@end


// class clustering... :)
@interface CGPaint( CGBlendedPaint)

+ (instancetype) paintWithPaint:(CGPaint *) paint
                     otherPaint:(CGPaint *) otherPaint
                          blend:(CGFloat) blend
                       rotation:(CARotation) rotation;

@end

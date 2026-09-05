//
//  CGPaint+Drawing.h
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
#import "import.h"

#import "CGPaintable.h"


@class CGContext;
@class CGImage;



//
// functions defined in the various: CG*+nanovg.m implementations
//


// CGGradient+nanovg.m

MULLE_CG_GLOBAL
void   CGContextFillLinearGradient( CGContext *context,
                                    CGPoint start,
                                    CGColor startColor,
                                    CGPoint end,
                                    CGColor endColor);

MULLE_CG_GLOBAL
void   CGContextStrokeLinearGradient( CGContext *context,
                                      CGPoint start,
                                      CGColor startColor,
                                      CGPoint end,
                                      CGColor endColor,
                                      CGFloat strokeWidth);

MULLE_CG_GLOBAL
void   CGContextFillBoxGradient( CGContext *context,
                                 CGRect rect,
                                 CGFloat cornerRadius,
                                 CGColor color,
                                 CGFloat feather,
                                 CGColor featherColor);


MULLE_CG_GLOBAL
void   CGContextStrokeBoxGradient( CGContext *context,
                                   CGRect rect,
                                   CGFloat cornerRadius,
                                   CGColor color,
                                   CGFloat feather,
                                   CGColor featherColor,
                                   CGFloat strokeWidth);


MULLE_CG_GLOBAL
void   CGContextFillRadialGradient( CGContext *context,
                                    CACircle circle,
                                    CGColor color,
                                    CGFloat innerRadius,
                                    CGColor innerColor);


MULLE_CG_GLOBAL
void   CGContextStrokeRadialGradient( CGContext *context,
                                      CACircle circle,
                                      CGColor color,
                                      CGFloat innerRadius,
                                      CGColor innerColor,
                                      CGFloat strokeWidth);


MULLE_CG_GLOBAL
void   CGContextFillGradientColors( CGContext *context,
                                    CGRect rect,
                                    CGColor startColor,
                                    CGColor endColor,
                                    CGFloat colorRotation);

MULLE_CG_GLOBAL
void   CGContextStrokeGradientColors( CGContext *context,
                                      CGRect rect,
                                      CGColor startColor,
                                      CGColor endColor,
                                      CGFloat colorRotation,
                                      CGFloat strokeWidth);


MULLE_CG_GLOBAL
void   CGContextFillImageOptions( CGContext *context,
                                      CGImage *image,
                                      CGRect rect,
                                      CGFillOptions *options);


MULLE_CG_GLOBAL
void   CGContextStrokeImageOptions( CGContext *context,
                                        CGImage *image,
                                        CGRect rect,
                                        CGFloat strokeWidth,
                                        CGStrokeOptions *options);


//
// paint often carry the "rect" within them, so this is the easy way...
//
static inline void   CGContextFillImage( CGContext *context, CGImage *image)
{
   CGContextFillImageOptions( context,
                                  image,
                                  CGRectNull,
                                  NULL);
}


static inline void   CGContextStrokeImage( CGContext *context, CGImage *image, CGFloat strokeWidth)
{
   CGContextStrokeImageOptions( context,
                                    image,
                                    CGRectNull,
                                    strokeWidth,
                                    NULL);
}


MULLE_CG_GLOBAL
void  CGContextDrawBitmapDrawableInRect( CGContext *context,
                                         id <CGBitmapDrawable> drawable,
                                         CGRect rect,
                                         CGRect patternRect,
                                         CGDrawableOptions *options);

MULLE_CG_GLOBAL
void  CGContextDrawBitmapDrawableInRect( CGContext *context,
                                         id <CGBitmapDrawable> drawable,
                                         CGRect rect,
                                         CGRect patternRect,
                                         CGDrawableOptions *options);


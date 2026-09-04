//
//  CGPaintable.m
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
#import "CGPaintable.h"
#import "CGContext+Drawing.h"
#import "CGGradient.h"
#import "CGGradient+Private.h"
#import "CGImage.h"
#import "CGImagePaint.h"
#import "CGBlendedPaint.h"

#import "import-private.h"


@implementation  CGPaintable


- (void) fillWithBounds:(CGRect) bounds
                options:(struct CGFillOptions *) options
                context:(CGContext *) context
{
   MULLE_C_UNUSED( bounds);
   MULLE_C_UNUSED( options);
   MULLE_C_UNUSED( context);
   // subclasses must override
   MULLE_OBJC_SUBCLASS_REQUIRES_IMPLEMENTATION;
}


- (void) strokeWithBounds:(CGRect) bounds
              strokeWidth:(CGFloat) strokeWidth
                  options:(struct CGStrokeOptions *) options
                  context:(CGContext *) context
{
   MULLE_C_UNUSED( bounds);
   MULLE_C_UNUSED( strokeWidth);
   MULLE_C_UNUSED( options);
   MULLE_C_UNUSED( context);
   // subclasses must override
   MULLE_OBJC_SUBCLASS_REQUIRES_IMPLEMENTATION;
}


- (CGImage *) image
{
   return( nil);
}


- (CGImage *) otherImage
{
   return( nil);
}


@end


@implementation CGPaint( CGPaintable)
@end


void   CGContextFillPaintableOptions( CGContext *context,
                                      id <CGPaintable> paint,
                                      CGRect bounds,
                                      CGFillOptions *options)
{
   static CGFillOptions   CGDefaultFillOptions_static = CGFillOptionsDefault;

   if( options)
      bounds = CGRectMakeFillRect( bounds, options->strokeWidth, options->relation);
   else
      options = &CGDefaultFillOptions_static;

   [paint fillWithBounds:bounds
                 options:options
                 context:context];
}


void   CGContextStrokePaintableOptions( CGContext *context,
                                        id <CGPaintable> paint,
                                        CGRect  bounds,
                                        CGFloat strokeWidth,
                                        CGStrokeOptions *options)
{
   static CGStrokeOptions   CGDefaultStrokeOptions_static = CGStrokeOptionsDefault;

   assert( strokeWidth > 0.0f);

   options  = options ? options : &CGDefaultStrokeOptions_static;
   bounds   = CGRectMakeStrokeRect( bounds, strokeWidth, options->relation);

   [paint strokeWithBounds:bounds
               strokeWidth:strokeWidth
                   options:options
                   context:context];
}

//
//  CGImage+CGPaintable.m
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
#import "CGImage.h"
#import "CGPaintable.h"
#import "CGContext+Drawing.h"
#import "CGContext+Render.h"

#import "import-private.h"

// declared in CGDrawable.m but not in the header
CGPoint  CGRectGetOriginToTexturePointForRotationAndExtent( CGRect rect,
                                                            CGPoint texturePoint,
                                                            CARotation rotation,
                                                            CGSize extent);


@implementation CGImage( CGPaintable)

- (void) drawRect:(CGRect) rect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context
{
   CGTextureID   textureID;
   CGSize        size;
   CGSize        extent;
   CGRect        patternRect;
   CGPoint       texturePoint;

   if( ! context)
      return;

   if( ! options)
      options = &CGDrawableOptionsDefault;

   // CGImage IS the texture — no need to call cgImageWithContext:textureFlags:
   // but if multisampled, resolve first so it can be used as a pattern
   if( [self isMultiSample])
   {
      [[self resolvedImage] drawRect:rect options:options context:context];
      return;
   }
   textureID = [self textureID];
   if( textureID == CGTextureIDInvalid)
      return;

   size = [self size];

   if( options->flags.flip & CGFlipHorizontally)
   {
      rect.origin.x   += rect.size.width;
      rect.size.width  = -rect.size.width;
      size.width       = -size.width;
   }
   if( options->flags.flip & CGFlipVertically)
   {
      rect.origin.y    += rect.size.height;
      rect.size.height  = -rect.size.height;
      size.height       = -size.height;
   }

   extent = rect.size;
   if( options->scale == CGScaleNone || (options->flags.repeat & CGRepeatHorizontally))
      extent.width = size.width;
   if( options->scale == CGScaleNone || (options->flags.repeat & CGRepeatVertically))
      extent.height = size.height;

   texturePoint.x     = 0.5;
   texturePoint.y     = 0.5;
   patternRect.origin = CGRectGetOriginToTexturePointForRotationAndExtent( rect,
                                                                           texturePoint,
                                                                           options->rotation,
                                                                           extent);
   patternRect.size   = extent;

   CGContextBeginPath( context);
   CGContextRoundedRectVarying( context, rect, options->cornerInsets);
   CGContextSetFillImagePattern( context, textureID, patternRect,
                                 options->rotation, options->alpha);
   CGContextFill( context);
}

- (void) fillWithBounds:(CGRect) rect
                options:(struct CGFillOptions *) options
                context:(CGContext *) context
{
   CGImage       *image;
   CGTextureID   textureID;

   assert( options);

   image     = [self resolvedImage];
   textureID = [image textureID];
   if( ! context || textureID == CGTextureIDInvalid)
      return;

   CGContextSetFillImagePattern( context, textureID, rect,
                                 options->paint.rotation + [image rotation],
                                 options->paint.alpha * [image alpha]);
   CGContextFill( context);
}


- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
                  options:(struct CGStrokeOptions *) options
                  context:(CGContext *) context
{
   CGImage       *image;
   CGTextureID   textureID;

   assert( options);
   assert( strokeWidth > 0.0f);

   image     = [self resolvedImage];
   textureID = [image textureID];
   if( ! context || textureID == CGTextureIDInvalid)
      return;

   CGContextSetStrokeImagePattern( context, textureID, rect,
                                   options->paint.rotation + [image rotation],
                                   options->paint.alpha * [image alpha]);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}

@end


void   CGContextFillImageOptions( CGContext *context,
                                  CGImage *image,
                                  CGRect rect,
                                  CGFillOptions *options)
{
   static CGFillOptions   defaults = CGFillOptionsDefault;
   CGFloat                alpha;
   CARotation             rotation;

   if( ! options)
      options = &defaults;

   alpha    = [image alpha] * options->paint.alpha;
   rotation = [image rotation] + options->paint.rotation;

   if( alpha <= 0.0f)
   {
      CGContextFillColor( context, CGColorMakeTransparent());
      return;
   }

   if( CGRectIsNull( rect))
      rect = CGRectMakeWithSize( [image size]);

   rect = CGRectMakeFillRect( rect, options->strokeWidth, options->relation);
   CGContextSetFillImagePattern( context, [image textureID], rect, rotation, alpha);
}


void   CGContextStrokeImageOptions( CGContext *context,
                                    CGImage *image,
                                    CGRect rect,
                                    CGFloat strokeWidth,
                                    CGStrokeOptions *options)
{
   static CGStrokeOptions   defaults = CGStrokeOptionsDefault;
   CGFloat                  alpha;
   CARotation               rotation;

   if( ! options)
      options = &defaults;

   alpha    = [image alpha] * options->paint.alpha;
   rotation = [image rotation] + options->paint.rotation;

   if( alpha <= 0.0f)
   {
      CGContextStrokeColor( context, CGColorMakeTransparent());
      return;
   }

   if( CGRectIsNull( rect))
      rect = CGRectMakeWithSize( [image size]);

   rect = CGRectMakeStrokeRect( rect, strokeWidth, options->relation);
   CGContextSetStrokeImagePattern( context, [image textureID], rect, rotation, alpha);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}


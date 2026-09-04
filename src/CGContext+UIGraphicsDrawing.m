//
//  CGContext+UIGraphicsDrawing.m
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
#import "CGContext+UIGraphicsDrawing.h"

#import "import-private.h"

#import "CGContext+Drawing.h"
#import "CGContext+CGImage.h"
#import "CGDrawable.h"
#import "CGImage.h"
#import "CGPaint+Drawing.h"
#import "CGTypes.h"


void  CGContextDrawBitmapDrawableInRect( CGContext *context,
                                         id <CGBitmapDrawable> drawable,
                                         CGRect rect,
                                         CGRect patternRect,
                                         CGDrawableOptions *options)
{
   CGImage       *image;
   CGTextureID   textureID;
   NSUInteger    textureFlags;

   if( ! options)
      options = &CGDrawableOptionsDefault;

   textureFlags = [drawable textureFlags];
   if( options->flags.repeat != CGRepeatAsIs)
   {
      textureFlags &= ~(CGTextureRepeatX|CGTextureRepeatY);
      if( options->flags.repeat & CGRepeatHorizontally)
         textureFlags |= CGTextureRepeatX;
      if( options->flags.repeat & CGRepeatVertically)
         textureFlags |= CGTextureRepeatY;
   }

   image = [drawable cgImageWithContext:context
                           textureFlags:textureFlags];
   if( ! image)
      return;

   textureID = [image textureID];
   if( textureID == CGTextureIDInvalid)
      return;

   if( options->flags.flip & CGFlipHorizontally)
   {
      patternRect.origin.x   += rect.size.width;
      rect.origin.x          += rect.size.width;
      rect.size.width        *= -1.0;
      patternRect.size.width *= -1.0;
   }
   if( options->flags.flip & CGFlipVertically)
   {
      patternRect.origin.y    += rect.size.height;
      rect.origin.y           += rect.size.height;
      rect.size.height        *= -1.0;
      patternRect.size.height *= -1.0;
   }

   CGContextBeginPath( context);
   CGContextRoundedRectVarying( context, rect, options->cornerInsets);
   CGContextSetFillImagePattern( context, textureID, patternRect,
                                 options->rotation, options->alpha);
   CGContextFill( context);
}



@implementation CGContext ( UIGraphicsDrawing)

- (void) setCompositionMode:(UIGraphicsCompositionMode) mode
{
   CGContextGlobalCompositeOperation( self, mode);
}


- (void) fillRect:(CGRect) rect
         hexColor:(NSUInteger) color
{
   CGContextBeginPath( self);
   {
      CGContextRect( self, rect);
      CGContextFillColor( self, CGColorMakeWithHexColor( color));
   }
   CGContextFill( self);
}


- (void) strokeRect:(CGRect) rect
        strokeWidth:(CGFloat) strokeWidth
           hexColor:(NSUInteger) color
{
   if( strokeWidth <= 0.0f)
      return;

   CGContextBeginPath( self);
   {
      CGContextRect( self, rect);
      CGContextStrokeWidth( self, strokeWidth);
      CGContextStrokeColor( self, CGColorMakeWithHexColor( color));
   }
   CGContextStroke( self);
}


- (void) blitRect:(CGRect) rect
            image:(id) image
            scale:(BOOL) scale
{
   CGDrawableOptions   *options;

   // this code will be used if MSAA is not available, as
   // _CGContextBlitFramebufferImage will be just an empty shell
   //

   CGContextSave( self);
   {
      CGContextGlobalCompositeOperation( self, CGCompositeOperationCopy);

      options = scale ? &CGDrawableOptionsScaleToFit :
                        &CGDrawableOptionsDefault;
      [image drawRect:rect
              options:options
              context:self];
   }
   CGContextRestore( self);
}



- (void) drawRect:(CGRect) rect
            image:(id) image
            scale:(BOOL) scale
{
   CGDrawableOptions   *options;

   options = scale ? &CGDrawableOptionsScaleToFit :
                     &CGDrawableOptionsDefault;
   assert( ! [image isMultiSample]);
   [image drawRect:rect
           options:options
           context:self];
}



- (void) fillRect:(CGRect) rect
           bitmap:(struct CGBitmap) fb
            scale:(BOOL) scale
{
   CGImage               *image;
   CGDrawableOptions     *options;
   struct CGBitmapInfo   convertedBitmapInfo;
   struct CGBitmap       convertedFb;

   if( CGBitmapIsNull( fb))
      return;

   convertedBitmapInfo = CGBitmapInfoMakeWHRGBABytes( fb.info.size.width, fb.info.size.height);
   if( CGBitmapNeedsConversion( fb, convertedBitmapInfo))
   {
      convertedFb = CGBitmapConvert( fb, convertedBitmapInfo, NULL);
      if( CGBitmapIsNull( convertedFb))
      {
         fprintf( stderr, "unsupported CGImage format\n");
#ifdef DEBUG
         abort();
#endif
         return;
      }

      image = [[[CGImage alloc] initWithBitmap:convertedFb
                                  textureFlags:0
                                nameUTF8String:NULL
                                       context:self] autorelease];
      CGBitmapDone( convertedFb);
   }
   else
      image = [[[CGImage alloc] initWithBitmap:fb
                                  textureFlags:0
                                nameUTF8String:NULL
                                       context:self] autorelease];

   options = scale ? &CGDrawableOptionsScaleToFit :
                     &CGDrawableOptionsDefault;
   [image drawRect:rect
           options:options
           context:self];

   // just for debugging, draws a frame somewhere
#ifdef DEBUG
   {
      // draw a rectangle on top so we know something is drawn...
      CGContextBeginPath( self);
      {
         rect = CGRectInset( rect, 20, 20);
         CGContextRect( self, rect);
         CGContextStrokeWidth( self, 3);
         CGContextStrokeColor( self, CGColorMakeWithHexColor( 0x8020A0FF));
      }
      CGContextStroke( self);
   }
#endif
}


- (void) drawAtPoint:(CGPoint) position
      textUTF8String:(char *) s
  fontNameUTF8String:(char *) fontNameUTF8String
            fontSize:(CGFloat) fontSize
            hexColor:(NSUInteger) color
{
   CGContextFontFace( self, fontNameUTF8String);
   CGContextFontSize( self, fontSize != 0.0 ? fontSize : 10.0);
   CGContextCombinedTextAlignment( self, CGTextAlignLeft | CGTextAlignTop);
   CGContextFillColor( self, CGColorMakeWithHexColor( color));

   CGContextTextBox( self, position, INFINITY, s, (size_t) -1);
}


//
// TODO: move this to UIControl where its used
//
- (void) drawIcon:(mulle_utf32_t) icon
          atPoint:(CGPoint) point
{
   char   icon_utf8[ 8];
   char   *end;

   CGContextCombinedTextAlignment( self, CGTextAlignCenter | CGTextAlignMiddle);
   end = (char *) mulle_utf32_as_utf8( icon, icon_utf8);
   CGContextText( self, point, icon_utf8, end - icon_utf8);
}


- (void) fillCircle:(CACircle) circle
           hexColor:(NSUInteger) color
{
   CGContextBeginPath( self);
   {
      CGContextCircle( self, circle);
      CGContextFillColor( self, CGColorMakeWithHexColor( color));
   }
   CGContextFill( self);
}


- (void) strokeCircle:(CACircle) circle
          strokeWidth:(CGFloat) strokeWidth
             hexColor:(NSUInteger) color
{
   if( strokeWidth <= 0.0f)
      return;

   CGContextBeginPath( self);
   {
      CGContextCircle( self, circle);
      CGContextStrokeWidth( self, strokeWidth);
      CGContextStrokeColor( self, CGColorMakeWithHexColor( color));
   }
   CGContextStroke( self);
}


- (void) fillPoint:(CGPoint) point
         pointSize:(CGFloat) size
          hexColor:(NSUInteger) color
{
   if( size <= 0.0f)
      return;

   CGContextBeginPath( self);
   {
      CGContextRect( self, CGRectMake( point.x - size / 2.0, point.y - size / 2.0, size, size));
      CGContextFillColor( self, CGColorMakeWithHexColor( color));
   }
   CGContextFill( self);
}


- (void) strokeLineFromPoint:(CGPoint) from
                     toPoint:(CGPoint) to
                 strokeWidth:(CGFloat) strokeWidth
                    hexColor:(NSUInteger) color
{
   if( strokeWidth <= 0.0f)
      return;

   CGContextBeginPath( self);
   {
      CGContextMoveTo( self, from);
      CGContextLineTo( self, to);
      CGContextStrokeWidth( self, strokeWidth);
      CGContextStrokeColor( self, CGColorMakeWithHexColor( color));
   }
   CGContextStroke( self);
}



- (void) fillPath:(CGPath *) path
         hexColor:(NSUInteger) color
{
   CGContextBeginPath( self);
   {
      CGContextAddCGPath( self, path);
      CGContextFillColor( self, CGColorMakeWithHexColor( color));
   }
   CGContextFill( self);
}


- (void) strokePath:(CGPath *) path
        strokeWidth:(CGFloat) strokeWidth
           hexColor:(NSUInteger) color
{
   if( strokeWidth <= 0.0f)
      return;

   CGContextBeginPath( self);
   {
      CGContextAddCGPath( self, path);
      CGContextStrokeWidth( self, strokeWidth);
      CGContextStrokeColor( self, CGColorMakeWithHexColor( color));
   }
   CGContextStroke( self);
}

@end

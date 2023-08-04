//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#import "CGContext+Drawing.h"

#import "import-private.h"

#import "CGDrawable.h"
#import "CGImage.h"
#include "CGPath+nanovg.h"


@implementation CGContext ( Drawing)

- (void) setCompositionMode:(UIGraphicsCompositionMode) mode
{
   assert( UIGraphicsSourceOver == NVG_SOURCE_OVER);
   assert( UIGraphicsXor        == NVG_XOR);
   assert( UIGraphicsCopy       == NVG_COPY);

   nvgGlobalCompositeOperation( _vg, mode);
}


- (void) fillRect:(CGRect) rect
         hexColor:(NSUInteger) color
{
   nvgBeginPath( _vg);
   {
      nvgRect( _vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
      nvgFillColor( _vg, CGColorMakeWithHexColor( color));
   }
   nvgFill( _vg);
}


- (void) strokeRect:(CGRect) rect
              width:(CGFloat) width
           hexColor:(NSUInteger) color
{
   nvgBeginPath( _vg);
   {
      nvgRect( _vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
      nvgStrokeWidth( _vg, width);
      nvgStrokeColor( _vg, CGColorMakeWithHexColor( color));
   }
   nvgStroke( _vg);
}


- (void) drawRect:(CGRect) rect
            image:(id) image
            scale:(BOOL) scale
{
   CGDrawableOptions   *options;

   options = scale ? &CGDrawableOptionsScaleToFit :
                     &CGDrawableOptionsDefault;
   [image drawRect:rect
           options:options
           context:self];
}


- (void) drawBitmap:(struct CGBitmap) fb
{
   CGImage                  *image;
   CGDrawableOptions        options;
   CGRect                   rect;
   struct CGBitmapInfo      convertedBitmapInfo;
   struct CGBitmap          convertedFb;

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
                                       context:self] autorelease];
      CGBitmapDone( convertedFb);
   }
   else
      image = [[[CGImage alloc] initWithBitmap:fb
                                  textureFlags:0
                                       context:self] autorelease];

   rect    = CGRectMakeWithIntegerSize( fb.info.size);
   options = CGDrawableOptionsMakeScaleToFit();
   [image drawRect:rect
           options:&options
           context:self];

   // just for debugging, draws a frame somewhere
#ifdef DEBUG
   {
      struct NVGcontext   *vg;

      vg = CGContextGetNVGContext( self);

      // draw a rectangle on top so we know something is drawn...
      nvgBeginPath( vg);
      {
         rect = CGRectInset( rect, 20, 20);
         nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
         nvgStrokeWidth( vg, 3);
         nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x8020A0FF));
      }
      nvgStroke( vg);
   }
#endif
}


- (void) drawAtPoint:(CGPoint) position
      textUTF8String:(char *) s
  fontNameUTF8String:(char *) fontNameUTF8String
            fontSize:(CGFloat) fontSize
            hexColor:(NSUInteger) color
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( self);

   nvgFontFace( vg, fontNameUTF8String ? fontNameUTF8String : "sans");
   nvgFontSize( vg, fontSize != 0.0 ? fontSize : 10.0);
   nvgTextAlign( vg, NVG_ALIGN_LEFT | NVG_ALIGN_TOP);
   nvgFillColor( vg, CGColorMakeWithHexColor( color));

   nvgTextBox( vg, position.x, position.y, INFINITY, s, NULL);
}


//
// TODO: move this to UIControl where its used
//
- (void) drawIcon:(mulle_utf32_t) icon
          atPoint:(CGPoint) point
{
   NVGcontext   *vg;
   char         icon_utf8[ 8];
   char         *end;

   vg = CGContextGetNVGContext( self);

   nvgTextAlign( vg, NVG_ALIGN_CENTER | NVG_ALIGN_MIDDLE);
   end = (char *) mulle_utf32_as_utf8( icon, (mulle_utf8_t *) icon_utf8);
   mvgText( vg, point, icon_utf8, end);
}


- (void) fillCircleAtPoint:(CGPoint) point
                    radius:(CGFloat) radius
                  hexColor:(NSUInteger) color
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( self);

   nvgBeginPath( vg);
   {
      nvgCircle( vg, point.x, point.y, radius);
      nvgFillColor( vg, CGColorMakeWithHexColor( color));
   }
   nvgFill( vg);
}


- (void) strokeCircleAtPoint:(CGPoint) point
                      radius:(CGFloat) radius
                       width:(CGFloat) width
                    hexColor:(NSUInteger) color
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( self);

   nvgBeginPath( vg);
   {
      nvgCircle( vg, point.x, point.y, radius);
      nvgStrokeWidth( vg, width);
      nvgStrokeColor( vg, CGColorMakeWithHexColor( color));
   }
   nvgStroke( vg);
}


- (void) fillPoint:(CGPoint) point 
             width:(CGFloat) width
          hexColor:(NSUInteger) color
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( self);

   nvgBeginPath( vg);
   {
      nvgRect( vg, point.x - width / 2.0, point.y - width / 2.0, width, width);
      nvgFillColor( vg, CGColorMakeWithHexColor( color));
   }
   nvgFill( vg);
}


- (void) strokeLineFromPoint:(CGPoint) from 
                     toPoint:(CGPoint) to
                       width:(CGFloat) strokeWidth
                    hexColor:(NSUInteger) color
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( self);

   nvgBeginPath( vg);
   {
      nvgMoveTo( vg, from.x, from.y);
      nvgLineTo( vg, to.x, to.y);
      nvgStrokeWidth( vg, strokeWidth);
      nvgStrokeColor( vg, CGColorMakeWithHexColor( color));
   }
   nvgStroke( vg);
}



- (void) fillPath:(CGPath *) path 
         hexColor:(NSUInteger) color
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( self);

   nvgBeginPath( vg);
   {
      mvgAddCGPath( vg, path);
      nvgFillColor( vg, CGColorMakeWithHexColor( color));
   }
   nvgFill( vg);
}


- (void) strokePath:(CGPath *) path 
              width:(CGFloat) strokeWidth
           hexColor:(NSUInteger) color
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( self);

   nvgBeginPath( vg);
   {
      mvgAddCGPath( vg, path);
      nvgStrokeWidth( vg, strokeWidth);
      nvgStrokeColor( vg, CGColorMakeWithHexColor( color));
   }
   nvgStroke( vg);
}

@end

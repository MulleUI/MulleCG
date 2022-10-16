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
            color:(CGColor) color
{
   nvgBeginPath( _vg);
   {
      nvgRect( _vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
      nvgFillColor( _vg, color);
   }
   nvgFill( _vg);
}


- (void) strokeRect:(CGRect) rect
              color:(CGColor) color
              width:(CGFloat) width
{
   nvgBeginPath( _vg);
   {
      nvgRect( _vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
      nvgStrokeWidth( _vg, width);
      nvgStrokeColor( _vg, color);
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
   void                     *bytes;
   struct CGBitmap          convertedFb;
   struct CGBitmapInfo      info;

   if( CGBitmapIsNull( fb))
      return;

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
                                    imageFlags:0
                                       context:self] autorelease];
      CGBitmapDone( convertedFb);
   }
   else
      image = [[[CGImage alloc] initWithBitmap:fb
                                    imageFlags:0
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
               color:(CGColor) color
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( self);

   nvgFontFace( vg, fontNameUTF8String ? fontNameUTF8String : "sans");
   nvgFontSize( vg, fontSize != 0.0 ? fontSize : 10.0);
   nvgTextAlign( vg, NVG_ALIGN_LEFT | NVG_ALIGN_TOP);
   nvgFillColor( vg, color);

   nvgTextBox( vg, position.x, position.y, INFINITY, s, NULL);
}


- (void) fillCircleAtPoint:(CGPoint) point
                    radius:(CGFloat) radius
                     color:(CGColor) color
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( self);

   nvgBeginPath( vg);
   {
      nvgCircle( vg, point.x, point.y, radius);
      nvgFillColor( vg, color);
   }
   nvgFill( vg);
}



- (void) strokeCircleAtPoint:(CGPoint) point
                      radius:(CGFloat) radius
                       width:(CGFloat) width
                       color:(CGColor) color
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( self);

   nvgBeginPath( vg);
   {
      nvgCircle( vg, point.x, point.y, radius);
      nvgStrokeWidth( vg, width);
      nvgStrokeColor( vg, color);
   }
   nvgStroke( vg);
}



- (void) fillPoint:(CGPoint) point 
             width:(CGFloat) width
             color:(CGColor) color
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( self);

   nvgBeginPath( vg);
   {
      nvgRect( vg, point.x - width / 2.0, point.y - width / 2.0, width, width);
      nvgFillColor( vg, color);
   }
   nvgFill( vg);
}


- (void) strokeLineFromPoint:(CGPoint) from 
                   toPoint:(CGPoint) to
                     width:(CGFloat) strokeWidth
                     color:(CGColor) color
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( self);

   nvgBeginPath( vg);
   {
      nvgMoveTo( vg, from.x, from.y);
      nvgLineTo( vg, to.x, to.y);
      nvgStrokeWidth( vg, strokeWidth);
      nvgStrokeColor( vg, color);
   }
   nvgStroke( vg);
}



- (void) fillPath:(CGPath *) path 
            color:(CGColor) color
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( self);

   nvgBeginPath( vg);
   {
      nvgAddCGPath( vg, path);
      nvgFillColor( vg, color);
   }
   nvgFill( vg);
}


- (void) strokePath:(CGPath *) path 
              width:(CGFloat) strokeWidth
              color:(CGColor) color
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( self);

   nvgBeginPath( vg);
   {
      nvgAddCGPath( vg, path);
      nvgStrokeWidth( vg, strokeWidth);
      nvgStrokeColor( vg, color);
   }
   nvgStroke( vg);
}

@end

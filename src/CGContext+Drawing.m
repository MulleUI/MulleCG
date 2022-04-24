//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#import "CGContext+Drawing.h"

#import "import-private.h"

#import "CGDrawable.h"
#import "CGImage.h"



@implementation CGContext ( Drawing)

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
   CGDrawableOptions   options;

   options = CGDrawableOptionsMake( 0.0, 1.0, 0.0, scale);
   [image drawRect:rect
           options:&options
           context:self];
}


- (void) drawBitmap:(struct CGBitmap *) fb
{
   CGImage                  *image;
   CGDrawableOptions        options;
   CGRect                   rect;
   enum CGBitmapEncoding    targetEncoding;
   void                     *bytes;
   struct CGBitmapInfo      info;

   if( ! fb->bytes)
      return;

   targetEncoding = CGBitmapEncodingRGBABytes;
   switch( CGBitmapInfoGetEncoding( fb->info))
   {
   case CGBitmapEncodingFlipYRGBABytes :
   case CGBitmapEncodingRGBABytes      :
      image = [[[CGImage alloc] initWithBytes:fb->bytes
                                   bitmapInfo:fb->info
                                   imageFlags:0
                                      context:self] autorelease];
      break;

   default:
      bytes = CGBitmapConvertBytesToEncoding( fb->bytes, fb->info, targetEncoding, NULL);
      if( ! bytes)
         abort();
      info  = CGBitmapInfoMake( fb->info.size, 0, targetEncoding);
      image = [[[CGImage alloc] initWithBytes:fb->bytes
                                   bitmapInfo:fb->info
                                   imageFlags:0
                                      context:self] autorelease];
      mulle_free( bytes);
   }

   rect    = CGRectMake( 0, 0, fb->info.size.width, fb->info.size.height);
   options = CGDrawableOptionsMake( 0.0, 1.0, 0.0, YES);
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
          UTF8String:(char *) s
            fontName:(char *) fontName
            fontSize:(CGFloat) fontSize
               color:(CGColor) color
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( self);

   nvgFontFace( vg, fontName ? fontName : "sans");
   nvgFontSize( vg, fontSize != 0.0 ? fontSize : 10.0);
   nvgTextAlign( vg, NVG_ALIGN_LEFT | NVG_ALIGN_TOP);
   nvgFillColor( vg, color);

   nvgTextBox( vg, position.x, position.y, INFINITY, s, NULL);
}



@end

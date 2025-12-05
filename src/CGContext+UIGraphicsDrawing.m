//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGContext+UIGraphicsDrawing.h"

#import "import-private.h"

#import "CGContext+Drawing.h"
#import "CGContext+CGImage.h"
#import "CGContext+OpenGL.h"
#import "CGContext+nanovg.h"
#import "CGImage.h"


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
   CGDrawableOptions             *options;
   struct CGContextFramebuffer   dst;

   if( [image isMultiSample])
   {
      //  a hack for UIWindow+Thread refresh code
      dst = CGContextCurrentOpenGLFramebuffer( self);
      _CGContextBlitFramebufferImage( self, dst, rect, image, NO);
      CGContextSetCurrentOpenGLFramebuffer( self, dst);
      return;
   }

   // this code will be used if MSAA is not available, as
   // _CGContextBlitFramebufferImage will be just an empty shell
   //

   CGContextSave( self);
   {
      CGContextGlobalCompositeOperation( self, NVG_COPY);

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
//   nvgFontFace( vg, fontNameUTF8String ? fontNameUTF8String : "sans");
   CGContextFontSize( self, fontSize != 0.0 ? fontSize : 10.0);
   CGContextCombinedTextAlignment( self, NVG_ALIGN_LEFT | NVG_ALIGN_TOP);
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

   CGContextCombinedTextAlignment( self, NVG_ALIGN_CENTER | NVG_ALIGN_MIDDLE);
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


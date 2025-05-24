//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGContext+CGDrawable.h"

#import "import-private.h"

#import "CGDrawable.h"
#import "CGImage.h"


static NSInteger   CGBitmapDrawableGetImageID( id <CGBitmapDrawable> self, 
                                               CGDrawableOptions *options,
                                               CGContext *context)
{
   NSInteger    textureFlags;
   NSInteger    textureID;
   CGImage      *image;

   // if we are a CGImage we can't really change, but a UIBitmapImage can
   textureFlags = [self textureFlags];
   if( options->flags.repeat != CGRepeatAsIs)
   {
      textureFlags &= ~(NVG_IMAGE_REPEATX|NVG_IMAGE_REPEATY);
      if( options->flags.repeat & CGRepeatHorizontally)
         textureFlags |= NVG_IMAGE_REPEATX;
      if( options->flags.repeat & CGRepeatVertically)
         textureFlags |= NVG_IMAGE_REPEATY;
   }

   image = [self cgImageWithContext:context
                       textureFlags:textureFlags];

   if( ! image)
   {
      assert( ! self);
      return( -1);
   }

   textureID = [image textureID];

   assert( textureID != -1);
   return( textureID);
}


void  CGContextDrawBitmapDrawableInRect( CGContext *context, 
                                         id <CGBitmapDrawable> drawable,
                                         CGRect rect,
                                         CGRect patternRect,
                                         CGDrawableOptions *options)
{
   NVGpaint     nvgPaint;
   NVGcontext   *vg;
   NSInteger    textureID;

   if( options->flags.flip & CGFlipHorizontally)
   {
      patternRect.origin.x    += rect.size.width;
      rect.origin.x           += rect.size.width;
      rect.size.width         *= -1.0;
      patternRect.size.width  *= -1.0;
   }

   if( options->flags.flip & CGFlipVertically)
   {
      patternRect.origin.y    += rect.size.height;
      rect.origin.y           += rect.size.height;
      rect.size.height        *= -1.0;
      patternRect.size.height *= -1.0;
   }

   textureID = CGBitmapDrawableGetImageID( drawable, options, context);
   if( textureID == -1)
   {
#ifdef DEBUG
      abort();      
#endif      
      return;  
   }

   // what this does is:
   //
   // origin is subtracted from rect.origin.x to get an initial value
   // extent divides the resultant value, if we get a value between 0.0 and 1.0
   // it's a valid texture.
   //
   vg        = CGContextGetNVGContext( context);
   nvgPaint  = mvgImagePattern( vg, patternRect,
                                    options->rotation,
                                    textureID,
                                    options->alpha);

   mvgBeginPath( vg);
   mvgRoundedRectVarying( vg, rect, options->cornerInsets);
   mvgFillPaint( vg, nvgPaint);
   mvgFill( vg);
}

//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGImage.h"

#import "import-private.h"

#import "CGContext+Drawing.h"
#import "CGPaint+Drawing.h"
// we want "import.h" always anyway
#import "CGDrawable.h"



#ifndef NDEBUG
static void   assertImageInNVGcontext( CGImage *self, NVGcontext *vg)
{
   CGContext   *otherContext;
   NVGcontext  *otherVG;

   if( ! self)
      return;

   otherContext = [self context];
   // circumvent otherContext assert with underscpre function, because we want
   // our more descriptive text
   otherVG      = _CGContextGetNVGContext( otherContext);
   assert( vg == otherVG && "paint image should belong to same context");
}


#else
# define assertImageInNVGcontext( self, vg)
#endif


@implementation CGImage( nanovg)

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                   paintOptions:(struct CGPaintOptions *) options
                        context:(CGContext *) context
{   
   NVGpaint       nvgPaint;
   CGTextureID    textureID;
   CGImage        *image;
   NVGcontext     *vg;

   assertImageInNVGcontext( self, CGContextGetNVGContext( context));

   image     = [self resolvedImage];
   textureID = [image textureID];

   if( ! context || textureID == CGTextureIDInvalid)
      return( (NVGpaint){ 0});

   vg       = CGContextGetNVGContext( context);
   nvgPaint = mvgImagePattern( vg, textureID,
                                   rect,
                                   options->rotation + [image rotation],
                                   options->alpha * [image alpha]);
   return( nvgPaint);
}

// inherit the rest from CGPaint

@end



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
   nvgPaint  = mvgImagePattern( vg, textureID,
                                    patternRect,
                                    options->rotation,
                                    options->alpha);

   mvgBeginPath( vg);
   mvgRoundedRectVarying( vg, rect, options->cornerInsets);
   mvgFillPaint( vg, nvgPaint);
   mvgFill( vg);
}



void   CGContextFillImageOptions( CGContext *context,
                                      CGImage *image,
                                      CGRect rect,
                                      CGFillOptions *options)
{
   NVGpaint     paint;
   NVGcontext   *vg;
   CARotation   rotation;
   CGFloat      alpha;

   assertImageInNVGcontext( image, CGContextGetNVGContext( context));

   vg       = CGContextGetNVGContext( context);
   alpha    = [image alpha] * options->paint.alpha;
   rotation = [image rotation] + options->paint.rotation;

   if( alpha <= 0.0f)
   {
      mvgFillColor( vg, CGColorMakeTransparent());
      return;
   }

   if( CGRectIsNull( rect))
      rect = CGRectMakeWithSize( [image size]);

   rect  = CGRectMakeFillRect( rect, options->strokeWidth, options->relation);
   paint = mvgImagePattern( vg, [image textureID],
                                rect,
                                rotation,
                                alpha);
   mvgFillPaint( vg, paint);
}



void   CGContextStrokeImageOptions( CGContext *context,
                                        CGImage *image,
                                        CGRect rect,
                                        CGFloat strokeWidth,
                                        CGStrokeOptions *options)
{
   NVGpaint     paint;
   NVGcontext   *vg;
   CARotation   rotation;
   CGFloat      alpha;

   assertImageInNVGcontext( image, CGContextGetNVGContext( context));

   vg    = CGContextGetNVGContext( context);
   alpha    = [image alpha] * options->paint.alpha;
   rotation = [image rotation] + options->paint.rotation;

   if( alpha <= 0.0f)
   {
      mvgStrokeColor( vg, CGColorMakeTransparent());
      return;
   }

   if( CGRectIsNull( rect))
      rect = CGRectMakeWithSize( [image size]);

   rect  = CGRectMakeStrokeRect( rect, strokeWidth, options->relation);
   paint = mvgImagePattern( vg, [image textureID],
                                rect,
                                rotation,
                                alpha);
   mvgStrokePaint( vg, paint);
}


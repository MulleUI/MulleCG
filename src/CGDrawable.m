#import "CGDrawable.h"

#import "CGContext.h"


PROTOCOLCLASS_IMPLEMENTATION( CGDrawable)

- (CGRect) canvas
{
   return( (CGRect){ .origin = CGPointZero, .size = [self size]});
}


- (CGRect) bounds
{
   return( [self canvas]);
}

PROTOCOLCLASS_END()



PROTOCOLCLASS_IMPLEMENTATION( CGBitmapDrawable)

- (struct CGBitmapSize) bitmapSize
{
   return( [self bitmapInfo].size);
}


- (CGSize) size
{
   struct CGBitmapSize   size;

   size = [self bitmapSize];

   return( CGSizeMake( size.width, size.height));
}


- (NSInteger) imageFlags
{
   return( 0);
}


// if you want to do more, do your own layer

static CGDrawableOptions  defaultOptions =
{
   0.0f, 1.0f, 0.0f, NO   // corner, alpha, rotation, scale
};


- (void) drawRect:(CGRect) rect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context
{
   int          textureID;
   NVGcontext   *vg;
   NVGpaint     imgPaint;
   CGSize       size;
   CGRect       patternRect;
   NSInteger    imageFlags;

   imageFlags = [self imageFlags];
   textureID  = [self textureIDWithContext:context
                                imageFlags:imageFlags];
   assert( textureID != -1);
   if( textureID == -1)
      return;

   if( ! options)
      options = &defaultOptions;

   vg = CGContextGetNVGContext( context);

   size        = [self size];
   patternRect = rect;
   if( ! options->scale || (imageFlags & NVG_IMAGE_REPEATX))
      patternRect.size.width = size.width;
   if( ! options->scale || (imageFlags & NVG_IMAGE_REPEATY))
      patternRect.size.height = size.height;

   // rotation some time in the future
   imgPaint  = nvgImagePattern( vg, patternRect.origin.x,
                                    patternRect.origin.y,
                                    patternRect.size.width,
                                    patternRect.size.height,
                                    options->rotation,
                                    textureID,
                                    options->alpha);

   nvgBeginPath( vg);
   nvgRoundedRect( vg, rect.origin.x,
                       rect.origin.y,
                       rect.size.width,
                       rect.size.height,
                       options->cornerRadius);
   nvgFillPaint( vg, imgPaint);
   nvgFill( vg);
}


- (void *) bytes
{
   return( NULL);
}

PROTOCOLCLASS_END()

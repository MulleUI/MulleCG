#import "CGImage.h"

#import "CGContext.h"


PROTOCOLCLASS_IMPLEMENTATION( CGImage)

- (NSUInteger) nvgImageFlags
{
   return( 0);
}

- (CGRect) canvas
{
   return( (CGRect){ .origin = CGPointZero, .size = [self size]});
}


- (CGRect) bounds
{
   return( [self canvas]);
}

PROTOCOLCLASS_END()



PROTOCOLCLASS_IMPLEMENTATION( _CGBitmapImage)

- (struct MulleBitmapSize) bitmapSize
{
   return( [self bitmapInfo].size);
}


- (void) drawRect:(CGRect) rect
     cornerRadius:(CGFloat) cornerRadius
            alpha:(CGFloat) alpha
          context:(CGContext *) context
{
   int          textureID;
   NVGcontext   *vg;
   NVGpaint     imgPaint;

   textureID = [self textureIDWithContext:context];
   assert( textureID != -1);
   if( textureID == -1)
      return;

   vg = MulleContextGetNVGContext( context);

   nvgBeginPath( vg);
   imgPaint  = nvgImagePattern( vg, rect.origin.x,
                                    rect.origin.y,
                                    rect.size.width,
                                    rect.size.height,
                                    0.0f/180.0f*NVG_PI,
                                    textureID,
                                    alpha);

   nvgRoundedRect( vg, rect.origin.x,
                       rect.origin.y,
                       rect.size.width,
                       rect.size.height,
                       (int) cornerRadius);
   nvgFillPaint( vg, imgPaint);
   nvgFill( vg);
}

PROTOCOLCLASS_END()



PROTOCOLCLASS_IMPLEMENTATION( CGBitmapImage)

- (int) textureIDWithContext:(CGContext *) context
{
   return( context ? [context registerTextureIDForImage:self] : -1);
}

PROTOCOLCLASS_END()

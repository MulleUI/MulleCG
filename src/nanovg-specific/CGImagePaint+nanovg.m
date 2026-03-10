//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGImagePaint.h"

#import "import-private.h"

#import "CGContext.h"
#import "CGImage.h"
#import "CGTypes.h"
#import "nanovg.h"


@implementation CGImagePaint( nanovg)

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                   paintOptions:(struct CGPaintOptions *) options
                        context:(CGContext *) context

{
   CGImage       *image;
   CGTextureID   textureID;
   NVGcontext    *vg;
   NVGpaint      nvgPaint;

   assert( options);
   assert( options->alpha >= 0.0 && options->alpha <= 1.0);

   image     = [_image resolvedImage];
   textureID = [image textureID];

   if( ! context || textureID == CGTextureIDInvalid)
      return( (NVGpaint){ 0});

   vg       = CGContextGetNVGContext( context);
   nvgPaint = mvgImagePattern( vg, textureID,
                                   rect,
                                   options->rotation + _rotation,
                                   options->alpha * _alpha);

   return( nvgPaint);
}

@end


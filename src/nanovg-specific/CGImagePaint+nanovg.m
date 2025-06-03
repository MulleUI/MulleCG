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

   assert( options);
   assert( options->alpha >= 0.0 && options->alpha <= 1.0);

   image     = [_image resolvedImage];
   textureID = [image textureID];

   if( ! context || textureID == CGTextureIDInvalid)
      return( (NVGpaint){ 0});

   vg = CGContextGetNVGContext( context);
   return( nvgImagePattern( vg, rect.origin.x,
                                rect.origin.y,
                                rect.size.width,
                                rect.size.height,
                                CARotationToRadians( options->rotation + _rotation),
                                textureID,
                                options->alpha * _alpha));
}

@end


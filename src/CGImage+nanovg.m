//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGImage.h"

#import "import-private.h"

#import "CGContext+Drawing.h"


@implementation CGImage( nanovg)

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                          alpha:(CGFloat) alpha
                        context:(CGContext *) context
{   
   CGTextureID    textureID;
   CGImage        *image;
   NVGcontext     *vg;

   image     = [self resolvedImage];
   textureID = [image textureID];

   if( ! context || textureID == CGTextureIDInvalid)
      return( (NVGpaint){ 0});

   vg = CGContextGetNVGContext( context);
   return( nvgImagePattern( vg, rect.origin.x,
                                rect.origin.y,
                                rect.size.width,
                                rect.size.height,
                                0.0,  // rotation
                                textureID,
                                alpha));
}

// inherit the rest from CGPaint

@end



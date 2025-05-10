//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGImage+nanovg.h"

#import "import-private.h"



@implementation CGImage( nanovg)

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                          alpha:(CGFloat) alpha
                     NVGcontext:(NVGcontext *) vg
{
   CGImage   *image;

   image = [self resolvedImage];
   // if you want -rotation or -alpha here, use CGImagePaint
   return( mvgImagePattern( vg, rect, 0.0f, [image textureID], alpha));
}

// inherit the rest from CGPaint

@end



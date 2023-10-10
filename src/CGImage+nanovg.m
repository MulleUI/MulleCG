//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGImage+nanovg.h"

#import "import-private.h"



@implementation CGImage( nanovg)

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                     NVGcontext:(NVGcontext *) vg
{
   CGImage   *image;

   image = [self resolvedImage];
   return( mvgImagePattern( vg, rect, [image rotation], [image textureID], 1.0));
}

// inherit the rest from CGPaint

@end



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

   image  = [self resolvedImage];
   alpha *= [image alpha];
   return( mvgImagePattern( vg, rect, [image rotation], [image textureID], alpha));
}

// inherit the rest from CGPaint

@end



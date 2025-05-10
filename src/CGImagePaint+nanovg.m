//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGImagePaint+nanovg.h"

#import "import-private.h"

#import "CGImage.h"
#import "microvg-nanowrap.h"


@implementation CGImagePaint( nanovg)

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                          alpha:(CGFloat) alpha
                     NVGcontext:(NVGcontext *) vg
{
   CGImage   *image;

   image = [_image resolvedImage];
   return( mvgImagePattern( vg,
                            rect,
                            _rotation,
                            [image textureID],
                            _alpha * alpha));
}

@end


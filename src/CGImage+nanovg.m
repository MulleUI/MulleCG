//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGImage+nanovg.h"

#import "import-private.h"



@implementation CGImage( nanovg)

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                     NVGcontext:(NVGcontext *) vg
{
   return( mvgImagePattern( vg, rect, [self rotation], [self textureID], 1.0));
}


- (void) strokeWithBounds:(CGRect) rect
                  context:(CGContext *) context
{
   NVGcontext   *vg;
   NVGpaint     paint;

   vg    = CGContextGetNVGContext( context);
   paint = [self NVGpaintWithBounds:rect
                         NVGcontext:vg];
   mvgStrokePaint( vg, paint);
   mvgStroke( vg);
}

@end



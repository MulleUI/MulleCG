//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGImagePaint+nanovg.h"

#import "import-private.h"

#import "CGImage.h"
#import "microvg.h"


@implementation CGImagePaint ( nanovg)

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                     NVGcontext:(NVGcontext *) vg
{
   CGFloat   blend;

   blend   = (_image == _otherImage) ? 0.0f : [self blend];
   return( mvgImagePattern( vg, rect, _rotation, [_image textureID], 1.0f - blend));
}



- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
               NVGcontext:(NVGcontext *) vg
{
   NVGpaint   paint;
   CGFloat    blend;

   if( strokeWidth <= 0.0f)
      return;

   blend = (_image == _otherImage) ? 0.0f : _blend;
   rect  = CGRectExtrude( rect, strokeWidth / 2.0f, strokeWidth / 2.0f);

   mvgStrokeWidth( vg, strokeWidth);

   if( blend != 1.0f)
   {
      paint = mvgImagePattern( vg, rect, _rotation, [_image textureID], 1.0f - blend);
      mvgStrokePaint( vg, paint);
      mvgStroke( vg);
   }

   if( blend != 0.0f)
   {
      paint = mvgImagePattern( vg, rect, _rotation, [_otherImage textureID], blend);
      mvgStrokePaint( vg, paint);
      mvgStroke( vg);
   }
}


- (void) fillWithBounds:(CGRect) rect
             NVGcontext:(NVGcontext *) vg
{
   NVGpaint   paint;
   CGFloat    blend;

   blend = (_image == _otherImage) ? 0.0f : _blend;
   if( blend != 1.0f)
   {
      paint = mvgImagePattern( vg, rect, _rotation, [_image textureID], 1.0f  - blend);
      mvgFillPaint( vg, paint);
      mvgFill( vg);
   }

   if( blend != 0.0f)
   {
      paint = mvgImagePattern( vg, rect, _rotation, [_otherImage textureID], blend);
      mvgFillPaint( vg, paint);
      mvgFill( vg);
   }
}

@end


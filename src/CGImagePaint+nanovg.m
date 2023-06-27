//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGImagePaint+nanovg.h"

#import "import-private.h"

#import "CGImage.h"
#import "millivg.h"


@implementation CGImagePaint ( nanovg)

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                     NVGcontext:(NVGcontext *) vg
{
   CGFloat          blend;

   blend = (_image == _otherImage) ? 0.0f : [self blend];
   return( mvgImagePattern( vg, rect, [self angle], [_image textureID], 1.0f - blend));
}



- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
               NVGcontext:(NVGcontext *) vg
{
   NVGpaint         paint;
   CAAngleRadians   angle;
   CGFloat          blend;

   angle = [self angle];
   blend = (_image == _otherImage) ? 0.0f : [self blend];
   rect  = CGRectExtrude( rect, strokeWidth / 2.0f, strokeWidth / 2.0f);

   mvgStrokeWidth( vg, strokeWidth);

   if( blend != 1.0f)
   {
      paint = mvgImagePattern( vg, rect, angle, [_image textureID], 1.0f - blend);
      mvgStrokePaint( vg, paint);
      mvgStroke( vg);
   }

   if( blend != 0.0f)
   {
      paint = mvgImagePattern( vg, rect, angle, [_otherImage textureID], blend);
      mvgStrokePaint( vg, paint);
      mvgStroke( vg);
   }
}


- (void) fillWithBounds:(CGRect) rect
             NVGcontext:(NVGcontext *) vg
{
   NVGpaint         paint;
   CAAngleRadians   angle;
   CGFloat          blend;

   angle = [self angle];
   blend = (_image == _otherImage) ? 0.0f : [self blend];

   if( blend != 1.0f)
   {
      paint = mvgImagePattern( vg, rect, angle, [_image textureID], 1.0f  - blend);
      mvgFillPaint( vg, paint);
      mvgFill( vg);
   }

   if( blend != 0.0f)
   {
      paint = mvgImagePattern( vg, rect, angle, [_otherImage textureID], blend);
      mvgFillPaint( vg, paint);
      mvgFill( vg);
   }
}

@end


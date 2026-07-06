//
// CGImage+PaintTransform.m
// MulleCG
//
// CGImage overrides for paint transform methods.
// Returns CGImagePaint instances with the appropriate effect parameters.
//
#import "CGImage.h"
#import "CGImagePaint.h"

#import "import-private.h"


@implementation CGImage( PaintTransform)

- (CGPaint *) rotatedPaint:(CARotation) rotation
{
   if( rotation == 0.0)
      return( self);

   return( [[[CGImagePaint alloc] initWithImage:self
                                      rotation:rotation
                                         alpha:1.0
                                    saturation:1.0
                                    brightness:0.0] autorelease]);
}


- (CGPaint *) transparentPaint:(CGFloat) alpha
{
   return( [[[CGImagePaint alloc] initWithImage:self
                                      rotation:0.0
                                         alpha:alpha
                                    saturation:1.0
                                    brightness:0.0] autorelease]);
}


- (CGPaint *) desaturatedPaint:(CGFloat) factor
{
   return( [[[CGImagePaint alloc] initWithImage:self
                                      rotation:0.0
                                         alpha:1.0
                                    saturation:1.0 - factor
                                    brightness:0.0] autorelease]);
}


- (CGPaint *) saturatedPaint:(CGFloat) factor
{
   return( [[[CGImagePaint alloc] initWithImage:self
                                      rotation:0.0
                                         alpha:1.0
                                    saturation:1.0 + factor
                                    brightness:0.0] autorelease]);
}


- (CGPaint *) brightenedPaint:(CGFloat) brighten
{
   return( [[[CGImagePaint alloc] initWithImage:self
                                      rotation:0.0
                                         alpha:1.0
                                    saturation:1.0
                                    brightness:brighten] autorelease]);
}


- (CGPaint *) dimmedPaint:(CGFloat) dim
{
   return( [[[CGImagePaint alloc] initWithImage:self
                                      rotation:0.0
                                         alpha:1.0
                                    saturation:1.0
                                    brightness:-dim] autorelease]);
}

@end

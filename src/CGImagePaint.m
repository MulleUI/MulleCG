//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGImagePaint.h"

#import "import-private.h"

#import "CGImage.h"


@implementation CGImagePaint

+ (instancetype) imagePaintWithImage:(CGImage *) image
                          otherImage:(CGImage *) otherImage
                               blend:(CGFloat) blend
                            rotation:(CGFloat) rotation
{
   return( [[[CGImagePaint alloc] initWithImage:image
                                     otherImage:otherImage
                                          blend:blend
                                       rotation:rotation] autorelease]);
}


- (instancetype) initWithImage:(CGImage *) image
                    otherImage:(CGImage *) otherImage
                         blend:(CGFloat) blend
                      rotation:(CGFloat) rotation
 {
   if( ! image && ! otherImage)
   {
      [self release];
      return( nil);
   }

   _image = [image copy];

   // for "rotation" only animation, this isn't unlikely
   if( ! otherImage || [otherImage textureID] == [_image textureID])
      _otherImage = [_image retain];
   else
      _otherImage = [otherImage copy];

   _blend    =  blend;
   _rotation = rotation;

   return( self);
}


- (void) dealloc
{
   [_image release];
   [_otherImage release];

   [super dealloc];
}


- (id) copy
{
   return( [self retain]);
}


- (CGPaint *) rotatedPaint:(CGFloat) rotation
{
   if( rotation == 0.0)
      return( self);

   return( [CGImagePaint imagePaintWithImage:_image
                                  otherImage:_otherImage
                                       blend:_blend
                                    rotation:rotation + _rotation]);
}

- (BOOL) isTexture
{
   return( YES);
}

@end

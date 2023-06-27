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
                               angle:(CAAngleRadians) angle
{
   return( [[[CGImagePaint alloc] initWithImage:image
                                     otherImage:otherImage
                                          blend:blend
                                          angle:angle] autorelease]);
}


- (instancetype) initWithImage:(CGImage *) image
                    otherImage:(CGImage *) otherImage
                         blend:(CGFloat) blend
                         angle:(CAAngleRadians) angle
 {
   _image = [image copy];

   // for "angle" only animation, this isn't unlikely
   if( ! otherImage || [otherImage textureID] == [_image textureID])
      _otherImage = [_image retain];
   else
      _otherImage = [otherImage copy];

   _blend = blend;
   _angle = angle;

   return( self);
}


- (void) dealloc
{
   [_image release];
   [_otherImage release];

   [super dealloc];
}

@end

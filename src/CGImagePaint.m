//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGImagePaint.h"

#import "import-private.h"


@implementation CGPaint( CGImagePaint)

+ (instancetype) paintWithImage:(CGImage *) image
                       rotation:(CARotation) rotation
                          alpha:(CGFloat) alpha
{
   id   paint;

   paint = [self alloc];
   paint = [paint initWithImage:image
                       rotation:rotation
                          alpha:alpha];
   paint = [paint autorelease];

   return( paint);
}

@end


@implementation CGImagePaint

- (instancetype) initWithImage:(CGImage *) image
                      rotation:(CARotation) rotation
                         alpha:(CGFloat) alpha
{
   if( ! image || alpha == 0.0)
   {
      [self release];
      return( nil);
   }

   _image    = [image retain];
   _rotation = rotation;
   _alpha    = alpha;

   return( self);
}


//
// CGPaint overrides
//
- (BOOL) isTexture
{
   return( YES);
}


- (CGImage *) image
{
   return( _image);
}

@end

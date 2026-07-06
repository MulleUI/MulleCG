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

   _image      = [image retain];
   _rotation   = rotation;
   _alpha      = alpha;
   _saturation = 1.0;
   _brightness = 0.0;

   return( self);
}


- (instancetype) initWithImage:(CGImage *) image
                      rotation:(CARotation) rotation
                         alpha:(CGFloat) alpha
                    saturation:(CGFloat) saturation
                    brightness:(CGFloat) brightness
{
   if( ! image || alpha == 0.0)
   {
      [self release];
      return( nil);
   }

   _image      = [image retain];
   _rotation   = rotation;
   _alpha      = alpha;
   _saturation = saturation;
   _brightness = brightness;

   return( self);
}


- (void) dealloc
{
   [_processedImage release];
   [_image release];
   [super dealloc];
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


- (CGPaint *) rotatedPaint:(CARotation) rotation
{
   if( rotation == 0.0)
      return( self);

   return( [[[CGImagePaint alloc] initWithImage:_image
                                      rotation:rotation + _rotation
                                         alpha:_alpha
                                    saturation:_saturation
                                    brightness:_brightness] autorelease]);
}


- (CGPaint *) transparentPaint:(CGFloat) alpha
{
   return( [[[CGImagePaint alloc] initWithImage:_image
                                      rotation:_rotation
                                         alpha:alpha
                                    saturation:_saturation
                                    brightness:_brightness] autorelease]);
}


- (CGPaint *) desaturatedPaint:(CGFloat) factor
{
   return( [[[CGImagePaint alloc] initWithImage:_image
                                      rotation:_rotation
                                         alpha:_alpha
                                    saturation:_saturation * (1.0 - factor)
                                    brightness:_brightness] autorelease]);
}


- (CGPaint *) saturatedPaint:(CGFloat) factor
{
   return( [[[CGImagePaint alloc] initWithImage:_image
                                      rotation:_rotation
                                         alpha:_alpha
                                    saturation:_saturation * (1.0 + factor)
                                    brightness:_brightness] autorelease]);
}


- (CGPaint *) brightenedPaint:(CGFloat) brighten
{
   return( [[[CGImagePaint alloc] initWithImage:_image
                                      rotation:_rotation
                                         alpha:_alpha
                                    saturation:_saturation
                                    brightness:_brightness + brighten] autorelease]);
}


- (CGPaint *) dimmedPaint:(CGFloat) dim
{
   return( [[[CGImagePaint alloc] initWithImage:_image
                                      rotation:_rotation
                                         alpha:_alpha
                                    saturation:_saturation
                                    brightness:_brightness - dim] autorelease]);
}

@end

//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGContext+CGImage.h"

#import "import-private.h"


#import "CGImage.h"



@implementation CGContext ( CGImage)

static CGImage  *getCachedImage( CGContext *self,
                                 NSUInteger textureFlags,
                                 MulleUIResourceStorageKey_t resourceKey)
{
   CGImage   *image;

   if( resourceKey)
   {
      image = [self resourceForKey:resourceKey];
      if( image)
      {
         assert( [image textureFlags] == textureFlags);
         return( image);
      }
   }
   return( nil);
}


static void   setCachedImage( CGContext *self,
                              CGImage *image,
                              MulleUIResourceStorageKey_t resourceKey)
{
   if( image)
      [self setResource:image
                 forKey:resourceKey];
}


- (CGImage *) imageWithRGBABytes:(void *) bytes
                      bitmapSize:(CGPixelSize) bitmapSize
                    textureFlags:(NSUInteger) textureFlags
                  nameUTF8String:(char *) nameUTF8String
                     resourceKey:(MulleUIResourceStorageKey_t) resourceKey
{
   CGImage   *image;

   image = getCachedImage( self, textureFlags, resourceKey);
   if( ! image)
   {
      image = [[[CGImage alloc] initWithRGBABytes:bytes
                                       bitmapSize:bitmapSize
                                     textureFlags:textureFlags
                                   nameUTF8String:nameUTF8String
                                          context:self] autorelease];
      setCachedImage( self, image, resourceKey);
   }
   return( image);
}



- (CGImage *) imageWithBitmap:(struct CGBitmap) bitmap
                 textureFlags:(NSUInteger) textureFlags
               nameUTF8String:(char *) nameUTF8String
                  resourceKey:(MulleUIResourceStorageKey_t) resourceKey
{
   CGImage   *image;

   image = getCachedImage( self, textureFlags, resourceKey);
   if( ! image)
   {
      image = [[[CGImage alloc] initWithBitmap:bitmap
                                  textureFlags:textureFlags
                                nameUTF8String:nameUTF8String
                                       context:self] autorelease];
      setCachedImage( self, image, resourceKey);
   }
   return( image);
}


- (CGImage *) imageWithContentsOfFileCString:(char *) filename
                                textureFlags:(NSUInteger) textureFlags
                              nameUTF8String:(char *) nameUTF8String
                                 resourceKey:(MulleUIResourceStorageKey_t) resourceKey
{
   CGImage   *image;

   image = getCachedImage( self, textureFlags, resourceKey);
   if( ! image)
   {
      image = [[[CGImage alloc] initWithContentsOfFileCString:filename
                                                 textureFlags:textureFlags
                                               nameUTF8String:nameUTF8String
                                                      context:self] autorelease];
      setCachedImage( self, image, resourceKey);
   }
   return( image);
}


// data can be discarded after init
- (CGImage *) imageWithFileCData:(struct mulle_data) fileCData
                    textureFlags:(NSUInteger) textureFlags
                  nameUTF8String:(char *) nameUTF8String
                     resourceKey:(MulleUIResourceStorageKey_t) resourceKey
{
   CGImage   *image;

   image = getCachedImage( self, textureFlags, resourceKey);
   if( ! image)
   {
      image = [[[CGImage alloc] initWithFileCData:fileCData
                                     textureFlags:textureFlags
                                   nameUTF8String:nameUTF8String
                                          context:self] autorelease];
      setCachedImage( self, image, resourceKey);
   }
   return( image);
}


@end

//
//  CGContext+CGImage.m
//  MulleCG
//
//  Copyright (c) 2023 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
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


- (CGImage *) imageWithContentsOfFileUTF8String:(char *) filename
                                textureFlags:(NSUInteger) textureFlags
                              nameUTF8String:(char *) nameUTF8String
                                 resourceKey:(MulleUIResourceStorageKey_t) resourceKey
{
   CGImage   *image;

   image = getCachedImage( self, textureFlags, resourceKey);
   if( ! image)
   {
      image = [[[CGImage alloc] initWithContentsOfFileUTF8String:filename
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

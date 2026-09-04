//
//  CGImage.m
//  MulleCG
//
//  Copyright (c) 2021 Nat! - Mulle kybernetiK.
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
#import "CGImage.h"

#import "import-private.h"

#import "CGTypes.h"
#import "CGContext.h"
#import "CGContext+Texture.h"
#import "CGContext+Render.h"
#import "CGContext+DebugPrivate.h"
#import "CGImage+DebugPrivate.h"
#import "CGFramebuffer.h"

#include <errno.h>


#define CGIMAGE_DEBUG

@implementation CGSharedGPUTexture : NSObject

- (instancetype) initWithGPUTexture:(CGGPUTextureID) gpuTexture
{
   _gpuTexture = gpuTexture;
   return( self);
}


#ifdef DEBUG
- (id) autorelease
{
   abort();
}
#endif


- (char *) nonLockingUTF8String
{
   char   *s;

   s = MulleObjC_asprintf( "<%s %p gpuTexture=%p rc=%td>",
                            MulleObjCInstanceGetClassNameUTF8String( self),
                            self,
                            self->_gpuTexture,
                            [self retainCount]);
   return( s);
}

@end


@implementation CGContext( CGImageGPUTexture)

- (CGImage *) imageWithGPUTexture:(CGGPUTextureID) gpuTexture
                       bitmapSize:(CGPixelSize) bitmapSize
                     textureFlags:(NSUInteger) textureFlags
                   nameUTF8String:(char *) nameUTF8String
{
   CGImage              *image;
   CGSharedGPUTexture   *sharedGPUTexture;

   if( ! gpuTexture)
      return( nil);

   image = mulle_map_get( &_gpuTextureMap, gpuTexture);
   if( image)
   {
      if( [image textureFlags] == textureFlags
           && CGPixelSizeEqualToPixelSize( [image bitmapSize], bitmapSize))
      {
         return( image);
      }

      sharedGPUTexture = [image sharedGPUTexture];
      if( ! sharedGPUTexture)
         return( nil);

      image = [[[CGImage alloc] initWithSharedGPUTexture:sharedGPUTexture
                                              bitmapSize:bitmapSize
                                            textureFlags:textureFlags
                                          nameUTF8String:nameUTF8String
                                                 context:self] autorelease];
      return( image);
   }

   image = [[[CGImage alloc] initWithGPUTexture:gpuTexture
                                     bitmapSize:bitmapSize
                                   textureFlags:textureFlags
                                 nameUTF8String:nameUTF8String
                                        context:self] autorelease];

   if( image)
   {
      CGContextLogVerbose( "remember %#@ for gpuTexture %p", image, gpuTexture);
      mulle_map_insert( &_gpuTextureMap, gpuTexture, image);
   }
   return( image);
}


- (CGImage *) imageWithSharedGPUTexture:(CGSharedGPUTexture *) sharedGPUTexture
                             bitmapSize:(CGPixelSize) size
                           textureFlags:(NSUInteger) textureFlags
                         nameUTF8String:(char *) nameUTF8String
{
   CGImage          *image;
   CGGPUTextureID   gpuTexture;

   if( ! sharedGPUTexture)
      return( nil);

   gpuTexture = [sharedGPUTexture gpuTexture];
   image      = mulle_map_get( &_gpuTextureMap, gpuTexture);
   if( image)
   {
      CGContextLogVerbose( "reuse %#@ for gpuTexture %p", image, gpuTexture);

      assert( ! sharedGPUTexture || [image sharedGPUTexture] == sharedGPUTexture);
      return( [image textureFlags] == textureFlags ? image : nil);
   }

   image = [[[CGImage alloc] initWithSharedGPUTexture:sharedGPUTexture
                                           bitmapSize:size
                                         textureFlags:textureFlags
                                       nameUTF8String:nameUTF8String
                                              context:self] autorelease];

   if( image)
   {
      CGContextLogVerbose( "remember %#@ for gpuTexture %p", image, gpuTexture);
      mulle_map_insert( &_gpuTextureMap, gpuTexture, image);
   }
   return( image);
}


- (void) removeFromSharedGPUTextureMap:(CGImage *) image
{
   CGGPUTextureID   gpuTexture;

   gpuTexture = [[image sharedGPUTexture] gpuTexture];
   CGContextLogVerbose( "forget %#@ for gpuTexture %p", image, gpuTexture);
   // if key is NULL its no problem
   mulle_map_remove( &_gpuTextureMap, gpuTexture);
}

@end


#pragma clang diagnostic ignored "-Wprotocol"


@implementation NSObject( CGImage)

- (BOOL) __isCGImage
{
   return( NO);
}

@end


@implementation CGImage

- (BOOL) __isCGImage
{
   return( YES);
}


static struct
{
   NSUInteger   _debuggingFlags;
} ClassStatic;


+ (void) initialize
{
   char   *s;

   // don't rerun for subclass
   if( MulleObjCClassGetID( self) != @selector( CGImage))
      return;

   s = getenv( MULLE_C_STRINGIFY( CGImage) "DebuggingFlags");
   if( ! s)
      s = getenv( "UIDebuggingFlags");
   if( s)
      ClassStatic._debuggingFlags = strtol( s, NULL, 0);
}


+ (void) deinitialize
{
}


+ (void) setDebuggingFlags:(NSUInteger) flag    MULLE_OBJC_THREADSAFE_METHOD
{
   ClassStatic._debuggingFlags = flag;
}


- (instancetype) initWithTextureID:(NSInteger) textureID
                        bitmapSize:(CGPixelSize) bitmapSize
                      textureFlags:(NSUInteger) textureFlags
                    nameUTF8String:(char *) nameUTF8String
                           context:(CGContext *) context
{
   CGGPUTextureID   gpuTexture;

   if( ! textureID || ! bitmapSize.width || ! bitmapSize.height)
   {
      [self release];
      return( nil);
   }

   _context        = context;
   _textureID      = textureID;
   _textureFlags   = textureFlags;
   _bitmapSize     = bitmapSize;
   _debuggingFlags = ClassStatic._debuggingFlags;

   MulleObjCObjectSetDuplicatedUTF8String( self, &_nameUTF8String, nameUTF8String);

   if( [_context shareID])
   {
      gpuTexture        = [_context gpuTextureForTextureID:textureID];
      _sharedGPUTexture = [[CGSharedGPUTexture alloc] initWithGPUTexture:gpuTexture];
   }

   CGImageLogVerbose( "");

   [_context assignResource:self
                     forKey:(MulleUIResourceStorageKey_t) self];


   return( self);
}


- (instancetype) initWithGPUTexture:(CGGPUTextureID) gpuTexture
                         bitmapSize:(CGPixelSize) bitmapSize
                       textureFlags:(NSUInteger) textureFlags
                     nameUTF8String:(char *) nameUTF8String
                            context:(CGContext *) context
{
   NSUInteger   textureID;

   if( ! gpuTexture || ! bitmapSize.width || ! bitmapSize.height)
   {
      [self release];
      return( nil);
   }

   textureID       = [context textureIDWithGPUTexture:gpuTexture
                                           bitmapSize:bitmapSize
                                         textureFlags:textureFlags];
   _context        = context;
   _textureID      = textureID;
   _textureFlags   = textureFlags;
   _bitmapSize     = bitmapSize;
   _debuggingFlags = ClassStatic._debuggingFlags;

   MulleObjCObjectSetDuplicatedUTF8String( self, &_nameUTF8String, nameUTF8String);

   if( [context shareID])
      _sharedGPUTexture = [[CGSharedGPUTexture alloc] initWithGPUTexture:gpuTexture];

   CGImageLogVerbose( "");

   [_context assignResource:self
                     forKey:(MulleUIResourceStorageKey_t) self];


   return( self);
}


- (instancetype) initWithSharedGPUTexture:(CGSharedGPUTexture *) sharedGPUTexture
                               bitmapSize:(CGPixelSize) bitmapSize
                             textureFlags:(NSUInteger) textureFlags
                           nameUTF8String:(char *) nameUTF8String
                                  context:(CGContext *) context
{
   CGGPUTextureID   gpuTexture;
   NSUInteger       textureID;

   if( ! sharedGPUTexture || ! bitmapSize.width || ! bitmapSize.height)
   {
      [self release];
      return( nil);
   }
   assert( [context shareID]);

   gpuTexture = [sharedGPUTexture gpuTexture];
   textureID  = [context textureIDWithGPUTexture:gpuTexture
                                      bitmapSize:bitmapSize
                                    textureFlags:textureFlags];
   _context          = context;
   _textureID        = textureID;
   _textureFlags     = textureFlags;
   _bitmapSize       = bitmapSize;
   _debuggingFlags   = ClassStatic._debuggingFlags;
   _sharedGPUTexture = [sharedGPUTexture retain];

   MulleObjCObjectSetDuplicatedUTF8String( self, &_nameUTF8String, nameUTF8String);

   CGImageLogVerbose( "");

   [_context assignResource:self];

   return( self);
}


// since we are moving framebuffers in and out of a context, this can be
// called more than once now.
- (void) didAddToContext:(CGContext *) context
{
   CGImageLogVerbose( "%#@", context);

   assert( _context);  // should already be set
   if( _context != context)
   {
      mulle_fprintf( stderr, "A %s can only belong to one context (%@) Once. "
                             "Use -sharedGPUTexture and create an image "
                             "with it in another context (%@).\n",
                             MulleObjCObjectGetClassNameUTF8String( self),
                             _context, context);
      abort();
   }

   // _context = context;
}


- (void) didRemoveFromContext:(CGContext *) context
{
   assert( context == _context);

   if( [_sharedGPUTexture retainCount] > 1)
   {
      //
      // nvg should forget the texture. So it wont get "really" deleted
      // as other context may still want to access it.
      // We only patch a struct and don't hit OpenGL here so no need to use
      // _CGContextGetNVGContext( _context);
      //
      [_context forgetTextureID:_textureID];
   }
   else
   {
      if( _textureID)
      {
         // the gpuTexture may have been nil-ed out by finalize
         // assert( [self state] & UIGraphicsContextActive);
         // the context NEED NOT be active! (check deleteTextureID: code)
         [_context deleteTextureID:_textureID];
         _textureID = 0;
      }
   }

   [_sharedGPUTexture release];  // sic!
   _sharedGPUTexture = nil;

   CGImageLogVerbose( "%#@", context);

   // once removed we can't do anything anymore
   _context = nil;
}


//
// when called to be finalized, we can't really be loaned to the CGContext
//
- (void) finalize
{
   CGImageLogVerbose( "finalizing");

   [_context removeFromSharedGPUTextureMap:self];

   // this will call didRemoveFromContext: eventually
   [_context removeResourceForKey:(MulleUIResourceStorageKey_t) self];

#ifdef DEBUG
   _context = (void *) 0xDEADFACE;
#endif

   [super finalize];
}


- (void) dealloc
{
   MulleObjCInstanceDeallocateMemory( self, _nameUTF8String);

   [super dealloc];
}


- (id) copy
{
   return( [self retain]);
}


- (id) mutableCopy
{
   CGFramebuffer   *framebuffer;

   framebuffer = [[self class] alloc];
   framebuffer = [framebuffer initWithImage:self
                               textureFlags:self->_textureFlags
                             nameUTF8String:NULL
                                    context:self->_context];
   framebuffer = [framebuffer autorelease];
   return( framebuffer);
}


- (CGImage *) cgImageWithContext:(CGContext *) context
                    textureFlags:(NSUInteger) textureFlags
{
   if( [context shareID] != [_context shareID])
   {
      CGImageLog( "ImageID requested for context %#@ "
                  "is in non-sharable context %#@",
                  context, _context);
      assert( 0);
      return( nil);
   }

   if( textureFlags != _textureFlags)
   {
      CGImageLog( "Non standard textureFlags 0x%tx (0x%x) requested. "
                        "Use UIBitmapImage instead (for now)", textureFlags, _textureFlags);
      // would need to construct a new CGImage, but CGImage is too low level
      // use UIBitmapImage instead
      assert( 0);
      return( nil);
   }

   return( self);
}

+ (instancetype) imageWithTextureID:(CGTextureID) textureID
                         bitmapSize:(CGPixelSize) bitmapSize
                       textureFlags:(NSUInteger) textureFlags
                            context:(CGContext *) context
{
    CGImage   *image;

    image = [self alloc];
    image = [image initWithTextureID:textureID
                         bitmapSize:bitmapSize
                       textureFlags:textureFlags
                     nameUTF8String:NULL
                            context:context];
    image = [image autorelease];
    return( image );
}


+ (instancetype) imageWithGPUTexture:(CGGPUTextureID) gpuTexture
                         bitmapSize:(CGPixelSize) size
                       textureFlags:(NSUInteger) textureFlags
                            context:(CGContext *) context
{
    CGImage   *image;

    image = [self alloc];
    image = [image initWithGPUTexture:gpuTexture
                           bitmapSize:size
                         textureFlags:textureFlags
                       nameUTF8String:NULL
                              context:context];
    image = [image autorelease];
    return( image );
}


+ (instancetype) imageWithSharedGPUTexture:(CGSharedGPUTexture *) sharedGPUTexture
                               bitmapSize:(CGPixelSize) size
                             textureFlags:(NSUInteger) textureFlags
                                  context:(CGContext *) context
{
    CGImage   *image;

    image = [self alloc];
    image = [image initWithSharedGPUTexture:sharedGPUTexture
                                 bitmapSize:size
                               textureFlags:textureFlags
                             nameUTF8String:NULL
                                    context:context];
    image = [image autorelease];
    return( image );
}


+ (instancetype) imageWithContentsOfFileUTF8String:(char *) filename
                                      textureFlags:(NSUInteger) textureFlags
                                           context:(CGContext *) context
{
    CGImage   *image;

    image = [self alloc];
    image = [image initWithContentsOfFileUTF8String:filename
                                    textureFlags:textureFlags
                                  nameUTF8String:NULL
                                         context:context];
    image = [image autorelease];
    return( image );
}


+ (instancetype) imageWithFileCData:(struct mulle_data) fileCData
                      textureFlags:(NSUInteger) textureFlags
                           context:(CGContext *) context
{
    CGImage   *image;

    image = [self alloc];
    image = [image initWithFileCData:fileCData
                        textureFlags:textureFlags
                      nameUTF8String:NULL
                             context:context];
    image = [image autorelease];
    return( image );
}


+ (instancetype) imageWithRGBABytes:(void *) bytes
                         bitmapSize:(CGPixelSize) bitmapSize
                       textureFlags:(NSUInteger) textureFlags
                            context:(CGContext *) context
{
    CGImage   *image;

    image = [self alloc];
    image = [image initWithRGBABytes:bytes
                          bitmapSize:bitmapSize
                        textureFlags:textureFlags
                      nameUTF8String:NULL
                             context:context];
    image = [image autorelease];
    return( image );
}


+ (instancetype) imageWithBitmap:(struct CGBitmap) bitmap
                   textureFlags:(NSUInteger) textureFlags
                        context:(CGContext *) context
{
    CGImage   *image;

    image = [self alloc];
    image = [image initWithBitmap:bitmap
                     textureFlags:textureFlags
                   nameUTF8String:NULL
                          context:context];
    image = [image autorelease];
    return( image );
}


- (instancetype) initWithContentsOfFileUTF8String:(char *) filename
                                     textureFlags:(NSUInteger) textureFlags
                                   nameUTF8String:(char *) nameUTF8String
                                          context:(CGContext *) context
{
   NSInteger     textureID;
   CGPixelSize   bitmapSize;

   assert( CGContextIsActiveInCurrentThread( context));

   textureID  = [context textureIDWithContentsOfFileUTF8String:filename
                                                  textureFlags:textureFlags & 0x3F];
   bitmapSize = [context bitmapSizeForTextureID:textureID];
   return( [self initWithTextureID:textureID
                        bitmapSize:bitmapSize
                      textureFlags:textureFlags
                    nameUTF8String:nameUTF8String
                           context:context]);
}


- (instancetype) initWithContentsOfFileUTF8String:(char *) filename
                                     textureFlags:(NSUInteger) textureFlags
                                          context:(CGContext *) context
{
   return( [self initWithContentsOfFileUTF8String:filename
                                     textureFlags:textureFlags
                                   nameUTF8String:NULL
                                          context:context]);
}


- (instancetype) initWithFileCData:(struct mulle_data) fileCData
                      textureFlags:(NSUInteger) textureFlags
                    nameUTF8String:(char *) nameUTF8String
                           context:(CGContext *) context
{
   NSInteger     textureID;
   CGPixelSize   bitmapSize;

   assert( CGContextIsActiveInCurrentThread( context));

   // bounce to CGContext kinda unnecessary now
   // this was used to generate debug output, but this now done in
   // addImageToResources.
   // Another theory is to isolate nvgCalls in CGContext, but really why ?
   // They are isolated in this library already
   textureID = [context textureIDWithFileCData:fileCData
                                  textureFlags:textureFlags & 0x3F];
   bitmapSize = [context bitmapSizeForTextureID:textureID];
   return( [self initWithTextureID:textureID
                        bitmapSize:bitmapSize
                      textureFlags:textureFlags
                    nameUTF8String:nameUTF8String
                           context:context]);
}


- (instancetype) initWithRGBABytes:(void *) bytes
                        bitmapSize:(CGPixelSize) bitmapSize
                      textureFlags:(NSUInteger) textureFlags
                    nameUTF8String:(char *) nameUTF8String
                           context:(CGContext *) context
{
   NSInteger   textureID;

   if( ! bytes)
   {
      [self release];
      return( nil);
   }

   assert( bitmapSize.width >= 1);
   assert( bitmapSize.height >= 1);

   assert( CGContextIsActiveInCurrentThread( context));

   // bounce to context for debugging output of CGContext
   textureID = [context textureIDWithRGBABytes:bytes
                                    bitmapSize:bitmapSize
                                  textureFlags:textureFlags & 0x3F];
   return( [self initWithTextureID:textureID
                        bitmapSize:bitmapSize
                      textureFlags:textureFlags
                    nameUTF8String:nameUTF8String
                           context:context]);
}


- (instancetype) initWithRGBABytes:(void *) bytes
                        bitmapSize:(CGPixelSize) bitmapSize
                      textureFlags:(NSUInteger) textureFlags
                           context:(CGContext *) context
{
   return( [self initWithRGBABytes:bytes
                        bitmapSize:bitmapSize
                      textureFlags:textureFlags
                    nameUTF8String:NULL
                           context:context]);
}


- (instancetype) initWithBitmap:(struct CGBitmap) bitmap
                   textureFlags:(NSUInteger) textureFlags
                 nameUTF8String:(char *) nameUTF8String
                        context:(CGContext *) context
{
   BOOL                  isFlipped;
   CGBitmapEncoding      convertedEncoding;
   CGBitmapEncoding      encoding;
   NSInteger             textureID;
   struct CGBitmap       convertedBitmap;
   struct CGBitmapInfo   convertedBitmapInfo;

   if( ! bitmap.bytes)
   {
      [self release];
      return( nil);
   }

   assert( CGContextIsActiveInCurrentThread( context));

   // we flip textureFlags on encoding, it allows more control for the
   // user, who will usually set this to 0

   encoding          = CGBitmapGetEncoding( bitmap);
   isFlipped         = CGBitmapEncodingIsFlipped( encoding);
   convertedEncoding = CGBitmapEncodingRGBABytes;
   if( isFlipped)
   {
      convertedEncoding = CGBitmapEncodingFlipYRGBABytes;
      textureFlags     ^= CGTextureFlipY;
   }

   convertedBitmapInfo = CGBitmapInfoMake( bitmap.info.size, 0, convertedEncoding);
   if( CGBitmapNeedsConversion( bitmap, convertedBitmapInfo))
   {
      convertedBitmap = CGBitmapConvert( bitmap, convertedBitmapInfo, NULL);
      if( CGBitmapIsNull( convertedBitmap))
      {
         mulle_fprintf( stderr, "unsupported CGImage format\n");
         [self release];
         return( nil);
      }
      textureID = [context textureIDWithRGBABytes:convertedBitmap.bytes
                                   bitmapSize:convertedBitmap.info.size
                                 textureFlags:textureFlags];
      CGBitmapDone( convertedBitmap);
   }  
   else
      textureID = [context textureIDWithRGBABytes:bitmap.bytes
                                   bitmapSize:bitmap.info.size
                                 textureFlags:textureFlags];

   return( [self initWithTextureID:textureID
                        bitmapSize:bitmap.info.size
                      textureFlags:textureFlags
                    nameUTF8String:nameUTF8String
                           context:context]);
}


- (instancetype) initWithBitmap:(struct CGBitmap) bitmap
                   textureFlags:(NSUInteger) textureFlags
                        context:(CGContext *) context
{
   return( [self initWithBitmap:bitmap
                   textureFlags:textureFlags
                 nameUTF8String:NULL
                        context:context]);
}


// MEMO: A texture id can be reused. So the referencing image textureID can
//       eventually deviate between contexts. The sharing of a textureID
//       happens through the binding.
//       Example, how textureIDs can be different
//
//           Context A  | Context B
//       ---------------|----------------
//        create ->1    |
//        copy 1        |  -> 1
//        delete 1      |  unaffected until next bind
//        create -> 1   |
//
// Changes in a shared texture are seen across all contexts. So if you change
// the background color, the background color will change everywhere. This
// is different from deletion and recreation, where changes remain local until
// the next bind. (Since nanovg or someone else can rebind as well, texture
// deletion is not really locally persistent)
//
// If a texture in OpenGL gets deleted and a new one is created, this texture
// ID will be reused. Unfortunately we will not be able to share this across
// contexts until the other contexts have also deleted their textures and
// haven't created a new texture.
//
// Now the CGImage NanoVG textureID is different and local to each context.
// NanoVG doesn't throw away the images on deletion. That's a user
// responsibility. Unfortunately the GL context will be gone, so its kinda
// expected to delete the images by hand before calling nvgDeleteGLES3 or some
// such.
//
// Scenario:
//            Context 1                  Context 2
//            NanoVG Context             NanoVG Context
//            CGImage                    CGImage
//                  \                     /
//            NanoVG textureID (1)     NanoVG textureID (2)
//                     \               /
//                     OpenGL textureID (3)
//
// We can only call glDeleteTextures, if all NanoVGs images are closed.
//
//
// We can not delete a NanoVG image, as it will delete the shared texture
// (OpenGL). So we have to postpone this until the last context relinquishes
// the image. Problem: a NanoVG context could just disappear while waiting...
// Will it delete its images ?
//
// [MEMO: it used to be that textureIDs were never reused (until wrappage)
//        I am not super-sure this is true anymore, because I changed the
//        allocation algorithm, and I am not sure anymore that this is 
//        an expected property]
//
// Question, can the size of a texture change behind our backs ?
//

- (struct CGBitmapInfo) bitmapInfo
{
   return( CGBitmapInfoMake( [self bitmapSize], 0, CGBitmapEncodingRGBABytes));
}



// this is a hack, until we properly turn multisample layers into standard
// cgimages for paints
- (BOOL) isMultiSample
{
   return( (_textureFlags & CGImageFlagMSAA) ? YES : NO);
}


- (instancetype) shareWithContext:(CGContext *) context
                     textureFlags:(NSUInteger) textureFlags
{
   Class     cls;
   CGImage   *image;

   cls   = MulleObjCObjectGetClass( self);
   image = [cls alloc];
   image = [image initWithSharedGPUTexture:[self sharedGPUTexture]
                                bitmapSize:[self bitmapSize]
                              textureFlags:textureFlags
                                      nameUTF8String:NULL
                                   context:context];
   image = [image autorelease];
   return( image);
}


- (char *) nonLockingUTF8String
{
   char   *s;

   mulle_buffer_do_autoreleased_string( buffer, NULL, s)
   {
      s = MulleObjCClassGetNameUTF8String( NSClassFromObject( self));
      mulle_buffer_sprintf( buffer, "<%s %p", s, self);
      if( _nameUTF8String)
         mulle_buffer_sprintf( buffer, " \"%s\"", self->_nameUTF8String);
      mulle_buffer_sprintf( buffer, " ID=%td", self->_textureID);
      if( self->_sharedGPUTexture)
         mulle_buffer_sprintf( buffer, " GPUID=%td", (intptr_t) [self->_sharedGPUTexture gpuTexture]);
      mulle_buffer_sprintf( buffer, " FLAGS=%s", CGTextureUTF8String( self->_textureFlags));
      mulle_buffer_add_string( buffer, ">");
   }
   return( s);
}


- (CGImage *) resolvedImage
{
   assert( ! [self isMultiSample]);

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
   return( self);
}

@end


@implementation CGImage( Future)

- (struct CGBitmap) RGBABytesBitmap:(struct mulle_allocator *) allocator
{
   if( [self isMultiSample])
      return( [[self resolvedImage] RGBABytesBitmap:allocator]);
   return( [[self context] RGBABytesBitmapOfImage:self
                                        allocator:allocator]);
}

@end

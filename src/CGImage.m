#import "CGImage.h"

#import "import-private.h"

#import "CGImage+DebugPrivate.h"
#import "CGContext+DebugPrivate.h"
#import "CGContext.h"
#import "CGContext+OpenGL.h"
#import "CGContext+Texture.h"

#include <errno.h>


#define CGIMAGE_DEBUG

@implementation CGSharedGPUTexture : NSObject

- (instancetype) initWithGPUTexture:(void *) gpuTexture
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


- (char *) UTF8String
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

- (CGImage *) imageWithGPUTextureRGBA:(void *) gpuTexture
                     sharedGPUTexture:(CGSharedGPUTexture *) sharedGPUTexture
                           bitmapSize:(struct MulleIntegerSize) size
                         textureFlags:(NSUInteger) textureFlags
{
   CGImage   *image;

   if( ! gpuTexture)
      return( nil);

   image = mulle_map_get( &_gpuTextureMap, gpuTexture);
   if( image)
   {
      CGContextLog( "reuse %#@ for gpuTexture %p", image, gpuTexture);

      assert( ! sharedGPUTexture || [image sharedGPUTexture] == sharedGPUTexture);
      return( [image textureFlags] == textureFlags ? image : nil);
   }

   image = [[[CGImage alloc] initWithGPUTextureRGBA:gpuTexture
                                   sharedGPUTexture:sharedGPUTexture
                                         bitmapSize:size
                                       textureFlags:textureFlags
                                            context:self] autorelease];
   CGContextLog( "remember %#@ for gpuTexture %p", image, gpuTexture);

   mulle_map_insert( &_gpuTextureMap, gpuTexture, image);
   return( image);
}


- (void) removeFromSharedGPUTextureMap:(CGImage *) image
{
   void   *gpuTexture;

   gpuTexture = [[image sharedGPUTexture] gpuTexture];
   CGContextLog( "forget %#@ for gpuTexture %p",
                  image,
                  [[image sharedGPUTexture] gpuTexture]);
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


- (instancetype) initWithTextureID:(NSInteger) textureID
                      textureFlags:(NSUInteger) textureFlags
                           context:(CGContext *) context
{
   if( ! textureID)
   {
      [self release];
      return( nil);
   }

   _context      = context;
   _textureID    = textureID;
   _textureFlags = textureFlags;

   [_context assignResource:self
                     forKey:(MulleUIResourceStorageKey_t) self];

   return( self);
}


- (instancetype) initWithGPUTextureRGBA:(void *) gpuTexture
                       sharedGPUTexture:(CGSharedGPUTexture *) sharedGPUTexture
                             bitmapSize:(struct MulleIntegerSize) size
                           textureFlags:(NSUInteger) textureFlags
                                context:(CGContext *) context
{
   NSUInteger   textureID;

   textureID = [context textureIDWithGPUTextureRGBA:gpuTexture
                                         bitmapSize:size
                                        textureFlags:textureFlags];

   self = [self initWithTextureID:textureID
                     textureFlags:textureFlags
                          context:context];
   if( self)
   {
      if( ! sharedGPUTexture)
         _sharedGPUTexture = [[CGSharedGPUTexture alloc] initWithGPUTexture:gpuTexture];
      else
         _sharedGPUTexture = [sharedGPUTexture retain];
   }
   return( self);
}


- (void) contextDidAddObject:(CGContext *) context
{
   if( _context != context)
   {
      fprintf( stderr, "CGImages should only belong to one context. Use -shareWithContext: to share an image with another context.");
      abort();
   }
}


- (void) contextDidRemoveObject:(CGContext *) context
{
   if( _textureID && context == _context)
   {
      // the gpuTexture may have been nil-ed out by finalize
      // assert( [context isActive]);
      // the context NEED NOT be active! (check deleteTextureID: code)
      [context deleteTextureID:_textureID];
      _textureID = 0;
   }
   _context = nil;
}


//
// when called to be finalized, we can't really be loaned to the CGContext
//
- (void) finalize
{
   [_context removeFromSharedGPUTextureMap:self];

   if( [_sharedGPUTexture retainCount] > 1)
   {
      //
      // nvg should forget the texture. So it wont get "really" deleted
      // as other context may still want to access it.
      // We only patch a struct and don't hit OpenGL here so use
      // _CGContextGetNVGContext( _context);
      //
      [_context forgetTextureID:_textureID];
   }

   [_sharedGPUTexture release];
   _sharedGPUTexture = nil;

   // this will call contextDidRemoveObject: eventually
   [_context removeResourceForKey:(MulleUIResourceStorageKey_t) self];

   [super finalize];
}


- (CGImage *) cgImageWithContext:(CGContext *) context
                    textureFlags:(NSUInteger) textureFlags
{
   if( [context shareID] != [_context shareID])
   {
      CGImageLog( "ImageID requested for context %#@ is in non-sharable context %#@",
                  context, _context);
      assert( 0);
      return( nil);
   }

   if( textureFlags != _textureFlags)
   {
      CGImageLog( "Non standard textureFlags 0x%tx (0x%x) requested. Use UIBitmapImage instead (for now)", textureFlags, _textureFlags);
      // would need to construct a new CGImage, but CGImage is too low level
      // use UIBitmapImage instead
      assert( 0);
      return( nil);
   }

   return( self);
}


- (instancetype) initWithContentsOfFileCString:(char *) filename
                                  textureFlags:(NSUInteger) textureFlags
                                       context:(CGContext *) context
{
   NSInteger   textureID;

   assert( [context isActive]);

   textureID = [context textureIDWithContentsOfFileCString:filename
                                              textureFlags:textureFlags & 0x3F];

   return( [self initWithTextureID:textureID
                      textureFlags:textureFlags
                           context:context]);
}


- (instancetype) initWithFileCData:(struct mulle_data) fileCData
                      textureFlags:(NSUInteger) textureFlags
                           context:(CGContext *) context
{
   NSInteger   textureID;

   assert( [context isActive]);

   // bounce to CGContext kind unneccessary now
   // this was used to generate debug output, but this now done
   // addImageToResources.
   // Another theory is to isolate nvgCalls in CGContext, but really why ?
   // They are isolated in this library already
   textureID = [context textureIDWithFileCData:fileCData
                                  textureFlags:textureFlags & 0x3F];
   return( [self initWithTextureID:textureID
                      textureFlags:textureFlags
                           context:context]);
}


- (instancetype) initWithRGBABytes:(void *) bytes
                        bitmapSize:(struct MulleIntegerSize) bitmapSize
                      textureFlags:(NSUInteger) textureFlags
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

   assert( [context isActive]);

   // bounce to context for debugging output of CGContext
   textureID = [context textureIDWithBytes:bytes
                                bitmapSize:bitmapSize
                              textureFlags:textureFlags & 0x3F];
   return( [self initWithTextureID:textureID
                      textureFlags:textureFlags
                           context:context]);
}


- (instancetype) initWithBitmap:(struct CGBitmap) bitmap
                   textureFlags:(NSUInteger) textureFlags
                        context:(CGContext *) context
{
   NSInteger             textureID;
   struct CGBitmap       convertedBitmap;
   struct CGBitmapInfo   convertedBitmapInfo;
   BOOL                  isFlipped;
   CGBitmapEncoding      encoding;
   CGBitmapEncoding      convertedEncoding;

   if( ! bitmap.bytes)
   {
      [self release];
      return( nil);
   }

   assert( [context isActive]);

   // we flip textureFlags on encoding, it allows more control for the
   // user, who will usually set this to 0

   encoding          = CGBitmapGetEncoding( bitmap);
   isFlipped         = CGBitmapEncodingIsFlipped( encoding);
   convertedEncoding = CGBitmapEncodingRGBABytes;
   if( isFlipped)
   {
      convertedEncoding = CGBitmapEncodingFlipYRGBABytes;
      textureFlags     ^= NVG_IMAGE_FLIPY;
   }

   convertedBitmapInfo = CGBitmapInfoMake( bitmap.info.size, 0, convertedEncoding);
   if( CGBitmapNeedsConversion( bitmap, convertedBitmapInfo))
   {
      convertedBitmap = CGBitmapConvert( bitmap, convertedBitmapInfo, NULL);
      if( CGBitmapIsNull( convertedBitmap))
      {
         fprintf( stderr, "unsupported CGImage format\n");
         [self release];
         return( nil);
      }
      textureID = [context textureIDWithBytes:convertedBitmap.bytes
                                   bitmapSize:convertedBitmap.info.size
                                 textureFlags:textureFlags];
      CGBitmapDone( convertedBitmap);
   }  
   else
      textureID = [context textureIDWithBytes:bitmap.bytes
                                   bitmapSize:bitmap.info.size
                                 textureFlags:textureFlags];

   return( [self initWithTextureID:textureID
                      textureFlags:textureFlags
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
// contexts until the other context have also deleted their textures and
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
// can change behind our backs, when shared for sure!
//
- (struct MulleIntegerSize) bitmapSize
{
   int   w, h;

   nvgImageSize( CGContextGetNVGContext( _context), _textureID, &w, &h);
   return( MulleIntegerSizeMake( w, h));
}


- (struct CGBitmapInfo) bitmapInfo
{
   return( CGBitmapInfoMake( [self bitmapSize], 0, CGBitmapEncodingRGBABytes));
}


- (void) setBytes:(void *) bytes
{
   assert( [_context isActive]);

   nvgUpdateImage( CGContextGetNVGContext( _context), _textureID, bytes);
}


- (void *) gpuTexture
{
   NVGcontext   *vg;
   void         *gpuTexture;

   if( _sharedGPUTexture)
      return( [_sharedGPUTexture gpuTexture]);

   vg = CGContextGetNVGContext( _context);
   nvgImageTextureInfo( vg, _textureID, NULL, NULL, &gpuTexture);
   return( gpuTexture);
}


- (id) shareWithContext:(id) otherContext
{
   NVGcontext   *vg;
   CGContext    *context;
   CGImage      *image;
   void         *gpuTexture;
   int          w, h;
   int          type;
   int          textureFlags;

   context = [self context];
   if( context == otherContext)
      return( self);

   if( ! otherContext)
   {
      errno = EINVAL;
      return( nil);
   }

   //
   // We would like to put up a barrier here, so that "we" know we are done
   // drawing the image and the other context doesn't get possibly an empty
   // buffer.
   // We can't be _really_ sure, that we are the active context though,
   // as all these commands don't touch OpenGL, but remain in MulleCG and
   // nanovg.
   // [context barrier]; // too expensive to do willy nilly

   // context need not be active, as we are just reading some internal
   // info
   vg = _CGContextGetNVGContext( context);

   //
   // if we can not copy from the original CGImage, we fail. This usually
   // means that the image is not in a sharing configuration
   //
   nvgImageSize( vg, _textureID, &w, &h);
   nvgImageTextureInfo( vg, _textureID, &textureFlags, &type, &gpuTexture);

   //
   // if this texture is already defined in the other context, we
   // get a CGImage back. If it wasn't its defined now, so we are done
   // As the context keeps track of this, we often get a cached image
   // back. We don't want to up the retainCount then, as we are already
   // sharing!
   //
   image = [otherContext imageWithGPUTextureRGBA:gpuTexture
                                sharedGPUTexture:_sharedGPUTexture
                                      bitmapSize:MulleIntegerSizeMake( w, h)
                                    textureFlags:textureFlags];

   // We now share a OpenGL texture with a different context
   // To keep track on who has to delete the OpenGL texture, we use a small
   // _sharedGPUTexture to keep the retainCount (and the OpenGL texture ID).
   //
   // -sharedGPUTexture will create a sharedGPUTexture if there isn't one yet
   //
   if( ! _sharedGPUTexture)
   {
      _sharedGPUTexture = [[image sharedGPUTexture] retain];

      if( [_context debugEnabled] || _debugEnabled)
         CGImageLog( "shared gpuTexture=%p in context %#@ with %#@ of %#@",
                     [_sharedGPUTexture gpuTexture], _context, image, otherContext);
   }

   return( image);
}


- (struct CGBitmap) RGBABytesBitmap:(struct mulle_allocator *) allocator
{
   return( [_context RGBABytesBitmapOfImage:self
                                  allocator:allocator]);
}

// this is a hack, until we properly turn multisample layers into standard
// cgimages for paints
- (BOOL) isMultiSample
{
   return( (_textureFlags & NVG_IMAGE_MSAA) ? YES : NO);
}


- (char *) UTF8String
{
   char   *s;

   s = MulleObjC_asprintf( "<%s %p textureID=%td %@>",
                           MulleObjCInstanceGetClassNameUTF8String( self),
                           self,
                           self->_textureID,
                           self->_sharedGPUTexture);
   return( s);
}

- (CGImage *) resolvedImage
{
   assert( ! [self isMultiSample]);

   return( self);
}


@end

#import "CGImage.h"

#import "CGContext.h"

#include <errno.h>


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

@end


@implementation CGContext( CGImage)

- (CGImage *) imageWithGPUTextureRGBA:(void *) gpuTexture
                     sharedGPUTexture:(CGSharedGPUTexture *) sharedGPUTexture
                           bitmapSize:(struct CGBitmapSize) size
                           imageFlags:(NSUInteger) imageFlags
{
   CGImage   *image;
   int       imageID;

   if( ! gpuTexture)
      return( nil);

   image = mulle_map_get( &_gpuTextureMap, gpuTexture);
   if( image)
   {
      if( _debugEnabled)
         fprintf( stderr, "*** context %p: reuse image %p nvgImage (%td) for texture %p (%p [%td])\n",
                       self,
                       image, [image imageID],
                       [image sharedGPUTexture], [[image sharedGPUTexture] gpuTexture], [[image sharedGPUTexture] retainCount]);

      assert( ! sharedGPUTexture || [image sharedGPUTexture] == sharedGPUTexture);
      return( [image imageFlags] == imageFlags ? image : nil);
   }

   image = [[[CGImage alloc] initWithGPUTextureRGBA:gpuTexture
                                   sharedGPUTexture:sharedGPUTexture
                                         bitmapSize:size
                                         imageFlags:imageFlags
                                            context:self] autorelease];
   if( _debugEnabled)
      fprintf( stderr, "*** context %p: remember image %p nvgImage (%td) for texture %p (%p [%td])\n",
                       self,
                       image, [image imageID],
                       [image sharedGPUTexture], [[image sharedGPUTexture] gpuTexture], [[image sharedGPUTexture] retainCount]);

   mulle_map_insert( &_gpuTextureMap, gpuTexture, image);
   return( image);
}


- (void) removeFromSharedGPUTextureMap:(CGImage *) image
{
   void   *gpuTexture;

   gpuTexture = [[image sharedGPUTexture] gpuTexture];
   if( _debugEnabled)
      fprintf( stderr, "*** context %p: forget image %p nvgImage (%td) for texture %p (%p [%td])\n",
                       self,
                       image, [image imageID],
                       [image sharedGPUTexture], [[image sharedGPUTexture] gpuTexture], [[image sharedGPUTexture] retainCount]);
   // if key is NULL its no problem
   mulle_map_remove( &_gpuTextureMap, gpuTexture);
}

@end




@implementation CGImage


- (instancetype) initWithNVGImage:(NSInteger) imageID
                        imageFlags:(NSUInteger) imageFlags
                           context:(CGContext *) context
{
   if( ! imageID)
   {
      [self release];
      return( nil);
   }

   if( [_context debugEnabled])
      fprintf( stderr, "*** context %p: create CGImage for nvgImage %td\n", context, imageID);

   _imageFlags = imageFlags;
   _context    = context;
   _imageID  = imageID;

   [_context addToResources:self];

   return( self);
}


- (instancetype) initWithGPUTextureRGBA:(void *) gpuTexture
                       sharedGPUTexture:(CGSharedGPUTexture *) sharedGPUTexture
                             bitmapSize:(struct CGBitmapSize) size
                             imageFlags:(NSUInteger) imageFlags
                                context:(CGContext *) context
{
   NSUInteger   imageID;

   imageID =  nvgCreateImageTexture( CGContextGetNVGContext( context),
                                     size.width,
                                     size.height,
                                     imageFlags,
                                     NVG_TEXTURE_RGBA,
                                     gpuTexture);
   self = [self initWithNVGImage:imageID
                      imageFlags:imageFlags
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


- (void) contextDidRemoveObject:(CGContext *) context
{
   if( _imageID)
   {
      // the gpuTexture may have been nil-ed out by finalize
      [context deleteTextureID:_imageID];
      _imageID = 0;
   }
   _context = nil;
}


//
// when called to be finalized, we can't really be loaned to the CGContext
//
- (void) finalize
{
   NVGcontext   *vg;

   if( [_context debugEnabled])
      fprintf( stderr, "*** context %p: finalize CGImage %p (nvgImage %td) with texture %p (%p [%td])\n",
                       _context,
                       self, _imageID,
                       _sharedGPUTexture, [_sharedGPUTexture gpuTexture], [_sharedGPUTexture retainCount]);

   [_context removeFromSharedGPUTextureMap:self];

   if( [_sharedGPUTexture retainCount] > 1)
   {
      //
      // nvg should forget the texture. So it wont get "really" deleted
      // as other context may still want to access it.
      // We only patch a struct and don't hit OpenGL here so use
      // _CGContextGetNVGContext( _context);
      //
      vg = _CGContextGetNVGContext( _context);
      nvgForgetImageTexture( vg, _imageID);
      _imageID = 0;  // but don't delete it now
   }

   [_sharedGPUTexture release];
   _sharedGPUTexture = nil;

   // this will call contextDidRemoveObject: eventually
   [_context removeFromResources:self];

   [super finalize];
}


- (NSInteger) nvgImageWithContext:(CGContext *) context
                       imageFlags:(NSUInteger) imageFlags
{
   if( context == _context && imageFlags == _imageFlags)
      return( _imageID);
   return( -1);
}


// this i
- (instancetype) initWithContentsOfFileCString:(char *) filename
                                    imageFlags:(NSUInteger) imageFlags
                                       context:(CGContext *) context
{
   NSInteger             imageID;
   struct CGBitmapSize   bitmapSize;

   assert( [context isActive]);

   imageID = nvgCreateImage( CGContextGetNVGContext( context),
                             filename,
                             imageFlags & 0x3F);
   return( [self initWithNVGImage:imageID
                        imageFlags:imageFlags
                           context:context]);
}


- (instancetype) initWithFileCData:(struct mulle_data) fileCData
                        imageFlags:(NSUInteger) imageFlags
                           context:(CGContext *) context
{
   NSInteger   imageID;

   assert( [context isActive]);

   imageID = nvgCreateImageMem( CGContextGetNVGContext( context),
                                imageFlags & 0x3F,
                                fileCData.bytes,
                                (int) fileCData.length);
   return( [self initWithNVGImage:imageID
                        imageFlags:imageFlags
                           context:context]);
}


- (instancetype) initWithRGBABytes:(void *) bytes
                        bitmapSize:(struct CGBitmapSize) bitmapSize
                        imageFlags:(NSUInteger) imageFlags
                           context:(CGContext *) context
{
   NSInteger   imageID;

   if( ! bytes)
   {
      [self release];
      return( nil);
   }

   assert( bitmapSize.width >= 1);
   assert( bitmapSize.height >= 1);

   assert( [context isActive]);

   imageID = nvgCreateImageRGBA( CGContextGetNVGContext( context),
                                   bitmapSize.width,
                                   bitmapSize.height,
                                   imageFlags & 0x3F,
                                   bytes);
   return( [self initWithNVGImage:imageID
                        imageFlags:imageFlags
                           context:context]);
}


- (instancetype) initWithBytes:(void *) bytes
                    bitmapInfo:(struct CGBitmapInfo) bitmapInfo
                    imageFlags:(NSUInteger) imageFlags
                       context:(CGContext *) context
{
   NSInteger    imageID;
   BOOL         isRGBA;
   void         *freeBytes;

   if( ! bytes)
   {
      [self release];
      return( nil);
   }
   assert( bitmapInfo.size.width >= 1);
   assert( bitmapInfo.size.height >= 1);

   assert( [context isActive]);

   // we flip imageFlags on encoding, it allows more control for the
   // user, who will usually set this to 0
   freeBytes = NULL;
   switch( CGBitmapInfoGetEncoding( bitmapInfo))
   {
   case CGBitmapEncodingFlipYRGBABytes : imageFlags ^= NVG_IMAGE_FLIPY;
   case CGBitmapEncodingRGBABytes      : break;
   default :
      freeBytes = CGBitmapConvertBytesToEncoding( bytes, bitmapInfo, CGBitmapEncodingRGBABytes, NULL);
      if( ! freeBytes)
      {
         fprintf( stderr, "unsupported CGImage format\n");
         [self release];
         return( nil);
      }
      bytes = freeBytes;
   }

   imageID = nvgCreateImageRGBA( CGContextGetNVGContext( context),
                                 bitmapInfo.size.width,
                                 bitmapInfo.size.height,
                                 imageFlags,
                                 bytes);
   mulle_free( freeBytes);

   return( [self initWithNVGImage:imageID
                       imageFlags:imageFlags
                          context:context]);
}


// - (int)  _ImageID
// {
//    return( _ImageID);
// }

// MEMO: A texture id can be reused. So the referencing image imageID can
//       eventually deviate between contexts. The sharing of a imageID
//       happens through the binding.
//       Example, how textureIDs can be differe
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
// Now the CGImage NanoVG imageID is different and local to each context.
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
//            NanoVG imageID (1)     NanoVG imageID (2)
//                     \               /
//                     OpenGL imageID (3)
//
// We can only call glDeleteTextures, if all NanoVGs images are closed.
//
//
// We can not delete a NanoVG image, as it will delete the shared texture
// (OpenGL). So we have to postpone this until the last context relinquishes
// the image. Problem: a NanoVG context could just disappear while waiting...
// Will it delete its images ?
//

//
// can change behind our backs, when shared for sure!
//
- (struct CGBitmapSize) bitmapSize
{
   int   w, h;

   nvgImageSize( CGContextGetNVGContext( _context), _imageID, &w, &h);
   return( CGBitmapSizeMake( w, h));
}


- (struct CGBitmapInfo) bitmapInfo
{
   return( CGBitmapInfoMake( [self bitmapSize], 0, CGBitmapEncodingRGBABytes));
}



- (void) setBytes:(void *) bytes
{
   assert( [_context isActive]);

   nvgUpdateImage( CGContextGetNVGContext( _context), _imageID, bytes);
}


- (void *) gpuTexture
{
   NVGcontext   *vg;
   void         *gpuTexture;

   if( _sharedGPUTexture)
      return( [_sharedGPUTexture gpuTexture]);

   vg = CGContextGetNVGContext( _context);
   nvgImageTextureInfo( vg, _imageID, NULL, NULL, &gpuTexture);
   return( gpuTexture);
}


- (CGImage *) shareWithContext:(CGContext *) otherContext
{
   NVGcontext           *vg;
   CGContext            *context;
   CGImage              *image;
   void                 *gpuTexture;
   int                  w, h;
   int                  type;
   int                  imageFlags;
   CGSharedGPUTexture   *otherSharedGPUTexture;

   context = [self context];
   if( context == otherContext)
      return( self);

   if( ! otherContext)
   {
      errno = EINVAL;
      return( nil);
   }

   // context need not be active, as we are just reading some internal
   // info
   vg = _CGContextGetNVGContext( context);

   //
   // if we can not copy from the original CGImage, we fail. This usually
   // means that the image is not in a sharing configuration
   //
   nvgImageSize( vg, _imageID, &w, &h);
   nvgImageTextureInfo( vg, _imageID, &imageFlags, &type, &gpuTexture);

   //
   // if this texture is already defined in the other context, we
   // get a CGImage back. If it wasn't its defined now, so we are done
   // As the context keeps track of this, we often get a cached image
   // back. We don't want to up the retainCount then, as we are already
   // sharing!
   //
   image = [otherContext imageWithGPUTextureRGBA:gpuTexture
                                sharedGPUTexture:_sharedGPUTexture
                                      bitmapSize:CGBitmapSizeMake( w, h)
                                      imageFlags:imageFlags];

   // We now share a OpenGL texture with a different context
   // To keep track on who has to delete the OpenGL texture, we use a small
   // _sharedGPUTexture to keep the retainCount (and the OpenGL texture ID).
   //
   // -sharedGPUTexture will create a sharedGPUTexture if there isn't one yet
   //
   if( ! _sharedGPUTexture)
   {
      _sharedGPUTexture = [[image sharedGPUTexture] retain];

      if( [_context debugEnabled])
         fprintf( stderr, "*** context %p: new CGImage %p (nvgImage %td) "
                        "shares texture %p (%p [%td]) with CGImage %p (nvgImage %td) of context %p\n",
                        otherContext, image, image->_imageID,
                        _sharedGPUTexture, [_sharedGPUTexture gpuTexture], [_sharedGPUTexture retainCount],
                        self, self->_imageID, _context);
   }

   return( image);
}

@end

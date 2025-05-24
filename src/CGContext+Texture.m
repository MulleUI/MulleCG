//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#import "CGContext+Texture.h"

#import "import-private.h"

#import "CGContext+OpenGL.h"
#import "CGContext+nanovg.h"
#import "CGImage.h"
#import "CGFramebuffer.h"


@implementation CGContext( Texture)


- (CGTextureID) textureIDWithRGBABytes:(void *) bytes
                            bitmapSize:(CGPixelSize) size
                          textureFlags:(NSUInteger) textureFlags
{
   CGTextureID   textureID;

   textureID = nvgCreateImageRGBA( _vg,
                                   (int) size.width,
                                   (int) size.height,
                                   (int) textureFlags,
                                   bytes);
   return( textureID);
}


- (CGTextureID) textureIDWithFileCData:(struct mulle_data) fileCData
                          textureFlags:(NSUInteger) textureFlags
{
   CGTextureID   textureID;

   textureID = nvgCreateImageMem( _vg,
                                  textureFlags,
                                  fileCData.bytes,
                                  (int) fileCData.length);
   return( textureID);
}


- (CGTextureID) textureIDWithContentsOfFileUTF8String:(char *) filename
                                      textureFlags:(NSUInteger) textureFlags
{
   CGTextureID   textureID;

   textureID = nvgCreateImage( _vg, filename, textureFlags);
   return( textureID);
}


- (CGTextureID) textureIDWithGPUTexture:(CGGPUTextureID) gpuTexture
                             bitmapSize:(CGPixelSize) size
                           textureFlags:(NSUInteger) textureFlags
{
   CGTextureID   textureID;
   int           textureType;

   textureType = NVG_TEXTURE_RGBA;
#ifdef NVG_TEXTURE_MSAA
   if( textureFlags & NVG_IMAGE_MSAA)
      textureType = NVG_TEXTURE_MSAA;
#endif
   textureID = nvgCreateImageTexture( _vg,
                                      size.width,
                                      size.height,
                                      textureFlags,
                                      textureType,
                                      gpuTexture);
   return( textureID);
}


- (void) deleteTextureIDs
{
   void   *textureID;

   mulle__pointerarray_for( &_deletedTextureIDs, textureID)
   {
      if( _debuggingFlags & 0x2)
         MulleUILog( "release nvgImageId %td", (CGTextureID) textureID);
      nvgDeleteImage( _vg, (int) (CGTextureID) textureID);
      CGContextCheckBackendError( self, "after nvgDeleteImage");
   }

   _mulle__pointerarray_reset( &_deletedTextureIDs);
}


//
// When a CGImage gets reaped by an NSAutoreleasePool the context may not
// be activated and it could be tricky to ascertain, that it isn't in use
// by another thread. So we queue these delete requests up
// TODO: may need to lock this... ?
- (void) deleteTextureID:(CGTextureID) textureID
{
   if( _debuggingFlags & 0x2)
      MulleUILog( "queuing release of nvgImageId %td", (CGTextureID) textureID);
   _mulle__pointerarray_add( &_deletedTextureIDs,
                             (void *) textureID,
                             MulleObjCInstanceGetAllocator( self));
}


// used by shared textureIDs
- (void) forgetTextureID:(CGTextureID) textureID
{
   if( _debuggingFlags & 0x2)
      MulleUILog( "forgetting nvgImageId %td", (CGTextureID) textureID);
   nvgForgetImageTexture( _vg, textureID);
   CGContextCheckBackendError( self, "after nvgForgetImageTexture");
}


- (void) deleteGPUFramebuffers
{
   CGGPUFramebuffer   *gpuFramebuffer;

   // no callbacks in the locked code so no need to copy, we need a second
   // lock here to not deadlock in CGImage finalize
   mulle_thread_mutex_do( _deletedGPUFramebuffersLock)
   {
      mulle__pointerarray_for( &_deletedGPUFramebuffers, gpuFramebuffer)
      {
         assert( ! _mulle_atomic_pointer_read( &_drawnRenderedFramebuffer)
                 || gpuFramebuffer != [(id) _mulle_atomic_pointer_read( &_drawnRenderedFramebuffer) gpuFramebuffer]);
         assert( ! _mulle_atomic_pointer_read( &_scratchRenderedFramebuffer)
                 || gpuFramebuffer != [(id) _mulle_atomic_pointer_read( &_scratchRenderedFramebuffer) gpuFramebuffer]);

         if( _debuggingFlags & 0x2)
            MulleUILog( "release framebuffer %p", gpuFramebuffer);
         nvgluDeleteFramebuffer( (NVGLUframebuffer *) gpuFramebuffer);
         CGContextCheckBackendError( self, "after nvgluDeleteFramebuffer");
      }

      _mulle__pointerarray_reset( &_deletedGPUFramebuffers);
   }
}


//
// When a CGImage gets reaped by an NSAutoreleasePool the context may not
// be activated and it could be tricky to ascertain, that it isn't in use
// by another thread. So we queue these delete requests up
//
- (void) deleteGPUFramebuffer:(CGGPUFramebuffer *) gpuFramebuffer
{
   if( _debuggingFlags & 0x2)
      MulleUILog( "queuing release of GPU framebuffer %p", gpuFramebuffer);

   mulle_thread_mutex_do( _deletedGPUFramebuffersLock)
   {
      _mulle__pointerarray_add( &_deletedGPUFramebuffers,
                                gpuFramebuffer,
                                MulleObjCInstanceGetAllocator( self));
   }
}


- (CGGPUTextureID) gpuTextureForTextureID:(CGTextureID) textureID
{
   NVGcontext       *vg;
   CGGPUTextureID   gpuTexture;

   vg = CGContextGetNVGContext( self);
   nvgImageTextureInfo( vg, textureID, NULL, NULL, &gpuTexture);
   return( gpuTexture);
}


- (void) setRGBABytes:(void *) bytes
         forTextureID:(CGTextureID) textureID
{
   assert( CGContextIsActiveInCurrentThread( self));

   nvgUpdateImage( CGContextGetNVGContext( self), textureID, bytes);
}


- (CGPixelSize) bitmapSizeForTextureID:(CGTextureID) textureID
{
   int   w, h;

   nvgImageSize( CGContextGetNVGContext( self), textureID, &w, &h);
   return( CGPixelSizeMake( w, h));
}

@end

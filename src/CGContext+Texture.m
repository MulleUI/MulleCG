//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#import "CGContext+Texture.h"

#import "import-private.h"

#import "CGContext+OpenGL.h"
#import "CGImage.h"


@implementation CGContext( Texture)


- (CGTextureID) textureIDWithBytes:(void *) bytes
                      bitmapSize:(struct MulleIntegerSize) size
                      imageFlags:(NSUInteger) imageFlags
{
   CGTextureID   textureID;

   textureID = nvgCreateImageRGBA( _vg,
                                 (int) size.width,
                                 (int) size.height,
                                 (int) imageFlags,
                                 bytes);
   return( textureID);
}


- (CGTextureID) textureIDWithFileCData:(struct mulle_data) fileCData
                          imageFlags:(NSUInteger) imageFlags
{
   CGTextureID   textureID;

   textureID = nvgCreateImageMem( _vg,
                                imageFlags,
                                fileCData.bytes,
                                (int) fileCData.length);
   return( textureID);
}


- (CGTextureID) textureIDWithContentsOfFileCString:(char *) filename
                                      imageFlags:(NSUInteger) imageFlags
{
   CGTextureID   textureID;

   textureID = nvgCreateImage( _vg, filename, imageFlags);
   return( textureID);
}


- (CGTextureID) textureIDWithGPUTextureRGBA:(void *) gpuTexture
                                 bitmapSize:(struct MulleIntegerSize) size
                                 imageFlags:(NSUInteger) imageFlags
{
   CGTextureID   textureID;

   textureID = nvgCreateImageTexture( _vg,
                                    size.width,
                                    size.height,
                                    imageFlags,
                                    NVG_TEXTURE_RGBA,
                                    gpuTexture);
   return( textureID);
}


- (void) deleteTextureIDs
{
   struct mulle__pointerarrayenumerator  rover;
   void                                  *textureID;

   rover = _mulle__pointerarray_enumerate( &_deletedTextureIDs);
   while( _mulle__pointerarrayenumerator_next( &rover, &textureID))
   {
      if( _debugEnabled & 0x2)
         MulleUILog( "release nvgImageId %td", (CGTextureID) textureID);
      nvgDeleteImage( _vg, (int) (CGTextureID) textureID);
      CGContextCheckBackendError( self, "after nvgDeleteImage");
   }
   mulle__pointerarrayenumerator_done( &rover);

   _mulle__pointerarray_reset( &_deletedTextureIDs);
}


//
// When a CGImage gets reaped by an NSAutoreleasePool the context may not
// be activated and it could be tricky to ascertain, that it isn't in use
// by another thread. So we queue these delete requests up
// TODO: may need to lock this... ?
- (void) deleteTextureID:(CGTextureID) textureID
{
   if( _debugEnabled & 0x2)
      MulleUILog( "queuing release of nvgImageId %td", (CGTextureID) textureID);
   _mulle__pointerarray_add( &_deletedTextureIDs,
                             (void *) textureID,
                             MulleObjCInstanceGetAllocator( self));
}


// used by shared textureIDs
- (void) forgetTextureID:(CGTextureID) textureID
{
   if( _debugEnabled & 0x2)
      MulleUILog( "forgetting nvgImageId %td", (CGTextureID) textureID);
   nvgForgetImageTexture( _vg, textureID);
   CGContextCheckBackendError( self, "after nvgForgetImageTexture");
}



- (void) deleteFramebuffers
{
   struct mulle__pointerarrayenumerator  rover;
   void                                  *framebuffer;

   rover = _mulle__pointerarray_enumerate( &_deletedFramebuffers);
   while( _mulle__pointerarrayenumerator_next( &rover, &framebuffer))
   {
      if( _debugEnabled & 0x2)
         MulleUILog( "release framebuffer %p", framebuffer);
      nvgluDeleteFramebuffer((NVGLUframebuffer *) framebuffer);
      CGContextCheckBackendError( self, "after nvgluDeleteFramebuffer");
   }
   mulle__pointerarrayenumerator_done( &rover);

   _mulle__pointerarray_reset( &_deletedFramebuffers);
}


//
// When a CGImage gets reaped by an NSAutoreleasePool the context may not
// be activated and it could be tricky to ascertain, that it isn't in use
// by another thread. So we queue these delete requests up
// TODO: may need to lock this... ?
- (void) deleteFramebuffer:(void *) framebuffer
{
   if( _debugEnabled & 0x2)
      MulleUILog( "queuing release of framebuffer %p", framebuffer);
   _mulle__pointerarray_add( &_deletedFramebuffers,
                             (void *) framebuffer,
                             MulleObjCInstanceGetAllocator( self));
}

@end

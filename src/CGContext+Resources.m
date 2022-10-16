//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#import "CGContext+Resources.h"

#import "import-private.h"

#import "CGImage.h"


@implementation CGContext ( Resources)

- (void) addToResources:(id) resource
{
   // resources are not retained! If you want them retained, use
   // loanResource after adding
   _mulle__pointerset_insert( &_resources, resource, MulleObjCInstanceGetAllocator( self));
}


- (void) _removeFromResources:(id) resource
{
   assert( ! mulle_set_get( &_loanedResources, resource));

   _mulle__pointerset_remove( &_resources, resource, MulleObjCInstanceGetAllocator( self));
}


- (void) removeFromResources:(id) resource
{
   assert( ! mulle_set_get( &_loanedResources, resource));

   if( _mulle__pointerset_remove( &_resources, resource, MulleObjCInstanceGetAllocator( self)))
      [resource contextDidRemoveObject:self];
}


- (void) removeAllResources
{
   struct mulle__pointersetenumerator   rover;
   struct mulle__pointerset             tmp;
   id                                   resource;

   if( _debugEnabled)
      MulleUILog( "removeAllResources");

   tmp = _resources;
   _mulle__pointerset_init( &_resources, 0, MulleObjCInstanceGetAllocator( self));

   rover = _mulle__pointerset_enumerate( &tmp);
   while( _mulle__pointersetenumerator_next( &rover, (void **) &resource))
      [resource contextDidRemoveObject:self];
   mulle__pointersetenumerator_done( &rover);

   _mulle__pointerset_done( &tmp, MulleObjCInstanceGetAllocator( self));
}


- (void) loanResource:(id <CGContextResource>) resource
{
   assert( _mulle__pointerset_get( &_resources, resource));
   assert( ! mulle_set_get( &_loanedResources, resource));

   [(id) resource retain];
   mulle_set_insert( &_loanedResources, resource);
}


- (void) repossessResource:(id <CGContextResource>) resource
{
   id <CGContextResource>  found;

   assert( mulle_set_get( &_loanedResources, resource));

   mulle_set_remove( &_loanedResources, resource);
   [(id) resource autorelease];
}


- (void) releaseAllLoanedResources
{
   struct mulle_setenumerator   rover;
   struct mulle_set             tmp;
   id                           resource;

   if( _debugEnabled)
      MulleUILog( "releaseAllLoanedResources");

   tmp = _loanedResources;
   mulle_set_init( &_loanedResources,
                   0,
                   &mulle_container_keycallback_nonowned_pointer,
                   MulleObjCInstanceGetAllocator( self));

   rover = _mulle_set_enumerate( &tmp);
   while( mulle_setenumerator_next( &rover, (void **) &resource))
      [resource autorelease];
   mulle_setenumerator_done( &rover);

   mulle_set_done( &tmp);
}


- (void) addImageToResources:(CGImage *) image
{
   if( _debugEnabled & 0x2)
      MulleUILog( "acquire nvgImageId %td", [image imageID]);

   // resources are not retained! If you want them retained, use
   // loanResource after adding
   _mulle__pointerset_insert( &_resources, image, MulleObjCInstanceGetAllocator( self));
}


- (NSInteger) textureIDWithBytes:(void *) bytes
                      bitmapSize:(struct MulleIntegerSize) size
                      imageFlags:(NSUInteger) imageFlags
{
   NSInteger   imageID;

   imageID = nvgCreateImageRGBA( _vg,
                                 (int) size.width,
                                 (int) size.height,
                                 (int) imageFlags,
                                 bytes);
   return( imageID);
}


- (NSInteger) textureIDWithFileCData:(struct mulle_data) fileCData
                          imageFlags:(NSUInteger) imageFlags
{
   NSInteger   imageID;

   imageID = nvgCreateImageMem( _vg,
                                imageFlags,
                                fileCData.bytes,
                                (int) fileCData.length);
   return( imageID);
}


- (NSInteger) textureIDWithContentsOfFileCString:(char *) filename
                                      imageFlags:(NSUInteger) imageFlags
{
   NSInteger   imageID;

   imageID = nvgCreateImage( _vg, filename, imageFlags);
   return( imageID);
}


- (NSInteger) textureIDWithGPUTextureRGBA:(void *) gpuTexture
                               bitmapSize:(struct MulleIntegerSize) size
                               imageFlags:(NSUInteger) imageFlags
{
   NSInteger   imageID;

   imageID = nvgCreateImageTexture( _vg,
                                    size.width,
                                    size.height,
                                    imageFlags,
                                    NVG_TEXTURE_RGBA,
                                    gpuTexture);
   return( imageID);
}


- (void) deleteTextureIDs
{
   struct mulle__pointerarrayenumerator  rover;
   void                                  *imageID;

   rover = _mulle__pointerarray_enumerate( &_deletedTexturedIDs);
   while( _mulle__pointerarrayenumerator_next( &rover, &imageID))
   {
      if( _debugEnabled & 0x2)
         MulleUILog( "release nvgImageId %td", (NSInteger) imageID);
      nvgDeleteImage( _vg, (int) (NSInteger) imageID);
   }
   mulle__pointerarrayenumerator_done( &rover);

   _mulle__pointerarray_reset( &_deletedTexturedIDs);
}


//
// When a CGImage gets reaped by an NSAutoreleasePool the context may not
// be activated and it could be tricky to ascertain, that it isn't in use
// by another thread. So we queue these delete requests up
// TODO: may need to lock this... ?
- (void) deleteTextureID:(NSInteger) imageID
{
   if( _debugEnabled & 0x2)
      MulleUILog( "queuing release of nvgImageId %td", (NSInteger) imageID);
   _mulle__pointerarray_add( &_deletedTexturedIDs,
                             (void *) imageID,
                             MulleObjCInstanceGetAllocator( self));
}



// used by shared textureIDs
- (void) forgetTextureID:(NSInteger) imageID
{
   if( _debugEnabled & 0x2)
      MulleUILog( "forgetting nvgImageId %td", (NSInteger) imageID);
   nvgForgetImageTexture( _vg, imageID);
}

@end

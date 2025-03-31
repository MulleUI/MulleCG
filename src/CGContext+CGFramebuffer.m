//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGContext+CGFramebuffer.h"

#import "import-private.h"

#import "CGContext+DebugPrivate.h"
#import "CGContext+OpenGL.h"
#import "CGContext+Render.h"
#import "CGImage+DebugPrivate.h"


@implementation CGContext ( CGFramebuffer)

/*
 * manage framebuffers
 */
- (CGFramebuffer *) framebufferWithSize:(CGPixelSize) size
                           textureFlags:(NSUInteger) textureFlags
                         nameUTF8String:(char *) nameUTF8String
{
   CGFramebuffer   *framebuffer;
   CGPixelSize     oldSize;

   framebuffer = [self acquireRecycledFramebuffer];
   CGContextLogVerbose( "try to reuse framebuffer %#@", framebuffer);
   oldSize     = [framebuffer bitmapSize];

   if( ! CGPixelSizeEqualToPixelSize( oldSize, size))
   {
      framebuffer = [CGFramebuffer framebufferWithBitmapSize:size
                                                textureFlags:textureFlags
                                              nameUTF8String:nameUTF8String
                                                      context:self];
   }
   else
   {
      CGContextLogVerbose( "reused framebuffer %#@ with size %s",
                           framebuffer,
                           CGPixelSizeUTF8String( size));
   }
   return( framebuffer);
}


- (void) clearFramebufferWithHexColor:(NSUInteger) hexColor
{
   [self clearFramebufferBits:_framebufferBits
                        color:CGColorMakeWithHexColor( hexColor)];
}

- (void) clearFramebufferWithColor:(CGColor) color
{
   [self clearFramebufferBits:_framebufferBits
                        color:color];
}


- (void) clearFramebuffer
{
   [self clearFramebufferBits:_framebufferBits
                        color:CGColorMakeWithHexColor( 0x000000FF)];
}


- (struct CGContextFramebuffer) currentFramebuffer
{
   return( _currentFramebuffer);
}


- (struct CGContextFramebuffer) bindFramebuffer:(struct CGContextFramebuffer) fb
{
   struct CGContextFramebuffer   old;

   assert( CGContextIsActiveInCurrentThread( self));

   old = _currentFramebuffer;
   // the old layer should notice that its unbound to set its
   // initialized flag
   if( old.type == CGContextLayerFramebuffer
      || old.type == CGContextLayerMultiSampleFramebuffer)
   {
      [(CGFramebuffer *) old.handle _unbindFromContext];  // nvg will restore
   }

   switch( fb.type)
   {
   case CGContextDefaultFramebuffer :
   case CGContextDefaultMultiSampleFramebuffer  :
      // this is GL on the "bottom" anyway
      [self bindDefaultOpenGLFramebuffer];
      break;

   case CGContextLayerFramebuffer :
   case CGContextLayerMultiSampleFramebuffer  :
      [(CGFramebuffer *) fb.handle _bindToContext];  // nvg will restore
      break;

   case CGContextOpenGLFramebuffer  :
   case CGContextOpenGLMultiSampleFramebuffer  :
      [self bindOpenGLFramebuffer:fb.handle];
      break;

   default :
      abort();
   }

   _currentFramebuffer = fb;

   return( old);
}


- (BOOL) needsFramebufferClear
{
   switch( _currentFramebuffer.type)
   {
   default                         :
      return( ! [self isInitializedFramebuffer]);

   case CGContextLayerFramebuffer  :
   case CGContextLayerMultiSampleFramebuffer  :
      return( ! [(CGFramebuffer *) _currentFramebuffer.handle isInitializedFramebuffer]);

   case CGContextOpenGLFramebuffer :
   case CGContextOpenGLMultiSampleFramebuffer  :
      return( YES);
   }
}


- (void) deleteFramebuffers
{
   CGFramebuffer   *framebuffer;

   // no callbacks in the locked code so no need to copy
   mulle_thread_mutex_do( _deletedFramebuffersLock)
   {
      mulle__pointerarray_for( &_deletedFramebuffers, framebuffer)
      {
         _CGImageLog( framebuffer, "%#@ finalizes framebuffer", self);
         [framebuffer mulleGainAccess];
         [framebuffer mullePerformFinalize];
      }

      _mulle__pointerarray_reset( &_deletedFramebuffers);
   }
}


//
// This can be called by another thread. So we can't autorelease anything
// be activated and it could be tricky to ascertain, that it isn't in use
// by another thread. So we queue these delete requests up
//
- (void) queueFramebufferForDeletion:(CGFramebuffer *) framebuffer
{
   _CGImageLog( framebuffer, "%#@ queues framebuffer for finalization/release");

   mulle_thread_mutex_do( _deletedFramebuffersLock)
   {
      [framebuffer mulleRelinquishAccess];
      _mulle__pointerarray_add( &_deletedFramebuffers,
                                framebuffer,
                                MulleObjCInstanceGetAllocator( self));
   }
}


//
// this is only to be used by the proper context, whereas 
// -acquireOffscreenFramebuffer and -recycleFramebuffer are "foreign" context
// methods
//
- (id) acquireRecycledFramebuffer
{
   id   framebuffer;

   framebuffer = _MulleObjCAcquireObjectAtomically( &_scratchLayer);
   assert( ! framebuffer || [framebuffer context] == self);
   return( framebuffer);
}


/*
 * Offscreenbuffer cycle.
 *
 * ## Generation
 *
 * When it's time to draw a new framebuffer, then we use the
 * _scratchLayer. If there is no _scratchLayer a new CGFramebuffer is
 * generated. If there was a _scratchLayer it is now set to nil.
 * The layer once finished is moved to _drawnLayer. If there was a
 * previous _drawnLayer it is attempted to place it into
 * _scratchLayer. If that doesn't succeed it gets released. If it does,
 * then fine. The drawing part is done.
 *
 * ## Display
 *
 * The _drawnLayer is acquired (take and _drawnLayer set to nil)
 * by the main thread usually. If it's nil, well shucks nothing to draw then.
 * Once the _drawnLayer has been used by the main thread it gets
 * repossesed. If there is no room in _scratchLayer it will get
 * discarded.
 */
- (id) acquireOffscreenFramebuffer
{
   id   framebuffer;

   // Acquire manages mulleGgainAccess
   framebuffer = _MulleObjCAcquireObjectAtomically( &_drawnLayer);  // this calls -autorelease
   return( framebuffer);
}


//
// get a framebuffer from possibly an outside source back. the framebuffer must
// have the same shareID as our context, we can then reuse it
//
- (void) recycleFramebuffer:(id) framebuffer
{
   if( ! _MulleObjCRecycleObjectAtomically( &_scratchLayer, framebuffer))
   {
      //
      // scratchLayer was already occupied...
      //
      // the framebuffer is now autoreleased again, but possibly in the wrong
      // thread, so it would be bad if it -finalized there.
      // The following method will relinquish the framebuffer again and
      // queue the framebuffer for finalization in our thread.
      //
      [self queueFramebufferForDeletion:framebuffer];
   }
}


static CGPixelSize
   _CGContextBitmapSizeOfLayerFramebuffer( CGContext *self,
                                           struct CGContextFramebuffer fb)
{
   assert( fb.type == CGContextLayerFramebuffer
           || fb.type == CGContextLayerMultiSampleFramebuffer);
   return( [(CGFramebuffer *) fb.handle bitmapSize]);
}


static CGPixelSize
   _CGContextBitmapSizeOfDefaultFramebuffer( CGContext *self,
                                             struct CGContextFramebuffer fb)
{
   struct CGFrameInfo   info;

   assert( fb.type == CGContextDefaultFramebuffer
           || fb.type == CGContextDefaultMultiSampleFramebuffer);
   [self getCurrentFrameInfo:&info];
   return( CGFrameInfoGetFramebufferSize( &info));
}


CGPixelSize
   CGContextBitmapSizeOfFramebuffer( CGContext *self,
                                     struct CGContextFramebuffer fb)
{
   switch( fb.type)
   {
   case CGContextDefaultFramebuffer :
   case CGContextDefaultMultiSampleFramebuffer :
      return( _CGContextBitmapSizeOfDefaultFramebuffer( self, fb));
   case CGContextLayerFramebuffer :
   case CGContextLayerMultiSampleFramebuffer :
      return( _CGContextBitmapSizeOfLayerFramebuffer( self, fb));
   case CGContextOpenGLFramebuffer :
   case CGContextOpenGLMultiSampleFramebuffer :
      return( _CGContextBitmapSizeOfOpenGLFramebuffer( self, fb));
   }
   abort();
}




// - (MulleTextureImage *) framebufferImageWithIntegerSize:(struct CGBitmapInfo) size
//                                                options:(NSUInteger) options
// {
//    MulleTextureImage   *image;
//
//    image = [[[MulleTextureImage alloc] initWithBitmapInfo:size
//                                                   context:self
//                                                   options:options] autorelease];
//    if( ! image)
//       return( nil);
//
//    // images are not retained!
//    if( ! _layers)
//       _layers = mulle_pointerarray_create( NULL);
//    _mulle_pointerarray_add( &_layers, image);
//
//    return( image);
// }

@end

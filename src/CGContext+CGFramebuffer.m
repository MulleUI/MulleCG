//
//  CGContext+CGFramebuffer.m
//  MulleCG
//
//  Copyright (c) 2025 Nat! - Mulle kybernetiK.
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
#import "CGContext+CGFramebuffer.h"

#import "import-private.h"

#import "CGContext+CGFramebuffer+Private.h"
#import "CGContext+DebugPrivate.h"
#import "CGImage+DebugPrivate.h"


@interface CGImage( Private)

- (void) didAddToContext:(CGContext *) context;
- (void) didRemoveFromContext:(CGContext *) context;

@end


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
   NSUInteger      oldTextureFlags;

   framebuffer     = [self repossessRenderedFramebuffer];
   CGContextLogVerbose( "try to reuse framebuffer %#@", framebuffer);
   oldSize         = [framebuffer bitmapSize];
   oldTextureFlags = [framebuffer textureFlags];

   if( ! CGPixelSizeEqualToPixelSize( oldSize, size) ||
       oldTextureFlags != textureFlags)
   {
      framebuffer = [CGFramebuffer framebufferWithBitmapSize:size
                                                textureFlags:textureFlags
                                              nameUTF8String:nameUTF8String
                                                      context:self];
   }
   else
   {
      CGContextLogVerbose( "reused framebuffer %#@ with size %s and texture flags 0x%tx",
                           framebuffer,
                           CGPixelSizeUTF8String( size),
                           textureFlags);
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
      [self bindDefaultGPUFramebuffer];
      break;

   case CGContextLayerFramebuffer :
   case CGContextLayerMultiSampleFramebuffer  :
      [(CGFramebuffer *) fb.handle _bindToContext];  // nvg will restore
      break;

   case CGContextOpenGLFramebuffer  :
   case CGContextOpenGLMultiSampleFramebuffer  :
      [self bindGPUFramebuffer:fb.handle];
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



/*
 * Offscreenbuffer cycle.
 *
 * ## Generation
 *
 * When it's time to draw a new framebuffer, then we use the
 * _scratchRenderedFramebuffer. If there is no _scratchRenderedFramebuffer a new CGFramebuffer is
 * generated. If there was a _scratchRenderedFramebuffer it is now set to nil.
 * The layer once finished is moved to _drawnRenderedFramebuffer. If there was a
 * previous _drawnRenderedFramebuffer it is attempted to place it into
 * _scratchRenderedFramebuffer. If that doesn't succeed it gets released. If it does,
 * then fine. The drawing part is done.
 *
 * ## Display
 *
 * The _drawnRenderedFramebuffer is acquired (take and _drawnRenderedFramebuffer set to nil)
 * by the main thread usually. If it's nil, well shucks nothing to draw then.
 * Once the _drawnRenderedFramebuffer has been used by the main thread it gets
 * repossesed. If there is no room in _scratchRenderedFramebuffer it will get
 * discarded.
 */

// Problem #1. Thread affinity. The framebuffer is in limbo as long as its
//             stored in the _drawnRenderedFramebuffer or _scratchRenderedFramebuffer. Once its taken
//             out it belongs to the thread taken out.
//
// Problem #2. Though the framebuffer may be acquired by another thread,
//             it's context never changed. You only share the GPUtexture
//
// Problem #3. When the context winds down in will finalize the resources
//             but the framebuffer may be in limbo (i.e. not accessible)
//             by the current thread. It could also be in the
//             deletedFramebuffers queue.
//
// Problem #4. When we have deletedFramebuffers and we close the thread
//             we have the framebuffers as resources, which will be transferred
//             but they are in limbo and therefore would crash.
//
// Problem #5. Even when we ensure that the framebuffers in scratch, drawn and
//             deleted are treated special, we still will crash on the
//             acquired framebuffer by the other thread, as its still our
//             resource.
//
// Solution:   Either give the resource back or treat all rendered buffer
//             as non-resources.
//
// What we do now, we give the resource back (works!) and now also tread all
// RenderedFramebuffer special, for less hacky code.
//

static BOOL   isAccessFromOtherThread( CGContext *self, BOOL defaultFlag)
{
   NSThread   *activeThread;
   NSThread   *currentThread;

   // during finalization we don't care anymore
   if( _mulle_objc_object_is_finalized( self))
      return( defaultFlag);

   activeThread = [self activeThread];
   if( ! activeThread)
      return( defaultFlag);

   currentThread = [NSThread currentThread];
   return( activeThread != currentThread);
}


#pragma mark - foreign thread interface

- (id) acquireRenderedFramebuffer
{
   id   framebuffer;

   // MEMO: a warning would be OK
#ifndef MULLE_TEST
   assert( isAccessFromOtherThread( self, YES));
#endif
   // acquire manages mulleGainAccess. store -> relinquish
   // acquire -> gain  (you can't read)
   framebuffer = _MulleObjCAcquireObjectAtomically( &_drawnRenderedFramebuffer);  // this calls -autorelease

   _CGImageLogVerbose( framebuffer, "%#@ acquires framebuffer", self);

   return( framebuffer);
}


//
// get a framebuffer from an outside source back
//
- (void) recycleAcquiredRenderedFramebuffer:(id) framebuffer
{
   if( ! framebuffer)
      return;

   _CGImageLogVerbose( framebuffer, "%#@ recycles framebuffer", self);

   if( ! _MulleObjCRecycleObjectAtomically( &_scratchRenderedFramebuffer, framebuffer))
   {
      // running thread gained access back
      // scratchLayer was already occupied...
      //
      // the framebuffer is now autoreleased again, but possibly in the wrong
      // thread, so it would be bad if it -finalized there.
      // The following method will relinquish the framebuffer again and
      // queue the framebuffer for finalization in our thread.
      //
      [self queueRenderedFramebufferForDeletion:framebuffer];
   }
}


#pragma mark - context thread interface


//
// _renderFramebuffer will be NULL at the end
// _scratchRenderedFramebuffer and _drawnRenderedFramebuffer are not part of resources
//
- (void) provideRenderedFramebuffer:(CGFramebuffer *) framebuffer
{
   CGFramebuffer   *old;

   if( ! framebuffer)
      return;

#ifndef MULLE_TEST
   assert( ! isAccessFromOtherThread( self, NO));
#endif

   // get rid of old "valid" framebuffer previously, if still present
   old = _MulleObjCAcquireObjectAtomically( &_drawnRenderedFramebuffer);
   if( old)
   {
      CGContextRenderLogVerbose( "Recycle scratch %#@ for %#@", _scratchRenderedFramebuffer, old);
      assert( [old context] == self || [old context] == nil);
      if( ! _MulleObjCRecycleObjectAtomically( &_scratchRenderedFramebuffer, old))
      {
         //
         // this means old will get discarded in the context thread,
         // which is fine, turn it back into resource though
         //
         [self _assignResource:old
                        forKey:(MulleUIResourceStorageKey_t) old];
      }
   }

   // by recycling it in _drawnRenderedFramebuffer we store it there, since
   // CGContext is the only one who is _supposed_ to write any NON-NULL value
   // into _drawnRenderedFramebuffer, this can't fail, and if it does it gets
   // harmlessly reaped.
   //
   // Before making it available to other contexts
   // possibly, we need to put up a barrier to ensure, that the drawing
   // has completed. Else you get surprising empty layers on races.
   // Also we must remove it from our resources, otherwise we might die
   // early and try to finalize, though we don't own it anymore.
   //
   [self barrier];

   // since the renderLayer will be soon acquired (hopefully) by the refresher
   // thread, we have to temporarily forget about it as a resource we would
   // want to finalize. Will be readded on demand by
   // -repossessRenderedFramebuffer
   //

   // no longer a resource!
   [self _removeResourceForKey:(MulleUIResourceStorageKey_t) framebuffer];

   _CGImageLogVerbose( framebuffer, "%#@ provides framebuffer", self);

   if( ! _MulleObjCRecycleObjectAtomically( &_drawnRenderedFramebuffer, framebuffer))
   {
      // someone produced a _drawnRenderedFramebuffer already (but who ?)
      // can't happen since we are single threaded and zeroed it
      // in #573: old = _MulleObjCAcquireObjectAtomically( &_drawnRenderedFramebuffer);
#ifdef DEBUG
      abort();
#endif
      // turn it back into a resource and get rid of it
      [self _assignResource:framebuffer
                     forKey:(MulleUIResourceStorageKey_t) framebuffer];
   }
}


//
// get a framebuffer from an inside source back
//
- (void) recycleRenderedFramebuffer:(id) framebuffer
{
#ifndef MULLE_TEST
   assert( ! isAccessFromOtherThread( self, NO));
#endif

   if( ! framebuffer)
      return;

   CGImageLogVerbose( framebuffer, "%#@ recycles framebuffer", self);

   [self _removeResourceForKey:(MulleUIResourceStorageKey_t) framebuffer];
   if( ! _MulleObjCRecycleObjectAtomically( &_scratchRenderedFramebuffer, framebuffer))
   {
      // running thread gained access back
      // scratchLayer was already occupied...
      //
      // the framebuffer is now autoreleased again, but possibly in the wrong
      // thread, so it would be bad if it -finalized there.
      // The following method will relinquish the framebuffer again and
      // queue the framebuffer for finalization in our thread.
      //
      [self queueRenderedFramebufferForDeletion:framebuffer];
   }
}


//
// this is only to be used by the proper context, whereas
// -acquireRenderedFramebuffer and -recycleAcquiredRenderedFramebuffer are "foreign" context
// methods
//
- (id) repossessRenderedFramebuffer
{
   id   framebuffer;

   assert( ! isAccessFromOtherThread( self, NO));

   framebuffer = _MulleObjCAcquireObjectAtomically( &_scratchRenderedFramebuffer);
   if( framebuffer)
   {
      // turn back into a resource for us
      [self _assignResource:framebuffer
                     forKey:(MulleUIResourceStorageKey_t) framebuffer];
   }

   assert( ! framebuffer || [framebuffer context] == self);

   _CGImageLogVerbose( framebuffer, "%#@ repossesses framebuffer", self);
   return( framebuffer);
}

#pragma mark - support for getting rid of framebuffers "in limbo"

- (void) deleteRenderedFramebuffers
{
   CGFramebuffer   *framebuffer;

   // no callbacks in the locked code so no need to copy
   mulle_thread_mutex_do( _deletedFramebuffersLock)
   {
      mulle__pointerarray_for( &_deletedFramebuffers, framebuffer)
      {
         [framebuffer mulleGainAccess];

         // turn it back into a resource (so we get proper callback)
         // we don't want a duplicate didAddToContect: callback though
         [self _assignResource:framebuffer
                        forKey:(MulleUIResourceStorageKey_t) framebuffer];
         _CGImageLogVerbose( framebuffer, "%#@ finalizes framebuffer", self);
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
- (void) queueRenderedFramebufferForDeletion:(CGFramebuffer *) framebuffer
{
   if( ! framebuffer)
      return;

   _CGImageLogVerbose( framebuffer, "%#@ queues framebuffer for finalization/release", self);

   mulle_thread_mutex_do( _deletedFramebuffersLock)
   {
      // put it in limbo, so we can gainAccess properly when deleting
      [framebuffer mulleRelinquishAccess];
      _mulle__pointerarray_add( &_deletedFramebuffers,
                                framebuffer,
                                MulleObjCInstanceGetAllocator( self));
   }
}


//
// this is supposed to be called from -finalize
//
- (void) queueScratchAndDrawnRenderedFramebuffersForDeletion

{
   CGFramebuffer  *framebuffer;

   //
   // move these directly into the _deletedFramebuffers as they are in
   // limbo and will be in limbo there
   //
   mulle_thread_mutex_do( _deletedFramebuffersLock)
   {
      // the _drawnRenderedFramebuffer does not belong to us as resource anymore
      framebuffer = _mulle_atomic_pointer_read( &_drawnRenderedFramebuffer);
      framebuffer = __mulle_atomic_pointer_cas( &_drawnRenderedFramebuffer, NULL, framebuffer);

      if( framebuffer)
      {
         _CGImageLogVerbose( framebuffer, "queue drawnLayer for deletion");
         _mulle__pointerarray_add( &_deletedFramebuffers,
                                   framebuffer,
                                   MulleObjCInstanceGetAllocator( self));
      }

      framebuffer = _mulle_atomic_pointer_read( &_scratchRenderedFramebuffer);
      framebuffer = __mulle_atomic_pointer_cas( &_scratchRenderedFramebuffer, NULL, framebuffer);
      if( framebuffer)
      {
         _CGImageLogVerbose( framebuffer, "queue _scratchRenderedFramebuffer for deletion");
         _mulle__pointerarray_add( &_deletedFramebuffers,
                                   framebuffer,
                                   MulleObjCInstanceGetAllocator( self));
      }
   }
}



//////


CGPixelSize
   CGContextBitmapSizeOfFramebuffer( CGContext *self,
                                     struct CGContextFramebuffer fb)
{
   return( [self bitmapSizeOfFramebuffer:fb]);
}




// - (MulleTextureImage *) framebufferImageWithPixelSize:(struct CGBitmapInfo) size
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

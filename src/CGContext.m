#import "import-private.h"

#import "CGContext.h"

#import "CGLayoutContext+CGFont.h"
#import "CGContext+DebugPrivate.h"
#import "CGContext+OpenGL.h"
#import "CGContext+nanovg.h"
#import "CGContext+Drawing.h"
#import "CGContext+Shader.h"
#import "CGContext+Texture.h"
#import "CGContext+CGFramebuffer.h"
#import "CGImage.h"
#import "CGImage+DebugPrivate.h"
#import "CGFramebuffer.h"

#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>


@interface CGContext( Private)

- (void) deleteTextureIDs;
- (void) deleteGPUFramebuffers;
- (void) deleteRenderedFramebuffers;
- (void) queueScratchAndDrawnRenderedFramebuffersForDeletion;

@end


@implementation NSObject( CGContext)

- (BOOL) __isCGContext
{
   return( NO);
}

@end


//
// there shall be no OpenGL calls or constants here. Just nanovg stuff
//
@implementation CGContext

- (BOOL) __isCGContext
{
   return( YES);
}

static struct
{
   mulle_thread_mutex_t                      _freeTypeLock;
   struct mulle_container_keyvaluecallback   _gpuTextureMapCallback;
   struct mulle_container_keyvaluecallback   _shaderMapCallback;
   NSUInteger                                _contextID; // unsafe but just for debugging
   NSUInteger                                _debuggingFlags;
} Self;


+ (void) initialize
{
   // don't rerun for subclass
   if( MulleObjCClassGetID( self) != @selector( CGContext))
      return;

   mulle_thread_mutex_init( &Self._freeTypeLock);

   Self._gpuTextureMapCallback.keycallback   = mulle_container_keycallback_nonowned_pointer;
   Self._gpuTextureMapCallback.valuecallback = mulle_container_valuecallback_nonowned_pointer;

   Self._shaderMapCallback.keycallback       = mulle_container_keycallback_copied_cstring;
   Self._shaderMapCallback.valuecallback     = mulle_container_valuecallback_intptr;
}


+ (void) deinitialize
{
   if( MulleObjCClassGetID( self) != @selector( CGContext))
      return;

   mulle_thread_mutex_done( &Self._freeTypeLock);
}


//
// we change the strategy here, so another thread can acquire the layers
// But the owning thread has to close it down, so we do change the thread
// ownership of the
- (MulleObjCTAOStrategy) mulleTAOStrategy
{
   return( MulleObjCTAOReceiverPerformsFinalize);
}


- (instancetype) init
{
   abort();
}


//
// due to freetype being singlethreaded (mostly ?) the nvgCreate routines
// need to run locked so only one thread can create a NVG context at the
// same time. The same probably has to be done for every font load  ?
//
- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) osContext
                            nameUTF8String:(char *) nameUTF8String
                                   shareID:(NSUInteger) shareID
                                   options:(UIGraphicsOptions) options
{
   struct mulle_allocator   *allocator;

   _backend = [osContext backend];
   _shareID = shareID;

   // do this early
   _debuggingFlags = [[self class] debuggingFlags];
   _contextID      = ++Self._contextID;

   if( _backend != UIGraphicsBackendNone)
   {
      mulle_thread_mutex_do( Self._freeTypeLock)
      {
         [self _initNanoVGWithGraphicsOptions:options];
      }

      if( ! _vg)
      {
         fprintf( stderr, "Could not create nanovg context\n");
         [self release];
         return( nil);
      }
   }

   // do this now to get CGContextLayout
   self = [self initWithOSGraphicsContext:osContext
                           nameUTF8String:nameUTF8String];

   if( self)
   {
      allocator = MulleObjCInstanceGetAllocator( self);
      mulle_thread_mutex_init( &_deletedFramebuffersLock);
      _mulle__pointerarray_init( &_deletedTextureIDs, 0, allocator);
      mulle_thread_mutex_init( &_deletedGPUFramebuffersLock);
      _mulle__pointerarray_init( &_deletedGPUFramebuffers, 0, allocator);
      _mulle__pointerarray_init( &_deletedFramebuffers, 0, allocator);
      // this is merely there to provide a mapping, it doesn't own the CGImage
      _mulle_map_init( &_gpuTextureMap, 0, &Self._gpuTextureMapCallback, allocator);

      // this is a way to rendezvous to exisiting shaders by name
      _mulle_map_init( &_shaderMap, 0, &Self._shaderMapCallback, allocator);
   }

   return( self);
}


- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) osContext
                                   shareID:(NSUInteger) shareID
                                   options:(UIGraphicsOptions) options
{
   return( [self initWithOSGraphicsContext:osContext
                            nameUTF8String:NULL
                                   shareID:shareID
                                   options:options]);
}


- (void) finalize
{
   // do this first as it releases resource, which still want
   // nanovg arounf
   [super finalize];

   if( _backend != UIGraphicsBackendNone)
   { 
      if( ! _vg)  // we died super early, so nothing to do
         return;

      assert( ! _isRendering);
   }

   CGContextLog("");

   [self _resetFontCache];

   [self queueScratchAndDrawnRenderedFramebuffersForDeletion];
   [self deleteRenderedFramebuffers];
   [self deleteTextureIDs];
   [self deleteGPUFramebuffers];
   [self deleteShaders];

   // so the problem here is, we are rele
   if( _backend != UIGraphicsBackendNone)
   {
      mulle_thread_mutex_do( Self._freeTypeLock)
      {
         [self _finalizeNanoVG];
      }
   }
}


- (void) dealloc
{
   struct mulle_allocator   *allocator;

   CGContextLog("");

   assert( ! _mulle_atomic_pointer_read( &_drawnRenderedFramebuffer));
   assert( ! _mulle_atomic_pointer_read( &_scratchRenderedFramebuffer));

   // images in _gpuTextureMap aren't retained just blow map away
   mulle_map_done( &_gpuTextureMap);
   mulle_map_done( &_shaderMap);

   allocator = MulleObjCInstanceGetAllocator( self);
   _mulle__pointerarray_done( &_deletedFramebuffers, allocator);
   _mulle__pointerarray_done( &_deletedGPUFramebuffers, allocator);
   mulle_thread_mutex_done( &_deletedGPUFramebuffersLock);
   _mulle__pointerarray_done( &_deletedTextureIDs, allocator);
   mulle_thread_mutex_done( &_deletedFramebuffersLock);

   [super dealloc];
}



#ifdef DEBUG
- (void) mulleGainAccess
{
   [super mulleGainAccess];

   // renderedFramebuffers are in limbo, let them stay like these
}


- (void) mulleRelinquishAccess
{
   // renderedFramebuffers are in limbo, let them stay like these

   [super mulleRelinquishAccess];
}
#endif


/*
 * petty accessors
 */
- (struct CGFrameInfo *) currentFrameInfo
{
   return( _isRendering ? &_currentFrameInfo : NULL);
}


//
// used by CGFramebuffer. This can hit us if no frame has been rendered, as
// we might be drawing CGLayers before hand
//
- (void) getCurrentFrameInfo:(struct CGFrameInfo *) info
{
   assert( info);

   if( _isRendering)
   {
      assert( _currentFrameInfo.window.pixelRatio);  // not yet initialized!!
      *info = _currentFrameInfo;
   }
   else
      memset( info, 0, sizeof( *info));
}


- (CGFloat) alpha
{
   return( _currentFrameInfo.alpha);
}


- (CGShaderID) activeShader
{
   return( _activeShader);
}


- (NSUInteger) numberOfFrames
{
   return( _numberOfFrames);
}


- (mulle_relativetime_t) secondsSinceFirstRender
{
   return( _currentFrameInfo.now - _firstRenderTimeStamp);
}


- (char *) backendUTF8String
{
   return( UIGraphicsBackendUTF8String( _backend));
}


- (CGFloat) fontScale
{
   return( _currentFrameInfo.window.UIScale.dx * 1.35); // Still true ????
}


// support for some demos
// UIWindow needs styleMask | UIWindowStyleMousePolling set to fill this
// property
- (struct UIInputState) inputState
{
   return( _inputState);
}

- (CGPoint) mouseLocation
{
   return( _inputState.locationInWindow);
}


- (NSUInteger) keyModifiers
{
   return( _inputState.keyModifiers);
}


- (NSUInteger) buttonStates
{
   return( _inputState.buttonStates);
}


- (BOOL) isInitializedFramebuffer
{
   return( (BOOL) (uintptr_t) _mulle_atomic_pointer_read( &_atomicInitializedFramebuffer));
}


- (void) setInitializedFramebuffer:(BOOL) flag
{
   _mulle_atomic_pointer_write( &_atomicInitializedFramebuffer, (void *) (uintptr_t) flag);
}


@end

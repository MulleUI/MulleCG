   #import "import-private.h"

#import "CGContext.h"

#import "CGLayoutContext+CGFont.h"
#import "CGContext+DebugPrivate.h"
#import "CGContext+OpenGL.h"
#import "CGContext+Drawing.h"
#import "CGContext+Shader.h"
#import "CGContext+Shader.h"
#import "CGContext+Texture.h"
#import "CGImage.h"
#import "CGFramebuffer.h"

#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>


@interface CGContext( Private)

- (void) deleteTextureIDs;
- (void) deleteGPUFramebuffers;
- (void) deleteFramebuffers;

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



//
// due to freetype being singlethreaded (mostly ?) the nvgCreate routines
// need to run locked so only one thread can create a NVG context at the
// same time. The same probably has to be done for every font load  ?
//
- (id) initWithBackend:(UIGraphicsBackend) backend
               shareID:(NSUInteger) shareID
               options:(UIGraphicsOptions) options
{
   struct mulle_allocator   *allocator;

   _backend      = backend;
   _shareID      = shareID;

   // do this early
   _debuggingFlags = [[self class] debuggingFlags];

   if( backend != UIGraphicsBackendNone)
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
   self = [super init];
   if( self)
   {
      allocator = MulleObjCInstanceGetAllocator( self);
      mulle_thread_mutex_init( &_deletedFramebufferLock);
      _mulle__pointerarray_init( &_deletedTextureIDs, 0, allocator);
      _mulle__pointerarray_init( &_deletedGPUFramebuffers, 0, allocator);
      _mulle__pointerarray_init( &_deletedFramebuffers, 0, allocator);
      // this is merely there to provide a mapping, it doesn't own the CGImage
      _mulle_map_init( &_gpuTextureMap, 0, &Self._gpuTextureMapCallback, allocator);

      // this is a way to rendezvous to exisiting shaders by name
      _mulle_map_init( &_shaderMap, 0, &Self._shaderMapCallback, allocator);
   }

   return( self);
}


- (void) finalize
{
   CGFramebuffer   *framebuffer;
   CGContext       *context;

   if( _backend != UIGraphicsBackendNone)
   { 
      if( ! _vg)  // we died super early, so nothing to do
      {
         [super finalize];
         return;
      }

      assert( _activeThread == [NSThread currentThread]);
      assert( ! _isRendering);
   }

   CGContextLog("");

   [self _resetFontCache];
   [self _finalizeResourceStorage:&_resourceStorage];

   CGContextLog( "autorelease offScreenFramebuffer");

   framebuffer = _mulle_atomic_pointer_read( &_drawnLayer);
   framebuffer = __mulle_atomic_pointer_cas( &_drawnLayer, NULL, framebuffer);
   // context is probably already zeroed or ? by who ? _finalizeResourceStorage ?
   context     = [framebuffer context];
   assert( ! context || context == self);
   MULLE_C_UNUSED( context);

   [framebuffer mullePerformFinalize];
   [framebuffer autorelease];

   framebuffer = _mulle_atomic_pointer_read( &_scratchLayer);
   framebuffer = __mulle_atomic_pointer_cas( &_scratchLayer, NULL, framebuffer);
   context     = [framebuffer context];
   assert( ! context || context == self);
   MULLE_C_UNUSED( context);

   [framebuffer mullePerformFinalize];
   [framebuffer autorelease];

   [self deleteFramebuffers];
   [self deleteTextureIDs];
   [self deleteGPUFramebuffers];
   [self deleteShaders];

   if( _backend != UIGraphicsBackendNone)
   {
      mulle_thread_mutex_do( Self._freeTypeLock)
      {
         [self _finalizeNanoVG];
      }
   }

   [super finalize];
}


- (void) dealloc
{
   struct mulle_allocator   *allocator;
   CGFramebuffer            *framebuffer;

   CGContextLog("");

   // this oughta be superflous, as they should be nil because of
   // -finalize
   framebuffer = _mulle_atomic_pointer_read( &_drawnLayer);
   [framebuffer release];

   framebuffer = _mulle_atomic_pointer_read( &_scratchLayer);
   [framebuffer release];

   // images in _gpuTextureMap aren't retained just blow map away
   mulle_map_done( &_gpuTextureMap);
   mulle_map_done( &_shaderMap);

   allocator = MulleObjCInstanceGetAllocator( self);
   _mulle__pointerarray_done( &_deletedFramebuffers, allocator);
   _mulle__pointerarray_done( &_deletedGPUFramebuffers, allocator);
   _mulle__pointerarray_done( &_deletedTextureIDs, allocator);
   mulle_thread_mutex_done( &_deletedFramebufferLock);

   [super dealloc];
}


/*
 * petty accessors
 */

- (BOOL) isRendering
{
   return( _isRendering);
}


- (BOOL) isActive
{
   return( _activeThread != nil);
}


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


/*
 * render
 */
- (void) _beginNestedRender:(struct CGFrameInfo *) info
{
}


- (CGFramebuffer *) framebufferWithSize:(CGPixelSize) size
                           textureFlags:(NSUInteger) textureFlags
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
                                                      context:self];
      CGContextLogVerbose( "created new framebuffer %#@ with size %s",
                           framebuffer,
                           CGPixelSizeUTF8String( size));
   }
   else
   {
      CGContextLogVerbose( "reused framebuffer %#@ with size %s",
                           framebuffer,
                           CGPixelSizeUTF8String( size));
   }
   return( framebuffer);
}


- (void) beginRender:(struct CGFrameInfo *) info
{
   NSUInteger   textureFlags;

   assert( ! _isRendering);

   // not 100% sure why this is written this way
   _isRendering = YES;

   assert( _activeThread == [NSThread currentThread]);
   assert( info);
   assert( info->window.pixelRatio != 0.0);

   CGContextRenderLog( "Viewport: %s, FB: %s, Window: %s",
                 CGPixelRectUTF8String( info->viewportFrame),
                 CGPixelSizeUTF8String( info->window.framebufferSize),
                 CGSizeUTF8String( info->window.frame.size));

   // not 100% sure why this is written this way

   _currentFrameInfo = *info;

   if( _firstRenderTimeStamp == 0.0)
      _firstRenderTimeStamp = _currentFrameInfo.now;

   // sets opengl viewport and a beginFrame for nanovg
   [self resumeRender];

   // now vg calls can happen

   // delete all queued for deletion framebuffers and textureIDs
   [self deleteFramebuffers];
   [self deleteGPUFramebuffers];
   [self deleteTextureIDs];

   CGContextCheckBackendError( self, "delete textureIDs");

   // create or reuse existing offscreen framebuffer
   if( _rendersOffScreen)
   {
      // will acquire hopefully a preexisting framebuffer for reuse
      assert( ! _renderLayer);

      textureFlags = ( _nvgFlags & NVG_IMAGE_MSAA) ? NVG_MSAA : 0;
      _renderLayer = [[self framebufferWithSize:info->window.framebufferSize
                                   textureFlags:textureFlags] retain];
      assert( _renderLayer);
#ifdef DEBUG
      if( ! [_renderLayer debugNameUTF8String])  // keep old if present
      {
         char   buf[ 256];
         static NSUInteger   counter;  // just for debugging

         mulle_snprintf( buf, sizeof( buf), "RenderFrame #%td (%p)", counter++, self);
         [_renderLayer setDebugNameUTF8String:buf];
      }
#endif
      CGContextRenderLog( "Begin render into layer %#@", _renderLayer);
      [self bindFramebuffer:CGContextFramebufferMakeWithLayer( _renderLayer)];
   }
}


static struct CGFrameInfo   emptyInfo;


- (struct CGFrameInfo) bindRender:(struct CGFrameInfo *) info
{
   struct CGFrameInfo   old;

   assert( info);

   if( ! _isRendering)
   {
      [self beginRender:info];
      return( emptyInfo);
   }

   if( ! info->window.pixelRatio)
   {
      [self endRender];
      return( emptyInfo);
   }

   old = _currentFrameInfo;
   [self changeRender:info];

   return( old);
}


- (void) suspendRender
{
   assert( _activeThread == [NSThread currentThread]);

   CGContextRenderLog( "");
   // MEMO: this also flushes the font cache, not sure if this desirable or
   //       necessary or too painful ??
   //
   // We could write a simpler:
   //
   // void nvgFlushFrame(NVGcontext* ctx)
   // {
   //    ctx->params.renderFlush(ctx->params.userPtr);
   // }
   //
   CGContextCheckBackendError( self, "before nvgEndFrame");

   nvgEndFrame( _vg);

   CGContextCheckBackendError( self, "nvgEndFrame");
}


- (void) _endRender
{
   CGFramebuffer   *old;

   assert( _isRendering);

   CGContextRenderLog( "");

   _isRendering = 0;
   _numberOfFrames++;

   /*
    * return to default, for unbinding YES or NO makes no difference
    */
   [self bindFramebuffer:CGContextFramebufferMakeDefault()];
   CGContextCheckBackendError( self, "unbind buffer");

   if( _rendersOffScreen)
   {
      // get rid of old "valid" framebuffer previously, if still present
      old = _MulleObjCAcquireObjectAtomically( &_drawnLayer);
      if( old)
      {
         CGContextRenderLog( "Recycle scratch %#@ for %#@", _scratchLayer, old);
         assert( [old context] == self);
         if( ! _MulleObjCRecycleObjectAtomically( &_scratchLayer, old))
         {
            //
            // this means old will get discarded int the context thread,
            // which is fine
            //
         }
      }

      // by recycling it in _drawnLayer we store it there, since
      // CGContext is the only one who is _supposed_ to write any NON-NULL value
      // into _drawnLayer, this can't fail, and if it does it gets
      // harmlessly reaped.
      //
      // Before making it available to other contexts
      // possibly, we need to put up a barrier to ensure, that the drawing
      // has completed. Else you get surprising empty layers on races.
      //
      [self barrier];
      if( ! _MulleObjCRecycleObjectAtomically( &_drawnLayer, _renderLayer))
      {
         // someone produced a _drawnLayer already (but who ?)
         // can't happen since we are single threaded and zeroed it
         // in #573: old = _MulleObjCAcquireObjectAtomically( &_drawnLayer);
#ifdef DEBUG
         abort();
#endif
      }

      if( self->_debuggingFlags & CGContextDebugDumpFrameToFile)
      {
         MulleUIWriteImageToPNGFileSequenceAsync( _renderLayer, "render-layer");
      }

      CGContextRenderLog( "End render into layer %#@", _renderLayer);

      [_renderLayer autorelease];
      _renderLayer = nil;
   }

   // so if we rendered to the "window" framebuffer mark it as initialized
   if( _currentFramebuffer.type == CGContextDefaultFramebuffer ||
       _currentFramebuffer.type == CGContextDefaultMultiSampleFramebuffer)
   {
      _initializedFramebuffer = YES;
   }
}


- (void) endRender
{
   assert( _isRendering);

// draw a rectangle when in offscreen for debugging, this will be
// surrounded by a green rectangle on swap
   [self suspendRender];
   [self _endRender];
}


// flushes drawings doesn't reset glViewport or reset internal caches
- (void) flushRender
{
   // if there are no draw commands, this does nothing
   nvgFlushFrame( _vg);
}


/*
 * manage framebuffers
 */
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

   assert( _activeThread == [NSThread currentThread]);

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
      nvgluBindFramebuffer( NULL);
      CGContextCheckBackendError( self, "bind buffer");
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


- (BOOL) isInitializedFramebuffer
{
   switch( _currentFramebuffer.type)
   {
   default                         :
      return( _initializedFramebuffer);

   case CGContextLayerFramebuffer  :
   case CGContextLayerMultiSampleFramebuffer  :
      return( [(CGFramebuffer *) _currentFramebuffer.handle isInitializedFramebuffer]);

   case CGContextOpenGLFramebuffer :
   case CGContextOpenGLMultiSampleFramebuffer  :
      return( NO);
   }
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

   framebuffer = _MulleObjCAcquireObjectAtomically( &_drawnLayer);  // this calls -autorelease
   return( framebuffer);
}


- (id) acquireRecycledFramebuffer
{
   id   framebuffer;

   framebuffer = _MulleObjCAcquireObjectAtomically( &_scratchLayer);
   assert( ! framebuffer || [framebuffer context] == self);
   return( framebuffer);
}


// get a framebuffer from an outside source back
- (void) recycleFramebuffer:(id) framebuffer
{
   if( ! _MulleObjCRecycleObjectAtomically( &_scratchLayer, framebuffer))
   {
      //
      // scratchLayer was already occupied...
      // the framebuffer is now autoreleased but possibly in the wrong thread
      // the following method will relinquish the framebuffer again and
      // queue the framebuffer for deletion
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


// support for some demos
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


- (char *) UTF8String
{
   char   *s;

   s = MulleObjC_asprintf( "<%s %p: %@>",
                           MulleObjCInstanceGetClassNameUTF8String( self),
                           self,
                           _OSWindow);
   return( s);
}

@end

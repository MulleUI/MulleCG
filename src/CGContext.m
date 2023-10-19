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
#import "CGLayer.h"

#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>


@interface CGContext( Private)

- (void) deleteTextureIDs;
- (void) deleteFramebuffers;

@end


//#define CGCONTEXT_DEBUG_ENABLED 3


static void   *acquire_ivar_pointer( mulle_atomic_pointer_t *p)
{
   void   *value;
   void   *actual;

   value = _mulle_atomic_pointer_read( p);
   if( ! value)
      return( NULL);

   for(;;)
   {
      // zero out _drawnLayer if its contents are "layer"
      // don't zero on mismatch
      // return the actual contents of _drawnLayer (before zeroing)
      actual = __mulle_atomic_pointer_cas( p, NULL, value);
      if( ! actual || actual == value)
         return( actual);
      value = actual;
   }
}


static void   *acquire_ivar_object( mulle_atomic_pointer_t *p)
{
   id   obj;

   obj = acquire_ivar_pointer( p);
   // MulleUICLog( "Extracted %#@ from pointer %p, now nil", obj, p);
   return( [obj autorelease]);
}


static inline int   recycle_ivar_pointer( mulle_atomic_pointer_t *p, void *value)
{
   return( _mulle_atomic_pointer_cas( p, value, NULL));
}


static void   recycle_ivar_object( mulle_atomic_pointer_t *p, id obj)
{
   if( ! obj)
      return;

   [obj retain];
   if( ! recycle_ivar_pointer( p, obj))
   {
      //MulleUICLog( "Failed to store %#@ into pointer %p", obj, p);
      [obj release];  // if it fails, undo retain
   }
   else
   {
      //MulleUICLog( "Stored %#@ in pointer %p", obj, p);
   }
}


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
   struct mulle_container_keyvaluecallback   _shaderSourcesCallback;
   struct mulle_map                          _registeredSources;
   NSUInteger                                _debugEnabled;
} Self;


+ (void) initialize
{
   struct mulle_allocator   *allocator;
   char                     *s;

   // don't rerun for subclass
   if( MulleObjCClassGetID( self) != @selector( CGContext))
      return;

   mulle_thread_mutex_init( &Self._freeTypeLock);

   Self._gpuTextureMapCallback.keycallback   = mulle_container_keycallback_nonowned_pointer;
   Self._gpuTextureMapCallback.valuecallback = mulle_container_valuecallback_nonowned_pointer;

   Self._shaderMapCallback.keycallback       = mulle_container_keycallback_copied_cstring;
   Self._shaderMapCallback.valuecallback     = mulle_container_valuecallback_intptr;

   Self._shaderSourcesCallback.keycallback   = mulle_container_keycallback_copied_cstring;
   Self._shaderSourcesCallback.valuecallback = mulle_container_valuecallback_nonowned_pointer;

   allocator = MulleObjCClassGetAllocator( self);
   mulle_map_init( &Self._registeredSources, 0, &Self._shaderSourcesCallback, allocator);

   s = getenv( "CGContextDebugEnabled");
   if( s)
      Self._debugEnabled = strtol( s, NULL, 0);
   else
   {
#ifdef CGCONTEXT_DEBUG_ENABLED
      Self._debugEnabled = CGCONTEXT_DEBUG_ENABLED;
#endif
   }
}


+ (void) deinitialize
{
   if( MulleObjCClassGetID( self) != @selector( CGContext))
      return;

   mulle_thread_mutex_done( &Self._freeTypeLock);
   mulle_map_done( &Self._registeredSources);
}


+ (void) setDebugEnabled:(NSUInteger) flag
{
   Self._debugEnabled = flag;
}



static UIGraphicsBackend   defaultBackends[] =
{
   UIGraphicsBackendDefault,
   UIGraphicsBackendNone
};


+ (void) registerShaderSources:(struct CGShaderUTF8Sources *) sources
             forNameUTF8String:(char *) nameUTF8String
{
   UIGraphicsBackend   *backends;
   char                *key;
   char                *prefix;

   if( ! nameUTF8String)
      nameUTF8String = sources->name;

   assert( nameUTF8String);

   backends = sources->backends ? sources->backends : defaultBackends;

   mulle_buffer_do( buffer)
   {
      while( *backends != UIGraphicsBackendNone)
      {
         mulle_buffer_reset( buffer);
         prefix = UIGraphicsBackendUTF8String( *backends);
         assert( ! strcmp( prefix, "???"));

         mulle_buffer_sprintf( buffer, "%s__%s", prefix, nameUTF8String);
         key = mulle_buffer_get_string( buffer);
         mulle_thread_mutex_do( Self._freeTypeLock)
         {
            mulle_map_insert( &Self._registeredSources, key, sources);
         }
         ++backends;
      }
   }
}


+ (void) registerShaderSources:(struct CGShaderUTF8Sources *) sources
{
   [self registerShaderSources:sources
             forNameUTF8String:NULL];
}


- (struct CGShaderUTF8Sources *)
   registeredShaderSourcesForNameUTF8String:(char *) nameUTF8String
{
   struct CGShaderUTF8Sources   *sources;
   char                         *prefix;
   UIGraphicsBackend            *backends;
   auto UIGraphicsBackend       targetBackends[ 3] =
                                {
                                   [self backend],
                                   UIGraphicsBackendDefault,
                                   UIGraphicsBackendNone
                                };

   backends = targetBackends;
   mulle_buffer_do( buffer)
   {
      do
      {
         prefix = UIGraphicsBackendUTF8String( *backends);
         mulle_buffer_sprintf( buffer, "%s__%s", prefix, nameUTF8String);

         mulle_thread_mutex_do( Self._freeTypeLock)
         {
            sources = mulle_map_get( &Self._registeredSources, nameUTF8String);
         }
      }
      while( ! sources && *++backends != UIGraphicsBackendNone);
   }
   return( sources);
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
   _debugEnabled = Self._debugEnabled;

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
      _mulle__pointerarray_init( &_deletedTextureIDs, 0, allocator);
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
   if( _backend != UIGraphicsBackendNone)
   { 
      if( ! _vg)  // we died super early, so nothing to do
      {
         [super finalize];
         return;
      }

      assert( _isActive);
      assert( ! _isRendering);
   }

   CGContextLog("");

   [self _resetFontCache];
   [self _finalizeResourceStorage:&_resourceStorage];
   [self deleteTextureIDs];
   [self deleteFramebuffers];
   [self deleteShaders];

   CGContextLog( "autorelease offScreenFramebuffer");

   // by acquiring we nil and autorelease, which is what we want to do
   acquire_ivar_object( &_drawnLayer);
   acquire_ivar_object( &_scratchLayer);

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

   CGContextLog("");

   // images in _gpuTextureMap aren't retained just blow map away
   mulle_map_done( &_gpuTextureMap);
   mulle_map_done( &_shaderMap);

   allocator = MulleObjCInstanceGetAllocator( self);
   _mulle__pointerarray_done( &_deletedFramebuffers, allocator);
   _mulle__pointerarray_done( &_deletedTextureIDs, allocator);

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
   return( _isActive);
}


- (struct CGFrameInfo *) currentFrameInfo
{
   return( _isRendering ? &_currentFrameInfo : NULL);
}


//
// used by CGLayer. This can hit us if no frame has been rendered, as
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


- (CGLayer *) layerWithSize:(struct MulleIntegerSize) size
                textureFlags:(NSUInteger) textureFlags
{
   CGLayer                   *layer;
   struct MulleIntegerSize   oldSize;

   layer   = acquire_ivar_object( &_scratchLayer);
   CGContextLogVerbose( "try to reuse layer %#@", layer);
   oldSize = [layer bitmapSize];

   if( ! MulleIntegerSizeEqualToIntegerSize( oldSize, size))
   {
      layer = [CGLayer layerWithBitmapSize:size
                              textureFlags:textureFlags
                                   context:self];
      CGContextLogVerbose( "created new layer %#@ with size %s",
                           layer,
                           MulleIntegerSizeUTF8String( size));
   }
   else
   {
      CGContextLogVerbose( "reused layer %#@ with size %s",
                           layer,
                           MulleIntegerSizeUTF8String( size));
   }
   return( layer);
}


- (void) beginRender:(struct CGFrameInfo *) info
{
   NSUInteger   textureFlags;

   assert( ! _isRendering);

   // not 100% sure why this is written this way
   _isRendering = YES;

   assert( _isActive);
   assert( info);
   assert( info->window.pixelRatio != 0.0);

   CGContextRenderLog( "Viewport: %s, FB: %s, Window: %s",
                 MulleIntegerRectUTF8String( info->viewportFrame),
                 MulleIntegerSizeUTF8String( info->window.framebufferSize),
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
   [self deleteTextureIDs];
   CGContextCheckBackendError( self, "delete textureIDs");

   // create or reuse existing offscreen framebuffer
   if( _rendersOffScreen)
   {
      // will acquire hopefully a preexisting layer for reuse
      assert( ! _renderLayer);

      textureFlags = ( _nvgFlags & NVG_IMAGE_MSAA) ? NVG_MSAA : 0;
      _renderLayer = [[self layerWithSize:info->window.framebufferSize
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
   assert( _isActive);

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
   CGLayer   *old;

   assert( _isRendering);

   CGContextRenderLog( "");

   _isRendering = 0;
   _numberOfFrames++;

   /*
    * return to default, for unbinding YES or NO makes no difference
    */
   [self bindFramebuffer:CGContextFramebufferMakeDefault( NO)];
   CGContextCheckBackendError( self, "unbind buffer");

   if( _rendersOffScreen)
   {
      // get rid of old "valid" framebuffer previously, if still present
      old = acquire_ivar_object( &_drawnLayer);
      if( old)
      {
         CGContextRenderLog( "Recycle scratch %#@ for %#@", _scratchLayer, old);
         recycle_ivar_object( &_scratchLayer, old);
      }

      // by recycling it in _drawnLayer we store it there, since
      // CGContext is the only one who is _supposed_ to write any NON-NULL value
      // into _drawnLayer, this can't fail, and if it does it gets
      // harmlessly reaped.
      //
      // Before making it available to other contexts
      // possibly, we need to put up a barrier to ensure, that the drawing
      // has completed. Else you get surprising empty layers on races.
      [self barrier];
      recycle_ivar_object( &_drawnLayer, _renderLayer);

      if( self->_debugEnabled & CGContextDebugDumpFrameToFile)
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

   assert( _isActive);

   old = _currentFramebuffer;
   // the old layer should notice that its unbound to set its
   // initialized flag
   if( old.type == CGContextLayerFramebuffer
      || old.type == CGContextLayerMultiSampleFramebuffer)
   {
      [(CGLayer *) old.handle _unbindFromContext];  // nvg will restore
   }

   switch( fb.type)
   {
   case CGContextDefaultFramebuffer :
   case CGContextDefaultMultiSampleFramebuffer  :
      // this is GL on the "bottom" anyway
      nvgluBindFramebuffer( NULL);
      break;

   case CGContextLayerFramebuffer :
   case CGContextLayerMultiSampleFramebuffer  :
      [(CGLayer *) fb.handle _bindToContext];  // nvg will restore
      break;

   case CGContextOpenGLFramebuffer  :
   case CGContextOpenGLMultiSampleFramebuffer  :
      [self bindOpenGLFramebuffer:fb.handle];
      break;

   default :
      abort();
   }
   CGContextCheckBackendError( self, "bind buffer");

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
      return( [(CGLayer *) _currentFramebuffer.handle isInitializedFramebuffer]);

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
 * _scratchLayer. If there is no _scratchLayer a new CGLayer is
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
   return( acquire_ivar_object( &_drawnLayer));
}


// get a layer from an outside source back
- (void) recycleFramebuffer:(id) layer
{
   recycle_ivar_object( &_scratchLayer, layer);
}


- (id) acquireRecycledFramebuffer
{
   return( acquire_ivar_object( &_scratchLayer));
}


static struct MulleIntegerSize
   _CGContextBitmapSizeOfLayerFramebuffer( CGContext *self,
                                           struct CGContextFramebuffer fb)
{
   assert( fb.type == CGContextLayerFramebuffer
           || fb.type == CGContextLayerMultiSampleFramebuffer);
   return( [(CGLayer *) fb.handle bitmapSize]);
}


static struct MulleIntegerSize
   _CGContextBitmapSizeOfDefaultFramebuffer( CGContext *self,
                                             struct CGContextFramebuffer fb)
{
   struct CGFrameInfo   info;

   assert( fb.type == CGContextDefaultFramebuffer
           || fb.type == CGContextDefaultMultiSampleFramebuffer);
   [self getCurrentFrameInfo:&info];
   return( CGFrameInfoGetFramebufferSize( &info));
}


struct MulleIntegerSize
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

@end

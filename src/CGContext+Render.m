//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
#import "CGContext+Render.h"

#import "import-private.h"

#import "CGContext+OpenGL.h"
#import "CGContext+CGFramebuffer.h"
#import "CGContext+DebugPrivate.h"


@interface CGContext( OpenGLPrivate)

- (void) _changeRenderOpenGL:(struct CGFrameInfo *) info;

@end


@interface CGContext( Private)

- (void) deleteTextureIDs;
- (void) deleteGPUFramebuffers;
- (void) deleteFramebuffers;

@end


@implementation CGContext ( Render)

- (BOOL) isRendering
{
   return( _isRendering);
}


- (void) drawObjects:(struct mulle_pointerarray *) objects
{
   id <CGRenderObject>   obj;

   mulle_pointerarray_for( objects, obj)
   {
      [obj renderInContext:self];
   }
}


static struct CGFrameInfo   emptyInfo;


- (void) _beginNestedRender:(struct CGFrameInfo *) info
{
}



- (void) beginRender:(struct CGFrameInfo *) info
{
   NSUInteger   textureFlags;
   char         *nameUTF8String;

   assert( CGContextIsActiveInCurrentThread( self));

   assert( ! _isRendering);

   // not 100% sure why this is written this way
   _isRendering = YES;

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
   [self deleteGPUFramebuffers]; // after framebuffers
   [self deleteTextureIDs];

   CGContextCheckBackendError( self, "delete textureIDs");

   // create or reuse existing offscreen framebuffer
   if( _rendersOffScreen)
   {
      // will acquire hopefully a preexisting framebuffer for reuse
      assert( ! _renderLayer);

      textureFlags   = ( _nvgFlags & NVG_IMAGE_MSAA) ? NVG_MSAA : 0;
#ifdef DEBUG
      {
         static uintptr_t   counter;

         nameUTF8String = MulleObjC_asprintf( "RenderFrame #%td", counter++);
      }
#else
      nameUTF8String = NULL;
#endif
      _renderLayer   = [[self framebufferWithSize:info->window.framebufferSize
                                     textureFlags:textureFlags
                                   nameUTF8String:nameUTF8String] retain];
      assert( _renderLayer);
      CGContextRenderLog( "Begin render into layer %#@", _renderLayer);
      [self bindFramebuffer:CGContextFramebufferMakeWithFramebuffer( _renderLayer)];
   }
}


- (struct CGFrameInfo) bindRender:(struct CGFrameInfo *) info
{
   struct CGFrameInfo   old;

   assert( CGContextIsActiveInCurrentThread( self));
   assert( info);

   CGContextRenderLog( "");

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
      [self setInitializedFramebuffer:YES];
   }
}



// flushes drawings doesn't reset glViewport or reset internal caches
- (void) flushRender
{
   assert( CGContextIsActiveInCurrentThread( self));

   CGContextRenderLog( "");

   // if there are no draw commands, this does nothing
   nvgFlushFrame( _vg);
}


- (void) suspendRender
{
   assert( CGContextIsActiveInCurrentThread( self));

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


- (void) endRender
{
   assert( CGContextIsActiveInCurrentThread( self));
   assert( _isRendering);

   CGContextRenderLog( "");

// draw a rectangle when in offscreen for debugging, this will be
// surrounded by a green rectangle on swap
   [self suspendRender];
   [self _endRender];
}


//#define GL_GPU_MEM_INFO_TOTAL_AVAILABLE_MEM_NVX   0x9048
//#define GL_GPU_MEM_INFO_CURRENT_AVAILABLE_MEM_NVX 0x9049
- (void) changeRender:(struct CGFrameInfo *) info
{
   assert( CGContextIsActiveInCurrentThread( self));
   assert( info);

   CGContextRenderLog( "%s", CGFrameInfoUTF8String( info));
   _currentFrameInfo = *info;
   // wasn't initialized before so ignore
   if( _currentFrameInfo.window.pixelRatio == 0.0)
      return;

   assert( _isRendering);

   CGContextCheckBackendError( self, "before nvgChangeFrame");


   // MEMO: the gLViewPort should be done afterwards
   nvgChangeFrame( _vg, _currentFrameInfo.window.frame.size.width,
                        _currentFrameInfo.window.frame.size.height,
                        _currentFrameInfo.window.pixelRatio);
   CGContextCheckBackendError( self, "nvgChangeFrame");

   [self _changeRenderOpenGL:&_currentFrameInfo];
}


- (void) resumeRender
{
   assert( _isRendering);

   CGContextRenderLog( "");

   CGContextCheckBackendError( self, "before resumeRender");
   [self _changeRenderOpenGL:&_currentFrameInfo];

   nvgBeginFrame( _vg, _currentFrameInfo.window.frame.size.width,
                       _currentFrameInfo.window.frame.size.height,
                       _currentFrameInfo.window.pixelRatio);
   CGContextCheckBackendError( self, "nvgBeginFrame");
}


@end

//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
#import "CGContext+Render.h"

#import "import-private.h"

#import "CGContext+Drawing.h"
#import "CGContext+CGFramebuffer.h"
#import "CGContext+UIGraphicsDrawing.h"
#import "CGContext+DebugPrivate.h"


@interface CGContext( OpenGLPrivate)

- (void) _changeRenderGPU:(struct CGFrameInfo *) info;

@end


@interface CGContext( Private)

- (void) deleteTextureIDs;
- (void) deleteGPUFramebuffers;
- (void) deleteRenderedFramebuffers;

@end


@implementation CGContext ( Render)

- (BOOL) isRendering
{
   return( _isRendering);
}


- (void) renderObjects:(struct mulle_pointerarray *) objects
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

   MULLE_C_ASSERT( UIGraphicsContextTraceDrawCalls == CGContextDebugTraceDrawCalls);

   // doesn't stack
   if( (info->debuggingFlags | _debuggingFlags) & CGContextDebugTraceDrawCalls)
      CGContextTrace( self, stderr);

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
   [self deleteRenderedFramebuffers];
   [self deleteGPUFramebuffers]; // after framebuffers
   [self deleteTextureIDs];

   // create or reuse existing offscreen framebuffer
   if( _rendersOffScreen)
   {
      // will acquire hopefully a preexisting framebuffer for reuse
      assert( ! _renderFramebuffer);

      // Use the texture flags configured at context creation time.
      // When MSAA is enabled (_renderLayerTextureFlags has CGImageFlagMSAA),
      // we render into a multisampled FBO and resolve it in endRender before
      // handing the result to the display context. The resolve happens within
      // this context so no cross-context MSAA issues arise.
      textureFlags  = _renderLayerTextureFlags;
#if defined( DEBUG) || defined( MULLE_TEST)
      {
         static uintptr_t   counter;

         nameUTF8String = MulleObjC_asprintf( "RenderFrame #%td", counter++);
      }
#else
      nameUTF8String = NULL;
#endif
      _renderFramebuffer   = [[self framebufferWithSize:info->window.framebufferSize
                                           textureFlags:textureFlags
                                         nameUTF8String:nameUTF8String] retain];
      assert( _renderFramebuffer);
      CGContextRenderLog( "Begin render into layer %#@", _renderFramebuffer);
      [self bindFramebuffer:CGContextFramebufferMakeWithFramebuffer( _renderFramebuffer)];
   }
}


/*
 *
 */
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


- (CGFramebuffer *) _endRender
{
   CGFramebuffer   *framebuffer;

   assert( _isRendering);

   CGContextRenderLog( "");

   _isRendering = 0;
   _numberOfFrames++;

   /*
    * return to default, for unbinding YES or NO makes no difference
    */
   [self bindFramebuffer:CGContextFramebufferMakeDefault()];

   // so if we rendered to the "window" framebuffer mark it as initialized
   if( _currentFramebuffer.type == CGContextDefaultFramebuffer ||
       _currentFramebuffer.type == CGContextDefaultMultiSampleFramebuffer)
   {
      [self setInitializedFramebuffer:YES];
   }

   // just so you know, we usually don't return _renderFramebuffer
   assert( ! _renderFramebuffer || _rendersOffScreen);

   framebuffer = [_renderFramebuffer autorelease];
   _renderFramebuffer = nil;

   return( framebuffer);
}


- (void) endRender
{
   CGFramebuffer   *framebuffer;

   assert( CGContextIsActiveInCurrentThread( self));
   assert( _isRendering);

   CGContextRenderLog( "");

// draw a rectangle when in offscreen for debugging, this will be
// surrounded by a green rectangle on swap
   [self suspendRender];

   framebuffer = [self _endRender];

   // this doesn't stack
   if( (_currentFrameInfo.debuggingFlags | _debuggingFlags) & CGContextDebugTraceDrawCalls)
      CGContextTrace( self, NULL);

   if( framebuffer)
   {
      // Resolve MSAA framebuffer into a plain single-sample framebuffer before
      // handing it off. The blit happens within this context so no cross-context
      // MSAA restrictions apply. The original MSAA framebuffer is autoreleased
      // and cleaned up normally after this scope.
      if( [framebuffer isMultiSample])
         framebuffer = (CGFramebuffer *) [self resolveMultiSampleImage:framebuffer];

      if( self->_debuggingFlags & CGContextDebugDumpFrameToFile)
      {
         MulleUIWriteImageToPNGFileSequenceAsync( framebuffer, "render-layer");
      }

      CGContextRenderLog( "End render into layer %#@", framebuffer);
      [self provideRenderedFramebuffer:framebuffer];
   }
}

@end


// No-op stubs — overridden by CGContext(Errors) in MulleCGNanovgGL
@implementation CGContext( BackendErrors)

- (void) _checkBackendError:(char *) str
{
}

- (BOOL) resetBackendError
{
   return( NO);
}

@end


@implementation CGContext( RenderMultiSample)

- (CGImage *) resolveMultiSampleImage:(CGImage *) image
{
   NSUInteger                    textureFlags;
   CGFramebuffer                 *layer;
   struct CGContextFramebuffer   previous;

   CGContextRenderLog( "");

   assert( [image isMultiSample]);

   textureFlags  = [image textureFlags] & ~CGImageFlagMSAA;
   layer         = [CGFramebuffer framebufferWithBitmapSize:[image bitmapSize]
                                               textureFlags:textureFlags
                                             nameUTF8String:[image nameUTF8String]
                                                    context:self];

   previous = [self bindFramebuffer:CGContextFramebufferMakeWithFramebuffer( layer)];
   [self blitRect:CGRectMakeWithOriginAndSize( CGPointZero, [layer size])
            image:image
            scale:NO];
   [self bindFramebuffer:previous];

   return( layer);
}

@end

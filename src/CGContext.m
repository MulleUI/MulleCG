#import "import-private.h"

#import "CGContext.h"

#import "CGContext+CGFont.h"
#import "CGContext+OpenGL.h"
#import "CGContext+Resources.h"
#import "CGImage.h"
#import "CGLayer.h"

#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>


#define SWAP_DEBUG
#define RESIZE_DEBUG
#define RENDER_DEBUG
// this writes out a PNG for each frame
//#define RENDER_LAYER_DEBUG

@interface NSObject( ShareId)

- (NSInteger) shareId;

@end


static void   *acquire_ivar_pointer( mulle_atomic_pointer_t *p)
{
   void   *value;
   void   *actual;

   value = _mulle_atomic_pointer_read( p);
   if( ! value)
      return( value);

   for(;;)
   {
      // zero out _drawnLayer if its contents are "layer"
      // don't zero on mismatch
      // return the actual contents of _drawnLayer (before zeroing)
      actual = __mulle_atomic_pointer_cas( p, NULL, value);
      if( actual == NULL)
         return( value);
      value = actual;
   }
}


static void   *acquire_ivar_object( mulle_atomic_pointer_t *p)
{
   id   obj;

   obj = acquire_ivar_pointer( p);
   if( obj)
      MulleUICLog( "Extracted %#@ from pointer %p, now nil", obj, p);
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
      MulleUICLog( "Failed to store %#@ into pointer %p", obj, p);
      [obj release];  // if it fails, undo retain
   }
   else
   {
      MulleUICLog( "Stored %#@ in pointer %p", obj, p);
   }
}



//
// there shall be no OpenGL calls or constants here. Just nanovg stuff
//
@implementation CGContext

static struct
{
   mulle_thread_mutex_t                      _freeTypeLock;
   struct mulle_container_keyvaluecallback   _callback;
   char                                      _debugEnabled;
} Self;


+ (void) initialize
{
   char   *s;

   mulle_thread_mutex_init( &Self._freeTypeLock);

   Self._callback.keycallback   = mulle_container_keycallback_nonowned_pointer;
   Self._callback.valuecallback = mulle_container_valuecallback_nonowned_pointer;

   s = getenv( "CGContextDebugEnabled");
   if( s)
      Self._debugEnabled = (char) strtol( s, NULL, 0);}


+ (void) deinitialize
{
   mulle_thread_mutex_done( &Self._freeTypeLock);
}


+ (void) setDebugEnabled:(BOOL) flag
{
   Self._debugEnabled = flag;
}


/*
static void   assert_shader_compiler_errors( GLuint shader)
{
   GLint    success;
   GLchar   infoLog[1024];

   glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
   if( ! success)
   {
      glGetShaderInfoLog( shader, 1024, NULL, infoLog);
      fprintf( stderr, "ERROR::SHADER_COMPILATION_ERROR: %s\n", infoLog);
      abort();
   }
}

// stolen from : https://learnopengl.com/code_viewer_gh.php?code=src/4.advanced_opengl/9.2.geometry_shader_exploding/9.2.geometry_shader.gs
static char  geometryShaderSource[] =
"#version 330 core\n"
"layout (triangles) in;\n"
"layout (triangle_strip, max_vertices = 3) out;\n"
"\n"
"in VS_OUT {\n"
"    vec2 texCoords;\n"
"} gs_in[];\n"
"\n"
"out vec2 TexCoords;\n"
"\n"
"uniform float time;\n"
"\n"
"vec4 explode(vec4 position, vec3 normal)\n"
"{\n"
"    float magnitude = 2.0;\n"
"    vec3 direction = normal * ((sin(time) + 1.0) / 2.0) * magnitude;\n"
"    return position + vec4(direction, 0.0);\n"
"}\n"
"\n"
"vec3 GetNormal()\n"
"{\n"
"    vec3 a = vec3(gl_in[0].gl_Position) - vec3(gl_in[1].gl_Position);\n"
"    vec3 b = vec3(gl_in[2].gl_Position) - vec3(gl_in[1].gl_Position);\n"
"    return normalize(cross(a, b));\n"
"}\n"
"\n"
"void main() {\n"   _context = nil;
l_Position, normal);\n"
"    TexCoords = gs_in[1].texCoords;\n"
"    EmitVertex();\n"
"    gl_Position = explode(gl_in[2].gl_Position, normal);\n"
"    TexCoords = gs_in[2].texCoords;\n"
"    EmitVertex();\n"
"    EndPrimitive();\n"
"}\n"
;
*/

// due to freetype being singlethreaded (mostly ?) the nvgCreate routines
// need to run locked so only one thread can create a NVG context at the
// same time. The same probably has to be done for every font load  ?
//
- (id) initWithEdgeAntialiasing:(BOOL) edgeAntialiasing
              useStencilStrokes:(BOOL) useStencilStrokes
{
   struct mulle_allocator   *allocator;

   mulle_thread_mutex_lock( &Self._freeTypeLock);
   {
      [self _initBackendWithEdgeAntialiasing:edgeAntialiasing
                           useStencilStrokes:useStencilStrokes];
   }
   mulle_thread_mutex_unlock( &Self._freeTypeLock);

   if( ! _vg)
   {
      fprintf( stderr, "Could not create nanovg context\n");
      [self release];
      return( nil);
   }

   [self _initFontCache];

   allocator = MulleObjCInstanceGetAllocator( self);
   _mulle__pointerset_init( &_resources, 0, allocator);
   _mulle__pointerarray_init( &_deletedTexturedIDs, 0, allocator);

   mulle_set_init( &_loanedResources,
                   0,
                   &mulle_container_keycallback_nonowned_pointer,
                   allocator);

   // this is merely there to provide a mapping, it doesn't own the CGImage
   _mulle_map_init( &_gpuTextureMap, 0, &Self._callback, allocator);

   _debugEnabled = Self._debugEnabled;
   if( _debugEnabled)
      MulleUILog( "init");

   return( self);
}


- (void) finalize
{
   CGLayer   *layer;

   if( ! _vg)  // we died super early, so nothing to do
   {
      [super finalize];
      return;
   }
   assert( _isActive);
   assert( ! _isRendering);

   if( _debugEnabled)
      MulleUILogThisMethod();

   [self _resetFontCache];
   [self releaseAllLoanedResources];
   [self removeAllResources];
   [self deleteTextureIDs];

   if( _debugEnabled)
      MulleUILog( "autorelease offScreenFramebuffer");

   // by acquiring we nil and autorelease, which is what we want to do
   acquire_ivar_object( &_drawnLayer);
   acquire_ivar_object( &_scratchLayer);

   mulle_thread_mutex_lock( &Self._freeTypeLock);
   {
      [self _finalizeBackend];
   }
   mulle_thread_mutex_unlock( &Self._freeTypeLock);

   [super finalize];
}


- (void) dealloc
{
   struct mulle_allocator   *allocator;

   if( _debugEnabled)
      MulleUILogThisMethod();

   [self _doneFontCache];

   // images in _gpuTextureMap aren't retained just blow map away
   mulle_map_done( &_gpuTextureMap);
   mulle_set_done( &_loanedResources);

   allocator = MulleObjCInstanceGetAllocator( self);

   _mulle__pointerset_done( &_resources, allocator);
   _mulle__pointerarray_done( &_deletedTexturedIDs, allocator);

   [super dealloc];
}


- (struct NVGcontext *) nvgContext
{
   return( CGContextGetNVGContext( self));
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


// not really used
- (void) getCurrentFrameInfo:(struct CGFrameInfo *) info
{
   assert( info);
   assert( _currentFrameInfo.window.pixelRatio);  // not yet initialized!!
   assert( _isRendering);

   *info = _currentFrameInfo;
}


- (CGFloat) alpha
{
   return( _currentFrameInfo.alpha);
}


- (NSUInteger) numberOfRenderedFrames
{
   return( _numberOfRenderedFrames);
}


- (mulle_relativetime_t) secondsSinceFirstRender
{
   return( _currentFrameInfo.now - _firstRenderTimeStamp);
}


/*
 * render
 */
- (void) _beginNestedRender:(struct CGFrameInfo *) info
{
}


- (CGLayer *) layerWithSize:(struct CGBitmapSize) size
{
   CGLayer               *layer;
   struct CGBitmapSize   oldSize;

   layer   = acquire_ivar_object( &_scratchLayer);
   oldSize = [layer bitmapSize];

   if( ! CGBitmapSizeEqualToBitmapSize( oldSize, size))
   {
      layer = [CGLayer layerWithBitmapSize:size
                                imageFlags:0
                                   context:self];
#ifdef DEBUG
   {
      static NSUInteger   count;
      char                *s;

      s = MulleObjC_asprintf( "CGLayer-%tu", count++);
      [layer setDebugNameUTF8String:s];
   }
#endif
#ifdef RESIZE_DEBUG
      mulleui_log_object_method( self,
                                 (char *) __PRETTY_FUNCTION__,
                                 "created new layer %#@ with size %s",
                                 layer,
                                 CGBitmapSizeUTF8String( size));
#endif
   }
   else
   {
#ifdef RESIZE_DEBUG
      mulleui_log_object_method( self,
                                 (char *) __PRETTY_FUNCTION__,
                                 "reused layer %#@ with size %s",
                                 layer,
                                 CGBitmapSizeUTF8String( size));
#endif
   }
   return( layer);
}


- (void) beginRender:(struct CGFrameInfo *) info
{
   assert( ! _isRendering);

   // not 100% sure why this is written this way
   _isRendering = YES;

   assert( _isActive);
   assert( info);
   assert( info->window.pixelRatio != 0.0);

#ifdef RENDER_DEBUG
   mulleui_log_object_method( self,
                              (char *) __PRETTY_FUNCTION__,
                              "Viewport: %s, FB: %s, Window: %s",
                              CGBitmapRectUTF8String( info->viewportFrame),
                              CGBitmapSizeUTF8String( info->window.framebufferSize),
                              CGSizeUTF8String( info->window.frame.size));
#endif

   // not 100% sure why anymore this written this way

   _currentFrameInfo = *info;

   if( _firstRenderTimeStamp == 0.0)
      _firstRenderTimeStamp = _currentFrameInfo.now;

   // sets opengl viewport and a beginFrame for nanovg
   [self resumeRender];

   // now vg calls can happen

   // delete all queued for deletion textureIDs
   [self deleteTextureIDs];
   CGContextCheckBackendError( self, "delete textureIDs");

   if( _rendersOffScreen)
   {
      // will acuire hopefully a preexisting layer for reuse
      assert( ! _renderLayer);
      _renderLayer = [[self layerWithSize:info->window.framebufferSize] retain];
      // create or reuse existing offscreen framebuffer

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
   char      *s;

   assert( _isRendering);

#ifdef RENDER_DEBUG
   mulleui_log_object_method( self,
                              (char *) __PRETTY_FUNCTION__,
                              "");
#endif

   _isRendering = 0;
   _numberOfRenderedFrames++;

   [self bindFramebuffer:CGContextFramebufferMakeDefault()];
   CGContextCheckBackendError( self, "unbind buffer");

   if( _rendersOffScreen)
   {
      // get rid of old "valid" framebuffer previously
      old = acquire_ivar_object( &_drawnLayer);
      recycle_ivar_object( &_scratchLayer, old);

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

#ifdef RENDER_LAYER_DEBUG
      MulleUIWriteImageToPNGFileSequenceAsync( _renderLayer, "render-layer");
#endif

#ifdef SWAP_DEBUG
      mulleui_log_object_method( self,
                                 (char *) __PRETTY_FUNCTION__,
                                 "least recent layer %#@",
                                 _renderLayer);
#endif
      [_renderLayer autorelease];
      _renderLayer = nil;
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


// flushes drawings doesn't set glViewport
- (void) flushRender
{
   nvgFlushFrame( _vg);
}


- (void) resetTransform
{
   assert( _isRendering);

   nvgResetTransform( _vg);
}


- (void) resetScissor
{
   assert( _isRendering);

   nvgResetScissor( _vg);
}


/*
 * manage framebuffers
 */
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
   switch( fb.type)
   {
   case CGContextDefaultFramebuffer :
      // this is GL on the "bottom" anyway
      nvgluBindFramebuffer( NULL);
      break;

   case CGContextLayerFramebuffer :
      [(CGLayer *) fb.handle bindFramebuffer];  // nvg will restore
      break;

   case CGContextOpenGLFramebuffer  :
      [self bindOpenGLFramebuffer:fb.handle];
      break;

   default :
      abort();
   }
   CGContextCheckBackendError( self, "bind buffer");

   _currentFramebuffer = fb;

   return( old);
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
 * _scratchLayer. If that doesn't succeed it gets releases. If it does
 * the fine. The drawing part is done.
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


// - (MulleTextureImage *) framebufferImageWithBitmapSize:(struct CGBitmapInfo) size
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
//    _mulle_pointerarray_add( _layers, image);
//
//    return( image);
// }

@end

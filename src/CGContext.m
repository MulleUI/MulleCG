#define DEFINE_NANOVG_GL_IMPLEMENTATION

#import "import-private.h"

#import "CGContext.h"
#import "CGContext+CGFont.h"
#import "CGGeometry+UTF8String.h"
#import "CGImage.h"
#include <stdio.h>


@interface NSObject( ShareId)

- (NSInteger) shareId;

@end



#define HAVE_MEM_GRAPH

// #define RENDER_DEBUG

@implementation CGContext

static struct
{
   mulle_thread_mutex_t                      _freeTypeLock;
   struct mulle_container_keyvaluecallback   _callback;
   char                                      _debugEnabled;
} Self;


+ (void) initialize
{
   mulle_thread_mutex_init( &Self._freeTypeLock);

   Self._callback.keycallback   = mulle_container_keycallback_nonowned_pointer;
   Self._callback.valuecallback = mulle_container_valuecallback_nonowned_pointer;
}


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
                      os_window:(id) os_window
{
   int   flags;


   flags  = edgeAntialiasing ? NVG_ANTIALIAS : 0;
   flags |= useStencilStrokes ? NVG_STENCIL_STROKES : 0;
#ifdef DEBUG
   flags |= NVG_DEBUG;
#endif

   mulle_thread_mutex_lock( &Self._freeTypeLock);
   {
#ifdef NANOVG_GL3_IMPLEMENTATION
      _vg  = nvgCreateGL3( flags);
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
      _vg  = nvgCreateGLES2( flags);
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
      _vg  = nvgCreateGLES3( flags);
#endif
   }
   mulle_thread_mutex_unlock( &Self._freeTypeLock);

   if( ! _vg)
   {
      [self release];
      return( nil);
   }

   _os_window = os_window;

   [self _initFontCache];

   _mulle__pointerset_init( &_resources, 0, MulleObjCInstanceGetAllocator( self));
   _mulle__pointerarray_init( &_deletedTexturedIDs, 0, MulleObjCInstanceGetAllocator( self));

   mulle_set_init( &_loanedResources,
                    0,
                    &mulle_container_keycallback_nonowned_pointer,
                    MulleObjCInstanceGetAllocator( self));

   // this is merely there to provide a mapping, it doesn't own the CGImage
   _mulle_map_init( &_gpuTextureMap, 0, &Self._callback, MulleObjCInstanceGetAllocator( self));

   _debugEnabled = Self._debugEnabled;
   if( _debugEnabled)
      fprintf( stderr, "*** context %p: init\n", self);

   return( self);
}


- (void) finalize
{
   assert( _isActive);
   assert( ! _isRendering);

   if( _debugEnabled)
      fprintf( stderr, "*** context %p: finalize\n", self);

   [self _resetFontCache];
   [self releaseAllLoanedResources];
   [self removeAllResources];
   [self deleteTextureIDs];

   if( _offScreenFramebuffer)
   {
   	nvgluDeleteFramebuffer((NVGLUframebuffer *) _offScreenFramebuffer);
      _offScreenFramebuffer = NULL;
   }

   if( _debugEnabled)
      fprintf( stderr, "*** context %p: autorelease offScreenFramebufferImage %p\n", self, _offScreenFramebufferImage);
   [_offScreenFramebufferImage autorelease];
   _offScreenFramebufferImage = nil;

   mulle_thread_mutex_lock( &Self._freeTypeLock);
   {
#ifdef NANOVG_GL3_IMPLEMENTATION
   	nvgDeleteGL3( _vg);
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
	   nvgDeleteGLES2(_vg);
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
	   nvgDeleteGLES3(_vg);
#endif
   }
   mulle_thread_mutex_unlock( &Self._freeTypeLock);

   _vg = NULL;
   _os_window = NULL;

   [super finalize];
}


- (void) dealloc
{
   if( _debugEnabled)
      fprintf( stderr, "*** context %p: dealloc\n", self);

   [self _doneFontCache];

   // images in _gpuTextureMap aren't retained just blow map away
   mulle_map_done( &_gpuTextureMap);
   mulle_set_done( &_loanedResources);
   _mulle__pointerset_done( &_resources, MulleObjCInstanceGetAllocator( self));
   _mulle__pointerarray_done( &_deletedTexturedIDs, MulleObjCInstanceGetAllocator( self));

   [super dealloc];
}


- (struct NVGcontext *) nvgContext
{
   return( CGContextGetNVGContext( self));
}


- (void) clearFramebuffer
{
   CGFloat   rgba[ 4];

   CGColorGetComponents( _backgroundColor, rgba);
   glClearColor( rgba[ 0], rgba[ 1], rgba[ 2], rgba[ 3]);
   glClear( GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
}


#define GL_GPU_MEM_INFO_TOTAL_AVAILABLE_MEM_NVX   0x9048
#define GL_GPU_MEM_INFO_CURRENT_AVAILABLE_MEM_NVX 0x9049


- (void) changeRender:(struct CGFrameInfo *) info 
                alpha:(CGFloat) alpha
{
   assert( _isActive);
   assert( _isRendering);

   _currentFrameInfo = *info;
   _alpha            = alpha;

   nvgChangeFrame( _vg, _currentFrameInfo.size.width,
                        _currentFrameInfo.size.height,
                        _currentFrameInfo.pixelRatio);
   glViewport( _currentFrameInfo.viewportFrame.origin.x,
               _currentFrameInfo.viewportFrame.origin.y,
               _currentFrameInfo.viewportFrame.size.width,
               _currentFrameInfo.viewportFrame.size.height);
}


- (void) resumeRender
{
   assert( _isActive);
   assert( _isRendering);

   nvgBeginFrame( _vg, _currentFrameInfo.size.width,
                       _currentFrameInfo.size.height,
                       _currentFrameInfo.pixelRatio);
   glViewport( _currentFrameInfo.viewportFrame.origin.x,
               _currentFrameInfo.viewportFrame.origin.y,
               _currentFrameInfo.viewportFrame.size.width,
               _currentFrameInfo.viewportFrame.size.height);
}


- (void) prepareOffScreenFramebuffer:(CGFrameInfo *) info
{
   if( ! CGBitmapSizeEqualToSize( _offScreenFramebufferSize, info->framebufferSize))
   {
      if( _offScreenFramebuffer)
      	nvgluDeleteFramebuffer((NVGLUframebuffer *) _offScreenFramebuffer);

      if( _debugEnabled)
         fprintf( stderr, "*** context %p: autorelease offScreenFramebufferImage %p\n", self, _offScreenFramebufferImage);

      [_offScreenFramebufferImage autorelease];
      _offScreenFramebufferImage = nil;

      _offScreenFramebuffer = nvgluCreateFramebuffer( _vg,
                                                      (int) info->framebufferSize.width,
                                                      (int) info->framebufferSize.height,
                                                      0);
//      fprintf( stderr, "created new offscreen framebuffer\n");
      if( ! _offScreenFramebuffer)
         abort();
      _offScreenFramebufferSize = info->framebufferSize;
      // torch old FB, create new one
   }
   assert( _offScreenFramebuffer);
}


- (void) _beginNestedRender:(struct CGFrameInfo *) info
{
   assert( _isActive);
   assert( info);
   assert( info->pixelRatio != 0.0);

#if RENDER_DEBUG
   if( ! CGSizeEqualToSize( info->viewportFrame.size, info->framebufferSize) ||
       ! CGSizeEqualToSize( info->viewportFrame.size, info->size) ||
       ! CGSizeEqualToSize( info->framebufferSize, info->size))
      fprintf( stderr, "Viewport: %s, FB: %s, Window: %s\n",
               CGSizeUTF8String( info->viewportFrame.size),
               CGSizeUTF8String( info->framebufferSize),
               CGSizeUTF8String( info->size));
#endif

   _isRendering        = YES;
   // not 100% sure why anymore this written this way

   _currentFrameInfo = *info;
   _alpha            = 1.0;

   [self resumeRender];
}


- (void) beginRender:(struct CGFrameInfo *) info
{
   assert( ! _isRendering);

   // not 100% sure why anymore this written this way
   _lastRenderStartTime = _renderStartTime;
   _renderStartTime     = info->now;
   _frameDelta          = 0.0;
   if( _lastRenderStartTime == 0.0)
      _frameDelta = _renderStartTime - _lastRenderStartTime;


   [self _beginNestedRender:info];
   // now vg calls can happen

   // delete all queued textureIDs
   [self deleteTextureIDs];

   if( _rendersOffScreen)
   {
      [self prepareOffScreenFramebuffer:info];
      // create or reuse existing offscreen framebuffer
      nvgluBindFramebuffer( _offScreenFramebuffer);
   }
}


- (void) bindDefaultFramebuffer
{
   nvgluBindFramebuffer( _rendersOffScreen ? _offScreenFramebuffer : NULL);
}

- (mulle_timeinterval_t) renderStartTime
{
   return( _renderStartTime);
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
   nvgEndFrame( _vg);
}


- (void) _endRender
{
   assert( _isRendering);

   nvgluBindFramebuffer( NULL);
   _isRendering = NO;
}

- (void) _finishRender
{
   // copy over, but kill current to catch moar problems
   _lastFrameInfo = _currentFrameInfo;
   memset( &_currentFrameInfo, 0xAD, sizeof( _currentFrameInfo));
   _numberOfRenderedFrames++;
}


- (void) endRender
{
   assert( _isRendering);

   [self suspendRender];
   [self _finishRender];
   [self _endRender];
}


- (BOOL) isRendering
{
   return( _isRendering);
}


- (BOOL) isActive
{
   return( _isActive);
}


static inline BOOL   haveLastFrameInfo( CGContext *self)
{
   return( self->_lastFrameInfo.pixelRatio != 0.0);
}


- (struct CGFrameInfo *) lastFrameInfo
{
   return( haveLastFrameInfo( self) ? &_lastFrameInfo : NULL);
}


- (struct CGFrameInfo *) currentFrameInfo
{
   return( _isRendering ? &_currentFrameInfo : NULL);
}


- (void) _setCurrentFrameInfo:(struct CGFrameInfo *) info
{
   if( info)
      _currentFrameInfo = *info;
}

- (NSUInteger) numberOfRenderedFrames
{
   return( _numberOfRenderedFrames);
}


// not really used
- (void) getCurrentFrameInfo:(struct CGFrameInfo *) info
{
   assert( info);
   assert( _currentFrameInfo.pixelRatio);  // not yet initialized!!
   assert( _isRendering);

   *info = _currentFrameInfo;
}


- (void) resetTransform
{
   assert( _isRendering);

   nvgResetTransform( _vg);
}


- (void) deleteTextureIDs
{
   struct mulle__pointerarrayenumerator  rover;
   void                                  *imageID;

   rover = _mulle__pointerarray_enumerate( &_deletedTexturedIDs);
   while( _mulle__pointerarrayenumerator_next( &rover, &imageID))
      nvgDeleteImage( _vg, (int) (NSInteger) imageID);
   mulle__pointerarrayenumerator_done( &rover);

   _mulle__pointerarray_reset( &_deletedTexturedIDs);
}


- (struct CGFramebufferBitmap) grabFramebufferAtRect:(struct CGBitmapRect) rect
                                            inFlight:(BOOL) inFlight
                                           allocator:(struct mulle_allocator *) allocator;
{
   struct CGFramebufferBitmap   fb;

   fb.allocator        = allocator ? allocator : &mulle_default_allocator;

   fb.info.size.width  = rect.size.width;
   fb.info.size.height = rect.size.height;
   fb.info.encoding    = CGBitmapEncodingFlipYRGBABytes;

   fb.data.length = CGBitmapInfoGetLineLength( fb.info) * fb.info.size.height;
   fb.data.bytes  = mulle_allocator_malloc( fb.allocator, fb.data.length);


   glReadBuffer( inFlight ? GL_BACK : GL_FRONT);
   glReadPixels( (int) rect.origin.x, (int) rect.origin.y,
                 (int) fb.info.size.width,
                 (int) fb.info.size.height,
                 GL_RGBA,
                 GL_UNSIGNED_BYTE,
                 fb.data.bytes);
   // TODO: check OpenGL errors
   return( fb);
}


- (struct CGFramebufferBitmap) grabLastRenderedFramebuffer:(struct mulle_allocator *) allocator;
{
   struct CGBitmapRect    rect;
   struct CGFrameInfo    *info;

   rect.origin = CGBitmapPointMake( 0, 0);
   info = [self lastFrameInfo];
   if( info)
      rect.size = info->framebufferSize;
   return( [self grabFramebufferAtRect:rect
                              inFlight:NO
                             allocator:allocator]);
}


- (struct CGFramebufferBitmap) grabLastRenderedOffscreenFramebuffer:(struct mulle_allocator *) allocator
{
   struct CGFramebufferBitmap   fb;

   assert( ! _isRendering);  // bad bad bad

   if( ! _offScreenFramebuffer)
   {
      memset( &fb, 0, sizeof( fb));
      return( fb);
   }

   fb.allocator        = allocator ? allocator : &mulle_default_allocator;

   fb.info.size.width  = _offScreenFramebufferSize.width;
   fb.info.size.height = _offScreenFramebufferSize.height;
   fb.info.encoding    = CGBitmapEncodingFlipYRGBABytes;

   fb.data.length      = _offScreenFramebufferSize.width *
                         _offScreenFramebufferSize.height * 4;
   // implicity transparent background
   fb.data.bytes  = mulle_allocator_calloc( fb.allocator, 1, fb.data.length);

   nvgluBindFramebuffer( _offScreenFramebuffer);
   {
      // TODO: check return value or error or something
      glReadPixels( 0, 0,
                   _offScreenFramebufferSize.width,
                   _offScreenFramebufferSize.height,
                   GL_RGBA,
                   GL_UNSIGNED_BYTE,
                   fb.data.bytes);
   }
   nvgluBindFramebuffer( NULL);

   return( fb);
}


// TODO: move to category
- (CGImage *) framebufferImage
{
   int   imageID;

   if( ! _offScreenFramebuffer)
      return( nil);

   assert( ! _isRendering);

   if( ! _offScreenFramebufferImage)
   {
      imageID = ((NVGLUframebuffer *) _offScreenFramebuffer)->image;
      _offScreenFramebufferImage = [[CGImage alloc] initWithNVGImage:imageID
                                                          imageFlags:NVG_IMAGE_FLIPY
                                                             context:self];
      if( _debugEnabled)
         fprintf( stderr, "*** context %p: created offScreenFramebufferImage "
                          "CGImage %p (nvgImage %d)\n",
                          self, _offScreenFramebufferImage, imageID);
   }

   return( _offScreenFramebufferImage);
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
      fprintf( stderr, "*** context %p: removeAllResources\n", self);

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
      fprintf( stderr, "*** context %p: releaseAllLoanedResources\n", self);
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



//
// When a CGImage gets reaped by an NSAutoreleasePool the context may not
// be activated and it could be tricky to ascertain, that it isn't in use
// by another thread. So we queue these delete requests up
// TODO: may need to lock this... ?
- (void) deleteTextureID:(NSInteger) imageID
{
   _mulle__pointerarray_add( &_deletedTexturedIDs,
                             (void *) imageID,
                             MulleObjCInstanceGetAllocator( self));
}

@end

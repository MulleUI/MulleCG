#define DEFINE_NANOVG_GL_IMPLEMENTATION

#import "import-private.h"

#import "CGContext.h"
#import "CGContext+CGFont.h"
#import "CGGeometry+CString.h"
#include <stdio.h>


#define HAVE_MEM_GRAPH

// #define RENDER_DEBUG

@implementation CGContext

static struct
{
   mulle_thread_mutex_t   _freeTypeLock;
} Self;

+ (void) initialize
{
   mulle_thread_mutex_init( &Self._freeTypeLock);
}


+ (void) deinitialize
{
   mulle_thread_mutex_done( &Self._freeTypeLock);
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

   return( self);
}


- (void) finalize
{
   assert( _isActive);
   assert( ! _isRendering);

   [self _resetFontCache];
   [self removeAllResources];
   [self deleteTextureIDs];

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

   if( _offScreenFramebuffer)
   {
   	nvgluDeleteFramebuffer((NVGLUframebuffer *) _offScreenFramebuffer);
      _offScreenFramebuffer = NULL;
   }

   _vg = NULL;
   _os_window = NULL;

   [super finalize];
}


- (void) dealloc
{
   [self _doneFontCache];

   _mulle__pointerarray_done( &_deletedTexturedIDs, MulleObjCInstanceGetAllocator( self));
   _mulle__pointerset_done( &_resources, MulleObjCInstanceGetAllocator( self));

   [super dealloc];
}


- (struct NVGcontext *) nvgContext
{
   return( _vg);
}


- (void) clearFramebuffer
{
   CGFloat   rgba[ 4];

   assert( _isRendering);

   MulleColorGetComponents( _backgroundColor, rgba);
   glClearColor( rgba[ 0], rgba[ 1], rgba[ 2], rgba[ 3]);
   glClear( GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
}


#define GL_GPU_MEM_INFO_TOTAL_AVAILABLE_MEM_NVX   0x9048
#define GL_GPU_MEM_INFO_CURRENT_AVAILABLE_MEM_NVX 0x9049


- (void) resumeRender
{
   assert( _isActive);
   assert( _isRendering);

   glViewport( _currentFrameInfo.viewportFrame.origin.x,
               _currentFrameInfo.viewportFrame.origin.y,
               _currentFrameInfo.viewportFrame.size.width,
               _currentFrameInfo.viewportFrame.size.height);
   nvgBeginFrame( _vg, _currentFrameInfo.size.width,
                       _currentFrameInfo.size.height,
                       _currentFrameInfo.pixelRatio);
}


- (void) prepareOffScreenFramebuffer:(CGFrameInfo *) info
{
   if( ! CGBitmapSizeEqualToSize( _offScreenFramebufferSize, info->framebufferSize))
   {
      if( _offScreenFramebuffer)
      	nvgluDeleteFramebuffer((NVGLUframebuffer *) _offScreenFramebuffer);

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


- (void) deleteTextureIDs
{
   struct mulle__pointerarrayenumerator  rover;
   void                                  *textureID;

   rover = _mulle__pointerarray_enumerate( &_deletedTexturedIDs);
   while( _mulle__pointerarrayenumerator_next( &rover, &textureID))
         nvgDeleteImage( _vg, (int) (NSUInteger) textureID);
   mulle__pointerarrayenumerator_done( &rover);

   _mulle__pointerarray_reset( &_deletedTexturedIDs);
}


- (void) beginRender:(struct CGFrameInfo *) info
{
   double   t;
   GLint    value;
   
   assert( _isActive);
   assert( ! _isRendering);
   assert( info);
   assert( info->pixelRatio != 0.0);

   _isRendering     = YES;
   // not 100% sure why anymore this written this way
   _lastRenderStart = _renderStart;
   _renderStart     = mulle_timeinterval_now();
   _frameDelta      = 0.0;
   if( _lastRenderStart == 0.0)
      _frameDelta = _renderStart - _lastRenderStart;

   _currentFrameInfo = *info;
   _alpha            = 1.0;

   // delete all queued textureIDs
   [self deleteTextureIDs];

#if RENDER_DEBUG
   if( ! CGSizeEqualToSize( info->viewportFrame.size, info->framebufferSize) ||
       ! CGSizeEqualToSize( info->viewportFrame.size, info->size) ||
       ! CGSizeEqualToSize( info->framebufferSize, info->size))
      fprintf( stderr, "Viewport: %s, FB: %s, Window: %s\n",
               CGSizeUTF8String( info->viewportFrame.size),
               CGSizeUTF8String( info->framebufferSize),
               CGSizeUTF8String( info->size));
#endif
   // < performance measurement
   if( _rendersOffScreen)
   {
      [self prepareOffScreenFramebuffer:info];
      // create or reuse existing offscreen framebuffer
      nvgluBindFramebuffer( _offScreenFramebuffer);
   }
   [self resumeRender];
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


- (void) endRender
{
   assert( _isRendering);

   // copy over, but kill current to catch moar problems
   _lastFrameInfo = _currentFrameInfo;
   memset( &_currentFrameInfo, 0xAD, sizeof( _currentFrameInfo));

   [self suspendRender];
   nvgluBindFramebuffer( NULL);
   _numberOfRenderedFrames++;
   _isRendering = NO;
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
   // resources are not retained!
   _mulle__pointerset_insert( &_resources, resource, MulleObjCInstanceGetAllocator( self));
}


- (void) _removeFromResources:(id) resource
{
   _mulle__pointerset_remove( &_resources, resource, MulleObjCInstanceGetAllocator( self));
}


- (void) removeFromResources:(id) resource
{
   if( _mulle__pointerset_remove( &_resources, resource, MulleObjCInstanceGetAllocator( self)))
      [resource contextDidRemoveObject:self];
}


- (void) removeAllResources
{
   struct mulle__pointersetenumerator   rover;
   struct mulle__pointerset             tmp;
   id                                   resource;

   tmp = _resources;
   _mulle__pointerset_init( &_resources, 0, MulleObjCInstanceGetAllocator( self));

   rover = _mulle__pointerset_enumerate( &tmp);
   while( _mulle__pointersetenumerator_next( &rover, (void **) &resource))
      [resource contextDidRemoveObject:self];
   mulle__pointersetenumerator_done( &rover);

   _mulle__pointerset_done( &tmp, MulleObjCInstanceGetAllocator( self));
}


//
// When a CGImage gets reaped by an NSAutoreleasePool the context may not
// be activated and it could be tricky to ascertain, that it isn't in use
// by another thread. So we queue these delete requests up
// TODO: may need to lock this... ?
- (void) deleteTextureID:(NSUInteger) textureID
{
   _mulle__pointerarray_add( &_deletedTexturedIDs, 
                             (void *) textureID, 
                             MulleObjCInstanceGetAllocator( self));
}

@end

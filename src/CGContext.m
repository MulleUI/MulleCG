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
+ (char *) backendUTF8String
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   return( "OpenGL v3.0+");
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   return( "GLES v2.0+");
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   return( "GLES v3.2+");
#endif
   abort();
}


+ (enum CGContextBackend) backend
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   return( CG_GL3);
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   return( CG_GLES2);
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   return( CG_GLES3);
#endif
   abort();
}

// due to freetype being singlethreaded (mostly ?) the nvgCreate routines
// need to run locked so only one thread can create a NVG context at the
// same time. The same probably has to be done for every font load  ?
//
- (id) initWithEdgeAntialiasing:(BOOL) edgeAntialiasing
              useStencilStrokes:(BOOL) useStencilStrokes
{
   _nvgFlags  = edgeAntialiasing ? NVG_ANTIALIAS : 0;
   _nvgFlags |= useStencilStrokes ? NVG_STENCIL_STROKES : 0;
#ifdef DEBUG
   _nvgFlags |= NVG_DEBUG;
#endif

   mulle_thread_mutex_lock( &Self._freeTypeLock);
   {
#ifdef NANOVG_GL3_IMPLEMENTATION
      _vg  = nvgCreateGL3( _nvgFlags);
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
      _vg  = nvgCreateGLES2( _nvgFlags);
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
      _vg  = nvgCreateGLES3( _nvgFlags);
#endif
   }
   mulle_thread_mutex_unlock( &Self._freeTypeLock);

   if( ! _vg)
   {
      fprintf( stderr, "Could not create nanovg context\n");
      [self release];
      return( nil);
   }

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
   if( ! _vg)  // we died super early, so nothing to do
   {
      [super finalize];
      return;
   }
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


- (char *) shaderHeaderUTF8String
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   return( "#version 150 core\n");
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   return( "#version 100\n");
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   return( "#version 300 es\n");
#endif
   return( "");
}


- (void *) gpuTextureForImageID:(NSInteger) imageID
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   return( (void *) (uintptr_t) nvglImageHandleGL3( _vg, imageID));
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   return( (void *) (uintptr_t) nvglImageHandleGLES2( _vg, imageID));
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   return( (void *) (uintptr_t) nvglImageHandleGLES3( _vg, imageID));
#endif
   abort();
}


- (struct NVGcontext *) nvgContext
{
   return( CGContextGetNVGContext( self));
}


char   *_CGNVGBackendErrorShortUTF8String( void *error)
{
   switch( (intptr_t) error)
   {
   case GL_INVALID_ENUM      : return( "GL_INVALID_ENUM");
   case GL_INVALID_VALUE     : return( "GL_INVALID_VALUE");
   case GL_INVALID_OPERATION : return( "GL_INVALID_OPERATION");
   case GL_NO_ERROR          : return( "GL_NO_ERROR");
#if ! defined( NANOVG_GLES2_IMPLEMENTATION) && ! defined( NANOVG_GLES3_IMPLEMENTATION)
   case GL_STACK_OVERFLOW    : return( "GL_STACK_OVERFLOW");
   case GL_STACK_UNDERFLOW   : return( "GL_STACK_UNDERFLOW");
#endif
   case GL_OUT_OF_MEMORY     : return( "GL_OUT_OF_MEMORY");
   default                   : abort();
   }
}

char   *_CGNVGBackendErrorUTF8String( void *error)
{
   switch( (intptr_t) error)
   {
   case GL_INVALID_ENUM      : return( "An unacceptable value was specified for an enumerated argument");
   case GL_INVALID_VALUE     : return( "A numeric argument was out of range");
   case GL_INVALID_OPERATION : return( "The specified operation is not allowed in the current state");
   case GL_NO_ERROR          : return( NULL);
#if ! defined( NANOVG_GLES2_IMPLEMENTATION) && ! defined( NANOVG_GLES3_IMPLEMENTATION)
   case GL_STACK_OVERFLOW    : return( "This function caused a stack overflow");
   case GL_STACK_UNDERFLOW   : return( "This function caused a stack underflow");
#endif
   case GL_OUT_OF_MEMORY     : return( "There is not enough memory left to execute the function");
   default                   : abort();
   }
}


char   *CGNVGBackendErrorUTF8String( void)
{
   GLenum   err;

   err = glGetError();
   return( _CGNVGBackendErrorUTF8String( (void *) (intptr_t) err));
}


static void  _checkGLError( char* str)
{
	GLenum       err;
   static int   counter;

	err = glGetError();
	if( err != GL_NO_ERROR)
   {
      if( counter < 50)  // gets tedious fast
      {
		   fprintf( stderr, "%s error %s( %x) \"%s\" after %s\n",
                                 [CGContext backendUTF8String],
                                 _CGNVGBackendErrorShortUTF8String( (void *) (intptr_t) err),
                                 err,
                                 _CGNVGBackendErrorUTF8String( (void *) (intptr_t) err),
                                 str ? str : "???");
         ++counter;
      }
      assert( err == GL_NO_ERROR);
		return;
	}
}

static void  checkGLError( char* str)
{
#ifdef DEBUG
   _checkGLError( str);
#endif
}


- (void) assertNoBackendError:(char *) str
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   _checkGLError( str);
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   _checkGLError( str);
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   _checkGLError( str);
#endif
}


- (void) clearFramebufferMinimally
{
   if( _nvgFlags & NVG_STENCIL_STROKES)
      glClear( GL_STENCIL_BUFFER_BIT);
   checkGLError( "clear stencil and depth framebuffer");
}


- (void) clearFramebufferWithHexColor:(NSUInteger) hexColor
{
   CGFloat   rgba[ 4];
   CGColor   color;
   GLuint    bits;

   color = CGColorMakeWithHexColor( hexColor);
   CGColorGetComponents( color, rgba);
   glClearColor( rgba[ 0], rgba[ 1], rgba[ 2], rgba[ 3]);

   bits = GL_COLOR_BUFFER_BIT;
   if( _nvgFlags & NVG_STENCIL_STROKES)
      bits |= GL_STENCIL_BUFFER_BIT;

   glClear( bits);
   checkGLError( "clear framebuffer");
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

   checkGLError( "before nvgChangeFrame");

   // MEMO: the gLViewPort should be done afterwards
   nvgChangeFrame( _vg, _currentFrameInfo.size.width,
                        _currentFrameInfo.size.height,
                        _currentFrameInfo.pixelRatio);
   checkGLError( "nvgChangeFrame");

   glViewport( _currentFrameInfo.viewportFrame.origin.x,
               _currentFrameInfo.viewportFrame.origin.y,
               _currentFrameInfo.viewportFrame.size.width,
               _currentFrameInfo.viewportFrame.size.height);
   checkGLError( "glViewport");
}


- (void) resumeRender
{
   assert( _isActive);
   assert( _isRendering);

   checkGLError( "before resumeRender");

   glViewport( _currentFrameInfo.viewportFrame.origin.x,
               _currentFrameInfo.viewportFrame.origin.y,
               _currentFrameInfo.viewportFrame.size.width,
               _currentFrameInfo.viewportFrame.size.height);
   checkGLError( "glViewPort");

   nvgBeginFrame( _vg, _currentFrameInfo.size.width,
                       _currentFrameInfo.size.height,
                       _currentFrameInfo.pixelRatio);
   checkGLError( "nvgBeginFrame");
}


- (void) prepareOffScreenFramebuffer:(CGFrameInfo *) info
{
   if( ! CGBitmapSizeEqualToSize( _offScreenFramebufferSize, info->framebufferSize))
   {
      checkGLError( "before framebuffer delete");

      if( _offScreenFramebuffer)
      	nvgluDeleteFramebuffer((NVGLUframebuffer *) _offScreenFramebuffer);

      if( _debugEnabled)
         fprintf( stderr, "*** context %p: autorelease offScreenFramebufferImage %p\n", self, _offScreenFramebufferImage);

      [_offScreenFramebufferImage autorelease];
      _offScreenFramebufferImage = nil;

      checkGLError( "before framebuffer create");

      _offScreenFramebuffer = nvgluCreateFramebuffer( _vg,
                                                      (int) info->framebufferSize.width,
                                                      (int) info->framebufferSize.height,
                                                      0);
       checkGLError( "framebuffer create");

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

   _isRendering      = YES;
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

   checkGLError( "before begin nested render");

   [self _beginNestedRender:info];
   // now vg calls can happen

   checkGLError( "before delete textureIDs");

   // delete all queued textureIDs
   [self deleteTextureIDs];

   if( _rendersOffScreen)
   {
      checkGLError( "before prepareOffScreenFramebuffer");

      [self prepareOffScreenFramebuffer:info];
      // create or reuse existing offscreen framebuffer

      checkGLError( "before bind buffer");

      nvgluBindFramebuffer( _offScreenFramebuffer);

      checkGLError( "bind buffer");
   }
}


- (void) bindDefaultFramebuffer
{
   nvgluBindFramebuffer( _rendersOffScreen ? _offScreenFramebuffer : NULL);

   checkGLError( "bind buffer");
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
   checkGLError( "before nvgEndFrame");

   nvgEndFrame( _vg);

   checkGLError( "nvgEndFrame");
}


// flushes drawings doesn't set glViewport
- (void) flushRender
{
   nvgFlushFrame( _vg);
}


- (void) _endRender
{
   assert( _isRendering);

   nvgluBindFramebuffer( NULL);  // technically not needed
   _isRendering = NO;

   checkGLError( "unbind buffer");

   _lastFrameInfo = _currentFrameInfo;
   memset( &_currentFrameInfo, 0xAD, sizeof( _currentFrameInfo));
   _numberOfRenderedFrames++;
}


- (void) endRender
{
   assert( _isRendering);

   [self suspendRender];
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

/*
 * Read framebuffer information from GPU to CPU
 */
- (struct CGFramebufferBitmap) framebufferBitmapAtRect:(struct CGBitmapRect) rect
                                 framebufferBitmapType:(enum CGFramebufferBitmapType) type
                                             allocator:(struct mulle_allocator *) allocator
{
   struct CGFramebufferBitmap   fb;
   enum CGBitmapEncoding        encoding;
   GLenum                       format;
   GLenum                       type;
   size_t                       size;

   switch( type)
   {
   case CGFramebufferRGBABytes     : encoding = CGBitmapEncodingFlipYRGBABytes;
                                     format   = GL_RGBA;
                                     type     = GL_UNSIGNED_BYTE;
                                     break;
   case CGFramebufferRGBAFloats    : encoding = CGBitmapEncodingFlipYRGBABytes;
                                     format   = GL_RGBA;
                                     type     = GL_FLOAT;
                                     break;
//   case CGFramebufferStencilBytes  : encoding = CGBitmapEncodingFlipYMonochromeBytes;
//                                     format   = GL_STENCIL_INDEX;
//                                     type     = GL_UNSIGNED_BYTE;
//                                     break;
#if ! defined( NANOVG_GLES2_IMPLEMENTATION) && ! defined( NANOVG_GLES3_IMPLEMENTATION)
   case CGFramebufferStencilFloats : encoding = CGBitmapEncodingFlipYMonochromeFloats;
                                     format   = GL_STENCIL_INDEX;
                                     type     = GL_FLOAT;
                                     break;
//   case CGFramebufferDepthBytes    : encoding = CGBitmapEncodingFlipYMonochromeBytes;
//                                     format   = GL_DEPTH_COMPONENT;
//                                     type     = GL_UNSIGNED_BYTE;
//                                     break;
   case CGFramebufferDepthFloats   : encoding = CGBitmapEncodingFlipYMonochromeFloats;
                                     format   = GL_DEPTH_COMPONENT;
                                     type     = GL_FLOAT;
                                     break;
#endif

   default :
#ifdef DEBUG
      fprintf( stderr, "CGFramebufferBitmapType %d is not supported\n", type);
#endif
      memset( &fb, 0, sizeof( fb));
      return( fb);
   }

   fb.info        = CGBitmapInfoMake( rect.size, 0, encoding);
   size           = CGBitmapInfoGetAllocationSize( fb.info);
   fb.allocator   = allocator ? allocator : &mulle_default_allocator;
   // nvidia seemingly has problems if rect has some off values(guess)
   // so we add something for safety (valgrinds better)
   size          += 16;
   fb.bytes       = mulle_allocator_malloc( fb.allocator, size);

   glReadPixels( (int) rect.origin.x,   (int) rect.origin.y,
                 (int) rect.size.width, (int) rect.size.height,
                 format,
                 type,
                 fb.bytes);
   checkGLError( "glReadPixels");
   return( fb);
}


- (struct CGFramebufferBitmap)
   lastRenderedFramebufferBitmapType:(enum CGFramebufferBitmapType) type
                            inFlight:(BOOL) inFlight
                           allocator:(struct mulle_allocator *) allocator
{
   struct CGBitmapRect    rect;
   struct CGFrameInfo    *info;

   rect.origin = CGBitmapPointMake( 0, 0);
   info = [self lastFrameInfo];
   if( info)
      rect.size = info->framebufferSize;

   // By default, mode is GL_FRONT in single-buffered configurations
   // and GL_BACK in double-buffered configurations.
   // just have no luck with GLES2 setting this
#ifndef NANOVG_GLES2_IMPLEMENTATION
   glReadBuffer( inFlight ? GL_BACK : GL_FRONT);
   _checkGLError( "glReadBuffer");
#endif

   return( [self framebufferBitmapAtRect:rect
                   framebufferBitmapType:type
                               allocator:allocator]);
}


- (struct CGFramebufferBitmap) lastRenderedFramebuffer
{
   return( [self lastRenderedFramebufferBitmapType:CGFramebufferRGBABytes
                                          inFlight:NO
                                         allocator:NULL]);
}


- (struct CGFramebufferBitmap)
   lastRenderedOffscreenFramebufferBitmapType:(enum CGFramebufferBitmapType) type
                                    allocator:(struct mulle_allocator *) allocator
{
   struct CGFramebufferBitmap   fb;
   struct CGBitmapRect          bitmapRect;

   assert( ! _isRendering);  // bad bad bad

   if( ! _offScreenFramebuffer)
   {
      memset( &fb, 0, sizeof( fb));
      return( fb);
   }

   nvgluBindFramebuffer( _offScreenFramebuffer);
   checkGLError( "bind buffer");
   {
      bitmapRect = CGBitmapRectMake( 0, 0,
                                     _offScreenFramebufferSize.width,
                                     _offScreenFramebufferSize.height);
      fb = [self framebufferBitmapAtRect:bitmapRect
                   framebufferBitmapType:type
                               allocator:allocator];
   }
   nvgluBindFramebuffer( NULL);
   checkGLError( "unbind buffer");

   return( fb);
}


- (struct CGFramebufferBitmap) lastRenderedOffscreenFramebuffer
{
   return( [self lastRenderedOffscreenFramebufferBitmapType:CGFramebufferRGBABytes
                                                  allocator:NULL]);
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



- (void) fillRect:(CGRect) rect
         hexColor:(NSUInteger) hexColor
{
   nvgBeginPath( _vg);
   {
      nvgRect( _vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
      nvgFillColor( _vg, CGColorMakeWithUnsignedInteger( hexColor));
   }
   nvgFill( _vg);
}


- (void) strokeRect:(CGRect) rect
           hexColor:(NSUInteger) hexColor
              width:(CGFloat) width
{
   nvgBeginPath( _vg);
   {
      nvgRect( _vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
      nvgStrokeWidth( _vg, width);
      nvgStrokeColor( _vg, CGColorMakeWithUnsignedInteger( hexColor));
   }
   nvgStroke( _vg);
}


- (void) drawRect:(CGRect) rect
            image:(id) image
            scale:(BOOL) scale
{
   CGDrawableOptions   options;

   options = CGDrawableOptionsMake( 0.0, 1.0, 0.0, scale);
   [image drawRect:rect
           options:&options
           context:self];
}



- (void) drawFramebufferBitmap:(struct CGFramebufferBitmap *) fb
{
   CGImage                  *image;
   CGDrawableOptions        options;
   CGRect                   rect;
   enum CGBitmapEncoding    targetEncoding;
   void                     *bytes;
   struct CGBitmapInfo      info;

   if( ! fb->bytes)
      return;

   targetEncoding = CGBitmapEncodingRGBABytes;
   switch( CGBitmapInfoGetEncoding( fb->info))
   {
   case CGBitmapEncodingFlipYRGBABytes :
   case CGBitmapEncodingRGBABytes      :
      image = [[[CGImage alloc] initWithBytes:fb->bytes
                                 bitmapInfo:fb->info
                                 imageFlags:0
                                    context:self] autorelease];
      break;

   default:
      bytes = CGBitmapConvertBytesToEncoding( fb->bytes, fb->info, targetEncoding, NULL);
      if( ! bytes)
         abort();
      info  = CGBitmapInfoMake( fb->info.size, 0, targetEncoding);
      image = [[[CGImage alloc] initWithBytes:fb->bytes
                                   bitmapInfo:fb->info
                                   imageFlags:0
                                    context:self] autorelease];
      mulle_free( bytes);
   }

   rect    = CGRectMake( 0, 0, fb->info.size.width, fb->info.size.height);
   options = CGDrawableOptionsMake( 0.0, 1.0, 0.0, YES);
   [image drawRect:rect
           options:&options
           context:self];

   // just for debugging, draws a frame somewhere
   {
      struct NVGcontext   *vg;

      vg = CGContextGetNVGContext( self);

      // draw a rectangle on top so we know something is drawn...
      nvgBeginPath( vg);
      {
         rect = CGRectInset( rect, 20, 20);
         nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
         nvgStrokeWidth( vg, 3);
         nvgStrokeColor( vg, CGColorMakeWithUnsignedInteger( 0x8020A0FF));
      }
      nvgStroke( vg);
   }
}

@end

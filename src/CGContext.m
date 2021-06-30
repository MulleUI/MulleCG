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
"void main() {\n"
"    vec3 normal = GetNormal();\n"
"\n"
"    gl_Position = explode(gl_in[0].gl_Position, normal);\n"
"    TexCoords = gs_in[0].texCoords;\n"
"    EmitVertex();\n"
"    gl_Position = explode(gl_in[1].gl_Position, normal);\n"
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
   int   flags;

   flags  = edgeAntialiasing ? NVG_ANTIALIAS : 0;
   flags |= useStencilStrokes ? NVG_STENCIL_STROKES : 0;
#if DEBUG
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
/*
#if MULLE_CG_GL
VERSION != MULLE_GLES2
   {
      struct GLNVGcontext   *vgl = (struct GLNVGcontext *) _vg;
      unsigned int          program;
      unsigned int          geometryShader;
      char                  *str[ 2];
	   static char           *shaderHeader = ""
#ifdef NANOVG_GL2_IMPLEMENTATION
#elif defined( NANOVG_GL3_IMPLEMENTATION)
		"#version 330 core\n"
#elif defined( NANOVG_GLES2_IMPLEMENTATION)
		"#version 100\n"
#elif defined( NANOVG_GLES3_IMPLEMENTATION)
		"#version 300 es\n"
#endif
      ;

      program        = vgl->shader.prog;
      geometryShader = glCreateShader (GL_GEOMETRY_SHADER);
      str[ 0] = shaderHeader;
      str[ 1] = geometryShaderSource;
      glShaderSource( geometryShader, 1, str, NULL);
      glCompileShader( geometryShader);
      assert_shader_compiler_errors( geometryShader);
      glAttachShader( program, geometryShader);
      glLinkProgram( program);
      glDeleteShader( geometryShader);     // release basically
   }
#endif
*/
   [self _initFontCache];

   _mulle__pointerset_init( &_resources, 0, MulleObjCInstanceGetAllocator( self));
   return( self);
}


- (instancetype) init
{
   return( [self initWithEdgeAntialiasing:YES
                        useStencilStrokes:YES]);
}


- (struct NVGcontext *) nvgContext
{
   return( _vg);
}


- (void) finalize
{
   assert( ! _isRendering);

   [self _resetFontCache];

   [self removeAllResources];

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
   [self _doneFontCache];

   [super dealloc];
}


- (void) clearFramebuffer
{
   CGFloat   rgba[ 4];

   MulleColorGetComponents( _backgroundColor, rgba);
   glClearColor( rgba[ 0], rgba[ 1], rgba[ 2], rgba[ 3]);
   glClear( GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
}


#define GL_GPU_MEM_INFO_TOTAL_AVAILABLE_MEM_NVX   0x9048
#define GL_GPU_MEM_INFO_CURRENT_AVAILABLE_MEM_NVX 0x9049


- (void) continueRender
{
   glViewport( _currentFrameInfo.viewportFrame.origin.x,
               _currentFrameInfo.viewportFrame.origin.y,
               _currentFrameInfo.viewportFrame.size.width,
               _currentFrameInfo.viewportFrame.size.height);
   nvgBeginFrame( _vg, _currentFrameInfo.size.width,
                       _currentFrameInfo.size.height,
                       _currentFrameInfo.pixelRatio);
}


- (void) beginRender:(struct CGFrameInfo *) info
{
   double   t;
   GLint    value;

   assert( ! _isRendering);
   assert( info);

   _isRendering = YES;
   _lastRenderStart  = _currentFrameInfo.renderStart
                          ? _currentFrameInfo.renderStart
                          : info->renderStart;
   _frameDelta       = _currentFrameInfo.renderStart - _lastRenderStart;

   _currentFrameInfo = *info;
   _alpha            = 1.0;

#if RENDER_DEBUG
   if( ! CGSizeEqualToSize( info->viewportFrame.size, info->framebufferSize) ||
       ! CGSizeEqualToSize( info->viewportFrame.size, info->size) ||
       ! CGSizeEqualToSize( info->framebufferSize, info->size))
      fprintf( stderr, "Viewport: %s, FB: %s, Window: %s\n",
               CGSizeCStringDescription( info->viewportFrame.size),
               CGSizeCStringDescription( info->framebufferSize),
               CGSizeCStringDescription( info->size));
#endif
   // < performance measurement
   [self continueRender];
}


- (void) suspendRender
{
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

   [self suspendRender];
   _isRendering = NO;
}


- (BOOL) isRendering
{
   return( _isRendering);
}



- (struct CGFrameInfo *) currentFrameInfo
{
   return( &_currentFrameInfo);
}


- (void) getCurrentFrameInfo:(struct CGFrameInfo *) info
{
   assert( info);
   assert( _currentFrameInfo.pixelRatio);  // not yet initialized!!
   *info = _currentFrameInfo;
}


- (void) resetTransform
{
   nvgResetTransform( _vg);
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


@end

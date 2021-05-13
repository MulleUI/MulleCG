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

   [self _unmapImages];
   [self _finalizeLayers];

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


- (void) beginRenderWithFrameInfo:(struct MulleFrameInfo *) info
{
   double   t;
   GLint    value;

   assert( ! _isRendering);

   _currentFrameInfo = *info;

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

   glViewport( info->viewportFrame.origin.x,
               info->viewportFrame.origin.y,
               info->viewportFrame.size.width,
               info->viewportFrame.size.height);
   nvgBeginFrame( _vg, info->size.width,
                       info->size.height,
                       info->pixelRatio);
   _isRendering = YES;
   _alpha       = 1.0;
}



- (void) endRender
{
   assert( _isRendering);

   _isRendering = NO;
   nvgEndFrame( _vg);
}


- (struct MulleFrameInfo *) currentFrameInfo
{
   return( &_currentFrameInfo);
}


- (void) getCurrentFrameInfo:(struct MulleFrameInfo *) info
{
   assert( info);
   assert( _currentFrameInfo.pixelRatio);  // not yet initialized!!
   *info = _currentFrameInfo;
}


- (void) resetTransform
{
   nvgResetTransform( _vg);
}


- (int) registerTextureIDForImage:(id <CGBitmapImage>) image
{
   int                      textureId;
   CGSize                   size;
   void                     *value;
   struct mulle_allocator   *allocator;

   if( _images)
   {
      value = _mulle__pointermap_get( _images, image);
      if( value)
      {
         textureId = (int) (intptr_t) value;
   //      fprintf( stderr, "textureid: %d\n", textureId);
         return( textureId);
      }
   }

   allocator = MulleObjCInstanceGetAllocator( self);
   if( ! _images)
      _images = mulle__pointermap_create( 16, 0, allocator);

   size      = [image size];
   textureId = nvgCreateImageRGBA( _vg,
                                   (int) round( size.width),
                                   (int) round( size.height),
                                   [image nvgImageFlags],
                                   [image bytes]);
//   fprintf( stderr, "textureid: %d\n", textureId);

   _mulle__pointermap_set( _images, image, (void *) (intptr_t) textureId, allocator);
   return( textureId);
}


- (void) unregisterTextureIDForImage:(id <CGBitmapImage>) image
{
   void   *value;
   int    textureId;

   assert( _images);

   value = _mulle__pointermap_get( _images, image);
   if( ! value)
      return;

   textureId = (int) (intptr_t) value;
   nvgDeleteImage( _vg, textureId);

   _mulle__pointermap_remove( _images, image, MulleObjCInstanceGetAllocator( self));
}


// - (MulleTextureImage *) framebufferImageWithBitmapSize:(struct MulleBitmapInfo) size
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

- (void) addToLayers:(CGLayer *) image
{
   // images are not retained!
   if( ! _layers)
      _layers = mulle_pointerarray_create( NULL);
   _mulle_pointerarray_add( _layers, image);
}


- (void) removeFromLayers:(CGLayer *) image
{
   intptr_t   index;

   if( ! _layers)
      return;

   index = _mulle_pointerarray_find( _layers, image);
   if( index == mulle_not_found_e)
      return;

   _mulle_pointerarray_set( _layers, index, NULL);
}


- (void) _unmapImages
{
   struct mulle__pointermapenumerator  rover;
   struct mulle_pointerpair            *pair;
   NSObject <CGImage>                  *image;
   int                                 textureId;

   if( ! _images)
      return;

   rover = mulle__pointermap_enumerate( _images);
   while( (pair = _mulle__pointermapenumerator_next( &rover)))
   {
      // we just remove the textureIDs and wipeout the mapping
      textureId = (int) (intptr_t) pair->value;
      nvgDeleteImage( _vg, textureId);
   }
   mulle__pointermapenumerator_done( &rover);

   _mulle__pointermap_destroy( _images, MulleObjCInstanceGetAllocator( self));
   _images = NULL;
}


- (void) _finalizeLayers
{
   struct mulle_pointerarrayenumerator  rover;
   NSObject <CGImage>                  *image;

   if( ! _layers)
      return;

   rover = mulle_pointerarray_enumerate( _layers);
   while( _mulle_pointerarrayenumerator_next( &rover, (void **) &image))
   {
      // call finalize on these as they are effectively dead now
      [image finalize];
   }
   mulle_pointerarrayenumerator_done( &rover);

   mulle_pointerarray_destroy( _layers);
   _layers = NULL;
}

@end

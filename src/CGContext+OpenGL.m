//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
#define DEFINE_NANOVG_GL_IMPLEMENTATION

#import "CGContext+OpenGL.h"

#import "import-private.h"

#import "CGImage.h"
#import "CGLayer.h"
#include <ctype.h>


@implementation CGContext ( OpenGL)


char   *CGNVGBackendErrorUTF8String( void)
{
   GLenum   err;

   err = glGetError();
   return( _CGNVGBackendErrorUTF8String( (void *) (intptr_t) err));
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
   case GL_INVALID_FRAMEBUFFER_OPERATION : return( "GL_INVALID_FRAMEBUFFER_OPERATION");
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
   case GL_INVALID_FRAMEBUFFER_OPERATION : return( "Wrong or no framebuffer selected");
   default                   : abort();
   }
}


void   _CGContextCheckBackendError( CGContext *ctxt, char *str)
{
   GLenum       err;
   static int   counter;
   char         *s;

   err = glGetError();
   if( err != GL_NO_ERROR)
   {
      if( counter < 50)  // gets tedious fast
      {
         s = [ctxt backendUTF8String];
         if( ! s)
            s = [CGContext nanoVGBackendUTF8String];

         mulle_fprintf( stderr, "%s error %@ %s( 0x%x) \"%s\": %s\n",
                                 s,
                                 ctxt,
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


static void   checkCompileErrors( GLuint shader, char *type, char *name)
{
   GLint   success;
   GLchar   infoLog[ 1024];

   glGetShaderiv( shader, GL_COMPILE_STATUS, &success);
   if( ! success)
   {
       glGetShaderInfoLog( shader, 1024, NULL, infoLog);
       fprintf( stderr, "%s %s compile error: %s\n", name, type, infoLog);
   }
}


static void   checkLinkErrors( GLuint shader, char *name)
{
   GLint   success;
   GLchar  infoLog[ 1024];

   glGetProgramiv( shader, GL_LINK_STATUS, &success);
   if( ! success)
   {
       glGetShaderInfoLog( shader, 1024, NULL, infoLog);
       fprintf( stderr, "%s link error: %s\n", name, infoLog);
   }
}


static int  has_version_header( char *s)
{
   while( isblank( *s))
      ++s;
   if( *s != '#')
      return( 0);
   ++s;

   while( isblank( *s))
      ++s;
   if( ! strncmp( s, "version", 7))
   {
      s += 7;
      if( isblank( *s))
         return( 1);
   }
   return( 0);
}


//
// MEMO: we can't do NANOVG_GL2_IMPLEMENTATION because we need
//       for example secondary framebuffers, which nanovg would not
//        support
//
+ (char *) nanoVGBackendUTF8String
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   return( "nanoVG OpenGL v3.0+");
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   return( "nanoVG GLES v2.0+");
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   return( "nanoVG GLES v3.2+");
#endif
   abort();
}


+ (CGContextNanoVGBackend) nanoVGBackend
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


- (void) _initNanoVGWithEdgeAntialiasing:(BOOL) edgeAntialiasing
                       useStencilStrokes:(BOOL) useStencilStrokes
{ 
   _nvgFlags  = edgeAntialiasing ? NVG_ANTIALIAS : 0;
   _nvgFlags |= useStencilStrokes ? NVG_STENCIL_STROKES : 0;
#ifdef DEBUG
   _nvgFlags |= NVG_DEBUG;
#endif

#ifdef NANOVG_GL3_IMPLEMENTATION
   _vg  = nvgCreateGL3( _nvgFlags);
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   _vg  = nvgCreateGLES2( _nvgFlags);
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   _vg  = nvgCreateGLES3( _nvgFlags);
#endif

   _framebufferBits = GL_COLOR_BUFFER_BIT;
   if( useStencilStrokes)
      _framebufferBits |= GL_STENCIL_BUFFER_BIT;
}


- (void) _finalizeNanoVG
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
   _vg = NULL;
}


//
// TODO: remember under name as resource somehow
//
- (NSUInteger) compileVertexShader:(char *) vertexShaderCode
                    fragmentShader:(char *) fragmentShaderCode
                    nameUTF8String:(char *) name
{
   GLuint   vertex;
   GLuint   fragment;
   GLuint   shaderID;
   char     *sources[ 2];

   vertex = glCreateShader( GL_VERTEX_SHADER);

   // put a "proper" version header on top of the shader, if there is none
   // will be like nanovg shader version
   sources[ 0] = has_version_header( vertexShaderCode) ? "" : [self shaderHeaderUTF8String];
   sources[ 1] = vertexShaderCode;
   glShaderSource( vertex, 2, (const GLchar *const *) sources, NULL);
   glCompileShader( vertex);
   checkCompileErrors( vertex, "vertex", name);

   // put a "proper" version header on top of the shader, if there is none
   // will be like nanovg shader version
   sources[ 0] = has_version_header( fragmentShaderCode) ? "" : [self shaderHeaderUTF8String];
   sources[ 1] = fragmentShaderCode;

   fragment = glCreateShader( GL_FRAGMENT_SHADER);
   glShaderSource( fragment, 2, (const GLchar *const *) sources, NULL);
   glCompileShader( fragment);
   checkCompileErrors( fragment, "fragment", name);

   shaderID = glCreateProgram();
   glAttachShader( shaderID, vertex);
   glAttachShader( shaderID, fragment);
   glLinkProgram( shaderID);
   checkLinkErrors( shaderID, name);

   return( shaderID);
}


- (void) useShader:(NSUInteger) shaderID
{
   glUseProgram( (GLuint) shaderID);
}


- (void) assertNoBackendError:(char *) str
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   _CGContextCheckBackendError( self, str);
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   _CGContextCheckBackendError( self, str);
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   _CGContextCheckBackendError( self, str);
#endif
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


- (NSUInteger) framebufferBitsWithColorBit:(BOOL) flag
{
   if( flag)
      return( _framebufferBits | GL_COLOR_BUFFER_BIT);
   return( _framebufferBits & ~GL_COLOR_BUFFER_BIT);
}


- (void) clearFramebufferBits:(NSUInteger) bits
                        color:(CGColor) color
{
   CGFloat   rgba[ 4];
   CGColor   color;
   GLuint    bits;

   if( bits & GL_COLOR_BUFFER_BIT)
   {
      CGColorGetRGBAComponents( color, rgba);
      glClearColor( rgba[ 0], rgba[ 1], rgba[ 2], rgba[ 3]);
   }

   glClear( bits);
   CGContextCheckBackendError( self, "clear framebuffer");
}


- (void) clearFramebufferNoColor
{
   [self clearFramebufferBits:_framebufferBits & ~GL_COLOR_BUFFER_BIT
                        color:CGColorMakeWithHexColor( 0x00000000)];
}


//#define GL_GPU_MEM_INFO_TOTAL_AVAILABLE_MEM_NVX   0x9048
//#define GL_GPU_MEM_INFO_CURRENT_AVAILABLE_MEM_NVX 0x9049


- (void) changeRender:(struct CGFrameInfo *) info
{
   assert( _isActive);
   assert( _isRendering);
   assert( info);

   _currentFrameInfo = *info;

   CGContextCheckBackendError( self, "before nvgChangeFrame");

   // MEMO: the gLViewPort should be done afterwards
   nvgChangeFrame( _vg, _currentFrameInfo.window.frame.size.width,
                        _currentFrameInfo.window.frame.size.height,
                        _currentFrameInfo.window.pixelRatio);
   CGContextCheckBackendError( self, "nvgChangeFrame");

   glViewport( _currentFrameInfo.viewportFrame.origin.x,
               _currentFrameInfo.viewportFrame.origin.y,
               _currentFrameInfo.viewportFrame.size.width,
               _currentFrameInfo.viewportFrame.size.height);
   CGContextCheckBackendError( self, "glViewport");
}


- (void) resumeRender
{
   assert( _isActive);
   assert( _isRendering);

   CGContextCheckBackendError( self, "before resumeRender");

   glViewport( _currentFrameInfo.viewportFrame.origin.x,
               _currentFrameInfo.viewportFrame.origin.y,
               _currentFrameInfo.viewportFrame.size.width,
               _currentFrameInfo.viewportFrame.size.height);
   CGContextCheckBackendError( self, "glViewPort");

   nvgBeginFrame( _vg, _currentFrameInfo.window.frame.size.width,
                       _currentFrameInfo.window.frame.size.height,
                       _currentFrameInfo.window.pixelRatio);
   CGContextCheckBackendError( self, "nvgBeginFrame");
}


- (void) bindOpenGLFramebuffer:(void *) framebuffer
{
   glBindFramebuffer( GL_FRAMEBUFFER, (GLuint) (uintptr_t) framebuffer);
   CGContextCheckBackendError( self, "glBindFramebuffer");
}


//
// used by CGImage when sharing textures to ensure that a texture is ready
// to be used:
// https://stackoverflow.com/questions/23300895/sharing-textures-between-opengl-contexts-with-glfw3-is-not-working
//
- (void) barrier
{
   glFinish();
   CGContextCheckBackendError( self, "glFinish");
}


//
// This does a "blit" to the framebuffer, so a framebuffer must be active
// and it's assumed that  glEnable( GL_TEXTURE_2D); is set. Any bound
// texture is unbound. This is no problem for nanovg, since it caches the
// drawing command, and then set the texture as needed
//
// https://android-developers.narkive.com/jbf8Z3nr/opengl-gl11-gldrawtexioes-does-not-seem-to-work-for-nexus-one
// https://stackoverflow.com/questions/46184719/is-their-any-equivalent-of-gldrawtexioes-oes-draw-texture-under-opengl-2-0
//
// void   glDrawTexiOES( int, int, int, int, int);
//
// - (void) blitRect:(struct MulleIntegerRect) rect
//             image:(CGImage *) image
// {
//    void   *gpuTexture;
//
//    assert( _isActive);
//    assert( glfwExtensionSupported( "OES_draw_texture"));
//
//    gpuTexture = [image gpuTexture];
//    // glEnable( GL_TEXTURE_2D);
//    glBindTexture( GL_TEXTURE_2D, (int) (intptr_t) gpuTexture);
//
//    // needed ?
//    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
//
//    CGContextCheckBackendError( self, "glBindTexture");
//    // viewport ? shrug: https://community.khronos.org/t/gldrawtexioes-behavior/2046
//    glDrawTexiOES( rect.origin.x, rect.origin.y, 0, rect.size.width, rect.size.height);
//    CGContextCheckBackendError( self, "glDrawTexiOES");
//
//    glBindTexture( GL_TEXTURE_2D, 0);
// }


// {
//    void   *gpuTexture;
//
//    assert( _isActive);
//    assert( glfwExtensionSupported( "OES_draw_texture"));
//
//    gpuTexture = [image gpuTexture];
//    // glEnable( GL_TEXTURE_2D);
//    glBindTexture( GL_TEXTURE_2D, (int) (intptr_t) gpuTexture);
//
//    // needed ?
//    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
//
//    CGContextCheckBackendError( self, "glBindTexture");
//    // viewport ? shrug: https://community.khronos.org/t/gldrawtexioes-behavior/2046
//    glDrawTexiOES( rect.origin.x, rect.origin.y, 0, rect.size.width, rect.size.height);
//    CGContextCheckBackendError( self, "glDrawTexiOES");
//
//    glBindTexture( GL_TEXTURE_2D, 0);
// }

//
// https://stackoverflow.com/questions/3073796/how-to-use-glcopyimage2d
//
// glGetTexImage doesn’t exist in OpenGL ES 1.1 or 2.0. This means, if we
// have GLES we need to create a temporary CGLayer
//
#if defined( NANOVG_GLES2_IMPLEMENTATION) || defined( NANOVG_GLES3_IMPLEMENTATION)

- (struct CGBitmap) RGBABytesBitmapOfImage:(CGImage *) image
                                 allocator:(struct mulle_allocator *) allocator
{
   void                          *gpuTexture;
   GLuint                        tmpFramebuffer;
   struct CGBitmap               bitmap;
   struct CGContextFramebuffer   next;
   struct CGContextFramebuffer   previous;
   struct MulleIntegerSize           bitmapSize;
   size_t                        size;

   assert( _isActive);

   bitmapSize  = [image bitmapSize];
   size        = bitmapSize.width * bitmapSize.height * 4;
   assert( size);

   // circumvent nvidia bug
   size            += 16;

   // implicity transparent background
   bitmap.allocator = allocator ? allocator : &mulle_default_allocator;
   bitmap.bytes     = mulle_allocator_calloc( bitmap.allocator, 1, size);
   // flipped not flipped ?
   bitmap.info      = CGBitmapInfoMake( bitmapSize, 0, CGBitmapEncodingFlipYRGBABytes);

   //
   // create a temporary framebuffer
   // attach texture of image ot it to it
   // read pixels from it, done
   // AFAIK this doesn't touch or need any OpenGL state, so we can just
   // interpose this, if we restore the bound framebuffer
   //
   glGenFramebuffers( 1, &tmpFramebuffer);
   CGContextCheckBackendError( self, "glGenFramebuffers");

   next     = CGContextFramebufferMakeWithOpenGLFramebuffer( (void *) (uintptr_t) tmpFramebuffer);
   previous = [self bindFramebuffer:next];
   {
      gpuTexture = [image gpuTexture];
      glFramebufferTexture2D( GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              GL_TEXTURE_2D,
                              (GLuint) (uintptr_t) gpuTexture,
                              0);
      CGContextCheckBackendError( self, "glFramebufferTexture2D");

      glReadPixels( 0, 0,
                    bitmapSize.width,
                    bitmapSize.height,
                    GL_RGBA,
                    GL_UNSIGNED_BYTE,
                    bitmap.bytes);
      CGContextCheckBackendError( self, "glReadPixels");
   }
   [self bindFramebuffer:previous];

   glDeleteFramebuffers( 1, &tmpFramebuffer);
   CGContextCheckBackendError( self, "glDeleteFramebuffers");

   return( bitmap);
}

#else

- (struct CGBitmap) RGBABytesBitmapOfImage:(CGImage *) image
                                 allocator:(struct mulle_allocator *) allocator
{
   struct CGBitmap         bitmap;
   struct MulleIntegerSize     bitmapSize;
   CGBitmapEncoding   encoding;
   GLenum                  format;
   GLenum                  type;
   size_t                  size;
   NSUInteger              imageID;
   void                    *gpuTexture;
   struct NVGcontext       *vg;

   assert( _isActive);

   encoding = CGBitmapEncodingFlipYRGBABytes;
   format   = GL_RGBA;
   type     = GL_UNSIGNED_BYTE;
   // imageID is OK here, because we don't care about repeats and stuff

   assert( [image context] == self);

   vg      = CGContextGetNVGContext( self);
   imageID = [image imageID];
   nvgImageTextureInfo( vg, imageID, NULL, NULL, &gpuTexture);

   bitmapSize        = [image bitmapSize];
   size              = bitmapSize.width * bitmapSize.height * 4;
   assert( size);

   // nvidia seemingly has problems if rect has some off values(guess)
   // so we add something for safety (valgrinds better)
   size             += 16;
   bitmap.allocator  = allocator ? allocator : &mulle_default_allocator;
   bitmap.bytes      = mulle_allocator_malloc( bitmap.allocator, size);
   bitmap.info       = CGBitmapInfoMake( bitmapSize, 0, encoding);

   glBindTexture( GL_TEXTURE_2D, (int) (intptr_t) gpuTexture);
   CGContextCheckBackendError( self, "glBindTexture");
   {
      glGetTexImage( GL_TEXTURE_2D,
                     0, // level
                     format,
                     type,
                     bitmap.bytes);
      CGContextCheckBackendError( self, "glGetTexImage");
   }
   glBindTexture( GL_TEXTURE_2D, 0);
   CGContextCheckBackendError( self, "glBindTexture");

   return( bitmap);
}

#endif


/*
 * Read framebuffer information from GPU to CPU
 */
- (struct CGBitmap) readFramebufferBitmap:(struct MulleIntegerRect) rect
                    framebufferBitmapType:(CGFramebufferBitmapType) fType
                                allocator:(struct mulle_allocator *) allocator
{
   struct CGBitmap         bitmap;
   CGBitmapEncoding        encoding;
   GLenum                  format;
   GLenum                  type;
   size_t                  size;

   switch( fType)
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
      fprintf( stderr, "CGFramebufferBitmapType %d is not supported\n", fType);
#endif
      memset( &bitmap, 0, sizeof( bitmap));
      return( bitmap);
   }

   bitmap.info      = CGBitmapInfoMake( rect.size, 0, encoding);
   size             = CGBitmapInfoGetAllocationSize( bitmap.info);
   bitmap.allocator = allocator ? allocator : &mulle_default_allocator;
   // nvidia seemingly has problems if rect has some off values(guess)
   // so we add something for safety (valgrinds better)
   size            += 16;
   bitmap.bytes     = mulle_allocator_malloc( bitmap.allocator, size);

   glReadPixels( (int) rect.origin.x,   (int) rect.origin.y,
                 (int) rect.size.width, (int) rect.size.height,
                 format,
                 type,
                 bitmap.bytes);
   CGContextCheckBackendError( self, "glReadPixels");

   return( bitmap);
}

@end

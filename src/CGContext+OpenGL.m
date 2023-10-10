//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
#define DEFINE_NANOVG_GL_IMPLEMENTATION

#import "CGContext+OpenGL.h"

#import "import-private.h"

#import "CGContext+Drawing.h"
#import "CGLayoutContext.h"
#import "CGImage.h"
#import "CGLayer.h"
#import "CGColor.h"
#include <ctype.h>


@implementation CGImage ( OpenGL)

- (GLint) openGLSamplerType
{
   return( [self isMultiSample]
           ? GL_TEXTURE_2D_MULTISAMPLE
           : GL_TEXTURE_2D);
}

@end

@implementation CGLayoutContext ( OpenGL)

- (void) _initializeNanoVG:(NSUInteger) flags
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   _vg  = nvgCreateGL3( _nvgFlags);
#else
# ifdef NANOVG_GLES2_IMPLEMENTATION
   _vg  = nvgCreateGLES2( _nvgFlags);
# else
#  ifdef NANOVG_GLES3_IMPLEMENTATION
   _vg  = nvgCreateGLES3( _nvgFlags);
#  else
#   error "Any of NANOVG_GL3/GLES2/GLES3_IMPLEMENTATION must be defined"
#  endif
# endif
#endif
   assert( _vg);
}


- (void) _finalizeNanoVG
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   nvgDeleteGL3( _vg);
   _vg = NULL;
#else
# ifdef NANOVG_GLES2_IMPLEMENTATION
   nvgDeleteGLES2(_vg);
   _vg = NULL;
# else
#  ifdef NANOVG_GLES3_IMPLEMENTATION
   nvgDeleteGLES3(_vg);
   _vg = NULL;
#  endif
# endif
#endif
}

@end



@implementation CGContext ( OpenGL)


+ (BOOL) supportsAntiAliasing
{
#ifdef NANOVG_HAVE_MSAA
   return( YES);
#endif
   return( NO);
}


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

//
// MEMO: we can't do NANOVG_GL2_IMPLEMENTATION because we need
//       for example secondary framebuffers, which nanovg would not
//        support
//
+ (char *) nanoVGBackendUTF8String
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   return( "OpenGL v3.2+");
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   return( "GLES v2.0+");
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   return( "GLES v3.2+");
#endif
   abort();
}


+ (CGContextNanoVGBackend) nanoVGBackend
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   return( CG_GL3_2);
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   return( CG_GLES2);
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   return( CG_GLES3_2);
#endif
   abort();
}


- (char *) nanovgInfoUTF8String
{
   char   *s;

   s = MulleObjC_asprintf( "%s%s%s%s%s",
                           [[self class] nanoVGBackendUTF8String],
                           _nvgFlags & NVG_ANTIALIAS ? " EdgeAA" : "",
                           _nvgFlags & NVG_CLEARTYPE ? " ClearType" : "",
                           _nvgFlags & NVG_STENCIL_STROKES ? " Stencil" : "",
                           _nvgFlags & NVG_MSAA ? " MSAA" : "");
   return( s);
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


BOOL   CGContextResetBackendError( CGContext *ctxt)
{
   GLenum       err;
   BOOL         flag;

   for( flag = NO;; flag = YES)
   {
      err = glGetError();
      if( err == GL_NO_ERROR)
         return( flag);
   }
}



+ (NVGcontext *) createPathContext
{
   struct NVGcontext  *pathContext;

#ifdef NANOVG_GL3_IMPLEMENTATION
   pathContext  = nvgCreateGL3( NVG_PATH_ONLY);
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   pathContext  = nvgCreateGLES2( NVG_PATH_ONLY);
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   pathContext  = nvgCreateGLES3( NVG_PATH_ONLY);
#endif
   assert( pathContext);
   return( pathContext);
}


- (void) _initNanoVGWithGraphicsOptions:(UIGraphicsOptions) options
{
   _nvgFlags  = (options & UIGraphicsEdgeAntiAliasing)  ? NVG_ANTIALIAS : 0;
   _nvgFlags |= (options & UIGraphicsUseStencilStrokes) ? NVG_STENCIL_STROKES : 0;
   _nvgFlags |= (options & UIGraphicsUseClearType)      ? NVG_CLEARTYPE : 0;
#ifdef DEBUG
   _nvgFlags |= NVG_DEBUG;
#endif

#ifdef NANOVG_GL3_IMPLEMENTATION
   _nvgFlags |= (options & UIGraphicsUseMSAA) ? NVG_MSAA : 0;
   _vg        = nvgCreateGL3( _nvgFlags);
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   _vg        = nvgCreateGLES2( _nvgFlags);
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   _nvgFlags |= (options & UIGraphicsUseMSAA) ? NVG_MSAA : 0;
   _vg        = nvgCreateGLES3( _nvgFlags);
#endif

   assert( _vg);
#ifdef DEBUG
   fprintf( stderr, "nanovg context          : %s\n", [self nanovgInfoUTF8String]);
#endif

   _framebufferBits = GL_COLOR_BUFFER_BIT;
   if( options & UIGraphicsUseStencilStrokes)
      _framebufferBits |= GL_STENCIL_BUFFER_BIT;
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


- (void *) gpuTextureForImageID:(NSInteger) textureID
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   return( (void *) (uintptr_t) nvglImageHandleGL3( _vg, textureID));
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   return( (void *) (uintptr_t) nvglImageHandleGLES2( _vg, textureID));
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   return( (void *) (uintptr_t) nvglImageHandleGLES3( _vg, textureID));
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
   if( bits & GL_COLOR_BUFFER_BIT)
      glClearColor( color.r, color.b, color.g, color.a);

   glClear( bits);
   CGContextCheckBackendError( self, "clear framebuffer");
}


- (void) clearFramebufferNoColor
{
   [self clearFramebufferBits:_framebufferBits & ~GL_COLOR_BUFFER_BIT
                        color:CGColorMakeWithHexColor(0x00000000)];
}



//#define GL_GPU_MEM_INFO_TOTAL_AVAILABLE_MEM_NVX   0x9048
//#define GL_GPU_MEM_INFO_CURRENT_AVAILABLE_MEM_NVX 0x9049
- (void) changeRender:(struct CGFrameInfo *) info
{
   assert( _isActive);
   assert( info);

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
   // 15.6.2023: if i comment glFinish out, the display flickers slightly
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
   GLint                         samplerType;
   struct CGBitmap               bitmap;
   struct CGContextFramebuffer   next;
   struct CGContextFramebuffer   previous;
   struct MulleIntegerSize       bitmapSize;
   size_t                        size;
   BOOL                          isMultiSample;
#if defined( NANOVG_GLES3_IMPLEMENTATION)
   NVGLUframebuffer              *nvgResultFramebuffer;
#endif
   assert( _isActive);

   bitmapSize       = [image bitmapSize];
   size             = bitmapSize.width * bitmapSize.height * 4;
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
   // attach texture of image to it
   // read pixels from it, done
   // AFAIK this doesn't touch or need any OpenGL state, so we can just
   // interpose this, if we restore the bound framebuffer
   //

   gpuTexture  = [image gpuTexture];

   glGenFramebuffers( 1, &tmpFramebuffer);
   CGContextCheckBackendError( self, "glGenFramebuffers");

   isMultiSample = [image isMultiSample];
   next          = CGContextFramebufferMakeWithOpenGLHandle( (void *) (uintptr_t) tmpFramebuffer,
                                                             isMultiSample);
   samplerType   = isMultiSample ? GL_TEXTURE_2D_MULTISAMPLE : GL_TEXTURE_2D;

   previous = [self bindFramebuffer:next];
   {
      glFramebufferTexture2D( GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              samplerType,
                              (GLuint) (uintptr_t) gpuTexture,
                              0);
      CGContextCheckBackendError( self, "glFramebufferTexture2D");

      // multisample framebuffers/textures need to be copied to
      // non-multisample first (how clumsy)
#if defined( NANOVG_GLES3_IMPLEMENTATION)
      if( samplerType == GL_TEXTURE_2D_MULTISAMPLE)
      {
         nvgResultFramebuffer = nvgluCreateFramebuffer( _vg, bitmapSize.width,
                                                             bitmapSize.height,
                                                             NVG_IMAGE_RBO_LESS);
         nvgluBindDrawFramebuffer( nvgResultFramebuffer);
         CGContextCheckBackendError( self, "nvgluBindDrawFramebuffer");
         glBindFramebuffer( GL_READ_FRAMEBUFFER, (GLuint) (uintptr_t) next.handle);
         CGContextCheckBackendError( self, "glBindFramebuffer");
         glBlitFramebuffer( 0, 0, bitmapSize.width, bitmapSize.height,
                            0, 0, bitmapSize.width, bitmapSize.height,
                            GL_COLOR_BUFFER_BIT, GL_NEAREST);
         CGContextCheckBackendError( self, "glBlitFramebuffer");
         nvgluBindFramebuffer( nvgResultFramebuffer);
      }
#endif
      glReadPixels( 0, 0,
                    bitmapSize.width,
                    bitmapSize.height,
                    GL_RGBA,
                    GL_UNSIGNED_BYTE,
                    bitmap.bytes);
      CGContextCheckBackendError( self, "glReadPixels");

#if defined( NANOVG_GLES3_IMPLEMENTATION)
      if( samplerType == GL_TEXTURE_2D_MULTISAMPLE)
      {
         nvgluBindFramebuffer( NULL);
         nvgluDeleteFramebuffer( nvgResultFramebuffer);
      }
#endif
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
   struct CGBitmap           bitmap;
   struct MulleIntegerSize   bitmapSize;
   CGBitmapEncoding          encoding;
   GLenum                    format;
   GLenum                    type;
   GLint                     samplerType;
   size_t                    size;
   NSUInteger                textureID;
   void                      *gpuTexture;

   assert( _isActive);

   encoding = CGBitmapEncodingFlipYRGBABytes;
   format   = GL_RGBA;
   type     = GL_UNSIGNED_BYTE;
   // textureID is OK here, because we don't care about repeats and stuff

   assert( [image context] == self);

   textureID = [image textureID];
   nvgImageTextureInfo( _vg, textureID, NULL, NULL, &gpuTexture);

   bitmapSize        = [image bitmapSize];
   size              = bitmapSize.width * bitmapSize.height * 4;
   assert( size);

   // nvidia seemingly has problems if rect has some off values(guess)
   // so we add something for safety (valgrinds better)
   size             += 16;
   bitmap.allocator  = allocator ? allocator : &mulle_default_allocator;
   bitmap.bytes      = mulle_allocator_malloc( bitmap.allocator, size);
   bitmap.info       = CGBitmapInfoMake( bitmapSize, 0, encoding);

   samplerType       = [image openGLSamplerType];

   glBindTexture( samplerType, (int) (intptr_t) gpuTexture);
   CGContextCheckBackendError( self, "glBindTexture");
   {
      glGetTexImage( samplerType,
                     0, // level
                     format,
                     type,
                     bitmap.bytes);
      CGContextCheckBackendError( self, "glGetTexImage");
   }
   glBindTexture( samplerType, 0);
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
   struct CGBitmap    bitmap;
   CGBitmapEncoding   encoding;
   GLenum             format;
   GLenum             type;
   size_t             size;

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
      fprintf( stderr, "CGFramebufferBitmapType %td is not supported\n", fType);
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


- (struct CGBitmap) framebufferBitmap
{
   struct CGBitmap          bitmap;
   struct CGFrameInfo       frameInfo;
   struct MulleIntegerRect  rect;

   [self getCurrentFrameInfo:&frameInfo];

   rect  = MulleIntegerRectMake( 0,
                                 0,
                                 frameInfo.window.framebufferSize.width,
                                 frameInfo.window.framebufferSize.height);
   bitmap = [self readFramebufferBitmap:rect
                  framebufferBitmapType:CGFramebufferRGBABytes
                              allocator:NULL];

   return( bitmap);
}


- (void) bindImage:(CGImage *) image
     toTextureUnit:(NSUInteger) index
{
   void   *gpuTexture;

   gpuTexture = [self gpuTextureForImageID:[image textureID]];

   assert( GL_TEXTURE15 == GL_TEXTURE0 + 15);
   glActiveTexture( GL_TEXTURE0 + index);
   CGContextCheckBackendError( self, "glActiveTexture");
   glBindTexture( [image openGLSamplerType], (GLuint) (uintptr_t) gpuTexture);
   CGContextCheckBackendError( self, "glBindTexture");
}


static BOOL  _CGContextCurrentContextIsMultiSample( CGContext *self,  GLint FBO)
{
#if defined( GL_ES_VERSION_3_0) || defined( GL_VERSION_3_0)
   GLint   samples;
   GLint   defaultRBO;
   GLint   stencilRenderbuffer;

   // Queries of default framebuffers are supported only if the GL version is
   // 4.5 or higher. Otherwise, an GL_INVALID_OPERATION error is generated.
   // shucks,  Queries of the framebuffer-dependent parameters
   // GL_SAMPLES, GL_SAMPLE_BUFFERS supported only if the GL version is 4.5
   // or higher. Double shucks.
   if( FBO == 0)
   {
      glGetIntegerv( GL_SAMPLES, &samples);
      CGContextCheckBackendError( self, "glGetIntegerv");
   }
   else
   {
      glGetIntegerv( GL_RENDERBUFFER_BINDING, &defaultRBO);
      CGContextCheckBackendError( self, "glGetIntegerv");
      glGetFramebufferAttachmentParameteriv( GL_FRAMEBUFFER,
                                             GL_STENCIL_ATTACHMENT,
                                             GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME,
                                             &stencilRenderbuffer);
      CGContextCheckBackendError( self, "glGetFramebufferAttachmentParameteriv");
      glBindRenderbuffer(GL_RENDERBUFFER, stencilRenderbuffer);
      glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_SAMPLES, &samples);
      CGContextCheckBackendError( self, "glGetRenderbufferParameteriv");
      glBindRenderbuffer(GL_RENDERBUFFER, defaultRBO);
      CGContextCheckBackendError( self, "glBindRenderbuffer");
   }
   return( samples > 1);
#else
   return( NO);
#endif
}


struct CGContextFramebuffer
   CGContextCurrentOpenGLFramebuffer( CGContext *self)
{
   BOOL    isMultiSample;
   GLint   defaultFBO;

   glGetIntegerv( GL_FRAMEBUFFER_BINDING, &defaultFBO);
   CGContextCheckBackendError( self, "glGetIntegerv");


   isMultiSample = _CGContextCurrentContextIsMultiSample( self, defaultFBO);
   return( CGContextFramebufferMakeWithOpenGLHandle( (void *) (intptr_t) defaultFBO,
                                                      isMultiSample));
}


void
   CGContextSetCurrentOpenGLFramebuffer( CGContext *self, struct CGContextFramebuffer fb)
{
   assert( fb.type == CGContextOpenGLFramebuffer
           || fb.type == CGContextDefaultFramebuffer
           || fb.type == CGContextOpenGLMultiSampleFramebuffer
           || fb.type == CGContextDefaultMultiSampleFramebuffer);

   glBindFramebuffer(GL_FRAMEBUFFER, (GLuint) (uintptr_t) fb.handle);
   CGContextCheckBackendError( self, "glBindFramebuffer");
}


struct MulleIntegerSize
   _CGContextBitmapSizeOfOpenGLFramebuffer( CGContext *self,
                                            struct CGContextFramebuffer fb)
{
#if defined( GL_ES_VERSION_3_0) || defined( GL_VERSION_3_0)
   GLint    defaultFBO;
   GLint    texture;
   GLint    width, height;
   GLint    samplerType;

   assert( fb.type == CGContextOpenGLFramebuffer
           || fb.type == CGContextDefaultFramebuffer
           || fb.type == CGContextOpenGLMultiSampleFramebuffer
           || fb.type == CGContextDefaultMultiSampleFramebuffer);

   glGetIntegerv(GL_FRAMEBUFFER_BINDING, &defaultFBO);
   glBindFramebuffer(GL_FRAMEBUFFER, (GLuint) (uintptr_t) fb.handle);
   {
      CGContextCheckBackendError( self, "glBindTexture");
      glGetFramebufferAttachmentParameteriv(GL_FRAMEBUFFER,
                                            GL_COLOR_ATTACHMENT0,
                                            GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME,
                                            &texture);
      CGContextCheckBackendError( self, "glGetFramebufferAttachmentParameteriv");
      samplerType = CGContextFramebufferIsMultiSample( fb)
                    ? GL_TEXTURE_2D_MULTISAMPLE
                    : GL_TEXTURE_2D;

      glBindTexture( samplerType, texture);
      glGetTexLevelParameteriv( samplerType, 0, GL_TEXTURE_WIDTH, &width);
      glGetTexLevelParameteriv( samplerType, 0, GL_TEXTURE_HEIGHT, &height);
      glBindTexture( samplerType, 0);

      CGContextCheckBackendError( self, "glGetTexLevelParameteriv");
   }
   glBindFramebuffer( GL_FRAMEBUFFER, defaultFBO);

   CGContextCheckBackendError( self, "glBindTexture");
   return( MulleIntegerSizeMake( width, height));
#else
   abort();
#endif
}


void   _CGContextBindFramebuffer( CGContext *self,
                                  CGContextFramebufferMode type,
                                  struct CGContextFramebuffer fb)
{
#if defined( GL_ES_VERSION_3_0) || defined( GL_VERSION_3_0)
   static GLint  glType[] = {
                              GL_FRAMEBUFFER,
                              GL_READ_FRAMEBUFFER,
                              GL_DRAW_FRAMEBUFFER
                             };
   GLuint   handle;

   assert( type >= 0 && type <= 2);

   switch( fb.type)
   {
   case CGContextDefaultFramebuffer :
   case CGContextOpenGLFramebuffer  :
   case CGContextDefaultMultiSampleFramebuffer :
   case CGContextOpenGLMultiSampleFramebuffer  :
      handle = (GLuint) (uintptr_t) fb.handle;
      break;

   case CGContextLayerFramebuffer :
   case CGContextLayerMultiSampleFramebuffer :
      handle = (GLuint) (uintptr_t) [(CGLayer *) fb.handle gpuTexture];
      break;
   }

   glBindFramebuffer( glType[ type], handle);
   CGContextCheckBackendError( self, "glBindFramebuffer");
#else
   abort();
#endif
}


void   _CGContextBlitFramebufferFramebuffer( CGContext *self,
                                             struct CGContextFramebuffer dst,
                                             CGRect rect,
                                             struct CGContextFramebuffer src,
                                             BOOL interpolate)
{
#if defined( GL_ES_VERSION_3_0) || defined( GL_VERSION_3_0)
   struct MulleIntegerSize   srcSize;
   struct MulleIntegerSize   dstSize;

   srcSize = CGContextBitmapSizeOfFramebuffer( self, src);
   dstSize = CGContextBitmapSizeOfFramebuffer( self, dst);

   // maybe overzealous
   if( MulleIntegerSizeEqualToIntegerSize( srcSize, dstSize))
      interpolate = NO;

   /* When using glBlitFramebuffer, it is not a problem to specify attachments
      that do not exist. The function will simply ignore the non-existent
      attachments and perform the blit operation on the attachments that do
      exist. This means that you can use glBlitFramebuffer to copy specific
      color, depth, or stencil buffers from one framebuffer to another,
      even if not all of these buffers exist in both framebuffers.
    */
   {
      _CGContextBindFramebuffer( self, CGContextFramebufferModeWrite, dst);
      _CGContextBindFramebuffer( self, CGContextFramebufferModeRead, src);
      glBlitFramebuffer( 0, 0, srcSize.width, srcSize.height,
                         (int) rect.origin.x, (int) rect.origin.y,
                         (int) rect.size.width, (int) rect.size.height,
                         GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT,
                         interpolate ? GL_LINEAR : GL_NEAREST);
      CGContextCheckBackendError( self, "glBlitFramebuffer");
      // return to consistent state
      _CGContextBindFramebuffer( self, CGContextFramebufferModeRead, dst);
   }
#else
   abort();
#endif
}


void   _CGContextBlitFramebufferImage( CGContext *self,
                                       struct CGContextFramebuffer dst,
                                       CGRect rect,
                                       CGImage *src,
                                       BOOL interpolate)
{
#if defined( GL_ES_VERSION_3_0) || defined( GL_VERSION_3_0)
   GLuint                        tmpFramebuffer;
   struct CGContextFramebuffer   tmpfb;
   GLuint                        samplerType;
   void                          *gpuTexture;
   BOOL                          isMultiSample;

   glGenFramebuffers( 1, &tmpFramebuffer);
   CGContextCheckBackendError( self, "glGenFramebuffers");

   isMultiSample = [src isMultiSample];
   tmpfb          = CGContextFramebufferMakeWithOpenGLHandle( (void *) (uintptr_t) tmpFramebuffer,
                                                              isMultiSample);
   samplerType = isMultiSample ? GL_TEXTURE_2D_MULTISAMPLE : GL_TEXTURE_2D;

   gpuTexture = [src gpuTexture];

   _CGContextBindFramebuffer( self, CGContextFramebufferModeDefault, tmpfb);
   glFramebufferTexture2D( GL_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           samplerType,
                           (GLuint) (uintptr_t) gpuTexture,
                           0);
   // this will bind dst
   _CGContextBlitFramebufferFramebuffer( self, dst, rect, tmpfb, interpolate);

   glDeleteFramebuffers( 1, &tmpFramebuffer);
   CGContextCheckBackendError( self, "glDeleteFramebuffers");
#else
   abort();
#endif
}



- (CGImage *) resolveMultiSampleImage:(CGImage *) image
{
   NSUInteger                    textureFlags;
   CGLayer                       *layer;
   struct CGContextFramebuffer   previous;

   assert( [image isMultiSample]);

   textureFlags  = [image textureFlags] & ~NVG_IMAGE_MSAA;
   layer         = [CGLayer layerWithBitmapSize:[image bitmapSize]
                                   textureFlags:textureFlags
                                        context:self];

   previous = [self bindFramebuffer:CGContextFramebufferMakeWithLayer( layer)];
   [self blitRect:CGRectMakeWithOriginAndSize( CGPointZero, [layer size])
            image:image
            scale:NO];
   [self bindFramebuffer:previous];

   return( layer);
}


@end
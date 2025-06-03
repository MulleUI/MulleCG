//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#define DEFINE_NANOVG_GL_IMPLEMENTATION

//
// so to actually compile nanovg on Apple we needs to tweak stuff
//
#define MULLE_CG_USE_APPLE_GL2

#import "CGContext+nanovg.h"

#import "import-private.h"

#import "CGContext+DebugPrivate.h"
#import "CGContext+OpenGL.h"
#import "CGContext+UIGraphicsDrawing.h"
//#import "CGContext+CGImage.h"
#import "CGContext+CGFramebuffer.h"
//#import "CGContext+nanovg.h"
//#import "CGLayoutContext.h"
#import "CGImage.h"
//#import "CGFramebuffer.h"
#import "CGColor.h"
#import "CGTypes.h"
#include "nanowrap.h"
#include <ctype.h>


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


@implementation CGContext( Errors)

char   *_CGNVGBackendErrorShortUTF8String( void *error)
{
   switch( (intptr_t) error)
   {
   case GL_INVALID_ENUM      : return( "GL_INVALID_ENUM");
   case GL_INVALID_VALUE     : return( "GL_INVALID_VALUE");
   case GL_INVALID_OPERATION : return( "GL_INVALID_OPERATION");
   case GL_NO_ERROR          : return( "GL_NO_ERROR");
#if ! defined( NANOVG_GLES2_IMPLEMENTATION) && ! defined( NANOVG_GLES3_IMPLEMENTATION)  && ! defined( __APPLE__)
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
#if ! defined( NANOVG_GLES2_IMPLEMENTATION) && ! defined( NANOVG_GLES3_IMPLEMENTATION) && ! defined( __APPLE__)
   case GL_STACK_OVERFLOW    : return( "This function caused a stack overflow");
   case GL_STACK_UNDERFLOW   : return( "This function caused a stack underflow");
#endif
   case GL_OUT_OF_MEMORY     : return( "There is not enough memory left to execute the function");
   case GL_INVALID_FRAMEBUFFER_OPERATION : return( "Wrong or no framebuffer selected");
   default                   : abort();
   }
}

char   *CGNVGBackendErrorUTF8String( void)
{
   GLenum   err;

   err = glGetError();
   return( _CGNVGBackendErrorUTF8String( (void *) (intptr_t) err));
}


void   _CGContextCheckBackendError( CGContext *ctxt, char *str)
{
   GLenum       err;
   static int   counter;
   char         *s;

   //
   // is that even possible to get called with a UIGraphicsBackendNone when
   // ctxt is non-NULL ? ctxt may be NULL (at least thats how it has been
   // coded in one demo, for some reason, that escapes me now)
   //
   if( ctxt && ctxt->_backend == UIGraphicsBackendNone)
      return;

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

@end


@implementation CGContextBase( nanovg)

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

@end


@implementation CGContext ( nanovg)


+ (BOOL) supportsAntiAliasing
{
#ifdef NANOVG_HAVE_MSAA
   return( YES);
#endif
   return( NO);
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



- (void) _initNanoVGWithGraphicsOptions:(UIGraphicsOptions) options
{
#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wenum-compare"
#endif
   assert( UIGraphicsSourceOver == NVG_SOURCE_OVER);
   assert( UIGraphicsXor        == NVG_XOR);
   assert( UIGraphicsCopy       == NVG_COPY);

   // Context Type assertions
   assert(CGContextTypeFull == NVG_FULL_CONTEXT);
   assert(CGContextTypePath == NVG_PATH_CONTEXT);
   assert(CGContextTypeFont == NVG_FONT_CONTEXT);

   // Winding assertions
   assert(CGWindingCCW == NVG_CCW);
   assert(CGWindingCW == NVG_CW);

   // Solidity assertions
   assert(CGSoliditySolid == NVG_SOLID);
   assert(CGSolidityHole == NVG_HOLE);

   // Line Cap assertions
   assert(CGLineCapButt == NVG_BUTT);
   assert(CGLineCapRound == NVG_ROUND);
   assert(CGLineCapSquare == NVG_SQUARE);
   assert(CGLineCapBevel == NVG_BEVEL);
   assert(CGLineCapMiter == NVG_MITER);

   // Text Align assertions
   assert(CGTextAlignLeft == NVG_ALIGN_LEFT);
   assert(CGTextAlignCenter == NVG_ALIGN_CENTER);
   assert(CGTextAlignRight == NVG_ALIGN_RIGHT);
   assert(CGTextAlignTop == NVG_ALIGN_TOP);
   assert(CGTextAlignMiddle == NVG_ALIGN_MIDDLE);
   assert(CGTextAlignBottom == NVG_ALIGN_BOTTOM);
   assert(CGTextAlignBaseline == NVG_ALIGN_BASELINE);

   // Blend Factor assertions
   assert(CGBlendFactorZero == NVG_ZERO);
   assert(CGBlendFactorOne == NVG_ONE);
   assert(CGBlendFactorSrcColor == NVG_SRC_COLOR);
   assert(CGBlendFactorOneMinusSrcColor == NVG_ONE_MINUS_SRC_COLOR);
   assert(CGBlendFactorDstColor == NVG_DST_COLOR);
   assert(CGBlendFactorOneMinusDstColor == NVG_ONE_MINUS_DST_COLOR);
   assert(CGBlendFactorSrcAlpha == NVG_SRC_ALPHA);
   assert(CGBlendFactorOneMinusSrcAlpha == NVG_ONE_MINUS_SRC_ALPHA);
   assert(CGBlendFactorDstAlpha == NVG_DST_ALPHA);
   assert(CGBlendFactorOneMinusDstAlpha == NVG_ONE_MINUS_DST_ALPHA);
   assert(CGBlendFactorSrcAlphaSaturate == NVG_SRC_ALPHA_SATURATE);

   // Composite Operation assertions
   assert(CGCompositeOperationSourceOver == NVG_SOURCE_OVER);
   assert(CGCompositeOperationSourceIn == NVG_SOURCE_IN);
   assert(CGCompositeOperationSourceOut == NVG_SOURCE_OUT);
   assert(CGCompositeOperationAtop == NVG_ATOP);
   assert(CGCompositeOperationDestinationOver == NVG_DESTINATION_OVER);
   assert(CGCompositeOperationDestinationIn == NVG_DESTINATION_IN);
   assert(CGCompositeOperationDestinationOut == NVG_DESTINATION_OUT);
   assert(CGCompositeOperationDestinationAtop == NVG_DESTINATION_ATOP);
   assert(CGCompositeOperationLighter == NVG_LIGHTER);
   assert(CGCompositeOperationCopy == NVG_COPY);
   assert(CGCompositeOperationXOR == NVG_XOR);

   // Image Flags assertions
   assert(CGImageFlagGenerateMipmaps == NVG_IMAGE_GENERATE_MIPMAPS);
   assert(CGImageFlagRepeatX == NVG_IMAGE_REPEATX);
   assert(CGImageFlagRepeatY == NVG_IMAGE_REPEATY);
   assert(CGImageFlagFlipY == NVG_IMAGE_FLIPY);
   assert(CGImageFlagPremultiplied == NVG_IMAGE_PREMULTIPLIED);
   assert(CGImageFlagNearest == NVG_IMAGE_NEAREST);
   assert(CGImageFlagMSAA == NVG_IMAGE_MSAA);
   assert(CGImageFlagRBOLess == NVG_IMAGE_RBO_LESS);

   // Tessellation assertions
   assert(CGTessellationSubdivision == NVG_TESS_SUBDIVISION);
   assert(CGTessellationAFD == NVG_TESS_AFD);

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic pop
#endif

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


- (CGImage *) resolveMultiSampleImage:(CGImage *) image
{
   NSUInteger                    textureFlags;
   CGFramebuffer                 *layer;
   struct CGContextFramebuffer   previous;

   CGContextRenderLog( "");

   assert( [image isMultiSample]);

   textureFlags  = [image textureFlags] & ~NVG_IMAGE_MSAA;
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


//
// https://stackoverflow.com/questions/3073796/how-to-use-glcopyimage2d
//
// glGetTexImage doesn’t exist in OpenGL ES 1.1 or 2.0. This means, if we
// have GLES we need to create a temporary CGFramebuffer
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
   CGPixelSize                   bitmapSize;
   size_t                        size;
   BOOL                          isMultiSample;
#if defined( NANOVG_GLES3_IMPLEMENTATION)
   NVGLUframebuffer              *nvgResultFramebuffer;
#endif

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


   glGenFramebuffers( 1, &tmpFramebuffer);
   CGContextCheckBackendError( self, "glGenFramebuffers");

   isMultiSample = [image isMultiSample];
   next          = CGContextFramebufferMakeWithOpenGLHandle( (void *) (uintptr_t) tmpFramebuffer,
                                                             isMultiSample);
   samplerType   = isMultiSample ? GL_TEXTURE_2D_MULTISAMPLE : GL_TEXTURE_2D;
   gpuTexture    = [self gpuTextureForTextureID:[image textureID]];
   previous      = [self bindFramebuffer:next];
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
   struct CGBitmap    bitmap;
   CGPixelSize        bitmapSize;
   CGBitmapEncoding   encoding;
   GLenum             format;
   GLenum             type;
   GLint              samplerType;
   size_t             size;
   NSUInteger         textureID;
   void               *gpuTexture;

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
// - (void) blitRect:(CGPixelRect) rect
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

/*
 * Read framebuffer information from GPU to CPU
 */
- (struct CGBitmap) readFramebufferBitmap:(CGPixelRect) rect
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
   size             = CGBitmapInfoGetAllocationLength( bitmap.info);
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

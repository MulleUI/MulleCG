#import "CGFramebuffer.h"

#import "CGContext.h"
#import "CGContext+Drawing.h"
#import "CGContext+DebugPrivate.h"
#import "CGContext+OpenGL.h"
#import "CGContext+Render.h"
#import "CGContext+CGFramebuffer.h"
#import "CGImage+DebugPrivate.h"

#import "import-private.h"


@implementation CGFramebuffer

+ (instancetype) framebufferWithBitmapSize:(CGPixelSize) bitmapSize
                             textureFlags:(NSUInteger) textureFlags
                           nameUTF8String:(char *) nameUTF8String
                                  context:(CGContext *) context {
    CGFramebuffer *obj;

    obj = [self alloc];
    obj = [obj initWithBitmapSize:bitmapSize
                     textureFlags:textureFlags
                   nameUTF8String:nameUTF8String
                          context:context];
    obj = [obj autorelease];
    return(obj);
}


+ (instancetype) framebufferWithBitmapSize:(CGPixelSize) bitmapSize
                             textureFlags:(NSUInteger) textureFlags
                                  context:(CGContext *) context {
    CGFramebuffer *obj;

    obj = [self alloc];
    obj = [obj initWithBitmapSize:bitmapSize
                     textureFlags:textureFlags
                   nameUTF8String:NULL
                          context:context];
    obj = [obj autorelease];
    return(obj);
}

- (instancetype) initWithBitmapSize:(CGPixelSize) bitmapSize
                       textureFlags:(NSUInteger) textureFlags
                     nameUTF8String:(char *) nameUTF8String
                            context:(CGContext *) context
{
   NVGcontext   *vg;
   NSInteger    textureID;
   int          w, h;
   int          imageFlags;

   assert( context && [context isKindOfClass:[CGContext class]]);

   if( bitmapSize.width == 0 || bitmapSize.height == 0)
   {
      [self release];
      return( nil);
   }

   vg              = CGContextGetNVGContext( context);
   _gpuFramebuffer = nvgluCreateFramebuffer( vg,
                                            bitmapSize.width,
                                            bitmapSize.height,
                                            textureFlags);
   if( ! _gpuFramebuffer)
   {
      [self release];
      return( nil);
   }

   textureID = ((NVGLUframebuffer *) _gpuFramebuffer)->image;

   // MEMO: nanovg adds some flags, so get em 
   nvgImageTextureInfo( vg, textureID, &imageFlags, NULL, NULL);
   // for completeness check if nanovg did some adaptations
   nvgImageSize( vg, textureID, &w, &h);

   textureFlags     |= imageFlags; // get FLIPY bit for example
   bitmapSize.width  = w;
   bitmapSize.height = h;

   //
   // Image is dependent on the graphics context, and can't live without it
   // TextureImage is threfore retained by the context and not the other way
   // (how long does the context live though)
   //

   CGImageLog( "create framebuffer %p with textureID %td (GPU: %p)",
                     _gpuFramebuffer,
                     textureID,
                     [context gpuTextureForImageID:textureID]);

   return( [self initWithTextureID:textureID
                        bitmapSize:bitmapSize
                      textureFlags:textureFlags
                    nameUTF8String:nameUTF8String
                           context:context]);
}


- (instancetype) initWithImage:(CGImage *) image
                  textureFlags:(NSUInteger) textureFlags
                nameUTF8String:(char *) nameUTF8String
                       context:(CGContext *) context
{
   CGPixelSize                   bitmapSize;
   struct CGContextFramebuffer   old;
   struct CGFrameInfo            frameInfo;
   struct CGFrameInfo            oldFrameInfo;
   CGRect                        rect;

   assert( [image context] == context);
   assert( [context conformsToProtocol:@protocol(UIGraphicsDrawing)]);

   bitmapSize = [image bitmapSize];
   self = [self initWithBitmapSize:bitmapSize
                      textureFlags:textureFlags
                    nameUTF8String:nameUTF8String
                           context:context];
   if( ! self)
      return( self);

   //
   // use nanovg to draw the bitmap, using OpenGL portably is just pain
   //
   frameInfo    = CGFrameInfoFBMake( bitmapSize, 1.0, 1.0);
   old          = [context bindFramebuffer:CGContextFramebufferMakeWithFramebuffer( self)];
   oldFrameInfo = [context bindRender:&frameInfo];
   {
      rect = CGRectMake( 0.0f, 0.0f, bitmapSize.width, bitmapSize.height);
      [(id <UIGraphicsDrawing>) context drawRect:rect
                                          image:image
                                           scale:1.0];
   }
   [context bindRender:&oldFrameInfo];
   [context bindFramebuffer:old];

   CGImageLog( "create framebuffer %p with textureID %td (GPU: %p)",
                     _gpuFramebuffer,
                     [self textureID],
                     [context gpuTextureForImageID:[self textureID]]);
   return( self);
}


- (instancetype) initWithContentsOfFileUTF8String:(char *) filename
                                  textureFlags:(NSUInteger) textureFlags
                                nameUTF8String:(char *) nameUTF8String
                                       context:(CGContext *) context
{
   abort();
   return( nil);
}


- (instancetype) initWithFileCData:(struct mulle_data) fileCData
                      textureFlags:(NSUInteger) textureFlags
                    nameUTF8String:(char *) nameUTF8String
                           context:(CGContext *) context
{
   abort();
   return( nil);
}


- (instancetype) initWithRGBABytes:(void *) bytes
                        bitmapSize:(CGPixelSize) bitmapSize
                      textureFlags:(NSUInteger) textureFlags
                    nameUTF8String:(char *) nameUTF8String
                           context:(CGContext *) context
{
   abort();
   return( nil);
}


- (void) didRemoveFromContext:(CGContext *) context
{
   if( _gpuFramebuffer && _context == context)
   {
      CGImageLog( "delete framebuffer %p", _gpuFramebuffer);
      // assert( [self state] & UIGraphicsContextActive);
      [context deleteGPUFramebuffer:_gpuFramebuffer];
      _gpuFramebuffer          = NULL;
      _initializedFramebuffer = NO;
   }

   [super didRemoveFromContext:context];
}


#ifdef DEBUG
- (void) dealloc
{
   assert( ! _gpuFramebuffer);
   CGImageLog( "framebuffer deallocs");
   [super dealloc];
}
#endif   
   

- (struct CGBitmap) RGBABytesBitmap:(struct mulle_allocator *) allocator
{
   return( [_context RGBABytesBitmapOfImage:self
                                  allocator:allocator]);
}


- (char *) colorizerPrefixUTF8String
{
   char        *s;
   char        *result;
   uintptr_t   hash;
   int         color;

   s = _nameUTF8String;
   if( s)
      hash = _mulle_string_hash( s);
   else
      hash  = mulle_pointer_hash( self);

   color  = (hash % (200 - 42)) + 42;
   mulle_asprintf( &result, "\033[38;5;%dm", color);;

   return( MulleObjCAutoreleaseAllocation( result, NULL));
}


/*
 * In a shared OpenGL context situation, you cannot create a framebuffer in one
 * context and then later delete it in the other. Framebuffer objects (FBOs)
 * cannot be shared between OpenGL contexts the way that vertex buffer objects
 * (VBOs), textures, and other objects can be.
 *
 * If you want to use the rendered result from one context in another context,
 * you can use a Pixel Buffer Object (PBO) to gain performant access to the
 * rendered picture, send it over to the other context through shared memory,
 * and upload it into a texture there (again through pixel buffer object).
 * PBOs are buffer objects and are shared across OpenGL contexts.
 *
 */
// so when we do a "shareWithContext" we only share the underlying texture
// - (id) shareWithContext:(id) otherContext
// {
//    [super shareWithContext:otherContext];
// }


- (CGImage *) resolvedImage
{
   if( ! _resolvedImage)
   {
      if( ! [self isMultiSample])
         return( self);

      _resolvedImage = [[_context resolveMultiSampleImage:self] retain];
   }
   return( _resolvedImage);
}


@end


@implementation CGFramebuffer( CGContentRendering)

// TODO: render with MSAA then resolve to regular texture ?
//
// That's what Cody says.
//
// // Create MSAA and regular FBOs
// glGenFramebuffers(1, &msaaFBO);
// glGenFramebuffers(1, &regularFBO);
// 
// // Create MSAA texture
// glGenTextures(1, &msaaTexture);
// glBindTexture(GL_TEXTURE_2D_MULTISAMPLE, msaaTexture);
// glTexImage2DMultisample(GL_TEXTURE_2D_MULTISAMPLE, samples, GL_RGBA8, width, height, GL_TRUE);
// 
// // Create regular texture
// glGenTextures(1, &regularTexture);
// glBindTexture(GL_TEXTURE_2D, regularTexture);
// glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
// 
// // Attach textures to FBOs
// glBindFramebuffer(GL_FRAMEBUFFER, msaaFBO);
// glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D_MULTISAMPLE, msaaTexture, 0);
// 
// glBindFramebuffer(GL_FRAMEBUFFER, regularFBO);
// glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, regularTexture, 0);
// 
// // Resolve MSAA to regular texture
// glBindFramebuffer(GL_READ_FRAMEBUFFER, msaaFBO);
// glBindFramebuffer(GL_DRAW_FRAMEBUFFER, regularFBO);
// glBlitFramebuffer(0, 0, width, height, 0, 0, width, height, GL_COLOR_BUFFER_BIT, GL_NEAREST);
//


+ (instancetype) framebufferWithBitmapSize:(CGPixelSize) size
                           backgroundColor:(CGColor) color
                              drawFunction:(void (*)( CGContext *context, CGSize size, void *userinfo)) drawFunction
                                  userInfo:(void *) userInfo
                            nameUTF8String:(char *) nameUTF8String
                                   context:(CGContext *) context
{
   CGFramebuffer                    *cgLayer;
   struct CGFramebufferRenderInfo   memo;

   assert( CGContextIsActiveInCurrentThread( context));

   if( size.width == 0 || size.height == 0)
      return( nil);

   cgLayer = [self framebufferWithBitmapSize:size
                                textureFlags:0
                              nameUTF8String:nameUTF8String
                                     context:context];
   [cgLayer beginFBRenderWithBackgroundColor:color
                            devicePixelRatio:1.0
                             layerRenderInfo:&memo];
   if( drawFunction)
      (*drawFunction)( context, CGSizeMakeWithPixelSize( size), userInfo);
   [cgLayer endFBRender:&memo];

   return( cgLayer);
}


- (void) _bindToContext
{
   assert( CGContextIsActiveInCurrentThread( _context));

   _CGContextRenderLog( _context, "->%p", _gpuFramebuffer);

   nvgluBindFramebuffer( _gpuFramebuffer);
   CGContextCheckBackendError( _context, "nvgluBindFramebuffer");
}


- (void) _unbindFromContext
{
   assert( CGContextIsActiveInCurrentThread( _context));

   _CGContextRenderLog( _context, "%p->NULL", _gpuFramebuffer);

   nvgluBindFramebuffer( NULL);
   CGContextCheckBackendError( _context, "nvgluBindFramebuffer");
   [self setInitializedFramebuffer:YES];
}


- (void) _beginFBRender:(struct CGFramebufferRenderInfo *) memo
{
   assert( memo);

   [_resolvedImage autorelease];
   _resolvedImage = nil;

   [_context flushRender];
   [_context getCurrentFrameInfo:&memo->frameInfo];
   memo->framebuffer = [_context bindFramebuffer:CGContextFramebufferMakeWithFramebuffer( self)];
}


- (void) _endFBRender:(struct CGFramebufferRenderInfo *) memo
{
   assert( memo);

   [_context flushRender];
   [_context bindFramebuffer:memo->framebuffer];
   [_context changeRender:&memo->frameInfo];
}


- (void) beginFBRenderWithBackgroundColor:(CGColor) color
                         devicePixelRatio:(CGFloat) ratio
                          layerRenderInfo:(struct CGFramebufferRenderInfo *) memo
{
#ifdef _CGLMACRO_H
   CGLContextObj  cgl_ctx = CGLGetCurrentContext();
#endif
   CGFloat             rgba[ 4];
   CGPixelSize         bitmapSize;
   struct NVGcontext   *vg;

   [self _beginFBRender:memo];

   vg = CGContextGetNVGContext( _context);

   CGColorGetRGBAComponents( color, rgba);

   bitmapSize = [self bitmapSize];
   glClearColor( rgba[ 0], rgba[ 1], rgba[ 2], rgba[ 3]);
   glClear( GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);

// this here is a little suspicious
   glViewport( 0, 0, bitmapSize.width, bitmapSize.height);

   CGContextCheckBackendError( _context, "glViewport");

// this here is also a little suspicious
   nvgBeginFrame( vg, bitmapSize.width, bitmapSize.height, ratio);
}


- (void) endFBRender:(struct CGFramebufferRenderInfo *) memo
{
//   struct NVGcontext   *vg;
//
//   vg = CGContextGetNVGContext( _context);
//
   // if we do just nvgFlushFrame here, then we don't torch font maps
   // nvgEndFrame( vg);

   // this will reset the viewport and call nvgFlushFrame
   [self _endFBRender:memo];
}

@end


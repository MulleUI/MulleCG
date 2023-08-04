#import "CGLayer.h"

#import "CGContext.h"
#import "CGContext+OpenGL.h"
#import "CGContext+Drawing.h"

#import "import-private.h"

#define CGLAYER_DEBUG


@implementation CGLayer

+ (instancetype) layerWithBitmapSize:(struct MulleIntegerSize) bitmapSize
                        textureFlags:(NSUInteger) textureFlags
                             context:(CGContext *) context
{
   return( [[[self alloc] initWithBitmapSize:bitmapSize
                                textureFlags:textureFlags
                                     context:context] autorelease]);
}


- (instancetype) initWithBitmapSize:(struct MulleIntegerSize) bitmapSize
                       textureFlags:(NSUInteger) textureFlags
                            context:(CGContext *) context
{
   NVGcontext   *vg;
   NSInteger    textureID;

   assert( context && [context isKindOfClass:[CGContext class]]);

   if( bitmapSize.width == 0 || bitmapSize.height == 0)
   {
      [self release];
      return( nil);
   }

   vg           = CGContextGetNVGContext( context);
   _framebuffer = nvgluCreateFramebuffer( vg,
                                          bitmapSize.width,
                                          bitmapSize.height,
                                          textureFlags);
   if( ! _framebuffer)
   {
      [self release];
      return( nil);
   }

   //
   // Image is dependent on the graphics context, and can't live without it
   // TextureImage is threfore retained by the context and not the other way
   // (how long does the context live though)
   //
   textureID = ((NVGLUframebuffer *) _framebuffer)->image;
#ifdef CGLAYER_DEBUG
   MulleUILog( "create framebuffer %p with textureID %td (GPU: %p)",
                     _framebuffer,
                     textureID,
                     [context gpuTextureForImageID:textureID]);

#endif
   return( [self initWithTextureID:textureID
                     textureFlags:textureFlags
                          context:context]);
}


- (instancetype) initWithImage:(CGImage *) image
                  textureFlags:(NSUInteger) textureFlags
                       context:(CGContext *) context
{
   struct MulleIntegerSize       bitmapSize;
   struct CGContextFramebuffer   old;
   struct CGFrameInfo            frameInfo;
   struct CGFrameInfo            oldFrameInfo;
   CGRect                        rect;

   assert( [image context] == context);
   assert( [context conformsToProtocol:@protocol(UIGraphicsDrawing)]);

   bitmapSize = [image bitmapSize];
   self = [self initWithBitmapSize:bitmapSize
                      textureFlags:textureFlags
                           context:context];
   if( ! self)
      return( self);

   //
   // use nanovg to draw the bitmap, using OpenGL portably is just pain
   //
   frameInfo    = CGFrameInfoFBMake( bitmapSize, 1.0, 1.0);
   old          = [context bindFramebuffer:CGContextFramebufferMakeWithLayer( self)];
   oldFrameInfo = [context bindRender:&frameInfo];
   {
      rect = CGRectMake( 0.0f, 0.0f, bitmapSize.width, bitmapSize.height);
      [(id <UIGraphicsDrawing>) context  drawRect:rect
                                            image:image
                                            scale:1.0];
   }
   [context bindRender:&oldFrameInfo];
   [context bindFramebuffer:old];

   return( self);
}


- (void) contextDidAddObject:(CGContext *) context
{
   if( _context != context)
   {
      fprintf( stderr, "CGLayers can not be copied to another context. Use -shareWithContext:");
      abort();
   }
}


- (void) contextDidRemoveObject:(CGContext *) context
{
   if( _framebuffer && _context == context)
   {
#ifdef CGLAYER_DEBUG
      MulleUILog( "delete framebuffer %p", _framebuffer);
#endif   
      // assert( [context isActive]);
      [context deleteFramebuffer:_framebuffer];
      _framebuffer = NULL;
   }

   [super contextDidRemoveObject:context];
}


#ifdef CGLAYER_DEBUG
- (void) dealloc
{
   assert( ! _framebuffer);
   MulleUILog( "layer deallocs");
   [super dealloc];
}
#endif   
   //

- (instancetype) initWithContentsOfFileCString:(char *) filename
                                  textureFlags:(NSUInteger) textureFlags
                                       context:(CGContext *) context
{
   abort();
   return( nil);
}


- (instancetype) initWithFileCData:(struct mulle_data) fileCData
                      textureFlags:(NSUInteger) textureFlags
                           context:(CGContext *) context
{
   abort();
   return( nil);
}


- (instancetype) initWithRGBABytes:(void *) bytes
                        bitmapSize:(struct MulleIntegerSize) bitmapSize
                      textureFlags:(NSUInteger) textureFlags
                           context:(CGContext *) context
{
   abort();
   return( nil);
}


- (struct CGBitmap) RGBABytesBitmap:(struct mulle_allocator *) allocator
{
   return( [_context RGBABytesBitmapOfImage:self
                                  allocator:allocator]);
}


- (void) setDebugNameUTF8String:(char *) s
{
   MulleObjCObjectSetDuplicatedUTF8String( self, &_debugNameUTF8String, s);
}


- (char *) UTF8String
{
   char        *result;
   char        *s;
   auto char   buf[ 64];
   size_t      len;
   char        *format;

   s = MulleObjCClassGetNameUTF8String( NSClassFromObject( self));
   sprintf( buf, "%p",  self);

   format = "<%s %s>";
   len    = _debugNameUTF8String ? strlen( _debugNameUTF8String) : 0;
   if( len)
   {
      format = "<%s %s \"%s\">";
      len   += 3; // < "">\0"
   }
   len    += strlen( s) + strlen( buf) + 4; // < "">\0"
   result  = mulle_malloc( len);
   sprintf( result, format, s, buf, _debugNameUTF8String);
   return( MulleObjCAutoreleaseAllocation( result, NULL));
}


- (char *) colorizerPrefixUTF8String
{
   char        *s;
   char        *result;
   uintptr_t   hash;
   int         color;

   s = _debugNameUTF8String;
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
 * In summary, you cannot directly share framebuffer objects between OpenGL
 * contexts. However, you can work around this limitation by using shared
 * textures, renderbuffers, or pixel buffer objects to transfer data between
 * contexts.
 */
// so when we do a "shareWithContext" we only share the underlying texture
// - (id) shareWithContext:(id) otherContext
// {
//    [super shareWithContext:otherContext];
// }


@end


@implementation CGLayer( CGContentRendering)


+ (instancetype) layerWithBitmapSize:(struct MulleIntegerSize) size
                     backgroundColor:(CGColor) color
                        drawFunction:(void (*)( CGContext *context, CGSize size, void *userinfo)) drawFunction
                            userInfo:(void *) userInfo
                             context:(CGContext *) context
{
   CGLayer                    *cgLayer;
   struct CGLayerRenderInfo   memo;

   assert( [context isActive]);

   if( size.width == 0 || size.height == 0)
      return( nil);

   cgLayer = [self layerWithBitmapSize:size
                          textureFlags:0
                               context:context];
   [cgLayer beginLayerRenderWithBackgroundColor:color
                               devicePixelRatio:1.0
                                layerRenderInfo:&memo];
   if( drawFunction)
      (*drawFunction)( context, CGSizeMakeWithIntegerSize( size), userInfo);
   [cgLayer endLayerRender:&memo];

   return( cgLayer);
}


- (void) _bindToContext
{
   assert( [_context isActive]);
   nvgluBindFramebuffer( _framebuffer);
}


- (void) _unbindFromContext
{
   assert( [_context isActive]);
   nvgluBindFramebuffer( NULL);
   _initializedFramebuffer = YES;
}


- (void) _beginLayerRender:(struct CGLayerRenderInfo *) memo
{
   assert( memo);

   [_context flushRender];
   [_context getCurrentFrameInfo:&memo->frameInfo];
   memo->framebuffer = [_context bindFramebuffer:CGContextFramebufferMakeWithLayer( self)];
}


- (void) _endLayerRender:(struct CGLayerRenderInfo *) memo
{
   assert( memo);

   [_context flushRender];
   [_context bindFramebuffer:memo->framebuffer];
   [_context changeRender:&memo->frameInfo];
}



- (void) beginLayerRenderWithBackgroundColor:(CGColor) color
                            devicePixelRatio:(CGFloat) ratio
                             layerRenderInfo:(struct CGLayerRenderInfo *) memo
{
   struct NVGcontext          *vg;
   CGFloat                    rgba[ 4];
   struct MulleIntegerSize    bitmapSize;

   [self _beginLayerRender:memo];

   vg = CGContextGetNVGContext( _context);

   CGColorGetRGBAComponents( color, rgba);

   bitmapSize = [self bitmapSize];
   glClearColor( rgba[ 0], rgba[ 1], rgba[ 2], rgba[ 3]);
   glClear( GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
   glViewport( 0, 0, bitmapSize.width, bitmapSize.height);

   nvgBeginFrame( vg, bitmapSize.width, bitmapSize.height, ratio);
}


- (void) endLayerRender:(struct CGLayerRenderInfo *) memo
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( _context);
   nvgEndFrame( vg);

   [self _endLayerRender:memo];
}

@end


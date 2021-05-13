#import "CGLayer.h"

#import "CGContext.h"

#import "import-private.h"



@implementation CGLayer

- (instancetype) initWithBitmapInfo:(struct MulleBitmapInfo) bitmapInfo
                            context:(CGContext *) context
                            options:(NSUInteger) options
{
   NVGcontext   *vg;

   assert( context && [context isKindOfClass:[CGContext class]]);

   vg           = [context nvgContext];
   _framebuffer = nvgluCreateFramebuffer( vg,
                                    bitmapInfo.size.width,
                                    bitmapInfo.size.height,
                                    options);
   if( ! _framebuffer)
   {
      [self release];
      return( nil);
   }
   [_context addToLayers:self];

   //
   // Image is dependent on the graphics context, and can't live without it
   // TextureImage is threfore retained by the context and not the other way
   // (how long does the context live though)
   //
   _context       = context;
   _bitmapInfo    = bitmapInfo;
   _nvgImageFlags = options;

   return( self);
}


- (int) textureIDWithContext:(CGContext *) context
{
   if( context != _context)
      return( -1);
   return( ((NVGLUframebuffer *) _framebuffer)->image);
}


- (void) finalize
{
   [_context removeFromLayers:self];
   _context = nil;

   if( _framebuffer)
   {
   	nvgluDeleteFramebuffer((NVGLUframebuffer *) _framebuffer);
      _framebuffer = NULL;
   }
   [super finalize];
}


- (struct mulle_data) readRGBACData:(struct mulle_allocator *) allocator
{
   struct mulle_data   data;

   data.length = _bitmapInfo.size.width * _bitmapInfo.size.height * 4;

   // implicity transparent background
   data.bytes  = mulle_allocator_calloc( allocator, 1, data.length);

   nvgluBindFramebuffer( _framebuffer);
   {
      glReadPixels( 0, 0,
                   _bitmapInfo.size.width,
                   _bitmapInfo.size.height,
                   GL_RGBA,
                   GL_UNSIGNED_BYTE,
                   data.bytes);
   }
   nvgluBindFramebuffer( NULL);

   return( data);
}


- (void) beginRenderWithFrameInfo:(struct MulleFrameInfo *) renderInfo
{
   // render view into a framebuffer tied to the texture
   nvgluBindFramebuffer( _framebuffer);
   [_context beginRenderWithFrameInfo:renderInfo];
   [_context clearFramebuffer];
}


- (void) endRender
{
   [_context endRender];
   nvgluBindFramebuffer( NULL);
}

@end


#import "CGLayer.h"

#import "CGContext.h"

#import "import-private.h"


@implementation CGLayer

- (instancetype) initWithBitmapInfo:(struct CGBitmapInfo) info
                         imageFlags:(NSUInteger) imageFlags
                            context:(CGContext *) context
{
   NVGcontext   *vg;

   assert( context && [context isKindOfClass:[CGContext class]]);
   assert( info.encoding == CGBitmapEncodingRGBABytes);

   vg           = CGContextGetNVGContext( context);
   _framebuffer = nvgluCreateFramebuffer( vg,
                                          info.size.width,
                                          info.size.height,
                                          imageFlags);
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
   return( [self initWithNVGImage:((NVGLUframebuffer *) _framebuffer)->image
                        imageFlags:imageFlags
                           context:context]);
}


- (void) finalize
{

   if( _framebuffer)
   {
   	nvgluDeleteFramebuffer((NVGLUframebuffer *) _framebuffer);
      _framebuffer = NULL;
   }

   // assume nvgluDeleteFramebuffer did delete the texture already
   _imageID = 0;
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


- (void) beginRender:(struct CGFrameInfo *) renderInfo
{
   // render view into a framebuffer tied to the texture
   nvgluBindFramebuffer( _framebuffer);
   [_context beginRender:renderInfo];
   [_context clearFramebuffer];  // suspect and too early ?=
}


- (void) endRender
{
   [_context endRender];
   nvgluBindFramebuffer( NULL);
}


- (instancetype) initWithContentsOfFileCString:(char *) filename
                                    imageFlags:(NSUInteger) imageFlags
                                       context:(CGContext *) context
{
   abort();
   return( nil);
}


- (instancetype) initWithFileCData:(struct mulle_data) fileCData
                        imageFlags:(NSUInteger) imageFlags
                           context:(CGContext *) context
{
   abort();
   return( nil);
}


- (instancetype) initWithRGBABytes:(void *) bytes
                        bitmapSize:(struct CGBitmapSize) bitmapSize
                        imageFlags:(NSUInteger) imageFlags
                           context:(CGContext *) context
{
   abort();
   return( nil);
}

@end


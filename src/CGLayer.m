#import "CGLayer.h"

#import "CGContext.h"

#import "import-private.h"


@implementation CGLayer

+ (instancetype) layerWithBitmapSize:(struct CGBitmapSize) bitmapSize
                         imageFlags:(NSUInteger) imageFlags
                            context:(CGContext *) context
{
   return( [[[self alloc] initWithBitmapSize:bitmapSize
                                  imageFlags:imageFlags
                                     context:context] autorelease]);
}

- (instancetype) initWithBitmapSize:(struct CGBitmapSize) bitmapSize
                         imageFlags:(NSUInteger) imageFlags
                            context:(CGContext *) context
{
   NVGcontext   *vg;

   assert( context && [context isKindOfClass:[CGContext class]]);

   vg           = CGContextGetNVGContext( context);
   _framebuffer = nvgluCreateFramebuffer( vg,
                                          bitmapSize.width,
                                          bitmapSize.height,
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


- (void) contextDidRemoveObject:(CGContext *) context
{
   [super contextDidRemoveObject:context];

   if( _framebuffer)
   {
   	nvgluDeleteFramebuffer((NVGLUframebuffer *) _framebuffer);
      _framebuffer = NULL;
   }
}


- (void) bindFramebuffer
{
   nvgluBindFramebuffer( _framebuffer);
}


- (void) unbindFramebuffer
{
   nvgluBindFramebuffer( NULL);
}


- (void *) readRGBABytes:(struct mulle_allocator *) allocator
{
   struct mulle_data   data;
   struct CGBitmapSize   bitmapSize;

   bitmapSize  = [self bitmapSize];
   data.length = bitmapSize.width * bitmapSize.height * 4;
   assert( data.length);

   // implicity transparent background
   data.bytes  = mulle_allocator_calloc( allocator, 1, data.length);

   [self bindFramebuffer];
   {
      glReadPixels( 0, 0,
                   bitmapSize.width,
                   bitmapSize.height,
                   GL_RGBA,
                   GL_UNSIGNED_BYTE,
                   data.bytes);
   }
   [self unbindFramebuffer];

   return( data.bytes);
}



- (void) beginRender:(struct CGFrameInfo *) renderInfo
{
   // render view into a framebuffer tied to the texture
   [self bindFramebuffer];
   [_context beginRender:renderInfo];
}


- (void) endRender
{
   [_context endRender];
   [self unbindFramebuffer];
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


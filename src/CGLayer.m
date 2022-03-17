#import "CGLayer.h"

#import "CGContext.h"
#import "CGContext+OpenGL.h"
#import "CGContext+Drawing.h"

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

   if( bitmapSize.width == 0 || bitmapSize.height == 0)
   {
      [self release];
      return( nil);
   }

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


- (instancetype) initWithImage:(CGImage *) image
                    imageFlags:(NSUInteger) imageFlags
                       context:(CGContext *) context
{
   struct CGBitmapSize           bitmapSize;
   struct CGContextFramebuffer   old;
   struct CGFrameInfo            frameInfo;
   struct CGFrameInfo            oldFrameInfo;

   assert( [image context] == context);

   bitmapSize = [image bitmapSize];
   self = [self initWithBitmapSize:bitmapSize
                        imageFlags:imageFlags
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
      [context drawRect:CGRectMake( 0.0f, 0.0f, bitmapSize.width, bitmapSize.height)
                  image:image
                  scale:1.0];
   }
   [context bindRender:&oldFrameInfo];
   [context bindFramebuffer:old];

   return( self);
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


- (struct CGBitmap) RGBABytesBitmap:(struct mulle_allocator *) allocator;
{
   struct mulle_data             data;
   struct CGBitmapSize           bitmapSize;
   struct CGBitmap               fb;
   size_t                        size;
   struct CGContextFramebuffer   old;

   bitmapSize  = [self bitmapSize];
   size        = bitmapSize.width * bitmapSize.height * 4;
   assert( size);

   // circumvent nvidia bug
   size        += 16;

   // implicity transparent background
   fb.info      = CGBitmapInfoMake( bitmapSize, 0, CGBitmapEncodingFlipYRGBABytes);
   fb.allocator = allocator ? allocator : &mulle_default_allocator;
   fb.bytes     = mulle_allocator_calloc( fb.allocator, 1, size);

   old = [_context bindFramebuffer:CGContextFramebufferMakeWithLayer( self)];
   {
      glReadPixels( 0, 0,
                   bitmapSize.width,
                   bitmapSize.height,
                   GL_RGBA,
                   GL_UNSIGNED_BYTE,
                   fb.bytes);
   }
   [_context bindFramebuffer:old];

   return( fb);
}

@end


@implementation CGLayer( CGContext)

- (void) bindFramebuffer
{
   assert( [_context isActive]);
   nvgluBindFramebuffer( _framebuffer);
}


- (void) unbindFramebuffer
{
   assert( [_context isActive]);
   nvgluBindFramebuffer( NULL);
}

@end

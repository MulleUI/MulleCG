#import "CGLayer.h"

#import "CGContext.h"
#import "CGContext+OpenGL.h"
#import "CGContext+Drawing.h"

#import "import-private.h"

#define CGLAYER_DEBUG

@implementation CGLayer

+ (instancetype) layerWithBitmapSize:(struct MulleIntegerSize) bitmapSize
                          imageFlags:(NSUInteger) imageFlags
                             context:(CGContext *) context
{
   return( [[[self alloc] initWithBitmapSize:bitmapSize
                                  imageFlags:imageFlags
                                     context:context] autorelease]);
}


- (instancetype) initWithBitmapSize:(struct MulleIntegerSize) bitmapSize
                         imageFlags:(NSUInteger) imageFlags
                            context:(CGContext *) context
{
   NVGcontext   *vg;
   NSInteger    imageID;

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

#ifdef CGLAYER_DEBUG
   MulleUILog( "create framebuffer %p", _framebuffer);
#endif   
   //
   // Image is dependent on the graphics context, and can't live without it
   // TextureImage is threfore retained by the context and not the other way
   // (how long does the context live though)
   //
   imageID = ((NVGLUframebuffer *) _framebuffer)->image;
   return( [self initWithNVGImage:imageID
                       imageFlags:imageFlags
                          context:context]);
}


- (instancetype) initWithImage:(CGImage *) image
                    imageFlags:(NSUInteger) imageFlags
                       context:(CGContext *) context
{
   struct MulleIntegerSize           bitmapSize;
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
#ifdef CGLAYER_DEBUG
      MulleUILog( "delete framebuffer %p", _framebuffer);
#endif   
   	nvgluDeleteFramebuffer((NVGLUframebuffer *) _framebuffer);
      _framebuffer = NULL;
   }
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
                        bitmapSize:(struct MulleIntegerSize) bitmapSize
                        imageFlags:(NSUInteger) imageFlags
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

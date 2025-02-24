#import <MulleCG/MulleCG.h>

@interface CGFakeFramebuffer : CGFramebuffer
@end


@implementation CGFakeFramebuffer

//
// avoid delayed call to nvgDeleteImage
// by clobbering -didRemoveFromContext:
//
- (void) didRemoveFromContext:(CGContext *) context
{
   assert( context == _context);

   _textureID = 0;
   _context   = nil;
}

@end



int   main( int argc, char *argv[])
{
   CGContext       *context;
   CGFramebuffer   *framebuffer;
   CGFramebuffer   *other;

   @autoreleasepool
   {
      context = [[[CGContext alloc] initWithBackend:UIGraphicsBackendNone
                                            shareID:0
                                            options:0] autorelease];

      framebuffer = [[[CGFakeFramebuffer alloc] initWithTextureID:(CGTextureID) 0x1848
                                                       bitmapSize:CGPixelSizeMake( 128, 128)
                                                     textureFlags:0
                                                          context:context] autorelease];
      [context recycleFramebuffer:framebuffer];
      other = [context acquireRecycledFramebuffer];
      if( other != framebuffer)
      {
         mulle_fprintf( stderr, "Bummer\n");
         return( 1);
      }
   }
   return( 0);
}

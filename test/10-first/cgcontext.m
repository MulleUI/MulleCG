#import <MulleCG/MulleCG.h>


int   main( int argc, char *argv[])
{
   CGContext   *context;

   @autoreleasepool
   {
      context = [[[CGContext alloc] initWithBackend:UIGraphicsBackendNone
                                            shareID:0
                                            options:0] autorelease];
   }
   return( 0);
}

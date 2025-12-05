#import <MulleCG/MulleCG.h>


@interface FakeOSContext :NSObject <UIOSGraphicsContext>
@end

@implementation FakeOSContext

- (UIGraphicsBackend) backend
{
   return( UIGraphicsBackendNone);
}

- (NSThread *) activeThread
{
   return( [NSThread currentThread]);
}

@end


int   main( int argc, char *argv[])
{
   CGContext       *context;
   FakeOSContext   *fake;

   @autoreleasepool
   {
      fake    = [FakeOSContext instance];
      context = [[[CGContext alloc] initWithOSGraphicsContext:fake
                                                      shareID:0
                                                      options:0] autorelease];
   }
   return( 0);
}

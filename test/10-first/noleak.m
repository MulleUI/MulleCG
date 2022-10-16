#import <MulleCG/MulleCG.h>


int   main( int argc, char *argv[])
{
   CGContext   *context;

   context = [[CGContext alloc] initWithBackend:UIGraphicsBackendNone
                                        shareID:0
                                        options:0];
   [context release];
   return( 0);
}

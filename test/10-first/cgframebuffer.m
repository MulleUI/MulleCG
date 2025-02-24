#import <MulleCG/MulleCG.h>


int   main( int argc, char *argv[])
{
   CGFramebuffer   *layer;

   layer = [CGFramebuffer new];
   [layer setDebugNameUTF8String:"Hello"];
   [layer release];
   return( 0);
}

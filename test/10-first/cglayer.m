#import <MulleCG/MulleCG.h>


int   main( int argc, char *argv[])
{
   CGLayer   *layer;

   layer = [CGLayer new];
   [layer setDebugNameUTF8String:"Hello"];
   [layer release];
   return( 0);
}

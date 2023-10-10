#import <MulleCG/MulleCG.h>
#import <MulleCG/CGGradient+Private.h>

#include <stdio.h>



// MEMO: autorelease troubles will be caught with NSZombieEnabled or with
//       mulle-sde test --valgrind run
int   main( int argc, char *argv[])
{
   CGGradient          *gradient;
   static CGColor      colorList[ 5] =
   {
      CGColorDataBlack,
      CGColorDataLimeGreen,
      CGColorDataBisque,
      CGColorDataCrimson,
      CGColorDataBlueViolet
   };
   static CGFloat   locationList[ 5] =
   {
      0.0,
      0.1,
      0.3,
      0.5,
      0.7
   };

   fprintf( stderr, "start: %s\n", __PRETTY_FUNCTION__);

   gradient = [[[CGGradient alloc] initWithStartColor:CGColorMakeWhite()
                                             endColor:CGColorMakeGray()] autorelease];
   gradient = [[[CGGradient alloc] initWithColors:colorList
                                        locations:NULL
                                            count:5] autorelease];
   gradient = [[[CGGradient alloc] initWithColors:colorList
                                        locations:locationList
                                            count:5] autorelease];

   fprintf( stderr, "end: %s\n", __PRETTY_FUNCTION__);
   return( 0);
}

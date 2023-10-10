#import <MulleCG/MulleCG.h>


int   main( int argc, char *argv[])
{
   CGPaint   *paint;
   CGPaint   *paint2;
   CGPaint   *paint3;
   CGPaint   *paint4;

   paint  = [CGPaint paintWithColor:CGColorMakeGray()];
   paint2 = [CGPaint paintWithStartColor:CGColorMakeGray()
                                endColor:CGColorMakeWhite()];

   paint3 = [[paint copy] autorelease];
   paint4 = [[paint2 copy] autorelease];

   return( 0);
}

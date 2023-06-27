#import <MulleCG/MulleCG.h>


void  test_gradient( CGGradient *gradient, char *name)
{
   NSUInteger   i, n;
   CGColor      color;
   CGFloat      location;

   n = [gradient numberOfColors];
   printf( "%s (%tu):\n", name, n);
   for( i = 0; i < n; i++)
   {
      location = [gradient locationAtIndex:i];
      color    = [gradient colorAtIndex:i];
      printf( "\t%tu: %g = 0x%08tX\n", i, location, CGColorGetHexColor( color));
   }
}



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

   gradient = [CGGradient object];
   test_gradient( gradient, "none");
   gradient = [CGGradient gradientWithColor:CGColorMakeBlueViolet()];
   test_gradient( gradient, "one");

   gradient = [CGGradient gradientWithStartColor:CGColorMakeWhite()
                                        endColor:CGColorMakeGray()];
   test_gradient( gradient, "two");

   gradient = [CGGradient gradientWithColors:colorList
                                   locations:NULL
                                       count:5];
   test_gradient( gradient, "multi-null");

   gradient = [CGGradient gradientWithColors:colorList
                                   locations:locationList
                                       count:5];
   test_gradient( gradient, "multi-list");

   return( 0);
}

#import <MulleCG/MulleCG.h>


// this test is just checking that paints respond to -copy, its not very 
// exciting. AI generated, human masssaged

void  print_paint( CGPaint *paint, char *name)
{
   printf( "%s (%s):\n", name, MulleObjCInstanceGetClassNameUTF8String( paint));
}


void  test_paint_copy( CGPaint *paint, char *name)
{
   CGPaint   *copy;

   print_paint( paint, name);

   copy = [[paint copy] autorelease];
   print_paint( copy, "copy");

   // Check if they are different objects but equal in value
   printf( "\tIsEqual: %s\n", [paint isEqual:copy] ? "YES" : "NO");

   printf( "\n");
}


int   main( int argc, char *argv[])
{
   // Test with a solid color paint
   CGPaint   *colorPaint;
   colorPaint = [CGPaint paintWithColor:CGColorMakeRed()];
   test_paint_copy( colorPaint, "Color Paint (Red)");

   // Test with a gradient
   CGGradient     *gradient;

   gradient = [CGGradient gradientWithStartColor:CGColorMakeBlue()
                                        endColor:CGColorMakeWhite()];
   test_paint_copy( gradient, "Gradient Paint (Blue to White)");

   // Test with multi-color gradient
   static CGColor colorList[3] = {
      CGColorDataRed,
      CGColorDataGreen,
      CGColorDataBlue
   };
   static CGFloat locationList[3] = {
      0.0,
      0.5,
      1.0
   };

   gradient = [CGGradient gradientWithColors:colorList
                                   locations:locationList
                                       count:3];
   test_paint_copy( gradient, "Gradient Paint (Multi-color)");

   CGImage   *image;

   // terrible hax to get image without a context
   image = NSAllocateObject( [CGImage class], 0, NULL);
   [image autorelease];

   test_paint_copy(image, "Image Paint");

   return(0);
}
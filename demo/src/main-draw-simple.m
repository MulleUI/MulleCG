#import "import.h"


static void   drawStuff( CALayer *layer, CGContext *context)
{
   struct NVGcontext   *vg;
   CGRect              canvas;

   vg = CGContextGetNVGContext( context);

   canvas               = [layer canvas];
   canvas.size.height  /= 3.0;

   // red stripe
   nvgBeginPath( vg);
   nvgRect( vg, canvas.origin.x,
                canvas.origin.y,
                canvas.size.width,
                canvas.size.height);
   nvgFillColor( vg, nvgRGBAf( 0.95, 0.0, 0.0, 1.0));
   nvgFill( vg);

   // white stripe
   nvgBeginPath( vg);
   nvgRect( vg, canvas.origin.x,
                canvas.origin.y + canvas.size.height * 1,
                canvas.size.width,
                canvas.size.height);
   nvgFillColor( vg, nvgRGBAf( 1.0, 1.0, 1.0, 1.0));
   nvgFill( vg);

   // blue stripe
   nvgBeginPath( vg);
   nvgRect( vg, canvas.origin.x,
                canvas.origin.y + canvas.size.height * 2,
                canvas.size.width,
                canvas.size.height);
   nvgFillColor( vg, nvgRGBAf( 0.0, 0.0, 1.0, 1.0));
   nvgFill( vg);
}


int   main( int argc, char *argv[])
{
   // convenience to the max...
   [UIApplication runWindowForDrawCallback:drawStuff
                                canvasSize:CGSizeMake( 200, 200)
                                windowSize:CGSizeZero   // CGSizeMake( 200, 400)
                           titleUTF8String:NULL
                               frameRateHz:100.0];
}

#import "import-private.h"



static void   usage( void)
{
   fprintf( stderr, "\n"
"Usage:\n"
"   aaa-demo [options]\n"
"\n"
"Options:\n"
"   -a      : disable default antialias (nvg/glfw)\n"
"   -f      : force edge antialias (nvg)\n"
"   -r      : retained\n"
"\n");
   exit( 1);
}



static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   struct NVGcontext   *vg;
   CGRect              canvas;

   vg = CGContextGetNVGContext( context);

   canvas               = [layer canvas];
   canvas.size.height  /= 3.0;

   // yellow stripe
   nvgBeginPath( vg);
   nvgRect( vg, canvas.origin.x,
                canvas.origin.y,
                canvas.size.width,
                canvas.size.height);
   nvgFillColor( vg, nvgRGBAf( 0.95, 0.95, 0.0, 1.0));
   nvgFill( vg);

   // green stripe
   nvgBeginPath( vg);
   nvgRect( vg, canvas.origin.x,
                canvas.origin.y + canvas.size.height * 1,
                canvas.size.width,
                canvas.size.height);
   nvgFillColor( vg, nvgRGBAf( 0.0, 0.95, 0.0, 1.0));
   nvgFill( vg);

   // blue stripe
   nvgBeginPath( vg);
   nvgRect( vg, canvas.origin.x,
                canvas.origin.y + canvas.size.height * 2,
                canvas.size.width,
                canvas.size.height);
   nvgFillColor( vg, nvgRGBAf( 0.5, 0.5, 0.95, 1.0));
   nvgFill( vg);

   return( YES);
}


int   main( int argc, char *argv[])
{
   CGGraphicsLayer    *layer;
   UIWindow           *window;
   NSUInteger         styleMask;
   int                i;

   styleMask = UIWindowStyleMaskDefault;

   /*
    * window and app
    */
   for( i = 1; i < argc; i++)
   {
      if( argv[ i][ 0] != '-')
         break;
      switch( argv[ i][ 1])
      {
      case 'r' :
         styleMask ^= UIWindowStyleRetained;
         break;

      case 'f' :
         styleMask ^= UIWindowStyleForceEdgeAntiAlias;
         break;

      case 'a' :
         styleMask ^= UIWindowStyleAntiAlias;
         break;

      default :
         usage();
      }
   }

   layer = [CGGraphicsLayer layerWithFrame:CGRectMake( 0, 0, 200,200)];
   [layer setDrawCallback:drawStuff];

   // need this for UIWindow to work, since it initializes glwf/SDL
   [UIApplication sharedInstance];

   window = [UIWindow windowWithLayer:layer
                      titleUTF8String:"Demo"
                            styleMask:styleMask & ~UIWindowStylePlanes];
   //[window setFrameRate:60.0];

   return( UIApplicationRunWindow( window));
}

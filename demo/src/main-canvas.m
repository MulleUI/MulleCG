#import "import-private.h"


enum
{
   even,
   odd
};


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect              canvas;
   CGPoint             point;
   int                 oddEvenStart;
   int                 oddEvenLine;
   int                 oddEvenField;

   canvas = [layer canvas];

   for( oddEvenStart = even; oddEvenStart <= odd; oddEvenStart++)
   {
      CGContextBeginPath( context);
      oddEvenLine = oddEvenStart;
      for( point.y = 0; point.y < canvas.size.height; point.y += 8)
      {
         oddEvenLine  = ! oddEvenLine;
         oddEvenField = odd;
         for( point.x = 0; point.x < canvas.size.width; point.x += 8)
         {
            oddEvenField = ! oddEvenField;
            if( oddEvenField != oddEvenLine)
               continue;
            CGContextRect( context, CGRectMake(point.x, point.y, 8, 8));
         }
      }

      if( oddEvenStart == even)
         // Fix: Use CGColorMakeWithRGBA instead of CGColorMakeWithRGBAf
         CGContextFillColor( context, CGColorMakeWithRGBA( 0.25, 1.0, 0.25, 1.0));
      else
         // Fix: Use CGColorMakeWithRGBA instead of CGColorMakeWithRGBAf
         CGContextFillColor( context, CGColorMakeWithRGBA( 1.0, 0.5, 0.0, 1.0));
      CGContextFill( context);
   }
   return( YES);
}


static void   usage( void)
{
   fprintf( stderr, "\n"
"Usage:\n"
"   canvas [options]\n"
"\n"
"Options:\n"
"   -a      : disable default antialias (nvg/glfw)\n"
"   -f      : force edge antialias (nvg)\n"
"   -r      : not retained\n"
"\n");
   exit( 1);
}


int   main( int argc, char *argv[])
{
   UIWindow       *window;
   UIApplication  *app;
   NSUInteger     styleMask;
   int            i;

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
         styleMask &= ~UIWindowStyleRetained;
         break;

      case 'f' :
         styleMask |= UIWindowStyleForceEdgeAntiAlias;
         break;

      case 'a' :
         styleMask &= ~UIWindowStyleAntiAlias;
         break;

      default :
         usage();
      }
   }

   if( i != argc)
      usage();

   app = [UIApplication sharedInstance];
   @autoreleasepool
   {
      window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 600, 400)
                                titleUTF8String:"Demo"
                                      styleMask:styleMask] autorelease];

      assert( window);
      [[window contentView] setDrawCallback:drawStuff];
      [app addWindow:window];
   }
   return( [app runApp]);
}

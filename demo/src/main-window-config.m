#define _GNU_SOURCE
#import "import-private.h"


static BOOL   g_shapeAA     = YES;
static BOOL   g_lighter     = NO;
static BOOL   g_twowin      = NO;
static BOOL   g_resetScissor = NO;
static int    g_timeout = 0;
static time_t g_startTime;

static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   if( g_timeout && (time( NULL) - g_startTime) >= g_timeout)
      exit( 0);
   CGRect   canvas;
   CGRect   rect;

   CGContextShapeAntiAlias( context, g_shapeAA);

   if( g_resetScissor)
      CGContextResetScissor( context);

   canvas = [layer canvas];

   if( g_lighter)
      CGContextGlobalCompositeOperation( context, CGCompositeOperationLighter);

   CGContextBeginPath( context);
   CGContextRect( context, canvas);
   CGContextFillColor( context, CGColorMakeGreen());
   CGContextFill( context);

   rect = CGRectInset( canvas, canvas.size.width / 4.0, canvas.size.height / 4.0);
   CGContextBeginPath( context);
   CGContextRect( context, rect);
   CGContextFillColor( context, CGColorMakeRed());
   CGContextFill( context);

   return( YES);
}

static void   usage( void)
{
   mulle_fprintf( stderr,
      "Usage: window-config [options]\n"
      "\n"
      "Options:\n"
      "  -nomsaa        disable MSAA\n"
      "  -noshapeaa     disable shape anti-alias (nvgShapeAntiAlias 0)\n"
      "  -planes        enable planes\n"
      "  -nocleartype   disable ClearType\n"
      "  -dump          dump frames to refresh-image-N.png (UIWindowDebugDumpFrameToFile)\n"
      "  -h             this help\n");
}

int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
   NSUInteger      styleMask;
   BOOL            dump = NO;
   int             i;

   styleMask = UIWindowStyleMaskDefault;
   styleMask &= ~UIWindowStylePlanes;

   for( i = 1; i < argc; i++)
   {
      if( ! strcmp( argv[ i], "-nomsaa"))
         styleMask &= ~UIWindowStyleAntiAlias;
      else if( ! strcmp( argv[ i], "-noshapeaa"))
         g_shapeAA = NO;
      else if( ! strcmp( argv[ i], "-lighter"))
         g_lighter = YES;
      else if( ! strcmp( argv[ i], "-twowin"))
         g_twowin = YES;
      else if( ! strcmp( argv[ i], "-resetscissor"))
         g_resetScissor = YES;
      else if( ! strcmp( argv[ i], "-planes"))
         styleMask |= UIWindowStylePlanes;
      else if( ! strcmp( argv[ i], "-nocleartype"))
         styleMask &= ~UIWindowStyleClearType;
      else if( ! strcmp( argv[ i], "-dump"))
         dump = YES;
      else if( ! strcmp( argv[ i], "-h") || ! strcmp( argv[ i], "--help"))
      {
         usage();
         return( 0);
      }
   }

   if( dump)
      setenv( "UIDebuggingFlags", "0x08000000", 1);

   app    = [UIApplication sharedInstance];

   if( g_twowin)
   {
      UIWindow   *win0;
      UIWindow   *win1;

      win0 = [UIWindow windowWithFrame:CGRectMake( 0, 0, 400, 300)
                       titleUTF8String:"no-shapeAA"
                             styleMask:styleMask];
      [win0 setFrameRate:UIWindowFrameRateAsync];
      [win0 setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];
      [app addWindow:win0];

      g_shapeAA = YES;
      win1 = [UIWindow windowWithFrame:CGRectMake( 0, 0, 400, 300)
                       titleUTF8String:"shapeAA"
                             styleMask:styleMask];
      [win1 setFrameRate:UIWindowFrameRateAsync];
      [win1 setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];
      [app addWindow:win1];
      return( [app runApp]);
   }

   window = [UIWindow windowWithFrame:CGRectMake( 0, 0, 400, 300)
                      titleUTF8String:"window-config"
                            styleMask:styleMask];
   [window setFrameRate:UIWindowFrameRateAsync];
   [window setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];

   return( [app runWindow:window]);
}

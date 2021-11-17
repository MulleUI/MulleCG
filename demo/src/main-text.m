#define _GNU_SOURCE

#import "import-private.h"


#define MIN_HEIGHT   5
#define MAX_HEIGHT   100
#define LOOP         1
#define TEXT         "Der VfL Bochum hat den zweiten Sieg in Folge gefeiert."


static void   drawStuff( CALayer *layer, CGContext *context)
{
   struct MulleLayout   layout;
   CGFloat              height;
   CGRect               rect;
   struct NVGcontext    *vg;
   CGRect               canvas;
   CGFont               *font;
   void                 *fonsContext;
   CGPoint              point;
   int                  atlas_w;
   int                  atlas_h;
   int                  i;

   font   = [context fontWithNameUTF8String:"sans"];
   canvas = [layer canvas];

   MulleLayoutInit( &layout, canvas, MulleEdgeInsetsZero);

   vg = CGContextGetNVGContext( context);

   nvgFontFace( vg, "sans");
   nvgTextAlign( vg, NVG_ALIGN_LEFT | NVG_ALIGN_BASELINE);
   nvgTextColor( vg, nvgRGBA( 0, 0, 0, 0xFF), nvgRGBA( 0xFF, 0xFF, 0xFF, 0xFF)); // TODO: use textColor

   for( height = MIN_HEIGHT;; height = height >= MAX_HEIGHT ? MAX_HEIGHT : height + 1)
   {
      if( LOOP)
      {
         rect = MulleLayoutAddRowWithHeight( &layout, height, MulleEdgeInsetsMakeHV( 0, 0, 2, 0));
         if( rect.size.height == 0.0)
            break;
      }
      else
      {
         rect.origin.x = CGRectGetMinX( canvas);
         rect.origin.y = CGRectGetMidY( canvas) - height / 2.0;
      }
#if 0
      nvgStrokeColor( vg, nvgRGBA( 0x80, 0, 0, 0xFF));
      nvgStrokeWidth( vg, 0.5);
      nvgBeginPath( vg);
      nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
      nvgStroke( vg);
#endif

      nvgFontSize( vg, height);
      nvgText( vg, rect.origin.x + 0.5,
                   rect.origin.y,
                   TEXT,
                   NULL);

      if( ! LOOP)
         break;
   }
}



void   setupScene( UIWindow *window)
{
   UIView        *view;
   CGRect         frame;
   UIEdgeInsets   insets;

   frame  = [[window contentPlane] contentRect];

   insets = UIEdgeInsetsMake( 30, 30, 30, 30);
   frame  = UIEdgeInsetsInsetRect( frame, insets);

   view  = [UIView viewWithFrame:frame];
   [view setMargins:insets];
   [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
   [view setDrawCallback:drawStuff];
   [[window contentPlane] addSubview:view];
}


static void   usage( void)
{
   fprintf( stderr, "\n"
"Usage:\n"
"   draw [options]\n"
"\n"
"Options:\n"
"   -i <v>  : swap interval (0-2)\n"
"   -a      : async\n"
"   -u      : no sync\n"
"   -s      : sync\n"
"   -f <hz> : refresh in hz\n"
"\n");
   exit( 1);
}

int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
   int             i;
   NSUInteger      styleMask;

   /*
    * window and app
    */
   for( i = 1; i < argc; i++)
   {
      if( argv[ i][ 0] != '-')
         break;
      switch( argv[ i][ 1])
      {
      default :
         usage();
      }
   }

   if( i != argc)
      usage();

   app = [UIApplication sharedInstance];

   @autoreleasepool
   {
      // UIWindowStyleRenderNonRetainedOnly
      styleMask = 0;
      // easier to debug with qrenderdoc
      styleMask |= UIWindowStyleRenderNonRetainedOnly;
      styleMask |= UIWindowStyleResizable;

      window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 800, 600)
                                   titleUTF8String:"Demo"
                                      styleMask:styleMask] autorelease];

      assert( window);
      [window setBackgroundColor:CGColorMakeRGBA( 1.0, 1.0, 1.0, 1.0)];
      setupScene( window);

      [app addWindow:window];
      [window renderLoop];
   }
   [app terminate];
}


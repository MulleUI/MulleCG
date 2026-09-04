//
// MSAA pixel test: single window that reads back its own window framebuffer.
// Run with different flags and compare output.
//
// Usage:
//   msaa-test         (MSAA - default)
//   msaa-test -a      (No AA)
//   msaa-test -a -f   (Edge AA)
//
#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect   canvas;

   canvas = [layer canvas];

   // black background
   CGContextFillRectWithColor( context, canvas, CGColorMakeBlack());

   // white diagonal line, 3px wide
   CGContextBeginPath( context);
   CGContextMoveTo( context, CGPointMake( 20.0, canvas.size.height - 20.0));
   CGContextLineTo( context, CGPointMake( canvas.size.width - 20.0, 20.0));
   CGContextStrokeWidth( context, 3.0);
   CGContextStrokeColor( context, CGColorMakeWhite());
   CGContextStroke( context);

   // a circle
   CGContextBeginPath( context);
   CGContextCircle( context, CACircleMakeWithCenterAndRadius(
                     CGPointMake( canvas.size.width / 2.0, canvas.size.height / 2.0),
                     42.0));
   CGContextStrokeWidth( context, 2.0);
   CGContextStrokeColor( context, CGColorMakeWhite());
   CGContextStroke( context);

   return( NO);
}


static void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame = [[window contentView] contentRect];
   view  = [UIView viewWithFrame:frame];
   [view setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];
   [[window contentView] addSubview:view];
}


static int   g_frameCount;
static char  *g_label;


static UIWindowDisplayBits   afterRender( UIPureWindow *window,
                                          id <UIGraphicsContext> context,
                                          struct CGFrameInfo *info,
                                          UIWindowDisplayBits displayBits)
{
   struct CGBitmap   bm;
   uint8_t           *pixels;
   int               i, n;
   int               black, white, gray;

   g_frameCount++;
   // wait for second frame
   if( g_frameCount != 3)
      return( displayBits);

   bm = [(id <UIGraphicsContext>) context
            readFramebufferBitmap:CGPixelRectMake( 0, 0, 128, 128)
            framebufferBitmapType:CGFramebufferRGBABytes
                        allocator:NULL];

   if( ! bm.bytes)
   {
      mulle_fprintf( stdout, "%s: readFramebufferBitmap returned nil\n", g_label);
      exit( 1);
   }

   pixels = (uint8_t *) bm.bytes;
   n      = 128 * 128;
   black  = 0;
   white  = 0;
   gray   = 0;

   for( i = 0; i < n; i++)
   {
      uint8_t r = pixels[ i * 4 + 0];
      if( r == 0)
         black++;
      else if( r >= 250)
         white++;
      else
         gray++;
   }

   mulle_fprintf( stdout, "%-8s: black=%d white=%d gray=%d (total=%d)\n",
                  g_label, black, white, gray, n);

   if( gray > 0)
   {
      int   printed = 0;
      mulle_fprintf( stdout, "  grays: ");
      for( i = 0; i < n && printed < 20; i++)
      {
         uint8_t r = pixels[ i * 4 + 0];
         if( r > 0 && r < 250)
         {
            mulle_fprintf( stdout, "%d ", (int) r);
            printed++;
         }
      }
      mulle_fprintf( stdout, "\n");
   }

   mulle_free( bm.bytes);
   return( displayBits);
}


int   main( int argc, char *argv[])
{
   UIWindow       *window;
   UIApplication  *app;
   NSUInteger     styleMask;
   int            i;

   styleMask = UIWindowStyleMaskDefault;
   g_label   = "MSAA";

   for( i = 1; i < argc; i++)
   {
      if( argv[ i][ 0] != '-')
         break;
      switch( argv[ i][ 1])
      {
      case 'f' :
         styleMask |= UIWindowStyleForceEdgeAntiAlias;
         g_label = "EdgeAA";
         break;

      case 'a' :
         styleMask &= ~UIWindowStyleAntiAlias;
         g_label = "NoAA";
         break;

      default :
         mulle_fprintf( stderr, "Usage: msaa-test [-a] [-f]\n");
         exit( 1);
      }
   }

   app = [UIApplication sharedInstance];
   @autoreleasepool
   {
      window = [[[UIWindow alloc] initWithFrame:CGRectMake( 50.0, 100.0, 128, 128)
                                titleUTF8String:g_label
                                      styleMask:styleMask] autorelease];
      assert( window);
      [window setBackgroundColor:CGColorMakeBlack()];
      [window setFrameRateHz:60.0];
      setupScene( window);
      [window setDidRenderFrameCallback:afterRender];
      [app addWindow:window];
   }
   return( [app runApp]);
}

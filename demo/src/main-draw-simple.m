#define _GNU_SOURCE

#import <MulleUICore/MulleUICore.h>

#include <string.h>
#include <time.h>



static void   drawStuff( CALayer *layer, CGContext *context)
{
   struct NVGcontext   *vg;
   CGRect              canvas;

   vg = CGContextGetNVGContext( context);

   canvas = [layer canvas];
   canvas.size.height  /= 3.0;

   nvgBeginPath( vg);
   nvgRect( vg, canvas.origin.x, 
                canvas.origin.y, 
                canvas.size.width, 
                canvas.size.height);
   nvgFillColor( vg, [UIColor redColor]);
   nvgFill( vg);

   nvgBeginPath( vg);
   nvgRect( vg, canvas.origin.x, 
                canvas.origin.y + canvas.size.height * 2, 
                canvas.size.width, 
                canvas.size.height);
   nvgFillColor( vg, [UIColor blueColor]);
   nvgFill( vg);   
}


void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame  = [[window contentPlane] contentRect];
   view   = [UIView viewWithFrame:frame];
   [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
   [view setDrawCallback:drawStuff];
   [[window contentPlane] addSubview:view];
}


int   main( int argc, char *argv[])
{
   UIWindow         *window;
   UIApplication    *app;
   NSUInteger        styleMask;

   app = [UIApplication sharedInstance];
   @autoreleasepool
   {
      // UIWindowStyleRenderNonRetainedOnly
      styleMask = 0;
//      styleMask |= UIWindowStyleRenderNonRetainedOnly;
      styleMask |= UIWindowStyleResizable;

      window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 200, 200)
                                   titleCString:"Demo"
                                      styleMask:styleMask] autorelease];

      assert( window);
      [window setBackgroundColor:CGColorMakeRGBA( 1.0, 1.0, 1.0, 1.0)];
      setupScene( window);
      [app addWindow:window];
      [window renderLoop];
   }
   [app terminate];
}

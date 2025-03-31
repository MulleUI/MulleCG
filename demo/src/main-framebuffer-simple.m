#define _GNU_SOURCE

#import "import-private.h"

#include "draw-flag.inc"

#define DEBUG_WRITE_IMAGE_PNG
//#define NO_FRAMEBUFFER


//
// This demo shows basic CGFramebuffer usage - create a framebuffer,
// draw into it, and display it on screen
//
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGFramebuffer                 *framebuffer;
   CGRect                        canvas;
   CGRect                        rect;
   struct CGFrameInfo            frameInfo;
   struct CGFrameInfo            oldFrameInfo;
   struct CGContextFramebuffer   oldFramebuffer;
   canvas = [layer canvas];
   rect   = CGRectInset( canvas, 20, 20);

   MulleUICLog( "****** >>>>>> ****** >>>>>> *******");
#ifndef NO_FRAMEBUFFER
   // Create a framebuffer matching our canvas size

   framebuffer = [CGFramebuffer framebufferWithBitmapSize:CGPixelSizeMakeWithSize( canvas.size)
                                             textureFlags:0
                                                  context:context];
   assert( framebuffer);

   oldFramebuffer = [context bindFramebuffer:CGContextFramebufferMakeWithFramebuffer( framebuffer)];
   {
      // Draw into framebuffer
      frameInfo    = CGFrameInfoFBMake( CGPixelSizeMakeWithSize( canvas.size), 1.0, 1.0);
      oldFrameInfo = [context bindRender:&frameInfo];
      {
         [context clearFramebufferWithColor:CGColorMakeOrange()];
         drawRedWhiteBlueFlag( CGContextGetNVGContext( context), rect);
      }
      // restore old frameinfo
      [context bindRender:&oldFrameInfo];
   }
   [context bindFramebuffer:oldFramebuffer];

#ifdef DEBUG_WRITE_IMAGE_PNG
   {
      static int   once;

      if( ! once)
      {
         [framebuffer writeToPNGUTF8String:"framebuffer-simple-debug.png"];
         once++;
      }
   }
#endif
   [framebuffer drawRect:canvas
                 options:NULL
                 context:context];
#else
   drawRedWhiteBlueFlag( CGContextGetNVGContext( context), rect);
#endif
   MulleUICLog( "****** <<<<<< ****** <<<<<<< *******");
   return( YES);
}


#if 1
int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 400, 300),
                                           NULL,
                                           0.0f));
}
#else
void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame  = [[window contentView] contentRect];
   view   = [UIView viewWithFrame:frame];
   [[window contentView] setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];
   [[window contentView] addSubview:view];
}


int   main( int argc, char *argv[])
{
   UIWindow         *window;
   UIApplication    *app;

   app = [UIApplication sharedInstance];
   @autoreleasepool
   {
      window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 200, 200)
                                   titleUTF8String:"Demo"
                                         styleMask:UIWindowStyleMaskDefault & ~UIWindowStyleRetained] autorelease];

      assert( window);
      [window setBackgroundColor:CGColorMakeWithRGBA( 0.5, 0.5, 0.5, 1.0)];
      setupScene( window);
      [app addWindow:window];
   }
   return( [app runApp]);
}

#endif

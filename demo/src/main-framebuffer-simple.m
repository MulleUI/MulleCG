#define _GNU_SOURCE

#import "import-private.h"

#include "draw-flag.inc"

#define DEBUG_WRITE_IMAGE_PNG
//
// This demo shows basic CGFramebuffer usage - create a framebuffer,
// draw into it, and display it on screen
//
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGFramebuffer        *framebuffer;
   CGRect               canvas;
   CGRect               rect;
   struct CGFrameInfo   frameInfo;
   struct CGFrameInfo   oldFrameInfo;
   
   canvas      = [layer canvas];
   
   // Create a framebuffer matching our canvas size
   framebuffer = [CGFramebuffer framebufferWithBitmapSize:CGPixelSizeMakeWithSize( canvas.size)
                                            textureFlags:0
                                                 context:context];
   
   // Draw into framebuffer
   frameInfo = CGFrameInfoFBMake( CGPixelSizeMakeWithSize( canvas.size), 1.0, 1.0);
   oldFrameInfo = [context bindRender:&frameInfo];
   {
      [context bindFramebuffer:CGContextFramebufferMakeWithLayer( framebuffer)];
      [context clearFramebufferWithColor:CGColorMakeWithRGBA( 0.2, 0.3, 0.3, 1.0)];
      drawRedWhiteBlueFlag( CGContextGetNVGContext( context), canvas);
   }
   [context bindRender:&oldFrameInfo];
   [context bindFramebuffer:CGContextFramebufferMakeDefault( NO)];

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
   // Draw framebuffer to screen
   rect = CGRectInset( canvas, 20, 20);
   [framebuffer drawRect:rect
                options:NULL
                context:context];

   return( YES);
}


int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 400, 300),
                                           NULL,
                                           0.0f));
}

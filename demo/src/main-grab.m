#import <MulleUICore/MulleUICore.h>

#include <assert.h>


static void   getFramebufferBitmapOfType( UIWindow *window,
                                          enum CGFramebufferBitmapType type,
                                          struct CGFramebufferBitmap *fb)
{
   CGContext   *context;

   context = [window activateWindowContext];
   *fb     = [window lastRenderedFramebufferBitmapType:type
                                               inFlight:NO
                                              allocator:NULL];
   [window deactivateWindowContext:context];
}


static void   drawFramebufferBitmap( UIWindow *window,
                                     struct CGFramebufferBitmap *fb)
{
   CGContext            *context;
   struct CGFrameInfo   info;

   context = [window activateWindowContext];
   assert( context);

   {
      [window getFrameInfo:&info];
      [context beginRender:&info];
      {
         [context clearFramebuffer];
         [context drawFramebufferBitmap:fb];
      }
      [context endRender];
      [window swapBuffers];
   }
   [window deactivateWindowContext:context];
}


static char   *title[] =
{
   "Drawing",
   "Colors",
   "Stencil",
   "Depth"
};


int   main( int argc, char *argv[])
{
   UIApplication                *app;
   UIWindow                     *window[ 4];
   CGRect                       rows[ 2];
   CGRect                       frame[ 4];
   CGContext                    *context;
   NSUInteger                   i;
   struct CGFramebufferBitmap   fb;
   struct CGFrameInfo           info;
   struct NVGcontext            *vg;

   app = [UIApplication sharedInstance];
   @autoreleasepool
   {
      CGRectPartitionVertically( CGRectMake( 0, 0, 400, 400),
                                 16.0,
                                 2,
                                 rows);
      for( i = 0; i < 2; i++)
         CGRectPartitionHorizontally( rows[ i],
                                      4.0,
                                      2,
                                      &frame[ i * 2]);
      for( i = 0; i < 4; i++)
      {
         window[ i] = [UIWindow windowWithFrame:frame[ i]
                                titleUTF8String:title[ i]
                                      styleMask:UIWindowStyleRenderNonRetainedOnly];
         [app addWindow:window[ i]];
      }

      // our self made renderloop
      for(;;)
      {
         //
         // build scene in window #1
         // as we are not doing anything with UIViews, we forego the usual
         // renderUpToNumberOfFrames:1 but do everything manually
         context = [window[ 0] activateWindowContext];
         {
            [window [0] getFrameInfo:&info];
            [context beginRender:&info];
            {
               [context clearFramebuffer];

               vg = CGContextGetNVGContext( context);
               nvgBeginPath( vg);
               {
                  nvgRect( vg, 20, 20, 40, 40);
               }
               nvgFillColor( vg, CGColorMakeWithUnsignedInteger( 0xA05030FF));
               nvgFill( vg);
            }
            [context endRender];
            [window[ 0] swapBuffers];
         }
         [window[ 0] deactivateWindowContext:context];

         // grab color info of window[ 0], display in window[ 1]
         getFramebufferBitmapOfType( window[ 0], CGFramebufferRGBABytes, &fb);
         drawFramebufferBitmap( window[ 1], &fb);
         CGFramebufferBitmapDone( &fb);

         // grab stencil info of window[ 0], display in window[ 2]
         getFramebufferBitmapOfType( window[ 0], CGFramebufferStencilFloats, &fb);
         drawFramebufferBitmap( window[ 2], &fb);
         CGFramebufferBitmapDone( &fb);

         // grab depth info of window[ 0], display in window[ 3]
         getFramebufferBitmapOfType( window[ 0], CGFramebufferDepthFloats, &fb);
         drawFramebufferBitmap( window[ 3], &fb);
         CGFramebufferBitmapDone( &fb);

         [UIEvent waitForEventsHz:INFINITY];
         if( [window[ 0] shouldClose])
            break;
      }
   }
   [app terminate];
}

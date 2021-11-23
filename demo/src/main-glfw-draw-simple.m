#import "import.h"


//
// This demo shows how to tie MulleCG and MulleGLFW together without
// MulleUICore. But what's the point ? MulleUICore is that much more
// convenient...
//
static void   drawStuff( CGRect canvas, CGContext *context)
{
   struct NVGcontext   *vg;

   vg = CGContextGetNVGContext( context);

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


@interface MyWindow : GLFWWindow

@property( retain) CGContext  *context;

@end

@implementation MyWindow
@end


//
// This needs to be implemented by the context owner. This is not a bug.
// setActive: is not supposed to be seen outside of the window setting this
// context active. (Locking is done in GLFWWindow with the implicit context!)
//
@implementation CGContext( MyWindow)

- (void) setActive:(BOOL) flag
{
   _isActive = flag;
}

@end


static void   display( GLFWWindow *window_in, struct CGFrameInfo *info)
{
   MyWindow    *window = (MyWindow *) window_in;
   CGRect      canvas;
   CGContext   *context;

   canvas.origin = CGPointZero;
   canvas.size   = [window os_windowFrame].size;

   context = [window context];

   [context beginRender:info];
   {
      drawStuff( canvas, context);
   }
   [context endRender];
}


int   main( int argc, char *argv[])
{
   UIApplication           *app;
   MyWindow                *window;
   CGContext               *context;
   enum GLFWGraphicsHints  hints;

   app = [UIApplication sharedInstance];
   @autoreleasepool
   {
      hints = GLFW_DEFAULT_CONTEXT;
      switch( [CGContext backend])
      {
      case CG_GL3   : hints = GLFW_GL3_CONTEXT; break;
      case CG_GLES2 : hints = GLFW_GLES2_CONTEXT; break;
      case CG_GLES3 : hints = GLFW_GLES3_CONTEXT; break;
      }

      window = [[[MyWindow alloc] initWithFrame:CGRectMake( 0, 0, 200, 200)
                                titleUTF8String:"Demo"
                                      styleMask:0
                                  graphicsHints:hints] autorelease];
      [window os_activateContext];

      context = [[[CGContext alloc] initWithEdgeAntialiasing:YES
                                           useStencilStrokes:YES] autorelease];
      // have to do this manually
      [context setActive:YES];

      // remember context for "display" callback
      [window setContext:context];
      [window setRenderCallback:display];

      [window renderLoopHz:100.0];
   }
   [app terminate];
}

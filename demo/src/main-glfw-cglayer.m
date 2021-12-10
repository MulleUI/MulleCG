#define _GNU_SOURCE

#import "import-private.h"
#include <mulle-testallocator/mulle-testallocator.h>

// This demo creates an invisible window to get an OpenGL context. This OpenGL
// context is "wrapped" into a CGContext (it isn't really, it's an implicit
// relationship. There is no OpenGL context pointer in CGContext, as this is
// a thread local variable most likely).
// Once we have to context, a offscreen framebuffer is created, drawn to
// (single color) and the result written to BMP file.
//
// It's very low level. In a UIWindow based setting you wouldn't use different
// code to manage CGLayers.
// That's it folks!

#define W   64
#define H   64
#define S   4     // stroke width of circle

//
// -[CGContext setActive:] needs to be implemented by the context owner.
// This is not a bug.
// setActive: is not supposed to be seen outside of the windoW, Hho sets this
// context active. (Locking is done in GLFWWindow with the implicit context!)
//
@implementation CGContext( MyWindow)

- (void) setActive:(BOOL) flag
{
   _isActive = flag;
}

@end


static void   draw( struct NVGcontext   *vg)
{
   // clearing the framebuffer is usually done by -[CGContext clearFramebuffer]
   // which uses the backgroundColor of the context
   glClearColor( 0.85, 0.0, 0.0, 1.0);
   glClear( GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);

   // glViewport and nvgBeginFrame are usually done by
   // -[CGContext beginRender],
   glViewport( 0, 0, W, H);
   nvgBeginFrame( vg, W, H, 1.0);
   {
      nvgBeginPath( vg);
      {
         nvgCircle( vg, W / 2.0 ,H / 2.0, W / 2.0 - S / 2.0);
         nvgStrokeColor( vg, CGColorMakeRGB( 0.85f, 0.85f, 0.85f));
         nvgStrokeWidth( vg, S);
      }
      nvgStroke( vg);
   }

   // nvgEndFrame is usually done by -[CGContext endRender]
   // it flushes the accumulated draw commands into the framebuffer
   nvgEndFrame( vg);
}


int   main( int argc, char *argv[])
{
   GLFWWindow          *window;
   CGContext           *context;
   CGLayer             *cgLayer;
   void                *bytes;

   // ensure that we don't leak (at least not in MulleCG) code
   // leaks in nanovg/OpenGL are harder to detect (use valgrind)
   mulle_testallocator_initialize();
   mulle_default_allocator = mulle_testallocator;
   {
      // instead of a sharedInstance we go even more low-level,
      // for no further advantage than just doing it.  +sharedInstance is
      // preferable though
      [UIApplication os_initialize];

      @autoreleasepool
      {
         // create an invisible window, we need it to be able to create a
         // CGContext
         window = [GLFWWindow windowWithFrame:CGRectMake( 0, 0, 200, 200)
                              titleUTF8String:"Demo"
                                    styleMask:UIWindowStyleInvisible
                              graphicsHints:0];

         // need to explicitly activate the "OS" context, it will be locked and
         // only available to this thread during activation
         [window os_activateContext];

         // CGContext can now use the "OS" context
         context = [[[CGContext alloc] initWithEdgeAntialiasing:YES
                                             useStencilStrokes:YES] autorelease];
         if( ! context)
         {
            fprintf( stderr, "No CGContext for you\n");
            return( 1);
         }
         [context setActive:YES];

         //
         // create a CGLayer of a certain size. This creates a bitmap on the
         // GPU, where we can draw into (a framebuffer). A CGLayer is a CGImage
         // so it can act as a texture
         //
         cgLayer = [CGLayer layerWithBitmapSize:CGBitmapSizeMake( W, H)
                                    imageFlags:0
                                       context:context];
         if( ! cgLayer)
         {
            fprintf( stderr, "No CGLayer for you\n");
            return( 1);
         }

         // bind the buffer as the drawing destination
         [cgLayer bindFramebuffer];

         // some OpenGL and NanoVG code to draw something
         draw( CGContextGetNVGContext( context));

         // afterwards we can read the contents, here we dump the with
         // mulle_rgba_dump into a BMP file named dump-0000.bmp

         bytes = [cgLayer readRGBABytes:NULL];
         mulle_rgba_dump( bytes, W, H);
         mulle_free( bytes);

         [cgLayer unbindFramebuffer];
      }

      [UIApplication os_terminate];
   }
   mulle_testallocator_reset();

   return( 0);
}




//
//                           ,╓≤æKª╨╙╙▓█D"╙╙╙*╨¥W▄╓,
//                      ╓▄ª╙└╧▓        █           ⁿ▓▓ª╦w
//                  ╓#╜^*█⌐   `╕       █           ╓▌    `╙%w
//               ╓ΦΓ      █    ╙⌐     ,█,,,Φ      ╓▌         ╙¥▄
//            ,▄▀ █▄       █µ,╓╝,╓≤╗≡≡ª╨╨╨¥≡∞╗w╓,ª█,  ,       ]▄▀V,
//          ,Φ└   ║"▀▄     ,▄▀╨"                 "╙¥▓▓       ▄▀  º▄¥,
//        ,#▌Φ▓▄╓  Φ `█Q▄M╙                           ╙¥▄ ,▄▀ ╙▄⌐`  `Φ
//       ▄▀   `V,"▀▀¼╓╩└                                 ╙¥▓╗ ,       ╙▄
//      Φ       `¥═▄▀                            ╒          ▀▄          ▓
//    .▓         ╓▓]V▄H       ▓                 ,Å            ▀,         ▀
//    █      ,-ª▓╛  `██▀½      "▄  ,╓╓╓╓;╓▄▄▄▄╗▄█,             ╙▄         ▀
//   █  `██▄   ▓. - Φ█═.~     ,≤█▄▀-      `   █└"▀▀▀▀▄╓╓╓╓       ▌    ██▄, █
//  ║⌐  " ▀   ▓╨⌐   }▀`      ,█  `           █      .█▀▄▄███▄     ▌  ` ▀    ▌
//  ▌        ▐M A   '┴      ▌                ▀        ╙█▌████▌    ╙▄        ║⌐
// ║⌐        █⌐'║▄ Γr2«    ║▀                 ▄▄▄      ╙▌▄███      █         ▌
// █]     ,▄▐H  ██████═ª  ╓` ▄█▀▀▀▀█▄        ████     ╓███` `╙╙║█  ▐H        █
// █ "% ,▄▀ ║░╠K█═╣███^   ╛╓█▀      ▐█         ,╓╓═ª╙└   █      ╙█▄▐▌▓######▌╫
// █║▄▄▄█▄▄▄║H:  "╙▀███▄╓▄,█▌╓▄,,▄∩  ██p$ΦΦ▀▀▀▀▀ΦΦΦR≡≥▄╓ ║▄       ╙j▌` ▄▀╙╗ `╫
// █"      ╙▐H-═M ▄███████¥█H "^╙    '█, ,«^``     `     ║▌        ▐M▄▀    "Φ█
// ║        !█▄▄████≤═^`╓█ █▌╓▀╦▄▀█   ╙█⌐               ╓█▌        ▓ `       █
//  ▌      ,▄██╫██ ▄█═╜" █▌▐█╣Hj⌐ █    █▌╙¥w,           ██▄       ╓▌        ▐M
//  ╢"▄▄#▀▀╙╟█Ü███▀`▀█  ║██J█▄▌jH █    ██    ╙▀W▄;    ,██  `╙w,   █▄     ,╓ █
//   █╙     ▐███▌▀█w ▀█ ╠██████j▌║█▌   ▀██▄       `╙▓██▀w,     ╙╗█'`"▀█▀╙"`║`
//   ╙▌     Φ████████▄██ ███████████    ═██▀W▄,   ╓█▀└         ╓▀ "    ╙▄ ╓▀
//    ╙▄     ╙▀███╙█▄▐██▄,╙▀█████▄▀▄▀▄   ,█M╗ ▀▄██▀╙""*ⁿ═─≈-,,▄▌,        ▄▀
//     `▌╙µ,▄Φ▀x███▄██████████▀V███▀╙└ ,▄#▌████▀`"*«,      .█▀▄▀▄,      ▄╛
//       ▀Ö█  ;▓████████▄▄█▀▄╙W "V▄██▀▀│▄███▀└ ▀╦     "*═╥▄▀ ║,  ║▀▄  ,▓
//        ╙W▀ '█████╨▀▀█████████   "▀▀████└      ╙▄   ,▄▀'   `▀▀╣H ▐▀▄▀
//          ╙▄  ▀▀Γ╓▌  ▄▀ⁿ`╙▀███      ██▌         ╓█R▀▄A█        ▀▀▄▀
//            ╙W,Φ╙  ║█        ▄╙╙ª%≡╦██≤≤╗╗≡≡╜▀▀   ╣▌   █╕     ,▄▀
//              `▀▄M█┘        ║▀▌   ╫"    *Φ▄  █       Φ` ▀▌, ▄M╙
//                 "▀╦,       M ╙▌  ▀       `█W▐▌       wæQ▄▀╙
//                     ╙▀W╥,╓╣   ╙█║        ╫M  █    ,╓▄╝╙`
//                          ╙╙▀%▄▄▄▌,≤▄_▄≡,▐▓▓▄▄#ª▀"`


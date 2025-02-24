#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>
#include <time.h>




static void   usage( void)
{
   fprintf( stderr, "\n"
"Usage:\n"
"   fps [options]\n"
"\n"
"   Flashes red when a frame was likely dropped."
"\n"
"Options:\n"
"   -i <v>  : swap interval (0-2)\n"
"   -a      : async\n"
"   -f <hz> : refresh in hz\n"
"   -m      : retained on main thread\n"
"   -r      : retained\n"
"   -u      : no sync\n"
"   -s      : sync (default)\n"
"\n");
   exit( 1);
}



@interface CustomContext : CGContext

@property( assign) mulle_absolutetime_t   previousTimestamp;
@property( assign) mulle_relativetime_t   previousElapsed;
@property( assign) mulle_relativetime_t   largestElapsed;

- (mulle_relativetime_t) frameRate;
- (mulle_relativetime_t) frameRateHz;
- (mulle_relativetime_t) refreshRate;
- (mulle_relativetime_t) refreshRateHz;
- (id <UIOSWindow>) screenOSWindow;
- (mulle_absolutetime_t) lastSwapBuffersTimestamp;
- (id <UIWindow>) parentWindow;

@end

@implementation CustomContext


- (id <UIWindow>) parentWindow
{
   id <UIOSWindow>   window;
   id <UIWindow>     parent;

   window = [self OSWindow];
   parent = [window parentWindow];
   return( parent);
}


- (id <UIOSWindow>) screenOSWindow
{
   id <UIOSWindow>   window;
   id <UIWindow>     parent;
   id <UIScreen>     screen;

   window = [self OSWindow];
   screen = [window screen];
   if( ! screen)
   {
      // get UIWindow from parentWindow if any
      parent = [window parentWindow];
      // this will be the "true" window
      window = [parent OSWindow];
   }
   return( window);
}


- (mulle_relativetime_t) frameRate
{
   id <UIOSWindow>         window;
   id <UIWindow>           parent;
   mulle_relativetime_t    frameRate;

   window    = [self screenOSWindow];
   parent    = [window parentWindow];
   frameRate = [window frameRate];

   if( frameRate == UIWindowFrameRateUnsynced)
      return( INFINITY);

   if( frameRate == UIWindowFrameRateAsync)
      return( 0.0);

   if( frameRate == UIWindowFrameRateSynced)
      return( [self refreshRate]);
   return( frameRate);
}


- (mulle_relativetime_t) frameRateHz
{
   mulle_relativetime_t    frameRate;

   frameRate = [self frameRate];
   return( frameRate == 0.0 ? 0.0 : 1.0 / frameRate);
}


- (mulle_relativetime_t) refreshRate
{
   id <UIOSWindow>         window;
   id <UIWindow>           parent;
   id <UIScreen>           screen;
   mulle_relativetime_t    refreshRate;

   window      = [self screenOSWindow];
   screen      = [window screen];
   refreshRate = [screen refreshRate];
   return( refreshRate);
}


- (mulle_relativetime_t) refreshRateHz
{
   mulle_relativetime_t    refreshRate;

   refreshRate = [self refreshRate];
   return( refreshRate == 0.0 ? 60.0 : 1.0 / refreshRate);
}


- (mulle_absolutetime_t) lastSwapBuffersTimestamp
{
   id <UIOSWindow>   window;

   window = [self screenOSWindow];
   return( [window lastSwapBuffersTimestamp]);
}


@end


static struct
{
   NSUInteger   scheduled;
   NSUInteger   immediately;
} swap_statistics;


static void  didSwapBuffersCallback( UIWindow *window, BOOL immediately)
{
   swap_statistics.scheduled   += immediately ? 0 : 1;
   swap_statistics.immediately += immediately ? 1 : 0;
}


//
// draw frame number, current time, elapsed time and calculated fps
//
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *_context)
{
   CustomContext          *context = (CustomContext *) _context;
   NVGcontext             *vg;
   NSUInteger             numberOfFrames;
   mulle_absolutetime_t   now;
   mulle_absolutetime_t   previous;
   mulle_relativetime_t   elapsed;
   mulle_relativetime_t   frameRate;
   mulle_relativetime_t   previousElapsed;
   CGRect                 canvas;
   CGRect                 rect;
   CGColor                color;

   numberOfFrames  = [context numberOfFrames];
   now             = [context lastSwapBuffersTimestamp];
   previous        = [context previousTimestamp];
   previousElapsed = [context previousElapsed];

   color           = CGColorMakeBlack();
   elapsed         = 0.0;

   // reset occasionally
   if( [context numberOfFrames] % 1000 == 999)
      [context setLargestElapsed:previousElapsed];

   if( previous != 0.0)
   {
      elapsed = now - previous;
      if( previousElapsed != 0.0)
      {
         if( fabs( elapsed - previousElapsed) > elapsed / 2.0)
            color = CGColorMakeRed();
      }
      if( elapsed > [context largestElapsed])
         [context setLargestElapsed:elapsed];
   }

   [context useFontWithNameUTF8String:"mono"];

   canvas = [layer canvas];
   vg     = CGContextGetNVGContext( context);
   mvgFillRectWithColor( vg, canvas, color);

   rect             = CGRectInset( canvas, 2, 2);
   rect.size.height = 24.0;

   mvgTextColor( vg, CGColorMakeWhite());
   mvgFontSize( vg, 24.0);

   mvgFormatInRect( vg, rect, CGContentModeTopLeft, 0, "frame         : %lu", numberOfFrames);
   rect.origin.y += rect.size.height;

   mvgFormatInRect( vg, rect, CGContentModeTopLeft, 0, "previous      : %.9f", previous);
   rect.origin.y += rect.size.height;

   mvgFormatInRect( vg, rect, CGContentModeTopLeft, 0, "now           : %.9f", now);
   rect.origin.y += rect.size.height;

   mvgFormatInRect( vg, rect, CGContentModeTopLeft, 0, "elapsed       : %.9f", elapsed);
   rect.origin.y += rect.size.height;

   mvgFormatInRect( vg, rect, CGContentModeTopLeft, 0, "elapsed (max) : %.9f", [context largestElapsed]);
   rect.origin.y += rect.size.height;

   mvgFormatInRect( vg, rect, CGContentModeTopLeft, 0, "fps           : %.9f", elapsed != 0.0 ? 1.0 / elapsed : 0.0);
   rect.origin.y += rect.size.height;

   mvgFormatInRect( vg, rect, CGContentModeTopLeft, 0, "nominal fps   : %.9f", [context frameRateHz]);
   rect.origin.y += rect.size.height;

   mvgFormatInRect( vg, rect, CGContentModeTopLeft, 0, "screen fps    : %.9f", [context refreshRateHz]);
   rect.origin.y += rect.size.height;

   mvgFormatInRect( vg, rect, CGContentModeTopLeft, 0, "swaps         : %tu", swap_statistics.scheduled);
   rect.origin.y += rect.size.height;

   mvgFormatInRect( vg, rect, CGContentModeTopLeft, 0, "extra swaps   : %tu", swap_statistics.immediately);
   rect.origin.y += rect.size.height;

   [context setPreviousTimestamp:now];
   [context setPreviousElapsed:elapsed];

   return( YES);
}



void   setupScene( UIWindow *window)
{
   UIView        *view;
   CGRect         frame;
   UIEdgeInsets   insets;

   frame  = [[window contentView] contentRect];

   insets = UIEdgeInsetsMake( 20, 20, 20, 20);
   frame  = UIEdgeInsetsInsetRect( frame, insets);

   view  = [UIView viewWithFrame:frame];
   [view setMargins:insets];
   [view setAutoresizingMask:UIViewAutoresizingScaleToFill];
   [view setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];
   [[window contentView] addSubview:view];
}



int   main( int argc, char *argv[])
{
   UIApplication          *app;
   UIWindow               *window;
   int                    i;
   mulle_relativetime_t   frameRate;
   NSUInteger             swapInterval;
   NSUInteger             styleMask;
   MulleUIPerf            *perf;
   BOOL                   isRetained;
   BOOL                   isMainThread;

   swapInterval = 0;
   frameRate    = UIWindowFrameRateSynced;
   isRetained   = NO;
   isMainThread = NO;

   /*
    * window and app
    */
   for( i = 1; i < argc; i++)
   {
      if( argv[ i][ 0] != '-')
         break;
      switch( argv[ i][ 1])
      {
      case 'a' :
         frameRate = UIWindowFrameRateAsync;
         break;

      case 'f' :
         if( ++i < argc)
            frameRate = 1 / atof( argv[ i]);
         break;

      case 'i' :
         if( ++i < argc)
            swapInterval = atoi( argv[ i]);
         break;

      case 'm' :
         isRetained   = YES;
         isMainThread = YES;
         break;

      case 'r' :
         isRetained = YES;
         break;

      case 's' :
         frameRate = UIWindowFrameRateSynced;
         break;

      case 'u' :
         frameRate = UIWindowFrameRateUnsynced;
         break;

      default :
         usage();
      }
   }

   if( i != argc)
      usage();

   [UIWindow setOSGraphicsContextClass:[CustomContext class]];
   fprintf( stderr, "%s\n", [CustomContext nanoVGBackendUTF8String]);

   app = [UIApplication sharedInstance];

   @autoreleasepool
   {
      // UIWindowStyleRenderNonRetainedOnly
      styleMask  = UIWindowStyleMaskDefault;
      if( ! isRetained)
         styleMask &= ~UIWindowStyleRetained;
      else
         if( isMainThread)
            styleMask |= UIWindowStyleRetainedOnMainThread;

      styleMask |= UIWindowStyleResizable;

      window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 800, 600)
                         titleUTF8String:"Demo"
                               styleMask:styleMask];

      assert( window);
      [window setBackgroundColor:CGColorMakeBlack()];
      [window setDidSwapBuffersCallback:didSwapBuffersCallback];
      setupScene( window);

      [window setSwapInterval:swapInterval];
      [window setFrameRate:frameRate];
      [app addWindow:window];
   }

   return( [app runApp]);
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



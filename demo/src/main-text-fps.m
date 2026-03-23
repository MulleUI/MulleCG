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

   window = MULLE_OBJC_PROTOCOL_CAST( UIOSWindow, [self OSWindow]);
   parent = MULLE_OBJC_PROTOCOL_CAST( UIWindow, [window parentWindow]);
   return( parent);
}
- (id <UIOSWindow>) screenOSWindow
{
   id <UIOSWindow>   window;
   id <UIWindow>     parent;
   id <UIScreen>     screen;

   window = MULLE_OBJC_PROTOCOL_CAST( UIOSWindow, [self OSWindow]);
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
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGFont               *font;
   CGRect               canvas;
   CGRect               rects[ 3][ 3];
   NSUInteger           x, y;
   CGRect               rect;
   char                 *s;
   //float                ascender, descender, lineh;
   char                 buf[ 256];
   float                textBounds[ 4];
   float                visualBounds[ 4];
   float                glyphBounds[ 4];
   float                bounds[ 4];
   CGPoint              origin;
   CGGlyphPosition     positions[ 32];
   int                  i;
   int                  nGlyphs;
   CGPoint              adjust;
   int                  alignment;
   NSUInteger           frameNr;
   CGContentMode        contentMode;

   frameNr   = [context numberOfFrames];
   alignment = CGTextAlignCenter | CGTextAlignMiddle; // Converted from CGTextAlignCenter | CGTextAlignMiddle

   font   = [context fontWithNameUTF8String:"sans"];

   CGContextFontSize( context, 32.0);

   canvas = [layer canvas];
   canvas = CGRectInset( canvas, 4, 4);

   CGRectPartition3x3( canvas, CGSizeMake( 4, 4), rects);

   s = "Yay! Yay! Yay! Yay! Yay! Yay! Yay!";

   for( y = 0; y < 3; y++)
   {
      for( x = 0; x < 3; x++)
      {
         rect = rects[ y][ x];
         CGContextStrokeRectWithColor( context, rect, 1.0, CGColorMakeGray()); // Converted from mvgStrokeRectWithColor

         CGContextSave( context);
         {
            CGContextScissor( context, rect);

            rect = CGRectInset( rect, 2, 2);

            CGContextCombinedTextAlignment( context, alignment);

            switch( y * 3 + x)
            {
            case 0 : contentMode = CGContentModeTopLeft; break;
            case 1 : contentMode = CGContentModeTop; break;
            case 2 : contentMode = CGContentModeTopRight; break;

            case 3 : contentMode = CGContentModeLeft; break;
            case 4 : contentMode = CGContentModeCenterPoint; break;
            case 5 : contentMode = CGContentModeRight; break;

            case 6 : contentMode = CGContentModeBottomLeft; break;
            case 7 : contentMode = CGContentModeBottom; break;
            case 8 : contentMode = CGContentModeBottomRight; break;
            }

            CGContextTextColor( context, CGColorMakeWithHSVA( (y * 3 + x) / 9.0, 1.0, 1.0, 1.0));
            CGContextTextBackgroundColor( context, CGColorMakeWhite());
            CGContextTextInRect( context, s, (size_t) -1, rect, contentMode, CGTextOptionAlignVisually); // Converted from mvgTextInRect
         }
         CGContextRestore( context);
      }
   }
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
   fprintf( stderr, "%s\n", [CustomContext backendUTF8String]);

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
// ║⌐        █⌐'║▄ Γr2«    ║▀                 ▄▄▄      ╙███` `╙╙║█  ▐H        █
// █]     ,▄▐H  ██████═ª  ╓` ▄█▀▀▀▀█▄        ██p$ΦΦ▀▀▀▀▀ΦΦΦR≡≥▄╓ ║▄       ╙j▌` ▄▀╙╗ `╫
// █ "% ,▄▀ ║░╠K█═╣███^   ╛╓█▀      ▐█         ,╓╓═ª╙└   █      ╙█▄▐▌▓######▌╫
// █║▄▄▄█▄▄▄║H:  "╙▀███▄╓▄,█▌╓▄,,▄∩  ██p$ΦΦ▀▀▀▀▀ΦΦΦR≡≥▄╓ ║▄       ╙j▌` ▄▀╙╗ `╫
// █"      ╙▐H-═M ▄███████¥█H "^╙    '█, ,«^``     `     ║▌        ▐M▄▀    "Φ█
// ║        !█▄▄████≤═^`╓█ █▌▐█╣Hj⌐ █    █▌╙¥w,           ██▄       ╓▌        ▐M
//  ▌      ,▄██╫██ ▄█═╜" █▌▐█╣Hj⌐ █    ██    ╙▀W▄;    ,██  `╙w,   █▄     ,╓ █
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

static char  *cgHAlignmentUTF8String( int alignment)
{
   switch( alignment & (CGTextAlignLeft | CGTextAlignCenter | CGTextAlignRight)) // Converted from CGTextAlignLeft | CGTextAlignCenter | CGTextAlignRight
   {
   case CGTextAlignLeft   : return( "CGTextAlignLeft"); // Converted from CGTextAlignLeft
   case CGTextAlignCenter : return( "CGTextAlignCenter"); // Converted from CGTextAlignCenter
   case CGTextAlignRight  : return( "CGTextAlignRight"); // Converted from CGTextAlignRight
   default               : return( "*invalid*");
   }
}
static char  *cgVAlignmentUTF8String( int alignment)
{
   switch( alignment & (CGTextAlignTop | CGTextAlignMiddle | CGTextAlignBottom | CGTextAlignBaseline)) // Converted from CGTextAlignTop | CGTextAlignMiddle | CGTextAlignBottom | CGTextAlignBaseline
   {
   case CGTextAlignTop      : return( "CGTextAlignTop"); // Converted from CGTextAlignTop
   case CGTextAlignMiddle   : return( "CGTextAlignMiddle"); // Converted from CGTextAlignMiddle
   case CGTextAlignBottom   : return( "CGTextAlignBottom"); // Converted from CGTextAlignBottom
   case CGTextAlignBaseline : return( "CGTextAlignBaseline"); // Converted from CGTextAlignBaseline
   default                 : return( "*invalid*");
   }
}

#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>
#include <time.h>

#define DRAW_ALPHA
#define DRAW_RECT
#define DRAW_LINES
//#define ARTIFICIAL_LAG



#define LAG_FRAMES    2

static void   lag( long refreshRate)
{
   struct timespec   sleep;
   long              nsperframe;

   nsperframe    = (1000000000L + (refreshRate - 1)) / refreshRate;
   sleep.tv_sec  = 0.0;
   sleep.tv_nsec = (long) round( nsperframe * LAG_FRAMES);
   nanosleep( &sleep, NULL);
}

// Topics:
//  * create a window
//  * place view inside window
//  * add drawing C code to the views layer to produce the graphics
//  * run renderloop (with event handling)
//  * shows differences for pixel alignment and antialiasing
//
static void   _drawAlpha( CGContext *context, // Changed from NVGcontext *vg
                          CGRect rect,
                          int antialias)
{
   struct NVGcontext *vg = CGContextGetNVGContext( context); // Get vg from context

   rect.size.width  -= 50;
   rect.size.height -= 50;

   nvgShapeAntiAlias( vg, antialias);
   nvgStrokeWidth( vg, 10.0);

   nvgBeginPath( vg);
   nvgRoundedRect( vg, rect.origin.x,
                       rect.origin.y,
                       rect.size.width,
                       rect.size.height,
                       20);
   nvgStrokeColor(vg, CGColorMakeWithHexColor( 0x8080007F));
   nvgStroke( vg);

   nvgBeginPath( vg);
   nvgRoundedRect( vg, rect.origin.x + 50,
                       rect.origin.y,
                       rect.size.width,
                       rect.size.height,
                       20);
   nvgStrokeColor(vg, CGColorMakeWithHexColor( 0x0080807F));
   nvgStroke( vg);

   nvgBeginPath( vg);
   nvgRoundedRect( vg, rect.origin.x + 50,
                       rect.origin.y + 50,
                       rect.size.width,
                       rect.size.height,
                       20);
   nvgStrokeColor(vg, CGColorMakeWithHexColor( 0x8000807F));
   nvgStroke( vg);

   nvgBeginPath( vg);
   nvgRoundedRect( vg, rect.origin.x,
                       rect.origin.y + 50,
                       rect.size.width,
                       rect.size.height,
                       20);
   nvgStrokeColor(vg, CGColorMakeWithHexColor( 0x8080807F));
   nvgStroke( vg);

   nvgShapeAntiAlias( vg, 1);
}



static void   _drawRects( CGContext *context, // Changed from NVGcontext *vg
                          CGRect rect,
                          CGColor color,
                          int antialias,
                          CGFloat thickness)
{
   struct NVGcontext *vg = CGContextGetNVGContext( context); // Get vg from context

   nvgShapeAntiAlias( vg, antialias);
   nvgStrokeWidth( vg, thickness);

   nvgBeginPath( vg);
   nvgRoundedRect( vg, rect.origin.x,
                       rect.origin.y,
                       rect.size.width,
                       rect.size.height,
                       20);
   nvgStrokeColor(vg, color);
   nvgStroke( vg);

   nvgShapeAntiAlias( vg, 1);
}

static NSInteger   lines;

static void   _drawColoredLinesH( CGContext *context, // Changed from NVGcontext *vg
                                  CGRect rect,
                                  int antialias,
                                  CGFloat thickness)
{
   struct NVGcontext *vg = CGContextGetNVGContext( context); // Get vg from context
   CGPoint      point;
   NSUInteger   i;
   CGFloat      h;

   nvgShapeAntiAlias( vg, antialias);
   nvgStrokeWidth( vg, thickness);

   h = rect.size.height / 8;

   for( point.x = rect.origin.x; point.x < CGRectGetMaxX( rect); point.x += 2.0)
   {
      point.y = rect.origin.y;
      for( i = 0; i < 8; i++)
      {
         nvgBeginPath( vg);

         nvgMoveTo(vg, point.x, point.y);
         point.y += h;
         nvgLineTo(vg, point.x, point.y);
         switch( i)
         {
         case 0 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xFFFFFFFF)); break;
         case 1 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xFF0000FF)); break;
         case 2 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x00FF00FF)); break;
         case 3 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x0000FFFF)); break;
         case 4 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xFFFF00FF)); break;
         case 5 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xFF00FFFF)); break;
         case 6 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x00FFFFFF)); break;
         case 7 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xFFFFFFFF)); break;
         }
         nvgStroke( vg);
         if( lines >= 0)
            ++lines;
      }
   }

   nvgShapeAntiAlias( vg, 1);
}


static void   _drawColoredLinesV( CGContext *context, // Changed from NVGcontext *vg
                                  CGRect rect,
                                  int antialias,
                                  CGFloat thickness)
{
   struct NVGcontext *vg = CGContextGetNVGContext( context); // Get vg from context
   CGPoint      point;
   NSUInteger   i;
   CGFloat      w;

   nvgShapeAntiAlias( vg, antialias);
   nvgStrokeWidth( vg, thickness);

   w = rect.size.width / 8;

   for( point.y = rect.origin.y; point.y < CGRectGetMaxY( rect); point.y += 2.0)
   {
      point.x = rect.origin.x;
      for( i = 0; i < 8; i++)
      {
         nvgBeginPath( vg);

         nvgMoveTo(vg, point.x, point.y);
         point.x += w;
         nvgLineTo(vg, point.x, point.y);
         switch( i)
         {
         case 0 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xFFFFFFFF)); break;
         case 1 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xFF0000FF)); break;
         case 2 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x00FF00FF)); break;
         case 3 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x0000FFFF)); break;
         case 4 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xFFFF00FF)); break;
         case 5 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xFF00FFFF)); break;
         case 6 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x00FFFFFF)); break;
         case 7 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xFFFFFFFF)); break;
         }
         nvgStroke( vg);
         if( lines >= 0)
            ++lines;
      }
   }

   nvgShapeAntiAlias( vg, 1);
}


static void   _drawColoredLinesHV( CGContext *context, // Changed from NVGcontext *vg
                                   CGRect rect,
                                   int antialias,
                                   CGFloat thickness)
{
   struct NVGcontext *vg = CGContextGetNVGContext( context); // Get vg from context
   CGPoint      point;
   NSUInteger   i;
   CGFloat      w;

   nvgShapeAntiAlias( vg, antialias);
   nvgStrokeWidth( vg, thickness);
   nvgSave( vg);
   nvgScissor( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
   nvgTranslate(vg, rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0);
   nvgRotate(vg, 0.9 * NVG_PI*2);
   nvgTranslate(vg, -rect.origin.x - rect.size.width / 2.0, -rect.origin.y - rect.size.height / 2.0);

   w = rect.size.width / 8;

   for( point.y = rect.origin.y; point.y < CGRectGetMaxY( rect); point.y += 2.0)
   {
      point.x = rect.origin.x;
      for( i = 0; i < 8; i++)
      {
         nvgBeginPath( vg);

         nvgMoveTo(vg, point.x, point.y);
         point.x += w;
         nvgLineTo(vg, point.x, point.y);
         switch( i)
         {
         case 0 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xFFFFFFFF)); break;
         case 1 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xFF0000FF)); break;
         case 2 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x00FF00FF)); break;
         case 3 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x0000FFFF)); break;
         case 4 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xFFFF00FF)); break;
         case 5 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xFF00FFFF)); break;
         case 6 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x00FFFFFF)); break;
         case 7 : nvgStrokeColor( vg, CGColorMakeWithHexColor( 0xFFFFFFFF)); break;
         }
         nvgStroke( vg);
         if( lines >= 0)
            ++lines;
      }
   }
   nvgRestore( vg);

   nvgShapeAntiAlias( vg, 1);
}


static void   _drawColoredLines( CGContext *context, // Changed from NVGcontext *vg
                                 CGRect rect,
                                 int antialias,
                                 CGFloat thickness)
{
   CGRect   rows[ 2];
   CGRect   columns[ 2];

   CGRectPartitionVertically( rect, 2, 2, rows);

   CGRectPartitionHorizontally( rows[ 0], 2, 2, columns);

   _drawColoredLinesH( context, columns[ 0], antialias, thickness); // Pass context
   _drawColoredLinesV( context, columns[ 1], antialias, thickness); // Pass context

   CGRectPartitionHorizontally( rows[ 1], 2, 2, columns);

   _drawColoredLinesHV( context, columns[ 0], antialias, thickness); // Pass context
}


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect              rows[ 3];
   CGRect              columns[ 8];
   CGRect              subrows[ 2];
   CGRect              rect;
   UIEdgeInsets        insets;
   NSUInteger          i;
   NSUInteger          j;
   struct NVGcontext   *vg;
   CGColor             fore;
   CGColor             back;
   CGRect              canvas;

   vg = CGContextGetNVGContext( context);

   canvas = [layer canvas];
   CGRectPartitionVertically( canvas, 8, 3, rows);

   // draw antialias demo shape on white
   CGRectPartitionHorizontally( rows[ 0], 8, 4, columns);

   for( i = 0; i < 4; i++)
   {
      nvgStrokeWidth( vg, 1.0);
      nvgBeginPath( vg);
      nvgStrokeColor( vg, CGColorMakeWithHexColor( 0x808080FF));
      nvgRoundedRect( vg, columns[ i].origin.x,
                          columns[ i].origin.y,
                          columns[ i].size.width,
                          columns[ i].size.height,
                          3);
      nvgStroke( vg);

      rect = CGSizeCenterInRect( CGSizeMake( 150, 150), columns[ i]);
      rect = CGRectIntegral( rect);

      if( i & 1)
      {
         rect.origin.x += 0.5;
         rect.origin.y += 0.5;
      }
#ifdef DRAW_ALPHA
      _drawAlpha( context, rect, i >= 2); // Pass context
#endif
   }

   // draw single lines of width 1 on black
   CGRectPartitionHorizontally( rows[ 1], 8, 8, columns);
   for( i = 0; i < 8; i++)
   {
      CGRectPartitionVertically( columns[ i], 8, 2,subrows);

      for( j = 0; j < 2; j++)
      {
         if( j == 0)
         {
            fore = CGColorMakeWithHexColor( 0xFFFFFFFF);
            back = CGColorMakeWithHexColor( 0x000000FF);
         }
         else
         {
            back = CGColorMakeWithHexColor( 0xFFFFFFFF);
            fore = CGColorMakeWithHexColor( 0x000000FF);
         }

         nvgStrokeWidth( vg, 1.0);
         nvgBeginPath( vg);
         nvgStrokeColor( vg, fore);
         nvgFillColor( vg, back);
         nvgRoundedRect( vg, subrows[ j].origin.x,
                             subrows[ j].origin.y,
                             subrows[ j].size.width,
                             subrows[ j].size.height,
                             3);
         nvgStroke( vg);
         nvgFill( vg);

         insets = UIEdgeInsetsMake( 10, 10, 10, 10);
         rect   = UIEdgeInsetsInsetRect( subrows[ j], insets);
         rect   = CGRectIntegral( rect);

         if( i & 1)
         {
            rect.origin.x += 0.5;
            rect.origin.y += 0.5;
         }
#ifdef DRAW_RECT
         _drawRects( context, rect, fore, i >= 2, i >= 4 ? 0.5 : 1.0); // Pass context
#endif
      }
   }

   // draw colored lines

   // draw single lines of width 1 on black
   CGRectPartitionHorizontally( rows[ 2], 8, 8, columns);
   for( i = 0; i < 8; i++)
   {
      CGRectPartitionVertically( columns[ i], 8, 2, subrows);

      for( j = 0; j < 2; j++)
      {
         if( j == 0)
         {
            fore = CGColorMakeWithHexColor( 0xFFFFFFFF);
            back = CGColorMakeWithHexColor( 0x000000FF);
         }
         else
         {
            back = CGColorMakeWithHexColor( 0xFFFFFFFF);
            fore = CGColorMakeWithHexColor( 0x000000FF);
         }

         nvgStrokeWidth( vg, 1.0);
         nvgBeginPath( vg);
         nvgStrokeColor( vg, fore);
         nvgFillColor( vg, back);
         nvgRoundedRect( vg, subrows[ j].origin.x,
                             subrows[ j].origin.y,
                             subrows[ j].size.width,
                             subrows[ j].size.height,
                             3);
         nvgStroke( vg);
         nvgFill( vg);

         insets = UIEdgeInsetsMake( 10, 10, 10, 10);
         rect   = UIEdgeInsetsInsetRect( subrows[ j], insets);
         rect   = CGRectIntegral( rect);

         if( i & 1)
         {
            rect.origin.x += 0.5;
            rect.origin.y += 0.5;
         }
#ifdef DRAW_LINES
         _drawColoredLines( context, rect, i >= 2, i >= 4 ? 0.5 : 1.0); // Pass context
#endif
      }
      if( lines > 0)
      {
         fprintf( stderr, "lines drawn: %ld\n", lines);
         lines = -1;
      }
   }
#ifdef ARTIFICIAL_LAG
   lag( info->refreshRate);
#endif

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


static void   usage( void)
{
   fprintf( stderr, "\n"
"Usage:\n"
"   draw [options]\n"
"\n"
"Options:\n"
"   -i <v>  : swap interval (0-2)\n"
"   -a      : async\n"
"   -f <hz> : refresh in hz\n"
"   -m      : retained on main thread\n"
"   -r      : retained\n"
"   -u      : no sync\n"
"   -s      : sync\n"
"\n");
   exit( 1);
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
   frameRate    = UIWindowFrameRateAsync;
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
      [window setBackgroundColor:CGColorMakeWithRGBA( 1.0, 1.0, 1.0, 1.0)];
      setupScene( window);

      [window setSwapInterval:swapInterval];
      [window setFrameRate:frameRate];

      perf = [MulleUIPerf object];
      [window setFrameDelegate:perf];

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
// █]     ,▄▐H  ██████═ª  ╓` ▄█▀▀▀▀█▄        ████     ╓███` `╙╙║█  ▐H        █
// █ "% ,▄▀ ║░╠K█═╣███^   ╛╓█▀      ▐█         ,╓╓═ª╙└   █      ╙█▄▐▌▓######▌╫
// █║▄▄▄█▄▄▄║H:  "╙▀███▄╓▄,█▌╓▄,,▄∩  ██p$ΦΦ▀▀▀▀▀ΦΦΦR≡≥▄╓ ║▄       ╙j▌` ▄▀╙╗ `╫
// █"      ╙▐H-═M ▄███████¥█H "^╙    '█, ,«^``     `     ║▌        ▐M▄▀    "Φ█
// ║        !█▄▄████≤═^`╓█ █▌╓▀╦▄▀█   ╙█⌐               ╓█▌        ▓ `       █
//  ▌      ,▄██╫██ ▄█═╜" █▌▐█╣Hj⌐ █    █▌╙¥w,           ██▄       ╓▌        ▐M
//  ╢"▄▄#▀▀╙╟█Ü███▀`▀█  ╠██████j▌║█▌   ▀██▄       `╙▓██▀w,     ╙╗█'`"▀█▀╙"`║`
//   █╙     ▐███▌▀█w ▀█ ╠██████j▌║█▌   ▀██▄       `╙▓██▀w,     ╙╗█'`"▀█▀╙"`║`
//   ╙▌     Φ████████▄██ ███████████    ═██▀W▄,   ╓█▀└         ╓▀ "    ╙▄ ╓▀
//    ╙▄     ╙▀███╙█▄▐██▄,╙▀█████▄▀▄▀▄   ,█M╗ ▀▄██▀╙""*ⁿ═─≈-,,▄▌,        ▄▀
//     `▌╙µ,▄Φ▀x███▄██████████▀V███▀╙└ ,▄#▌████▀`"*«,      .█▀▄▀▄,      ▄╛
//       ▀Ö█  ;▓████████▄▄█▀▄╙W "V▄██▀▀│▄███▀└ ▀╦     "*═╥▄▀ ║,  ║▀▄  ,▓
//        ╙W▀ '█████╨▀▀█████████   "▀▀████└      ╙▄   ,▄▀'   `▀▀╣H ▐▀▄▀
//          ╙▄  Φ▀╓▌  ▄▀ⁿ`╙▀███      ██▌         ╓█R▀▄A█        ▀▀▄▀
//            ╙W,Φ╙  ║█        ▄╙╙ª%≡╦██≤≤╗╗≡≡╜▀▀   ╣▌   █╕     ,▄▀
//              `▀▄M█┘        ║▀▌   ╫"    *Φ▄  █       Φ` ▀▌, ▄M╙
//                 "▀╦,       M ╙▌  ▀       `█W▐▌       wæQ▄▀╙
//                     ╙▀W╥,╓╣   ╙█║        ╫M  █    ,╓▄╝╙`
//                          ╙╙▀%▄▄▄▌,≤▄_▄≡,▐▓▓▄▄#ª▀"`





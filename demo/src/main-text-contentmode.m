#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>


static int   contentMode[] =
{
   CGContentModeTopLeft,
   CGContentModeTop,
   CGContentModeTopRight,
   CGContentModeLeft,
   CGContentModeCenterPoint,
   CGContentModeRight,
   CGContentModeBottomLeft,
   CGContentModeBottom,
   CGContentModeBottomRight
};
#define N_CONTENT_MODES    (sizeof( contentMode) / sizeof( contentMode[ 0]))


static char   *contentMode_text[] =
{
   "CGContentModeTopLeft",
   "CGContentModeTop",
   "CGContentModeTopRight",
   "CGContentModeLeft",
   "CGContentModeCenterPoint",
   "CGContentModeRight",
   "CGContentModeBottomLeft",
   "CGContentModeBottom",
   "CGContentModeBottomRight"
};
#define N_CONTENT_MODES   (sizeof( contentMode) / sizeof( contentMode[ 0]))


static int   contentMode2[] =
{
   CGContentModeScaleToFill,
   CGContentModeScaleAspectFit,
   CGContentModeScaleAspectFill
};
#define N_CONTENT_MODES2   (sizeof( contentMode2) / sizeof( contentMode2[ 0]))


static char   *contentMode2_text[] =
{
   "Fill",
   "AspectFit",
   "AspectFill"
};


static int   alignMode[] =
{
   MVGTextDefault,
   MVGTextAlignVisually,
   MVGTextAlignBaseline
};
#define N_ALIGN_MODES      (sizeof( alignMode) / sizeof( alignMode[ 0]))


static char   *alignMode_text[] =
{
   "DEFAULT",
   "VISUAL",
   "BASELINE"
};

char   *texts[] =
{

   "A long text",
#if 0
   "Hello",
   "VfL y!",
   "ux ma",
   " <spc> "
#endif
};
#define N_TEXTS   (sizeof( texts) / sizeof( texts[ 0]))


static CGRect   drawLabelBelowRect( struct NVGcontext *vg, float fontSize, char *s, CGRect rect)
{
   CGRect   rectBelow;

   rectBelow = CGRectMake( CGRectGetMinX( rect),
                           CGRectGetMaxY( rect),
                           rect.size.width,
                           fontSize + 4.0);
   nvgFontSize( vg, fontSize);
   nvgTextColor( vg, CGColorMakeGray(), CGColorMakeWhite());
   mvgTextInRect( vg,
                  s,
                  NULL,
                  rectBelow,
                  CGContentModeCenterPoint,
                  0);

   return( rectBelow);
}


// for debugging one mode
static void   drawStuff1( CALayer *layer, CGContext *context)
{
   struct NVGcontext   *vg;
   CGFont              *font;
   CGRect              rect;
   char                *s;
   auto char           buf[ 256];
   size_t              len;

   s    = "Hello this is, yay, the VfL Bochum";
   len  = strlen( s);
   s    = &s[ len - [context numberOfFrames] % len];

   vg   = CGContextGetNVGContext( context);
   font = [context fontWithNameUTF8String:"sans"];
   rect = CGSizeCenterInRect( CGSizeMake( 300, 80), [layer canvas]);

   mvgStrokeRect( vg, rect, CGColorMakeGray());

   mvgStrokeLineH( vg, CGRectGetMinX( rect),
                    CGRectGetMaxX( rect),
                    CGRectGetMidY( rect),
                    CGColorMakeGray());
   nvgFontSize( vg, 20.0);
   nvgTextColor( vg, CGColorMakeGreen(), CGColorMakeWhite());
   mvgTextInRect( vg,
                  s,
                  NULL,
                  rect,
                  CGContentModeScaleToFill,
                  MVGTextAlignVisually);
}


static void   drawStuff2( CALayer *layer, CGContext *context)
{
   struct NVGcontext    *vg;
   CGFont               *font;
   CGRect               canvas;
   CGRect               rect;
   CGRect               rects[ N_ALIGN_MODES][ 2];
   CGRect               small_rects[ N_ALIGN_MODES][ N_CONTENT_MODES2];
   int                  i, j, k;
   char                 *s;
   auto char            buf[ 256];

   s      = texts[ [context numberOfFrames] % N_TEXTS];

   vg     = CGContextGetNVGContext( context);
   font   = [context fontWithNameUTF8String:"sans"];
   canvas = MulleEdgeInsetsInsetRect( MulleEdgeInsetsMake( 16, 32, 16 + 20, 32),
                                      [layer canvas]);
   CGRectPartitionIntoRowsAndColumns( CGRectInset( canvas, 32, 16),
                                      CGSizeMake( 32, 32),
                                      N_ALIGN_MODES,
                                      2,
                                      (CGRect *) rects);

#if 1
   for( i = 0; i < N_ALIGN_MODES; i++)
   {
      mvgStrokeRect( vg, rects[ i][ 0], CGColorMakeGray());
      drawLabelBelowRect( vg, 14, alignMode_text[ i], rects[ i][ 0]);

      mvgStrokeLineH( vg, CGRectGetMinX( rects[ i][ 0]),
                       CGRectGetMaxX( rects[ i][ 0]),
                       CGRectGetMidY( rects[ i][ 0]),
                       CGColorMakeGray());
      nvgFontSize( vg, 20.0);
      nvgTextColor( vg, CGColorMakeGreen(), CGColorMakeWhite());

      for( j = 0; j < N_CONTENT_MODES; j++)
         mvgTextInRect( vg, s, NULL, rects[ i][ 0], contentMode[ j], alignMode[ i]);
   }

#endif
   CGRectPartitionIntoRowsAndColumns( rects[ 0][ 1],
                                      CGSizeMake( 16, 16),
                                      N_CONTENT_MODES2,
                                      N_ALIGN_MODES,
                                      (CGRect *) small_rects);

#if 1
   for( j = 0; j < N_CONTENT_MODES2; j++)
   {
      for( k = 0; k < N_ALIGN_MODES; k++)
      {
         mvgStrokeRect( vg, small_rects[ j][ k], CGColorMakeGray());
         sprintf( buf, "%s/%s", alignMode_text[ k], contentMode2_text[ j]);
         drawLabelBelowRect( vg, 9, buf, small_rects[ j][ k]);

         mvgStrokeLineH( vg, CGRectGetMinX( small_rects[ j][ k]),
                          CGRectGetMaxX( small_rects[ j][ k]),
                          CGRectGetMidY( small_rects[ j][ k]),
                          CGColorMakeGray());

         nvgFontSize( vg, 10.0);
         nvgTextColor( vg, CGColorMakeGreen(), CGColorMakeWhite());
         mvgTextInRect( vg, s, NULL, small_rects[ j][ k], contentMode2[ j], alignMode[ k]);
      }
   }
#endif

   CGRectPartitionIntoRowsAndColumns( rects[ 1][ 1],
                                      CGSizeMake( 16, 16),
                                      N_CONTENT_MODES2,
                                      N_ALIGN_MODES,
                                      (CGRect *) small_rects);


   for( j = 0; j < N_CONTENT_MODES2; j++)
   {
      for( k = 0; k < N_ALIGN_MODES; k++)
      {
         i = j * 3 + k;
         mvgStrokeRect( vg, small_rects[ j][ k], CGColorMakeGray());
         rect = drawLabelBelowRect( vg, 9, contentMode_text[ i], small_rects[ j][ k]);
         if( j == 2 && k == 1)
            drawLabelBelowRect( vg, 12, "ALIGN_VISUAL/FILL", rect);
         mvgStrokeLineH( vg, CGRectGetMinX( small_rects[ j][ k]),
                          CGRectGetMaxX( small_rects[ j][ k]),
                          CGRectGetMidY( small_rects[ j][ k]),
                          CGColorMakeGray());

         nvgFontSize( vg, 10.0);
         nvgTextColor( vg, CGColorMakeGreen(), CGColorMakeWhite());
         mvgTextInRect( vg, s, NULL, small_rects[ j][ k], contentMode[ i], MVGTextFill|MVGTextAlignVisually);
      }
   }
}


void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame  = [[window contentPlane] contentRect];

   view  = [UIView viewWithFrame:frame];
   [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
   [view setDrawCallback:drawStuff2]; // drawStuff1];
   [[window contentPlane] addSubview:view];
}


int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
   NSUInteger      styleMask;

   app = [UIApplication sharedInstance];

   @autoreleasepool
   {
      styleMask = UIWindowStyleMaskDefault;
      styleMask = UIWindowsStyleMaskBySetting( styleMask, UIWindowStyleResizable, YES);
      styleMask = UIWindowsStyleMaskBySetting( styleMask, UIWindowStyleRetained, NO);

      window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 1000, 600)
                         titleUTF8String:"Demo"
                               styleMask:styleMask];

      assert( window);
      [window setBackgroundColor:CGColorMakeWhite()];
      setupScene( window);
      [window setFrameRate:UIWindowFrameRateUnsynced];
      [app addWindow:window];
   }

   [window setFrameDelegate:[MulleUIPerf object]];

   return( [app run]);
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


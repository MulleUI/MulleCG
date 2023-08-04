#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>


static BOOL   drawStuff( CALayer *layer, CGContext *context)
{
   CAPolarPoint        polar;
   CGColor             color;
   CGFloat             end;
   CGFloat             initial;
   CGFloat             radius;
   CGFloat             start;
   CGPoint             centerPoint;
   CGPoint             leftPoint;
   CGPoint             rightPoint;
   CGRect              bottomRect;
   CGRect              canvas;
   CGRect              rect;
   CGRect              rects[ 2][ 4];
   CGRect              topRect;
   char                buf[ 128];
   int                 dir;
   int                 startingPoint;
   NSUInteger          frameNr;
   struct NVGcontext   *vg;
   unsigned int        i, j;

   frameNr       = [context numberOfFrames] % 240 * 4;
   startingPoint = frameNr / 240;

   canvas  = [layer canvas];
   vg      = CGContextGetNVGContext( context);

   CGRectPartitionIntoRowsAndColumns( CGRectInset( canvas, 10, 10),
                                      CGSizeMake( 10, 10),
                                      2,
                                      4,
                                      (CGRect *) rects);
   [context useDefaultFont];

   for( j = 0; j < 2; j++)
   {
      if( j & 0x1)
         initial = 1.5;
      else
         initial = 0.5;

      for( i = 0; i < 4; i++)
      {
         if( i & 0x2)
            dir = NVG_CCW;
         else
            dir = NVG_CW;

         if( i & 0x1)
         {
            start = initial + 0.25;
            end   = initial - 0.25;
         }
         else
         {
            start = initial - 0.25;
            end   = initial + 0.25;
         }

         rect = CGRectIntegral( rects[ j][ i]);
         mvgStrokeRectWithColor( vg, rect, 0.5, CGColorMakeBlack());

         CGRectDivide( rect, &bottomRect, &topRect, 20, CADirectionBottom);

         nvgSave( vg);
         {
            mvgIntersectScissor( vg, rect);

            // draw label
            sprintf( buf, "%s %g-%g", dir == NVG_CW ? "CW" : "CCW",
                                    start, end);
            nvgTextColor( vg, CGColorMakeBlack(), CGColorMakeWhite());
            mvgTextInRect( vg, buf, NULL, bottomRect, CGContentModeCenterPoint, 0);

            // draw arc
            // mvgMoveTo( vg, CGRectGetTopPoint( topRect));

            centerPoint = CGRectGetCenterPoint( topRect);
            radius      = CGRectGetInnerRadius( topRect) - 4.0;
            polar       = CAPolarPointMakeWithPoint( centerPoint);
            polar       = CAPolarPointAdd( polar, CAPolarPointMakeWithRadians( radius, start * M_PI_f));
            leftPoint   = CGPointMakeWithPolarPoint( polar);
            polar       = CAPolarPointMakeWithPoint( centerPoint);
            polar       = CAPolarPointAdd( polar, CAPolarPointMakeWithRadians( radius, end * M_PI_f));
            rightPoint  = CGPointMakeWithPolarPoint( polar);

            mvgStrokeLineWithColor( vg, centerPoint, leftPoint, 0.5, CGColorMakeBlack());
            mvgStrokeLineWithColor( vg, centerPoint, rightPoint, 0.5, CGColorMakeRed());

            switch( startingPoint)
            {
            case 0 : nvgBeginPath( vg);
                     break;

            case 1 : mvgFillCircleWithColor( vg, centerPoint, 4.0, CGColorMakeDarkGray());
                     nvgBeginPath( vg);
                     mvgMoveTo( vg, centerPoint);
                     break;

            case 2 : mvgFillCircleWithColor( vg, leftPoint, 4.0, CGColorMakeDarkGray());
                     nvgBeginPath( vg);
                     mvgMoveTo( vg, leftPoint);
                     break;

            case 3 : mvgFillCircleWithColor( vg, rightPoint, 4.0, CGColorMakeDarkGray());
                     nvgBeginPath( vg);
                     mvgMoveTo( vg, rightPoint);
                     break;
            }

            nvgArc( vg, centerPoint.x, centerPoint.y, radius, start * M_PI_f, end * M_PI_f, dir);
            color = CGColorMakeWithHSL( 0.2 + ((i + (j * 4)) / 7.0) * 0.6,
                                        1.0,
                                        0.6);
            nvgStrokeColor( vg, color);
            nvgStrokeWidth( vg, 3);
            nvgStroke( vg);
         }
         nvgRestore( vg);
      }
   }
   return( YES);
}


void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame  = [[window contentView] contentRect];
   view   = [UIView viewWithFrame:frame];
   [view setDrawCallback:(CALayerDrawCallback_t *) drawStuff];
   [[window contentView] addSubview:view];
}


static void   usage( void)
{
   fprintf( stderr, "\n"
"Usage:\n"
"   arc-cw [options]\n"
"\n"
"Options:\n"
"   -a      : disable default antialias (nvg/glfw)\n"
"   -f      : force edge antialias (nvg)\n"
"   -r      : retained\n"
"\n");
   exit( 1);
}


int   main( int argc, char *argv[])
{
   UIWindow        *window;
   UIApplication   *app;
   NSUInteger      styleMask;
   int             i;

   styleMask = UIWindowStyleMaskDefault;

   /*
    * window and app
    */
   for( i = 1; i < argc; i++)
   {
      if( argv[ i][ 0] != '-')
         break;
      switch( argv[ i][ 1])
      {
      case 'r' :
         styleMask &= ~UIWindowStyleRetained;
         break;

      case 'f' :
         styleMask |= UIWindowStyleForceEdgeAntiAlias;
         break;

      case 'a' :
         styleMask &= ~UIWindowStyleAntiAlias;
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
      window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 600, 400)
                                titleUTF8String:"Demo"
                                      styleMask:styleMask] autorelease];

      assert( window);
      [window setBackgroundColor:CGColorMakeWhite()];
      [window setFrameRateHz:15.0];
      setupScene( window);
      [app addWindow:window];
   }
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



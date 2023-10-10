#define _GNU_SOURCE

#import "import-private.h"


BOOL  scissor;

void   drawSplitRectWithHole(NVGcontext* vg, CGRect rect, CGFloat x, CGFloat radius)
{
    CGFloat y = CGRectGetMidY( rect);
    CGFloat angle = asinf( rect.size.height / (2 * radius));

    nvgSave( vg);

    if( scissor)
      nvgIntersectScissor( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

    // Draw the left part of the rect
    nvgBeginPath(vg);
    nvgMoveTo(vg, CGRectGetMinX( rect), CGRectGetMinY( rect));
    nvgLineTo(vg, x - radius * cosf(angle), CGRectGetMinY( rect));
    nvgArc(vg, x, y, radius, M_PI_f + angle, M_PI_f - angle, NVG_CCW);
    nvgLineTo(vg, CGRectGetMinX( rect), CGRectGetMaxY( rect));
    nvgClosePath(vg);
    nvgFillColor( vg, CGColorMakeIndigo());
    nvgFill(vg);

    // Draw the right part of the rect
    nvgBeginPath(vg);
    nvgMoveTo(vg, x + radius * cosf(angle), CGRectGetMinY( rect));
    nvgLineTo(vg, CGRectGetMaxX( rect), CGRectGetMinY( rect));
    nvgLineTo(vg, CGRectGetMaxX( rect), CGRectGetMaxY( rect));
    nvgLineTo(vg, x + radius * cosf(angle), CGRectGetMaxY( rect));
    nvgArc(vg, x, y, radius, angle, -angle, NVG_CCW);
    nvgClosePath(vg);
    nvgFillColor( vg, CGColorMakeOrange());
    nvgFill(vg);

    nvgRestore( vg);
}


static BOOL   drawStuff( CALayer *layer, void *_context)
{
   CGContext           *context = _context;
   struct NVGcontext   *vg;
   CGRect              rect;
   CGFloat             factor;
   NSUInteger          frameNr;

   frameNr = [context numberOfFrames] % 240;
   if( frameNr >= 120)
      factor = 1.0 - (frameNr - 120) / 119.0;
   else
      factor = frameNr / 119.0;
   factor = _CAQuadraticGetValue( ((struct CAQuadratic) { 0.0f, 0.010f, 0.990f, 1.0f }), factor);

   vg   = CGContextGetNVGContext( context);
   rect = CGRectInset( [layer canvas], 25, 25);
   rect = CGSizePlaceInRect( CGSizeMake( rect.size.width, 200), rect, CGContentModeCenterPoint);

   drawSplitRectWithHole( vg, rect, CGRectGetMidX( rect), rect.size.height / 2.0);
   return( YES);
}


static void   usage( void)
{
   fprintf( stderr, "\n"
"Usage:\n"
"   circle-hole [options]\n"
"\n"
"Options:\n"
"   -a      : disable default antialias (nvg/glfw)\n"
"   -f      : force edge antialias (nvg)\n"
"   -r      : retained\n"
"   -s      : use scissor\n"
"\n");
   exit( 1);
}


int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
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
         styleMask ^= ~UIWindowStyleRetained;
         break;

      case 'f' :
         styleMask ^= UIWindowStyleForceEdgeAntiAlias;
         break;

      case 'a' :
         styleMask ^= UIWindowStyleAntiAlias;
         break;

      case 's' :
         scissor   ^= 1;
         break;

      default :
         usage();
      }
   }

   if( i != argc)
      usage();

   app = [UIApplication sharedInstance];

   window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 600, 400)
                             titleUTF8String:"Demo"
                                   styleMask:styleMask] autorelease];
   [[window contentView] setDrawCallback:drawStuff];
   [window setFrameRateHz:60.0f];
   [app addWindow:window];

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

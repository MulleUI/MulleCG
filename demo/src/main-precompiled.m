#define _GNU_SOURCE

#import "import-private.h"
static BOOL   precompile = YES;
static BOOL   cache = YES;

void   drawSplitRectWithHole( CGContext *context, CGRect rect, CGFloat x, CGFloat radius)
{
    CGFloat y = CGRectGetMidY( rect);
    CGFloat angle = asinf( rect.size.height / (2 * radius));

    CGContextBeginPath( context);
    CGContextMoveTo( context, CGPointMake(CGRectGetMinX( rect), CGRectGetMinY( rect)));
    CGContextLineTo( context, CGPointMake(x - radius * cosf(angle), CGRectGetMinY( rect)));
    CGContextArc( context, CACircleMakeWithCenterAndRadius( CGPointMake( x, y), radius), CARadiansToAngle( M_PI_f + angle), -2 * angle);
    CGContextLineTo( context, CGPointMake(CGRectGetMinX( rect), CGRectGetMaxY( rect)));
    CGContextLineTo( context, CGPointMake(CGRectGetMinX( rect), CGRectGetMinY( rect)));

    CGContextMoveTo( context, CGPointMake(x + radius * cosf(angle), CGRectGetMinY( rect)));
    CGContextLineTo( context, CGPointMake(CGRectGetMaxX( rect), CGRectGetMinY( rect)));
    CGContextLineTo( context, CGPointMake(CGRectGetMaxX( rect), CGRectGetMaxY( rect)));
    CGContextLineTo( context, CGPointMake(x + radius * cosf(angle), CGRectGetMaxY( rect)));
    CGContextArc( context, CACircleMakeWithCenterAndRadius( CGPointMake( x, y), radius), CARadiansToAngle( angle), -2 * angle);
    CGContextClosePath( context);
}
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *_context)
{
   CGContext                  *context = _context;
   CGRect                     contentRect;
   CGRect                     rect;
   CGFloat                    hue;
   NSUInteger                 frameNr;
   static CGContext   *pathContext;
   NSUInteger                 i;
   CGFloat                    steps;

   contentRect = CGRectInset( [layer canvas], 25, 25);
   rect        = CGSizePlaceInRect( CGSizeMake( 100, 100), contentRect, CGContentModeLeft);

   if( cache && ! pathContext)
   {
      MulleUICLog( "Cache path");

      pathContext = [CGContext createPathContext];
      assert( pathContext);

      drawSplitRectWithHole( pathContext, rect, CGRectGetMidX( rect), rect.size.height / 2.0);
      if( precompile)
      {
         // TODO: CGContextPrecompilePath( pathContext);
         MulleUICLog( "Precompile path");
      }
   }

#define STEPS  200

   hue   = CGContextGetBackAndForthAnimationFactor( context, 240);
   steps = (contentRect.size.width - CGRectGetMidX( rect) * 2.0) / (CGFloat) STEPS;
   for( i = 0; i < STEPS; i++)
   {
      CGContextTranslate( context, CGPointMake(steps, 0.0f));
      if( cache)
         { /* TODO: CGContextCopyPath( context, pathContext); */ }
      else
         drawSplitRectWithHole( context, rect, CGRectGetMidX( rect), rect.size.height / 2.0);
      CGContextStrokeColor( context, CGColorMakeWithHSL( fmodf( hue + i / 100.0, 1.0), 1.0, 0.5));
      CGContextStrokeWidth( context, 3.0);
      CGContextStroke( context);
   }
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
"   -p      : dont precompile path\n"
"   -c      : dont cache path\n"
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

      case 'p' :
         precompile = NO;
         break;

      case 'c' :
         cache = NO;
         break;

      default :
         usage();
      }
   }

   if( i != argc)
      usage();

   app = [UIApplication sharedInstance];

   window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 600, 400)
                      titleUTF8String:"Demo"
                            styleMask:styleMask];
   [[window contentView] setDrawCallback:drawStuff];
   [window setFrameRateHz:60.0f];
   [window setFrameDelegate:[MulleUIPerf instance]];
   [app addWindow:window];
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

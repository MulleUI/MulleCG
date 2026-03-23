#define _GNU_SOURCE

#import "import-private.h"
enum
{
   LeftConvex   = 0x0,
   LeftConcave  = 0x1,
   RightConvex  = 0x0,
   RightConvave = 0x2
};

static void   drawRoundedStroke( CGContext *context, // Converted from struct CGContext *context
                                 CGRect rect,
                                 CGColor color,
                                 NSUInteger bits)
{
   // insets are flipped, because rect is flipped!
   CGFloat          radius;
   CGFloat          offset;
   int              ldir;
   int              rdir;
   CGFloat          startRadians;
   CGFloat          endRadians;

   radius       = CGRectGetHeight( rect) / 2.0;
   offset       = radius;
   startRadians = 1.5 * M_PI_f;
   endRadians   = 0.5 * M_PI_f;
   if( bits & RightConvave)
   {
      rdir = CARotationDirectionClockWise;
   }
   else
   {
      rect = CGRectContract( rect, offset, CADirectionRight);
      rdir = CARotationDirectionCounterClockWise;
   }

   if( bits & LeftConcave)
   {
      rect = CGRectExpand( rect, offset, CADirectionLeft);
      ldir = CARotationDirectionClockWise;
   }
   else
   {
      ldir = CARotationDirectionCounterClockWise;
   }

   CGContextBeginPath( context);

   CGContextMoveTo( context, CGPointMake( rect.origin.x + offset, rect.origin.y));

   CGContextArcRadians( context, CACircleMakeWithCenterAndRadius( CGPointMake( rect.origin.x + offset, rect.origin.y + radius), radius),
                                 startRadians,
                                 endRadians,
                                 ldir);

   // Draw the top edge of the rectangle to the beginning of the arc
   CGContextLineTo( context, CGPointMake( rect.origin.x + rect.size.width - offset,
                  rect.origin.y + rect.size.height));
   // Add a concave half circle on the right edge of the rectangle
   CGContextArcRadians( context, CACircleMakeWithCenterAndRadius( CGPointMake( rect.origin.x + rect.size.width,
                                 rect.origin.y + radius), radius),
                                 endRadians,
                                 startRadians,
                                 rdir);
//   CGContextLineTo( context, CGPointMake( rect.origin.x, rect.origin.y));
   // Draw the left edge of the rectangle

   CGContextLineTo( context, CGPointMake( rect.origin.x + rect.size.width - offset, rect.origin.y));

//   CGContextClosePath( context);
   CGContextFillColor( context, color); // Converted from mvgFillColor
   CGContextFill( context); // Converted from mvgFill
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( CGPointMake( rect.origin.x + offset, rect.origin.y), 2.0), CGColorMakeRed()); // Converted from mvgFillCircleWithColor
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( CGPointMake( rect.origin.x + offset, rect.origin.y + radius), 2.0), CGColorMakeBlue()); // Converted from mvgFillCircleWithColor
}
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *_context)
{
   CGContext                  *context = _context;
   CGRect                     canvas;
   CGRect                     rect;
   struct MulleCornerInsets   insets;
   CGFloat                    value;
   int                        i, j;
   CGFloat                    factor;
   CGFloat                    h;
   CGRect                     rects[ 2][ 2];
   CGHexColor                 color[ 2][ 2] = { { 0xF080F0CF, 0x404060CF },
                                              { 0x20F020CF, 0xF02020CF } };

   factor = ([context numberOfFrames] % 120) / 119.0;
   factor = _CACubicGetValue( ((struct CACubic) { 0.0f, 0.010f, 0.990f, 1.0f }), factor);

   canvas = CGRectInset( [layer canvas], 25, 25);
   CGRectPartition2x2( canvas, CGSizeMake( 100, 50), rects);

   for( j = 0; j < 2; j++)
      for( i = 0; i < 2; i++)
      {
         rect           = CGRectIntegral( rects[ j][ i]);
         CGContextStrokeRectWithColor( context, rect, 5.0, CGColorMake( 0.0, 0.0, 0.0, 0.2)); // Converted from mvgStrokeRectWithColor

         h                = 2.0 + (rect.size.height - 2.0) * factor;
         rect.origin.y   += (rect.size.height - h) / 2.0;
         rect.size.height = h;
         drawRoundedStroke( context, rect, CGColorMakeWithHexColor( color[ j][ i]), (j << 1) + i); // Updated function call
      }
   return( YES);
}

int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;

   app = [UIApplication sharedInstance];

   window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 600, 400)];
   [[window contentView] setDrawCallback:drawStuff];
   [window setFrameRateHz:60.0f];
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
// ║⌐        █⌐'║▄ Γr2«    ║▀                 ▄▄▄      ╙███` `╙╙║█  ▐H        █
// █]     ,▄▐H  ██████═ª  ╓` ▄█▀▀▀▀█▄        ████     ╓███` `╙╙║█  ▐H        █
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

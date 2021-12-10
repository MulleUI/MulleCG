#define _GNU_SOURCE

#import "import-private.h"

enum ColorModel
{
   RGB,
   HSL,
   HSV
};


static void   drawStuff( CALayer *layer, CGContext *context)
{
   struct NVGcontext   *vg;
   CGRect              canvas;
   CGRect              square;
   CGRect              rows[ 6];
   CGRect              grid[ 6][ 10];
   NSUInteger          i;
   NSUInteger          x, y;
   CGRect              rect;
   struct NVGpaint     paint;
   CGColor             from;
   CGColor             to;
   enum ColorModel     model;
   char                *name;

   canvas = [layer canvas];
   canvas = MulleEdgeInsetsInsetRect( MulleEdgeInsetsMake( 14, 14, 14, 14), canvas);

   CGRectPartitionVertically( canvas, 4.0, 6, rows);
   for( i = 0; i < 6; i++)
      CGRectPartitionHorizontally( rows[ i], 4.0, 10, grid[ i]);

   model = (long) ([context renderStartTime] / 2) % 3;

   vg = CGContextGetNVGContext( context);
   for( y = 0; y < 6; y++)
   {
      for( x = 0; x < 10; x++)
      {
      switch( model)
      {
         case RGB :
            name = "RGB";
            from = CGColorMakeRGB( 1.0 - x / 9.0, y / 6.0f, x / 9.0);
            to   = CGColorMakeRGB( y / 6.0f, x / 9.0, 1.0 - x / 9.0);
            break;

         case HSL :
            name = "HSL";
            from = CGColorMakeHSL( x / 9.0, y / 6.0f, 1.0);
            to   = CGColorMakeHSL( x / 9.0, 1.0, y / 6.0f);
            break;

         case HSV :
            name = "HSV";
            from = CGColorMakeHSV( x / 9.0, y / 6.0f, 1.0);
            to   = CGColorMakeHSV( x / 9.0, 1.0, y / 6.0f);
         }
         rect = grid[ y][ x];

         square = CGSizePlaceInRectWithAspectCorrection( CGSizeMake( 1, 1), rect, NO);
         nvgBeginPath( vg);

         nvgMoveTo(vg, CGRectGetMidX( square), CGRectGetMinY( square));
         nvgLineTo(vg, CGRectGetMaxX( square), CGRectGetMaxY( square));
         nvgLineTo(vg, CGRectGetMinX( square), CGRectGetMaxY( square));
         nvgClosePath(vg);


         paint = nvgLinearGradient(vg, CGRectGetMinX( square), CGRectGetMinY( square),
                                       CGRectGetMaxX( square), CGRectGetMaxY( square),
                                       from, to);
         nvgFillPaint(vg, paint);
         nvgFill(vg);
      }
   }

   [context useFontWithNameUTF8String:"sans"];
   nvgFontSize( vg, 32);
   nvgFontBlur( vg, 3.0);
   nvgTextColor( vg, [UIColor whiteColor], [UIColor darkGrayColor]);
   nvgText( vg, 20, CGRectGetMaxY( canvas) - 60, name, NULL);
}


int   main( int argc, char *argv[])
{
   UIApplication   *app;

   app = [UIApplication sharedInstance];
   @autoreleasepool
   {
      [app runWindowForDrawCallback:drawStuff
                         canvasSize:CGSizeMake( 640, 400)
                         windowSize:CGSizeZero   // CGSizeMake( 200, 400)
                    titleUTF8String:NULL
                        frameRateHz:100.0];
   }
   [app terminate];
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

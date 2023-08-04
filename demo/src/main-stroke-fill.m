#define _GNU_SOURCE

#import "import-private.h"


static void   drawRect( CALayer *layer, CGContext *context, NSUInteger antiAlias)
{
   struct NVGcontext    *vg;
   CGRect               canvas;
   CGRect               fillRect;
   CGRect               strokeRect;
   char                 buf[ 64];
   CGFloat              strokeWidth;
   CGRect               rows[ 3];
   CGRect               columns[ 3];
   NSUInteger           i, j;
   char                 *strokeMode;
   char                 *fillMode;

   vg     = CGContextGetNVGContext( context);
   canvas = CGRectInset( [layer canvas], 10.0, 10.0);

   nvgShapeAntiAlias( vg, antiAlias);

   CGRectPartitionHorizontally( canvas, 20.0, 3, columns);
   for( j = 0; j < 3; j++)
   {
      fillRect = CGRectIntegral( columns[ j]);

      // draw line around fillRect
      nvgBeginPath( vg);
      nvgStrokeWidth( vg, 1.0);
      nvgStrokeColor( vg, CGColorMake( 0.5, 0.5, 0.5, 1.0));
      nvgRect( vg, fillRect.origin.x - 0.5, fillRect.origin.y - 0.5, fillRect.size.width + 1.0, fillRect.size.height + 1.0);
      nvgStroke( vg);

      nvgBeginPath( vg);
      nvgStrokeWidth( vg, 1.0);
      switch( j)
      {
      case 0 :
         nvgRect( vg, fillRect.origin.x + 1, fillRect.origin.y + 1, 3, 1);
         nvgFillColor( vg, CGColorMake( 0.5, 0.5, 1.0, 1.0));
         nvgFill( vg);

         nvgBeginPath( vg);
         nvgRect( vg, fillRect.origin.x + 1, fillRect.origin.y + 10, 6, 6);
         nvgFill( vg);
         break;

      case 1 :
         nvgMoveTo( vg, fillRect.origin.x + 1.0, fillRect.origin.y + 1.5);
         nvgLineTo( vg, fillRect.origin.x + 4.0, fillRect.origin.y + 1.5);
         nvgStrokeColor( vg, CGColorMake( 0.5, 1.0, 0.5, 1.0));
         nvgStrokeWidth( vg, 1.0);
         nvgStroke( vg);

         nvgBeginPath( vg);
         nvgRect( vg, fillRect.origin.x + 1 + 1.5, fillRect.origin.y + 10 - 1.5, 3, 3);
         nvgStrokeWidth( vg, 3.0);
         nvgStroke( vg);
         break;

      case 2 :
         nvgMoveTo( vg, fillRect.origin.x + 2.5, fillRect.origin.y + 1.0);
         nvgLineTo( vg, fillRect.origin.x + 2.5, fillRect.origin.y + 2.0);
         nvgStrokeColor( vg, CGColorMake( 1.0, 0.5, 0.5, 1.0));
         nvgStrokeWidth( vg, 3.0);
         nvgStroke( vg);

         nvgBeginPath( vg);
         nvgRect( vg, fillRect.origin.x + 1 + 1.5, fillRect.origin.y + 10 - 1.5, 3, 3);
         nvgStrokeWidth( vg, 3.0);
         nvgStroke( vg);
         break;
      }
   }
}


static void   drawStuff0( CALayer *layer, CGContext *context)
{
   drawRect( layer, context, 0x0);
}

static void   drawStuff1( CALayer *layer, CGContext *context)
{
   drawRect( layer, context, 0x1);
}



typedef CALayerDrawCallback_t  *CALayerDrawCallbackPointer_t;

static CALayerDrawCallbackPointer_t   drawStuff[ 2] =
{
   (CALayerDrawCallback_t *) drawStuff0,
   (CALayerDrawCallback_t *) drawStuff1
};


int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window[ 2];
   NSUInteger      i;

   app = [UIApplication sharedInstance];

   for( i = 0; i < 2; i++)
   {
      window[ i] = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 320, 100)
                             titleUTF8String:i == 0 ? "No AntiAlias" : "AntiAlias"
                                   styleMask:UIWindowStyleMaskDefault];
      [window[ i] setDrawCallback:drawStuff[ i]];
      [window[ i] setBackgroundColor:CGColorMakeBlack()];
      [app addWindow:window[ i]];
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


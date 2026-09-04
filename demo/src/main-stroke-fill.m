#define _GNU_SOURCE

#import "import-private.h"
static void   drawRect( CALayer *layer, CGContext *context, NSUInteger antiAlias)
{
   CGRect               canvas;
   CGRect               fillRect;
   CGRect               columns[ 3];
   NSUInteger           j;

   canvas = CGRectInset( [layer canvas], 10.0, 10.0);

   CGContextShapeAntiAlias( context, antiAlias);

   CGRectPartitionHorizontally( canvas, 20.0, 3, columns);
   for( j = 0; j < 3; j++)
   {
      fillRect = CGRectIntegral( columns[ j]);

      // draw line around fillRect
      CGContextBeginPath( context);
      CGContextStrokeWidth( context, 1.0);
      CGContextStrokeColor( context, CGColorMake( 0.5, 0.5, 0.5, 1.0));
      CGContextRect( context, CGRectMake(fillRect.origin.x - 0.5, fillRect.origin.y - 0.5, fillRect.size.width + 1.0, fillRect.size.height + 1.0));
      CGContextStroke( context);

      CGContextBeginPath( context);
      CGContextStrokeWidth( context, 1.0);
      switch( j)
      {
      case 0 :
         CGContextRect( context, CGRectMake(fillRect.origin.x + 1, fillRect.origin.y + 1, 3, 1));
         CGContextFillColor( context, CGColorMake( 0.5, 0.5, 1.0, 1.0));
         CGContextFill( context);

         CGContextBeginPath( context);
         CGContextRect( context, CGRectMake(fillRect.origin.x + 1, fillRect.origin.y + 10, 6, 6));
         CGContextFill( context);
         break;

      case 1 :
         CGContextMoveTo( context, CGPointMake(fillRect.origin.x + 1.0, fillRect.origin.y + 1.5));
         CGContextLineTo( context, CGPointMake(fillRect.origin.x + 4.0, fillRect.origin.y + 1.5));
         CGContextStrokeColor( context, CGColorMake( 0.5, 1.0, 0.5, 1.0));
         CGContextStrokeWidth( context, 1.0);
         CGContextStroke( context);

         CGContextBeginPath( context);
         CGContextRect( context, CGRectMake(fillRect.origin.x + 1 + 1.5, fillRect.origin.y + 10 - 1.5, 3, 3));
         CGContextStrokeWidth( context, 3.0);
         CGContextStroke( context);
         break;

      case 2 :
         CGContextMoveTo( context, CGPointMake(fillRect.origin.x + 2.5, fillRect.origin.y + 1.0));
         CGContextLineTo( context, CGPointMake(fillRect.origin.x + 2.5, fillRect.origin.y + 2.0));
         CGContextStrokeColor( context, CGColorMake( 1.0, 0.5, 0.5, 1.0));
         CGContextStrokeWidth( context, 3.0);
         CGContextStroke( context);

         CGContextBeginPath( context);
         CGContextRect( context, CGRectMake(fillRect.origin.x + 1 + 1.5, fillRect.origin.y + 10 - 1.5, 3, 3));
         CGContextStrokeWidth( context, 3.0);
         CGContextStroke( context);
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

typedef CGGraphicsLayerDrawCallback_t  *CALayerDrawCallbackPointer_t;

static CALayerDrawCallbackPointer_t   drawStuff[ 2] =
{
   (CGGraphicsLayerDrawCallback_t *) drawStuff0,
   (CGGraphicsLayerDrawCallback_t *) drawStuff1
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


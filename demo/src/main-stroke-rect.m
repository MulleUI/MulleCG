#define _GNU_SOURCE

#import "import-private.h"


#define AntiAlias  1
#define Thick      2
#define Offset     4



static void   drawRect( CALayer *layer, CGContext *context, NSUInteger antiAlias)
{
   struct NVGcontext    *vg;
   CGRect               canvas;
   CGRect               fillRect;
   CGRect               strokeRect;
   char                 buf[ 1024];
   CGFloat              strokeWidth;
   CGRect               rows[ 3];
   CGRect               columns[ 3];
   NSUInteger           i, j;
   char                 *strokeMode;
   char                 *fillMode;

   vg     = CGContextGetNVGContext( context);
   canvas = CGRectInset( [layer canvas], 10.0, 10.0);

   strokeWidth = 6.0;
   nvgShapeAntiAlias( vg, antiAlias);

   nvgResetScissor( vg); // see if it makes a difference
   CGRectPartitionVertically( canvas, 20.0, 3, rows);
   for( i = 0; i < 3; i++)
   {
      CGRectPartitionHorizontally( rows[ i], 20.0, 3, columns);
      for( j = 0; j < 3; j++)
      {
         fillRect   = CGRectIntegral( columns[ j]);
         strokeRect = fillRect;
         strokeMode = "sOutside";
         fillMode   = "fOutside";

         switch( j)
         {
         case 0 :
            strokeRect = CGRectMakeStrokeRect( fillRect, strokeWidth, CGOutside);
            strokeMode = "sOutside";
            break;

         case 1 :
            strokeRect = CGRectMakeStrokeRect( fillRect, strokeWidth, CGInside);
            strokeMode = "sInside";
            break;

         case 2 :
            strokeRect = CGRectMakeStrokeRect( fillRect, strokeWidth, CGOverlap);
            strokeMode = "sOverlap";
            break;
         }

         switch( i)
         {
         case 0 :
            fillRect = CGRectMakeFillRect( strokeRect, strokeWidth, CGInside);
            fillMode = "fInside";
            break;

         case 1 :
            fillRect = CGRectMakeFillRect( strokeRect, strokeWidth, CGCover);
            fillMode = "fCover";
            break;

         case 2 :
            fillRect = CGRectMakeFillRect( strokeRect, strokeWidth, CGOverlap);
            fillMode = "fOverlap";
            break;
         }

         nvgBeginPath( vg);
         nvgRect( vg, strokeRect.origin.x, strokeRect.origin.y, strokeRect.size.width, strokeRect.size.height);
         nvgStrokeColor( vg, CGColorMake( 1.0, 0.0, 1.0, 0.75));
         nvgStrokeWidth( vg, strokeWidth);
         nvgStroke( vg);

         nvgGlobalCompositeOperation( vg, NVG_LIGHTER);
         {
            nvgBeginPath( vg);
            nvgRect( vg, fillRect.origin.x, fillRect.origin.y, fillRect.size.width, fillRect.size.height);
            nvgFillColor( vg, CGColorMake( 0.0, 1.0, 0.0, 0.75));
            nvgFill( vg);
         }
         nvgGlobalCompositeOperation( vg, NVG_SOURCE_OVER);
         mulle_snprintf( buf, sizeof( buf),
                           "%s %s %s\nf:%s\ns:%s",
                           antiAlias ? "AA " : "No AA ",
                           fillMode,
                           strokeMode,
                           CGRectUTF8String( fillRect),
                           CGRectUTF8String( strokeRect));

         [context fontWithNameUTF8String:"sans"];

         nvgFontFace( vg, "sans");
         nvgTextAlign( vg, NVG_ALIGN_CENTER | NVG_ALIGN_TOP);
         nvgTextColor( vg, CGColorMakeBlack());
         nvgTextBackgroundColor( vg, CGColorMake( 0.0, 1.0, 0.0, 0.75));
         nvgFontSize( vg, 12.0);
         nvgTextBox( vg, CGRectGetMinX( fillRect),
                         CGRectGetMidY( fillRect) - 12.0,
                         fillRect.size.width,
                         buf,
                         NULL);
      }
   }

   strokeWidth = 1.0;
   nvgShapeAntiAlias( vg, 1);

   CGRectPartitionVertically( canvas, 20.0, 3, rows);
   for( i = 2; i < 3; i++)
   {
      CGRectPartitionHorizontally( rows[ i], 20.0, 3, columns);
      for( j = 0; j < 3; j++)
      {
         fillRect = CGRectIntegral( columns[ j]);

         nvgBeginPath( vg);
         nvgStrokeWidth( vg, strokeWidth);
         nvgStrokeColor( vg, CGColorMake( 1.0, 1.0, 1.0, 0.8));

         nvgMoveTo( vg, CGRectGetStrokeMinX( fillRect, 1.0), CGRectGetStrokeMinY( fillRect, 1.0) - 3.0);
         nvgLineTo( vg, CGRectGetStrokeMinX( fillRect, 1.0), CGRectGetStrokeMinY( fillRect, 1.0) + 3.0);
         nvgMoveTo( vg, CGRectGetStrokeMinX( fillRect, 1.0) - 3.0, CGRectGetStrokeMinY( fillRect, 1.0));
         nvgLineTo( vg, CGRectGetStrokeMinX( fillRect, 1.0) + 3.0, CGRectGetStrokeMinY( fillRect, 1.0));

         nvgMoveTo( vg, CGRectGetStrokeMaxX( fillRect, 1.0), CGRectGetStrokeMinY( fillRect, 1.0) - 3.0);
         nvgLineTo( vg, CGRectGetStrokeMaxX( fillRect, 1.0), CGRectGetStrokeMinY( fillRect, 1.0) + 3.0);
         nvgMoveTo( vg, CGRectGetStrokeMaxX( fillRect, 1.0) - 3.0, CGRectGetStrokeMinY( fillRect, 1.0));
         nvgLineTo( vg, CGRectGetStrokeMaxX( fillRect, 1.0) + 3.0, CGRectGetStrokeMinY( fillRect, 1.0));

         nvgMoveTo( vg, CGRectGetStrokeMinX( fillRect, 1.0), CGRectGetStrokeMaxY( fillRect, 1.0) - 3.0);
         nvgLineTo( vg, CGRectGetStrokeMinX( fillRect, 1.0), CGRectGetStrokeMaxY( fillRect, 1.0) + 3.0);
         nvgMoveTo( vg, CGRectGetStrokeMinX( fillRect, 1.0) - 3.0, CGRectGetStrokeMaxY( fillRect, 1.0));
         nvgLineTo( vg, CGRectGetStrokeMinX( fillRect, 1.0) + 3.0, CGRectGetStrokeMaxY( fillRect, 1.0));

         nvgMoveTo( vg, CGRectGetStrokeMaxX( fillRect, 1.0), CGRectGetStrokeMaxY( fillRect, 1.0) - 3.0);
         nvgLineTo( vg, CGRectGetStrokeMaxX( fillRect, 1.0), CGRectGetStrokeMaxY( fillRect, 1.0) + 3.0);
         nvgMoveTo( vg, CGRectGetStrokeMaxX( fillRect, 1.0) - 3.0, CGRectGetStrokeMaxY( fillRect, 1.0));
         nvgLineTo( vg, CGRectGetStrokeMaxX( fillRect, 1.0) + 3.0, CGRectGetStrokeMaxY( fillRect, 1.0));

         nvgStroke( vg);
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
      window[ i] = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 600, 300)
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


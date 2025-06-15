#define _GNU_SOURCE

#import "import-private.h"


#define AntiAlias  1
#define Thick      2
#define Offset     4



static void   drawRect( CALayer *layer, CGContext *context, NSUInteger antiAlias)
{
   CGFloat      strokeWidth;
   CGRect       canvas;
   CGRect       columns[ 3];
   CGRect       fillRect;
   CGRect       rect;
   CGRect       rows[ 3];
   CGRect       strokeRect;
   char         *fillMode;
   char         *strokeMode;
   char         buf[ 1024];
   NSUInteger   i, j;
   // struct NVGcontext *vg = CGContextGetNVGContext( context); // Get vg from context, though not strictly needed if all calls are CGContext...

   canvas      = CGRectInset( [layer canvas], 10.0, 10.0);

   strokeWidth = 6.0;
   CGContextShapeAntiAlias( context, antiAlias); // Converted from nvgShapeAntiAlias

   CGContextResetScissor( context); // Converted from nvgResetScissor // see if it makes a difference
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
            fillRect = CGRectMakeFillRect( strokeRect, strokeWidth, CGOverlap);
            fillMode = "fCover";
            break;

         case 2 :
            fillRect = CGRectMakeFillRect( strokeRect, strokeWidth, CGOverlap);
            fillMode = "fOverlap";
            break;
         }

         CGContextBeginPath( context);
         CGContextRect( context, strokeRect);
         CGContextStrokeColor( context, CGColorMake( 1.0, 0.0, 1.0, 0.75));
         CGContextStrokeWidth( context, strokeWidth);
         CGContextStroke( context);

         CGContextGlobalCompositeOperation( context, NVG_LIGHTER);
         {
            CGContextBeginPath( context);
            CGContextRect( context, fillRect);
            CGContextFillColor( context, CGColorMake( 0.0, 1.0, 0.0, 0.75));
            CGContextFill( context);
         }
         CGContextGlobalCompositeOperation( context, NVG_SOURCE_OVER);
         mulle_snprintf( buf, sizeof( buf),
                           "%s %s %s\nf:%s\ns:%s",
                           antiAlias ? "AA " : "No AA ",
                           fillMode,
                           strokeMode,
                           CGRectUTF8String( fillRect),
                           CGRectUTF8String( strokeRect));

         CGContextFontFace( context, "sans");
         CGContextTextAlign( context, CGTextAlignCenter | CGTextAlignTop); // Converted from NVG_ALIGN_CENTER | NVG_ALIGN_TOP
         CGContextTextColor( context, CGColorMakeBlack());
         CGContextTextBackgroundColor( context, CGColorMake( 0.0, 1.0, 0.0, 0.75));
         CGContextFontSize( context, 12.0);
         CGContextTextBox( context, CGPointMake ( CGRectGetMinX( fillRect),
                                                  CGRectGetMidY( fillRect) - 12.0),
                                    fillRect.size.width,
                                    buf,
                                    (size_t) -1);
      }
   }

   strokeWidth = 1.0;
   CGContextShapeAntiAlias( context, 1); // Converted from nvgShapeAntiAlias

   CGRectPartitionVertically( canvas, 20.0, 3, rows);
   for( i = 2; i < 3; i++)
   {
      CGRectPartitionHorizontally( rows[ i], 20.0, 3, columns);
      for( j = 0; j < 3; j++)
      {
         fillRect = CGRectIntegral( columns[ j]);
         rect     = CGRectMakeStrokeRect( fillRect, strokeWidth, CGOutside);

         CGContextBeginPath( context);
         {
            CGContextStrokeWidth( context, strokeWidth);
            CGContextStrokeColor( context, CGColorMake( 1.0, 1.0, 1.0, 0.8));

            CGContextMoveTo( context, CGPointMake( CGRectGetMinX( rect),       CGRectGetMinY( rect) - 3.0));
            CGContextLineTo( context, CGPointMake( CGRectGetMinX( rect),       CGRectGetMinY( rect) + 3.0));
            CGContextMoveTo( context, CGPointMake( CGRectGetMinX( rect) - 3.0, CGRectGetMinY( rect)));
            CGContextLineTo( context, CGPointMake( CGRectGetMinX( rect) + 3.0, CGRectGetMinY( rect)));

            CGContextMoveTo( context, CGPointMake( CGRectGetMaxX( rect),       CGRectGetMinY( rect) - 3.0));
            CGContextLineTo( context, CGPointMake( CGRectGetMaxX( rect),       CGRectGetMinY( rect) + 3.0));
            CGContextMoveTo( context, CGPointMake( CGRectGetMaxX( rect) - 3.0, CGRectGetMinY( rect)));
            CGContextLineTo( context, CGPointMake( CGRectGetMaxX( rect) + 3.0, CGRectGetMinY( rect)));

            CGContextMoveTo( context, CGPointMake( CGRectGetMinX( rect),       CGRectGetMaxY( rect) - 3.0));
            CGContextLineTo( context, CGPointMake( CGRectGetMinX( rect),       CGRectGetMaxY( rect) + 3.0));
            CGContextMoveTo( context, CGPointMake( CGRectGetMinX( rect) - 3.0, CGRectGetMaxY( rect)));
            CGContextLineTo( context, CGPointMake( CGRectGetMinX( rect) + 3.0, CGRectGetMaxY( rect)));

            CGContextMoveTo( context, CGPointMake( CGRectGetMaxX( rect),       CGRectGetMaxY( rect) - 3.0));
            CGContextLineTo( context, CGPointMake( CGRectGetMaxX( rect),       CGRectGetMaxY( rect) + 3.0));
            CGContextMoveTo( context, CGPointMake( CGRectGetMaxX( rect) - 3.0, CGRectGetMaxY( rect)));
            CGContextLineTo( context, CGPointMake( CGRectGetMaxX( rect) + 3.0, CGRectGetMaxY( rect)));
         }
         CGContextStroke( context);
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

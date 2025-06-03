//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#define _GNU_SOURCE

#import "import-private.h"


#define SPEED    240

static int    modes[] =
{
   NVG_SOURCE_OVER,
   NVG_SOURCE_IN,
   NVG_SOURCE_OUT,
   NVG_ATOP,

   NVG_DESTINATION_OVER,
   NVG_DESTINATION_IN,
   NVG_DESTINATION_OUT,
   NVG_DESTINATION_ATOP,

   NVG_LIGHTER,
   NVG_COPY,
   NVG_XOR,

   1848
};


static char   *mode_names[] =
{
   "SOURCE_OVER",
   "SOURCE_IN",
   "SOURCE_OUT",
   "ATOP",

   "DESTINATION_OVER",
   "DESTINATION_IN",
   "DESTINATION_OUT",
   "DESTINATION_ATOP",

   "LIGHTER",
   "COPY",
   "XOR",
   "*CUSTOM*"
};


static char   *mode_name_for_mode( int mode)
{
   unsigned int  i;

   for( i = 0; i < sizeof( mode_names) / sizeof( mode_names[ 0]); i++)
      if( modes[ i] == mode)
         return( mode_names[ i]);
   abort();
}



static void   drawGridInRect( CGContext  *context, CGRect rect)
{
#define B   { 0xF8, 0xF8, 0xF8, 0x7F }
#define G   { 0xA2, 0xA2, 0xA2, 0x7F }
   static uint8_t   imagedata[ 8][ 8][ 4] =
   {
       { B, B, B, B,  G, G, G, G },
       { B, B, B, B,  G, G, G, G },
       { B, B, B, B,  G, G, G, G },
       { B, B, B, B,  G, G, G, G },

       { G, G, G, G,  B, B, B, B },
       { G, G, G, G,  B, B, B, B },
       { G, G, G, G,  B, B, B, B },
       { G, G, G, G,  B, B, B, B },
   };
   static MulleUIResourceStorageKeyDefine( grid);
   CGImage   *image;

   image = [context imageWithRGBABytes:imagedata
                            bitmapSize:CGPixelSizeMake( 8, 8)
                          textureFlags:CGImageFlagRepeatX|CGImageFlagRepeatY
                        nameUTF8String:NULL
                           resourceKey:MulleUIResourceStorageKey( grid)];
   assert( image);

   [image drawRect:rect
           options:NULL
           context:context];
}




static void   drawCirclesInRect( CGContext *context,
                                 NSUInteger step,
                                 CGRect rect,
                                 int  operation)
{
   CACircle            circle;
   CACircle            circles[ 3];
   CGFloat             radius;
   CGFloat             factor;
   CGFloat             deg;
   CGFloat             alpha;

   CGContextSave( context);
   {
      factor = CGContextGetLinearAnimationFactor( context, SPEED * 4);
      if( factor >= 1.0 / 3)
      {
         CGContextFillRectWithColor( context, rect, CGColorMakeBlack());
      }

      if( factor >= 2.0 / 3)
      {
         CGContextGlobalCompositeOperation( context, NVG_COPY);
         drawGridInRect( context, rect);
      }

      circle = CGRectGetInnerCircle( rect);
      radius = CACircleGetRadius( circle) / 2.0;
      circle = CACircleInset( circle, radius + radius / 4.0);
      radius += radius / 4.0;

      if( operation == 1848)
         CGContextGlobalCompositeBlendFuncSeparate( context, NVG_DST_COLOR, NVG_SRC_ALPHA, NVG_SRC_COLOR, NVG_ZERO);
      else
         CGContextGlobalCompositeOperation( context, operation);
      factor = CGContextGetBackAndForthAnimationFactor( context, SPEED);

      deg    = 360.0f * factor + 60.0f * (step / (3.0f * 4.0f));

      circles[ 0].center = CACirclePointAtAngle( circle, CADegreesToAngle( deg + 0.0));
      circles[ 0].radius = radius;
      circles[ 1].center = CACirclePointAtAngle( circle, CADegreesToAngle( deg + 120.0));
      circles[ 1].radius = radius;
      circles[ 2].center = CACirclePointAtAngle( circle, CADegreesToAngle( deg + 240.0));
      circles[ 2].radius = radius;

      factor = CGContextGetBackAndForthAnimationFactor( context, SPEED);
      alpha  = factor;
      CGContextFillCircleWithColor( context, circles[ 0], CGColorBySettingAlpha( CGColorMakeRed(),  alpha));
      CGContextFillCircleWithColor( context, circles[ 1], CGColorBySettingAlpha( CGColorMakeLime(), alpha));
      CGContextFillCircleWithColor( context, circles[ 2], CGColorBySettingAlpha( CGColorMakeBlue(), alpha));
   }
   CGContextRestore( context);
}


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *_context)
{
   CGContext           *context = _context;
   CGRect              canvas;
   CGRect              rect;
   CGRect              info;
   CGRect              area;
   CGRect              rects[ 3][ 4];
   NSUInteger          i, j;
   int                 mode;

   canvas = [layer canvas];
   CGContextFillRectWithColor( context, canvas, CGColorMake( 0.5, 0.5, 0.5, 1.0));
//   MulleUICLog( "f: %s b: %s c: %s",
//                     CGRectUTF8String( [layer frame]),
//                     CGRectUTF8String( [layer bounds]),
//                     CGRectUTF8String( [layer canvas]));

   CGRectPartitionVerticallyAndHorizontally( CGRectInset( canvas, 8, 8),
                                             CGSizeMake( 8, 8),
                                             3,
                                             4,
                                             (CGRect *) rects);
   for( j = 0; j < 3; j++)
   {
      for( i = 0; i < 4; i++)
      {
         mode = j * 4 + i;
         rect = CGRectIntegral( rects[ j][ i]);
         CGRectDivide( rect, &info, &area, 24, CADirectionBottom);

         drawCirclesInRect( context,
                            mode,
                            area,
                            modes[ mode]);

         [context useDefaultFont];
         CGContextFontSize( context, 12.0f);
         CGContextTextColor( context, CGColorMakeBlack());
         CGContextTextBackgroundColor( context, CGColorMakeWhite());
         CGContextFormatInRect( context, CGRectInset( info, 2, 2),
                              CGContentModeCenter,
                              0,
                              "%s",
                              mode_name_for_mode( modes[ mode]));
      }
   }

   return( YES);
}


int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 800, 800),
                                           NULL,
                                           60.0f));
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

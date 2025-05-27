#define _GNU_SOURCE

#import "import-private.h"


#define SPEED    60

static int    modes[] =
{
   CGBlendFactorZero,
   CGBlendFactorOne,
   CGBlendFactorSrcColor,
   CGBlendFactorOneMinusSrcColor,

   CGBlendFactorDstColor,
   CGBlendFactorOneMinusDstColor,
   CGBlendFactorSrcAlpha,
   CGBlendFactorOneMinusSrcAlpha,

   CGBlendFactorDstAlpha,
   CGBlendFactorOneMinusDstAlpha,
   CGBlendFactorSrcAlphaSaturate
};


static char   *mode_names[] =
{
   "CGBlendFactorZero",
   "CGBlendFactorOne",
   "CGBlendFactorSrcColor",
   "CGBlendFactorOneMinusSrcColor",

   "CGBlendFactorDstColor",
   "CGBlendFactorOneMinusDstColor",
   "CGBlendFactorSrcAlpha",
   "CGBlendFactorOneMinusSrcAlpha",

   "CGBlendFactorDstAlpha",
   "CGBlendFactorOneMinusDstAlpha",
   "CGBlendFactorSrcAlphaSaturate"
};


static char   *mode_name_for_mode( int mode)
{
   unsigned int  i;

   for( i = 0; i < 11; i++)
      if( modes[ i] == mode)
         return( mode_names[ i]);
   abort();
}


static void   drawGridInRect( CGContext  *context, CGRect rect)
{
#define B   { 0xF8, 0xF8, 0xF8, 0xFF }
#define G   { 0xC2, 0xC2, 0xC2, 0xFF }
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
   CGImage   *image;

   image = [[[CGImage alloc] initWithRGBABytes:imagedata
                                    bitmapSize:CGPixelSizeMake( 8, 8)
                                  textureFlags:NVG_IMAGE_REPEATX|NVG_IMAGE_REPEATY
                                       context:context] autorelease];
   [image drawRect:rect
           options:NULL
           context:context];
}




static void   drawCirclesInRect( CGContext *context,
                                 NSUInteger frameNr,
                                 NSUInteger step,
                                 CGRect rect,
                                 int srcRGB,
                                 int srcAlpha,
                                 int dstRGB,
                                 int dstAlpha)
{
   CACircle            circle;
   CACircle            circles[ 3];
   CGFloat             radius;
   CGFloat             factor;
   CGFloat             deg;
   CGFloat             alpha;
   CGRect              rects[ 2][ 2];

   drawGridInRect( context, rect);
   CGContextFillRectWithColor( context, rect, CGColorMakeBlack());

//   CGRectPartition2x2( rect, CGSizeZero, rects);
//
//   CGContextFillRectWithColor( context, CGRectIntegral( rects[ 0][ 0]), CGColorMakeBlack());
//   CGContextFillRectWithColor( context, CGRectIntegral( rects[ 1][ 0]), CGColorMakeBlack());
//   CGContextFillRectWithColor( context, CGRectIntegral( rects[ 0][ 1]), CGColorMakeWhite());
//   CGContextFillRectWithColor( context, CGRectIntegral( rects[ 1][ 1]), CGColorMakeWhite());

   circle = CGRectGetInnerCircle( rect);
   radius = CACircleGetRadius( circle) / 2.0;
   circle = CACircleInset( circle, radius + radius / 4.0);
   radius += radius / 4.0;

   CGContextSave( context);
   {
//      CGContextGlobalCompositeOperation( context, CGCompositeOperationLighter); // Updated commented line
      CGContextGlobalCompositeBlendFuncSeparate( context, srcRGB, srcAlpha, dstRGB, dstAlpha);
//      CGContextGlobalCompositeBlendFuncSeparate( context, // Updated commented line
//                                           CGBlendFactorOne,
//                                           CGBlendFactorOne,
//                                           CGBlendFactorOne,
//                                           CGBlendFactorOne);
      factor = (frameNr % 360) / (CGFloat) (360 - 1);
      deg    = 360.0f * factor + 60.0f * (step / (11.0f * 11.0f));

      circles[ 0].center = CACirclePointAtAngle( circle, CADegreesToAngle( deg + 0.0));
      circles[ 0].radius = radius;
      circles[ 1].center = CACirclePointAtAngle( circle, CADegreesToAngle( deg + 120.0));
      circles[ 1].radius = radius;
      circles[ 2].center = CACirclePointAtAngle( circle, CADegreesToAngle( deg + 240.0));
      circles[ 2].radius = radius;


      alpha  = factor < 0.5
               ? 1.0
               : 0.5;
      CGContextFillCircleWithColor( context, circles[ 0], CGColorBySettingAlpha( CGColorMakeRed(),  alpha));
      CGContextFillCircleWithColor( context, circles[ 1], CGColorBySettingAlpha( CGColorMakeLime(), alpha));
      CGContextFillCircleWithColor( context, circles[ 2], CGColorBySettingAlpha( CGColorMakeBlue(), alpha));
   }
   CGContextRestore( context);
}


static NSInteger   freeze;

static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *_context)
{
   CGContext           *context = _context;
   int                 srcRGB;
   int                 dstRGB;
   int                 srcAlpha;
   int                 dstAlpha;
   NSUInteger          frameNr;
   CGRect              canvas;
   CGRect              area;
   CGRect              info;
   CGRect              rects[ 11][ 11];
   NSUInteger          i, j;
   NSUInteger          k, l;
   CGPoint             location;

   if( [context buttonStates])
   {
      freeze = freeze ? freeze : [context numberOfFrames];
      [context setNumberOfFrames:freeze];
   }
   else
      freeze = 0;

   frameNr  = freeze ? freeze : [context numberOfFrames];
   frameNr  = frameNr % (11 * 11 * SPEED);
   canvas   = [layer canvas];

   CGRectDivide( canvas, &info, &area, 24, CADirectionBottom);

   // start with nanovg default

   k = (0 + (frameNr / (SPEED))) % 11;
   l = (0 + (frameNr / (SPEED * 11))) % 11;
   srcAlpha = modes[ k];
   dstAlpha = modes[ l];

   CGRectPartitionVerticallyAndHorizontally( CGRectInset( area, 2, 2),
                                             CGSizeMake( 2, 2),
                                             11,
                                             11,
                                             (CGRect *) rects);
   for( j = 0; j < 11; j++)
   {
      dstRGB   = modes[ j];
      for( i = 0; i < 11; i++)
      {
         srcRGB = modes[ i];
         drawCirclesInRect( context,
                            frameNr,
                            j * 11 + i,
                            CGRectIntegral( rects[ j][ i]),
                            srcRGB,
                            srcAlpha,
                            dstRGB,
                            dstAlpha);
      }
   }

   [context useDefaultFont];

   srcRGB = modes[ 0];
   dstRGB = modes[ 0];

   location = [context mouseLocation];
   for( j = 0; j < 11; j++)
   {
      dstRGB = modes[ j];
      for( i = 0; i < 11; i++)
      {
         srcRGB = modes[ i];
         if( CGRectContainsPoint( rects[ j][ i], location))
            goto found;
      }
   }

found:
   CGContextFontSize( context, 12.0f);
   CGContextTextColor( context, CGColorMakeBlack());
   CGContextTextBackgroundColor( context, CGColorMakeWhite());
   if( [context buttonStates])
      CGContextFormatInRect( context, CGRectInset( info, 2, 2),
                           CGContentModeLeft,
                           0,
                           "srcRGB: %s dstRGB: %s",
                           mode_name_for_mode( srcRGB),
                           mode_name_for_mode( dstRGB));

   CGContextFormatInRect( context, CGRectInset( info, 2, 2),
                        CGContentModeRight,
                        0,
                        "%d (%d) srcAlpha: %s dstAlpha: %s",
                        l * 11 + k, 11 * 11,
                        mode_name_for_mode( srcAlpha),
                        mode_name_for_mode( dstAlpha));


//   [context useDefaultFont];
//   CGContextFontSize( context, 20.0f);
//   CGContextTextColor( context, CGColorMakeBlack(), CGColorMakeWhite());
//   CGContextFormatInRect( context, CGRectInset( rects[ 0][ 0], 10, 10), CGContentModeTopLeft, 0, "srcRGB: %s", mode_name_for_mode( srcRGB));
//
//   CGContextTextColor( context, CGColorMakeBlack(), CGColorMakeLightGray());
//   CGContextFormatInRect( context, CGRectInset( rects[ 0][ 1], 10, 10), CGContentModeTopRight, 0, "dstRGB: %s", mode_name_for_mode( dstRGB));
//
//   CGContextTextColor( context, CGColorMakeWhite(), CGColorMakeGray());
//   CGContextFormatInRect( context, CGRectInset( rects[ 1][ 0], 10, 10), CGContentModeBottomLeft, 0, "srcAlpha: %s", mode_name_for_mode( srcAlpha));
//
//   CGContextTextColor( context, CGColorMakeWhite(), CGColorMakeBlack());
//   CGContextFormatInRect( context, CGRectInset( rects[ 1][ 1], 10, 10), CGContentModeBottomRight, 0, "dstAlpha: %s", mode_name_for_mode( dstAlpha));
//   drawCirclesInRect( context, canvas, srcRGB, srcAlpha, dstRGB, dstAlpha);
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

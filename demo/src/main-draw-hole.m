#define _GNU_SOURCE

#import "import-private.h"

// this demo shows how to draw "holes". Notice how the first nvgPathWinding
// is completely ignored. It doesn't really (seem) to matter, if you do
// hole / solid or solid / hole, the result is the same.

static void   drawCheckboard( CGRect  rect, CGContext *context)
{
   CGImage   *image;

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

   image = [[[CGImage alloc] initWithRGBABytes:imagedata
                                    bitmapSize:CGPixelSizeMake( 8, 8)
                                  textureFlags:CGImageFlagRepeatX|CGImageFlagRepeatY
                                       context:context] autorelease];
   [image drawRect:rect
           options:NULL
           context:context];
}


static void   drawRect( CGContext *context, CGRect rect, int slim)
{
   CGRect   drawRect;

   drawRect = CGRectInset( rect, 20, 20);
   if( slim)
   {
      drawRect.origin.y    = CGRectGetMidY( rect);
      drawRect.size.height = 0.0;
      drawRect             = CGRectExtrude( drawRect, 0.0, 5.0);
   }

#if 1
   CGContextRect( context, drawRect);
#else
   CGContextRoundedRect( context, drawRect, 3.0);
#endif
}


static void   drawCircle( CGContext *context, CGRect rect, CGFloat animation)
{
   rect = CGRectInset( rect, 20, 20);
   rect = CGRectInset( rect, animation, animation);
   CGContextCircle( context, CGRectGetInnerCircle( rect));
}


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect              rects[ 2][ 4];
   int                 i, j;
   CGRect              rect;
   int                 mode[ 3];
   char                buf[ 64];
   CGPaint             *paint;
   CGFloat             animation;
   int                 slim;
   int                 reverse;
   NSUInteger          animFrame;

   animFrame = [context numberOfFrames] / 10 % 40;
   animation = 20.0f - animFrame;
   animFrame = [context numberOfFrames] / 10 % 80;
   slim      = animFrame >= 40;
   animFrame = [context numberOfFrames] / 10 % 160;
   reverse   = animFrame >= 80;

   drawCheckboard( [layer canvas], context);

   CGRectPartitionVerticallyAndHorizontally(
                       CGRectInset( [layer canvas], 4, 4),
                       CGSizeMake( 4, 4),
                       2,
                       4,
                       (CGRect *) rects);
   for( j = 0; j < 2; j++)
      for( i = 0; i < 4; i++)
      {
         rect = CGRectIntegral( rects[ j][ i]);

         CGContextStrokeRectWithColor( context, rect, 0.5, CGColorMakeBlack());

         CGContextBeginPath( context);
         mode[ 0] = i < 2 ? CGPathFillStyleSolid : CGPathFillStyleHole; // Converted from CGPathFillStyleSolid/CGPathFillStyleHole
         CGContextPathWinding( context, mode[ 0]);

         if( reverse)
            drawCircle( context, rect, animation);
         else
            drawRect( context, rect, slim);

         mode[ 1] = (i & 0x1) ? CGPathFillStyleSolid : CGPathFillStyleHole; // Converted from CGPathFillStyleSolid/CGPathFillStyleHole
         CGContextPathWinding( context, mode[ 1]);

         if( reverse)
            drawRect( context, rect, slim);
         else
            drawCircle( context, rect, animation);

         mode[ 2] = j ? CGPathFillStyleSolid : CGPathFillStyleHole; // Converted from CGPathFillStyleSolid/CGPathFillStyleHole
         CGContextPathWinding( context, mode[ 2]);
         paint = [CGPaint paintWithStartColor:CGColorMake( j / 1.0, i / 3.0, 0.0, 1.0)
                                     endColor:CGColorMakeLightGray()];
         [paint fillWithBounds:rect
                       context:context];

         sprintf( buf, "%c%c%c %s%s",
            mode[ 0] == CGPathFillStyleHole ? 'H' : 'S', // Converted from CGPathFillStyleHole
            mode[ 1] == CGPathFillStyleHole ? 'H' : 'S', // Converted from CGPathFillStyleHole
            mode[ 2] == CGPathFillStyleHole ? 'H' : 'S', // Converted from CGPathFillStyleHole
            slim ? "s" : "f",
            reverse ? "r" : "n");

         [context useDefaultFont];
         CGContextTextColor( context, CGColorMakeGray());
         CGContextTextBackgroundColor( context, CGColorMakeWhite());
         CGContextTextInRect( context,
                        buf,
                        (size_t) -1,
                        CGRectInset( rect, 4, 4),
                        CGContentModeCenterPoint,
                        0);
      }

   return( YES);
}
int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 400, 200),
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

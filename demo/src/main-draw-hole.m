
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
                                    bitmapSize:MulleIntegerSizeMake( 8, 8)
                                  textureFlags:NVG_IMAGE_REPEATX|NVG_IMAGE_REPEATY
                                       context:context] autorelease];
   [image drawRect:rect
           options:NULL
           context:context];
}


static void   drawRect( struct NVGcontext *vg, CGRect rect, int slim)
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
   mvgRect( vg, drawRect);
#else
   mvgRoundedRect( vg, drawRect, 3.0);
#endif
}


static void   drawCircle( struct NVGcontext *vg, CGRect rect, CGFloat animation)
{
   rect = CGRectInset( rect, 20, 20);
   rect = CGRectInset( rect, animation, animation);
   mvgCircle( vg, CGRectGetInnerCircle( rect));
}


static BOOL   drawStuff( CALayer *layer, CGContext *context)
{
   struct NVGcontext   *vg;
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

   vg = CGContextGetNVGContext( context);

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

         mvgStrokeRectWithColor( vg, rect, 0.5, CGColorMakeBlack());

         mvgBeginPath( vg);
         mode[ 0] = i < 2 ? NVG_SOLID : NVG_HOLE;
         mvgPathWinding( vg, mode[ 0]);

         if( reverse)
            drawCircle( vg, rect, animation);
         else
            drawRect( vg, rect, slim);

         mode[ 1] = (i & 0x1) ? NVG_SOLID : NVG_HOLE;
         mvgPathWinding( vg, mode[ 1]);

         if( reverse)
            drawRect( vg, rect, slim);
         else
            drawCircle( vg, rect, animation);

         mode[ 2] = j ? NVG_SOLID : NVG_HOLE;
         mvgPathWinding( vg, mode[ 2]);


         paint = [CGPaint paintWithStartColor:CGColorMake( j / 1.0, i / 3.0, 0.0, 1.0)
                                     endColor:CGColorMakeLightGray()];
         [paint fillWithBounds:rect
                    NVGcontext:vg];

         sprintf( buf, "%c%c%c %s%s",
            mode[ 0] == NVG_HOLE ? 'H' : 'S',
            mode[ 1] == NVG_HOLE ? 'H' : 'S',
            mode[ 2] == NVG_HOLE ? 'H' : 'S',
            slim ? "s" : "f",
            reverse ? "r" : "n");

         [context useDefaultFont];
         mvgTextColor( vg, CGColorMakeGray());
         mvgTextBackgroundColor( vg, CGColorMakeWhite());
         mvgTextInRect( vg,
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
   return( UIApplicationRunDrawCallbackHz( (CALayerDrawCallback_t *) drawStuff,
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


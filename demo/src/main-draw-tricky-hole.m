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
                                  textureFlags:NVG_IMAGE_REPEATX|NVG_IMAGE_REPEATY
                                       context:context] autorelease];
   [image drawRect:rect
           options:NULL
           context:context];
}


static CGRect   drawRect( CGContext *context, CGRect rect) // Converted from struct NVGcontext *vg
{
   CGRect   drawRect;

   drawRect             = CGRectInset( rect, 20, 20);
   drawRect.origin.y    = CGRectGetMidY( rect);
   drawRect.size.height = 0.0;
   drawRect             = CGRectExtrude( drawRect, 0.0, 5.0);
   CGContextRect( context, drawRect); // Converted from mvgRect

   return( drawRect);
}


static void   drawArcHole( CGContext *context, CGRect rect) // Converted from struct NVGcontext *vg
{
   CGPoint          center;
   CGFloat          radius;
   CGPoint          intersectionPoint[ 4];
   CAAngle          angle[ 4];
   CGFloat          h_2;
   CGFloat          y;
   CGFloat          x;
   CGPaint          *paint;

   center = CGRectGetCenter( rect);
   radius = 20.0;

   h_2    = rect.size.height / 2.0;
   y      = h_2 / radius;           // normalize y to the unit circle
   x      = sqrt( 1 - pow(y, 2));   // calculate x in the unit circle

   // calculate intersection points
   intersectionPoint[ 0] = CGPointMake( center.x - x * radius, center.y - h_2);
   intersectionPoint[ 1] = CGPointMake( center.x - x * radius, center.y + h_2);
   intersectionPoint[ 2] = CGPointMake( center.x + x * radius, center.y - h_2);
   intersectionPoint[ 3] = CGPointMake( center.x + x * radius, center.y + h_2);

   fprintf( stderr, "0: %s\n", CGPointUTF8String( intersectionPoint[ 0]));
   fprintf( stderr, "1: %s\n", CGPointUTF8String( intersectionPoint[ 1]));
   fprintf( stderr, "2: %s\n", CGPointUTF8String( intersectionPoint[ 2]));
   fprintf( stderr, "3: %s\n", CGPointUTF8String( intersectionPoint[ 3]));

   CGContextMoveTo( context, intersectionPoint[ 1]); // Converted from mvgMoveTo
   CGContextArc( context, CACircleMakeWithCenterAndRadius( center, radius), angle[ 1], angle[ 0], NVG_CW); // Converted from mvgArc
   CGContextLineTo( context, intersectionPoint[ 2]); // Converted from mvgLineTo
   CGContextArc( context, CACircleMakeWithCenterAndRadius( center, radius), angle[ 2], angle[ 3], NVG_CW); // Converted from mvgArc
   CGContextLineTo( context, intersectionPoint[ 1]); // Converted from mvgLineTo
}



static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect              rect;
   CGRect              aRect;
   CGRect              bRect;
   CGPaint             *paint;
   NSUInteger          animFrame;
   CGFloat             animation;
   int                 animShape;
   CGFloat             radius;

   drawCheckboard( [layer canvas], context);

   animFrame = [context numberOfFrames] / 10 % 40;
   animation = 20.0f - animFrame;
   animFrame = [context numberOfFrames] / 10 % 80;
   animShape = animFrame >= 40;

   rect = CGRectIntegral( [layer canvas]);
   CGContextStrokeRectWithColor( context, rect, 0.5, CGColorMakeBlack()); // Converted from mvgStrokeRectWithColor

   CGContextBeginPath( context); // Converted from mvgBeginPath
   aRect = drawRect( context, rect); // Updated function call
   CGContextPathWinding( context, NVG_SOLID); // Converted from mvgPathWinding

   if( animShape)
   {
      bRect = CACircleGetOuterRect( CACircleMakeWithCenterAndRadius( CGRectGetCenter( rect), 50.0));
      bRect = CGRectOffset( bRect, animation * rect.size.width / 2.0 / 20.0, 0.0);
      CGContextRect( context, bRect); // Converted from mvgRect
      CGContextPathWinding( context, NVG_HOLE); // Converted from mvgPathWinding
   }
   else
   {
      radius = CGRectGetHeight( aRect) / 2.0;
      bRect  = CACircleGetOuterRect( CACircleMakeWithCenterAndRadius( CGRectGetCenter( rect), radius));
      bRect  = CGRectOffset( bRect, animation * rect.size.width / 2.0 / 20.0, 0.0);
      CGContextCircle( context, CACircleMakeWithCenterAndRadius( CGRectGetCenter( bRect), radius - 1.0)); // Converted from mvgCircle
      CGContextPathWinding( context, NVG_HOLE); // Converted from mvgPathWinding
   }

   paint = [CGPaint paintWithStartColor:CGColorMakeGray()
                               endColor:CGColorMakeBlack()];
   [paint fillWithBounds:aRect
                 context:context];
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

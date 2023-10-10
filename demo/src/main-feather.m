#define _GNU_SOURCE

#import "import-private.h"


#define COLS 2
#define ROWS 2
#define WEIGH( x)   ((double) (x) / (COLS * ROWS - 1))

#define DISTANCE   40

static BOOL   drawStuff( CALayer *layer, CGContext *context)
{
   CGRect               canvas;
   CGRect               rect;
   CGRect               gradientRect;
   CGRect               textRect;
   CGRect               drawRect;
   CGRect               outlineRect;
   NSUInteger           x, y;
   NSUInteger           i, j;
   CGRect               rects[ COLS * ROWS];
   CGFloat              cornerRadius;
   CGFloat              feather;
   CGFloat              offset;
   NSUInteger           frameNr;
   struct NVGcontext    *vg;
   NVGpaint             paint;
   CGColor              color;
   char                 buf[ 64];

   canvas = [layer canvas];
   rect   = CGRectInset( canvas, DISTANCE, DISTANCE);

   CGRectPartitionIntoRowsAndColumns( rect,
                                      CGSizeMake( DISTANCE, DISTANCE),
                                      ROWS,
                                      COLS,
                                      rects);

   frameNr = [context numberOfFrames];
   vg      = CGContextGetNVGContext( context);

   [context useDefaultFont];  // default
   nvgTextColor( vg, CGColorMakeWhite());
   nvgTextBackgroundColor( vg, CGColorMakeGray());
   nvgFontSize( vg, 14.0);
   sprintf( buf, "frame: %ld", frameNr);
   mvgExtendedAlignedText( vg,
                           buf,
                           (size_t) -1,
                           canvas.origin,
                           CGContentModeLeft|CGContentModeTop,
                           MVGTextAlignVisually);


   i = 0;
   for( y = 0; y < ROWS; y++)
      for( x = 0; x < COLS; x++)
      {
         nvgSave( vg);
         rect         = CGRectIntegral( rects[ i]);

         nvgTranslate( vg, rect.origin.x, rect.origin.y);
         rect.origin  = CGPointZero;

         cornerRadius = rect.size.width / 16.0;
         feather      = (rect.size.width <= rect.size.height
                        ? rect.size.width / 2.0
                        : rect.size.height / 2.0) * WEIGH( i);
         MulleUICLog( "rect:    %s", CGRectUTF8String( rect));
         MulleUICLog( "feather: %g", feather);

         switch( frameNr % 4)
         {
         case 0 : gradientRect = rect;
                  color        = CGColorMakeGreen();
                  break;
         case 1 : gradientRect = CGRectInset( rect, feather / 4.0, feather / 4.0);
                  color        = CGColorMakeGreen();
                  break;
         case 2 : gradientRect = CGRectInset( rect, feather / 2.0, feather / 2.0);
                  color        = CGColorMakeGreen();
                  break;
         case 3 : gradientRect = CGRectInset( rect, feather, feather);
                  color        = CGColorMakeGreen();
                  break;
         }

//         offset = 0;
//        offset  = (rect.size.width <= rect.size.height
//                       ? rect.size.width / 2.0
//                       : rect.size.height / 2.0);
//        offset = offset * 2.0 * ((frameNr >> 2) % 8 / 7.0) - offset;

         paint        = nvgBoxGradient( vg, gradientRect.origin.x,
                                            gradientRect.origin.y,
                                            gradientRect.size.width,
                                            gradientRect.size.height,
                                            cornerRadius,
                                            feather,
                                            CGColorMakeGreen(),
                                            CGColorMakeTransparent());
         nvgBeginPath(vg);

//         drawRect = CGRectExtrude( rect, offset, offset);

         drawRect = rect;
         nvgRoundedRect(vg, drawRect.origin.x,
                            drawRect.origin.y,
                            drawRect.size.width ,
                            drawRect.size.height,
                            cornerRadius);
         nvgFillPaint(vg, paint);
         nvgFill(vg);
#if 0
         nvgBeginPath(vg);
         nvgRoundedRect(vg, rect.origin.x,
                            rect.origin.y,
                            rect.size.width,
                            rect.size.height,
                            cornerRadius);
         switch( frameNr % 4)
         {
         case 0 : color = CGColorMakeYellow();
                  break;
         case 1 : color = CGColorMakeOrange();
                  break;
         case 2 : color = CGColorMakeRed();
                  break;
         case 3 : color = CGColorMakeMagenta();
                  break;
         }
         nvgFillColor(vg, color);
         nvgFill(vg);
#endif

#if 1
         for( j = 0; j < 3; j++)
         {
            color = CGColorMakeWhite();
            switch( j % 3)
            {
            case 0 : outlineRect = CGRectExtrude( rect, 0, 0);  color = CGColorMakeRed(); break;
            case 1 : outlineRect = CGRectInset( rect, feather / 2.0, feather / 2.0); break;
            case 2 : outlineRect = CGRectInset( rect, feather, feather); break;
            }

            nvgBeginPath(vg);
            nvgRoundedRect( vg, outlineRect.origin.x,
                                outlineRect.origin.y,
                                outlineRect.size.width,
                                outlineRect.size.height,
                                cornerRadius);
            nvgStrokeColor( vg, color);
            nvgStrokeWidth( vg, 0.5);
            nvgStroke(vg);
         }
#endif


#if 1
         [context useDefaultFont];  // default
         textRect = CGRectInset( rect, 10, 10);
         nvgFontSize( vg, 14.0);
         nvgTextColor( vg, CGColorMakeBlack());
         nvgTextBackgroundColor( vg, CGColorMakeGreen());

         sprintf( buf, "feather: %g", feather);
         mvgTextInRect( vg, buf,
                        (size_t) -1,
                        CGRectMake( textRect.origin.x, textRect.origin.y + 20, textRect.size.width, 20),
                        CGContentModeLeft,
                        MVGTextAlignVisually);
         sprintf( buf, "gradientRect: %s", CGRectUTF8String( gradientRect));
         mvgTextInRect( vg, buf,
                        (size_t) -1,
                        CGRectMake( textRect.origin.x, textRect.origin.y + 40, textRect.size.width, 20),
                        CGContentModeLeft,
                        MVGTextAlignVisually);
         sprintf( buf, "drawRect: %s", CGRectUTF8String( drawRect));
         mvgTextInRect( vg, buf,
                        (size_t) -1,
                        CGRectMake( textRect.origin.x, textRect.origin.y + 60, textRect.size.width, 20),
                        CGContentModeLeft,
                        MVGTextAlignVisually);
#endif

         nvgRestore( vg);
         ++i;
      }

   return( YES);
}



int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;

   app = [UIApplication sharedInstance];

   window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 800, 600)];
   [window setDrawCallback:(CALayerDrawCallback_t *) drawStuff];
   [window setBackgroundColor:CGColorMakeWithRGBA( 0.5, 0.5, 0.5, 1.0)];
   [window setFrameRateHz:0.5];
   return( [app runWindow:window]);
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


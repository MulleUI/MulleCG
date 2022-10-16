#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>
#include <time.h>


static void   drawFilledRect( NVGcontext *vg, CGRect rect, CGColor color)
{
   nvgBeginPath( vg);
   {
      nvgRect( vg, rect.origin.x,
                   rect.origin.y,
                   rect.size.width,
                   rect.size.height);
      nvgFillColor( vg, color);
   }
   nvgFill( vg);
}


static void   drawStrokedRect( NVGcontext *vg, CGRect rect, CGColor color)
{
   nvgBeginPath( vg);
   {
      nvgRect( vg, rect.origin.x,
                   rect.origin.y,
                   rect.size.width,
                   rect.size.height);
      nvgStrokeWidth( vg, 1.0);
      nvgStrokeColor( vg, color);
   }
   nvgStroke( vg);
}



static char* cpToUTF8(int cp, char* str)
{
   int n = 0;
   if (cp < 0x80) n = 1;
   else if (cp < 0x800) n = 2;
   else if (cp < 0x10000) n = 3;
   else if (cp < 0x200000) n = 4;
   else if (cp < 0x4000000) n = 5;
   else if (cp <= 0x7fffffff) n = 6;
   str[n] = '\0';
   switch (n) {
   case 6: str[5] = 0x80 | (cp & 0x3f); cp = cp >> 6; cp |= 0x4000000;
   case 5: str[4] = 0x80 | (cp & 0x3f); cp = cp >> 6; cp |= 0x200000;
   case 4: str[3] = 0x80 | (cp & 0x3f); cp = cp >> 6; cp |= 0x10000;
   case 3: str[2] = 0x80 | (cp & 0x3f); cp = cp >> 6; cp |= 0x800;
   case 2: str[1] = 0x80 | (cp & 0x3f); cp = cp >> 6; cp |= 0xc0;
   case 1: str[0] = cp;
   }
   return str;
}


static inline CGFloat   CGSizeGetMax( CGSize size)
{
   return( size.width > size.height ? size.width : size.height);
}


static inline CGFloat   CGSizeGetMin( CGSize size)
{
   return( size.width < size.height ? size.width : size.height);
}


static inline CGFloat   CGRectGetCornerRadiusValue( CGRect rect, CGFloat factor)
{
   CGFloat   corner;

   corner  = CGSizeGetMin( rect.size);
   corner *= factor;
   return( corner);
}


// "inspired" by:
//
// https://www.vecteezy.com/vector-art/957623-modern-rounded-web-interface-buttons-set
//
static void   drawFancyButtonBackground( struct NVGcontext *vg, CGRect rect, CGColor color1, CGColor color2)
{
   NVGpaint   paint;
   CGFloat    corner;

   /*
    * outer
    */

   corner = CGRectGetCornerRadiusValue( rect, 0.5);

   nvgBeginPath( vg);
   nvgRoundedRect( vg, rect.origin.x,
                       rect.origin.y,
                       rect.size.width,
                       rect.size.height,
                       corner);

   paint = nvgLinearGradient( vg,
                              CGRectGetMinX( rect),
                              CGRectGetMinY( rect),
                              CGRectGetMinX( rect),   // sic!, we dont want change across x
                              CGRectGetMaxY( rect),
                              color1,
                              color2);
   nvgFillPaint( vg, paint);
   nvgFill( vg);
}



static void   drawFancyButtonHighlight( struct NVGcontext *vg, CGRect rect)
{
   NVGpaint   paint;
   CGFloat    corner;

   /*
    * highlight
    */

   corner = CGRectGetCornerRadiusValue( rect, 0.5);


   nvgBeginPath( vg);
   nvgRoundedRectVarying( vg, rect.origin.x,
                              rect.origin.y,
                              rect.size.width,
                              rect.size.height,
                              corner,
                              corner,
                              0.0,
                              0.0);

   // now subtract the next rect to get a highlight shape
   nvgPathWinding(vg, NVG_HOLE); // sets nvgRoundedRect as a hole

   nvgRoundedRectVarying( vg, rect.origin.x,
                              rect.origin.y + 8,
                              rect.size.width,
                              rect.size.height - 8,
                              corner,
                              corner,
                              0.0,
                              0.0);

   paint = nvgLinearGradient( vg,
                              CGRectGetMinX( rect),
                              CGRectGetMinY( rect),
                              CGRectGetMinX( rect),
                              CGRectGetMinY( rect) + corner,
                              CGColorMakeWithRGBA( 1.0, 1.0, 1.0, 0.8),
                              CGColorMakeTransparent());
//   nvgGlobalCompositeOperation( vg, NVG_LIGHTER);
   nvgFillPaint( vg, paint);
   nvgFill( vg);
}


static void   drawFancyButtonLine( struct NVGcontext *vg, CGRect rect, CGColor color)
{
   CGFloat    corner;

   corner = CGRectGetCornerRadiusValue( rect, 0.5);

   nvgBeginPath( vg);

   nvgRoundedRect( vg, rect.origin.x,
                       rect.origin.y,
                       rect.size.width,
                       rect.size.height,
                       corner);

   nvgGlobalCompositeOperation( vg, NVG_SOURCE_OVER);
   nvgStrokeColor( vg, color);
   nvgStrokeWidth( vg, 1.5);
   nvgStroke( vg);
}


static void   drawFancyButton( CGContext *context, CGRect rect, CGColor colors[ 6])
{
   NVGpaint   paint;
   CGFloat    corner;
   CGRect     innerRect;
   CGRect     lineRect;
   CGRect     outerRect;
   CGRect     middleRect;
   CGFont     *font;

   struct NVGcontext *vg;

   vg = CGContextGetNVGContext( context);

   nvgSave( vg);
   {
      /*
       * outer
       */

      outerRect = rect;
      drawFancyButtonBackground( vg, outerRect, colors[ 0], colors[ 1]);

      /*
       * inner
       */
      innerRect = CGRectInset( outerRect, 6, 6);
      drawFancyButtonBackground( vg, innerRect, colors[ 1], colors[ 0]);


      /*
       * highlight
       */
      drawFancyButtonHighlight( vg, innerRect);

      /*
       * line
       */
      lineRect = CGRectInset( innerRect, 12, 12);
      drawFancyButtonLine( vg, lineRect, colors[ 3]);

      // draw text
      // recognize that nvgText layout is somewhat broken, if using
      // NVG_ALIGN_CENTER and NVG_ALIGN_RIGHT
      //
      char     icon[8];
      float    iw = 0;
      float    ih = 0;
      int      preicon = 0xE740;
      float    x, y, w, h;
      char     *text = "Start";
      char     *iconText;
      CGRect   iconRect;
      CGRect   textRect;
      CGRect   remainingRect;
      CGSize   size;

      struct MulleLayout     layout;

      drawStrokedRect( vg, lineRect, CGColorMakeGray());

      corner  = CGRectGetCornerRadiusValue( lineRect, 0.5);
      corner /= 4;

      MulleLayoutInitReverse( &layout, lineRect, MulleEdgeInsetsMake( corner, corner + 8, corner, corner));

      remainingRect = MulleLayoutGetRemainingRowContentRect( &layout);
      drawStrokedRect( vg, remainingRect, CGColorMakeGray());

      {
         if( preicon != 0)
         {
            font = [context fontWithNameUTF8String:"icons"];
            assert( font);

            size = MulleLayoutGetRowContentSize( &layout);
            if( size.width > size.height)
               iconRect = MulleLayoutAddToRow( &layout,
                                               CGSizeMake( size.height, size.height),
                                               MulleEdgeInsetsMake( 0, 8, 0, 0));
            else
               iconRect = MulleLayoutAddToRow( &layout,
                                               CGSizeMake( size.width, size.width),
                                               MulleEdgeInsetsMake( 0, 8, 0, 0));
            drawStrokedRect( vg, iconRect, CGColorMakeGray());

            nvgBeginPath( vg);
            nvgCircle( vg, CGRectGetMidX( iconRect), CGRectGetMidY( iconRect), iconRect.size.width / 2.0);
#if 0
            paint = nvgLinearGradient( vg,
                                       CGRectGetMinX( iconRect),
                                       CGRectGetMinY( iconRect),
                                       CGRectGetMinX( iconRect),
                                       CGRectGetMaxY( iconRect),
                                       CGColorMakeWithRGBA( 0.6, 0.6, 0.6, 0.6),
                                       CGColorMakeWithRGBA( 0.2, 0.2, 0.2, 0.2));
#else
            paint = nvgRadialGradient( vg,
                                       CGRectGetMidX( iconRect) - iconRect.size.width / 8.0,
                                       CGRectGetMidY( iconRect) - iconRect.size.width / 8.0,
                                       iconRect.size.width / 8.0,
                                       iconRect.size.width / 2.0,
                                       CGColorMakeWithRGBA( 1.0, 1.0, 1.0, 0.6),
                                       CGColorMakeWithRGBA( 0.2, 0.2, 0.2, 0.2)),
#endif
            nvgFillPaint( vg, paint);
            nvgFill( vg);
            nvgStrokeColor( vg, CGColorMakeWithRGBA( 0.8, 0.8, 0.8, 0.8));
            nvgStroke( vg);

            iconRect = CGRectInset( iconRect, iconRect.size.width / 8.0, iconRect.size.width / 8.0);

            nvgFontSize( vg, iconRect.size.height);
            nvgFontFace( vg, "icons");


            iconText = cpToUTF8( preicon, icon);

            nvgGlobalCompositeOperation( vg, NVG_LIGHTER);
            nvgTextColor( vg, colors[ 3], CGColorByMultiplyingAlpha( colors[ 1], 0.2));
            mvgTextInRect( vg, iconText,
                               NULL,
                               iconRect,
                               CGContentModeScaleAspectFit,
                               MVGTextAlignVisually);
         }

         textRect = MulleLayoutGetRemainingRowContentRect( &layout);
         drawStrokedRect( vg, textRect, CGColorMakeBlack());

         font = [context fontWithNameUTF8String:"sans"];
         assert( font);

         nvgFontFace(vg, "sans");
         nvgGlobalCompositeOperation( vg, NVG_SOURCE_OVER);
         nvgTextColor( vg, CGColorByMultiplyingAlpha( colors[ 3], 0.9),
                           CGColorByMultiplyingAlpha( colors[ 1], 1.0));
         mvgTextInRect( vg, text,
                            NULL,
                            CGRectInset( textRect, 4, 4),
                            CGContentModeScaleAspectFit,
                            MVGTextAlignVisually);
      }
      MulleLayoutDone( &layout);
   }
   nvgRestore( vg);
}


static void   drawButton( CALayer *layer, CGContext *context)
{
   CGRect              canvas;
   CGRect              rects[ 3][ 3];
   CGRect              rect;
   NSUInteger          x, y;
   CGColor             colors[ 6];
   NVGcontext          *vg;

   canvas = [layer canvas];
   canvas = CGRectInset( canvas, 16, 16);

   CGRectPartitionIntoRowsAndColumns( canvas, CGSizeMake( 16, 16), 3, 3, (CGRect *) rects);

   for( y = 0; y < 3; y++)
      for( x = 0; x < 3; x++)
      {
         colors[ 0] = CGColorMakeWithHSV( 1.0 / 8.0 * (x + y * 3), 1.0, 1.0);
         colors[ 1] = CGColorMakeWithHSV( 1.0 / 8.0 * (x + y * 3), 1.0, 0.5);
         colors[ 2] = CGColorMakeTransparent();
         colors[ 3] = CGColorMakeWithRGB( 1.0, 1.0, 1.0);

         rect = CGRectIntegral( rects[ y][ x]);
         drawFancyButton( context, rect, colors);

         vg = CGContextGetNVGContext( context);
         nvgFontSize( vg, 14.0f);
         nvgFontFace( vg, "sans");
         nvgTextColor( vg, CGColorMakeWhite(), CGColorMakeWithRGBA( 0.8, 0.8, 0.8, 1.0));
         mvgTextInRect( vg,
                        CGRectUTF8String( rect),
                        NULL,
                        CGRectPlaceBelowRect( rect, 0.0, 16.0f),
                        CGContentModeCenterPoint,
                        0);
      }
}


void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame  = [[window contentPlane] contentRect];
   view   = [UIView viewWithFrame:frame];
   [[window contentPlane] setDrawCallback:drawButton];
   [[window contentPlane] addSubview:view];
}


int   main( int argc, char *argv[])
{
   UIWindow         *window;
   UIApplication    *app;

   app = [UIApplication sharedInstance];
   @autoreleasepool
   {
      window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0, 0.0, 1280, 500)
                                titleUTF8String:"Demo"
                                      styleMask:UIWindowStyleMaskDefault & ~UIWindowStyleRetained] autorelease];

      assert( window);
      [window setBackgroundColor:CGColorMakeWithRGBA( 0.8, 0.8, 0.8, 1.0)];
      setupScene( window);
      [app addWindow:window];
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



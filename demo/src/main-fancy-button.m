#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>
#include <time.h>
static void   drawFilledRect( CGContext *context, CGRect rect, CGColor color)
{
   CGContextBeginPath( context);
   {
      CGContextRect( context, CGRectMake( rect.origin.x, rect.origin.y, rect.size.width, rect.size.height));
      CGContextFillColor( context, color);
   }
   CGContextFill( context);
}
static void   drawStrokedRect( CGContext *context, CGRect rect, CGColor color)
{
   CGContextBeginPath( context);
   {
      CGContextRect( context, CGRectMake( rect.origin.x, rect.origin.y, rect.size.width, rect.size.height));
      CGContextStrokeWidth( context, 1.0);
      CGContextStrokeColor( context, color);
   }
   CGContextStroke( context);
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
static void   drawFancyButtonBackground( CGContext *context, CGRect rect, CGColor color1, CGColor color2)
{
   CGFloat    corner;

   /*
    * outer
    */

   corner = CGRectGetCornerRadiusValue( rect, 0.5);

   CGContextBeginPath( context);
   CGContextRoundedRect( context, CGRectMake( rect.origin.x, rect.origin.y, rect.size.width, rect.size.height), corner);

   CGContextSetFillLinearGradient( context, CGPointMake( CGRectGetMinX( rect), CGRectGetMinY( rect)), CGPointMake( CGRectGetMinX( rect), CGRectGetMaxY( rect)), color1, color2);
   CGContextFill( context);
   CGContextFill( context);
}

static void   drawFancyButtonHighlight( CGContext *context, CGRect rect)
{
   CGFloat    corner;

   /*
    * highlight
    */

   corner = CGRectGetCornerRadiusValue( rect, 0.5);
   CGContextBeginPath( context);
   CGContextRoundedRectVarying( context, CGRectMake( rect.origin.x, rect.origin.y, rect.size.width, rect.size.height), MulleCornerInsetsMake( corner, corner, 0.0, 0.0));

   // now subtract the next rect to get a highlight shape
   CGContextPathWinding( context, CGPathFillStyleHole); // sets nvgRoundedRect as a hole

   CGContextRoundedRectVarying( context, CGRectMake( rect.origin.x, rect.origin.y + 8, rect.size.width, rect.size.height - 8), MulleCornerInsetsMake( corner, corner, 0.0, 0.0));

   CGContextSetFillLinearGradient( context, CGPointMake( CGRectGetMinX( rect), CGRectGetMinY( rect)), CGPointMake( CGRectGetMinX( rect), CGRectGetMinY( rect) + corner), CGColorMakeWithRGBA( 1.0, 1.0, 1.0, 0.8), CGColorMakeTransparent());
//   CGContextGlobalCompositeOperation( context, CGCompositeOperationLighter);
   CGContextFill( context);
   CGContextFill( context);
}
static void   drawFancyButtonLine( CGContext *context, CGRect rect, CGColor color)
{
   CGFloat    corner;

   corner = CGRectGetCornerRadiusValue( rect, 0.5);

   CGContextBeginPath( context);

   CGContextRoundedRect( context, CGRectMake( rect.origin.x, rect.origin.y, rect.size.width, rect.size.height), corner);

   CGContextGlobalCompositeOperation( context, CGCompositeOperationSourceOver);
   CGContextStrokeColor( context, color);
   CGContextStrokeWidth( context, 1.5);
   CGContextStroke( context);
}
static void   drawFancyButton( CGContext *context, CGRect rect, CGColor colors[ 6])
{
   CGFloat    corner;
   CGRect     innerRect;
   CGRect     lineRect;
   CGRect     outerRect;
   CGRect     middleRect;
   CGFont     *font;
   CGContextSave( context);
   {
      /*
       * outer
       */

      outerRect = rect;
      drawFancyButtonBackground( context, outerRect, colors[ 0], colors[ 1]);

      /*
       * inner
       */
      innerRect = CGRectInset( outerRect, 6, 6);
      drawFancyButtonBackground( context, innerRect, colors[ 1], colors[ 0]);

      /*
       * highlight
       */
      drawFancyButtonHighlight( context, innerRect);

      /*
       * line
       */
      lineRect = CGRectInset( innerRect, 12, 12);
      drawFancyButtonLine( context, lineRect, colors[ 3]);

      // draw text
      // recognize that nvgText layout is somewhat broken, if using
      // CGTextAlignCenter and CGTextAlignRight
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

      drawStrokedRect( context, lineRect, CGColorMakeGray());

      corner  = CGRectGetCornerRadiusValue( lineRect, 0.5);
      corner /= 4;

      MulleLayoutInitReverse( &layout, lineRect, MulleEdgeInsetsMake( corner, corner + 8, corner, corner));

      remainingRect = MulleLayoutGetRemainingRowContentRect( &layout);
      drawStrokedRect( context, remainingRect, CGColorMakeGray());

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
            drawStrokedRect( context, iconRect, CGColorMakeGray());

            CGContextBeginPath( context);
            CGContextCircle( context, CACircleMakeWithCenterAndRadius( CGPointMake( CGRectGetMidX( iconRect), CGRectGetMidY( iconRect)), iconRect.size.width / 2.0));
#if 0
   CGContextSetFillLinearGradient( context, CGPointMake( CGRectGetMinX( iconRect), CGRectGetMinY( iconRect)), CGPointMake( CGRectGetMinX( iconRect), CGRectGetMaxY( iconRect)), CGColorMakeWithRGBA( 0.6, 0.6, 0.6, 0.6), CGColorMakeWithRGBA( 0.2, 0.2, 0.2, 0.2));
#else
   CGContextSetFillRadialGradient( context, CACircleMakeWithCenterAndRadius( CGPointMake( CGRectGetMidX( iconRect) - iconRect.size.width / 8.0, CGRectGetMidY( iconRect) - iconRect.size.width / 8.0), iconRect.size.width / 2.0), CGColorMakeWithRGBA( 0.2, 0.2, 0.2, 0.2), iconRect.size.width / 8.0, CGColorMakeWithRGBA( 1.0, 1.0, 1.0, 0.6)),
#endif
            CGContextFill( context);
            CGContextFill( context);
            CGContextStrokeColor( context, CGColorMakeWithRGBA( 0.8, 0.8, 0.8, 0.8));
            CGContextStroke( context);

            iconRect = CGRectInset( iconRect, iconRect.size.width / 8.0, iconRect.size.width / 8.0);

            CGContextFontSize( context, iconRect.size.height);
            CGContextFontFace( context, "icons");
            iconText = cpToUTF8( preicon, icon);

            CGContextGlobalCompositeOperation( context, CGCompositeOperationLighter);
            CGContextTextColor( context, colors[ 3]);
            CGContextTextBackgroundColor( context, CGColorMultiplyAlpha( colors[ 1], 0.2));
            CGContextTextInRect( context, iconText,
                               (size_t) -1,
                               iconRect,
                               CGContentModeScaleAspectFit,
                               CGTextOptionAlignVisually);
         }

         textRect = MulleLayoutGetRemainingRowContentRect( &layout);
         drawStrokedRect( context, textRect, CGColorMakeBlack());

         font = [context fontWithNameUTF8String:"sans"];
         assert( font);

         CGContextFontFace( context, "sans");
         CGContextGlobalCompositeOperation( context, CGCompositeOperationSourceOver);
         CGContextTextColor( context, CGColorMultiplyAlpha( colors[ 3], 0.9));
         CGContextTextBackgroundColor( context, CGColorMultiplyAlpha( colors[ 1], 1.0));
         CGContextTextInRect( context, text,
                            (size_t) -1,
                            CGRectInset( textRect, 4, 4),
                            CGContentModeScaleAspectFit,
                            CGTextOptionAlignVisually);
      }
      MulleLayoutDone( &layout);
   }
   CGContextRestore( context);
}
static void   drawButton( CALayer *layer, CGContext *context)
{
   CGRect              canvas;
   CGRect              rects[ 3][ 3];
   CGRect              rect;
   NSUInteger          x, y;
   CGColor             colors[ 6];

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

         CGContextFontSize( context, 14.0f);
         CGContextFontFace( context, "sans");
         CGContextTextColor( context, CGColorMakeWhite());
         CGContextTextBackgroundColor( context, CGColorMakeWithRGBA( 0.8, 0.8, 0.8, 1.0));
         CGContextTextInRect( context, CGRectUTF8String( rect),
                        (size_t) -1,
                        CGRectPlaceBelowRect( rect, 0.0, 16.0f),
                        CGContentModeCenterPoint,
                        0);
      }
}
void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame  = [[window contentView] contentRect];
   view   = [UIView viewWithFrame:frame];
   [[window contentView] setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawButton];
   [[window contentView] addSubview:view];
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

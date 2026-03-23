#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>
#include <time.h>

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
static void   drawFancyStepperBackground( CGContext *context, // Changed from struct CGContext *context
                                          CGRect rect,
                                          CGColor color1,
                                          CGColor color2,
                                          CADirection direction)
{
   CGFloat    corner;
   CGFloat    cornerTR;
   CGFloat    cornerTL;
   CGFloat    cornerBR;
   CGFloat    cornerBL;

   /*
    * outer
    */

   corner = CGRectGetCornerRadiusValue( rect, 0.5);

   if( direction == CADirectionLeft)
   {
      cornerTL = cornerBL = corner;
      cornerBR = cornerTR = 0.0f;
   }
   else
   {
      cornerTL = cornerBL = 0.0f;
      cornerBR = cornerTR = corner;
   }
   CGContextBeginPath( context);
   CGContextRoundedRectVarying( context, CGRectMake( rect.origin.x, rect.origin.y, rect.size.width, rect.size.height), MulleCornerInsetsMake( cornerTL, cornerTR, cornerBR, cornerBL));

   CGContextSetFillLinearGradient( context, CGPointMake( CGRectGetMinX( rect), CGRectGetMinY( rect)), CGPointMake( CGRectGetMinX( rect), CGRectGetMaxY( rect)), color1, color2);
   CGContextFill( context);
   CGContextFill( context);
}
static void   drawFancyStepperHighlight( CGContext *context, // Changed from struct CGContext *context
                                         CGRect rect,
                                         CGFloat thickness,
                                         CGFloat brightness,
                                         CADirection direction)
{
   CGFloat    corner;
   CGFloat    cornerTL;
   CGFloat    cornerTR;

   /*
    * highlight
    */

   corner = CGRectGetCornerRadiusValue( rect, 0.5);

   cornerTL = (direction == CADirectionLeft) ? corner : 0.0f;
   cornerTR = (direction == CADirectionRight) ? corner : 0.0f;

   CGContextBeginPath( context);
   CGContextRoundedRectVarying( context, CGRectMake( rect.origin.x, rect.origin.y, rect.size.width, rect.size.height), MulleCornerInsetsMake( cornerTL, cornerTR, 0.0, 0.0));

   // now subtract the next rect to get a highlight shape
   CGContextPathWinding( context, CGPathFillStyleHole); // sets nvgRoundedRect as a hole

   CGContextRoundedRectVarying( context, CGRectMake( rect.origin.x, rect.origin.y + thickness, rect.size.width, rect.size.height - thickness), MulleCornerInsetsMake( cornerTL, cornerTR, 0.0, 0.0));

   CGContextSetFillLinearGradient( context, CGPointMake( CGRectGetMinX( rect), CGRectGetMinY( rect)), CGPointMake( CGRectGetMinX( rect), CGRectGetMinY( rect) + corner), CGColorMakeWithRGBA( 1.0, 1.0, 1.0, brightness), CGColorMakeTransparent());
//   CGContextGlobalCompositeOperation( context, CGCompositeOperationLighter);
   CGContextFill( context);
   CGContextFill( context);
}
static void   drawFancyStepperLine( CGContext *context, CGRect rect, CGFloat strokeWidth, CGColor color) // Changed from struct CGContext *context
{
   CGFloat    corner;

   corner = CGRectGetCornerRadiusValue( rect, 0.5);

   CGContextBeginPath( context);

   CGContextRoundedRect( context, CGRectMake( rect.origin.x, rect.origin.y, rect.size.width, rect.size.height), corner);

   CGContextGlobalCompositeOperation( context, CGCompositeOperationSourceOver);
   CGContextStrokeColor( context, color);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}

static void   drawEmote( CGContext *context, CGRect iconRect, int unicodeIcon, BOOL highlight)
{
   CGFont              *font;
   char                icon[ 8];
   char                *iconText;
   CGFloat             radius;

   // if too small, we don't draw anything
   radius = CGFloatMinimum( iconRect.size.width, iconRect.size.height) / 2.0;
   if( radius < 5.0 / 2.0)
      return;

   font = [context fontWithNameUTF8String:"icons"];

   if( highlight)
   {
      CGContextBeginPath( context);
      CGContextCircle( context, CACircleMakeWithCenterAndRadius( CGPointMake( CGRectGetMidX( iconRect), CGRectGetMidY( iconRect)), radius));
#if 0
   CGContextSetFillLinearGradient( context, CGPointMake( CGRectGetMinX( iconRect), CGRectGetMinY( iconRect)), CGPointMake( CGRectGetMinX( iconRect), CGRectGetMaxY( iconRect)), CGColorMakeWithRGBA( 0.6, 0.6, 0.6, 0.6), CGColorMakeWithRGBA( 0.2, 0.2, 0.2, 0.2));
#else
   CGContextSetFillRadialGradient( context, CACircleMakeWithCenterAndRadius( CGPointMake( CGRectGetMidX( iconRect) - radius / 8.0, CGRectGetMidY( iconRect) - radius / 8.0), radius / 2.0), CGColorMakeWithRGBA( 0.2, 0.2, 0.2, 0.3), radius / 8.0, CGColorMakeWithRGBA( 1.0, 1.0, 1.0, 0.6));
#endif
      CGContextFill( context);
      CGContextFill( context);
   }
//   CGContextStrokeColor( context, CGColorMakeWithRGBA( 0.8, 0.8, 0.8, 0.8));
//   CGContextStroke( context);

   iconRect.origin = CGPointMake( CGRectGetMidX( iconRect) - radius,
                                  CGRectGetMidY( iconRect) - radius);
   iconRect.size   = CGSizeMake( radius * 2.0, radius * 2.0f);

   CGContextFontSize( context, iconRect.size.height);
   CGContextFontFace( context, "icons");

   iconText = cpToUTF8( unicodeIcon, icon);

   CGContextGlobalCompositeOperation( context, CGCompositeOperationLighter);
   CGContextGlobalAlpha( context, 0.8);
   CGContextTextColor( context, CGColorMakeWhite());
   CGContextTextBackgroundColor( context, CGColorMakeBlack());
   CGContextTextInRect( context, iconText, // Converted from mvgTextInRect
                      (size_t) -1,
                      iconRect,
                      CGContentModeScaleAspectFit,
                      CGTextOptionAlignVisually);
}

static void   drawFancyStepper( CGContext *context, CGRect rect, CGColor colors[ 6])
{
   CGFloat    corner; // This variable seems unused here
   CGRect     innerRect;
   CGRect     iconRect;
   CGRect     lineRect;
   CGRect     contentRect;
   CGRect     outerRect;
   CGRect     middleRect; // This variable seems unused here
   CGRect     leftRect;
   CGRect     rightRect;
   CGFont     *font; // This variable seems unused here
   CGFloat    thickness;
   CGFloat    horw;

   CGContextSave( context);
   {
      /*
       * outer
       */
      outerRect   = rect;
      contentRect = outerRect;

      CGRectDivide( outerRect, &leftRect, &rightRect, outerRect.size.width / 2.0, CADirectionLeft);
      drawFancyStepperBackground( context, leftRect, colors[ 0], colors[ 1], CADirectionLeft); // Pass context
      drawFancyStepperBackground( context, rightRect, colors[ 2], colors[ 3], CADirectionRight); // Pass context

      /*
       * inner
       */
      horw      = CGSizeGetMinimum( contentRect.size);
      horw      = CGFloatClamp( horw, 10.0f, 60.0f);
      thickness = roundf( horw / 15.0);
      innerRect = CGRectInset( contentRect, thickness, thickness);

      CGRectDivide( innerRect, &leftRect, &rightRect, innerRect.size.width / 2.0, CADirectionLeft);
      drawFancyStepperBackground( context, leftRect, colors[ 1], colors[ 0], CADirectionLeft); // Pass context
      drawFancyStepperBackground( context, rightRect, colors[ 3], colors[ 2], CADirectionRight); // Pass context

      contentRect = innerRect;

      /*
       * highlight
       */
      thickness = roundf( horw / 5.0);
      drawFancyStepperHighlight( context, leftRect, thickness, 0.3, CADirectionLeft); // Pass context
      drawFancyStepperHighlight( context, rightRect, thickness, 0.6, CADirectionRight); // Pass context

      if( innerRect.size.height >= 60.0 && innerRect.size.width >= 60.0)
      {
         lineRect = CGRectInset( innerRect, 12, 12);
         drawFancyStepperLine( context, lineRect, 1.5, colors[ 5]); // Pass context
      }

      iconRect = CGRectInset( contentRect, 2, 2);

      CGRectDivide( iconRect, &leftRect, &rightRect, iconRect.size.width / 2.0, CADirectionLeft);
      drawEmote( context, leftRect, 0x2796, NO);  // -
      drawEmote( context, rightRect, 0x2795, NO); // +
      /*
       * line
       */
   }
   CGContextRestore( context);
}

static void   drawStepper( CALayer *layer, CGContext *context)
{
   CGRect              canvas;
   CGRect              rects[ 3][ 3];
   CGRect              rect;
   NSUInteger          x, y;
   CGColor             colors[ 6];
   CGFloat             leftHue;
   CGFloat             rightHue;

   canvas = [layer canvas];
   canvas = CGRectInset( canvas, 16, 16);

   CGRectPartitionIntoRowsAndColumns( canvas, CGSizeMake( 16, 16), 3, 3, (CGRect *) rects);

   for( y = 0; y < 3; y++)
      for( x = 0; x < 3; x++)
      {
         leftHue  = 1.0 / 8.0 * (x + y * 3);
         rightHue = leftHue; //CGFloatClamp( 1.0 / 8.0 * (x + y * 3) + 0.2);

         colors[ 0] = CGColorMakeWithHSV( leftHue, 1.0, 0.5);
         colors[ 1] = CGColorMakeWithHSV( leftHue, 1.0, 1.0);
         colors[ 2] = CGColorMakeWithHSV( rightHue, 0.75, 0.33);
         colors[ 3] = CGColorMakeWithHSV( rightHue, 0.75, 0.66);
         colors[ 4] = CGColorMakeTransparent();
         colors[ 5] = CGColorMakeWithRGB( 1.0, 1.0, 1.0);

         rect = CGRectIntegral( rects[ y][ x]);
         drawFancyStepper( context, rect, colors);
      }
}
void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame  = [[window contentView] contentRect];
   view   = [UIView viewWithFrame:frame];
   [[window contentView] setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStepper];
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

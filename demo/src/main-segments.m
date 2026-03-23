//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#define _GNU_SOURCE

#import "import-private.h"

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
static inline CGFloat   CGRectGetCornerRadiusValue( CGRect rect, CGFloat factor)
{
   CGFloat   corner;

   corner  = CGSizeGetMinimum( rect.size);
   corner *= factor;
   return( corner);
}
struct CornerRadiusInfo
{
   CGFloat   corner;
   CGFloat   cornerTL;
   CGFloat   cornerBL;
   CGFloat   cornerBR;
   CGFloat   cornerTR;
};

struct CornerAndLinearGradientInfo
{
   CGPoint                    gradientStartPoint;
   CGPoint                    gradientEndPoint;
   struct CornerRadiusInfo    cornerInfo;
};
static void   CornerAndLinearGradientInfoInit( struct CornerAndLinearGradientInfo *p,
                                               CGRect rect,
                                               CGFloat cornerFactor,
                                               CADirection direction)
{
   CGFloat   corner;

   if( ! p)
      return;

   memset( p, 0, sizeof( *p));

   corner = CGRectGetCornerRadiusValue( rect, cornerFactor);

   p->cornerInfo.corner  = corner;
   p->gradientStartPoint = CGPointMake( CGRectGetMinX( rect),
                                        CGRectGetMinY( rect));

   // default for no direction (not good for vertical case i suspect)
   p->gradientEndPoint   = CGPointMake( CGRectGetMinX( rect),
                                        CGRectGetMaxY( rect));

   if( direction & (CADirectionLeft|CADirectionRight))
   {
      if( direction & CADirectionLeft)
         p->cornerInfo.cornerTL = p->cornerInfo.cornerBL = corner;
      if( direction & CADirectionRight)
         p->cornerInfo.cornerBR = p->cornerInfo.cornerTR = corner;
   }

   if( direction & (CADirectionTop|CADirectionBottom))
   {
      p->gradientEndPoint = CGPointMake( CGRectGetMaxX( rect),
                                         CGRectGetMinY( rect));
      if( direction & CADirectionTop)
         p->cornerInfo.cornerTL = p->cornerInfo.cornerTR = corner;
      if( direction & CADirectionBottom)
         p->cornerInfo.cornerBL = p->cornerInfo.cornerBR = corner;
   }
}
static void   fillRectWithLinearGradient( CGContext *context, // Converted from struct CGContext *context
                                          CGRect rect,
                                          CGColor color1,
                                          CGColor color2,
                                          struct CornerAndLinearGradientInfo *info)
{
   // MulleUICLog( "cornerTL: %g cornerBL: %g cornerBR: %g cornerTR: %g",
   //                info->cornerInfo.cornerTL,
   //                info->cornerInfo.cornerBL,
   //                info->cornerInfo.cornerBR,
   //                info->cornerInfo.cornerTR);

   CGContextBeginPath( context);
   CGContextRoundedRectVarying( context, rect, MulleCornerInsetsMake( info->cornerInfo.cornerTL, info->cornerInfo.cornerTR, info->cornerInfo.cornerBR, info->cornerInfo.cornerBL));

   CGContextFillLinearGradient( context,
                                info->gradientStartPoint, // Converted from x, y
                                color1,
                                info->gradientEndPoint,   // Converted from x, y
                                color2);
   CGContextFill( context);
}

// highlight is always top/down, 90 degree rotation makes no visual sense

static void   fillRectWithHighlight( CGContext *context, // Converted from struct CGContext *context
                                     CGRect rect,
                                     CGFloat thickness,
                                     CGFloat brightness,
                                     struct CornerAndLinearGradientInfo *info)
{
   CGContextBeginPath( context);
   CGContextRoundedRectVarying( context, rect, MulleCornerInsetsMake( info->cornerInfo.cornerTL, info->cornerInfo.cornerTR, info->cornerInfo.cornerBR, info->cornerInfo.cornerBL));

   // now subtract the next rect to get a highlight shape
   CGContextPathWinding( context, CGPathFillStyleHole);

   CGContextRoundedRectVarying( context, CGRectMake( rect.origin.x,
                              rect.origin.y + thickness,
                              rect.size.width,
                              rect.size.height - thickness),
                              MulleCornerInsetsMake( info->cornerInfo.cornerTL, info->cornerInfo.cornerTR, info->cornerInfo.cornerBR, info->cornerInfo.cornerBL));

//   CGContextGlobalCompositeOperation( context, CGCompositeOperationLighter);
   CGContextFillLinearGradient( context,
                                info->gradientStartPoint, // Converted from x, y
                                CGColorMakeWithRGBA( 1.0, 1.0, 1.0, brightness),
                                CGPointMake( info->gradientStartPoint.x, info->gradientStartPoint.y + info->cornerInfo.corner), // Converted from x, y
                                CGColorMakeTransparent());
   CGContextFill( context);
}

static void   fillRectWithLinearGradientBorder( CGContext *context, // Converted from struct CGContext *context
                                                CGRect rect,
                                                CGFloat strokeWidth,
                                                CGColor color1,
                                                CGColor color2,
                                                struct CornerAndLinearGradientInfo *info)
{
   CGContextBeginPath( context);
   rect = CGRectInset( rect, strokeWidth / 2.0, strokeWidth / 2.0);
   CGContextRoundedRectVarying( context, rect, MulleCornerInsetsMake( info->cornerInfo.cornerTL, info->cornerInfo.cornerTR, info->cornerInfo.cornerBR, info->cornerInfo.cornerBL));
   CGContextFillColor( context, color1);
   CGContextFill( context);

   CGContextStrokeWidth( context, strokeWidth);
   CGContextStrokeLinearGradient( context,
                                  info->gradientStartPoint, // Converted from x, y
                                  color1,
                                  info->gradientEndPoint,   // Converted from x, y
                                  color2,
                                  strokeWidth);
   CGContextStroke( context);
}

static void   strokeRectWithHairline( CGContext *context, // Converted from struct CGContext *context
                                      CGRect rect,
                                      CGFloat strokeWidth,
                                      CGColor color,
                                      struct CornerAndLinearGradientInfo *info)
{
   CGFloat    corner;

   CGContextBeginPath( context);

   CGContextRoundedRect( context, rect, info->cornerInfo.corner);

   CGContextGlobalCompositeOperation( context, CGCompositeOperationSourceOver);
   CGContextStrokeColor( context, color);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}

static void   drawEmote( CGContext *context, CGRect iconRect, int unicodeIcon, BOOL highlight)
{
   CGFont     *font;
   char       icon[ 8];
   char       *iconText;
   CGFloat    radius;
   CACircle   circle;

   // if too small, we don't draw anything
   radius = CGFloatMinimum( iconRect.size.width, iconRect.size.height) / 2.0;
   if( radius < 5.0 / 2.0)
      return;

   font = [context fontWithNameUTF8String:"icons"];

   if( highlight)
   {
      CGContextBeginPath( context);
      CGContextCircle( context, CACircleMake( CGRectGetMidX( iconRect),
                                              CGRectGetMidY( iconRect),
                                              radius));
      circle = CACircleMake( CGRectGetMidX( iconRect) - radius / 8.0,
                             CGRectGetMidY( iconRect) - radius / 8.0, // Converted from x, y
                             radius / 8.0);
      CGContextFillRadialGradient( context,
                                   circle,
                                   CGColorMakeWithRGBA( 1.0, 1.0, 1.0, 0.6),
                                   radius / 2.0,
                                   CGColorMakeWithRGBA( 0.2, 0.2, 0.2, 0.3));
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

struct MulleUIButtonSegment
{
   CGFloat           width;
   CGFloat           brightness;
   MulleEdgeInsets   insets;
   CGColor           color0;
   CGColor           color1;
   CGColor           color2;
   char              *labelUTF8String;
};
struct MulleUISegmentedButton
{
   CGRect                        frame;
   NSUInteger                    nSegments;
   CGFloat                       spacing;
   CGFloat                       cornerFactor;
   CGColor                       color0;
   CGColor                       color1;
   struct MulleUIButtonSegment   segments[];
};
static CADirection   MulleUISegmentedButtonDirectionForSegmentIndex( struct MulleUISegmentedButton *p,
                                                                     NSUInteger i)
{
   CADirection   direction = 0;

   if( i == 0)
      direction = CADirectionLeft;
   if( i == p->nSegments - 1)
      direction |= CADirectionRight;

   //MulleUICLog( "%td of %td -> %tx", i, p->nSegments, direction);
   return( direction);
}
struct MulleUISegmentedButtonLayout
{
   CGRect   outerRect;
   CGFloat  outerCornerRadius;

   CGRect   innerRect;
   CGFloat  innerCornerRadius;
   CGFloat  innerThickness;

   CGRect   contentRect;
   CGFloat  contentCornerRadius;
   CGFloat  contentThickness;
};
void MulleUISegmentedButtonLayoutInit( struct MulleUISegmentedButtonLayout *p,
                                       CGRect canvas)
{
   CGFloat    horw;

   p->outerRect           = canvas;
   p->outerCornerRadius   = CGSizeGetMinimum( p->outerRect.size) / 2.0;

   horw                   = CGSizeGetMinimum( p->outerRect.size);
   horw                   = CGFloatClamp( horw, 10.0f, 60.0f);

   p->innerThickness      = roundf( horw / 15.0);
   p->innerRect           = CGRectInset( p->outerRect, p->innerThickness, p->innerThickness);
   p->innerCornerRadius   = CGSizeGetMinimum( p->innerRect.size) / 2.0;

   horw                   = CGSizeGetMinimum( p->innerRect.size);
   horw                   = CGFloatClamp( horw, 10.0f, 60.0f);

   p->contentThickness    = roundf( horw / 30.0f);
   p->contentRect         = CGRectInset( p->innerRect, p->contentThickness, p->contentThickness);
   p->contentCornerRadius = CGSizeGetMinimum( p->contentRect.size) / 2.0;

}
static void   CGDrawSegmentedButton( CGContext *context, struct MulleUISegmentedButton *p)
{
   CGRect                               rect;
   NSInteger                            i;
   struct MulleUISegmentedButtonLayout  layout;
   struct CornerAndLinearGradientInfo   info;
   CADirection                          direction;

   mulle_alloca_do( rects, CGRect, p->nSegments)
   {

   //   CGContextSave( context);
      {
         /*
          * outer
          */
         MulleUISegmentedButtonLayoutInit( &layout, p->frame);

         CornerAndLinearGradientInfoInit( &info, layout.outerRect, p->cornerFactor, CADirectionLeft|CADirectionRight);

         fillRectWithLinearGradientBorder( context, // Updated function call
                                           layout.outerRect,
                                           layout.innerThickness,
                                           p->color0,
                                           p->color1,
                                           &info);

         CGRectPartitionIntoColumns( layout.innerRect, p->spacing, p->nSegments, rects);
         for( i = 0; i < p->nSegments; i++)
         {
            rect = MulleEdgeInsetsInsetRect( p->segments[ i].insets, rects[ i]);

            direction = MulleUISegmentedButtonDirectionForSegmentIndex( p, i);
            CornerAndLinearGradientInfoInit( &info, rect, p->cornerFactor, direction);
            fillRectWithLinearGradient( context, // Updated function call
                                        rect,
                                        p->segments[ i].color1,
                                        p->segments[ i].color0,
                                        &info);

            fillRectWithHighlight( context, // Updated function call
                                   rect,
                                   layout.innerThickness,
                                   p->segments[ i].brightness,
                                   &info);
         }

#if 0
         /*
          * inner
          */

         CGRectDivide( innerRect, &leftRect, &rightRect, innerRect.size.width / 2.0, CADirectionLeft);
         fillRectWithLinearGradient( context, leftRect, colors[ 1], colors[ 0], CADirectionLeft); // Updated function call
         fillRectWithLinearGradient( context, rightRect, colors[ 3], colors[ 2], CADirectionRight); // Updated function call

         contentRect = innerRect;

         /*
          * highlight
          */
         thickness = roundf( horw / 5.0);
         fillRectWithHighlight( context, leftRect, thickness, 0.3, CADirectionLeft); // Updated function call
         fillRectWithHighlight( context, rightRect, thickness, 0.6, CADirectionRight); // Updated function call

         if( innerRect.size.height >= 60.0 && innerRect.size.width >= 60.0)
         {
            lineRect = CGRectInset( innerRect, 12, 12);
            strokeRectWithHairline( context, lineRect, 1.5, colors[ 5]); // Updated function call
         }

         iconRect = CGRectInset( contentRect, 2, 2);

         CGRectDivide( iconRect, &leftRect, &rightRect, iconRect.size.width / 2.0, CADirectionLeft);
         drawEmote( context, leftRect, 0x2796, NO);  // -
         drawEmote( context, rightRect, 0x2795, NO); // +
         /*
          * line
          */
#endif
      }
   }
//   CGContextRestore( context);
}
static struct MulleUISegmentedButton  button =
{
   .frame        = { 0 },
   .nSegments    = 3,
   .cornerFactor = 0.25,
   .color0       = CGColorDataBlack,
   .color1       = CGColorDataGray,
   .spacing      = 2.0,
   .segments     =
   {
      {
         .width           = 100.0,
         .brightness      = 0.8,
         .color0          = CGColorDataBlack,
         .color1          = CGColorDataGray,
         .color2          = CGColorDataGreen,
         .labelUTF8String = "a"
      },
      {
         .width           = 100.0,
         .brightness      = 0.8,
         .color0          = CGColorDataBlack,
         .color1          = CGColorDataGray,
         .color2          = CGColorDataGreen,
         .labelUTF8String = "a"
      },
      {
         .width           = 100.0,
         .brightness      = 0.8,
         .color0          = CGColorDataBlack,
         .color1          = CGColorDataGray,
         .color2          = CGColorDataGreen,
         .labelUTF8String = "a"
      }
   }
};

static void   drawStuff1( CALayer *layer, CGContext *context)
{
   // MulleUICLog( "%#@ %#@", layer, context);

   button.frame = [layer canvas];
   CGDrawSegmentedButton( context, &button);
}
static struct MulleUISegmentedButton  pushed_button =
{
   .frame        = { 0 },
   .nSegments    = 3,
   .cornerFactor = 0.25,
   .spacing      = 2.0,
   .color0       = CGColorDataBlack,
   .color1       = CGColorDataGray,
   .segments     =
   {
      {
         .width           = 100.0,
         .brightness      = 0.8,
         .color0          = CGColorDataBlack,
         .color1          = CGColorDataGray,
         .color2          = CGColorDataGreen,
         .labelUTF8String = "a"
      },
      {
         .width           = 100.0,
         .brightness      = 0.2,
         .insets          = MulleEdgeInsetsData( 2.0f, 2.0f, 2.0f, 0.0f ),
         .color0          = CGColorDataWithHexColor( 0x101010ff),
         .color1          = CGColorDataWithHexColor( 0xa0a0a0ff),
         .color2          = CGColorDataGreen,
         .labelUTF8String = "a"
      },
      {
         .width           = 100.0,
         .brightness      = 0.8,
         .color0          = CGColorDataBlack,
         .color1          = CGColorDataGray,
         .color2          = CGColorDataGreen,
         .labelUTF8String = "a"
      }
   }
};

static void   drawStuff2( CALayer *layer, CGContext *context)
{
   // MulleUICLog( "%#@ %#@", layer, context);
   if( [context numberOfFrames] & 1)
   {
      button.frame = [layer canvas];
      CGDrawSegmentedButton( context, &button);
   }
   else
   {
      pushed_button.frame = [layer canvas];
      CGDrawSegmentedButton( context, &pushed_button);
   }
}

void   setupScene( UIWindow *window)
{
   UIView   *view;

   view  = [UIView viewWithFrame:CGRectMake( 20, 20, 300, 100)];
   [view setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff2];
   [[window contentView] addSubview:view];

   view  = [UIView viewWithFrame:CGRectMake( 340, 20, 300, 100)];
   [view setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff1];
   [[window contentView] addSubview:view];
}
int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
   NSUInteger      styleMask;

   app = [UIApplication sharedInstance];

   @autoreleasepool
   {
      styleMask = UIWindowStyleMaskDefault;
      styleMask = UIWindowStyleMaskBySetting( styleMask, UIWindowStyleResizable, YES);
      styleMask = UIWindowStyleMaskBySetting( styleMask, UIWindowStyleRetained, NO);

      window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 800, 600)
                         titleUTF8String:"Demo"
                               styleMask:styleMask];

      assert( window);
      [window setBackgroundColor:CGColorMakeWithRGBA( 0.3, 0.3, 0.3, 1.0)];
      setupScene( window);
      [window setFrameRate:2.0];
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
// █]     ,▄▐H  ██████═ª  ╓` ▄█▀▀▀▀█▄        ██p$ΦΦ▀▀▀▀▀ΦΦΦR≡≥▄╓ ║▄       ╙j▌` ▄▀╙╗ `╫
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

#define _GNU_SOURCE

#import "import-private.h"



// NSTableView
//    NSTableHeaderView
//       Is a subclass of NSSegmentedControl probably
//
//    NSTableCornerView
//       Doesn't exist anymore, place buttons or other stuff directly
//       unto UICollectionView (?) ..
//
//    UICollectionView
//          handles views to display
//
//    UICollectionViewTableLayout
//       Layout code that uses NSTableHeaderView info to steer UICollectionView
//


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
                                               CGDirection direction)
{
   CGFloat   corner;

   if( ! p)
      return;

   memset( p, 0, sizeof( *p));

   corner = CGRectGetCornerRadiusValue( rect, cornerFactor);

   p->cornerInfo.corner  = corner;
   p->gradientStartPoint = CGPointMake( CGRectGetMinX( rect),
                                        CGRectGetMinY( rect));
   p->gradientEndPoint   = CGPointMake( CGRectGetMinX( rect),
                                        CGRectGetMaxY( rect));

   if( direction & (CGDirectionLeft|CGDirectionRight))
   {
      if( direction & CGDirectionLeft)
         p->cornerInfo.cornerTL = p->cornerInfo.cornerBL = corner;
      if( direction & CGDirectionRight)
         p->cornerInfo.cornerBR = p->cornerInfo.cornerTR = corner;
   }

   if( direction & (CGDirectionTop|CGDirectionBottom))
   {
      if( direction & CGDirectionTop)
         p->cornerInfo.cornerTL = p->cornerInfo.cornerTR = corner;
      if( direction & CGDirectionBottom)
         p->cornerInfo.cornerBL = p->cornerInfo.cornerBR = corner;
   }
}


static void   fillRectWithLinearGradient( struct NVGcontext *vg,
                                          CGRect rect,
                                          CGColor color1,
                                          CGColor color2,
                                          struct CornerAndLinearGradientInfo *info)
{
   NVGpaint   paint;

   MulleUICLog( "cornerTL: %g cornerBL: %g cornerBR: %g cornerTR: %g",
                  info->cornerInfo.cornerTL,
                  info->cornerInfo.cornerBL,
                  info->cornerInfo.cornerBR,
                  info->cornerInfo.cornerTR);

   nvgBeginPath( vg);
   nvgRoundedRectVarying( vg, rect.origin.x,
                              rect.origin.y,
                              rect.size.width,
                              rect.size.height,
                              info->cornerInfo.cornerTL,
                              info->cornerInfo.cornerTR,
                              info->cornerInfo.cornerBR,
                              info->cornerInfo.cornerBL);

   paint = nvgLinearGradient( vg,
                              info->gradientStartPoint.x,
                              info->gradientStartPoint.y,
                              info->gradientEndPoint.x,   // sic!, we dont want change across x
                              info->gradientEndPoint.y,
                              color1,
                              color2);
   nvgFillPaint( vg, paint);
   nvgFill( vg);
}



// highlight is always top/down, 90 degree rotation makes no visual sense

static void   fillRectWithHighlight( struct NVGcontext *vg,
                                     CGRect rect,
                                     CGFloat thickness,
                                     CGFloat brightness,
                                     struct CornerAndLinearGradientInfo *info)
{
   NVGpaint   paint;

   nvgBeginPath( vg);
   nvgRoundedRectVarying( vg, rect.origin.x,
                              rect.origin.y,
                              rect.size.width,
                              rect.size.height,
                              info->cornerInfo.cornerTL,
                              info->cornerInfo.cornerTR,
                              info->cornerInfo.cornerBR,
                              info->cornerInfo.cornerBL);

   // now subtract the next rect to get a highlight shape
   nvgPathWinding(vg, NVG_HOLE); // sets nvgRoundedRect as a hole

   nvgRoundedRectVarying( vg, rect.origin.x,
                              rect.origin.y + thickness,
                              rect.size.width,
                              rect.size.height - thickness,
                              info->cornerInfo.cornerTL,
                              info->cornerInfo.cornerTR,
                              info->cornerInfo.cornerBR,
                              info->cornerInfo.cornerBL);

   paint = nvgLinearGradient( vg,
                              info->gradientStartPoint.x,
                              info->gradientStartPoint.y,
                              info->gradientStartPoint.x,   // sic
                              info->gradientStartPoint.y + info->cornerInfo.corner,
                              CGColorMakeWithRGBA( 1.0, 1.0, 1.0, brightness),
                              CGColorMakeTransparent());
//   nvgGlobalCompositeOperation( vg, NVG_LIGHTER);
   nvgFillPaint( vg, paint);
   nvgFill( vg);
}



static void   fillRectWithLinearGradientBorder( struct NVGcontext *vg,
                                                CGRect rect,
                                                CGFloat strokeWidth,
                                                CGColor color1,
                                                CGColor color2,
                                                CGColor color3,
                                                struct CornerAndLinearGradientInfo *info)
{
   NVGpaint   paint;

   nvgBeginPath( vg);
   rect = CGRectInset( rect, strokeWidth / 2.0, strokeWidth / 2.0);
   nvgRoundedRectVarying( vg, rect.origin.x,
                              rect.origin.y,
                              rect.size.width,
                              rect.size.height,
                              info->cornerInfo.cornerTL,
                              info->cornerInfo.cornerTR,
                              info->cornerInfo.cornerBR,
                              info->cornerInfo.cornerBL);
   nvgFillColor( vg, color3);
   nvgFill( vg);

   paint = nvgLinearGradient( vg,
                              info->gradientStartPoint.x,
                              info->gradientStartPoint.y,
                              info->gradientEndPoint.x,   // sic
                              info->gradientEndPoint.y,
                              color1,
                              color2);
   nvgStrokeWidth( vg, strokeWidth);
   nvgStrokePaint( vg, paint);
   nvgStroke( vg);
}



static void   CGDrawTableView( CGContext *context, CGRect rect)
{
   struct CornerAndLinearGradientInfo   info;
   NVGcontext                           *vg;
   NSUInteger                           nRows;
   NSUInteger                           nColumns;
   NSUInteger                           row;
   NSUInteger                           column;
   NSUInteger                           selectedColumn;
   NSUInteger                           selectedRow;
   CGRect                               contentRect;
   CGRect                               cellRect;
   NVGpaint                             paint;

   vg = CGContextGetNVGContext( context);

   CornerAndLinearGradientInfoInit( &info, rect, 0.01, CGDirectionLeft|CGDirectionRight);

   fillRectWithLinearGradientBorder( vg,
                                     rect,
                                     2.0f,
                                     CGColorMakeWithHexColor( 0x303030FF),
                                     CGColorMakeWithHexColor( 0x808080FF),
                                     CGColorMakeWithHexColor( 0x404040FF),
                                     &info);

   contentRect = CGRectInset( rect, 2.0, 2.0);

   nRows           = 10;
   nColumns        = 5;
   cellRect.size.width  = contentRect.size.width / nColumns;
   cellRect.size.height = contentRect.size.height / nRows;

   selectedColumn = 1;
   selectedRow    = NSUIntegerMax;

   nvgBeginPath( vg);
   for( row = 0; row < nRows; row++)
   {
      cellRect.origin.y = contentRect.origin.y + row * cellRect.size.height;

      for( column = 0; column < nColumns; column++)
      {
         cellRect.origin.x = contentRect.origin.x + column * cellRect.size.width;

         nvgRoundedRect( vg, cellRect.origin.x, 
                             cellRect.origin.y, 
                             cellRect.size.width,
                             cellRect.size.height,
                             3.0);

      }
   }

   paint = nvgLinearGradient( vg,
                              info.gradientStartPoint.x,
                              info.gradientStartPoint.y,
                              info.gradientEndPoint.x,   // sic
                              info.gradientEndPoint.y,
                              CGColorMakeWithHexColor( 0x101010FF),
                              CGColorMakeWithHexColor( 0x202020FF));
   nvgStrokeWidth( vg, 2.0);
   nvgStrokePaint( vg, paint);
   nvgStroke( vg);   

   //
   // draw selected cells background
   //
   nvgBeginPath( vg);
   for( row = 0; row < nRows; row++)
   {
      if( selectedRow == NSUIntegerMax || selectedRow == row)
      {
         cellRect.origin.y = contentRect.origin.y + row * cellRect.size.height;

         for( column = 0; column < nColumns; column++)
         {
            if( selectedColumn == NSUIntegerMax || selectedColumn == column)
            {
               cellRect.origin.x = contentRect.origin.x + column * cellRect.size.width;

               nvgRoundedRect( vg, cellRect.origin.x, 
                                   cellRect.origin.y, 
                                   cellRect.size.width,
                                   cellRect.size.height,
                                   3.0);
            }
         }
      }
   }

   nvgStrokeWidth( vg, 1.5);
   nvgStrokeColor( vg, CGColorMakeWhite());
   nvgStroke( vg);   
}



static void   drawTableViewContents( CALayer *layer, CGContext *context)
{
   CGDrawTableView( context, [layer canvas]);
}


////////
//////// SEGMENTED BUTTON
////////

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


static CGDirection   MulleUISegmentedButtonDirectionForSegmentIndex( struct MulleUISegmentedButton *p,
                                                                     NSUInteger i)
{
   CGDirection   direction = 0;

   if( i == 0)
      direction = CGDirectionLeft;
   if( i == p->nSegments - 1)
      direction |= CGDirectionRight;

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
   horw                   = CGFloatClampToMinMax( horw, 10.0f, 60.0f);

   p->innerThickness      = roundf( horw / 15.0);
   p->innerRect           = CGRectInset( p->outerRect, p->innerThickness, p->innerThickness);
   p->innerCornerRadius   = CGSizeGetMinimum( p->innerRect.size) / 2.0;

   horw                   = CGSizeGetMinimum( p->innerRect.size);
   horw                   = CGFloatClampToMinMax( horw, 10.0f, 60.0f);

   p->contentThickness    = roundf( horw / 30.0f);
   p->contentRect         = CGRectInset( p->innerRect, p->contentThickness, p->contentThickness);
   p->contentCornerRadius = CGSizeGetMinimum( p->contentRect.size) / 2.0;

}


static void   CGDrawSegmentedButton( CGContext *context, struct MulleUISegmentedButton *p)
{
   NVGpaint                             paint;
   CGRect                               rect;
   NSInteger                            i;
   struct MulleUISegmentedButtonLayout  layout;
   struct CornerAndLinearGradientInfo   info;
   CGDirection                          direction;
   NVGcontext                           *vg;
   mulle_flexarray_define( rects, CGRect, 16, p->nSegments);

   vg = CGContextGetNVGContext( context);

//   nvgSave( vg);
   {
      /*
       * outer
       */
      MulleUISegmentedButtonLayoutInit( &layout, p->frame);

      CornerAndLinearGradientInfoInit( &info, layout.outerRect, p->cornerFactor, CGDirectionLeft|CGDirectionRight);

      fillRectWithLinearGradientBorder( vg,
                                        layout.outerRect,
                                        layout.innerThickness,
                                        p->color0,
                                        p->color1,
                                        p->color1,
                                        &info);

      CGRectPartitionIntoColumns( layout.innerRect, p->spacing, p->nSegments, rects);
      for( i = 0; i < p->nSegments; i++)
      {
         rect = MulleEdgeInsetsInsetRect( p->segments[ i].insets, rects[ i]);

         direction = MulleUISegmentedButtonDirectionForSegmentIndex( p, i);
         CornerAndLinearGradientInfoInit( &info, rect, p->cornerFactor, direction);
         fillRectWithLinearGradient( vg,
                                     rect,
                                     p->segments[ i].color1,
                                     p->segments[ i].color0,
                                     &info);

         fillRectWithHighlight( vg,
                                rect,
                                layout.innerThickness,
                                p->segments[ i].brightness,
                                &info);
      }

#if 0
      /*
       * inner
       */

      CGRectDivide( innerRect, &leftRect, &rightRect, innerRect.size.width / 2.0, CGDirectionLeft);
      fillRectWithLinearGradient( vg, leftRect, colors[ 1], colors[ 0], CGDirectionLeft);
      fillRectWithLinearGradient( vg, rightRect, colors[ 3], colors[ 2], CGDirectionRight);

      contentRect = innerRect;

      /*
       * highlight
       */
      thickness = roundf( horw / 5.0);
      fillRectWithHighlight( vg, leftRect, thickness, 0.3, CGDirectionLeft);
      fillRectWithHighlight( vg, rightRect, thickness, 0.6, CGDirectionRight);

      if( innerRect.size.height >= 60.0 && innerRect.size.width >= 60.0)
      {
         lineRect = CGRectInset( innerRect, 12, 12);
         strokeRectWithHairline( vg, lineRect, 1.5, colors[ 5]);
      }

      iconRect = CGRectInset( contentRect, 2, 2);

      CGRectDivide( iconRect, &leftRect, &rightRect, iconRect.size.width / 2.0, CGDirectionLeft);
      drawEmote( context, leftRect, 0x2796, NO);  // -
      drawEmote( context, rightRect, 0x2795, NO); // +
      /*
       * line
       */
#endif
   }
//   nvgRestore( vg);
}



static struct MulleUISegmentedButton  button =
{
   .frame        = { 0 },
   .nSegments    = 5,
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



static void   drawTableHeader( CALayer *layer, CGContext *context)
{
   button.frame = [layer canvas];
   CGDrawSegmentedButton( context, &button);
}


///////
///////
///////



static void   drawIcon( CGContext *context, 
                        CGRect iconRect, 
                        MulleEdgeInsets iconInsets,
                        int unicodeIcon, 
                        BOOL highlight)
{
   CGFont              *font;
   struct NVGpaint     paint;
   struct NVGcontext   *vg;
   char                icon[ 8];
   char                *iconText;
   CGFloat             radius;

   // if too small, we don't draw anything
   radius = CGFloatMinimum( iconRect.size.width, iconRect.size.height) / 2.0;
   if( radius < 5.0 / 2.0)
      return;

   vg = CGContextGetNVGContext( context);

   if( highlight)
   {
      nvgBeginPath( vg);
      nvgCircle( vg, CGRectGetMidX( iconRect), CGRectGetMidY( iconRect), radius);
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
                                 CGRectGetMidX( iconRect) - radius / 8.0,
                                 CGRectGetMidY( iconRect) - radius / 8.0,
                                 radius / 8.0,
                                 radius / 2.0,
                                 CGColorMakeWithRGBA( 1.0, 1.0, 1.0, 0.6),
                                 CGColorMakeWithRGBA( 0.2, 0.2, 0.2, 0.3)),
#endif
      nvgFillPaint( vg, paint);
      nvgFill( vg);
   }
//   nvgStrokeColor( vg, CGColorMakeWithRGBA( 0.8, 0.8, 0.8, 0.8));
//   nvgStroke( vg);


   iconRect.origin = CGPointMake( CGRectGetMidX( iconRect) - radius,
                                  CGRectGetMidY( iconRect) - radius);
   iconRect.size   = CGSizeMake( radius * 2.0, radius * 2.0f);

   iconRect        = MulleEdgeInsetsInsetRect( iconInsets, iconRect);

   font = [context fontWithNameUTF8String:"icons"];
   nvgFontFace( vg, "icons");

   iconText = cpToUTF8( unicodeIcon, icon);

   // will get scaled up anyway ?
   nvgFontSize( vg, iconRect.size.height);
   nvgGlobalCompositeOperation( vg, NVG_LIGHTER);
   nvgGlobalAlpha( vg, 0.8);
   nvgTextColor( vg, CGColorMakeWhite(), CGColorMakeBlack());
   mvgTextInRect( vg, iconText,
                      NULL,
                      iconRect,
                      CGContentModeScaleAspectFit,
                      MVGTextAlignVisually);
}



static void   drawCornerView( CALayer *layer, CGContext *context)
{
   struct CornerAndLinearGradientInfo   info;
   NVGcontext                           *vg;
   CGRect                               rect;

   rect = [layer canvas];

   vg = CGContextGetNVGContext( context);

   CornerAndLinearGradientInfoInit( &info, rect, 0.2, 0);

   fillRectWithLinearGradientBorder( vg,
                                     rect,
                                     2.0f,
                                     CGColorMakeWithHexColor( 0xA0A0A07F),
                                     CGColorMakeWithHexColor( 0x8080807F),
                                     CGColorMakeWithHexColor( 0x4040407F),
                                     &info);

   drawIcon( context, CGRectInset( rect, 2.0, 2.0), MulleEdgeInsetsMakeTLBR( 4, 2, 4, 2), 0xe74f, YES);
}


void   setupScene( UIWindow *window)
{
   UIView   *view;
   UIView   *cornerView;
   CGRect   frame;
   CGRect   headerFrame;
   CGRect   contentFrame;
   CGRect   cornerFrame;

   frame = CGRectInset( [window contentRect], 20, 20);
   CGRectDivide( frame, &headerFrame, &contentFrame, 30, CGDirectionTop);

   view  = [UIView viewWithFrame:headerFrame];
   [view setDrawCallback:drawTableHeader];
   [[window contentPlane] addSubview:view];

   view  = [UIView viewWithFrame:contentFrame];
   [view setDrawCallback:drawTableViewContents];
   [[window contentPlane] addSubview:view];

   cornerFrame = CGSizePlaceInRect( CGSizeMake( 44, 44), contentFrame, CGContentModeBottomRight);
   cornerFrame = [window convertRect:cornerFrame
                              toView:view];

   cornerView  = [UIView viewWithFrame:cornerFrame];
   [cornerView setDrawCallback:drawCornerView];
   [view addSubview:cornerView];
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
      styleMask = UIWindowsStyleMaskBySetting( styleMask, UIWindowStyleResizable, YES);
      styleMask = UIWindowsStyleMaskBySetting( styleMask, UIWindowStyleRetained, NO);

      window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 800, 600)
                         titleUTF8String:"Demo"
                               styleMask:styleMask];

      assert( window);
      [window setBackgroundColor:CGColorMakeWithRGBA( 0.3, 0.3, 0.3, 1.0)];
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


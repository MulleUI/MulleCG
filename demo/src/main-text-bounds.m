#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>


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


static char  *nvgHAlignmentUTF8String( int alignment)
{
   switch( alignment & (NVG_ALIGN_LEFT | NVG_ALIGN_CENTER | NVG_ALIGN_RIGHT))
   {
   case NVG_ALIGN_LEFT   : return( "NVG_ALIGN_LEFT");
   case NVG_ALIGN_CENTER : return( "NVG_ALIGN_CENTER");
   case NVG_ALIGN_RIGHT  : return( "NVG_ALIGN_RIGHT");
   default               : return( "*invalid*");
   }
}


static char  *nvgVAlignmentUTF8String( int alignment)
{
   switch( alignment & (NVG_ALIGN_TOP | NVG_ALIGN_MIDDLE | NVG_ALIGN_BOTTOM | NVG_ALIGN_BASELINE))
   {
   case NVG_ALIGN_TOP      : return( "NVG_ALIGN_TOP");
   case NVG_ALIGN_MIDDLE   : return( "NVG_ALIGN_MIDDLE");
   case NVG_ALIGN_BOTTOM   : return( "NVG_ALIGN_BOTTOM");
   case NVG_ALIGN_BASELINE : return( "NVG_ALIGN_BASELINE");
   default                 : return( "*invalid*");
   }
}

#define N_ALIGNMENTS  (sizeof( alignments) / sizeof( alignments[ 0]))


static void   nvgStrokeGlyphPosition( NVGcontext *vg, NVGglyphPosition *position, CGColor color)
{
   nvgBeginPath( vg);
   nvgRect( vg, position->minx,
                position->miny,
                position->maxx - position->minx,
                position->maxy - position->miny);
   nvgStrokeColor( vg, color);
   nvgStrokeWidth( vg, 1.0);
   nvgStroke( vg);
}


static void   strokeLineH( NVGcontext *vg, float x1, float x2, float y, CGColor color)
{
   nvgBeginPath(vg);
   nvgMoveTo( vg, x1, y);
   nvgLineTo( vg, x2, y);
   nvgStrokeColor( vg, color);
   nvgStrokeWidth( vg, 1.0);
   nvgStroke( vg);
}


static void   strokeLineV( NVGcontext *vg, float x, float y1, float y2, CGColor color)
{
   nvgBeginPath(vg);
   nvgMoveTo( vg, x, y1);
   nvgLineTo( vg, x, y2);
   nvgStrokeColor( vg, color);
   nvgStrokeWidth( vg, 1.0);
   nvgStroke( vg);
}


static void   strokeBounds( NVGcontext *vg, float bounds[ 4], CGColor color)
{
   nvgBeginPath(vg);
   nvgRect( vg, bounds[0], bounds[1], bounds[2] - bounds[0], bounds[3] - bounds[1]);
   nvgStrokeColor( vg, color);
   nvgStrokeWidth( vg, 1.0);
   nvgStroke( vg);
}


static void  strokeBoundsInRect( NVGcontext *vg, float bounds[ 4], CGRect rect, CGColor color)
{
   CGPoint   point;

   point = CGPointMirrorInRectH( CGPointMake( bounds[ 0], 0), rect);
   strokeLineV( vg, bounds[ 0], CGRectGetMinY( rect), CGRectGetMidY( rect), color);
   strokeLineV( vg, point.x, CGRectGetMidY( rect), CGRectGetMaxY( rect), color);
   strokeLineV( vg, bounds[ 2], CGRectGetMinY( rect), CGRectGetMidY( rect), color);

//   point = CGPointMirrorInRectH( CGPointMake( bounds[ 2], 0), rect);
//   strokeLineV( vg, bounds[ 2], CGRectGetMinY( rect), CGRectGetMidY( rect), color);
//   strokeLineV( vg, point.x, CGRectGetMidY( rect), CGRectGetMaxY( rect), color);

//   strokeLineH( vg, CGRectGetMinX( rect), CGRectGetMidX( rect), bounds[ 1], color);
//   strokeLineH( vg, CGRectGetMinX( rect), CGRectGetMidX( rect), bounds[ 3], color);
}

static void  strokeBoundsInRect2( NVGcontext *vg, float bounds[ 4], CGRect rect, CGColor color)
{
   CGPoint   point;

   point = CGPointMirrorInRectH( CGPointMake( bounds[ 0], 0), rect);
   strokeLineV( vg, bounds[ 0], CGRectGetMidY( rect), CGRectGetMaxY( rect), color);
   strokeLineV( vg, point.x, CGRectGetMinY( rect), CGRectGetMidY( rect), color);
   strokeLineV( vg, bounds[ 2], CGRectGetMidY( rect), CGRectGetMaxY( rect), color);

//   point = CGPointMirrorInRectH( CGPointMake( bounds[ 2], 0), rect);
//   strokeLineV( vg, bounds[ 2], CGRectGetMinY( rect), CGRectGetMidY( rect), color);
//   strokeLineV( vg, point.x, CGRectGetMidY( rect), CGRectGetMaxY( rect), color);

//   strokeLineH( vg, CGRectGetMinX( rect), CGRectGetMidX( rect), bounds[ 1], color);
//   strokeLineH( vg, CGRectGetMinX( rect), CGRectGetMidX( rect), bounds[ 3], color);
}



NSUInteger   alignments[] =
{
   NVG_ALIGN_LEFT   | NVG_ALIGN_TOP,
   NVG_ALIGN_CENTER | NVG_ALIGN_TOP,
   NVG_ALIGN_RIGHT  | NVG_ALIGN_TOP,

   NVG_ALIGN_LEFT   | NVG_ALIGN_MIDDLE,
   NVG_ALIGN_CENTER | NVG_ALIGN_MIDDLE,
   NVG_ALIGN_RIGHT  | NVG_ALIGN_MIDDLE,

   NVG_ALIGN_LEFT   | NVG_ALIGN_BOTTOM,
   NVG_ALIGN_CENTER | NVG_ALIGN_BOTTOM,
   NVG_ALIGN_RIGHT  | NVG_ALIGN_BOTTOM,

   NVG_ALIGN_LEFT   | NVG_ALIGN_BASELINE,
   NVG_ALIGN_CENTER | NVG_ALIGN_BASELINE,
   NVG_ALIGN_RIGHT  | NVG_ALIGN_BASELINE
};
#define N_ALIGNMENTS  (sizeof( alignments) / sizeof( alignments[ 0]))


static CGPoint   originOfRectForAlignment( CGRect  rect, int alignment)
{
   CGPoint  origin;

   switch( alignment & (NVG_ALIGN_LEFT | NVG_ALIGN_CENTER | NVG_ALIGN_RIGHT))
   {
   default               : origin.x = CGRectGetMinX( rect); break;
   case NVG_ALIGN_CENTER : origin.x = CGRectGetMidX( rect); break;
   case NVG_ALIGN_RIGHT  : origin.x = CGRectGetMaxX( rect); break;
   }

   // not sure what to do with baseline
   switch( alignment & (NVG_ALIGN_TOP | NVG_ALIGN_MIDDLE | NVG_ALIGN_BOTTOM | NVG_ALIGN_BASELINE))
   {
   case NVG_ALIGN_TOP    : origin.y = CGRectGetMinY( rect); break;
   case NVG_ALIGN_MIDDLE : origin.y = CGRectGetMidY( rect); break;
   default               : origin.y = CGRectGetMaxY( rect); break;
   }

   return( origin);
}

static CGPoint  visualOffsetToTextBounds( float visualBounds[ 4], int alignment, float textBounds[ 4])
{
   float   xOffset;
   float   yOffset;
   float   textBoundsMidY;
   float   visualBoundsMidY;
   float   textBoundsMidX;
   float   visualBoundsMidX;

   xOffset = 0.0;
   switch( alignment & (NVG_ALIGN_LEFT | NVG_ALIGN_CENTER | NVG_ALIGN_RIGHT))
   {
   case NVG_ALIGN_LEFT    :
      xOffset = -(textBounds[ 0] - visualBounds[ 0]);
      break;

   case NVG_ALIGN_CENTER :
      textBoundsMidX   = textBounds[ 0] + (textBounds[ 2] - textBounds[ 0]) / 2.0;
      visualBoundsMidX = visualBounds[ 0] + (visualBounds[ 2] - visualBounds[ 0]) / 2.0;
      xOffset          = -(textBoundsMidX - visualBoundsMidX);
      break;

   case NVG_ALIGN_RIGHT :
      xOffset = (textBounds[ 2] - visualBounds[ 2]);
      break;
   }

   yOffset = 0.0;
   switch( alignment & (NVG_ALIGN_TOP | NVG_ALIGN_MIDDLE | NVG_ALIGN_BOTTOM | NVG_ALIGN_BASELINE))
   {
   case NVG_ALIGN_TOP    :
      yOffset = -(textBounds[ 1] - visualBounds[ 1]);
      break;

   case NVG_ALIGN_MIDDLE :
      textBoundsMidY   = textBounds[ 1] + (textBounds[ 3] - textBounds[ 1]) / 2.0;
      visualBoundsMidY = visualBounds[ 1] + (visualBounds[ 3] - visualBounds[ 1]) / 2.0;
      yOffset          = (textBoundsMidY - visualBoundsMidY);
      break;

   case NVG_ALIGN_BOTTOM :
      yOffset = (textBounds[ 3] - visualBounds[ 3]);
      break;

   case NVG_ALIGN_BASELINE :
      // keep as is
      break;
   }

   return( CGPointMake( xOffset, yOffset));
}


static void   drawStuff( CALayer *layer, CGContext *context)
{
   struct NVGcontext    *vg;
   CGFont               *font;
   CGRect               canvas;
   CGRect               rects[ 4];
   NSUInteger           x, y;
   CGRect               rect;
   CGRect               centeredRect;
   CGPoint              point;
   char                 *s;
   float                ascender, descender, lineh;
   char                 buf[ 256];
   float                textBounds[ 4];
   float                visualBounds[ 4];
   float                glyphBounds[ 4];
   float                bounds[ 4];
   CGPoint              origin;
   NVGglyphPosition     positions[ 32];
   int                  i;
   int                  nGlyphs;
   CGPoint              offset;

   int                  alignment;
   NSUInteger           frameNr;

   frameNr   = [context numberOfRenderedFrames];
   alignment = alignments[ frameNr % N_ALIGNMENTS];

   vg     = CGContextGetNVGContext( context);
   font   = [context fontWithNameUTF8String:"sans"];

   canvas = [layer canvas];
   canvas = CGRectInset( canvas, 20, 20);

   CGRectPartitionVertically( canvas, 20, 4, rects);

   for( y = 0; y < 4; y++)
   {
      switch( y)
      {
      case 0 : s = "VfL Bochum 1848"; break;
      case 1 : s = "Ascend _y_ Descend"; break;
      case 2 : s = "  Space around  "; break;
      case 3 : s = "nox suarv zemnx"; break;
      }

      rect = rects[ y];
      nvgSave( vg);
      {
         origin = originOfRectForAlignment( rect, alignment);

         nvgFontSize( vg, 80.0);
         nvgTextAlign( vg, alignment);
         nvgTextBounds( vg, origin.x, origin.y, s, NULL, textBounds);
         nvgTextVisualBounds(vg, origin.x, origin.y, s, NULL, visualBounds);

         drawStrokedRect( vg, rect, CGColorMakeGray());

//         nvgTextColor( vg, CGColorMakeRGB( 0.5, 0.5, 0.5), CGColorMakeWhite()); // TODO: use textColor
//         nvgText( vg, origin.x, origin.y, s, NULL);

         strokeLineH( vg, CGRectGetMinX( rect), CGRectGetMaxX( rect), CGRectGetMidY( rect), CGColorMakeGray());
         strokeLineV( vg, CGRectGetMidX( rect), CGRectGetMinY( rect), CGRectGetMaxY( rect), CGColorMakeGray());

         strokeBoundsInRect( vg, textBounds, rect, CGColorMakeRGBA( 1, 0, 0, 0.666));


         offset  = visualOffsetToTextBounds( visualBounds, alignment, textBounds);
         nGlyphs = nvgTextGlyphPositions( vg, origin.x, origin.y, s, NULL, positions, 32);

         nvgSave( vg);
         {
            nvgTranslate( vg, offset.x, offset.y);
//            strokeBounds( vg, textBounds,    CGColorMakeRGBA( 1, 0, 0, 0.666));
//            strokeBounds( vg, minimalBounds, CGColorMakeRGBA( 0, 1, 0, 0.666));

            strokeBounds( vg, visualBounds, CGColorMakeGreen());

            nvgFontSize( vg, 80.0);
            nvgTextAlign( vg, alignment);
            nvgTextColor( vg, CGColorMakeBlack(), CGColorMakeWhite()); // TODO: use textColor
            nvgText( vg, origin.x, origin.y, s, NULL);

            for( i = 0; i < nGlyphs; i++)
               nvgStrokeGlyphPosition( vg, &positions[ i], CGColorMakeGray());
         }
         nvgRestore( vg);

         // write info line
         nvgFontSize( vg, 12);
         nvgTextAlign( vg, NVG_ALIGN_LEFT|NVG_ALIGN_BOTTOM);
         sprintf( buf, "offset: %s align: %s | %s",
                     CGPointUTF8String( offset),
                     nvgHAlignmentUTF8String( alignment),
                     nvgVAlignmentUTF8String( alignment));
         nvgTextColor( vg, CGColorMakeBlack(), CGColorMakeWhite()); // TODO: use textColor
         nvgText( vg, CGRectGetMinX( rect) + 2, CGRectGetMaxY( rect) - 2, buf, NULL);
      }
      nvgRestore( vg);
   }
}


void   setupScene( UIWindow *window)
{
   UIView        *view;
   CGRect         frame;

   frame  = [[window contentPlane] contentRect];

   view  = [UIView viewWithFrame:frame];
   [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
   [view setDrawCallback:drawStuff];
   [[window contentPlane] addSubview:view];
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

      window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 1000, 600)
                         titleUTF8String:"Demo"
                               styleMask:styleMask];

      assert( window);
      [window setBackgroundColor:CGColorMakeRGBA( 1.0, 1.0, 1.0, 1.0)];
      setupScene( window);
      [window setFrameRate:2.0];

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


#define _GNU_SOURCE

#import "import-private.h"


#define MIN_HEIGHT   5
#define MAX_HEIGHT   100
#define LOOP         1
#define TEXT         "Der VfL Bochum hat den zweiten Sieg in Folge gefeiert."

#define TEXT_COLOR   CGColorMakeBlack()

static char   *fontFilename;

static BOOL   drawStuff( CALayer *layer, CGContext *context)
{
   BOOL                 useClearType;
   CGFloat              height;
   CGFont               *font;
   CGPoint              point;
   CGRect               canvas;
   CGRect               rect;
   float                factor;
   int                  atlas_h;
   int                  atlas_w;
   int                  i;
   struct MulleLayout   layout;
   struct NVGcontext    *vg;
   void                 *fonsContext;
   char                 *fontName;

   if( fontFilename)
   {
      fontName = "custom";
      font     = [context fontWithContentsOfFileWithFileRepresentationString:fontFilename
                                                          fontNameUTF8String:fontName];
   }
   else 
   {
      fontName = "sans";
      font     = [context fontWithNameUTF8String:fontName];
   }

   if( ! font)
   {
      MulleUICLog( "Could not load font \"%s\"", fontName);
      abort();;
   }
   [context useFont:font];
   canvas = [layer canvas];

   MulleLayoutInit( &layout, CGRectInset( canvas, 30, 30), MulleEdgeInsetsZero);

   vg = CGContextGetNVGContext( context);

   mvgFillRectWithColor( vg, canvas, CGColorInvertRGB( TEXT_COLOR));

   factor       = CGContextGetLinearAnimationFactor( context, 15.0f);
   useClearType = factor >= 0.5f;
   nvgClearType( vg, useClearType);

   nvgTextAlign( vg, NVG_ALIGN_LEFT | NVG_ALIGN_BASELINE);
   nvgTextColor( vg, TEXT_COLOR);

   for( height = MIN_HEIGHT;; height = height >= MAX_HEIGHT ? MAX_HEIGHT : height + 1)
   {
      if( LOOP)
      {
         rect = MulleLayoutAddRowWithHeight( &layout, height, MulleEdgeInsetsMakeHV( 0, 0, 2, 0));
         if( rect.size.height == 0.0)
            break;
      }
      else
      {
         rect.origin.x = CGRectGetMinX( canvas);
         rect.origin.y = CGRectGetMidY( canvas) - height / 2.0;
      }
#if 0
      nvgStrokeColor( vg, nvgRGBA( 0x80, 0, 0, 0xFF));
      nvgStrokeWidth( vg, 0.5);
      nvgBeginPath( vg);
      nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
      nvgStroke( vg);
#endif

      nvgFontSize( vg, height);
      nvgText( vg, rect.origin.x, rect.origin.y, TEXT, NULL);

      if( ! LOOP)
         break;
   }

   [context useDefaultFont];
   nvgClearType( vg, 0);
   nvgFontFace( vg, "sans");
   nvgFontSize( vg, 13.0f);   if( useClearType)
      nvgTextColor( vg, CGColorMakeRandomOpaque());
   else
      nvgTextColor( vg, CGColorMakeDarkGray());
   nvgText( vg, CGRectGetMinX( canvas) + 15.0,
                CGRectGetMaxY( canvas) - 15.0,
                useClearType ? "ClearType" : "Default",
                NULL);

   return( YES);
}



int   main( int argc, char *argv[])
{
   if( argc > 1)
      fontFilename = argv[ 1];
   return( UIApplicationRunDrawCallbackHz( (CALayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 640, 400),
                                           NULL,
                                           5.0f));
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


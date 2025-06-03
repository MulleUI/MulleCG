//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#define _GNU_SOURCE

#import "import-private.h"

static char   default_text[] = "Der VfL Bochum spielte erstmals im März 1976\n"
"mit einem Werbeaufdruck auf dem vereinseigenen Trikot.\n"
"\n"
"Zunächst befand sich ein stilisierter Osborne-Stier, das Zeichen\n"
"des Spirituosenherstellers Osborne, auf den Bochumer Trikots.\n"
"Darstellung und Größe dieser Werbung verstießen gegen die damals\n"
"strengen DFB-Regularien, weshalb ab 1977 nur noch mit dem Schriftzug\n"
"„Osborne“ geworben werden durfte.";

static char   *text = default_text;
static BOOL   debug = YES;
static BOOL   cleartype = YES;
static BOOL   dump_glyphs = NO;

struct Info
{
   CGRect                 bounds;
   CGRect                 area;
   struct CGTextMetrics   metrics;
   struct CGTextMetrics   visualMetrics;
   CGFloat                compensation;
   BOOL                   isClearType;
   CGFloat                fontSize;
   NSUInteger             verticalAlignment;
};


static char  *NVG_ALIGN_UTF8String( NSUInteger valign)
{
   switch( valign)
   {
   case CGTextAlignBaseline : return( "CGTextAlignBaseline"); // Converted from NVG_ALIGN_BASELINE
   case CGTextAlignTop      : return( "CGTextAlignTop"); // Converted from NVG_ALIGN_TOP
   case CGTextAlignMiddle   : return( "CGTextAlignMiddle"); // Converted from NVG_ALIGN_MIDDLE
   case CGTextAlignBottom   : return( "CGTextAlignBottom"); // Converted from NVG_ALIGN_BOTTOM
   }
   return( "???");
}


static void   drawDebugInfo( struct Info *info, CGRect canvas, CGContext *context)
{
   CGTextMetrics   metrics;
   CGRect          adjustedBounds;
   CGPaint         *paint;

   CGContextSave( context);
   {
#if 0
      // adjustedBounds are just there for debugging
      adjustedBounds = CGRectOffset( info->bounds, info->area.origin.x, info->area.origin.y);
      paint          = [CGGradient gradientWithStartColor:CGColorMultiplyAlpha( CGColorMakePapaya(), 0.5)
                                                 endColor:CGColorMultiplyAlpha( CGColorMakeRed(), 0.5)
                                                 rotation:0.1625];
      CGContextStrokeRectWithPaintable( context, adjustedBounds, 1.0, paint);
#endif

      CGContextFontSize( context, 11.0);
      CGContextClearType( context, 0);
      CGContextTextColor( context, CGColorMakeBlack());
      CGContextTextBackgroundColor( context, CGColorMakeOrange());

      metrics = [context textMetrics];

      mulle_buffer_do( buf)
      {

         // top info
         mulle_buffer_sprintf( buf, "clearType = %bd, fontSize = %g, valign = %s",
                                    info->isClearType,
                                    info->fontSize,
                                    NVG_ALIGN_UTF8String( info->verticalAlignment));
         CGContextTextInRect( context,
                 mulle_buffer_get_string( buf), (size_t) -1,
                 CGRectMake( canvas.origin.x + 2,
                 canvas.origin.y + 2,
                 canvas.size.width,
                 metrics.lineHeight),
                 CGContentModeLeft,
                 CGTextOptionDefault);

         mulle_buffer_reset( buf);
         mulle_buffer_sprintf( buf, "bounds = %s, area = %s",
                                    CGRectUTF8String( info->bounds),
                                    CGRectUTF8String( info->area));
         CGContextTextInRect( context,
                 mulle_buffer_get_string( buf), (size_t) -1,
                 CGRectMake( canvas.origin.x + 2,
                 canvas.origin.y + (2 + metrics.lineHeight),
                 canvas.size.width,
                 metrics.lineHeight),
                 CGContentModeLeft,
                 CGTextOptionDefault);

         // bottom info
         mulle_buffer_reset( buf);
         mulle_buffer_sprintf( buf, "metrics: asc = %g, desc = %g, height = %g",
                                    info->metrics.ascender,
                                    info->metrics.descender,
                                    info->metrics.lineHeight);
         CGContextTextInRect( context,
                 mulle_buffer_get_string( buf), (size_t) -1,
                 CGRectMake( canvas.origin.x + 2,
                 CGRectGetMaxY( canvas) - (2 + metrics.lineHeight * 2),
                 canvas.size.width,
                 metrics.lineHeight),
                 CGContentModeLeft,
                 CGTextOptionDefault);

         mulle_buffer_reset( buf);
         mulle_buffer_sprintf( buf, "visual: asc = %g, desc = %g, height = %g, compensation = %g",
                                    info->visualMetrics.ascender,
                                    info->visualMetrics.descender,
                                    info->visualMetrics.lineHeight,
                                    info->compensation);
         CGContextTextInRect( context,
                 mulle_buffer_get_string( buf), (size_t) -1,
                 CGRectMake( canvas.origin.x + 2,
                 CGRectGetMaxY( canvas) - (2 + metrics.lineHeight * 1),
                 canvas.size.width,
                 metrics.lineHeight),
                 CGContentModeLeft,
                 CGTextOptionDefault);
      }
   }
   CGContextRestore( context);
}




static void   dump_row_glyphs_to_file( FILE *fp,
                                       struct UITextRow *rows,
                                       NSUInteger i,
                                       struct Info *info,
                                       CGContext *context)
{
   struct UIGlyphPosition   positions[ 64];
   NSUInteger               j, m;
   CGRect                   rect;

   m = [context getGlyphPositions:positions
                            count:sizeof( positions) / sizeof( positions[ 0])
                             text:UITextRowGetUTF8Characters( &rows[ i])
                           length:UITextRowGetLength( &rows[ i])];

   if( cleartype)
      mulle_fprintf( fp, "clearType = %bd, ",info->isClearType);

   mulle_fprintf( fp, "fontSize = %g, valign = %s, lineHeight: %g visualLineHeight: %g\n",
                       info->fontSize,
                       NVG_ALIGN_UTF8String( info->verticalAlignment),
                       info->metrics.lineHeight,
                       info->visualMetrics.lineHeight);
   for( j = 0; j < m; j++)
   {
      rect = UIGlyphPositionGetVisualBounds( &positions[ j]);
      mulle_fprintf( fp, "\t%td,%td: %s\n", j, i, CGRectUTF8String( rect));
   }
}


// nanovg uses a texture atlas, where each character has a 1 pixel clear
// border around it, because:
//
// Why Texture Bleeding Happens
//
//     Bilinear/Trilinear Filtering: When OpenGL samples textures, it
//     interpolates between neighboring texels. At the edge of your texture
//     content, it can sample outside your intended area.
//
//     Mipmapping: When generating mipmaps, texels get averaged together, which
//     can cause colors to bleed across boundaries.
//
//     Floating-Point Precision: Texture coordinates might not exactly hit the
//     center of texels due to floating-point imprecision.
//
// The Border Solution
//
//     Add a 1-pixel border around your actual texture content
//     Fill this border with either transparent pixels (for sprites).
//
//     When dealing with say an 8×8 pixel image, add a 1-pixel border:
//
//     You create a 10×10 texture (8×8 plus 1-pixel border on all sides)
//     You fill the texture with clear color
//     You place your original 8×8 image in the center (positions 1,1 to 8,8)
//     You use the entire 10×10 as your texture
//     You adjust your UV coordinates to only sample from the inner 8×8 region
//

static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect                 canvas;
   float                  factor;
   struct UITextRow       rows[ 64];
   NSUInteger             i, n;
   CGFloat                x, y;
   CGPaint                *paint;
   struct Info            space = { 0 };
   struct Info            *info = &space;
   NSUInteger             bits;
   CGFloat                lineHeight;

   canvas = [layer canvas];
   paint  = [CGGradient gradientWithStartColor:CGColorMakeYellow()
                                      endColor:CGColorMakeOrange()
                                      rotation:0.1625];
   CGContextFillRectWithPaintable( context, canvas, paint);

   bits = [context numberOfFrames] & 0x1F;

   // NVG_ALIGN_TOP      = 1<<3,  // Align text vertically to top.
   // NVG_ALIGN_MIDDLE   = 1<<4,  // Align text vertically to middle.
   // NVG_ALIGN_BOTTOM   = 1<<5,  // Align text vertically to bottom.
   // NVG_ALIGN_BASELINE = 1<<6, // Default, align text vertically to baseline.

   switch( bits & 0x3)
   {
   case 0x00 : info->verticalAlignment = CGTextAlignBaseline; break; // Converted from NVG_ALIGN_BASELINE
   case 0x01 : info->verticalAlignment = CGTextAlignTop;      break; // Converted from NVG_ALIGN_TOP
   case 0x02 : info->verticalAlignment = CGTextAlignMiddle;   break; // Converted from NVG_ALIGN_MIDDLE
   case 0x03 : info->verticalAlignment = CGTextAlignBottom;   break; // Converted from NVG_ALIGN_BOTTOM
   }
   bits >>= 0x2;

   if( cleartype)
   {
      info->isClearType = (bits & 0x1) ? YES : NO;
      bits >>= 1;
   }

   info->fontSize = 10 + (bits & 0x3);

   //CGContextShapeAntiAlias( context, 0);
   CGContextClearType( context, info->isClearType);
   CGContextTextAlign( context, CGTextAlignLeft | info->verticalAlignment); // Converted from NVG_ALIGN_LEFT | info->verticalAlignment
   CGContextFontSize( context, info->fontSize);

   info->metrics       = [context textMetrics];
   info->visualMetrics = [context visualTextMetrics];
   info->compensation  = roundf( (info->visualMetrics.ascender - info->metrics.ascender));
   info->area          = CGRectInsetWithInsets( canvas, UIEdgeInsetsMake( 40, 30, 30, 30));

   CGContextFillRectWithColor( context, CGRectExtrude( info->area, 2, 2), CGColorMakeWhite());

   // MEMO: if we don't do this fudge factor, the
   if( debug)
   {
      paint = [CGGradient gradientWithStartColor:CGColorMakeDimGray()
                                        endColor:CGColorMakeDarkSlateGray()
                                        rotation:0.1625];
      CGContextFillRectWithPaintable( context, info->area, paint);
   }

   //
   // let context figure out how to format text into rows that fit the area
   //
   n = [context getTextRows:rows
                      count:sizeof( rows) / sizeof( rows[ 0])
                       text:text
                     length:(NSUInteger) -1
              breakRowWidth:info->area.size.width];

   info->bounds  = [context boundsOfTextRows:rows
                                      count:n];
//   info->bounds  = CGRectOffset( info->bounds, 0, 0);

   x = info->area.origin.x;
   y = info->area.origin.y;

   //
   // this is "correct" because there is no "jumping" between mode on the
   // same 'y' coordinate
   //
   // TODO: we actually don't need visualLineHeight but visualAscender
   //       so we can make a decision where to position the baseline, the
   //       rest should fall into place
   //
   y += info->compensation;
   switch( info->verticalAlignment)
   {
   case CGTextAlignBaseline : y += info->metrics.ascender; // info->metrics.descender; break; // Converted from NVG_ALIGN_BASELINE
   case CGTextAlignTop      : y += 0; break; // Converted from NVG_ALIGN_TOP
   case CGTextAlignMiddle   : y += info->metrics.lineHeight / 2.0; break; // Converted from NVG_ALIGN_MIDDLE
   case CGTextAlignBottom   : y += info->metrics.lineHeight; break; // Converted from NVG_ALIGN_BOTTOM
   }

   CGContextTextColor( context, CGColorMakeWhite());
   CGContextTextBackgroundColor( context, CGColorMakeDarkSlateGray());

   // make black blobs
   CGContextGlobalCompositeBlendFunc( context, CGBlendFactorZero, CGBlendFactorZero);
   // black background with inverted pixels (unreadable)
   // CGContextGlobalCompositeBlendFunc( context, CGBlendFactorOneMinusSrcAlpha, CGBlendFactorZero);

   for( i = 0; i < n; i++)
   {
      CGContextText( context, CGPointMake( x, y), rows[ i].start, rows[ i].end - rows[ i].start);

      if( dump_glyphs)
         dump_row_glyphs_to_file( stdout, rows, i, info,  context);
      y += info->visualMetrics.lineHeight;
   }

   CGContextGlobalCompositeBlendFunc( context, CGBlendFactorOne, CGBlendFactorOneMinusSrcAlpha);

   if( debug)
      drawDebugInfo( info, canvas, context);

   return( NO);
}


int   main( int argc, char *argv[])
{
   int    i;
   char   *s;

   if( argc > 1)
   {
      mulle_buffer_do_autoreleased_string( buffer, NULL, s)
      {
         for( i = 1; i < argc; i++)
         {
            if( ! strcmp( argv[ i], "--no-debug"))
            {
               debug = NO;
               continue;
            }

            if( ! strcmp( argv[ i], "--no-cleartype"))
            {
               cleartype = NO;
               continue;
            }

            if( ! strcmp( argv[ i], "--dump-glyphs"))
            {
               dump_glyphs = YES;
               continue;
            }

            mulle_buffer_add_string_if_not_empty( buffer, "\n");
            mulle_buffer_add_string( buffer, argv[ i]);
         }
      }
      if( strlen( s))
         text = s;
   }

   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 400, 300),
                                           NULL,
                                           0.125f));
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

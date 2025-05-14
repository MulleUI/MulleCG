#define _GNU_SOURCE

#import "import-private.h"


static void   metricsDraw( struct NVGcontext *vg, float x, float y, float w, CGFloat fontSize)
{
   float   ascender, descender, lineHeight;

      // Set the font size
   nvgFontSize(vg, fontSize);

   // Set text alignment to default left and baseline
   nvgTextAlign(vg, NVG_ALIGN_LEFT | NVG_ALIGN_BASELINE);

   nvgTextMetrics( vg, &ascender, &descender, &lineHeight);

   // Set the stroke color to gray and draw bounds markers
   nvgBeginPath( vg);

   nvgMoveTo( vg, x, y -ascender);
   nvgLineTo( vg, x + w, y -ascender);

   nvgMoveTo( vg, x, y - descender);
   nvgLineTo( vg, x + w, y - descender);

   nvgStrokeColor( vg, nvgRGB( 0, 64, 0)); // green color
   nvgStrokeWidth( vg, 1.0);
   nvgStroke( vg);

   mulle_printf( "font ascender,descender,lineHeight : %g %g %g\n", ascender, descender, lineHeight);
}


static void   visualMetricsDraw( struct NVGcontext *vg, float x, float y, float w, CGFloat fontSize)
{
   float   ascender, descender, lineHeight;

      // Set the font size
   nvgFontSize(vg, fontSize);

   // Set text alignment to default left and baseline
   nvgTextAlign(vg, NVG_ALIGN_LEFT | NVG_ALIGN_BASELINE);

   nvgTextVisualMetrics( vg, &ascender, &descender, &lineHeight);

   // Set the stroke color to gray and draw bounds markers
   nvgBeginPath( vg);

   nvgMoveTo( vg, x, y -ascender);
   nvgLineTo( vg, x + w, y -ascender);

   nvgMoveTo( vg, x, y - descender);
   nvgLineTo( vg, x + w, y - descender);

   nvgStrokeColor( vg, nvgRGB( 0, 64, 0)); // green color
   nvgStrokeWidth( vg, 1.0);
   nvgStroke( vg);

   mulle_printf( "visual ascender,descender,lineHeight : %g %g %g\n", ascender, descender, lineHeight);
}


static void   codyDraw( struct NVGcontext *vg, float x, float y, char *s, float fontSize, BOOL visual)
{
   // Set the font size
   nvgFontSize(vg, fontSize);

   // Set text alignment to default left and baseline
   nvgTextAlign(vg, NVG_ALIGN_LEFT | NVG_ALIGN_BASELINE);

   // Measure the text bounds
   float bounds[6]= {0};
   if( visual)
      nvgTextVisualBounds(vg, x, y, s, NULL, bounds);
   else
      nvgTextBounds(vg, x, y, s, NULL, bounds);

   // Calculate width and height of the text
   float textWidth = bounds[2] - bounds[0];
   float textHeight = bounds[3] - bounds[1];

   // draw strokes and fills w/o antialiasing
   nvgShapeAntiAlias( vg, 1);

   // Set the background color to yellow and draw a rectangle covering the text area
   nvgBeginPath(vg);
   nvgRect(vg, bounds[0], bounds[1], textWidth, textHeight);
   nvgFillColor(vg, nvgRGB(255, 255, 255)); // White color
   nvgFill(vg);

   if( visual)
   {
      // Set the stroke color to gray and draw bounds markers
      nvgBeginPath( vg);

      nvgMoveTo( vg, bounds[0], bounds[4]);
      nvgLineTo( vg, bounds[ 0] + textWidth, bounds[4]);

      nvgMoveTo( vg, bounds[ 0], bounds[5]);
      nvgLineTo( vg, bounds[ 0] + textWidth, bounds[5]);

      nvgMoveTo( vg, bounds[ 0], y);
      nvgLineTo( vg, bounds[ 0] + textWidth, y);

      nvgStrokeColor( vg, nvgRGB( 64, 64, 0)); // yellow color
      nvgStrokeWidth( vg, 1.0);
      nvgStroke( vg);
   }

   // Set the stroke color to red and draw a rectangle around the text
   nvgBeginPath( vg);
   nvgRect( vg, bounds[0] - 1, bounds[1] - 1, textWidth + 2, textHeight + 2);
   nvgStrokeColor( vg, nvgRGB(255, 0, 0)); // Red color
   nvgStrokeWidth( vg, 1.0);
   nvgStroke( vg);


   // Set the fill color to black and draw the 'y' character
   nvgFillColor(vg, nvgRGB(0, 0, 0)); // Black color
   nvgText(vg, x, y, s, NULL);

   mulle_printf( "textW/H : %g %g\n", textWidth, textHeight);
   mulle_printf( "bounds  : %g %g %g %g (%g %g)\n", bounds[ 0], bounds[ 1], bounds[ 2], bounds[ 3], bounds[ 4], bounds[ 5]);
}


static void codyDraw2(struct NVGcontext *vg, float x, float y, char *s, float fontSize) {
    // Set the font size
    nvgFontSize(vg, fontSize);

    // Set text alignment to default left and baseline
    nvgTextAlign(vg, NVG_ALIGN_LEFT | NVG_ALIGN_BASELINE);

    // Measure the glyph positions
    NVGglyphPosition glyphs[100]; // Assuming the string is not longer than 100 characters
    int numGlyphs = nvgTextGlyphPositions(vg, x, y, s, NULL, glyphs, 100);

    // Calculate the bounding box from the glyph positions
    float minX = glyphs[0].x;
    float maxX = glyphs[numGlyphs - 1].maxx;

    // Use the first and last glyph to determine vertical bounds
    float minY = glyphs[0].miny;
    float maxY = glyphs[0].maxy;

    for (int i = 1; i < numGlyphs; i++) {
        if (glyphs[i].miny < minY) minY = glyphs[i].miny;
        if (glyphs[i].maxy > maxY) maxY = glyphs[i].maxy;
    }

    // Calculate width and height of the text
    float textWidth = maxX - minX;
    float textHeight = maxY - minY;

    // Draw strokes and fills without antialiasing
    nvgShapeAntiAlias(vg, 0);

    // Set the background color to white and draw a rectangle covering the text area
    nvgBeginPath(vg);
    nvgRect(vg, minX, minY, textWidth, textHeight);
    nvgFillColor(vg, nvgRGB(255, 255, 255)); // White color
    nvgFill(vg);

    // Set the stroke color to red and draw a rectangle around the text
    nvgBeginPath(vg);
    nvgRect(vg, minX - 1, minY - 1, textWidth + 2, textHeight + 2);
    nvgStrokeColor(vg, nvgRGB(255, 0, 0)); // Red color
    nvgStrokeWidth(vg, 1.0);
    nvgStroke(vg);

    // Set the fill color to black and draw the text
    nvgFillColor(vg, nvgRGB(0, 0, 0)); // Black color
    nvgText(vg, x, y, s, NULL);

   mulle_printf( "textW/H    : %g %g\n", textWidth, textHeight);
   mulle_printf( "minX/maxX  : %g %g\n", minX, maxX);
   mulle_printf( "minY/maxY  : %g %g\n", minY, maxY);
}


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   struct NVGcontext   *vg;
   float               fontSize;
   char                *text[] = { "y", "|", "`", "_" };
   NSUInteger          i, n;


   vg = CGContextGetNVGContext( context);

   fontSize = 20.0;

   metricsDraw( vg, 100 - 20, 50, 4 * (fontSize + fontSize / 2) + 20, fontSize);

   codyDraw( vg, 100 + 0 * (fontSize + fontSize / 2), 50, "y", fontSize, NO);
   codyDraw( vg, 100 + 1 * (fontSize + fontSize / 2), 50, "|", fontSize, NO);
   codyDraw( vg, 100 + 2 * (fontSize + fontSize / 2), 50, "`", fontSize, NO);
   codyDraw( vg, 100 + 3 * (fontSize + fontSize / 2), 50, "_", fontSize, NO);

   visualMetricsDraw( vg, 100 - 20, 125, 4 * (fontSize + fontSize / 2) + 20, fontSize);

   codyDraw( vg, 100 + 0 * (fontSize + fontSize / 2), 125, "y", fontSize, YES);
   codyDraw( vg, 100 + 1 * (fontSize + fontSize / 2), 125, "|", fontSize, YES);
   codyDraw( vg, 100 + 2 * (fontSize + fontSize / 2), 125, "`", fontSize, YES);
   codyDraw( vg, 100 + 3 * (fontSize + fontSize / 2), 125, "_", fontSize, YES);

   metricsDraw( vg, 100 - 20, 200, 4 * (fontSize + fontSize / 2) + 20, fontSize);

   codyDraw2( vg, 100 + 0 * (fontSize + fontSize / 2), 200, "y", fontSize);
   codyDraw2( vg, 100 + 1 * (fontSize + fontSize / 2), 200, "|", fontSize);
   codyDraw2( vg, 100 + 2 * (fontSize + fontSize / 2), 200, "`", fontSize);
   codyDraw2( vg, 100 + 3 * (fontSize + fontSize / 2), 200, "_", fontSize);

   return( NO);
}


int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 400, 300),
                                           NULL,
                                           0.0f));
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


#define _GNU_SOURCE

#import "import-private.h"

#define DEBUG_TEXTURE 0

#define drawFill 0

static void   draw_texture( CGLayer *self, CGContext *context)
{
   struct NVGcontext          *vg;
   struct MulleIntegerSize    bitmapSize;

   bitmapSize = [self bitmapSize];

   vg = CGContextGetNVGContext( context);

   nvgBeginPath( vg);
   nvgShapeAntiAlias( vg, 0);
   nvgMoveTo( vg, bitmapSize.width - 2 + 0.5, 0.0);
   nvgLineTo( vg, bitmapSize.width - 2 + 0.5, bitmapSize.height - 2);
   nvgLineTo( vg, 0.0, bitmapSize.height - 2);
   nvgStrokeColor( vg, CGColorMakeRed());
   nvgStrokeWidth( vg, 1.0);
   nvgStroke( vg);
}


static void   drawGridWithLayer( CALayer *layer, CGContext *context, NSUInteger mode)
{
   struct NVGcontext             *vg;
   CGRect                        canvas;
   CGRect                        rect;
   CGFloat                       strokeWidth;
   CGSize                        wh;
   unsigned int                  i, j, k;
   CGColor                       color;
   CGColor                       colors[ 4];
   CGLayer                       *cgLayer;
   struct MulleIntegerSize       bitmapSize;
   NVGpaint                      imgPaint;
   struct CGLayerRenderInfo      memo;

   vg     = CGContextGetNVGContext( context);
   canvas = [layer canvas];

   strokeWidth = 1.0;
   nvgStrokeWidth( vg, strokeWidth);

   wh = CGSizeMake( floorf( canvas.size.width / 100.0),
                    floorf( canvas.size.height / 70.0));

   // create a CGLayer that looks like this
   //  tt| t
   //  tt| t
   //  --- t
   //  ttttt
   //
   // where 't' is transparent

   bitmapSize = MulleIntegerSizeMake( 4, 4);
   cgLayer    = [CGLayer layerWithBitmapSize:bitmapSize
                                  imageFlags:NVG_IMAGE_REPEATX|NVG_IMAGE_REPEATY
                                     context:context];
   if( ! cgLayer)
   {
      fprintf( stderr, "No CGLayer for you\n");
      return;
   }


   [cgLayer beginLayerRenderWithBackgroundColor:CGColorMakeClear()
                               devicePixelRatio:1.0
                                layerRenderInfo:&memo];
   draw_texture( cgLayer, context);
   [cgLayer endLayerRender:&memo];

#if DEBUG_TEXTURE
   {
      static struct CGBitmap  bitmap = { 0 };

      if( ! bitmap.bytes)
      {
         bitmap = [cgLayer RGBABytesBitmap:NULL];
         mulle_bitmap_rgba_dump( bitmap);
         CGBitmapDone( bitmap);
      }
   }
#endif

   imgPaint = nvgImagePattern( vg, 0,
                                   0,
                                   wh.width, // * (x / 10.0), // - (rect.size.width  / 4 * (y - 1)),
                                   wh.height, // * (y / 10.0), // - (rect.size.height / 4 * (y - 1)),
                                   0,
                                   [cgLayer textureID],
                                   1.0);
   nvgFillPaint( vg, imgPaint);
   CGContextCheckBackendError( context, "after nvgFillPaint");

   for( j = 0; j < 70; j++)
   {
      rect = CGRectMake( CGRectGetMinX( canvas), j * wh.height, canvas.size.width, wh.height);
      rect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside);

      // compensate for surrounding unused space of CGLayer
      rect.size.width  += 1.0;
      rect.size.height += 1.0;

      nvgBeginPath( vg);
      nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
      nvgFill( vg);
      CGContextCheckBackendError( context, "after nvgFill");
   }

   for( i = 0; i < 100; i++)
   {
      rect = CGRectMake( i * wh.width, CGRectGetMinY( canvas), wh.width, canvas.size.height);
      rect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside);

      // compensate for surrounding unused space of CGLayer
      rect.size.width  += 1.0;
      rect.size.height += 1.0;
      nvgBeginPath( vg);
      nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
      nvgFill( vg);
      CGContextCheckBackendError( context, "after nvgFill");
   }
}

#if 0
// 1600 fps (1700 filled)
static void   drawGrid( CALayer *layer, CGContext *context, NSUInteger mode)
{
   struct NVGcontext    *vg;
   CGRect               canvas;
   CGRect               rect;
   CGFloat              strokeWidth;
   CGSize               wh;
   unsigned int         i, j, k;
   CGColor              color;
   CGColor              colors[ 4];

   vg     = CGContextGetNVGContext( context);
   canvas = [layer canvas];

   strokeWidth = 1.0;
   nvgStrokeWidth( vg, strokeWidth);

   wh = CGSizeMake( floorf( canvas.size.width / 100.0),
                    floorf( canvas.size.height / 70.0));

   nvgBeginPath( vg);
   for( j = 0; j < 70; j++)
   {
      rect = CGRectMake( CGRectGetMinX( canvas), j * wh.height, canvas.size.width, wh.height);
      rect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside);
      nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
   }

   for( i = 0; i < 100; i++)
   {
      rect = CGRectMake( i * wh.width, CGRectGetMinY( canvas), wh.width, canvas.size.height);
      rect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside);
      nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
   }
   nvgShapeAntiAlias( vg, 1);
#if drawFill
   nvgFillColor( vg, CGColorMakeBlue());
   nvgFill( vg);
#else
   nvgStrokeColor( vg, CGColorMakeBlack());
   nvgStrokeWidth( vg, strokeWidth);
   nvgStroke( vg);
#endif
}
#endif

static void   drawStuff0( CALayer *layer, CGContext *context)
{
   drawGridWithLayer( layer, context, 0);
}


typedef CALayerDrawCallback_t  *CALayerDrawCallbackPointer_t;

static CALayerDrawCallbackPointer_t   drawStuff[ 1] =
{
   (CALayerDrawCallback_t *) drawStuff0
};


int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window[ 8];
   NSUInteger      i;
   MulleUIPerf     *perf;
   NSUInteger      styleMask;

   app = [UIApplication sharedInstance];

   for( i = 0; i < 1; i++)
   {
      styleMask  = UIWindowStyleMaskDefault;
      styleMask &= ~UIWindowStyleRetained;

      window[ i] = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 1000, 700)
                             titleUTF8String:"Demo"
                                  styleMask:styleMask];
      [window[ i] setDrawCallback:drawStuff[ i]];
      [window[ i] setBackgroundColor:CGColorMakeWhite()];
      [app addWindow:window[ i]];

//      [window[ i] setSwapInterval:1];
      [window[ i] setFrameRate:UIWindowFrameRateUnsynced];

      perf = [MulleUIPerf object];
      [window[ i] setFrameDelegate:perf];
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


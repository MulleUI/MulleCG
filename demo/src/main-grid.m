#define _GNU_SOURCE

#import "import-private.h"

#define DEBUG_TEXTURE 0

#define drawFill 0

static void   draw_texture( CGFramebuffer *self, CGContext *context)
{
   CGPixelSize    bitmapSize;

   bitmapSize = [self bitmapSize];

   CGContextBeginPath( context);
   {
      CGContextShapeAntiAlias( context, 0);
      CGContextMoveTo( context, CGPointMake( bitmapSize.width - 2 + 0.5, 0.0));
      CGContextLineTo( context, CGPointMake( bitmapSize.width - 2 + 0.5, bitmapSize.height - 2));
      CGContextLineTo( context, CGPointMake( 0.0, bitmapSize.height - 2));
      CGContextStrokeColor( context, CGColorMakeRed());
      CGContextStrokeWidth( context, 1.0);
   }
   CGContextStroke( context);
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
   CGFramebuffer                       *cgLayer;
   CGPixelSize       bitmapSize;
   NVGpaint                      imgPaint;
   struct CGFramebufferRenderInfo      memo;

   vg     = CGContextGetNVGContext( context);
   canvas = [layer canvas];

   strokeWidth = 1.0;
   nvgStrokeWidth( vg, strokeWidth);

   wh = CGSizeMake( floorf( canvas.size.width / 100.0),
                    floorf( canvas.size.height / 70.0));

   // create a CGFramebuffer that looks like this
   //  tt| t
   //  tt| t
   //  --- t
   //  ttttt
   //
   // where 't' is transparent

   bitmapSize = CGPixelSizeMake( 4, 4);
   cgLayer    = [CGFramebuffer framebufferWithBitmapSize:bitmapSize
                                            textureFlags:CGImageFlagRepeatX|CGImageFlagRepeatY
                                                 context:context];
   if( ! cgLayer)
   {
      fprintf( stderr, "No CGFramebuffer for you\n");
      return;
   }


   [cgLayer beginFBRenderWithBackgroundColor:CGColorMakeClear()
                               devicePixelRatio:1.0
                                layerRenderInfo:&memo];
   draw_texture( cgLayer, context);
   [cgLayer endFBRender:&memo];

#if DEBUG_TEXTURE
   {
      static struct CGBitmap  bitmap = { 0 };

      if( ! bitmap.bytes)
      {
         bitmap = [cgLayer RGBABytesBitmap:NULL];
         CGBitmapDump( bitmap);
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
   CGContextFillImageOptions( context, cgLayer, CGRectMakeWithSize( wh), NULL);
   CGContextCheckBackendError( context, "after CGContextFillPaintable");

   for( j = 0; j < 70; j++)
   {
      rect = CGRectMake( CGRectGetMinX( canvas), j * wh.height, canvas.size.width, wh.height);
      rect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside);

      // compensate for surrounding unused space of CGFramebuffer
      rect.size.width  += 1.0;
      rect.size.height += 1.0;

      CGContextBeginPath( context);
      CGContextRect( context, rect);
      CGContextFill( context);
      CGContextCheckBackendError( context, "after CGContextFill");
   }

   for( i = 0; i < 100; i++)
   {
      rect = CGRectMake( i * wh.width, CGRectGetMinY( canvas), wh.width, canvas.size.height);
      rect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside);

      // compensate for surrounding unused space of CGFramebuffer
      rect.size.width  += 1.0;
      rect.size.height += 1.0;
      CGContextBeginPath( context);
      CGContextRect( context, rect);
      CGContextFill( context);
      CGContextCheckBackendError( context, "after CGContextFill");
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


typedef CGGraphicsLayerDrawCallback_t  *CALayerDrawCallbackPointer_t;

static CALayerDrawCallbackPointer_t   drawStuff[ 1] =
{
   (CGGraphicsLayerDrawCallback_t *) drawStuff0
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


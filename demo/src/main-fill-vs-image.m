//
// fill-vs-image: tests that a tiled image covers its rect completely at
// various sub-pixel offsets. For each (dx, dy) in {0.0, 0.1, ..., 0.9}^2:
//   1. Fill window black
//   2. Fill rect with blue (should be fully covered by checkerboard)
//   3. Draw red/green checkerboard over same rect
//   4. After nvgEndFrame, read back pixels via readFramebufferBitmap:
//   5. Report any blue pixels that leaked through
//
#define _GNU_SOURCE
#import "import-private.h"
#include <math.h>

#define TILE_SIZE   8
#define RECT_W      160
#define RECT_H      120
#define MARGIN      40

#define R   { 0xFF, 0x00, 0x00, 0xFF }
#define G   { 0x00, 0xFF, 0x00, 0xFF }

static uint8_t   imagedata[ TILE_SIZE][ TILE_SIZE][ 4] =
{
    { R, R, R, R,  G, G, G, G },
    { R, R, R, R,  G, G, G, G },
    { R, R, R, R,  G, G, G, G },
    { R, R, R, R,  G, G, G, G },
    { G, G, G, G,  R, R, R, R },
    { G, G, G, G,  R, R, R, R },
    { G, G, G, G,  R, R, R, R },
    { G, G, G, G,  R, R, R, R },
};

static int   g_dx_step = 0;
static int   g_dy_step = 0;

static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   static MulleUIResourceStorageKeyDefine( grid);
   CGImage   *image;
   CGRect     canvas;
   CGRect     rect;
   CGFloat    dx, dy;

   dx = g_dx_step / 10.0f;
   dy = g_dy_step / 10.0f;

   canvas = [layer canvas];
   CGContextFillRectWithColor( context, canvas, CGColorMakeBlack());

   rect = CGRectMake( MARGIN + dx, MARGIN + dy, RECT_W, RECT_H);
   CGContextFillRectWithColor( context, rect, CGColorMake( 0.0, 0.0, 1.0, 1.0));

   image = [context imageWithRGBABytes:imagedata
                            bitmapSize:CGPixelSizeMake( TILE_SIZE, TILE_SIZE)
                          textureFlags:CGImageFlagRepeatX|CGImageFlagRepeatY
                        nameUTF8String:NULL
                           resourceKey:MulleUIResourceStorageKey( grid)];
   assert( image);
   [image drawRect:rect options:NULL context:context];

   return( YES);
}

static UIWindowDisplayBits   checkAndAdvance( UIPureWindow *window,
                                              id <UIGraphicsContext> context,
                                              struct CGFrameInfo *info,
                                              UIWindowDisplayBits displayBits)
{
   struct CGBitmap   bm;
   uint8_t           *pixels;
   int                w, h, leaks, i;
   CGFloat            dx, dy;

   if( g_dx_step >= 10)
      return( displayBits);

   dx = g_dx_step / 10.0f;
   dy = g_dy_step / 10.0f;

   bm = [(id <UIGraphicsContext>) context
            readFramebufferBitmap:CGPixelRectMake( (int)(MARGIN + dx) + 1,
                                                   (int)(MARGIN + dy) + 1,
                                                   RECT_W - 2,
                                                   RECT_H - 2)
            framebufferBitmapType:CGFramebufferRGBABytes
                        allocator:NULL];

   if( bm.bytes)
   {
      pixels = (uint8_t *) bm.bytes;
      w      = RECT_W - 2;
      h      = RECT_H - 2;
      leaks  = 0;

      for( i = 0; i < w * h; i++)
      {
         uint8_t r = pixels[ i*4 + 0];
         uint8_t g = pixels[ i*4 + 1];
         uint8_t b = pixels[ i*4 + 2];
         if( b > 128 && r < 64 && g < 64)
            leaks++;
      }
      if( leaks)
         mulle_fprintf( stdout, "dx=%.1f dy=%.1f : %d blue pixel(s) leaked\n", dx, dy, leaks);

      mulle_free( bm.bytes);
   }
   else
      mulle_fprintf( stdout, "dx=%.1f dy=%.1f : readFramebufferBitmap returned nil\n", dx, dy);

   g_dy_step++;
   if( g_dy_step >= 10)
   {
      g_dy_step = 0;
      g_dx_step++;
      if( g_dx_step >= 10)
      {
         mulle_fprintf( stdout, "done.\n");
         exit( 0);
      }
   }

   return( displayBits);
}

int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;

   app    = [UIApplication sharedInstance];
   window = [UIWindow windowWithFrame:CGRectMake( 0, 0, MARGIN*2 + RECT_W + 2, MARGIN*2 + RECT_H + 2)
                      titleUTF8String:"fill-vs-image"
                            styleMask:UIWindowStyleMaskDefault];
   [window setFrameRate:UIWindowFrameRateSynced];
   [window setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];
   [window setDidRenderFrameCallback:checkAndAdvance];
   return( [app runWindow:window]);
}

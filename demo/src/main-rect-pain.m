#define _GNU_SOURCE

#import "import-private.h"


#define AntiAlias  1
#define Thick      2



// MEMO: this is just a test to see how one can draw many bordered rectangles
//       efficiently, without having to use intermediate textures.
//       Result: it depends. The best is "drawRectColorOrdered" with twice
//       the FPs than the others

// drawRectColor, drawRectColorOrdered, drawRectColorOrderedWithFill
#define TestRectDrawAlgorithm        drawRectColorOrdered

// strokeRect1-4, fillRect
#define TestRectDrawFunction         strokeRect2

// 0 1
#define drawRectColorOrderedFill     1  // 171-174 fps

// ca. 48-50fps
static void   strokeRect1( struct NVGcontext *vg,
                           CGRect rect,
                           CGColor color,
                           CGColor backgroundColor,
                           CGFloat strokeWidth)
{
   rect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside);

   nvgBeginPath( vg);
   nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
   nvgStrokeColor( vg, color);
   nvgStrokeWidth( vg, strokeWidth);
   nvgStroke( vg);
}


// ca. 66 fps
static void   strokeRect2( struct NVGcontext *vg,
                           CGRect rect,
                           CGColor color,
                           CGColor backgroundColor,
                           CGFloat strokeWidth)
{
   nvgBeginPath( vg);
   nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
   nvgFillColor( vg, color);
   nvgFill( vg);

   rect = CGRectInset( rect, strokeWidth, strokeWidth);
   nvgBeginPath( vg);
   nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
   nvgFillColor( vg, backgroundColor);
   nvgFill( vg);
}


// ca. 39-40 fps
static void   strokeRect3( struct NVGcontext *vg,
                           CGRect rect,
                           CGColor color,
                           CGColor backgroundColor,
                           CGFloat strokeWidth)
{
   nvgBeginPath( vg);
   nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
   rect = CGRectInset( rect, strokeWidth, strokeWidth);
   nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
   nvgPathWinding( vg, NVG_HOLE); // affect last nvgRect
   nvgFillColor( vg, color);
   nvgFill( vg);
}


// ca. 47-49 fps
static void   strokeRect4( struct NVGcontext *vg,
                           CGRect rect,
                           CGColor color,
                           CGColor backgroundColor,
                           CGFloat strokeWidth)
{

   rect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside);

   nvgBeginPath( vg);
   nvgMoveTo( vg, CGRectGetMinX( rect), CGRectGetMinY( rect));
   nvgLineTo( vg, CGRectGetMaxX( rect), CGRectGetMinY( rect));
   nvgLineTo( vg, CGRectGetMaxX( rect), CGRectGetMaxY( rect));
   nvgLineTo( vg, CGRectGetMinX( rect), CGRectGetMaxY( rect));
   nvgClosePath( vg);
   nvgStrokeColor( vg, color);
   nvgStroke( vg);
}


// here we just fill a rect for reference
// ca. 125-127 fps
static void   fillRect( struct NVGcontext *vg,
                        CGRect rect,
                        CGColor color,
                        CGColor backgroundColor,
                        CGFloat strokeWidth)
{
   nvgBeginPath( vg);
   nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
   nvgFillColor( vg, color);
   nvgFill( vg);
}




static inline NSUInteger  getColorIndex( NSUInteger i, NSUInteger j)
{
   return ((j & 1) << 1) | (i & 1);
}


static inline CGColor  getColor( NSUInteger i, NSUInteger j)
{
   switch( getColorIndex( i, j))
   {
   case 0  : return( CGColorMakeBlue());
   case 1  : return( CGColorMakeGreen());
   case 2  : return( CGColorMakeBlack());
   default : return( CGColorMakeRed());
   }
}


static struct
{
   CGPoint       origin;
   CADirection   direction;
   CGFloat       energy;
} muncher;


static CGRect   munch( CGRect rect, NSUInteger i, NSUInteger j)
{
   NSUInteger   colorIndex;

   if( floorf( muncher.origin.x) != i || floorf( muncher.origin.y) != j)
      return( rect);

   switch( muncher.direction)
   {
   case 0:
      muncher.direction = CADirectionLeft;
      break;

   case CADirectionLeft  :
      if( floorf( muncher.origin.x) == 0)
      {
         muncher.direction = CADirectionRight;
         muncher.energy = 0.0;
      }
      else
         muncher.origin.x = muncher.origin.x - 0.3;
      break;

   case CADirectionRight :
      if( floorf( muncher.origin.x) == 99)
      {
         muncher.direction = CADirectionLeft;
         muncher.energy = 0.0;
      }
      else
         muncher.origin.x = muncher.origin.x + 0.3;
      break;

   case CADirectionUp    :
      if( floorf( muncher.origin.y) == 0)
      {
         muncher.direction = CADirectionDown;
         muncher.energy = 0.0;
      }
      else
         muncher.origin.y = muncher.origin.y - 0.3;
      break;

   case CADirectionDown  :
      if( floorf( muncher.origin.y) == 69)
      {
         muncher.direction = CADirectionUp;
         muncher.energy = 0.0;
      }
      else
         muncher.origin.y = muncher.origin.y + 0.3;
      break;
   }

   colorIndex = getColorIndex( i, j);

   muncher.energy += 1.0 + (colorIndex / 4.0);
   if( muncher.energy >= 200.0)
   {
      muncher.energy -= 200.0;
      muncher.direction = (rand() & 0x800)
                          ? CADirectionTurn90ClockWise( muncher.direction)
                          : CADirectionTurn90CounterClockWise( muncher.direction);
   }

   return( CGRectInset( rect, -4, -4));
}



static void   drawRectColor( CALayer *layer, CGContext *context, NSUInteger mode)
{
   struct NVGcontext   *vg;
   CGRect              canvas;
   CGRect              rect;
   CGFloat             strokeWidth;
   CGSize              wh;
   unsigned int        i, j, k;
   CGColor             color;
   NSUInteger          colorIndex;

   vg     = CGContextGetNVGContext( context);
   canvas = [layer canvas];

   strokeWidth = 1.5;
   nvgStrokeWidth( vg, strokeWidth);

   wh = CGSizeMake( floorf( canvas.size.width / 100.0),
                    floorf( canvas.size.height / 70.0));
   for( j = 0; j < 70; j++)
   {
      nvgShapeAntiAlias( vg, j >= 35);
      for( i = 0; i < 100; i++)
      {
         rect       = CGRectMake( i * wh.width, j * wh.height, wh.width, wh.height);
         rect       = CGRectInset( rect, 1, 1);
         rect       = munch( rect, i, j);
         color      = getColor( i, j);
         TestRectDrawFunction( vg, rect, color, CGColorMakeWhite(), strokeWidth);
      }
   }
}

// ca. 150-153 fps
// can't turn on/off ShapeAntiAlias here because we are producing one big mesh
static void   drawRectColorOrdered( CALayer *layer, CGContext *context, NSUInteger mode)
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

   strokeWidth = 1.5;
   nvgStrokeWidth( vg, strokeWidth);

   wh = CGSizeMake( floorf( canvas.size.width / 100.0),
                    floorf( canvas.size.height / 70.0));

   colors[ 0] = CGColorMakeBlue();
   colors[ 1] = CGColorMakeGreen();
   colors[ 2] = CGColorMakeBlack();
   colors[ 3] = CGColorMakeRed();
   for( k = 0; k < 4; k++)
   {
      nvgBeginPath( vg);
      for( j = 0; j < 70; j++)
      {
         for( i = 0; i < 100; i++)
         {
            if( (((j & 1) << 1) | (i & 1)) != k)
               continue;

            rect = CGRectMake( i * wh.width, j * wh.height, wh.width, wh.height);
            rect = CGRectInset( rect, 1, 1);
            rect = munch( rect, i, j);
            rect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside);
            nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
         }
      }
      nvgShapeAntiAlias( vg, 1);
#if drawRectColorOrderedFill
      nvgFillColor( vg, colors[ k]);
      nvgFill( vg);
#else
      nvgStrokeColor( vg, colors[ k]);
      nvgStrokeWidth( vg, strokeWidth);
      nvgStroke( vg);
#endif
   }
}


// 90 fps
static void   drawRectColorOrderedWithFill( CALayer *layer, CGContext *context, NSUInteger mode)
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

   strokeWidth = 1.5;
   nvgStrokeWidth( vg, strokeWidth);

   wh = CGSizeMake( floorf( canvas.size.width / 100.0),
                    floorf( canvas.size.height / 70.0));

   colors[ 0] = CGColorMakeBlue();
   colors[ 1] = CGColorMakeGreen();
   colors[ 2] = CGColorMakeBlack();
   colors[ 3] = CGColorMakeRed();
   for( k = 0; k < 4; k++)
   {
      nvgBeginPath( vg);
      for( j = 0; j < 70; j++)
      {
         for( i = 0; i < 100; i++)
         {
            if( (((j & 1) << 1) | (i & 1)) != k)
               continue;

            rect = CGRectMake( i * wh.width, j * wh.height, wh.width, wh.height);
            rect = CGRectInset( rect, 1, 1);
            rect = munch( rect, i, j);

            nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
         }
      }
      nvgShapeAntiAlias( vg, 1);
      nvgFillColor( vg, colors[ k]);
      nvgFill( vg);
   }

   // now clear out holes
   nvgBeginPath( vg);
   for( j = 0; j < 70; j++)
   {
      for( i = 0; i < 100; i++)
      {
         rect = CGRectMake( i * wh.width, j * wh.height, wh.width, wh.height);
         rect = CGRectInset( rect, 1, 1);
         rect = munch( rect, i, j);
         rect = CGRectInset( rect, strokeWidth, strokeWidth);
         nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
      }
   }
   nvgShapeAntiAlias( vg, 1);
   nvgFillColor( vg, CGColorMakeWhite());
   nvgFill( vg);
}



static void   drawStuff0( CALayer *layer, CGContext *context)
{
   TestRectDrawAlgorithm( layer, context, 0);
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

   app = [UIApplication sharedInstance];

   for( i = 0; i < 1; i++)
   {
      window[ i] = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 1000, 700)];
      [window[ i] setDrawCallback:drawStuff[ i]];
      [window[ i] setBackgroundColor:CGColorMakeWhite()];
      [app addWindow:window[ i]];

      [window[ i] setSwapInterval:0];
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


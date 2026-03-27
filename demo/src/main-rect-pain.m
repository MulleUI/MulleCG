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
static void   strokeRect1( CGContext *context,
                           CGRect rect,
                           CGColor color,
                           CGColor backgroundColor,
                           CGFloat strokeWidth)
{
   rect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside);

   CGContextBeginPath( context);
   CGContextRect( context, rect);
   CGContextStrokeColor( context, color);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}
// ca. 66 fps
static void   strokeRect2( CGContext *context,
                           CGRect rect,
                           CGColor color,
                           CGColor backgroundColor,
                           CGFloat strokeWidth)
{
   CGContextBeginPath( context);
   CGContextRect( context, rect);
   CGContextFillColor( context, color);
   CGContextFill( context);

   rect = CGRectInset( rect, strokeWidth, strokeWidth);
   CGContextBeginPath( context);
   CGContextRect( context, rect);
   CGContextFillColor( context, backgroundColor);
   CGContextFill( context);
}
// ca. 39-40 fps
static void   strokeRect3( CGContext *context,
                           CGRect rect,
                           CGColor color,
                           CGColor backgroundColor,
                           CGFloat strokeWidth)
{
   CGContextBeginPath( context);
   CGContextRect( context, rect);
   rect = CGRectInset( rect, strokeWidth, strokeWidth);
   CGContextRect( context, rect);
   CGContextPathWinding( context, CGPathFillStyleHole); // affect last nvgRect
   CGContextFillColor( context, color);
   CGContextFill( context);
}
// ca. 47-49 fps
static void   strokeRect4( CGContext *context,
                           CGRect rect,
                           CGColor color,
                           CGColor backgroundColor,
                           CGFloat strokeWidth)
{

   rect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside);

   CGContextBeginPath( context);
   CGContextMoveTo( context, CGPointMake(CGRectGetMinX( rect), CGRectGetMinY( rect)));
   CGContextLineTo( context, CGPointMake(CGRectGetMaxX( rect), CGRectGetMinY( rect)));
   CGContextLineTo( context, CGPointMake(CGRectGetMaxX( rect), CGRectGetMaxY( rect)));
   CGContextLineTo( context, CGPointMake(CGRectGetMinX( rect), CGRectGetMaxY( rect)));
   CGContextClosePath( context);
   CGContextStrokeColor( context, color);
   CGContextStroke( context);
}
// here we just fill a rect for reference
// ca. 125-127 fps
static void   fillRect( CGContext *context,
                        CGRect rect,
                        CGColor color,
                        CGColor backgroundColor,
                        CGFloat strokeWidth)
{
   CGContextBeginPath( context);
   CGContextRect( context, rect);
   CGContextFillColor( context, color);
   CGContextFill( context);
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
   CGRect              canvas;
   CGRect              rect;
   CGFloat             strokeWidth;
   CGSize              wh;
   unsigned int        i, j, k;
   CGColor             color;
   NSUInteger          colorIndex;

   canvas = [layer canvas];

   strokeWidth = 1.5;
   CGContextStrokeWidth( context, strokeWidth);

   wh = CGSizeMake( floorf( canvas.size.width / 100.0),
                    floorf( canvas.size.height / 70.0));
   for( j = 0; j < 70; j++)
   {
      CGContextShapeAntiAlias( context, j >= 35);
      for( i = 0; i < 100; i++)
      {
         rect       = CGRectMake( i * wh.width, j * wh.height, wh.width, wh.height);
         rect       = CGRectInset( rect, 1, 1);
         rect       = munch( rect, i, j);
         color      = getColor( i, j);
         TestRectDrawFunction( context, rect, color, CGColorMakeWhite(), strokeWidth);
      }
   }
}

// ca. 150-153 fps
// can't turn on/off ShapeAntiAlias here because we are producing one big mesh
static void   drawRectColorOrdered( CALayer *layer, CGContext *context, NSUInteger mode)
{
   CGRect               canvas;
   CGRect               rect;
   CGFloat              strokeWidth;
   CGSize               wh;
   unsigned int         i, j, k;
   CGColor              color;
   CGColor              colors[ 4];

   canvas = [layer canvas];

   strokeWidth = 1.5;
   CGContextStrokeWidth( context, strokeWidth);

   wh = CGSizeMake( floorf( canvas.size.width / 100.0),
                    floorf( canvas.size.height / 70.0));

   colors[ 0] = CGColorMakeBlue();
   colors[ 1] = CGColorMakeGreen();
   colors[ 2] = CGColorMakeBlack();
   colors[ 3] = CGColorMakeRed();
   for( k = 0; k < 4; k++)
   {
      CGContextBeginPath( context);
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
            CGContextRect( context, rect);
         }
      }
      CGContextShapeAntiAlias( context, 1);
#if drawRectColorOrderedFill
      CGContextFillColor( context, colors[ k]);
      CGContextFill( context);
#else
      CGContextStrokeColor( context, colors[ k]);
      CGContextStrokeWidth( context, strokeWidth);
      CGContextStroke( context);
#endif
   }
}
// 90 fps
static void   drawRectColorOrderedWithFill( CALayer *layer, CGContext *context, NSUInteger mode)
{
   CGRect               canvas;
   CGRect               rect;
   CGFloat              strokeWidth;
   CGSize               wh;
   unsigned int         i, j, k;
   CGColor              color;
   CGColor              colors[ 4];

   canvas = [layer canvas];

   strokeWidth = 1.5;
   CGContextStrokeWidth( context, strokeWidth);

   wh = CGSizeMake( floorf( canvas.size.width / 100.0),
                    floorf( canvas.size.height / 70.0));

   colors[ 0] = CGColorMakeBlue();
   colors[ 1] = CGColorMakeGreen();
   colors[ 2] = CGColorMakeBlack();
   colors[ 3] = CGColorMakeRed();
   for( k = 0; k < 4; k++)
   {
      CGContextBeginPath( context);
      for( j = 0; j < 70; j++)
      {
         for( i = 0; i < 100; i++)
         {
            if( (((j & 1) << 1) | (i & 1)) != k)
               continue;

            rect = CGRectMake( i * wh.width, j * wh.height, wh.width, wh.height);
            rect = CGRectInset( rect, 1, 1);
            rect = munch( rect, i, j);

            CGContextRect( context, rect);
         }
      }
      CGContextShapeAntiAlias( context, 1);
      CGContextFillColor( context, colors[ k]);
      CGContextFill( context);
   }

   // now clear out holes
   CGContextBeginPath( context);
   for( j = 0; j < 70; j++)
   {
      for( i = 0; i < 100; i++)
      {
         rect = CGRectMake( i * wh.width, j * wh.height, wh.width, wh.height);
         rect = CGRectInset( rect, 1, 1);
         rect = munch( rect, i, j);
         rect = CGRectInset( rect, strokeWidth, strokeWidth);
         CGContextRect( context, rect);
      }
   }
   CGContextShapeAntiAlias( context, 1);
   CGContextFillColor( context, CGColorMakeWhite());
   CGContextFill( context);
}

static void   drawStuff0( CALayer *layer, CGContext *context)
{
   TestRectDrawAlgorithm( layer, context, 0);
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

   app = [UIApplication sharedInstance];

   for( i = 0; i < 1; i++)
   {
      window[ i] = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 1000, 700)];

      [window[ i] setDrawCallback:drawStuff[ i]];
      [window[ i] setBackgroundColor:CGColorMakeWhite()];

      [window[ i] setSwapInterval:0];
      [window[ i] setFrameRate:UIWindowFrameRateUnsynced];

      perf = [MulleUIPerf instance];
      [window[ i] setFrameDelegate:perf];

      [app addWindow:window[ i]];
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


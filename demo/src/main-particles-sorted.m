#define _GNU_SOURCE

#import "import-private.h"

#import <string.h>


// THIS DEMOS IS DIFFERENT BECAUSE WE TRY TO KEEP SAME COLORED PARTICLES
// TOGETHER. WILL IT MAKE A DIFFERENCE ?
// 2.9.2022: on this lame wayland emulated 3d, its actually slower

#define PARTICLE_COUNT  1000
#define PARTICLE_SIZE   10


#define STROKE          0
#define FILL            1

//
// Release Numbers for Fill
//
// Aliasing makes only a difference when both are on. Assumption is, that
// shape antialias only turns on if edge antialias is turned on as well.
//
//  CIRCLE | EDGE_ANTIALIAS | SHAPE_ANTIALIAS | DRAW_METHOD | FPS
// --------|----------------|-----------------|-------------|------
//     0   |        0       |         0       |     FILL    | 203
//     0   |        1       |         0       |     FILL    | 203
//     0   |        0       |         1       |     FILL    | 203
//     0   |        1       |         1       |     FILL    | 163
//
//     0   |        0       |         0       |     FILL    | 65
//     0   |        1       |         1       |     FILL    | 49

#define CIRCLE          1
#define EDGE_ANTIALIAS  1
#define SHAPE_ANTIALIAS 1
#define DRAW_METHOD     FILL



// Debug Values
//
// P_COUNT  |  P_SIZE  | CIRCLE | ANTIALIAS | STROKE | FILL | FPS
// ---------|----------|--------|-----------|--------|------|---------
//   10000  |     4    |   0    |     0     |    0   |   1  |  82
//   10000  |     4    |   0    |     1     |    0   |   1  |  63
//   10000  |     4    |   0    |     0     |    1   |   0  |  27
//   10000  |     4    |   0    |     1     |    1   |   0  |  26
//
//   10000  |     4    |   1    |     0     |    0   |   1  |  31
//   10000  |     4    |   1    |     1     |    0   |   1  |  23
//   10000  |     4    |   1    |     0     |    1   |   0  |  18
//   10000  |     4    |   1    |     1     |    1   |   0  |  19

//
// Conclusions: filled circles are faster than stroked rectangles
//              AntiAliasing only helps for filling (speed wise)
//              Filling is faster than stroke
//

//Particle object with random starting position, velocity and color
struct Particle
{
   CGPoint      location;
   CGVector     velocity;
   CGColor      color;
};

static CGColor    colors[ 32] =
{
   CGColorDataAliceBlue,
   CGColorDataAqua,
   CGColorDataAquamarine,
   CGColorDataAzure,
   CGColorDataBisque,
   CGColorDataBlack,
   CGColorDataBlanchedAlmond,
   CGColorDataBlue,

   CGColorDataBlueViolet,
   CGColorDataBrown,
   CGColorDataBurlyWood,
   CGColorDataCadetBlue,
   CGColorDataChartreuse,
   CGColorDataChocolate,
   CGColorDataCrimson,
   CGColorDataCyan,

   CGColorDataDarkBlue,
   CGColorDataDarkCyan,
   CGColorDataDarkGoldenrod,
   CGColorDataDarkGray,
   CGColorDataDarkGreen,
   CGColorDataDarkKhaki,
   CGColorDataDarkMagenta,
   CGColorDataLime,

   CGColorDataLimeGreen,
   CGColorDataMagenta,
   CGColorDataMediumOrchid,
   CGColorDataTan,
   CGColorDataTomato,
   CGColorDataTurquoise,
   CGColorDataViolet,
   CGColorDataYellowGreen
};


static inline void   ParticleInit( struct Particle *p, CGSize canvasSize)
{
   CGFloat    r, g, b;

   p->location.x  = (rand() % (int) floor( canvasSize.width / 8)) - (canvasSize.width / 16) + canvasSize.width / 2;
   p->location.y  = 0;
   p->velocity.dx = 4 * (rand() / (double) RAND_MAX) - 2;
   p->velocity.dy = 4 * (rand() / (double) RAND_MAX) - 2;

   p->color       = colors[ rand() % 32];
}


static inline void   ParticleDrawRange( struct Particle *particles,
                                        NSRange range,
                                        NVGcontext *vg)
{
   CGFloat          size;
   struct Particle  *start;
   struct Particle  *sentinel;
   struct Particle  *p;

#if DRAW_METHOD == STROKE
   size = PARTICLE_SIZE / 2;
#else
   size = PARTICLE_SIZE;
#endif

   start    = &particles[ range.location];
   sentinel = &start[ range.length];

   if( start == sentinel)
      return;

   nvgBeginPath( vg);
#if DRAW_METHOD == STROKE
   nvgStrokeColor( vg, start->color);
#else
   nvgFillColor( vg, start->color);
#endif

   for( p = start; p < sentinel; p++)
   {
#if CIRCLE
   nvgCircle( vg, p->location.x,
                  p->location.y,
                  size);
#else
   nvgRect( vg, p->location.x,
                p->location.y,
                size,
                size);
#endif
   }

#if DRAW_METHOD == STROKE
   nvgStroke( vg);
#else
   nvgFill( vg);
#endif

}


static inline void   ParticleUpdate( struct Particle *p, CGSize canvasSize)
{
   p->location.x += p->velocity.dx;
   p->location.y += p->velocity.dy;

   if (p->location.x<0 || p->location.x > canvasSize.width)
       p->velocity.dx = -p->velocity.dx;
  if (p->location.y < 0 || p->location.y > canvasSize.height)
     p->velocity.dy = -p->velocity.dy;
}


static int   ParticleCompareByColor( struct Particle *p, struct Particle *q)
{
   return( CGColorCompare( p->color, q->color));
}


@interface ParticlesLayer : CGGraphicsLayer
{
   struct Particle   *_particles;
}

@property( readonly) NSUInteger   numberOfParticles;

- (void) setupParticles:(NSUInteger) n;

@end


@implementation ParticlesLayer

- (void) dealloc
{
   struct mulle_allocator  *allocator;

   allocator = MulleObjCInstanceGetAllocator( self);
   mulle_allocator_free( allocator, _particles);
   [super dealloc];
}


- (void) setupParticles:(NSUInteger) n
{
   CGRect                  canvas;
   NSUInteger              i;
   struct mulle_allocator  *allocator;

   canvas             = [self canvas];
   allocator          = MulleObjCInstanceGetAllocator( self);
   _numberOfParticles = n;
   _particles         = mulle_allocator_malloc( allocator, n * sizeof( struct Particle));

   for( i = 0; i < n; i++)
      ParticleInit( &_particles[ i], canvas.size);

   qsort( _particles,
          n,
          sizeof( struct Particle),
          (int (*)(const void *, const void *))
          ParticleCompareByColor);
}


- (BOOL) drawInContext:(CGContext *) context
{
   NVGcontext   *vg;
   CGRect       canvas;
   NSUInteger   i;
   NSRange      range;
   CGColor      color;

//   MulleUICLog( stderr, "%#@: %#@ drawInContext\n", [NSThread currentThread], self);

   if( ! [super drawInContext:context])
      return( NO);

   vg     = CGContextGetNVGContext( context);
   canvas = [self canvas];

   nvgShapeAntiAlias( vg, SHAPE_ANTIALIAS);


//enum NVGcompositeOperation {
//	NVG_SOURCE_OVER,
//	NVG_SOURCE_IN,          // saturate to black ?
//	NVG_SOURCE_OUT,         // flitter
//	NVG_ATOP,               // normaaahl
//	NVG_DESTINATION_OVER,   // schwarz
//	NVG_DESTINATION_IN,     // schwarz
//	NVG_DESTINATION_OUT,    // schwarz vom hintergrund
//	NVG_DESTINATION_ATOP,   // kleiner flitter
//	NVG_LIGHTER,   // brightness --> saturate to white
//	NVG_COPY,   // rahmen effect
//	NVG_XOR,    // flitter effect
//};

//   nvgGlobalCompositeOperation( vg, NVG_ATOP);

   nvgStrokeWidth( vg, PARTICLE_SIZE / 4);

   for( i = 0; i < _numberOfParticles; i++)
   {
      ParticleUpdate( &_particles[ i], canvas.size);
   }

   color = CGColorMakeWithRGB( 0, 0, 0);
   range = NSRangeMake( 0, 0);

   for( i = 0; i < _numberOfParticles; i++)
   {
      if( ! CGColorEqualToColor( color, _particles[ i].color))
      {
         range.length    = i - range.location;
         ParticleDrawRange( _particles, range, vg);

         range.location += range.length;
         color           = _particles[ i].color;
      }
   }

   range.length = _numberOfParticles - range.location;

   ParticleDrawRange( _particles, range, vg);
   range.location += range.length;

   return( YES);
}

@end


void   setupSceneInView( UIWindowPlane *contentPlane)
{
   ParticlesLayer   *layer;

   layer = [ParticlesLayer layerWithFrame:[contentPlane contentRect]];
   [contentPlane addLayer:layer];
   [layer setupParticles:PARTICLE_COUNT];
}


int   main()
{
   UIWindow         *window;
   UIApplication    *app;
   UIWindowStyleMask    styleMask;
   /*
    * window and app
    */
   app        = [UIApplication sharedInstance];

   styleMask  = UIWindowStyleMaskDefault;
   styleMask  = UIWindowStyleMaskBySetting( styleMask, UIWindowStyleRetained, NO);
   styleMask  = UIWindowStyleMaskBySetting( styleMask, UIWindowStyleAntiAlias, EDGE_ANTIALIAS);

   window     = [UIWindow windowWithFrame:CGRectMake( 0.0f, 0.0f, 640.0f, 400.0f)
                          titleUTF8String:"Demo"
                                styleMask:styleMask];

   [window setBackgroundColor:CGColorMakeWithRGBA( 0.0, 0.0, 0.0, 1.0)];
   [window setFrameRate:UIWindowFrameRateSynced];
   setupSceneInView( [window contentView]);

   [window setFrameDelegate:[MulleUIPerf object]];
   [app addWindow:window];

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


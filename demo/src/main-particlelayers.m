#import <MulleUICore/MulleUICore.h>

#import <string.h>


#define PARTICLE_COUNT  10000
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
//     0   |        0       |         0       |     FILL    | 178
//     0   |        1       |         1       |     FILL    | 130
//
//     0   |        0       |         0       |     FILL    |  60
//     0   |        1       |         1       |     FILL    |  40

#define CIRCLE          0
#define EDGE_ANTIALIAS  1
#define SHAPE_ANTIALIAS 1
#define DRAW_METHOD     FILL

//
// Debug numbers
//

// P_COUNT  |  P_SIZE  | CIRCLE | ANTIALIAS | STROKE | FILL | FPS
// ---------|----------|--------|-----------|--------|------|---------
//   10000  |     4    |   0    |     0     |    0   |   1  | 43
//   10000  |     4    |   0    |     1     |    0   |   1  |
//   10000  |     4    |   0    |     0     |    1   |   0  |
//   10000  |     4    |   0    |     1     |    1   |   0  |
//
//   10000  |     4    |   1    |     0     |    0   |   1  |
//   10000  |     4    |   1    |     1     |    0   |   1  |
//   10000  |     4    |   1    |     0     |    1   |   0  |
//   10000  |     4    |   1    |     1     |    1   |   0  |

//
// Conclusions: filled circles are faster than stroked rectangles
//              Antialiasing only helps for filling (speed wise)
//              Filling is faster than stroke
//

//Particle object with random starting position, velocity and color
@interface ParticleLayer : CALayer
{
   CGPoint      location;
   CGVector     velocity;
   CGColorRef   color;
}
@end


@implementation ParticleLayer

- (instancetype) initWithFrame:(CGRect) frame
{
   CGFloat    r, g, b;
   CGFloat    w;
   CGFloat    h;

   [super initWithFrame:frame];

   w = frame.size.width;
   h = frame.size.height;

   self->location.x  = (rand() % (int) floor( w / 8)) - (w / 16) + w / 2;
   self->location.y  = 0;
   self->velocity.dx = 4 * (rand() / (double) RAND_MAX) - 2;
   self->velocity.dy = 4 * (rand() / (double) RAND_MAX) - 2;

   do
   {
      r = (rand() / (double) RAND_MAX);
      g = (rand() / (double) RAND_MAX);
      b = (rand() / (double) RAND_MAX);
   }
   while( (r + g + b) < 0.4);

   self->color       = MulleColorMakeRGB( r, g, b);
   return( self);
}


static inline void   ParticleDraw( ParticleLayer *p, NVGcontext *vg)
{
   CGFloat   size;

#if DRAW_METHOD == STROKE
   size = PARTICLE_SIZE / 2;
#else
   size = PARTICLE_SIZE;
#endif

   nvgBeginPath( vg);
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
#if DRAW_METHOD == STROKE
   nvgStrokeColor( vg, p->color);
   nvgStroke( vg);
#else
   nvgFillColor( vg, p->color);
   nvgFill( vg);
#endif
}


static inline void   ParticleUpdate( ParticleLayer *p, CGSize canvasSize)
{
   p->location.x += p->velocity.dx;
   p->location.y += p->velocity.dy;

   if (p->location.x<0 || p->location.x > canvasSize.width)
       p->velocity.dx = -p->velocity.dx;
  if (p->location.y < 0 || p->location.y > canvasSize.height)
     p->velocity.dy = -p->velocity.dy;
}


- (void) drawInContext:(CGContext *) context
{
   NVGcontext   *vg;
   CGRect       canvas;
   NSUInteger   i;

   [super drawInContext:context];

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

   // nvgGlobalCompositeOperation( vg, NVG_ATOP);

   nvgStrokeWidth( vg, PARTICLE_SIZE / 4);

   ParticleUpdate( self, canvas.size);
   ParticleDraw( self, vg);
}

@end



void   setupSceneInView( UIView *contentView)
{
   CGRect          rect;
   NSUInteger      i;
   ParticleLayer   *layer;

   rect = [contentView contentRect];
   for( i = 0; i < PARTICLE_COUNT; i++)
   {
      layer = [ParticleLayer layerWithFrame:rect];
      [contentView addLayer:layer];
   }
}


int   main()
{
   UIWindow       *window;
   UIApplication  *app;
   /*
    * window and app
    */
   app    = [UIApplication sharedInstance];
   window = [[[UIWindow alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 640.0f, 400.0f)
                                titleCString:"Demo"
                                   styleMask:EDGE_ANTIALIAS ? 0 : UIWindowStyleNoEdgeAntialias] autorelease];
   [app addWindow:window];

   [window setBackgroundColor:CGColorMakeRGBA( 0.0, 0.0, 0.0, 1.0)];

   setupSceneInView( [window contentPlane]);

   [window renderLoop];

   [app terminate];
   return( 0);
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


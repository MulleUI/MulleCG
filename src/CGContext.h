#import "import.h"

#import "CGColor.h"


struct NVGcontext;

@class CGFont;
@class CGLayer;
@class CGContext;


@protocol CGContextResource

- (void) contextDidRemoveObject:(CGContext *) context;

@end


// mulle addition
typedef struct CGFrameInfo
{
   CGSize                 size;             // window coordinates size
   CGSize                 framebufferSize;  // actual pixels (frameSize * pixelRatio)
   CGRect                 viewportFrame;    // used for the viewport (use: 0, 0, frameSize)
   CGVector               UIScale;
   CGFloat                pixelRatio;
   NSUInteger             frameNumber;          // current frame nr (can wrap)
   NSUInteger             monitorRefreshRate;   // often 60 Hz
   mulle_timeinterval_t   renderStart;
} CGFrameInfo;

//
// could make those variable public ?
// for OpenGL we have one context per OpenGL, to keep fonts and
// other textures around. Each frame is encloded in a
// startRender and an endRender. frames can't be nested.
//
// The glfw window is necessary to the set the current OpenGL context.
// Therefore there is a 1:1 relationship between a context and a window. A
// thread can have multiple contexts though. But each context needs to be
// switched in and out. This is done with [UIWindow os_startRender]. The
// nanovg context is tied to the OpenGL context. Effectively you have to
// enclose drawing calls and OpenGL state calls with
// os_startRender/os_endRender. This is locking, so that there is no
// accidental switching.
//
@interface CGContext : NSObject
{
	struct NVGcontext            *_vg;
   struct CGFrameInfo           _currentFrameInfo;
   struct mulle__pointerset     _resources;
   struct mulle_map             _fontMap;
   BOOL                         _isRendering;
   mulle_timeinterval_t         _lastRenderStart;
}

@property( assign) CGFloat      alpha;

// not animatable though, better use windows ?
@property( assign) CGColorRef   backgroundColor;


@property( readonly, assign) mulle_timeinterval_t   frameDelta;


- (id) initWithEdgeAntialiasing:(BOOL) edgeAntialiasing
              useStencilStrokes:(BOOL) useStencilStrokes;

- (struct NVGcontext *) nvgContext;

- (void) beginRender:(struct CGFrameInfo *) info;
- (void) endRender;

//
// used to intermix OpenGL or other commands, this flushes commands
// cleans some font state and sets the viewport.
// Maybe rename to -flush and -start ?

- (void) suspendRender;
- (void) continueRender;

- (void) getCurrentFrameInfo:(struct CGFrameInfo *) info;
- (struct CGFrameInfo *) currentFrameInfo;

- (void) resetTransform;
- (void) clearFramebuffer;

//
// Images and maybe future other resources, that are only valid as long as
// the context is valid, are registered here. When the context goes down all
// resources will be finalized.
//
- (void) addToResources:(id <CGContextResource>) resource;
- (void) _removeFromResources:(id <CGContextResource>) resource; // will not callback
- (void) removeFromResources:(id <CGContextResource>) resource;
- (void) removeAllResources;

- (BOOL) isRendering;

@end

typedef CGContext   *CGContextRef;

static inline struct NVGcontext   *CGContextGetNVGContext( CGContextRef self)
{
   return( ((struct{ @defs( CGContext); } *) self)->_vg);
}


static inline void   CGContextSetAlpha( CGContextRef self, CGFloat alpha)
{
   [self setAlpha:alpha];
}


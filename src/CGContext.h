#import "import.h"

#import "CGColor.h"
#import "CGBitmap.h"

struct NVGcontext;

@class CGFont;
@class CGLayer;
@class CGContext;


@protocol CGContextResource

// tricky, but context may not be activated! it's not a good idea to 
// activate the context. See how CGImage does it
- (void) contextDidRemoveObject:(CGContext *) context;

@end


// mulle addition
typedef struct CGFrameInfo
{
   CGSize                 size;             // window coordinates size
   struct CGBitmapSize    framebufferSize;  // actual pixels (frameSize * pixelRatio)
   struct CGBitmapRect    viewportFrame;    // used for the viewport (use: 0, 0, frameSize)
   CGVector               UIScale;
   CGFloat                pixelRatio;
} CGFrameInfo;


// this is a convenience constructor, it's not fully flexible
static inline struct CGFrameInfo
   CGFrameInfoSFMake( CGSize size, struct CGBitmapSize framebufferSize, CGFloat scale)
{
   struct CGFrameInfo   info;

   memset( &info, 0, sizeof( info));
   info.size               = size;
   info.framebufferSize    = framebufferSize;
   info.viewportFrame.size = framebufferSize;
   info.UIScale            = CGVectorMake( scale, scale);
   info.pixelRatio         = size.width / framebufferSize.width;

   return( info);
}


static inline struct CGFrameInfo
   CGFrameInfoFBMake( struct CGBitmapSize framebufferSize, CGFloat pixelRatio, CGFloat scale)
{
   struct CGFrameInfo   info;

   memset( &info, 0, sizeof( info));
   info.size               = CGSizeMake( framebufferSize.width * pixelRatio,
                                         framebufferSize.height * pixelRatio);
   info.framebufferSize    = framebufferSize;
   info.viewportFrame.size = framebufferSize;
   info.UIScale            = CGVectorMake( scale, scale);
   info.pixelRatio         = pixelRatio;

   return( info);
}


struct CGFramebufferBitmap
{
   struct mulle_data        data;
   struct CGBitmapInfo      info;
   struct mulle_allocator   *allocator;
   int                      isFlipped;
};

static inline  void   CGFramebufferBitmapInit( struct CGFramebufferBitmap *p,
                                               struct mulle_data data,
                                               struct CGBitmapInfo info,
                                               struct mulle_allocator *allocator)
{
   if( ! p)
      return;
   p->data      = data;
   p->info      = info;
   p->allocator = allocator; // if NULL no free
}


static inline void   CGFramebufferBitmapDone( struct CGFramebufferBitmap *p)
{
   if( p && p->allocator)
      mulle_allocator_free( p->allocator, p->data.bytes);
}


//
// for OpenGL we have one context per OpenGL, to keep fonts and
// other textures around. Each frame is encloded in a
// startRender and an endRender. frames can't be nested. While inside
// startRender/endRender -isRendering will say YES.
//
// The glfw window is necessary to the set the current OpenGL context.
// Therefore there is a 1:1 relationship between a context and a window. A
// thread can have multiple contexts though. But each context needs to be
// switched in and out. This is done with [UIWindow os_startRender]. The
// nanovg context is tied to the OpenGL context. Effectively you have to
// enclose drawing calls and OpenGL state calls with
// os_startRender/os_endRender. This is locking, so that there is no
// accidental switching. If the context is tied to an OpenGL (or Vulcan
// whatever) context -isActive will say YES.
//
@interface CGContext : NSObject
{
	struct NVGcontext           *_vg;
   struct CGFrameInfo          _currentFrameInfo;
   struct CGFrameInfo          _lastFrameInfo;
   struct mulle__pointerset    _resources;
   struct mulle_map            _fontMap;
   struct mulle__pointerarray  _deletedTexturedIDs;
   NSUInteger                  _numberOfRenderedFrames;
   mulle_timeinterval_t        _renderStart;
   mulle_timeinterval_t        _lastRenderStart;
   BOOL                        _isRendering;
   BOOL                        _isActive;
   void                        *_offScreenFramebuffer;
   struct CGBitmapSize         _offScreenFramebufferSize;
}
@property( assign) CGFloat      alpha;

// not animatable though, better use windows ?
@property( assign) CGColorRef    backgroundColor;
@property( assign) BOOL          rendersOffScreen;
@property( assign, readonly) id  os_window;  // GLFWWindow


@property( readonly) mulle_timeinterval_t   frameDelta;

- (id) initWithEdgeAntialiasing:(BOOL) edgeAntialiasing
              useStencilStrokes:(BOOL) useStencilStrokes
                      os_window:(id) os_window;

- (struct NVGcontext *) nvgContext;

- (void) beginRender:(struct CGFrameInfo *) info;
- (void) endRender;

//
// used to intermix OpenGL or other commands, this flushes commands
// cleans some font state and sets the viewport.
// Maybe rename to -flush and -start ?
//
- (void) suspendRender;
- (void) resumeRender;

- (void) getCurrentFrameInfo:(struct CGFrameInfo *) info;

- (struct CGFrameInfo *) currentFrameInfo;
- (struct CGFrameInfo *) lastFrameInfo;

- (void) resetTransform;
- (void) clearFramebuffer;

// with 60hz and 32 bit wraps in a little more than 2 years
// value changes during -endRender
- (NSUInteger) numberOfRenderedFrames;

//
// Images and maybe future other resources, that are only valid as long as
// the context is valid, are registered here. When the context goes down all
// resources will be finalized.
//
- (void) addToResources:(id <CGContextResource>) resource;
- (void) _removeFromResources:(id <CGContextResource>) resource; // will not callback
- (void) removeFromResources:(id <CGContextResource>) resource;
- (void) removeAllResources;

// these are queued and deleted on the next render
- (void) deleteTextureID:(NSUInteger) id;

// between beginRender: and endRender:
- (BOOL) isRendering;

// it has a nvgContext and the openGL context is connected
// to the window. If isActive is no, you can/must not do any graphics
// calls for example.
- (BOOL) isActive;

// if you use inFlight, remember to flush with suspendRender/resumeRender
// otherwise likely you will see nothing. Rect is in framebuffer pixels,
// currently!!)
- (struct CGFramebufferBitmap) grabFramebufferAtRect:(struct CGBitmapRect) rect
                                            inFlight:(BOOL) inFlight
                                           allocator:(struct mulle_allocator *) allocator;

// TODO: combine with grabLastRenderedOffscreenFramebuffer
- (struct CGFramebufferBitmap) grabLastRenderedFramebuffer:(struct mulle_allocator *) allocator;

// this is available with renderOffScreen==YES and a render has gone through
// otherwise this could be stale or return something empty
- (struct CGFramebufferBitmap) grabLastRenderedOffscreenFramebuffer:(struct mulle_allocator *) allocator;

@end

typedef CGContext   *CGContextRef;

static inline struct NVGcontext   *CGContextGetNVGContext( CGContextRef self)
{
   assert( [self isActive]);

   return( ((struct{ @defs( CGContext); } *) self)->_vg);
}


static inline void   CGContextSetAlpha( CGContextRef self, CGFloat alpha)
{
   [self setAlpha:alpha];
}


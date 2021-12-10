#import "import.h"

#import "CGColor.h"


struct NVGcontext;

@class CGFont;
@class CGLayer;
@class CGContext;
@class CGImage;


enum CGContextBackend
{
   CG_GL3,
   CG_GL3_2,
   CG_GLES2,
   CG_GLES3
};



@protocol CGContextResource

// tricky, but context may not be activated! it's not a good idea to
// activate the context. See how CGImage does it
- (void) contextDidRemoveObject:(CGContext *) context;

@end
//
// for OpenGL we have one context per OpenGL, to keep fonts and
// other textures around. Each frame is encloded in a
// startRender and an endRender. frames can't be nested. While inside
// startRender/endRender -isRendering will say YES.
//
// The glfw window is necessary to the set the current OpenGL context.
// Therefore there is a 1:1 relationship between a context and a window. A
// thread can have multiple contexts though. But each context needs to be
// switched in and out. This is done with [UIWindow os_activateContext]. The
// nanovg context is tied to the OpenGL context. Effectively you have to
// enclose drawing calls and OpenGL state calls with
// os_activateContext/os_deactivateContext. This is locking, so that there is
// no accidental switching. If the context is tied to an OpenGL (or Vulcan
// whatever) context -isActive will say YES.
//
@interface CGContext : NSObject
{
	struct NVGcontext            *_vg;
   struct CGFrameInfo           _currentFrameInfo;
   struct CGFrameInfo           _lastFrameInfo;
   struct mulle__pointerset     _resources;
   struct mulle_set             _loanedResources;
   struct mulle_map             _fontMap;
   struct mulle_map             _gpuTextureMap;
   struct mulle__pointerarray   _deletedTexturedIDs;
   NSUInteger                   _numberOfRenderedFrames;
   mulle_timeinterval_t         _renderStartTime;
   mulle_timeinterval_t         _lastRenderStartTime;
   BOOL                         _isRendering;
   BOOL                         _isActive;
   int                          _nvgFlags; // used for nvgCreate

   // its more convenient to use a private framebuffer for offscreen rendering
   // than the default framebuffer of a offscreen window. So even if this
   // context is tied to an offscreen window, it will/should use this
   // offScreenFramebuffer instead.
   void                         *_offScreenFramebuffer;
   struct CGBitmapSize          _offScreenFramebufferSize;
   CGImage                      *_offScreenFramebufferImage;
}
@property( assign) CGFloat       alpha;

@property( assign) BOOL          rendersOffScreen;

@property( assign) BOOL          debugEnabled;
@property( assign) char          *debugNameUTF8String;  // useful for debugging


@property( readonly) mulle_timeinterval_t   frameDelta;

+ (enum CGContextBackend) backend;
+ (char *) backendUTF8String;

- (id) initWithEdgeAntialiasing:(BOOL) edgeAntialiasing
              useStencilStrokes:(BOOL) useStencilStrokes;

- (struct NVGcontext *) nvgContext;

- (void) beginRender:(struct CGFrameInfo *) info;
- (void) endRender;

- (void) _endRender; // does not call suspendRender

// does not delete textures, calculate frame timings, and does not
// set the offscreen buffer if needed. This method can be useful for
// intermediate changes to a different fbo during rendering. Be sure
// to save and restore -alpha and _currentFrameInfo.
// Use:
//    oldAlpha = [context alpha];
//    oldInfo  = *[context currentFrameInfo];
//    [context suspendRender];
//    [context _beginNestedRender:&myInfo];
//    ...
//    [context suspendRender];
//    [context _beginNestedRender:&oldInfo];
//    [context setAlpha:oldAlpha];
//
- (void) _beginNestedRender:(struct CGFrameInfo *) info;

//
// used to intermix OpenGL or other commands, this flushes commands
// cleans some font state and sets the viewport.
//
- (void) suspendRender;  // flushes and resets
- (void) resumeRender;   // resumes after a suspend
- (void) flushRender;    // suspends and resumes

- (void) changeRender:(struct CGFrameInfo *) info
                alpha:(CGFloat) alpha;

// to return to the "default" framebuffer, either the offscreen or the window
// one, if no offscreen exists
- (void) bindDefaultFramebuffer;

- (void) getCurrentFrameInfo:(struct CGFrameInfo *) info;

- (struct CGFrameInfo *) currentFrameInfo;
- (struct CGFrameInfo *) lastFrameInfo;

// used to restore state.. might go away soonish
- (void) _setCurrentFrameInfo:(struct CGFrameInfo *) info;

- (void) resetTransform;


// call this after beginRender, if you don't redraw the whole framebuffer
- (void) clearFramebufferWithHexColor:(NSUInteger) color;

// call this after beginRender, if you redraw everything
- (void) clearFramebufferMinimally;

// with 60hz and 32 bit wraps in a little more than 2 years
// value changes during -endRender
- (NSUInteger) numberOfRenderedFrames;
- (mulle_timeinterval_t) renderStartTime;
//
// Images and maybe future other resources, that are only valid as long as
// the context is valid, are registered here. When the context goes down all
// resources will be finalized. The resource is *NOT* retained by he context.
// If you want the context to "own" it. Use *giftResource*.

- (void) addToResources:(id <CGContextResource>) resource;
- (void) _removeFromResources:(id <CGContextResource>) resource; // will not callback
- (void) removeFromResources:(id <CGContextResource>) resource;
- (void) removeAllResources;

// if you want the context to retain the resource (and) release it on finalize
// you can loan it. A resource must have been added with addToResources: before
// though. Calling removeFromResources on a loaned resource is an error.
// You need to reposses the resource first.
//
- (void) loanResource:(id <CGContextResource>) resource;
- (void) repossessResource:(id <CGContextResource>) resource;
- (void) releaseAllLoanedResources;

// these are queued and deleted on the next render
// the imageID is the nanovg texture not the GPU texture
- (void) deleteTextureID:(NSInteger) id;

// between beginRender: and endRender:
- (BOOL) isRendering;

// it has a nvgContext and the openGL context is connected
// to the window. If isActive is no, you can/must not do any graphics
// calls for example.
- (BOOL) isActive;

// retrieve openGLError if any, print and abort
- (void) assertNoBackendError:(char *) str;


// the low-level glReadPixels routine, allocates memory of appropriate size
- (struct CGFramebufferBitmap) framebufferBitmapAtRect:(struct CGBitmapRect) rect
                                 framebufferBitmapType:(enum CGFramebufferBitmapType) type
                                             allocator:(struct mulle_allocator *) allocator;

// if you use inFlight, remember to flush with suspendRender/resumeRender
// otherwise likely you will see nothing. This needs the window context
// activated its not going to work with an offscreen framebuffer
- (struct CGFramebufferBitmap)
   lastRenderedFramebufferBitmapType:(enum CGFramebufferBitmapType) type
                            inFlight:(BOOL) inFlight
                           allocator:(struct mulle_allocator *) allocator;

- (struct CGFramebufferBitmap) lastRenderedFramebuffer;

// this is available with renderOffScreen==YES and a render has gone through
// otherwise this could be stale or return something empty
- (struct CGFramebufferBitmap)
   lastRenderedOffscreenFramebufferBitmapType:(enum CGFramebufferBitmapType) type
                                    allocator:(struct mulle_allocator *) allocator;

- (struct CGFramebufferBitmap) lastRenderedOffscreenFramebuffer;

// only useable until the offscreen renderer hits again
- (CGImage *) framebufferImage;
- (void) drawFramebufferBitmap:(struct CGFramebufferBitmap *) fb;

- (char *) shaderHeaderUTF8String;
- (void *) gpuTextureForImageID:(NSInteger) imageID;


// some very simple draw commands for debugging
- (void) fillRect:(CGRect) rect
         hexColor:(CGHexColor) hexColor;

- (void) strokeRect:(CGRect) rect
           hexColor:(CGHexColor) hexColor
              width:(CGFloat) width;

// used by UIWindow to blit...
- (void) drawRect:(CGRect) rect
            image:(id) image
            scale:(BOOL) scale;

@end

typedef CGContext   *CGContextRef;

static inline struct NVGcontext   *CGContextGetNVGContext( CGContextRef self)
{
   assert( [self isActive]);

   return( ((struct{ @defs( CGContext); } *) self)->_vg);
}


static inline struct NVGcontext   *_CGContextGetNVGContext( CGContextRef self)
{
   return( ((struct{ @defs( CGContext); } *) self)->_vg);
}



static inline void   CGContextSetAlpha( CGContextRef self, CGFloat alpha)
{
   [self setAlpha:alpha];
}


char   *CGNVGBackendErrorUTF8String( void);
char   *_CGNVGBackendErrorUTF8String( void  *error);

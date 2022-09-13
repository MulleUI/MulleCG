#import "import.h"


struct NVGcontext;

@class CGFont;
@class CGLayer;
@class CGContext;
@class CGImage;


typedef NS_ENUM( NSUInteger, CGContextNanoVGBackend)
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



typedef NS_ENUM( NSUInteger, CGContextFramebufferType)
{
   CGContextDefaultFramebuffer,
   CGContextLayerFramebuffer,
   CGContextOpenGLFramebuffer
};


struct CGContextFramebuffer
{
   void         *handle;
   NSUInteger   type;
};


// handle
static inline struct CGContextFramebuffer
CGContextFramebufferMake( void *handle, NSUInteger type)
{
   assert( type >= CGContextDefaultFramebuffer && type <= CGContextOpenGLFramebuffer);
   return( (struct CGContextFramebuffer) { .handle = handle, .type = type });
}


static inline struct CGContextFramebuffer
CGContextFramebufferMakeDefault( void)
{
   return( (struct CGContextFramebuffer) { .handle = NULL, .type = CGContextDefaultFramebuffer });
}


static inline struct CGContextFramebuffer
CGContextFramebufferMakeWithLayer( CGLayer *layer)
{
   return( (struct CGContextFramebuffer) { .handle = layer, .type = CGContextLayerFramebuffer });
}


static inline struct CGContextFramebuffer
CGContextFramebufferMakeWithOpenGLFramebuffer( void *handle)
{
   return( (struct CGContextFramebuffer) { .handle = handle, .type = CGContextOpenGLFramebuffer });
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
// switched in and out. This is done with [UIWindow os_activateGraphicsContext]. The
// nanovg context is tied to the OpenGL context. Effectively you have to
// enclose drawing calls and OpenGL state calls with
// os_activateGraphicsContext/os_deactivateGraphicsContext. This is locking, so that there is
// no accidental switching. If the context is tied to an OpenGL (or Vulcan
// whatever) context -isActive will say YES.
//
@interface CGContext : NSObject
{
   struct NVGcontext            *_vg;
   struct CGFrameInfo           _currentFrameInfo;
   struct CGContextFramebuffer  _currentFramebuffer;

   struct mulle__pointerset     _resources;
   struct mulle_set             _loanedResources;
   struct mulle_map             _fontMap;
   struct mulle_map             _gpuTextureMap;
   struct mulle__pointerarray   _deletedTexturedIDs;
   NSUInteger                   _numberOfFrames;  // counts endRenders...
   BOOL                         _isRendering;
   BOOL                         _isActive;
   int                          _nvgFlags; // used for nvgCreate

   mulle_absolutetime_t         _firstRenderTimeStamp;

   // its more convenient to use a private framebuffer for offscreen rendering
   // than the default framebuffer of a offscreen window. So even if this
   // context is tied to an offscreen window, it will/should use this
   // offScreenFramebuffer instead.

   mulle_atomic_pointer_t       _drawnLayer;    // CGLayer
   mulle_atomic_pointer_t       _scratchLayer;  // CGLayer

   CGLayer                      *_renderLayer;  // ephemeral(!)
}

@property( assign, readonly) BOOL   shareID;

@property( assign) BOOL             rendersOffScreen;

@property( assign) BOOL             debugEnabled;
@property( assign) char             *debugNameUTF8String;  // useful for debugging

@property( assign) NSUInteger       framebufferBits;
@property( assign) id               OSWindow;

@property( assign, readonly) UIGraphicsBackend    backend;


// the context needs to be told, what backend is being used
- (id) initWithEdgeAntialiasing:(BOOL) edgeAntialiasing
              useStencilStrokes:(BOOL) useStencilStrokes
                        shareID:(NSUInteger) shareID
                        backend:(UIGraphicsBackend) backend;

- (struct NVGcontext *) nvgContext;

- (void) beginRender:(struct CGFrameInfo *) info;
- (struct CGFrameInfo) bindRender:(struct CGFrameInfo *) info;
- (void) endRender;

- (void) _endRender; // does not call suspendRender

//
// used to intermix OpenGL or other commands, this flushes commands
// cleans some font state and sets the viewport.
// (resumeRender is in OpenGL)
- (void) suspendRender;  // flushes and resets
- (void) flushRender;    // suspends and resumes


// default is NULL until MulleUIOS comes into play
- (char *) backendUTF8String;


// to return to the "default" framebuffer, either the offscreen or the window
// one, if no offscreen exists
- (void) clearFramebuffer;
- (void) clearFramebufferWithColor:(CGColor) color;

- (struct CGContextFramebuffer) bindFramebuffer:(struct CGContextFramebuffer) framebuffer;

- (void) getCurrentFrameInfo:(struct CGFrameInfo *) info;
- (struct CGFrameInfo *) currentFrameInfo;

- (void) resetTransform;
- (void) resetScissor;

// betweenbeginRender: and endRender:
- (BOOL) isRendering;

// it has a nvgContext and the openGL context is connected
// to the window. If isActive is no, you can/must not do any graphics
// calls for example.
- (BOOL) isActive;

- (NSUInteger) numberOfFrames;
- (mulle_relativetime_t) secondsSinceFirstRender;

- (CGFloat) alpha;


// Once acquired its yours and its gone from CGContext. Now the window has
// contents to draw itself. It should keep the CGLayer around for the next
// refresh. If acquireOffscreenFramebuffer returns nil (no new drawing
// ready yet), it shold reuse that kept layer. Otherwise recycle the old
// and use the new.
- (id) acquireOffscreenFramebuffer;

//
// Framebuffer presumably acquired through acquireFramebuffer, should be given
// back. For reuse ot discarding
//
- (void) recycleFramebuffer:(id) layer;

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



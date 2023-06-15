#import "import.h"

#import "CGColor.h"
#include "millivg.h"

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


struct CGShaderUTF8Sources
{
   char                *name;
   char                *vertexSource;
   char                *fragmentSource;
   char                *geometrySource;
   UIGraphicsBackend   *backends;          // NULL is UIGraphicsBackendDefault
};                                         // terminate with UIGraphicsBackendNone


// just a rename
@protocol CGContextResource

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
   assert( layer);
   return( (struct CGContextFramebuffer) { .handle = layer, .type = CGContextLayerFramebuffer });
}


static inline struct CGContextFramebuffer
CGContextFramebufferMakeWithOpenGLFramebuffer( void *handle)
{
   assert( handle);
   return( (struct CGContextFramebuffer) { .handle = handle, .type = CGContextOpenGLFramebuffer });
}


struct CGContextItem
{
   void   *key;
   void   *value;
   void   (*release)( struct CGContextItem *item, CGContext *context);
};


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
@interface CGContext : NSObject < MulleUIResourceMap>
{
   struct NVGcontext                *_vg;
   struct CGFrameInfo               _currentFrameInfo;
   struct CGContextFramebuffer      _currentFramebuffer;

   struct MulleUIResourceStorage    _resourceStorage;
   struct mulle_map                 _fontMap;
   struct mulle_map                 _gpuTextureMap;
   struct mulle_map                 _shaderMap;
   struct mulle__pointerarray       _deletedTextureIDs;
   struct mulle__pointerarray       _deletedFramebuffers;
   NSUInteger                       _numberOfFrames;  // counts endRenders...
   BOOL                             _isRendering;
   BOOL                             _isActive;
   BOOL                             _isFreshLayer;
   int                              _nvgFlags; // used for nvgCreate
   CGShaderID                       _activeShader;

   mulle_absolutetime_t             _firstRenderTimeStamp;

   // its more convenient to use a private framebuffer for offscreen rendering
   // than the default framebuffer of a offscreen window. So even if this
   // context is tied to an offscreen window, it will/should use this
   // offScreenFramebuffer instead.

   mulle_atomic_pointer_t           _drawnLayer;       // CGLayer
   mulle_atomic_pointer_t           _scratchLayer;     // CGLayer

   CGLayer                          *_renderLayer;     // ephemeral(!)
   BOOL                             _hasLoadedFont;
}

@property( assign, readonly) BOOL   shareID;

@property( assign) BOOL             rendersOffScreen;

// to create "accumlate" effects, you don't clear the framebuffer but instead
// overwrite the old contents. This is hampered by double buffering and that
// the old framebuffer is likely to be destroyed at any time by the GPU/OS.
// So to achieve this use another CGImage is as an intermediate render layer, 
// which is then blitted into the onscreen or offscreen
// buffer. This is necessary, because singlebuffer or persistent double
// buffer is not working with wayland (and maybe not elswhere)
//
// So render into [CGImage] - blit -> [offscreen] - blit -> [framebuffer]
//

@property( assign) BOOL             debugEnabled;
@property( assign) char             *debugNameUTF8String;  // useful for debugging

@property( assign) NSUInteger       framebufferBits;
@property( assign) id               OSWindow;

@property( assign, readonly) UIGraphicsBackend             backend;

@property( assign) struct UIInputState                     inputState;
@property( assign, getter=isInitializedFramebuffer) BOOL   initializedFramebuffer;


+ (void) setDebugEnabled:(BOOL) flag;


+ (void) registerShaderSources:(struct CGShaderUTF8Sources *) source
             forNameUTF8String:(char *) nameUTF8String;
+ (void) registerShaderSources:(struct CGShaderUTF8Sources *) source;
- (struct CGShaderUTF8Sources *) registeredShaderSourcesForNameUTF8String:(char *) nameUTF8String;


// the context needs to be told, what backend is being used
- (id) initWithBackend:(UIGraphicsBackend) backend
               shareID:(NSUInteger) shareID
               options:(UIGraphicsOptions) options;

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
- (void) clearFramebufferWithHexColor:(NSUInteger) color;
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
- (BOOL) hasLoadedFont;

- (NSUInteger) numberOfFrames;
- (mulle_relativetime_t) secondsSinceFirstRender;

- (CGFloat) alpha;

- (CGShaderID) activeShader;


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

// get recycled framebuffer back 
- (id) acquireRecycledFramebuffer;

// support for some demos
- (CGPoint) mouseLocation;
- (NSUInteger) keyModifiers;
- (NSUInteger) buttonStates;

- (struct MulleUIResourceStorage *) _resourceStorage;


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

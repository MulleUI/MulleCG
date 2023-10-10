#import "CGLayoutContext.h"

#import "CGColor.h"
#include "microvg.h"


@class CGFont;
@class CGLayer;
@class CGContext;
@class CGImage;


@interface NSObject( CGLayerForward)

- (BOOL) isMultiSample;

@end


typedef NS_ENUM( NSUInteger, CGContextNanoVGBackend)
{
   CG_GL3,
   CG_GL3_2,
   CG_GLES2,
   CG_GLES3,
   CG_GLES3_2
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
   CGContextDefaultFramebuffer            = 0,
   CGContextLayerFramebuffer              = 1,
   CGContextOpenGLFramebuffer             = 2,
   CGContextDefaultMultiSampleFramebuffer = 0x10,
   CGContextLayerMultiSampleFramebuffer   = 0x11,
   CGContextOpenGLMultiSampleFramebuffer  = 0x12
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
   assert( (type >= CGContextDefaultFramebuffer && type <= CGContextOpenGLFramebuffer) ||
           (type >= CGContextDefaultMultiSampleFramebuffer && type <= CGContextOpenGLMultiSampleFramebuffer));
   return( (struct CGContextFramebuffer) { .handle = handle, .type = type });
}


static inline struct CGContextFramebuffer
   CGContextFramebufferMakeDefault( BOOL isMultiSample)
{
   return( (struct CGContextFramebuffer)
           {
              .handle = NULL,
              .type = isMultiSample
                      ? CGContextDefaultMultiSampleFramebuffer
                      : CGContextDefaultFramebuffer
           });
}


static inline struct CGContextFramebuffer
   CGContextFramebufferMakeWithLayer( CGLayer *layer)
{
   assert( layer);
   return( (struct CGContextFramebuffer)
           {
               .handle = layer,
               .type = [layer isMultiSample]
                       ? CGContextLayerMultiSampleFramebuffer
                       : CGContextLayerFramebuffer
           });
}


static inline struct CGContextFramebuffer
   CGContextFramebufferMakeWithOpenGLHandle( void *handle, BOOL isMultiSample)
{
   if( ! handle)
      return( CGContextFramebufferMakeDefault( isMultiSample));
   return( (struct CGContextFramebuffer)
           {
              .handle = handle,
              .type   = isMultiSample
                        ? CGContextOpenGLMultiSampleFramebuffer
                        : CGContextOpenGLFramebuffer
           });
}



static inline int
   CGContextFramebufferIsMultiSample( struct CGContextFramebuffer fb)
{
   return( fb.type >= CGContextDefaultMultiSampleFramebuffer);
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
@interface CGContext : CGLayoutContext
{
   struct CGFrameInfo               _currentFrameInfo;
   struct CGContextFramebuffer      _currentFramebuffer;

   struct mulle_map                 _gpuTextureMap;
   struct mulle_map                 _shaderMap;
   struct mulle__pointerarray       _deletedTextureIDs;
   struct mulle__pointerarray       _deletedFramebuffers;
   BOOL                             _isRendering;
   BOOL                             _isActive;
   BOOL                             _isFreshLayer;
   CGShaderID                       _activeShader;

   mulle_absolutetime_t             _firstRenderTimeStamp;

   // its more convenient to use a private framebuffer for offscreen rendering
   // than the default framebuffer of a offscreen window. So even if this
   // context is tied to an offscreen window, it will/should use this
   // offScreenFramebuffer instead.

   mulle_atomic_pointer_t           _drawnLayer;       // CGLayer
   mulle_atomic_pointer_t           _scratchLayer;     // CGLayer

   CGLayer                          *_renderLayer;     // ephemeral(!)
   NSUInteger                       _renderLayerTextureFlags;
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

@property( assign) NSUInteger                              framebufferBits;
@property( assign) id                                      OSWindow;

@property( assign, readonly) UIGraphicsBackend             backend;

@property( assign) struct UIInputState                     inputState;
@property( assign, getter=isInitializedFramebuffer) BOOL   initializedFramebuffer;

@property( assign) NSUInteger                              numberOfFrames;  // counts endRenders...


+ (void) registerShaderSources:(struct CGShaderUTF8Sources *) source
             forNameUTF8String:(char *) nameUTF8String;
+ (void) registerShaderSources:(struct CGShaderUTF8Sources *) source;
- (struct CGShaderUTF8Sources *) registeredShaderSourcesForNameUTF8String:(char *) nameUTF8String;


// the context needs to be told, what backend is being used
- (id) initWithBackend:(UIGraphicsBackend) backend
               shareID:(NSUInteger) shareID
               options:(UIGraphicsOptions) options;

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

// betweenbeginRender: and endRender:
- (BOOL) isRendering;

// it has a nvgContext and the openGL context is connected
// to the window. If isActive is no, you can/must not do any graphics
// calls for example.
- (BOOL) isActive;

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

// is this still used ? does it make sense ?
- (CGFloat) fontScale;


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


// we want to produce (excepting the quadratic) for a rate of 4
// 0.0, 0.5, 1.0, 1.5
static inline float  CGContextGetBackAndForthAnimationFactor( CGContext *context, NSUInteger rate)
{
   NSUInteger   n;
   NSUInteger   halfRate;
   float        factor;

   assert( rate >= 4);

   halfRate = rate / 2;
   n        = [context numberOfFrames] % rate;

   if( n <= halfRate)
      factor = n / ((float) halfRate);  // 0: 0 1: 0.5 2: 1
   else
      factor = 1.0f - ((n - halfRate) / (float) halfRate);  // 3: 0.5
   factor = _CAQuadraticGetValue( ((struct CAQuadratic) { 0.0f, 0.010f, 0.990f, 1.0f }), factor);
   return( factor);
}


static inline float  CGContextGetLinearAnimationFactor( CGContext *context, NSUInteger rate)
{
   assert( rate >= 2);

   return( (float) ([context numberOfFrames] % rate) / (float) (rate - 1));
}


struct MulleIntegerSize
   CGContextBitmapSizeOfFramebuffer( CGContext *self,
                                     struct CGContextFramebuffer fb);

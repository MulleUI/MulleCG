#import "CGLayoutContext.h"
#import "CGLayoutContext+CGFont.h"

#import "CGTypes.h"



@class CGFont;
@class CGFramebuffer;
@class CGContext;
@class CGImage;


@interface NSObject( CGLayer_Forward)

- (BOOL) isMultiSample;

@end


typedef NS_ENUM( NSUInteger, CGContextNanoVGBackend)
{
   CG_GL3,
   CG_GL3_2,
   CG_GLES2,
   CG_GLES3,
   CG_GLES3_2,
   CG_D3D11,
   CG_VULKAN,
   CG_METAL
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

- (void) didRemoveFromContext:(CGContext *) context;

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


struct CGContextItem
{
   void   *key;
   void   *value;
   void   (*release)( struct CGContextItem *item, CGContext *context);
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
   CGContextFramebufferMakeDefault( void)
{
   return( (struct CGContextFramebuffer)
           {
              .handle = NULL,
              .type   = CGContextDefaultFramebuffer
           });
}


static inline struct CGContextFramebuffer
   CGContextFramebufferMakeDefaultMultiSample( void)
{
   return( (struct CGContextFramebuffer)
           {
              .handle = NULL,
              .type   = CGContextDefaultMultiSampleFramebuffer
           });
}



static inline struct CGContextFramebuffer
   CGContextFramebufferMakeWithFramebuffer( CGFramebuffer *layer)
{
   assert( layer);
   return( (struct CGContextFramebuffer)
           {
               .handle = layer,
               .type   = [layer isMultiSample]
                         ? CGContextLayerMultiSampleFramebuffer
                         : CGContextLayerFramebuffer
           });
}


static inline struct CGContextFramebuffer
   CGContextFramebufferMakeWithOpenGLHandle( void *handle, BOOL isMultiSample)
{
   if( ! handle)
      return( isMultiSample
              ? CGContextFramebufferMakeDefaultMultiSample()
              : CGContextFramebufferMakeDefault());

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
   struct mulle__pointerarray       _deletedGPUFramebuffers;
   mulle_thread_mutex_t             _deletedGPUFramebuffersLock; // used for above pointer array

   BOOL                             _isRendering;
   BOOL                             _isFreshLayer;
   CGShaderID                       _activeShader;
   mulle_absolutetime_t             _firstRenderTimeStamp;

   // its more convenient to use a private framebuffer for offscreen rendering
   // than the default framebuffer of a offscreen window. So even if this
   // context is tied to an offscreen window, it will/should use this
   // offScreenFramebuffer instead.
   mulle_atomic_pointer_t           _atomicInitializedFramebuffer;

   CGFramebuffer                    *_renderFramebuffer;     // ephemeral(!)
   NSUInteger                       _renderLayerTextureFlags;

// these "rendered" Framebuffers are special, they are not a resource anymore
// and they have no thread ownership, they are "in limbo".
// Basically: Do not touch.
@private
   mulle_atomic_pointer_t           _drawnRenderedFramebuffer;   // CGFramebuffer
   mulle_atomic_pointer_t           _scratchRenderedFramebuffer; // CGFramebuffer
   struct mulle__pointerarray       _deletedFramebuffers;        // reycled framebuffers that are in limbo
   mulle_thread_mutex_t             _deletedFramebuffersLock;    // used for above pointer array
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

@property( assign, readonly) UIGraphicsBackend             backend;

// the contextID is just for debugging, each context gets a number we use
// it to differentiate textureIDs so we write contextID.textureID to make
// it clear that textureIDs can be reused by different contexts
@property( readonly) NSUInteger                            contextID;  // counts endRenders...

@property( assign) struct UIInputState                     inputState;

@property( dynamic, getter=isInitializedFramebuffer) BOOL  initializedFramebuffer  MULLE_OBJC_THREADSAFE_PROPERTY;

@property( assign) NSUInteger                              numberOfFrames;  // counts endRenders...

// designated:
- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context
                            nameUTF8String:(char *) nameUTF8String
                                   shareID:(NSUInteger) shareID
                                  options:(UIGraphicsOptions) options;

- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context
                                   shareID:(NSUInteger) shareID
                                   options:(UIGraphicsOptions) options;


// default is NULL until MulleUIOS comes into play
+ (char *) backendUTF8String;
- (char *) backendUTF8String;

- (void) getCurrentFrameInfo:(struct CGFrameInfo *) info;
- (struct CGFrameInfo *) currentFrameInfo;

- (NSUInteger) numberOfFrames;
- (mulle_relativetime_t) secondsSinceFirstRender;

- (CGFloat) alpha;

- (CGShaderID) activeShader;

// support for some demos
// UIWindow needs to be set with UIWindowStyleMousePolling to get values
- (CGPoint) mouseLocation;
- (NSUInteger) keyModifiers;
- (NSUInteger) buttonStates;

// is this still used ? does it make sense ?
- (CGFloat) fontScale;

// Debug tracing — backend sets/returns a FILE* for draw call logging.
// Returns the previous trace file (NULL if none). Pass NULL to disable.
- (FILE *) setTraceFile:(FILE *) file;

@end


@interface CGContext( Forward)

- (void) _initNanoVGWithGraphicsOptions:(UIGraphicsOptions) options;
- (void) _doneBackend;
- (void) barrier;
- (CGImage *) resolveMultiSampleImage:(CGImage *) image;

@end


typedef CGContext   *CGContextRef;


static inline BOOL   CGContextIsActiveInCurrentThread( CGContextRef self)
{
   return( [self activeThread] == [NSThread currentThread]);
}


MULLE_C_CONST_RETURN
static inline void   *CGContextGetBackendContext( CGContextRef self)
{
   assert( CGContextIsActiveInCurrentThread( self));

   return( ((struct{ @defs( CGContext); } *) self)->_cgBackend.context);
}


MULLE_C_CONST_RETURN
static inline void   *_CGContextGetBackendContext( CGContextRef self)
{
   return( ((struct{ @defs( CGContext); } *) self)->_cgBackend.context);
}

MULLE_C_CONST_RETURN
static inline struct CGFunctionTable *_CGContextGetFunctionTable( CGContextRef self)
{
   return( &((struct{ @defs( CGContext); } *) self)->_cgBackend.functions);
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
   factor = _CACubicGetValue( ((struct CACubic) { 0.0f, 0.010f, 0.990f, 1.0f }), factor);
   return( factor);
}


static inline float  CGContextGetLinearAnimationFactor( CGContext *context, NSUInteger rate)
{
   assert( rate >= 2);

   return( (float) ([context numberOfFrames] % rate) / (float) (rate - 1));
}








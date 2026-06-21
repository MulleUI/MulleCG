//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "import.h"

#include "CGBackend.h"

// CGGraphicsContextProvideris a `id <UIOSWindow>` usually, but we don't know.
// We also don't know how to activate the context (though we could), but the
// UIWindow usually does this for us
// that for us
//




// Resources are usually not-threadsafe and are tied via a handle to the 
// OpenGL context, they live in (textures as they usually are) but also tied
// to the current thread (with TAO).
// 
// When the CGContextBase changes to another NSThread then it needs to 
// move all the resources over to the new thread. Or discard all the resources 
// ?
//
@interface CGContextBase : MulleObject < MulleUIResourceMap, MulleUINamedObject>
{
   struct MulleUIResourceStorage   _resourceStorage;
   mulle_atomic_pointer_t          _atomicState;
}

@property( assign, readonly) id          OSWindow         MULLE_OBJC_THREADSAFE_PROPERTY;
@property( readonly) NSUInteger          debuggingFlags   MULLE_OBJC_THREADSAFE_PROPERTY;
@property( readonly) char                *nameUTF8String  MULLE_OBJC_THREADSAFE_PROPERTY;

// MEMO: state is two bits, one bit is essentially -activeThread != NULL and
//       the other is the state if the context is tied to thread at all.
//       We could get rid of the first bit easily...
@property( dynamic, assign) NSUInteger   state            MULLE_OBJC_THREADSAFE_PROPERTY;

- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context
                            nameUTF8String:(char *) name;

- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context;


- (struct MulleUIResourceStorage *) _resourceStorage   MULLE_OBJC_THREADSAFE_METHOD;

// use CGContextDebuggingFlags not CGContextBaseDebuggingFlags
+ (void) setDebuggingFlags:(NSUInteger) flag           MULLE_OBJC_THREADSAFE_METHOD;
+ (NSUInteger) debuggingFlags                          MULLE_OBJC_THREADSAFE_METHOD;


// pass thru to OSWindow, OK use this only for debugging and asserts
// and preferably only do pointer comparisons
- (NSThread *) activeThread                            MULLE_OBJC_THREADSAFE_METHOD;

- (void *) backendContext;

@end


@interface CGContextBase( Future) < MulleObjCFuture>

- (void) _initBackend;      // deprecated: use _initGraphicsBackend
- (void) _doneBackend;      // deprecated: use _doneGraphicsBackend

- (void) _initGraphicsBackend;
- (void) _doneGraphicsBackend;
- (void) _initFontBackend;
- (void) _doneFontBackend;

@end


//
// These return NULL/empty for CGContextBase/CGLayoutContext.
// CGContext overrides backendContext to return _cgBackend.context.
// CGContext+Drawing.h provides the real inline accessors using @defs(CGContext).
//
MULLE_C_CONST_RETURN
static inline void   *CGContextBaseGetBackendContext( CGContextBase *self)
{
   if( ! self)
      return( NULL);
   return( [self backendContext]);
}

MULLE_C_CONST_RETURN
static inline void   *_CGContextBaseGetBackendContext( CGContextBase *self)
{
   return( [self backendContext]);
}


MULLE_C_CONST_RETURN
static inline struct CGFunctionTable *_CGContextBaseGetFunctionTable( CGContextBase *self)
{
   // overridden in CGContext+Drawing.h with @defs(CGContext)
   return( NULL);
}


MULLE_C_CONST_RETURN
static inline struct CGBackendFunctionTable *_CGContextBaseGetBackendFunctionTable( CGContextBase *self)
{
   // overridden in CGContext+Drawing.h with @defs(CGContext)
   return( NULL);
}


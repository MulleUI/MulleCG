//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "NSObject.h")
#  import "NSObject.h"
# endif
#endif

#import "import.h"

// CGGraphicsContextProvideris a `id <UIOSWindow>` usually, but we don't know.
// We also don't know how to activate the context (though we could), but the
// UIWindow usually does this for us
// that for us
//


struct NVGcontext;



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
   struct NVGcontext                *_vg;

   struct MulleUIResourceStorage    _resourceStorage;
   int                              _nvgFlags; // used for nvgCreate
   mulle_atomic_pointer_t           _atomicState;
}

@property( assign, readonly) id          OSWindow         MULLE_OBJC_THREADSAFE_PROPERTY;
@property( readonly) NSUInteger          debuggingFlags   MULLE_OBJC_THREADSAFE_PROPERTY;
@property( readonly) char                *nameUTF8String  MULLE_OBJC_THREADSAFE_PROPERTY;

// MEMO: state is two bits, one bit is essentially -activeThread != NULL and
//       the other is the state if the context is tied to thread at all.
//       We could get rid of the first bit easily...
@property( dynamic, assign) NSUInteger    state           MULLE_OBJC_THREADSAFE_PROPERTY;

- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context
                            nameUTF8String:(char *) name;

- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context;


- (struct MulleUIResourceStorage *) _resourceStorage    MULLE_OBJC_THREADSAFE_METHOD;

// use CGContextDebuggingFlags not CGContextBaseDebuggingFlags
+ (void) setDebuggingFlags:(NSUInteger) flag            MULLE_OBJC_THREADSAFE_METHOD;
+ (NSUInteger) debuggingFlags                           MULLE_OBJC_THREADSAFE_METHOD;


// pass thru to OSWindow, OK use this only for debugging and asserts
// and preferably only do pointer comparisons
- (NSThread *) activeThread                            MULLE_OBJC_THREADSAFE_METHOD;

- (struct NVGcontext *) nvgContext;
- (void) reset; // resets drawing state (incl. scissor and transform)

@end



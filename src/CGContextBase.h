//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "NSObject.h")
#  import "NSObject.h"
# endif
#endif

#import "import.h"


struct NVGcontext;


// Resources are usually not-threadsafe and are tied via a handle to the 
// OpenGL context, they live in (textures as they usually are) but also tied
// to the current thread (with TAO).
// 
// When the CGContextBase changes to another NSThread then it needs to 
// move all the resources over to the new thread. Or discard all the resources 
// ?
//
@interface CGContextBase : MulleObject < MulleUIResourceMap>
{
   struct NVGcontext                *_vg;

   struct MulleUIResourceStorage    _resourceStorage;
   int                              _nvgFlags; // used for nvgCreate
   mulle_atomic_pointer_t           _nameUTF8String;
}

@property( dynamic, assign) char  *mulleNameUTF8String  MULLE_OBJC_THREADSAFE_PROPERTY;
@property( readonly) NSUInteger   debuggingFlags        MULLE_OBJC_THREADSAFE_PROPERTY;

- (struct MulleUIResourceStorage *) _resourceStorage    MULLE_OBJC_THREADSAFE_METHOD;

// use CGContextDebuggingFlags not CGContextBaseDebuggingFlags
+ (void) setDebuggingFlags:(NSUInteger) flag            MULLE_OBJC_THREADSAFE_METHOD;
+ (NSUInteger) debuggingFlags                           MULLE_OBJC_THREADSAFE_METHOD;

- (struct NVGcontext *) nvgContext;
- (void) reset; // resets drawing state (incl. scissor and transform)


@end

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


@interface CGContextBase : NSObject < MulleUIResourceMap>
{
   struct NVGcontext                *_vg;

   struct MulleUIResourceStorage    _resourceStorage;
   int                              _nvgFlags; // used for nvgCreate
}

@property( assign) NSUInteger   debugEnabled;
@property( assign) char         *debugNameUTF8String;  // useful for debugging


+ (void) setDebugEnabled:(NSUInteger) flag;

- (struct NVGcontext *) nvgContext;
- (void) reset; // resets drawing state (incl. scissor and transform)

- (struct MulleUIResourceStorage *) _resourceStorage;

@end

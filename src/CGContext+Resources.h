//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


@interface CGContext( Resources)

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
- (void) deleteTextureIDs;

@end

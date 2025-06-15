//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


#import "CGLayoutContext+nanovg.h"


@interface CGContext( nanovg)

+ (CGContextNanoVGBackend) nanoVGBackend;
+ (char *) nanoVGBackendUTF8String;

- (char *) nanovgInfoUTF8String;

// called by -init / -finalize
- (void) _initNanoVGWithGraphicsOptions:(UIGraphicsOptions) options;

- (char *) nanovgInfoUTF8String;


@end



@interface CGContextBase( nanovg)

+ (NVGcontext *) createPathContext;

@end


@interface CGLayoutContext ( OpenGL)

- (void) _initializeNanoVG:(NSUInteger) flags;
- (void) _finalizeNanoVG;

@end


@interface CGContext( Errors)

// this is here because nanovg sets the OpenGL version
- (void) assertNoBackendError:(char *) str;

@end




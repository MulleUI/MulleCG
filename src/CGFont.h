#import "import.h"


@class CGContext;

#include "millivg.h"

//
// CGFont is created and maintained by CGContext, you should not keep a
// reference to it, as it is only valid during rendering
//
@interface CGFont : NSObject

@property( assign) char       *nameUTF8String;   // NVG fontNameUTF8String
@property( assign) CGFontID   fontID;         // NVG index

+ (instancetype) fontWithNameUTF8String:(char *) name
                              fontID:(CGFontID) fontID;

- (instancetype) initWithNameUTF8String:(char *) name
                              fontID:(CGFontID) fontID;

@end

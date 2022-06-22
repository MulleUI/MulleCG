#import "import.h"


@class CGContext;


//
// CGFont is created and maintained by CGContext, you should not keep a
// reference to it, as it is only valid during rendering
//
@interface CGFont : NSObject

@property( assign) char       *nameUTF8String;   // NVG fontNameUTF8String
@property( assign) NSInteger   fontIndex;        // NVG index

+ (instancetype) fontWithNameUTF8String:(char *) name
                              fontIndex:(NSInteger) fontIndex;

- (instancetype) initWithNameUTF8String:(char *) name
                              fontIndex:(NSInteger) fontIndex;

@end

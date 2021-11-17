#import "import-private.h"

#import "CGFont.h"

#import "CGContext.h"

//
// CGFont needs the CGContext for fontloading and will only be valid for
// that context
//
@implementation CGFont

- (instancetype) initWithNameUTF8String:(char *) name
                             fontIndex:(NSInteger) fontIndex
{
	if( _fontIndex == -1)
   {
      [self release];
      return( nil);
	}

   [self setNameUTF8String:name];
	_fontIndex = fontIndex;
   return( self);
}


+ (instancetype) fontWithNameUTF8String:(char *) name
                              fontIndex:(NSInteger) fontIndex
{
   return( [[[self alloc] initWithNameUTF8String:name
                                   fontIndex:fontIndex] autorelease]);
}


- (void) setNameUTF8String:(char *) s
{
   MulleObjCObjectSetDuplicatedUTF8String( self, &_nameUTF8String, s);
}


- (void) dealloc
{
   MulleObjCInstanceDeallocateMemory( self, _nameUTF8String);
   [super dealloc];
}


@end
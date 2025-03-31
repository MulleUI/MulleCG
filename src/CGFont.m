#import "import-private.h"

#import "CGFont.h"

#import "CGContext.h"

//
// CGFont needs the CGContext for fontloading and will only be valid for
// that context
//
@implementation CGFont

- (instancetype) initWithNameUTF8String:(char *) name
                                 fontID:(CGFontID) fontID
{
	if( _fontID == -1)
   {
      [self release];
      return( nil);
	}

   [self setNameUTF8String:name];
	_fontID = fontID;
   return( self);
}


+ (instancetype) fontWithNameUTF8String:(char *) name
                                 fontID:(CGFontID) fontID
{
   CGFont   *obj;

   obj = [self alloc];
   obj = [obj initWithNameUTF8String:name
                              fontID:fontID];
   obj = [obj autorelease];
   return( obj);
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
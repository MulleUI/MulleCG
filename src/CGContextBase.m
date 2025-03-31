//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGContextBase.h"

#import "import-private.h"



@implementation CGContextBase

static struct
{
   NSUInteger    _debuggingFlags;
} Self;


+ (void) initialize
{
   char   *s;

   // don't rerun for subclass
   if( MulleObjCClassGetID( self) != @selector( CGContextBase))
      return;

   // use CGContext instead of CGContextBase
   s = getenv( "CGContextDebuggingFlags");
   if( ! s)
      s = getenv( "UIDebuggingFlags");
   if( s)
      Self._debuggingFlags = strtol( s, NULL, 0);
}


+ (NSUInteger) debuggingFlags
{
   return( Self._debuggingFlags);
}


+ (void) setDebuggingFlags:(NSUInteger) flag
{
    Self._debuggingFlags = flag;
}


- (struct MulleUIResourceStorage *) _resourceStorage
{
   return( &_resourceStorage);
}


- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context
                            nameUTF8String:(char *) name
{
   static SEL selectors[ 2] = {
                                 @selector( didAddToContext:),
                                 @selector( didRemoveFromContext:)
                              };

   [self _initResourceStorage:&_resourceStorage
            callbackSelectors:selectors];
   // MEMO: the layout context will have NULL _OSWindow (!)
   _OSWindow = os_context; // sic, not retained

   MulleObjCObjectSetDuplicatedUTF8String( self, &_nameUTF8String, name);

   return( self);
}


- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context
{
   return( [self initWithOSGraphicsContext:os_context
                                      nameUTF8String:NULL]);
}


- (instancetype) init
{
   abort();
   return( nil);
}



- (void) finalize
{
   [self _finalizeResourceStorage:&_resourceStorage];
   [super finalize];
}


- (void) dealloc
{
   [self _doneResourceStorage:&_resourceStorage];
   MulleObjCInstanceDeallocateMemory( self, _nameUTF8String);

   [super dealloc];
}


- (void) mulleGainAccess
{
   [super mulleGainAccess];
   [self mulleGainAccessToResources];
}


- (void) mulleRelinquishAccess
{
   [self mulleRelinquishAccessToResources];
   [super mulleRelinquishAccess];
}


- (NSUInteger) state
{
   return( (NSUInteger) (uintptr_t) _mulle_atomic_pointer_read( &_atomicState));
}


- (void) setState:(NSUInteger) state
{
   _mulle_atomic_pointer_write( &_atomicState, (void *) (uintptr_t) state);
}


- (NSThread *) activeThread
{
   return( [_OSWindow activeThread]);
}


- (struct NVGcontext *) nvgContext
{
   return( _vg);
}


- (void) reset
{
   nvgReset( _vg);
}


- (char *) threadSafeUTF8String
{
   char   *s;

   mulle_buffer_do_autoreleased_string( buffer, NULL, s)
   {
      s = MulleObjCClassGetNameUTF8String( NSClassFromObject( self));
      mulle_buffer_sprintf( buffer, "<%s %p", s, self);
      if( _nameUTF8String)
         mulle_buffer_sprintf( buffer, " \"%s\"", self->_nameUTF8String);
      mulle_buffer_add_string( buffer, ">");
   }
   return( s);
}

@end

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


- (instancetype) init
{
   static SEL selectors[ 2] = {
                                 @selector( didAddToContext:),
                                 @selector( didRemoveFromContext:)
                              };

   [self _initResourceStorage:&_resourceStorage
            callbackSelectors:selectors];
   return( self);
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


- (struct NVGcontext *) nvgContext
{
   return( _vg);
}


- (void) reset
{
   nvgReset( _vg);
}


- (char *) mulleNameUTF8String
{
   char  *s;

   s = _mulle_atomic_pointer_read( &_nameUTF8String);
   return( s ? s : "unnamed");
}


- (void) mulleSetNameUTF8String:(char *) s
{
   struct mulle_allocator       *allocator;
   struct _mulle_objc_universe  *universe;
   void                         *actual;
   void                         *old;

   // need universe allocator for abafree
   universe  = _mulle_objc_object_get_universe( self);
   allocator = _mulle_objc_universe_get_allocator( universe);
   old       = _mulle_atomic_pointer_read( &_nameUTF8String);
   if( s)
      s = mulle_allocator_strdup( allocator, s);

   actual = __mulle_atomic_pointer_cas( &_nameUTF8String, s, old);

   if( actual == old)
      mulle_allocator_abafree( allocator, old);
   else
      mulle_allocator_free( allocator, s);
}


- (char *) UTF8String
{
   Class   cls;
   char    *s;

   s = _mulle_atomic_pointer_read( &_nameUTF8String);
   if( s)
      return( s);

   cls = MulleObjCObjectGetClass( self);
   return( MulleObjC_asprintf( "<%s %p>", MulleObjCClassGetNameUTF8String( cls), self));
}

@end

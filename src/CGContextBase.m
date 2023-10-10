//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGContextBase.h"

#import "import-private.h"



@implementation CGContextBase

static struct
{
   NSUInteger    _debugEnabled;
} Self;


+ (void) initialize
{
   char   *s;

   s = getenv( "CGContextDebugEnabled");
   if( s)
      Self._debugEnabled = strtol( s, NULL, 0);
   else
   {
#ifdef CGCONTEXT_DEBUG_ENABLED
      Self._debugEnabled = CGCONTEXT_DEBUG_ENABLED;
#endif
   }
}


+ (void) setDebugEnabled:(NSUInteger) flag
{
   Self._debugEnabled = flag;
}


- (instancetype) init
{
   static SEL selectors[ 2] = {
                                 @selector( contextDidAddObject:),
                                 @selector( contextDidRemoveObject:)
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
   [super dealloc];
}


- (struct NVGcontext *) nvgContext
{
   return( _vg);
}


- (void) reset
{
   nvgReset( _vg);
}


- (struct MulleUIResourceStorage *) _resourceStorage
{
   return( &_resourceStorage);
}


@end

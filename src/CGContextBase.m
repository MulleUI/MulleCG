//
//  CGContextBase.m
//  MulleCG
//
//  Copyright (c) 2023 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#import "CGContextBase.h"

#import "import-private.h"



@implementation CGContextBase

static struct
{
   NSUInteger    _debuggingFlags;
} ClassStatic;


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
      ClassStatic._debuggingFlags = strtol( s, NULL, 0);
}


+ (NSUInteger) debuggingFlags
{
   return( ClassStatic._debuggingFlags);
}


+ (void) setDebuggingFlags:(NSUInteger) flag
{
    ClassStatic._debuggingFlags = flag;
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


- (void) dealloc
{
   [self _doneResourceStorage:&_resourceStorage];

   MulleObjCInstanceDeallocateMemory( self, _nameUTF8String);

   [super dealloc];
}


// no-op stubs — overridden by backends
- (void) _initBackend        {}
- (void) _doneBackend        {}
- (void) _initGraphicsBackend {}
- (void) _doneGraphicsBackend {}
- (void) _initFontBackend    {}
- (void) _doneFontBackend    {}



- (void) mulleGainAccessWithUniquingSet:(struct mulle_pointerset *) uniquing
{
   [super mulleGainAccessWithUniquingSet:uniquing];

   [self mulleGainAccessToResourcesWithUniquingSet:uniquing];  // -> CGContext+CGFramebuffer
}


- (void) mulleRelinquishAccessWithUniquingSet:(struct mulle_pointerset *) uniquing
{
   assert( mulle_pointerset_get( uniquing, self) == self);

   [self  mulleRelinquishAccessToResourcesWithUniquingSet:uniquing]; // -> CGContext+CGFramebuffer
   [super mulleRelinquishAccessWithUniquingSet:uniquing];
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


- (void *) backendContext
{
   return( NULL);
}


- (char *) nonLockingUTF8String
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

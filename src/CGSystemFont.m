//
//  CGSystemFont.m
//  MulleCG
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
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
#import "import-private.h"

#import "CGSystemFont.h"
#import "CGSystemFont+Private.h"


//
// The single registered platform backend, or NULL for "none". A platform
// backend registers itself from its constructor (see CGSystemFont+fontconfig.m
// etc.). Since backends register at load time, before any drawing, no locking
// is needed here.
//
static struct CGSystemFontBackend   *CGSystemFontActiveBackend;


void   CGSystemFontRegisterBackend( struct CGSystemFontBackend *backend)
{
   if( backend)
      CGSystemFontActiveBackend = backend;
}


BOOL   CGSystemFontIsAvailable( void)
{
   return( CGSystemFontActiveBackend != NULL);
}


char   *CGSystemFontBackendUTF8String( void)
{
   struct CGSystemFontBackend   *backend;

   backend = CGSystemFontActiveBackend;
   if( ! backend || ! backend->nameUTF8String)
      return( "none");
   return( backend->nameUTF8String);
}


NSUInteger   CGSystemFontEnumerate( struct CGSystemFontDescriptor **descriptors,
                                    NSUInteger *count)
{
   struct CGSystemFontBackend   *backend;

   if( descriptors)
      *descriptors = NULL;
   if( count)
      *count = 0;

   backend = CGSystemFontActiveBackend;
   if( ! backend || ! backend->enumerate || ! descriptors || ! count)
      return( 0);

   return( (*backend->enumerate)( descriptors, count));
}


BOOL   CGSystemFontResolve( struct CGSystemFontQuery *query,
                            struct CGSystemFontDescriptor *descriptor)
{
   struct CGSystemFontBackend   *backend;

   if( descriptor)
      memset( descriptor, 0, sizeof( *descriptor));

   backend = CGSystemFontActiveBackend;
   if( ! backend || ! backend->resolve || ! query || ! descriptor)
      return( NO);

   return( (*backend->resolve)( query, descriptor));
}


//
// Descriptor strings are always allocated by the backend with the default
// mulle_malloc/mulle_strdup, so we free them here uniformly. Backends must
// not allocate them any other way.
//
void   CGSystemFontDescriptorDone( struct CGSystemFontDescriptor *descriptor)
{
   if( ! descriptor)
      return;

   mulle_free( descriptor->familyUTF8String);
   mulle_free( descriptor->styleUTF8String);
   mulle_free( descriptor->pathUTF8String);
   memset( descriptor, 0, sizeof( *descriptor));
}


void   CGSystemFontDescriptorsFree( struct CGSystemFontDescriptor *descriptors,
                                    NSUInteger count)
{
   NSUInteger   i;

   if( ! descriptors)
      return;

   for( i = 0; i < count; i++)
      CGSystemFontDescriptorDone( &descriptors[ i]);
   mulle_free( descriptors);
}

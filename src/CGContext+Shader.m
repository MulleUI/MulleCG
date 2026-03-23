//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#define _POSIX_C_SOURCE 200809L // for strtok_r

#import "CGContext+Shader.h"

#import "import-private.h"

#include <ctype.h>
#include <string.h>


@implementation CGContext ( Shader)

static struct
{
   mulle_thread_mutex_t                      _shaderSourceLock;
   struct mulle_container_keyvaluecallback   _shaderSourcesCallback;
   struct mulle_map                          _registeredSources;
} Self;


// can't use +initialize in a category
+ (void) load
{
   struct mulle_allocator   *allocator;

   if( MulleObjCClassGetID( self) != @selector( CGContext))
      return;

   mulle_thread_mutex_init( &Self._shaderSourceLock);

   Self._shaderSourcesCallback.keycallback   = mulle_container_keycallback_copied_cstring;
   Self._shaderSourcesCallback.valuecallback = mulle_container_valuecallback_nonowned_pointer;

   allocator = MulleObjCClassGetAllocator( self);
   mulle_map_init( &Self._registeredSources, 0, &Self._shaderSourcesCallback, allocator);
}


+ (void) unload
{
   if( MulleObjCClassGetID( self) != @selector( CGContext))
      return;

   mulle_map_done( &Self._registeredSources);
   mulle_thread_mutex_done( &Self._shaderSourceLock);
}


- (CGShaderID) compileShaderWithShaderSources:(struct CGShaderUTF8Sources *) sources
{
   CGShaderID  shaderID;

   assert( sources);
   assert( sources->name);
   assert( sources->name[ 0]);

   shaderID = [self _compileShaderWithShaderSources:sources];
   if( shaderID)
      mulle_map_insert( &_shaderMap, sources->name, (void *) (uintptr_t) shaderID);
   return( (CGShaderID) shaderID);
}


- (void) useShader:(CGShaderID) shaderID
{
   [self _useShader:shaderID];
   _activeShader = shaderID;
}


- (CGShaderID) compileShaderWithNameUTF8String:(char *) name
{
   struct CGShaderUTF8Sources   *sources;

   assert( ! mulle_map_get( &_shaderMap, name));

   sources = [self registeredShaderSourcesForNameUTF8String:name];
   if( ! sources)
   {
      fprintf( stderr, "need a shader \"%s\" to be registered ahead of use\n", name);
      abort();
   }
   return( [self compileShaderWithShaderSources:sources]);
}


- (CGShaderID) _shaderWithNameUTF8String:(char *) name
{
   return( (CGShaderID) mulle_map_get( &_shaderMap, name));
}


- (CGShaderID) shaderWithNameUTF8String:(char *) name
{
   CGShaderID   shaderID;

   shaderID = (CGShaderID) mulle_map_get( &_shaderMap, name);
   if( ! shaderID)
      shaderID = [self compileShaderWithNameUTF8String:name];
   return( shaderID);
}


- (CGShaderID) useShaderWithNameUTF8String:(char *) name
{
   CGShaderID   shaderID;

   shaderID = [self shaderWithNameUTF8String:name];
   if( ! shaderID)
      return( 0);
   [self useShader:shaderID];
   return( shaderID);
}


- (void) deleteShaderWithNameUTF8String:(char *) name
{
   CGShaderID   shaderID;

   shaderID = (CGShaderID) mulle_map_get( &_shaderMap, name);
   [self _deleteShader: shaderID];
   if( _debuggingFlags & 0x2)
      MulleUILog( "release shader \"%s\"", name);
   mulle_map_remove( &_shaderMap, name);
}


- (void) deleteShader:(CGShaderID) shaderID
{
   void  *name;
   void  *mappedID;

   // MEMO: can't remember why its coded this way
   mulle_map_for( &_shaderMap, name, mappedID)
   {
      if( mappedID == (void *) shaderID)
         break;
   }
   if( ! name)
      abort();

   [self deleteShaderWithNameUTF8String:name];
}




- (void) deleteShaders
{
   void   *name;
   void   *shaderID;

   mulle_map_for( &_shaderMap, name, shaderID)
   {
      if( _debuggingFlags & 0x2)
         MulleUILog( "release shader \"%s\"", name);
      [self _deleteShader:(CGShaderID) (uintptr_t) shaderID];
   }

   mulle_map_reset( &_shaderMap);
}


static UIGraphicsBackend   defaultBackends[] =
{
   UIGraphicsBackendDefault,
   UIGraphicsBackendNone
};


+ (void) registerShaderSources:(struct CGShaderUTF8Sources *) sources
             forNameUTF8String:(char *) nameUTF8String
{
   UIGraphicsBackend   *backends;
   char                *key;
   char                *prefix;

   if( ! nameUTF8String)
      nameUTF8String = sources->name;

   assert( nameUTF8String);

   backends = sources->backends ? sources->backends : defaultBackends;

   mulle_buffer_do( buffer)
   {
      while( *backends != UIGraphicsBackendNone)
      {
         mulle_buffer_reset( buffer);
         prefix = UIGraphicsBackendUTF8String( *backends);
         assert( ! strcmp( prefix, "???"));

         mulle_buffer_sprintf( buffer, "%s__%s", prefix, nameUTF8String);
         key = mulle_buffer_get_string( buffer);
         mulle_thread_mutex_do( Self._shaderSourceLock)
         {
            mulle_map_insert( &Self._registeredSources, key, sources);
         }
         ++backends;
      }
   }
}


+ (void) registerShaderSources:(struct CGShaderUTF8Sources *) sources
{
   [self registerShaderSources:sources
             forNameUTF8String:NULL];
}


- (struct CGShaderUTF8Sources *)
   registeredShaderSourcesForNameUTF8String:(char *) nameUTF8String
{
   struct CGShaderUTF8Sources   *sources;
   char                         *prefix;
   UIGraphicsBackend            *backends;
   auto UIGraphicsBackend       targetBackends[ 3] =
                                {
                                   [self backend],
                                   UIGraphicsBackendDefault,
                                   UIGraphicsBackendNone
                                };

   backends = targetBackends;
   mulle_buffer_do( buffer)
   {
      do
      {
         prefix = UIGraphicsBackendUTF8String( *backends);
         mulle_buffer_sprintf( buffer, "%s__%s", prefix, nameUTF8String);

         mulle_thread_mutex_do( Self._shaderSourceLock)
         {
            sources = mulle_map_get( &Self._registeredSources, nameUTF8String);
         }
      }
      while( ! sources && *++backends != UIGraphicsBackendNone);
   }
   return( sources);
}


@end

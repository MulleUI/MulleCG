//
//  CGSystemFont+Android.m
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
//
// Android NDK backend for CGSystemFont. Active on Android API >= 29.
//
// Uses the NDK font API: ASystemFontIterator (android/system_fonts.h) for
// enumeration and AFontMatcher (android/font_matcher.h) for resolution. Both
// are C and part of libandroid; the returned file paths are absolute and can
// be fed straight into the MulleCG file loader.
//
// Notes and limitations:
//
// * API 29 gate: the ASystemFont* / AFont* API exists only since Android 10
//   (API 29). On older Android there is no NDK path; ship fonts (status quo).
//   The file is gated on __ANDROID__ only — the *headers* ship with the NDK
//   regardless of minSdkVersion, so a pre-29 device is a runtime matter: the
//   libandroid symbols resolve only on API 29+. Target API >= 29 for system
//   fonts.
//
// * Family names: ASystemFontIterator exposes no family name, only the file
//   path (+ weight/italic/collection index/locale). Enumeration therefore
//   derives familyUTF8String from the file name (a stable, unique-enough
//   identifier), which is NOT the typographic family. Resolve() is the
//   authoritative path: AFontMatcher knows the real families.
//
// Define MULLE_CG_NO_ANDROID to force this backend off.
//
#import "import-private.h"

#if ! defined( MULLE_CG_NO_ANDROID) && defined( __ANDROID__)
# define MULLE_CG_HAVE_ANDROID
#endif

#if defined( MULLE_CG_HAVE_ANDROID)

#import "CGSystemFont+Private.h"

#include <android/font.h>
#include <android/font_matcher.h>
#include <android/system_fonts.h>

#include <string.h>


static NSInteger   CGSystemFontWeightFromAndroid( uint16_t weight)
{
   if( weight <= 0)
      return( CGSystemFontWeightUnknown);
   if( weight < 100)
      return( CGSystemFontWeightThin);
   if( weight > 900)   // AFont_getWeight may go up to 1000
      return( CGSystemFontWeightBlack);
   return( (NSInteger) weight);
}


//
// Best-effort family identifier for enumeration: the file name without
// directory and extension. ASystemFontIterator does not expose real family
// names; see the header comment. Caller frees with mulle_free.
//
static char   *CGSystemFontCopyFamilyNameFromFilePath( const char *path)
{
   const char   *base;
   char         *name;
   char         *extension;

   if( ! path || ! path[ 0])
      return( NULL);

   base = strrchr( path, '/');
   base = base ? base + 1 : path;

   name = mulle_strdup( base);
   extension = strrchr( name, '.');
   if( extension)
      *extension = '\0';
   return( name);
}


//
// Fill one descriptor from an AFont. `familyUTF8String` is owned by the
// caller; on success descriptor->familyUTF8String is a mulle_ duplicate.
//
static BOOL   CGSystemFontDescriptorFromAFont( AFont *font,
                                               const char *familyUTF8String,
                                               struct CGSystemFontDescriptor *descriptor)
{
   const char   *path;
   char         *pathCopy;

   memset( descriptor, 0, sizeof( *descriptor));

   if( ! familyUTF8String || ! familyUTF8String[ 0])
      return( NO);

   path = AFont_getFontFilePath( font);
   if( ! path)
      return( NO);

   pathCopy = mulle_strdup( path);

   descriptor->familyUTF8String = mulle_strdup( familyUTF8String);
   descriptor->styleUTF8String  = NULL;   // not exposed by the NDK API
   descriptor->pathUTF8String   = pathCopy;
   descriptor->faceIndex        = AFont_getCollectionIndex( font);
   descriptor->weight           = CGSystemFontWeightFromAndroid( AFont_getWeight( font));
   descriptor->italic           = AFont_isItalic( font) ? YES : NO;
   return( YES);
}


static NSUInteger   CGSystemFontAndroidEnumerate( struct CGSystemFontDescriptor **descriptorsp,
                                                  NSUInteger *countp)
{
   struct CGSystemFontDescriptor   *descriptors;
   ASystemFontIterator             *iterator;
   char                            *familyName;
   AFont                           *font;
   NSUInteger                      n;

   *descriptorsp = NULL;
   *countp       = 0;

   //
   // First pass: count fonts so the array can be allocated exactly. The
   // iterator can be reopened; this stays a cold path.
   //
   n        = 0;
   iterator = ASystemFontIterator_open();
   if( ! iterator)
      return( 0);
   while( (font = ASystemFontIterator_next( iterator)) != NULL)
   {
      n++;
      AFont_close( font);
   }
   ASystemFontIterator_close( iterator);

   if( n == 0)
      return( 0);

   descriptors = mulle_malloc( sizeof( *descriptors) * n);

   //
   // Second pass: fill descriptors, skipping fonts without a usable path.
   //
   n        = 0;
   iterator = ASystemFontIterator_open();
   if( ! iterator)
   {
      mulle_free( descriptors);
      return( 0);
   }
   while( (font = ASystemFontIterator_next( iterator)) != NULL)
   {
      familyName = CGSystemFontCopyFamilyNameFromFilePath( AFont_getFontFilePath( font));
      if( familyName)
      {
         if( CGSystemFontDescriptorFromAFont( font, familyName, &descriptors[ n]))
            n++;
         mulle_free( familyName);
      }
      AFont_close( font);
   }
   ASystemFontIterator_close( iterator);

   if( n == 0)
   {
      mulle_free( descriptors);
      return( 0);
   }

   *descriptorsp = descriptors;
   *countp       = n;
   return( n);
}


static BOOL   CGSystemFontAndroidResolve( struct CGSystemFontQuery *query,
                                          struct CGSystemFontDescriptor *descriptor)
{
   AFontMatcher   *matcher;
   AFont          *font;
   uint16_t       weight;
   BOOL           ok;

   if( ! query->familyUTF8String)
      return( NO);

   matcher = AFontMatcher_create();
   if( ! matcher)
      return( NO);

   weight = (query->weight > 0) ? (uint16_t) query->weight : 400;
   AFontMatcher_setStyle( matcher, weight, (query->italic != NO));

   //
   // familyName is a generic family ("sans-serif", "serif", "monospace", ...)
   // or a concrete family; text may be NULL (no text-run shaping requested).
   //
   font = AFontMatcher_match( matcher, query->familyUTF8String, NULL, 0, NULL);
   AFontMatcher_destroy( matcher);

   if( ! font)
      return( NO);

   ok = CGSystemFontDescriptorFromAFont( font, query->familyUTF8String, descriptor);
   AFont_close( font);
   return( ok);
}


static struct CGSystemFontBackend   CGSystemFontAndroidBackend =
{
   .nameUTF8String = "android",
   .enumerate      = CGSystemFontAndroidEnumerate,
   .resolve        = CGSystemFontAndroidResolve
};


MULLE_C_CONSTRUCTOR( CGSystemFontAndroidRegister)
static void   CGSystemFontAndroidRegister( void)
{
   CGSystemFontRegisterBackend( &CGSystemFontAndroidBackend);
}

#endif // MULLE_CG_HAVE_ANDROID

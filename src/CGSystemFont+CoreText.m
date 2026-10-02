//
//  CGSystemFont+CoreText.m
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
// Core Text backend for CGSystemFont. Active on macOS and iOS.
//
// Core Text is guaranteed by the OS, so per the linking policy this backend
// is linked statically against the CoreText framework (no dlopen). It is
// gated on __APPLE__; define MULLE_CG_NO_CORETEXT to force it off.
//
// Notes and limitations:
//
// * Collection files: Core Text resolves a face inside a .ttc internally and
//   does not expose the face index via public API. `faceIndex` is therefore
//   always 0 here, and a resolved/enumerated .ttc will hand back the file
//   path only. Loading still hits the known "font collections" limitation of
//   the MulleCG loader (whole file loaded as one face).
//
// * iOS: the same API works, but the file URL may point into a sandbox
//   restricted area (/System/Library/Fonts). If POSIX open of the path fails
//   on iOS, the data-blob route (CTFontManagerCreateFontDescriptorFromData)
//   is the follow-up; macOS is the primary target today.
//
// * Weight: kCTFontWeightTrait is roughly in [-1, 1] with 0 == regular. There
//   is no public linear mapping to the OpenType scale, so the conversion here
//   is an approximation anchored at regular == 400 (see
//   CGSystemFontWeightFromCoreTextTrait).
//
#import "import-private.h"

#if ! defined( MULLE_CG_NO_CORETEXT) && defined( __APPLE__)
# define MULLE_CG_HAVE_CORETEXT
#endif

#if defined( MULLE_CG_HAVE_CORETEXT)

#import "CGSystemFont+Private.h"

#include <CoreText/CoreText.h>

#include <math.h>


//
// Copy a CFString as UTF8 into a freshly mulle_malloc'ed buffer. Returns NULL
// for a NULL/empty string or on conversion failure. Callers free with
// mulle_free.
//
static char   *CGSystemFontCopyUTF8StringFromCFString( CFStringRef string)
{
   char        *buf;
   const char  *cstring;
   CFIndex     length;

   if( ! string)
      return( NULL);

   cstring = CFStringGetCStringPtr( string, kCFStringEncodingUTF8);
   if( cstring)
      return( mulle_strdup( (char *) cstring));

   length = CFStringGetMaximumSizeForEncoding( CFStringGetLength( string),
                                               kCFStringEncodingUTF8);
   if( length < 0)
      return( NULL);

   buf = mulle_malloc( (size_t) length + 1);
   if( ! CFStringGetCString( string, buf, length + 1, kCFStringEncodingUTF8))
   {
      mulle_free( buf);
      return( NULL);
   }
   return( buf);
}


//
// Absolute POSIX path of the file behind a font descriptor, or NULL when the
// descriptor has no file (e.g. a data-backed font).
//
static char   *CGSystemFontCopyFilePathFromFontDescriptor( CTFontDescriptorRef fontDescriptor)
{
   CFStringRef   filePathString;
   char          *result;
   CFURLRef      url;

   result = NULL;
   url    = CTFontDescriptorCopyAttribute( fontDescriptor, kCTFontURLAttribute);
   if( url)
   {
      filePathString = CFURLCopyFileSystemPath( url, kCFURLPOSIXPathStyle);
      if( filePathString)
      {
         result = CGSystemFontCopyUTF8StringFromCFString( filePathString);
         CFRelease( filePathString);
      }
      CFRelease( url);
   }
   return( result);
}


//
// Approximate mapping of the Core Text weight trait (roughly [-1, 1], 0 ==
// regular) to the OpenType 100..900 scale. Piecewise linear, anchored so a
// regular font (trait 0) is 400; -1.0 -> 100 and 1.0 -> 900 at the extremes.
//
static NSInteger   CGSystemFontWeightFromCoreTextTrait( double weightTrait)
{
   double   openTypeWeight;

   if( ! isfinite( weightTrait))
      return( CGSystemFontWeightUnknown);

   if( weightTrait < -1.0)
      weightTrait = -1.0;
   else
      if( weightTrait > 1.0)
         weightTrait = 1.0;

   if( weightTrait <= 0.0)
      openTypeWeight = 400.0 + weightTrait * 300.0;   // -1.0 -> 100, 0.0 -> 400
   else
      openTypeWeight = 400.0 + weightTrait * 500.0;   //  0.0 -> 400, 1.0 -> 900

   return( (NSInteger) lround( openTypeWeight));
}


//
// Fill one descriptor from a Core Text font descriptor. Returns NO (and leaves
// nothing allocated) if there is no usable family+file. Strings are mulle_-
// allocated so the dispatcher can free them uniformly.
//
static BOOL   CGSystemFontDescriptorFromFontDescriptor( CTFontDescriptorRef fontDescriptor,
                                                        struct CGSystemFontDescriptor *descriptor)
{
   CFDictionaryRef      traits;
   CTFontSymbolicTraits symbolicTraits;
   CFStringRef          familyString;
   CFStringRef          styleString;
   CFNumberRef          slantNumber;
   CFNumberRef          weightNumber;
   double               slantTrait;
   double               weightTrait;
   NSInteger            weight;
   char                 *family;
   char                 *path;
   char                 *style;

   memset( descriptor, 0, sizeof( *descriptor));

   familyString = CTFontDescriptorCopyAttribute( fontDescriptor, kCTFontFamilyNameAttribute);
   family       = CGSystemFontCopyUTF8StringFromCFString( familyString);
   if( familyString)
      CFRelease( familyString);

   path = CGSystemFontCopyFilePathFromFontDescriptor( fontDescriptor);
   if( ! family || ! path)
   {
      mulle_free( family);
      mulle_free( path);
      return( NO);
   }

   styleString = CTFontDescriptorCopyAttribute( fontDescriptor, kCTFontStyleNameAttribute);
   style       = CGSystemFontCopyUTF8StringFromCFString( styleString);
   if( styleString)
      CFRelease( styleString);

   symbolicTraits = CTFontDescriptorGetSymbolicTraits( fontDescriptor);

   weight       = CGSystemFontWeightUnknown;
   slantTrait   = 0.0;
   traits       = CTFontDescriptorCopyAttribute( fontDescriptor, kCTFontTraitsAttribute);
   if( traits)
   {
      weightNumber = (CFNumberRef) CFDictionaryGetValue( traits, kCTFontWeightTrait);
      if( weightNumber)
         if( CFNumberGetValue( weightNumber, kCFNumberDoubleType, &weightTrait))
            weight = CGSystemFontWeightFromCoreTextTrait( weightTrait);

      slantNumber = (CFNumberRef) CFDictionaryGetValue( traits, kCTFontSlantTrait);
      if( slantNumber)
         CFNumberGetValue( slantNumber, kCFNumberDoubleType, &slantTrait);

      CFRelease( traits);
   }

   descriptor->familyUTF8String = family;
   descriptor->styleUTF8String  = style;
   descriptor->pathUTF8String   = path;
   descriptor->faceIndex        = 0;   // Core Text does not expose .ttc face indices
   descriptor->weight           = weight;
   descriptor->italic           = ((symbolicTraits & kCTFontTraitItalic) || slantTrait > 0.0) ? YES : NO;
   return( YES);
}


static NSUInteger   CGSystemFontCoreTextEnumerate( struct CGSystemFontDescriptor **descriptorsp,
                                                   NSUInteger *countp)
{
   CTFontCollectionRef            collection;
   struct CGSystemFontDescriptor  *descriptors;
   CFArrayRef                     fontDescriptors;
   CFIndex                        i;
   CFIndex                        n;
   NSUInteger                     nfound;

   *descriptorsp = NULL;
   *countp       = 0;

   collection = CTFontCollectionCreateFromAvailableFonts( NULL);
   if( ! collection)
      return( 0);

   fontDescriptors = CTFontCollectionCreateMatchingFontDescriptors( collection);
   CFRelease( collection);

   if( ! fontDescriptors)
      return( 0);

   n = CFArrayGetCount( fontDescriptors);
   if( n <= 0)
   {
      CFRelease( fontDescriptors);
      return( 0);
   }

   descriptors = mulle_malloc( sizeof( *descriptors) * (NSUInteger) n);
   nfound      = 0;
   for( i = 0; i < n; i++)
   {
      if( CGSystemFontDescriptorFromFontDescriptor(
             (CTFontDescriptorRef) CFArrayGetValueAtIndex( fontDescriptors, i),
             &descriptors[ nfound]))
         nfound++;
   }

   CFRelease( fontDescriptors);

   if( nfound == 0)
   {
      mulle_free( descriptors);
      return( 0);
   }

   *descriptorsp = descriptors;
   *countp       = nfound;
   return( nfound);
}


static BOOL   CGSystemFontCoreTextResolve( struct CGSystemFontQuery *query,
                                           struct CGSystemFontDescriptor *descriptor)
{
   CFMutableDictionaryRef   attributes;
   CTFontDescriptorRef      baseDescriptor;
   CFStringRef              familyString;
   CTFontDescriptorRef      matchDescriptor;
   CFNumberRef              number;
   BOOL                     ok;
   SInt32                   symbolic;
   CFMutableDictionaryRef   traits;

   if( ! query->familyUTF8String)
      return( NO);

   attributes = CFDictionaryCreateMutable( NULL, 0,
                                           &kCFTypeDictionaryKeyCallBacks,
                                           &kCFTypeDictionaryValueCallBacks);
   if( ! attributes)
      return( NO);

   familyString = CFStringCreateWithCString( NULL, query->familyUTF8String,
                                             kCFStringEncodingUTF8);
   if( ! familyString)
   {
      CFRelease( attributes);
      return( NO);
   }
   CFDictionarySetValue( attributes, kCTFontFamilyNameAttribute, familyString);
   CFRelease( familyString);

   //
   // Ask for bold/italic variants via the symbolic traits (the classic way to
   // request a variant match). Core Text falls back to the closest available
   // face when the exact variant is missing.
   //
   symbolic = 0;
   if( query->italic)
      symbolic |= kCTFontTraitItalic;
   if( query->weight >= CGSystemFontWeightBold)
      symbolic |= kCTFontTraitBold;

   if( symbolic)
   {
      traits = CFDictionaryCreateMutable( NULL, 0,
                                          &kCFTypeDictionaryKeyCallBacks,
                                          &kCFTypeDictionaryValueCallBacks);
      if( traits)
      {
         number = CFNumberCreate( NULL, kCFNumberSInt32Type, &symbolic);
         CFDictionarySetValue( traits, kCTFontSymbolicTrait, number);
         if( number)
            CFRelease( number);

         CFDictionarySetValue( attributes, kCTFontTraitsAttribute, traits);
         CFRelease( traits);
      }
   }

   baseDescriptor = CTFontDescriptorCreateWithAttributes( attributes);
   CFRelease( attributes);
   if( ! baseDescriptor)
      return( NO);

   matchDescriptor = CTFontDescriptorCreateMatchingFontDescriptor( baseDescriptor, NULL);
   CFRelease( baseDescriptor);
   if( ! matchDescriptor)
      return( NO);

   ok = CGSystemFontDescriptorFromFontDescriptor( matchDescriptor, descriptor);
   CFRelease( matchDescriptor);
   return( ok);
}


static struct CGSystemFontBackend   CGSystemFontCoreTextBackend =
{
   .nameUTF8String = "coretext",
   .enumerate      = CGSystemFontCoreTextEnumerate,
   .resolve        = CGSystemFontCoreTextResolve
};


MULLE_C_CONSTRUCTOR( CGSystemFontCoreTextRegister)
static void   CGSystemFontCoreTextRegister( void)
{
   CGSystemFontRegisterBackend( &CGSystemFontCoreTextBackend);
}

#endif // MULLE_CG_HAVE_CORETEXT

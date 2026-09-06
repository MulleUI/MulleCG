//
//  CGSystemFont+fontconfig.m
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
// fontconfig backend for CGSystemFont. Active on Linux and FreeBSD. The
// build restricts linking of libfontconfig to those platforms (see the
// `fontconfig` library entry, marked only-platform-linux/freebsd), so we
// gate the source on the same platforms here.
//
// Define MULLE_CG_NO_FONTCONFIG to force this backend off (e.g. a Linux
// build without fontconfig installed); the "none" backend then stays in
// effect and shipped fonts remain the fallback.
//
#import "import-private.h"

#if ! defined( MULLE_CG_NO_FONTCONFIG) && (defined( __linux__) || defined( __FreeBSD__))
# define MULLE_CG_HAVE_FONTCONFIG
#endif

#if defined( MULLE_CG_HAVE_FONTCONFIG)

#import "CGSystemFont+Private.h"

#include <fontconfig/fontconfig.h>


//
// Map a fontconfig weight (FC_WEIGHT_*, roughly 0..215) to the OpenType
// 100..900 scale used by CGSystemFontWeight. fontconfig provides
// FcWeightToOpenType since 2.11.91; fall back to a small table otherwise.
//
static NSInteger   CGSystemFontWeightFromFcWeight( int fcWeight)
{
#ifdef FC_WEIGHT_REGULAR
   int   ot;

   ot = FcWeightToOpenType( fcWeight);
   if( ot > 0)
      return( (NSInteger) ot);
#endif
   //
   // Fallback: coarse bucketing on the classic fontconfig scale.
   //
   if( fcWeight <= 40)     return( CGSystemFontWeightThin);
   if( fcWeight <= 50)     return( CGSystemFontWeightExtraLight);
   if( fcWeight <= 55)     return( CGSystemFontWeightLight);
   if( fcWeight <= 80)     return( CGSystemFontWeightRegular);
   if( fcWeight <= 100)    return( CGSystemFontWeightMedium);
   if( fcWeight <= 180)    return( CGSystemFontWeightSemiBold);
   if( fcWeight <= 200)    return( CGSystemFontWeightBold);
   if( fcWeight <= 205)    return( CGSystemFontWeightExtraBold);
   return( CGSystemFontWeightBlack);
}


//
// Copy an FcPattern string object into a freshly mulle_malloc'ed UTF8 string.
// Returns NULL if absent. The dispatcher frees these with mulle_free.
//
static char   *CGSystemFontCopyPatternString( FcPattern *pattern, const char *object)
{
   FcChar8   *value;

   if( FcPatternGetString( pattern, object, 0, &value) != FcResultMatch)
      return( NULL);
   if( ! value)
      return( NULL);
   return( mulle_strdup( (char *) value));
}


static NSUInteger   CGSystemFontCopyPatternInteger( FcPattern *pattern,
                                                    const char *object,
                                                    NSUInteger defaultValue)
{
   int   value;

   if( FcPatternGetInteger( pattern, object, 0, &value) != FcResultMatch)
      return( defaultValue);
   return( (NSUInteger) value);
}


//
// Fill one descriptor from an FcPattern. Returns NO (and leaves nothing
// allocated) if the pattern has no usable family+file.
//
static BOOL   CGSystemFontDescriptorFromPattern( FcPattern *pattern,
                                                 struct CGSystemFontDescriptor *descriptor)
{
   char   *family;
   char   *path;
   char   *style;
   int    slant;

   memset( descriptor, 0, sizeof( *descriptor));

   family = CGSystemFontCopyPatternString( pattern, FC_FAMILY);
   path   = CGSystemFontCopyPatternString( pattern, FC_FILE);
   if( ! family || ! path)
   {
      mulle_free( family);
      mulle_free( path);
      return( NO);
   }

   style = CGSystemFontCopyPatternString( pattern, FC_STYLE);

   slant = FC_SLANT_ROMAN;
   FcPatternGetInteger( pattern, FC_SLANT, 0, &slant);

   descriptor->familyUTF8String = family;
   descriptor->styleUTF8String  = style;
   descriptor->pathUTF8String   = path;
   descriptor->faceIndex        = CGSystemFontCopyPatternInteger( pattern, FC_INDEX, 0);
   descriptor->weight           = CGSystemFontWeightFromFcWeight(
                                     (int) CGSystemFontCopyPatternInteger( pattern, FC_WEIGHT, 80));
   descriptor->italic           = (slant != FC_SLANT_ROMAN) ? YES : NO;
   return( YES);
}


static NSUInteger   CGSystemFontFontconfigEnumerate( struct CGSystemFontDescriptor **descriptorsp,
                                                     NSUInteger *countp)
{
   FcObjectSet                     *objectSet;
   FcPattern                       *pattern;
   FcFontSet                       *fontSet;
   struct CGSystemFontDescriptor   *descriptors;
   NSUInteger                      n;
   int                             i;

   *descriptorsp = NULL;
   *countp       = 0;

   if( ! FcInit())
      return( 0);

   pattern   = FcPatternCreate();
   objectSet = FcObjectSetBuild( FC_FAMILY, FC_STYLE, FC_FILE,
                                 FC_INDEX, FC_WEIGHT, FC_SLANT,
                                 (char *) NULL);
   fontSet   = FcFontList( NULL, pattern, objectSet);

   FcObjectSetDestroy( objectSet);
   FcPatternDestroy( pattern);

   if( ! fontSet)
      return( 0);

   if( fontSet->nfont <= 0)
   {
      FcFontSetDestroy( fontSet);
      return( 0);
   }

   descriptors = mulle_malloc( sizeof( *descriptors) * (NSUInteger) fontSet->nfont);
   n           = 0;
   for( i = 0; i < fontSet->nfont; i++)
   {
      if( CGSystemFontDescriptorFromPattern( fontSet->fonts[ i], &descriptors[ n]))
         n++;
   }

   FcFontSetDestroy( fontSet);

   if( n == 0)
   {
      mulle_free( descriptors);
      return( 0);
   }

   *descriptorsp = descriptors;
   *countp       = n;
   return( n);
}


static BOOL   CGSystemFontFontconfigResolve( struct CGSystemFontQuery *query,
                                             struct CGSystemFontDescriptor *descriptor)
{
   FcPattern   *pattern;
   FcPattern   *match;
   FcResult    result;
   BOOL        ok;

   if( ! query->familyUTF8String)
      return( NO);

   if( ! FcInit())
      return( NO);

   pattern = FcPatternCreate();
   FcPatternAddString( pattern, FC_FAMILY, (const FcChar8 *) query->familyUTF8String);
   if( query->weight)
      FcPatternAddInteger( pattern, FC_WEIGHT, FcWeightFromOpenType( (int) query->weight));
   if( query->italic)
      FcPatternAddInteger( pattern, FC_SLANT, FC_SLANT_ITALIC);

   FcConfigSubstitute( NULL, pattern, FcMatchPattern);
   FcDefaultSubstitute( pattern);

   match = FcFontMatch( NULL, pattern, &result);
   FcPatternDestroy( pattern);

   if( ! match)
      return( NO);

   ok = CGSystemFontDescriptorFromPattern( match, descriptor);
   FcPatternDestroy( match);
   return( ok);
}


static struct CGSystemFontBackend   CGSystemFontFontconfigBackend =
{
   .nameUTF8String = "fontconfig",
   .enumerate      = CGSystemFontFontconfigEnumerate,
   .resolve        = CGSystemFontFontconfigResolve
};


MULLE_C_CONSTRUCTOR( CGSystemFontFontconfigRegister)
static void   CGSystemFontFontconfigRegister( void)
{
   CGSystemFontRegisterBackend( &CGSystemFontFontconfigBackend);
}

#endif // MULLE_CG_HAVE_FONTCONFIG

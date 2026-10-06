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
// fontconfig backend for CGSystemFont. Active on Linux and FreeBSD.
//
// fontconfig is deliberately NOT linked. The backend dlopens
// "libfontconfig.so.1" (fallback "libfontconfig.so") at load time and binds
// the functions it uses into a static vtable. Only if the library is present
// AND every symbol resolves is the backend registered; otherwise the "none"
// backend stays in effect and shipped fonts remain the fallback. This keeps
// a MulleCG app loadable on a host that has no fontconfig installed.
//
// Prototypes and constants still come from <fontconfig/fontconfig.h>, which
// is a compile-time-only dependency (no -lfontconfig). If the dev headers are
// missing the gate below compiles this file to nothing.
//
// Define MULLE_CG_NO_FONTCONFIG to force this backend off (e.g. a Linux build
// without fontconfig installed); the "none" backend then stays in effect.
//
#import "import-private.h"

#if ! defined( MULLE_CG_NO_FONTCONFIG) && (defined( __linux__) || defined( __FreeBSD__))
# if defined( __has_include)
#  if __has_include( <fontconfig/fontconfig.h>)
#   define MULLE_CG_HAVE_FONTCONFIG
#  endif
# else
#  define MULLE_CG_HAVE_FONTCONFIG
# endif
#endif

#if defined( MULLE_CG_HAVE_FONTCONFIG)

#import "CGSystemFont+Private.h"

#include <fontconfig/fontconfig.h>

#include <mulle-dlfcn/mulle-dlfcn.h>   // dlopen/dlsym/dlclose, portable


//
// Bindings: one function pointer per fontconfig function used below, filled
// in by CGSystemFontFontconfigLoad(). Signatures match fontconfig.h exactly.
// The call sites go through these pointers instead of calling fontconfig
// directly, so nothing needs to be linked against libfontconfig.
//
struct CGSystemFontFontconfigBindings
{
   FcBool      (*FcConfigSubstitute)( FcConfig *config,
                                      FcPattern *pattern,
                                      FcMatchKind kind);
   void        (*FcDefaultSubstitute)( FcPattern *pattern);
   FcFontSet   *(*FcFontList)( FcConfig *config,
                               FcPattern *pattern,
                               FcObjectSet *objectSet);
   FcPattern   *(*FcFontMatch)( FcConfig *config,
                                FcPattern *pattern,
                                FcResult *result);
   void        (*FcFontSetDestroy)( FcFontSet *fontSet);
   FcBool      (*FcInit)( void);
   void        (*FcFini)( void);
   FcObjectSet *(*FcObjectSetBuild)( const char *first, ...);
   void        (*FcObjectSetDestroy)( FcObjectSet *objectSet);
   FcBool      (*FcPatternAddInteger)( FcPattern *pattern,
                                       const char *object,
                                       int value);
   FcBool      (*FcPatternAddString)( FcPattern *pattern,
                                      const char *object,
                                      const FcChar8 *value);
   FcPattern   *(*FcPatternCreate)( void);
   void        (*FcPatternDestroy)( FcPattern *pattern);
   FcResult    (*FcPatternGetInteger)( const FcPattern *pattern,
                                       const char *object,
                                       int id,
                                       int *value);
   FcResult    (*FcPatternGetString)( const FcPattern *pattern,
                                      const char *object,
                                      int id,
                                      FcChar8 **value);
   int         (*FcWeightFromOpenType)( int openTypeWeight);
   int         (*FcWeightToOpenType)( int fcWeight);
};


static struct CGSystemFontFontconfigBindings   CGSystemFontFontconfigBindings;

static void                                    *CGSystemFontFontconfigLibrary;

static BOOL                                    CGSystemFontFontconfigLoadAttempted;

static BOOL                                    CGSystemFontFontconfigInitialized;


// return TRUE if the fontconfig backend is ready to use
static BOOL   CGSystemFontFontconfigLoad( void)
{
   void   *library;
   void   *symbol;

   if( CGSystemFontFontconfigLibrary)
      return( YES);
   if( CGSystemFontFontconfigLoadAttempted)
      return( NO);
   CGSystemFontFontconfigLoadAttempted = YES;

   library = dlopen( "libfontconfig.so.1", RTLD_NOW);
   if( ! library)
      library = dlopen( "libfontconfig.so", RTLD_NOW);
   if( ! library)
      return( NO);

   //
   // Bind every function we call. On any miss close the library again and
   // stay "none"; partial bindings would crash later.
   //
#define CG_SYSTEM_FONT_FONTCONFIG_BIND( _name)                \
   do                                                         \
   {                                                          \
      symbol = dlsym( library, #_name);                       \
      if( ! symbol)                                           \
      {                                                       \
         dlclose( library);                                   \
         return( NO);                                         \
      }                                                       \
      *(void **) &CGSystemFontFontconfigBindings._name = symbol;  \
   }                                                          \
   while( 0)

   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcConfigSubstitute);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcDefaultSubstitute);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcFontList);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcFontMatch);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcFontSetDestroy);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcInit);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcFini);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcObjectSetBuild);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcObjectSetDestroy);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcPatternAddInteger);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcPatternAddString);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcPatternCreate);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcPatternDestroy);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcPatternGetInteger);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcPatternGetString);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcWeightFromOpenType);
   CG_SYSTEM_FONT_FONTCONFIG_BIND( FcWeightToOpenType);

#undef CG_SYSTEM_FONT_FONTCONFIG_BIND

   CGSystemFontFontconfigLibrary = library;   // never dlclose'ed (process lifetime)
   return( YES);
}


//
// fontconfig keeps a process-global configuration that is only released by
// FcFini(). Call FcInit() at most once and remember it, so the destructor
// below knows whether there is anything to clean up. This keeps valgrind
// happy: without FcFini the parsed config (via libexpat) stays "definitely
// lost" for the lifetime of the process.
//
static BOOL   CGSystemFontFontconfigInit( void)
{
   if( CGSystemFontFontconfigInitialized)
      return( YES);

   if( ! CGSystemFontFontconfigBindings.FcInit())
      return( NO);

   CGSystemFontFontconfigInitialized = YES;
   return( YES);
}


MULLE_C_DESTRUCTOR( CGSystemFontFontconfigUnload)
static void   CGSystemFontFontconfigUnload( void)
{
   if( ! CGSystemFontFontconfigInitialized)
      return;

   CGSystemFontFontconfigInitialized = NO;
   CGSystemFontFontconfigBindings.FcFini();
}


//
// Map a fontconfig weight (FC_WEIGHT_*, roughly 0..215) to the OpenType
// 100..900 scale used by CGSystemFontWeight. fontconfig provides
// FcWeightToOpenType since 2.11.91; fall back to a small table otherwise.
//
static NSInteger   CGSystemFontWeightFromFcWeight( int fcWeight)
{
#ifdef FC_WEIGHT_REGULAR
   int   ot;

   ot = CGSystemFontFontconfigBindings.FcWeightToOpenType( fcWeight);
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

   if( CGSystemFontFontconfigBindings.FcPatternGetString( pattern, object, 0, &value) != FcResultMatch)
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

   if( CGSystemFontFontconfigBindings.FcPatternGetInteger( pattern, object, 0, &value) != FcResultMatch)
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
   CGSystemFontFontconfigBindings.FcPatternGetInteger( pattern, FC_SLANT, 0, &slant);

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

   if( ! CGSystemFontFontconfigInit())
      return( 0);

   pattern   = CGSystemFontFontconfigBindings.FcPatternCreate();
   objectSet = CGSystemFontFontconfigBindings.FcObjectSetBuild( FC_FAMILY, FC_STYLE, FC_FILE,
                                                                FC_INDEX, FC_WEIGHT, FC_SLANT,
                                                                (char *) NULL);
   fontSet   = CGSystemFontFontconfigBindings.FcFontList( NULL, pattern, objectSet);

   CGSystemFontFontconfigBindings.FcObjectSetDestroy( objectSet);
   CGSystemFontFontconfigBindings.FcPatternDestroy( pattern);

   if( ! fontSet)
      return( 0);

   if( fontSet->nfont <= 0)
   {
      CGSystemFontFontconfigBindings.FcFontSetDestroy( fontSet);
      return( 0);
   }

   descriptors = mulle_malloc( sizeof( *descriptors) * (NSUInteger) fontSet->nfont);
   n           = 0;
   for( i = 0; i < fontSet->nfont; i++)
   {
      if( CGSystemFontDescriptorFromPattern( fontSet->fonts[ i], &descriptors[ n]))
         n++;
   }

   CGSystemFontFontconfigBindings.FcFontSetDestroy( fontSet);

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

   if( ! CGSystemFontFontconfigInit())
      return( NO);

   pattern = CGSystemFontFontconfigBindings.FcPatternCreate();
   CGSystemFontFontconfigBindings.FcPatternAddString( pattern, FC_FAMILY, (const FcChar8 *) query->familyUTF8String);
   if( query->weight)
      CGSystemFontFontconfigBindings.FcPatternAddInteger( pattern, FC_WEIGHT, CGSystemFontFontconfigBindings.FcWeightFromOpenType( (int) query->weight));
   if( query->italic)
      CGSystemFontFontconfigBindings.FcPatternAddInteger( pattern, FC_SLANT, FC_SLANT_ITALIC);

   CGSystemFontFontconfigBindings.FcConfigSubstitute( NULL, pattern, FcMatchPattern);
   CGSystemFontFontconfigBindings.FcDefaultSubstitute( pattern);

   match = CGSystemFontFontconfigBindings.FcFontMatch( NULL, pattern, &result);
   CGSystemFontFontconfigBindings.FcPatternDestroy( pattern);

   if( ! match)
      return( NO);

   ok = CGSystemFontDescriptorFromPattern( match, descriptor);
   CGSystemFontFontconfigBindings.FcPatternDestroy( match);
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
   if( CGSystemFontFontconfigLoad())
      CGSystemFontRegisterBackend( &CGSystemFontFontconfigBackend);
}

#endif // MULLE_CG_HAVE_FONTCONFIG

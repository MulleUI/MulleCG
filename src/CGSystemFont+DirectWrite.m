//
//  CGSystemFont+DirectWrite.m
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
// DirectWrite backend for CGSystemFont. Active on Windows.
//
// DirectWrite is guaranteed by the OS (Windows 7+), but the mingw-w64
// toolchains used for cross builds often ship neither dwrite.h nor an import
// library. So this file is fully self-contained:
//
//   * the small set of COM interfaces we call is declared by hand below. The
//     vtable layout MUST match dwrite.h exactly (method order is part of the
//     ABI) — see the individual interface comments;
//   * the single factory entry point, DWriteCreateFactory, is resolved at
//     runtime with LoadLibrary( "dwrite.dll") / GetProcAddress. Everything
//     else is called through the vtables, so no import library is needed.
//
// This is a pragmatic deviation from the "static link guaranteed OS APIs"
// policy: the API is still guaranteed present, only the *binding* happens at
// runtime because the toolchain provides no import library.
//
// Define MULLE_CG_NO_DIRECTWRITE to force this backend off.
//
#import "import-private.h"

#if defined( _WIN32) && ! defined( MULLE_CG_NO_DIRECTWRITE)
# define MULLE_CG_HAVE_DIRECTWRITE
#endif

#if defined( MULLE_CG_HAVE_DIRECTWRITE)

#import "CGSystemFont+Private.h"

#include <windows.h>

#include <wchar.h>
#include <wctype.h>

#include <unknwn.h>


//----------------------------------------------------------------------------
// Minimal DirectWrite declarations (layout per dwrite.h)
//
// Every interface below is laid out in exact dwrite.h method order. Only the
// methods actually used are declared, but every slot up to the last used one
// must be present so the indices line up. Enums are plain ints; the values we
// rely on are defined where used.
//----------------------------------------------------------------------------

typedef int   DWRITE_FONT_WEIGHT;
typedef int   DWRITE_FONT_STYLE;
typedef int   DWRITE_FACTORY_TYPE;

enum
{
   DWRITE_FONT_STYLE_NORMAL  = 0,
   DWRITE_FONT_STYLE_OBLIQUE = 1,
   DWRITE_FONT_STYLE_ITALIC  = 2
};

enum
{
   DWRITE_FACTORY_TYPE_SHARED = 0
};

// DWRITE_FONT_WEIGHT values are already OpenType-ish (100..900, 0 == undefined)


struct IDWriteLocalizedStrings;
struct IDWriteFactory;
struct IDWriteFontCollection;
struct IDWriteFontList;
struct IDWriteFontFamily;
struct IDWriteFont;
struct IDWriteFontFace;
struct IDWriteFontFile;
struct IDWriteFontFileLoader;
struct IDWriteLocalFontFileLoader;

// ObjC is C: struct tags need a typedef (or the struct keyword) to be used
// as plain type names. All uses below are pointers to these structs.
typedef struct IDWriteLocalizedStrings     IDWriteLocalizedStrings;
typedef struct IDWriteFactory              IDWriteFactory;
typedef struct IDWriteFontCollection       IDWriteFontCollection;
typedef struct IDWriteFontFamily           IDWriteFontFamily;
typedef struct IDWriteFont                 IDWriteFont;
typedef struct IDWriteFontFace             IDWriteFontFace;
typedef struct IDWriteFontFile             IDWriteFontFile;
typedef struct IDWriteFontFileLoader       IDWriteFontFileLoader;
typedef struct IDWriteLocalFontFileLoader  IDWriteLocalFontFileLoader;


//
// IDWriteLocalizedStrings : IUnknown (slots 0..2), GetStringLength = 7,
// GetString = 8.
//
struct IDWriteLocalizedStringsVtbl
{
   HRESULT ( STDMETHODCALLTYPE *QueryInterface)( struct IDWriteLocalizedStrings *, REFIID, void **);
   ULONG   ( STDMETHODCALLTYPE *AddRef)( struct IDWriteLocalizedStrings *);
   ULONG   ( STDMETHODCALLTYPE *Release)( struct IDWriteLocalizedStrings *);
   UINT32  ( STDMETHODCALLTYPE *GetCount)( struct IDWriteLocalizedStrings *);
   HRESULT ( STDMETHODCALLTYPE *FindLocaleName)( struct IDWriteLocalizedStrings *, const WCHAR *, UINT32 *, BOOL *);
   HRESULT ( STDMETHODCALLTYPE *GetLocaleNameLength)( struct IDWriteLocalizedStrings *, UINT32, UINT32 *);
   HRESULT ( STDMETHODCALLTYPE *GetLocaleName)( struct IDWriteLocalizedStrings *, UINT32, WCHAR *, UINT32);
   HRESULT ( STDMETHODCALLTYPE *GetStringLength)( struct IDWriteLocalizedStrings *, UINT32, UINT32 *);
   HRESULT ( STDMETHODCALLTYPE *GetString)( struct IDWriteLocalizedStrings *, UINT32, WCHAR *, UINT32);
};

struct IDWriteLocalizedStrings
{
   struct IDWriteLocalizedStringsVtbl   *lpVtbl;
};


//
// IDWriteFontFile : IUnknown, GetReferenceKey = 3, GetLoader = 4.
//
struct IDWriteFontFileVtbl
{
   HRESULT ( STDMETHODCALLTYPE *QueryInterface)( struct IDWriteFontFile *, REFIID, void **);
   ULONG   ( STDMETHODCALLTYPE *AddRef)( struct IDWriteFontFile *);
   ULONG   ( STDMETHODCALLTYPE *Release)( struct IDWriteFontFile *);
   HRESULT ( STDMETHODCALLTYPE *GetReferenceKey)( struct IDWriteFontFile *, const void **, UINT32 *);
   HRESULT ( STDMETHODCALLTYPE *GetLoader)( struct IDWriteFontFile *, struct IDWriteFontFileLoader **);
};

struct IDWriteFontFile
{
   struct IDWriteFontFileVtbl   *lpVtbl;
};


//
// IDWriteFontFace : IUnknown, GetFiles = 4.
//
struct IDWriteFontFaceVtbl
{
   HRESULT ( STDMETHODCALLTYPE *QueryInterface)( struct IDWriteFontFace *, REFIID, void **);
   ULONG   ( STDMETHODCALLTYPE *AddRef)( struct IDWriteFontFace *);
   ULONG   ( STDMETHODCALLTYPE *Release)( struct IDWriteFontFace *);
   int     ( STDMETHODCALLTYPE *GetType)( struct IDWriteFontFace *);
   HRESULT ( STDMETHODCALLTYPE *GetFiles)( struct IDWriteFontFace *, UINT32 *, struct IDWriteFontFile **);
};

struct IDWriteFontFace
{
   struct IDWriteFontFaceVtbl   *lpVtbl;
};


//
// IDWriteFont : IUnknown, GetWeight = 4, GetStyle = 6, GetFaceNames = 8,
// CreateFontFace = 13.
//
struct IDWriteFontVtbl
{
   HRESULT ( STDMETHODCALLTYPE *QueryInterface)( struct IDWriteFont *, REFIID, void **);
   ULONG   ( STDMETHODCALLTYPE *AddRef)( struct IDWriteFont *);
   ULONG   ( STDMETHODCALLTYPE *Release)( struct IDWriteFont *);
   HRESULT ( STDMETHODCALLTYPE *GetFontFamily)( struct IDWriteFont *, struct IDWriteFontFamily **);
   int     ( STDMETHODCALLTYPE *GetWeight)( struct IDWriteFont *);
   int     ( STDMETHODCALLTYPE *GetStretch)( struct IDWriteFont *);
   int     ( STDMETHODCALLTYPE *GetStyle)( struct IDWriteFont *);
   BOOL    ( STDMETHODCALLTYPE *IsSymbolFont)( struct IDWriteFont *);
   HRESULT ( STDMETHODCALLTYPE *GetFaceNames)( struct IDWriteFont *, struct IDWriteLocalizedStrings **);
   HRESULT ( STDMETHODCALLTYPE *GetInformationalStrings)( struct IDWriteFont *, struct IDWriteLocalizedStrings **, struct IDWriteLocalizedStrings **);
   int     ( STDMETHODCALLTYPE *GetSimulations)( struct IDWriteFont *);
   void    ( STDMETHODCALLTYPE *GetMetrics)( struct IDWriteFont *, void *);
   HRESULT ( STDMETHODCALLTYPE *HasCharacter)( struct IDWriteFont *, UINT32, BOOL *);
   HRESULT ( STDMETHODCALLTYPE *CreateFontFace)( struct IDWriteFont *, struct IDWriteFontFace **);
};

struct IDWriteFont
{
   struct IDWriteFontVtbl   *lpVtbl;
};


//
// IDWriteFontList : IUnknown, GetFontCount = 4, GetFont = 5.
//
struct IDWriteFontListVtbl
{
   HRESULT ( STDMETHODCALLTYPE *QueryInterface)( struct IDWriteFontList *, REFIID, void **);
   ULONG   ( STDMETHODCALLTYPE *AddRef)( struct IDWriteFontList *);
   ULONG   ( STDMETHODCALLTYPE *Release)( struct IDWriteFontList *);
   HRESULT ( STDMETHODCALLTYPE *GetFontCollection)( struct IDWriteFontList *, struct IDWriteFontCollection **);
   UINT32  ( STDMETHODCALLTYPE *GetFontCount)( struct IDWriteFontList *);
   HRESULT ( STDMETHODCALLTYPE *GetFont)( struct IDWriteFontList *, UINT32, struct IDWriteFont **);
};

struct IDWriteFontList
{
   struct IDWriteFontListVtbl   *lpVtbl;
};


//
// IDWriteFontFamily : IDWriteFontList, GetFamilyNames = 6.
//
struct IDWriteFontFamilyVtbl
{
   HRESULT ( STDMETHODCALLTYPE *QueryInterface)( struct IDWriteFontFamily *, REFIID, void **);
   ULONG   ( STDMETHODCALLTYPE *AddRef)( struct IDWriteFontFamily *);
   ULONG   ( STDMETHODCALLTYPE *Release)( struct IDWriteFontFamily *);
   HRESULT ( STDMETHODCALLTYPE *GetFontCollection)( struct IDWriteFontFamily *, struct IDWriteFontCollection **);
   UINT32  ( STDMETHODCALLTYPE *GetFontCount)( struct IDWriteFontFamily *);
   HRESULT ( STDMETHODCALLTYPE *GetFont)( struct IDWriteFontFamily *, UINT32, struct IDWriteFont **);
   HRESULT ( STDMETHODCALLTYPE *GetFamilyNames)( struct IDWriteFontFamily *, struct IDWriteLocalizedStrings **);
};

struct IDWriteFontFamily
{
   struct IDWriteFontFamilyVtbl   *lpVtbl;
};


//
// IDWriteFontCollection : IUnknown, GetFontFamilyCount = 3,
// GetFontFamily = 4.
//
struct IDWriteFontCollectionVtbl
{
   HRESULT ( STDMETHODCALLTYPE *QueryInterface)( struct IDWriteFontCollection *, REFIID, void **);
   ULONG   ( STDMETHODCALLTYPE *AddRef)( struct IDWriteFontCollection *);
   ULONG   ( STDMETHODCALLTYPE *Release)( struct IDWriteFontCollection *);
   UINT32  ( STDMETHODCALLTYPE *GetFontFamilyCount)( struct IDWriteFontCollection *);
   HRESULT ( STDMETHODCALLTYPE *GetFontFamily)( struct IDWriteFontCollection *, UINT32, struct IDWriteFontFamily **);
};

struct IDWriteFontCollection
{
   struct IDWriteFontCollectionVtbl   *lpVtbl;
};


//
// IDWriteFactory : IUnknown, GetSystemFontCollection = 3.
//
struct IDWriteFactoryVtbl
{
   HRESULT ( STDMETHODCALLTYPE *QueryInterface)( struct IDWriteFactory *, REFIID, void **);
   ULONG   ( STDMETHODCALLTYPE *AddRef)( struct IDWriteFactory *);
   ULONG   ( STDMETHODCALLTYPE *Release)( struct IDWriteFactory *);
   HRESULT ( STDMETHODCALLTYPE *GetSystemFontCollection)( struct IDWriteFactory *, struct IDWriteFontCollection **, BOOL);
};

struct IDWriteFactory
{
   struct IDWriteFactoryVtbl   *lpVtbl;
};


//
// IDWriteFontFileLoader : IUnknown, CreateStreamFromKey = 3. Only used as the
// source for a QueryInterface to IDWriteLocalFontFileLoader.
//
struct IDWriteFontFileLoaderVtbl
{
   HRESULT ( STDMETHODCALLTYPE *QueryInterface)( struct IDWriteFontFileLoader *, REFIID, void **);
   ULONG   ( STDMETHODCALLTYPE *AddRef)( struct IDWriteFontFileLoader *);
   ULONG   ( STDMETHODCALLTYPE *Release)( struct IDWriteFontFileLoader *);
   HRESULT ( STDMETHODCALLTYPE *CreateStreamFromKey)( struct IDWriteFontFileLoader *, const void *, UINT32, void **);
};

struct IDWriteFontFileLoader
{
   struct IDWriteFontFileLoaderVtbl   *lpVtbl;
};


//
// IDWriteLocalFontFileLoader : IDWriteFontFileLoader,
// GetFilePathLengthFromKey = 4, GetFilePathFromKey = 5.
//
struct IDWriteLocalFontFileLoaderVtbl
{
   HRESULT ( STDMETHODCALLTYPE *QueryInterface)( struct IDWriteLocalFontFileLoader *, REFIID, void **);
   ULONG   ( STDMETHODCALLTYPE *AddRef)( struct IDWriteLocalFontFileLoader *);
   ULONG   ( STDMETHODCALLTYPE *Release)( struct IDWriteLocalFontFileLoader *);
   HRESULT ( STDMETHODCALLTYPE *CreateStreamFromKey)( struct IDWriteLocalFontFileLoader *, const void *, UINT32, void **);
   HRESULT ( STDMETHODCALLTYPE *GetFilePathLengthFromKey)( struct IDWriteLocalFontFileLoader *, const void *, UINT32, UINT32 *);
   HRESULT ( STDMETHODCALLTYPE *GetFilePathFromKey)( struct IDWriteLocalFontFileLoader *, const void *, UINT32, WCHAR *, UINT32);
};

struct IDWriteLocalFontFileLoader
{
   struct IDWriteLocalFontFileLoaderVtbl   *lpVtbl;
};


typedef HRESULT ( STDMETHODCALLTYPE * CGDirectWriteCreateFactoryFunction)( DWRITE_FACTORY_TYPE, REFIID, void **);

// IID_IDWriteFactory
static const IID   CGDirectWriteFactoryIID =
{
   0xb859ee5a, 0xd838, 0x4b5b, { 0xa2, 0xe8, 0x1a, 0xdc, 0x7d, 0x93, 0xdb, 0x48}
};

// IID_IDWriteLocalFontFileLoader
static const IID   CGDirectWriteLocalFontFileLoaderIID =
{
   0x727cad4e, 0xd5af, 0x4c4e, { 0x8a, 0x43, 0x69, 0x72, 0xe0, 0x61, 0xb1, 0xec}
};


static IDWriteFactory                        *CGDirectWriteFactory;
static CGDirectWriteCreateFactoryFunction     CGDirectWriteCreateFactoryFunctionPointer;
static HMODULE                               CGDirectWriteLibrary;
static BOOL                                  CGDirectWriteLoadAttempted;


//
// Load dwrite.dll and create the shared factory. Returns YES when the backend
// is usable. Called from the constructor; safe to call more than once.
//
static BOOL   CGSystemFontDirectWriteLoad( void)
{
   if( CGDirectWriteFactory)
      return( YES);
   if( CGDirectWriteLoadAttempted)
      return( NO);
   CGDirectWriteLoadAttempted = YES;

   CGDirectWriteLibrary = LoadLibraryA( "dwrite.dll");
   if( ! CGDirectWriteLibrary)
      return( NO);

   CGDirectWriteCreateFactoryFunctionPointer = (CGDirectWriteCreateFactoryFunction)
      GetProcAddress( CGDirectWriteLibrary, "DWriteCreateFactory");
   if( ! CGDirectWriteCreateFactoryFunctionPointer)
      return( NO);

   if( FAILED( (*CGDirectWriteCreateFactoryFunctionPointer)( DWRITE_FACTORY_TYPE_SHARED,
                                                            &CGDirectWriteFactoryIID,
                                                            (void **) &CGDirectWriteFactory)))
      return( NO);

   return( CGDirectWriteFactory != NULL);
}


//----------------------------------------------------------------------------
// Conversion helpers (UTF-16 <-> UTF-8), mulle_ allocated
//----------------------------------------------------------------------------

static char   *CGSystemFontCopyUTF8StringFromWideString( const WCHAR *wide)
{
   char    *utf8;
   int     size;

   if( ! wide)
      return( NULL);

   size = WideCharToMultiByte( CP_UTF8, 0, wide, -1, NULL, 0, NULL, NULL);
   if( size <= 0)
      return( NULL);

   utf8 = mulle_malloc( (size_t) size);
   if( ! WideCharToMultiByte( CP_UTF8, 0, wide, -1, utf8, size, NULL, NULL))
   {
      mulle_free( utf8);
      return( NULL);
   }
   return( utf8);
}


static WCHAR   *CGSystemFontCopyWideStringFromUTF8String( const char *utf8)
{
   WCHAR   *wide;
   int     size;

   if( ! utf8)
      return( NULL);

   size = MultiByteToWideChar( CP_UTF8, 0, utf8, -1, NULL, 0);
   if( size <= 0)
      return( NULL);

   wide = mulle_malloc( (size_t) size * sizeof( WCHAR));
   if( ! MultiByteToWideChar( CP_UTF8, 0, utf8, -1, wide, size))
   {
      mulle_free( wide);
      return( NULL);
   }
   return( wide);
}


static BOOL   CGSystemFontWideStringEqualIgnoreCase( const WCHAR *a, const WCHAR *b)
{
   if( ! a || ! b)
      return( a == b);

   while( *a && *b)
   {
      if( towlower( *a) != towlower( *b))
         return( NO);
      a++;
      b++;
   }
   return( *a == *b);
}


//
// String at index 0 of a localized strings object, as UTF8. DirectWrite puts
// the default locale first; good enough for family/style names.
//
static char   *CGSystemFontCopyStringFromLocalizedStrings( struct IDWriteLocalizedStrings *strings)
{
   UINT32   length;
   WCHAR    *wide;
   char     *utf8;
   HRESULT  hr;

   if( ! strings)
      return( NULL);

   hr = strings->lpVtbl->GetStringLength( strings, 0, &length);
   if( FAILED( hr))
      return( NULL);

   wide = mulle_malloc( ((size_t) length + 1) * sizeof( WCHAR));
   hr   = strings->lpVtbl->GetString( strings, 0, wide, length + 1);
   if( FAILED( hr))
   {
      mulle_free( wide);
      return( NULL);
   }

   utf8 = CGSystemFontCopyUTF8StringFromWideString( wide);
   mulle_free( wide);
   return( utf8);
}


//
// Absolute file path behind a font, via IDWriteLocalFontFileLoader, or NULL
// for fonts that have no local file.
//
static char   *CGSystemFontCopyFilePathFromFont( struct IDWriteFont *font)
{
   struct IDWriteFontFace            *face;
   struct IDWriteFontFile            *file;
   struct IDWriteFontFile            **files;
   struct IDWriteFontFileLoader      *loader;
   struct IDWriteLocalFontFileLoader *localLoader;
   const void                        *referenceKey;
   UINT32                            referenceKeySize;
   UINT32                            filePathLength;
   WCHAR                             *filePathWide;
   char                              *filePath;
   UINT32                            numberOfFiles;
   HRESULT                           hr;

   face         = NULL;
   file         = NULL;
   files        = NULL;
   loader       = NULL;
   localLoader  = NULL;
   filePathWide = NULL;
   filePath     = NULL;

   hr = font->lpVtbl->CreateFontFace( font, &face);
   if( FAILED( hr))
      goto done;

   numberOfFiles = 0;
   hr = face->lpVtbl->GetFiles( face, &numberOfFiles, NULL);   // query count first
   if( FAILED( hr) || numberOfFiles == 0)
      goto done;

   files = mulle_malloc( sizeof( *files) * numberOfFiles);
   hr    = face->lpVtbl->GetFiles( face, &numberOfFiles, files);
   if( FAILED( hr) || numberOfFiles == 0)
      goto done;
   file = files[ 0];

   hr = file->lpVtbl->GetReferenceKey( file, &referenceKey, &referenceKeySize);
   if( FAILED( hr))
      goto done;

   hr = file->lpVtbl->GetLoader( file, &loader);
   if( FAILED( hr))
      goto done;

   hr = loader->lpVtbl->QueryInterface( loader, &CGDirectWriteLocalFontFileLoaderIID,
                                        (void **) &localLoader);
   if( FAILED( hr))
      goto done;

   hr = localLoader->lpVtbl->GetFilePathLengthFromKey( localLoader, referenceKey,
                                                       referenceKeySize, &filePathLength);
   if( FAILED( hr))
      goto done;

   filePathWide = mulle_malloc( ((size_t) filePathLength + 1) * sizeof( WCHAR));
   hr = localLoader->lpVtbl->GetFilePathFromKey( localLoader, referenceKey, referenceKeySize,
                                                 filePathWide, filePathLength + 1);
   if( FAILED( hr))
      goto done;

   filePath = CGSystemFontCopyUTF8StringFromWideString( filePathWide);

done:
   if( files)
      mulle_free( files);
   if( filePathWide)
      mulle_free( filePathWide);
   if( localLoader)
      localLoader->lpVtbl->Release( localLoader);
   if( loader)
      loader->lpVtbl->Release( loader);
   if( file)
      file->lpVtbl->Release( file);
   if( face)
      face->lpVtbl->Release( face);
   return( filePath);
}


static NSInteger   CGSystemFontWeightFromDirectWrite( DWRITE_FONT_WEIGHT weight)
{
   if( weight <= 0)
      return( CGSystemFontWeightUnknown);
   if( weight < 100)
      return( CGSystemFontWeightThin);
   if( weight > 900)   // DWRITE_FONT_WEIGHT goes up to 950
      return( CGSystemFontWeightBlack);
   return( (NSInteger) weight);
}


//
// Fill one descriptor from a font. `familyUTF8String` is owned by the caller;
// on success descriptor->familyUTF8String is a mulle_ duplicate.
//
static BOOL   CGSystemFontDescriptorFromFont( struct IDWriteFont *font,
                                              const char *familyUTF8String,
                                              struct CGSystemFontDescriptor *descriptor)
{
   struct IDWriteLocalizedStrings   *faceNames;
   char                             *style;
   char                             *path;
   NSInteger                        weight;
   int                              dwriteStyle;
   HRESULT                          hr;

   memset( descriptor, 0, sizeof( *descriptor));

   faceNames = NULL;
   style     = NULL;
   hr        = font->lpVtbl->GetFaceNames( font, &faceNames);
   if( SUCCEEDED( hr))
   {
      style = CGSystemFontCopyStringFromLocalizedStrings( faceNames);
      faceNames->lpVtbl->Release( faceNames);
   }

   path = CGSystemFontCopyFilePathFromFont( font);
   if( ! familyUTF8String || ! path)
   {
      mulle_free( style);
      mulle_free( path);
      return( NO);
   }

   weight      = CGSystemFontWeightFromDirectWrite( font->lpVtbl->GetWeight( font));
   dwriteStyle = font->lpVtbl->GetStyle( font);

   descriptor->familyUTF8String = mulle_strdup( familyUTF8String);
   descriptor->styleUTF8String  = style;
   descriptor->pathUTF8String   = path;
   descriptor->faceIndex        = 0;
   descriptor->weight           = weight;
   descriptor->italic           = (dwriteStyle != DWRITE_FONT_STYLE_NORMAL) ? YES : NO;
   return( YES);
}


static NSUInteger   CGSystemFontDirectWriteEnumerate( struct CGSystemFontDescriptor **descriptorsp,
                                                      NSUInteger *countp)
{
   struct IDWriteFontCollection      *collection;
   struct IDWriteFontFamily          *family;
   struct IDWriteLocalizedStrings    *familyNames;
   struct IDWriteFont                *font;
   struct CGSystemFontDescriptor     *descriptors;
   char                              *familyName;
   UINT32                            familyCount;
   UINT32                            fontCount;
   UINT32                            i;
   UINT32                            j;
   NSUInteger                        n;
   HRESULT                           hr;

   *descriptorsp = NULL;
   *countp       = 0;

   if( ! CGSystemFontDirectWriteLoad())
      return( 0);

   collection = NULL;
   hr = CGDirectWriteFactory->lpVtbl->GetSystemFontCollection( CGDirectWriteFactory,
                                                               &collection, FALSE);
   if( FAILED( hr) || ! collection)
      return( 0);

   familyCount = collection->lpVtbl->GetFontFamilyCount( collection);

   // First pass: count faces so the array can be allocated exactly.
   n = 0;
   for( i = 0; i < familyCount; i++)
   {
      family = NULL;
      if( FAILED( collection->lpVtbl->GetFontFamily( collection, i, &family)))
         continue;
      n += family->lpVtbl->GetFontCount( family);
      family->lpVtbl->Release( family);
   }
   if( n == 0)
   {
      collection->lpVtbl->Release( collection);
      return( 0);
   }

   descriptors = mulle_malloc( sizeof( *descriptors) * n);

   // Second pass: fill descriptors, skipping faces without a local file.
   n = 0;
   for( i = 0; i < familyCount; i++)
   {
      family = NULL;
      if( FAILED( collection->lpVtbl->GetFontFamily( collection, i, &family)))
         continue;

      familyNames = NULL;
      familyName  = NULL;
      if( SUCCEEDED( family->lpVtbl->GetFamilyNames( family, &familyNames)))
      {
         familyName = CGSystemFontCopyStringFromLocalizedStrings( familyNames);
         familyNames->lpVtbl->Release( familyNames);
      }

      if( familyName)
      {
         fontCount = family->lpVtbl->GetFontCount( family);
         for( j = 0; j < fontCount; j++)
         {
            font = NULL;
            if( FAILED( family->lpVtbl->GetFont( family, j, &font)))
               continue;
            if( CGSystemFontDescriptorFromFont( font, familyName, &descriptors[ n]))
               n++;
            font->lpVtbl->Release( font);
         }
         mulle_free( familyName);
      }
      family->lpVtbl->Release( family);
   }
   collection->lpVtbl->Release( collection);

   if( n == 0)
   {
      mulle_free( descriptors);
      return( 0);
   }

   *descriptorsp = descriptors;
   *countp       = n;
   return( n);
}


//
// Resolve family (+ weight/italic) by scanning the system collection. No
// DirectWrite "best match" API is used: we pick the face of the requested
// family closest to the requested weight/italic, which keeps the COM surface
// small. Returns NO when the family does not exist at all.
//
static BOOL   CGSystemFontDirectWriteResolve( struct CGSystemFontQuery *query,
                                              struct CGSystemFontDescriptor *descriptor)
{
   struct IDWriteFontCollection      *collection;
   struct IDWriteFontFamily          *family;
   struct IDWriteLocalizedStrings    *familyNames;
   struct IDWriteFont                *font;
   struct IDWriteFont                *bestFont;
   char                              *familyName;
   char                              *bestFamilyName;
   WCHAR                             *queryWide;
   WCHAR                             *familyNameWide;
   NSInteger                         wantedWeight;
   NSInteger                         bestScore;
   NSInteger                         score;
   NSInteger                         fontWeight;
   BOOL                              wantItalic;
   BOOL                              fontItalic;
   BOOL                              ok;
   UINT32                            familyCount;
   UINT32                            fontCount;
   UINT32                            i;
   UINT32                            j;
   HRESULT                           hr;

   if( ! query->familyUTF8String)
      return( NO);

   if( ! CGSystemFontDirectWriteLoad())
      return( NO);

   wantedWeight = (query->weight) ? query->weight : CGSystemFontWeightRegular;
   wantItalic   = query->italic;

   queryWide = CGSystemFontCopyWideStringFromUTF8String( query->familyUTF8String);
   if( ! queryWide)
      return( NO);

   collection     = NULL;
   bestFont       = NULL;
   bestFamilyName = NULL;
   bestScore      = 0x7FFFFFFF;

   hr = CGDirectWriteFactory->lpVtbl->GetSystemFontCollection( CGDirectWriteFactory,
                                                               &collection, FALSE);
   if( FAILED( hr) || ! collection)
   {
      mulle_free( queryWide);
      return( NO);
   }

   familyCount = collection->lpVtbl->GetFontFamilyCount( collection);
   for( i = 0; i < familyCount; i++)
   {
      family         = NULL;
      familyNames    = NULL;
      familyName     = NULL;
      familyNameWide = NULL;

      if( FAILED( collection->lpVtbl->GetFontFamily( collection, i, &family)))
         continue;

      if( SUCCEEDED( family->lpVtbl->GetFamilyNames( family, &familyNames)))
         familyName = CGSystemFontCopyStringFromLocalizedStrings( familyNames);
      if( familyNames)
         familyNames->lpVtbl->Release( familyNames);

      if( familyName)
         familyNameWide = CGSystemFontCopyWideStringFromUTF8String( familyName);

      if( familyNameWide && CGSystemFontWideStringEqualIgnoreCase( queryWide, familyNameWide))
      {
         fontCount = family->lpVtbl->GetFontCount( family);
         for( j = 0; j < fontCount; j++)
         {
            font = NULL;
            if( FAILED( family->lpVtbl->GetFont( family, j, &font)))
               continue;

            // Cheap scoring: weight/style come straight off the font, no
            // file path round trip.
            fontWeight = CGSystemFontWeightFromDirectWrite( font->lpVtbl->GetWeight( font));
            if( fontWeight <= 0)
               fontWeight = CGSystemFontWeightRegular;
            fontItalic = (font->lpVtbl->GetStyle( font) != DWRITE_FONT_STYLE_NORMAL) ? YES : NO;

            score = fontWeight - wantedWeight;
            if( score < 0)
               score = -score;
            if( fontItalic != wantItalic)
               score += 1000;
            if( score < bestScore)
            {
               bestScore = score;
               if( bestFont)
                  bestFont->lpVtbl->Release( bestFont);
               bestFont = font;
               if( bestFamilyName)
                  mulle_free( bestFamilyName);
               bestFamilyName = mulle_strdup( familyName);
               font = NULL;   // ownership moved to bestFont
            }
            if( font)
            {
               font->lpVtbl->Release( font);
               font = NULL;
            }
         }
      }

      if( familyNameWide)
         mulle_free( familyNameWide);
      if( familyName)
         mulle_free( familyName);
      family->lpVtbl->Release( family);
   }
   collection->lpVtbl->Release( collection);
   mulle_free( queryWide);

   if( ! bestFont)
      return( NO);

   ok = CGSystemFontDescriptorFromFont( bestFont, bestFamilyName, descriptor);
   bestFont->lpVtbl->Release( bestFont);
   if( bestFamilyName)
      mulle_free( bestFamilyName);
   return( ok);
}


//
// Probe whether this DirectWrite can actually hand out file paths. Wine's
// dwrite does not implement IDWriteLocalFontFileLoader, so on Wine a backend
// would register yet enumerate nothing (our descriptors need local files).
// Registering only when paths are obtainable keeps CGSystemFontIsAvailable()
// honest: YES means "use system fonts", NO means "keep shipping fonts".
//
static BOOL   CGSystemFontDirectWriteCanProducePaths( void)
{
   struct IDWriteFontCollection      *collection;
   struct IDWriteFontFamily          *family;
   struct IDWriteFont                *font;
   char                              *path;
   BOOL                              ok;
   UINT32                            familyCount;
   HRESULT                           hr;

   collection = NULL;
   family     = NULL;
   font       = NULL;
   path       = NULL;
   ok         = NO;

   hr = CGDirectWriteFactory->lpVtbl->GetSystemFontCollection( CGDirectWriteFactory,
                                                               &collection, FALSE);
   if( FAILED( hr) || ! collection)
      goto done;

   familyCount = collection->lpVtbl->GetFontFamilyCount( collection);
   if( familyCount == 0)
      goto done;

   if( FAILED( collection->lpVtbl->GetFontFamily( collection, 0, &family)))
      goto done;
   if( family->lpVtbl->GetFontCount( family) == 0)
      goto done;
   if( FAILED( family->lpVtbl->GetFont( family, 0, &font)))
      goto done;

   path = CGSystemFontCopyFilePathFromFont( font);
   ok   = (path != NULL);
   if( path)
      mulle_free( path);


done:
   if( font)
      font->lpVtbl->Release( font);
   if( family)
      family->lpVtbl->Release( family);
   if( collection)
      collection->lpVtbl->Release( collection);
   return( ok);
}


static struct CGSystemFontBackend   CGSystemFontDirectWriteBackend =
{
   .nameUTF8String = "directwrite",
   .enumerate      = CGSystemFontDirectWriteEnumerate,
   .resolve        = CGSystemFontDirectWriteResolve
};


MULLE_C_CONSTRUCTOR( CGSystemFontDirectWriteRegister)
static void   CGSystemFontDirectWriteRegister( void)
{
   if( CGSystemFontDirectWriteLoad() && CGSystemFontDirectWriteCanProducePaths())
      CGSystemFontRegisterBackend( &CGSystemFontDirectWriteBackend);
}

#endif // MULLE_CG_HAVE_DIRECTWRITE

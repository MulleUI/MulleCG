#ifndef _GNU_SOURCE
# define _GNU_SOURCE   // strdup, setenv, mkdtemp
#endif

#import <MulleCG/MulleCG.h>

#include <dirent.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>


//
// Collection (.ttc/.otc) test. Verifies the two face-index paths:
//
//   (a) loading dispatch — fontWithContentsOfFileWithFileRepresentationString:
//       fontNameUTF8String:faceIndex: (and fontWithSystemFontDescriptor:) must
//       hand the descriptor's faceIndex to the backend's createFontMemAtIndex
//       entry, and fall back to createFontMem when a backend has no index
//       entry. Verified with an injectable fake font function table, no glyph
//       rendering needed.
//   (b) enumeration — CGSystemFontEnumerate must report face 0 AND face 1 of
//       a real .ttc with the right faceIndex values.
//
// The .ttc is genuinely built at test time from two installed .ttf files
// (12-byte "ttcf" header + per-face offsets + both font blobs) and validated
// structurally. Enumeration works by pointing fontconfig at a temp user font
// dir (XDG_DATA_HOME) before the first enumerate.
//
// This test is Linux-gated: building needs host .ttf files and enumeration
// needs fontconfig user-font support. On other platforms it prints the same
// PASS line (nothing to do). Output is stable and platform-invariant.
//

#if defined( __linux__)

static int   g_failures;

#define CHECK( cond, message)                         \
   do                                                 \
   {                                                  \
      if( ! (cond))                                   \
      {                                               \
         printf( "collection: FAIL %s\n", message);   \
         g_failures = 1;                              \
      }                                               \
   }                                                  \
   while( 0)


//----------------------------------------------------------------------------
// fake font function table — records what the loader dispatched
//----------------------------------------------------------------------------

struct fake_call
{
   char        *name;       // strdup'ed
   size_t      length;
   BOOL        freeData;
   NSUInteger  faceIndex;
   int         kind;        // 1 = createFontMem, 2 = createFontMemAtIndex
   int         calls;
};

static struct fake_call   g_fake_call;


static void   fake_reset( void)
{
   free( g_fake_call.name);
   memset( &g_fake_call, 0, sizeof( g_fake_call));
}


static CGFontID   fake_createFontMem( void *vg, char *name, void *data, size_t length, BOOL freeData)
{
   (void) vg;

   g_fake_call.kind     = 1;
   g_fake_call.name     = strdup( name);
   g_fake_call.length   = length;
   g_fake_call.freeData = freeData;
   g_fake_call.calls++;

   // a real backend takes ownership of `data` when freeData is YES
   if( freeData)
      free( data);
   return( 42);
}


static CGFontID   fake_createFontMemAtIndex( void *vg, char *name, void *data, size_t length, BOOL freeData, NSUInteger faceIndex)
{
   (void) vg;

   g_fake_call.kind      = 2;
   g_fake_call.name      = strdup( name);
   g_fake_call.length    = length;
   g_fake_call.freeData  = freeData;
   g_fake_call.faceIndex = faceIndex;
   g_fake_call.calls++;

   // a real backend takes ownership of `data` when freeData is YES
   if( freeData)
      free( data);
   return( 42);
}


//
// A CGLayoutContext subclass so the test can install the fake font table
// (the _fontFunctions ivar is protected, i.e. visible to subclasses) and
// keep the real backend from overwriting it.
//
@interface TestFontContext : CGLayoutContext

- (void) installTestFontTable:(struct CGFontFunctionTable *) table;

@end


@implementation TestFontContext

- (void) _initFontBackend
{
   // no-op: keep whatever installTestFontTable: put into _fontFunctions
}

- (void) installTestFontTable:(struct CGFontFunctionTable *) table
{
   _fontFunctions = *table;
   _fontContext   = NULL;
}

@end


//----------------------------------------------------------------------------
// small file/ttc helpers
//----------------------------------------------------------------------------

static void   *read_file( const char *path, size_t *length)
{
   FILE   *fp;
   long   size;
   void   *data;

   *length = 0;
   fp = fopen( path, "rb");
   if( ! fp)
      return( NULL);
   if( fseek( fp, 0, SEEK_END) != 0)
   {
      fclose( fp);
      return( NULL);
   }
   size = ftell( fp);
   if( size <= 0)
   {
      fclose( fp);
      return( NULL);
   }
   if( fseek( fp, 0, SEEK_SET) != 0)
   {
      fclose( fp);
      return( NULL);
   }
   data = malloc( (size_t) size);
   if( fread( data, 1, (size_t) size, fp) != (size_t) size)
   {
      free( data);
      fclose( fp);
      return( NULL);
   }
   fclose( fp);
   *length = (size_t) size;
   return( data);
}


static void   put32( unsigned char *p, uint32_t v)
{
   p[ 0] = (unsigned char) (v >> 24);
   p[ 1] = (unsigned char) (v >> 16);
   p[ 2] = (unsigned char) (v >> 8);
   p[ 3] = (unsigned char) v;
}


static uint32_t   get32( const unsigned char *p)
{
   return( ((uint32_t) p[ 0] << 24) | ((uint32_t) p[ 1] << 16) |
           ((uint32_t) p[ 2] << 8) | (uint32_t) p[ 3]);
}


static size_t   pad4( size_t n)
{
   return( (n + 3) & ~(size_t) 3);
}


static char   *build_ttc( const char *tmpdir, const char *srcA, const char *srcB)
{
   unsigned char *data;
   unsigned char *p;
   void          *fontA;
   void          *fontB;
   size_t        sizeA;
   size_t        sizeB;
   size_t        offset0;
   size_t        offset1;
   size_t        total;
   char          fontsdir[ 4096];
   FILE          *fp;

   fontA = read_file( srcA, &sizeA);
   fontB = read_file( srcB, &sizeB);
   if( ! fontA || ! fontB)
   {
      free( fontA);
      free( fontB);
      return( NULL);
   }

   offset0 = 12 + 4 * 2;                 // "ttcf" + version + numFonts + offsets
   offset1 = offset0 + pad4( sizeA);
   total   = offset1 + pad4( sizeB);

   data = malloc( total);
   p    = data;
   memcpy( p, "ttcf", 4);
   p += 4;
   put32( p, 0x00010000);
   p += 4;
   put32( p, 2);
   p += 4;
   put32( p, (uint32_t) offset0);
   p += 4;
   put32( p, (uint32_t) offset1);
   p += 4;
   memcpy( data + offset0, fontA, sizeA);
   memcpy( data + offset1, fontB, sizeB);
   free( fontA);
   free( fontB);

   snprintf( fontsdir, sizeof( fontsdir), "%s/fonts", tmpdir);
   mkdir( fontsdir, 0700);
   snprintf( fontsdir, sizeof( fontsdir), "%s/fonts/collection.ttc", tmpdir);

   fp = fopen( fontsdir, "wb");
   if( ! fp)
   {
      free( data);
      return( NULL);
   }
   if( fwrite( data, 1, total, fp) != total)
   {
      fclose( fp);
      free( data);
      return( NULL);
   }
   fclose( fp);
   free( data);

   return( strdup( fontsdir));
}


static BOOL   ttc_looks_valid( const char *path)
{
   unsigned char *data;
   size_t        length;
   uint32_t      numFonts;
   uint32_t      offset0;
   uint32_t      offset1;
   BOOL          ok;

   ok   = NO;
   data = read_file( path, &length);
   if( ! data)
      return( NO);

   if( length > 12 && memcmp( data, "ttcf", 4) == 0)
   {
      numFonts = get32( data + 8);
      offset0  = get32( data + 12);
      offset1  = get32( data + 16);
      if( numFonts == 2 && offset0 < length && offset1 < length && offset0 < offset1)
         ok = YES;
   }
   free( data);
   return( ok);
}


//----------------------------------------------------------------------------
// host .ttf source discovery
//----------------------------------------------------------------------------

static char   *g_sources[ 2];
static int    g_nSources;


static void   collect_ttf( const char *path, int depth)
{
   DIR           *dir;
   struct dirent *entry;
   struct stat   st;
   char          full[ 4096];
   size_t        len;

   if( g_nSources >= 2 || depth > 6)
      return;

   dir = opendir( path);
   if( ! dir)
      return;

   while( (entry = readdir( dir)) && g_nSources < 2)
   {
      if( entry->d_name[ 0] == '.')
         continue;
      snprintf( full, sizeof( full), "%s/%s", path, entry->d_name);
      if( stat( full, &st) != 0)
         continue;
      if( S_ISDIR( st.st_mode))
         collect_ttf( full, depth + 1);
      else
      {
         len = strlen( entry->d_name);
         if( len > 4 && strcmp( entry->d_name + len - 4, ".ttf") == 0)
            g_sources[ g_nSources++] = strdup( full);
      }
   }
   closedir( dir);
}


static BOOL   find_ttf_sources( void)
{
   static const char   *roots[] = { "/usr/share/fonts", "/usr/local/share/fonts" };
   size_t              i;

   for( i = 0; i < sizeof( roots) / sizeof( roots[ 0]); i++)
   {
      collect_ttf( roots[ i], 0);
      if( g_nSources >= 2)
         break;
   }
   return( g_nSources >= 2);
}


static void   rm_rf( const char *path)
{
   DIR           *dir;
   struct dirent *entry;
   struct stat   st;
   char          full[ 4096];

   dir = opendir( path);
   if( dir)
   {
      while( (entry = readdir( dir)))
      {
         if( entry->d_name[ 0] == '.')
            continue;
         snprintf( full, sizeof( full), "%s/%s", path, entry->d_name);
         if( stat( full, &st) == 0 && S_ISDIR( st.st_mode))
            rm_rf( full);
         else
            unlink( full);
      }
      closedir( dir);
   }
   rmdir( path);
}


//----------------------------------------------------------------------------
// tests
//----------------------------------------------------------------------------

static void   test_loading_dispatch( char *ttcPath)
{
   struct CGFontFunctionTable   table;
   struct CGSystemFontDescriptor descriptor;
   TestFontContext              *context;
   CGFont                       *font;

   memset( &table, 0, sizeof( table));
   table.createFontMemAtIndex = fake_createFontMemAtIndex;

   context = [[TestFontContext alloc] init];
   CHECK( context != nil, "context init");
   [context installTestFontTable:&table];

   // face 0 via the index entry
   fake_reset();
   font = [context fontWithContentsOfFileWithFileRepresentationString:ttcPath
                                                  fontNameUTF8String:(char *) "face-zero"
                                                           faceIndex:0];
   CHECK( font != nil, "load face 0");
   CHECK( g_fake_call.kind == 2, "AtIndex entry used");
   CHECK( g_fake_call.faceIndex == 0, "faceIndex 0 dispatched");
   CHECK( g_fake_call.length > 0, "data read");
   CHECK( g_fake_call.freeData == YES, "freeData YES");
   CHECK( g_fake_call.calls == 1, "one call");
   CHECK( strcmp( g_fake_call.name, "face-zero") == 0, "font name");

   // face 1
   fake_reset();
   font = [context fontWithContentsOfFileWithFileRepresentationString:ttcPath
                                                  fontNameUTF8String:(char *) "face-one"
                                                           faceIndex:1];
   CHECK( font != nil, "load face 1");
   CHECK( g_fake_call.faceIndex == 1, "faceIndex 1 dispatched");

   // cache: same name must not call the backend again
   fake_reset();
   font = [context fontWithContentsOfFileWithFileRepresentationString:ttcPath
                                                  fontNameUTF8String:(char *) "face-one"
                                                           faceIndex:1];
   CHECK( font != nil, "cached face 1");
   CHECK( g_fake_call.calls == 0, "cached, no second call");

   // fallback: backend without the index entry gets the plain entry
   memset( &table, 0, sizeof( table));
   table.createFontMem = fake_createFontMem;
   [context installTestFontTable:&table];

   fake_reset();
   font = [context fontWithContentsOfFileWithFileRepresentationString:ttcPath
                                                  fontNameUTF8String:(char *) "fallback"
                                                           faceIndex:1];
   CHECK( font != nil, "fallback load");
   CHECK( g_fake_call.kind == 1, "plain entry used");
   CHECK( g_fake_call.length > 0, "fallback data read");

   // glue: descriptor -> loader must carry family + faceIndex
   memset( &table, 0, sizeof( table));
   table.createFontMemAtIndex = fake_createFontMemAtIndex;
   [context installTestFontTable:&table];

   fake_reset();
   memset( &descriptor, 0, sizeof( descriptor));
   descriptor.familyUTF8String = (char *) "glue-face";
   descriptor.pathUTF8String   = ttcPath;
   descriptor.faceIndex        = 1;
   font = [context fontWithSystemFontDescriptor:&descriptor];
   CHECK( font != nil, "descriptor glue");
   CHECK( g_fake_call.faceIndex == 1, "glue faceIndex");
   CHECK( strcmp( g_fake_call.name, "glue-face") == 0, "glue name");

   fake_reset();
   [context release];
}


static void   test_enumeration( char *ttcPath, const char *tmpdir)
{
   struct CGSystemFontDescriptor   *descriptors;
   NSUInteger                      count;
   NSUInteger                      i;
   int                             n0;
   int                             n1;

   // point fontconfig at a temp user font dir BEFORE the first enumerate
   setenv( "XDG_DATA_HOME", tmpdir, 1);
   setenv( "XDG_CACHE_HOME", tmpdir, 1);

   CHECK( CGSystemFontIsAvailable(), "fontconfig available");
   if( ! CGSystemFontIsAvailable())
      return;

   descriptors = NULL;
   count       = 0;
   CGSystemFontEnumerate( &descriptors, &count);

   n0 = 0;
   n1 = 0;
   for( i = 0; i < count; i++)
   {
      if( strcmp( descriptors[ i].pathUTF8String, ttcPath) != 0)
         continue;
      if( descriptors[ i].faceIndex == 0)
         n0++;
      else
         if( descriptors[ i].faceIndex == 1)
            n1++;
   }

   CHECK( n0 >= 1, "face 0 enumerated");
   CHECK( n1 >= 1, "face 1 enumerated");

   CGSystemFontDescriptorsFree( descriptors, count);
}


int   main( int argc, char *argv[])
{
   char   *tmpdir;
   char   *ttcPath;
   char   dirname[ 4096];

   if( ! find_ttf_sources())
   {
      // no .ttf sources on this host; nothing to build or verify
      printf( "collection: PASS\n");
      return( 0);
   }

   snprintf( dirname, sizeof( dirname), "/tmp/mullecg-ttc-XXXXXX");
   tmpdir = mkdtemp( dirname);
   CHECK( tmpdir != NULL, "mkdtemp");
   if( ! tmpdir)
      return( 1);

   ttcPath = build_ttc( tmpdir, g_sources[ 0], g_sources[ 1]);
   CHECK( ttcPath != NULL, "build ttc");
   if( ttcPath)
   {
      CHECK( ttc_looks_valid( ttcPath), "ttc structure");

      test_loading_dispatch( ttcPath);
      test_enumeration( ttcPath, tmpdir);
   }

   rm_rf( tmpdir);

   free( ttcPath);
   while( g_nSources > 0)
      free( g_sources[ --g_nSources]);

   if( g_failures == 0)
      printf( "collection: PASS\n");
   return( g_failures);
}

#else

int   main( int argc, char *argv[])
{
   printf( "collection: PASS\n");
   return( 0);
}

#endif
#import <MulleCG/MulleCG.h>

#include <string.h>


//
// System fonts vary per machine AND the test harness may run on a platform
// with no backend (e.g. a Windows build without DirectWrite). So this test
// checks the API *contract* on whatever platform it runs and prints stable,
// platform-invariant PASS lines.
//
// Contract:
//   available == YES  ->  enumeration returns >= 1 valid face
//                         AND resolve() of one of those enumerated families
//                         yields an absolute path
//   available == NO   ->  enumeration is empty and resolve fails (quiet
//                         degrade; caller falls back to shipped fonts)
//
// Either way each check prints "<name>: PASS". A contract violation prints
// "<name>: FAIL ..." and the process exits non-zero.
//


//
// A path is "absolute" in the platform's own sense: leading '/' (POSIX) or a
// drive letter / UNC root (Windows). DirectWrite hands out Windows style
// paths like "C:\Windows\Fonts\arial.ttf".
//
static BOOL   path_is_absolute( char *path)
{
#if defined( _WIN32)
   if( ! path || ! path[ 0])
      return( NO);
   if( path[ 0] == '/' || path[ 0] == '\\')
      return( YES);
   if( path[ 1] == ':')
      return( YES);
   return( NO);
#else
   if( ! path || path[ 0] != '/')
      return( NO);
   return( YES);
#endif
}


//
// A descriptor from enumeration/resolution is valid iff it has a non-empty
// family and an absolute file path.
//
static BOOL   descriptor_is_valid( struct CGSystemFontDescriptor *d)
{
   if( ! d->familyUTF8String || ! d->familyUTF8String[ 0])
      return( NO);
   if( ! path_is_absolute( d->pathUTF8String))
      return( NO);
   return( YES);
}


static int   test_enumerate( BOOL available,
                             struct CGSystemFontDescriptor **descriptorsp,
                             NSUInteger *countp)
{
   NSUInteger   i;

   *descriptorsp = NULL;
   *countp       = 0;

   CGSystemFontEnumerate( descriptorsp, countp);

   if( ! available)
   {
      if( *countp != 0)
      {
         printf( "enumerate: FAIL (no backend but got %tu)\n", *countp);
         CGSystemFontDescriptorsFree( *descriptorsp, *countp);
         *descriptorsp = NULL;
         *countp       = 0;
         return( 1);
      }
      return( 0);
   }

   if( *countp == 0)
   {
      printf( "enumerate: FAIL (backend present but no fonts)\n");
      return( 1);
   }

   for( i = 0; i < *countp; i++)
      if( ! descriptor_is_valid( &(*descriptorsp)[ i]))
      {
         printf( "enumerate: FAIL (invalid descriptor at %tu)\n", i);
         CGSystemFontDescriptorsFree( *descriptorsp, *countp);
         *descriptorsp = NULL;
         *countp       = 0;
         return( 1);
      }

   return( 0);
}


//
// Resolve one of the families that enumeration just produced. The concrete
// family depends on the platform (fontconfig does not know Windows families
// and DirectWrite does not know fontconfig's generic "sans-serif"), but the
// contract is the same everywhere: a family that exists must resolve.
//
static int   test_resolve( BOOL available,
                           struct CGSystemFontDescriptor *descriptors,
                           NSUInteger count)
{
   struct CGSystemFontQuery        query;
   struct CGSystemFontDescriptor   descriptor;
   BOOL                            matched;

   memset( &query, 0, sizeof( query));
   if( descriptors && count > 0)
      query.familyUTF8String = descriptors[ 0].familyUTF8String;
   else
      query.familyUTF8String = "sans-serif";

   matched = CGSystemFontResolve( &query, &descriptor);

   if( ! available)
   {
      if( matched)
      {
         printf( "resolve: FAIL (no backend but matched)\n");
         CGSystemFontDescriptorDone( &descriptor);
         return( 1);
      }
      return( 0);
   }

   if( ! matched)
   {
      printf( "resolve: FAIL (backend present but no match for %s)\n",
              query.familyUTF8String);
      return( 1);
   }

   if( ! descriptor_is_valid( &descriptor))
   {
      printf( "resolve: FAIL (invalid descriptor)\n");
      CGSystemFontDescriptorDone( &descriptor);
      return( 1);
   }

   CGSystemFontDescriptorDone( &descriptor);
   return( 0);
}


int   main( int argc, char *argv[])
{
   struct CGSystemFontDescriptor   *descriptors;
   NSUInteger                      count;
   BOOL                            available;
   int                             rval;

   descriptors = NULL;
   count       = 0;
   available   = CGSystemFontIsAvailable();

   rval  = 0;
   rval |= test_enumerate( available, &descriptors, &count);
   rval |= test_resolve( available, descriptors, count);

   CGSystemFontDescriptorsFree( descriptors, count);

   //
   // Stable, platform-invariant output. The contract is validated the same
   // way on every platform; only a violation prints a FAIL line above and
   // flips the exit code. On success the output is identical whether a
   // backend exists (fontconfig / CoreText / DirectWrite) or not.
   //
   if( rval == 0)
      printf( "systemfont: PASS\n");
   return( rval);
}

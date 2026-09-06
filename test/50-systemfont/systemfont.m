#import <MulleCG/MulleCG.h>

#include <string.h>


//
// System fonts vary per machine AND the test harness may run on a platform
// with no backend (e.g. the Windows cross-build under Wine). So this test
// checks the API *contract* on whatever platform it runs and prints stable,
// platform-invariant PASS lines.
//
// Contract:
//   available == YES  ->  enumeration returns >= 1 valid face
//                         AND resolve("sans-serif") yields an absolute path
//   available == NO   ->  enumeration is empty and resolve fails (quiet
//                         degrade; caller falls back to shipped fonts)
//
// Either way each check prints "<name>: PASS". A contract violation prints
// "<name>: FAIL ..." and the process exits non-zero.
//


//
// A descriptor from enumeration/resolution is valid iff it has a non-empty
// family and an absolute (leading '/') file path.
//
static BOOL   descriptor_is_valid( struct CGSystemFontDescriptor *d)
{
   if( ! d->familyUTF8String || ! d->familyUTF8String[ 0])
      return( NO);
   if( ! d->pathUTF8String || d->pathUTF8String[ 0] != '/')
      return( NO);
   return( YES);
}


static int   test_enumerate( BOOL available)
{
   struct CGSystemFontDescriptor   *descriptors;
   NSUInteger                      count;
   NSUInteger                      i;

   count       = 0;
   descriptors = NULL;
   CGSystemFontEnumerate( &descriptors, &count);

   if( ! available)
   {
      if( count != 0)
      {
         printf( "enumerate: FAIL (no backend but got %tu)\n", count);
         CGSystemFontDescriptorsFree( descriptors, count);
         return( 1);
      }
      return( 0);
   }

   if( count == 0)
   {
      printf( "enumerate: FAIL (backend present but no fonts)\n");
      return( 1);
   }

   for( i = 0; i < count; i++)
      if( ! descriptor_is_valid( &descriptors[ i]))
      {
         printf( "enumerate: FAIL (invalid descriptor at %tu)\n", i);
         CGSystemFontDescriptorsFree( descriptors, count);
         return( 1);
      }

   CGSystemFontDescriptorsFree( descriptors, count);
   return( 0);
}


static int   test_resolve( BOOL available)
{
   struct CGSystemFontQuery        query;
   struct CGSystemFontDescriptor   descriptor;
   BOOL                            matched;

   memset( &query, 0, sizeof( query));
   query.familyUTF8String = "sans-serif";
   query.weight           = CGSystemFontWeightBold;

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
      printf( "resolve: FAIL (backend present but no match)\n");
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
   BOOL   available;
   int    rval;

   available = CGSystemFontIsAvailable();

   rval  = 0;
   rval |= test_enumerate( available);
   rval |= test_resolve( available);

   //
   // Stable, platform-invariant output. The contract is validated the same
   // way on every platform; only a violation prints a FAIL line above and
   // flips the exit code. On success the output is identical whether a
   // backend exists (Linux/FreeBSD fontconfig) or not (e.g. Windows build).
   //
   if( rval == 0)
      printf( "systemfont: PASS\n");
   return( rval);
}

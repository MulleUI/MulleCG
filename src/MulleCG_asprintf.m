#import "MulleCG_asprintf.h"

#import "import-private.h"


char   *MulleCG_vasprintf( char *format, va_list args)
{
   char                  *s;
   struct mulle_buffer   buffer;

   if( ! format)
      return( NULL);

   mulle_buffer_init( &buffer, NULL);
   mulle_vsprintf( &buffer, format, args);
   mulle_buffer_add_byte( &buffer, 0);
   s = mulle_buffer_extract_bytes( &buffer);
   mulle_buffer_done( &buffer);

   MulleObjCAutoreleaseAllocation( s, NULL);

   return( s);
}


char   *MulleCG_asprintf( char *format, ...)
{
   va_list   args;
   char      *s;

   va_start( args, format);
   s = MulleCG_vasprintf( format, args);
   va_end( args);
   return( s);
}

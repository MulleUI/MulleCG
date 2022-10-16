#define _GNU_SOURCE

#import <MulleCG/MulleCG.h>

#include <time.h>

static void  random_delay()
{
   struct timespec  delay;

   delay.tv_sec = 0;
   delay.tv_nsec = random() % 1000;
   nanosleep( &delay, NULL);
}

static mulle_atomic_pointer_t   finished;


static int  run_stress( NSThread *thread, void *_context)
{
   CGContext      *context = _context;
   CGLayer        *layer;
   unsigned int   i;

   for( i = 0; i < 100000; i++)
   {
      layer = [context acquireRecycledFramebuffer];
      if( ! layer)
         layer = [NSAllocateObject( [NSObject class], 0, NULL) autorelease];
      random_delay();

      [context recycleFramebuffer:layer];
      random_delay();
   }
   _mulle_atomic_pointer_increment( &finished);

   return( 0);
}


int   main( int argc, char *argv[])
{
   CGContext   *context;

   context = [[CGContext alloc] initWithBackend:UIGraphicsBackendNone
                                        shareID:0
                                        options:0];

   [NSThread mulleDetachNewThreadWithFunction:(MulleThreadFunction_t *) run_stress
                                     argument:context];
   [NSThread mulleDetachNewThreadWithFunction:(MulleThreadFunction_t *) run_stress
                                     argument:context];
   [NSThread mulleDetachNewThreadWithFunction:(MulleThreadFunction_t *) run_stress
                                     argument:context];
   while( (intptr_t) _mulle_atomic_pointer_read( &finished) < 3)
      random_delay();

   [context release];
   return( 0);
}

//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
#import "CGContext+Render.h"

#import "import-private.h"


@implementation CGContext ( Render)

- (void) drawObjects:(struct mulle_pointerarray *) objects
{
   id <CGRenderObject>   obj;

   mulle_pointerarray_for( objects, obj)
   {
      [obj renderInContext:self];
   }
}

@end

//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
#include "CGAffineTransform+CString.h"

#include "include-private.h"

#include "MulleCG_asprintf.h"


char   *CGAffineTransformRefUTF8String( CGAffineTransform *xform)
{
   auto char  *s;

   s = MulleCG_asprintf( "%.3f %.3f %.3f %.3f %.3f %.3f",
            xform->a,
            xform->b,
            xform->c,
            xform->d,
            xform->tx,
            xform->ty);
   return( s);
}

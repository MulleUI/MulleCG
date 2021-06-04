//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
// prefer a local CGAffineTransform over one in import.h
#include "CGAffineTransform.h"


char   *CGAffineTransformRefCStringDescription( CGAffineTransform *xform);


static inline char   *CGAffineTransformCStringDescription( CGAffineTransform xform)
{
   return( CGAffineTransformRefCStringDescription( &xform));
}



//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
// prefer a local CGAffineTransform over one in import.h
#include "include.h"


char   *CGAffineTransformRefUTF8String( CGAffineTransform *xform);


static inline char   *CGAffineTransformUTF8String( CGAffineTransform xform)
{
   return( CGAffineTransformRefUTF8String( &xform));
}



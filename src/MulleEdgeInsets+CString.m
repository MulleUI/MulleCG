//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#include "MulleEdgeInsets+CString.h"

#include "include-private.h"

#include "MulleCG_asprintf.h"



// cast this to CGRect as the code is identical ?
char   *MulleEdgeInsetsCStringDescription( MulleEdgeInsets insets)
{
   auto char  *s;

   s = MulleCG_asprintf( "%.2f %.2f %.2f %.2f",
         insets.top,
         insets.left,
         insets.bottom,
         insets.right);
   return( s);
}

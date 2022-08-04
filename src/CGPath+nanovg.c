//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#include "CGPath+nanovg.h"

#include "include-private.h"


void   nvgAddCGPath( NVGcontext *nvg, CGPathRef path)
{
   unsigned int   n_commands;
   CGFloat        *f;
   unsigned char  *p;
   unsigned char  *sentinel;
   CGFloat         x, y;
   CGFloat         x1, y1;
   CGFloat         x2, y2;

   if( ! path)
      return;

   n_commands = mulle_buffer_get_length( &path->_commands);
   if( ! n_commands)
      return;

   p = mulle_buffer_get_bytes( &path->_commands);
   f = _mulle_structarray_get_first( &path->_floats);

   sentinel = &p[n_commands];
   while( p < sentinel)
   {
      switch( *p)
      {
      case CGPathMoveToPointCommand:
         x = *f++;
         y = *f++;
         nvgMoveTo(nvg, x, y);
         break;

      case CGPathAddLineCommand:
         x = *f++;
         y = *f++;
         nvgLineTo(nvg, x, y);
         break;

      case CGPathBezierCommand:
         x1 = *f++;
         y1 = *f++;
         x2 = *f++;
         y2 = *f++;
         x  = *f++;
         y  = *f++;
         nvgBezierTo(nvg, x1, y1, x2, y2, x, y);
         break;

      case CGPathCloseSubpathCommand:
         nvgClosePath(nvg);
         break;
      }
      ++p;
   }
}

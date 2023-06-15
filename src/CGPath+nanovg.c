//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#include "CGPath+nanovg.h"

#include "include-private.h"


void   mvgAddCGPath( NVGcontext *vg, CGPathRef path)
{
   unsigned int    n_commands;
   CGFloat        *f;
   unsigned char  *p;
   unsigned char  *sentinel;
   CGFloat         x, y;
   CGFloat         x1, y1;
   CGFloat         x2, y2;
   CGFloat         r;

   if( ! path)
      return;

   n_commands = mulle_buffer_get_length( &path->_commands);
   if( ! n_commands)
      return;

   p = mulle_buffer_get_bytes( &path->_commands);
   f = _mulle_floatarray_get_floats( &path->_floats);

   sentinel = &p[ n_commands];
   while( p < sentinel)
   {
      switch( *p)
      {
      case CGPathMoveCommand:
         x = *f++;
         y = *f++;
         nvgMoveTo( vg, x, y);
         break;

      case CGPathLineCommand:
         x = *f++;
         y = *f++;
         nvgLineTo( vg, x, y);
         break;

      case CGPathBezierCommand:
         x1 = *f++;
         y1 = *f++;
         x2 = *f++;
         y2 = *f++;
         x  = *f++;
         y  = *f++;
         nvgBezierTo( vg, x1, y1, x2, y2, x, y);
         break;

      case CGPathQuadCommand :
         x1 = *f++;
         y1 = *f++;
         x  = *f++;
         y  = *f++;
         nvgQuadTo( vg, x1, y1, x, y);
         break;

      case CGPathArcCommand :
         x1 = *f++;
         y1 = *f++;
         x  = *f++;
         y  = *f++;
         r  = *f++;
         nvgArcTo( vg, x1, y1, x2, y2, r);
         break;

      case CGPathWindingCommand :
         x = *f++;
         nvgPathWinding( vg, (int) x);
         break;

      case CGPathCloseSubpathCommand:
         nvgClosePath( vg);
         break;
      }
      ++p;
   }
}

//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#include "CGPath+nanovg.h"

#include "include-private.h"


// TODO: this could just be part of nanovg-extensions.inc
//       further more this could be added wholesale with nvg__appendCommands
void   mvgAddCGPath( NVGcontext *vg, CGPathRef path)
{
   unsigned int    n;
   float           *f;
   float           *sentinel;
   float           x, y;
   float           x1, y1;
   float           x2, y2;
   float           r;

   if( ! path)
      return;

   n        = _mulle_floatarray_get_count( &path->_floats);
   f        = _mulle_floatarray_get_floats( &path->_floats);
   sentinel = &f[ n];
   while( f < sentinel)
   {
      switch( (int) *f++)
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
   }
}

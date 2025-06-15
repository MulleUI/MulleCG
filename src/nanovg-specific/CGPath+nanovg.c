//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#include "include-private.h"

#include "CGTypes.h"

#include <assert.h>


// TODO: this could just be part of nanovg-extensions.inc
//       further more this could be added wholesale with nvg__appendCommands
void   mvgAddCGPath( NVGcontext *vg, CGPath *path)
{
   unsigned int    n;
   float           *f;
   float           *sentinel;
   float           x, y;
   float           x1, y1;
   float           x2, y2;
   float           r;
   float           dir;
   float           a0, a1;
   int             cmd;
#ifndef NDEBUG
   int            prev;
   int            prevprev;

   cmd      = -1;
   prevprev = -1;
#endif

   if( ! vg || ! path)
      return;

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wenum-compare"
#endif

   assert( CARotationDirectionCounterClockWise == NVG_CCW);
   assert( CARotationDirectionClockWise == NVG_CW);

   n        = _mulle_floatarray_get_count( &path->_floats);
   f        = _mulle_floatarray_get_floats( &path->_floats);
   sentinel = &f[ n];
   while( f < sentinel)
   {
#ifndef NDEBUG
      prevprev = prev;
      prev     = cmd;
#endif
      cmd  = (int) *f++;

      switch( cmd)
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
         x   = *f++;
         y   = *f++;
         r   = *f++;
         a0  = *f++;
         a1  = *f++;
         dir = *f++;
         nvgArc( vg, x, y, r, a0, a1, (int) dir);
         break;

      case CGPathFillStyleCommand :
         assert( prev != CGPathFillStyleCommand);
         assert( prevprev != CGPathFillStyleCommand);
         x = *f++;
         nvgPathWinding( vg, (int) x);
         break;

      case CGPathCloseSubpathCommand:
         assert( prev != CGPathCloseSubpathCommand);
         assert( prevprev != CGPathCloseSubpathCommand);
         nvgClosePath( vg);
         break;
      }
   }
}

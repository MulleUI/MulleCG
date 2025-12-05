//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#include "include-private.h"

#include "CGTypes.h"

#include <assert.h>
#include <math.h>


void   mvgAddCGPath( NVGcontext *vg, CGPath *path)
{
   unsigned int          n;
   float                 *f;
   float                 *sentinel;
   float                 x, y;
   float                 x1, y1;
   float                 x2, y2;
   int                   cmd;
   CGPoint               current_point;
   CGPoint               start_point;
   CACircle              circle;
   CAAngle               start_angle, end_angle;
   CARotationDirection   rotation_dir;
   int                   nvg_dir;

   if( ! vg || ! path)
      return;

#if defined(__GNUC__) || defined(__clang__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wenum-compare"
#endif

   assert( CARotationDirectionCounterClockWise == NVG_CCW);
   assert( CARotationDirectionClockWise == NVG_CW);

   // broken paths draw nothing
   current_point.x = -INFINITY;
   current_point.y = -INFINITY;
   start_point.x   = +INFINITY;  // easier for debug
   start_point.y   = -INFINITY;  // keep negative

   n        = _mulle_floatarray_get_count( &path->_floats);
   f        = _mulle_floatarray_get_floats( &path->_floats);
   sentinel = &f[ n];

   while( f < sentinel)
   {
      cmd  = (int) *f++;

      switch( cmd)
      {
      case CGPathMoveCommand:
         x = *f++;
         y = *f++;
         nvgMoveTo( vg, x, y);

         start_point = CGPointMake( x, y);  // need or close
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

      case CGPathCircleSegmentCommand:
         // Extract data
         x1     = *f++;
         y1     = *f++;
         x      = *f++;
         y      = *f++;

         // MEMO: nvgArcTo does something different :/
         // nvgArcTo( vg, x1, y1, x, y);

         circle      = CACircleMakeWithCenterAndPerimeter( CGPointMake(x1, y1), CGPointMake(x, y));

         // Get angles using CACircle functions
         start_angle = CACircleAngleAtPoint( circle, current_point);
         end_angle   = CACircleAngleAtPoint( circle, CGPointMake(x, y)); // Fixed: was end_point

         // Use existing function to determine rotation direction
         rotation_dir = CAAngleGetRotationDirection( start_angle, end_angle);
         nvg_dir      = (rotation_dir == CARotationDirectionCounterClockWise) ? NVG_CCW : NVG_CW;
         nvgArc( vg, x1, y1, circle.radius, start_angle, end_angle, nvg_dir);
         break;

      case CGPathCloseSubpathCommand:
         nvgClosePath( vg);
         x = start_point.x;
         y = start_point.y;
         break;  // do not advance current point

      case CGPathFillStyleCommand :
         x1 = *f++;
         nvgPathWinding( vg, x1 == CGPathFillStyleSolid ? NVG_SOLID : NVG_HOLE);
         continue;  // do not advance current point

      }
      current_point = CGPointMake( x, y);
   }
}

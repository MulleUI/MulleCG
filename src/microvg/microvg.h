#ifndef microvg_h__
#define microvg_h__

#include "include.h"

//     x1                       x2
//   y ---------------------------
//
//
// Draw a horizontal line from y1 to y2 in the given color.
//
void   mvgStrokeLineH( NVGcontext *vg, float x1, float x2, float y, NVGcolor color);


//   x
//   | y1
//   |
//   |
//   |
//   |
//   | y2
//
// Draw a vertical line from y1 to y2 in the given color.
//
void   mvgStrokeLineV( NVGcontext *vg, float x, float y1, float y2, NVGcolor color);

#endif 

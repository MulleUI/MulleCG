//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifndef cgpath_h__
#define cgpath_h__

#include "include.h"

#include <math.h>

// pure C file, can't use NS_ENUM
enum CGPathCommand
{
   CGPathMoveCommand         = 0,
   CGPathLineCommand         = 1,
   CGPathBezierCommand       = 2,
   CGPathCloseSubpathCommand = 3,
   CGPathWindingCommand      = 4,
   CGPathQuadCommand         = 5,
   CGPathArcCommand          = 6,
   CGPathArcToCommand        = 7
};


typedef uintptr_t  CGPathCommand;

//
// A CGPath can be useful, if you want to keep path information for multiple
// frames. It will likely also form the basis for creating and managing VBOs.
// A CGPath is not like a SVG, as it doesn't contain color, fill or strokeWidth
// information, so it's more low level. We probably need something like
// CGShape, CGVectorDrawing to support more higher level storage.
//

//
// This is always mutable, but CGMutablePathRef is kept in the API for
// slightly better compatibility.
//
// TODO: store commands in _floats for simplicity and compatiblilty with
//       nanovg
//
typedef struct CGPath
{
  struct mulle_floatarray   _floats;
  CGRect                    _bbox;
} CGPath;


typedef struct CGPath   *CGPathRef;
typedef CGPathRef        CGMutablePathRef;


// mulle additions
struct CGPath     *CGPathCreate( struct mulle_allocator *allocator);

void   _CGPathInit( struct CGPath *path, struct mulle_allocator *allocator);
void   _CGPathDone( struct CGPath *path);
void   CGPathDestroy( struct CGPath *path);

struct CGPath   *CGPathCopy( struct CGPath *path, struct mulle_allocator *allocator);


static inline struct mulle_allocator  *_CGPathGetAllocator( struct CGPath *path)
{
   return( mulle_floatarray_get_allocator( &path->_floats)); 
}


// should only be set
static inline void   _CGPathSetBounds( CGPathRef path, CGRect bbox)
{
   path->_bbox = bbox;
}


CGRect   CGPathComputeBounds( CGPathRef path);

// TODO: compute dynamically if not set
static inline CGRect   CGPathGetBounds( CGPathRef path)
{
   if( ! path)
      return( CGRectNull);
   if( CGRectIsNull( path->_bbox))
      path->_bbox = CGPathComputeBounds( path);
   return( path->_bbox);
}


//
// standard API was too weird...
// The names are supposed to be the same here, but use mulle-geometry.
// Many of the parameters are different as well, no transformation f.e.
// winding is different...
// https://developer.apple.com/documentation/coregraphics/1411201-cgpathaddpath?language=objc
//
static inline void  CGPathMoveToPoint( CGPathRef path, CGPoint point)
{
   if( ! path)
      return;

   _mulle_floatarray_guarantee( &path->_floats, 3);
   _mulle_floatarray_add_guaranteed( &path->_floats, CGPathMoveCommand);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.x);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.y);
}


static inline void  CGPathAddLineToPoint( CGPathRef path,
                                          CGPoint point)
{
   if( ! path)
      return;

   _mulle_floatarray_guarantee( &path->_floats, 3);
   _mulle_floatarray_add_guaranteed( &path->_floats, CGPathLineCommand);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.x);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.y);
}



static inline void  CGPathAddCurveToPoint( CGPathRef path,
                                           CGPoint control1,
                                           CGPoint control2,                                                                                  
                                           CGPoint point)
{
   if( ! path)
      return;

   _mulle_floatarray_guarantee( &path->_floats, 7);
   _mulle_floatarray_add_guaranteed( &path->_floats, CGPathBezierCommand);
   _mulle_floatarray_add_guaranteed( &path->_floats, control1.x);
   _mulle_floatarray_add_guaranteed( &path->_floats, control1.y);
   _mulle_floatarray_add_guaranteed( &path->_floats, control2.x);
   _mulle_floatarray_add_guaranteed( &path->_floats, control2.y);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.x);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.y);
}


static inline void  CGPathAddQuadToPoint( CGPathRef path,
                                          CGPoint control1,
                                          CGPoint point)
{
   if( ! path)
      return;

   _mulle_floatarray_guarantee( &path->_floats, 5);
   _mulle_floatarray_add_guaranteed( &path->_floats, CGPathQuadCommand);
   _mulle_floatarray_add_guaranteed( &path->_floats, control1.x);
   _mulle_floatarray_add_guaranteed( &path->_floats, control1.y);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.x);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.y);
}


static inline void  CGPathAddArcToPoint( CGPathRef path,
                                         CGPoint control1,
                                         CGPoint point,
                                         CGFloat radius)
{
   if( ! path)
      return;

   _mulle_floatarray_guarantee( &path->_floats, 6);
   _mulle_floatarray_add_guaranteed( &path->_floats, CGPathArcCommand);
   _mulle_floatarray_add_guaranteed( &path->_floats, control1.x);
   _mulle_floatarray_add_guaranteed( &path->_floats, control1.y);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.x);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.y);
   _mulle_floatarray_add_guaranteed( &path->_floats, radius);
}


static inline void  CGPathAddArcWithCenter( CGPathRef path,
                                                 CGPoint point,
                                                 CGFloat radius,
                                                 CAAngle a0,
                                                 CAAngle a1,
                                                 int direction)
{
   if( ! path)
      return;

   _mulle_floatarray_guarantee( &path->_floats, 7);
   _mulle_floatarray_add_guaranteed( &path->_floats, CGPathArcCommand);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.x);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.y);
   _mulle_floatarray_add_guaranteed( &path->_floats, radius);
   _mulle_floatarray_add_guaranteed( &path->_floats, CAAngleToRadians( a0));
   _mulle_floatarray_add_guaranteed( &path->_floats, CAAngleToRadians( a1));
   _mulle_floatarray_add_guaranteed( &path->_floats, (float) direction);
}


static inline void  CGPathAddWinding( CGPathRef path, int value)
{
   float   v;

   if( ! path)
      return;

   assert( value == NVG_HOLE || value == NVG_SOLID);
   v = (float) value;
   _mulle_floatarray_guarantee( &path->_floats, 2);
   _mulle_floatarray_add_guaranteed( &path->_floats, CGPathWindingCommand);
   _mulle_floatarray_add( &path->_floats, v);
}


static inline void  CGPathCloseSubpath( CGMutablePathRef path)
{
   if( ! path)
      return;

   _mulle_floatarray_add( &path->_floats, CGPathCloseSubpathCommand);
}



// alternative API: 
static inline struct CGPath   *CGPathCreateMutable( void)
{
   return( CGPathCreate( NULL));
}


static inline void  CGPathMoveTo( CGPathRef path, 
                                  CGAffineTransform *xform,
                                  float x, float y)
{
   CGPathMoveToPoint( path, CGPointMake( x, y));
}


static inline void  CGPathAddLineTo( CGPathRef path,
                                     CGAffineTransform *xform,
                                     float x, float y)
{
   CGPathAddLineToPoint( path, CGPointMake( x, y));
}


static inline void  CGPathAddCurveTo( CGPathRef path,
                                      CGAffineTransform *xform,
                                      float c1x, float c1y,
                                      float c2x, float c2y,
                                      float x, float y)
{
   CGPathAddCurveToPoint( path, CGPointMake( c1x, c1y),
                                CGPointMake( c2x, c2y),
                                CGPointMake( x, y));
}


static inline void  CGPathAddQuadTo( CGPathRef path,
                                     CGAffineTransform *xform,
                                     float cx, float cy,
                                     float x, float y)
{
   CGPathAddQuadToPoint( path, CGPointMake( cx, cy),
                               CGPointMake( x, y));
}


static inline void  CGPathAddArcTo( CGPathRef path,
                                    CGAffineTransform *xform,
                                    float cx, float cy,
                                    float x, float y,
                                    float r)
{
   CGPathAddArcToPoint( path, CGPointMake( cx, cy),
                              CGPointMake( x, y),
                              r);
}


static inline void  CGPathAddArc( CGPathRef path,
                                  CGAffineTransform *xform,
                                  float cx, float cy,
                                  float r,
                                  float a0, float a1,
                                  int direction)
{
   CGPathAddArcWithCenter( path, CGPointMake( cx, cy),
                                      r,
                                      CARadiansToAngle( a0),
                                      CARadiansToAngle( a1),
                                      direction);
}


#endif

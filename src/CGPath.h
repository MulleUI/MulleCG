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
   CGPathMoveCommand,
   CGPathLineCommand,
   CGPathQuadCommand,
   CGPathArcCommand,
   CGPathBezierCommand,
   CGPathWindingCommand,
   CGPathCloseSubpathCommand
};

typedef uintptr_t  CGPathCommand;

// A CGPath can be useful, if you want to keep path information for multiple
// frames. It will likely also form the basis for creating and managing VBOs
//
// This is always mutable, but CGMutablePathRef is kept in the API for
// slightly better compatibility.
//
typedef struct CGPath
{
  struct mulle_buffer        _commands;
  struct mulle_floatarray    _floats;
  CGRect                     _bbox;
  unsigned char              _initialStorage[ 8];
} CGPath;


typedef struct CGPath   *CGPathRef;
typedef CGPathRef        CGMutablePathRef;


// mulle additions
struct CGPath     *CGPathCreate( struct mulle_allocator *allocator);

void   _CGPathInit( struct CGPath *path, struct mulle_allocator *allocator);
void   _CGPathDone( struct CGPath *path);
void   CGPathDestroy( struct CGPath *path);


// should only be set
static inline void   _CGPathSetBoundingBox( CGPathRef path, CGRect bbox)
{
   path->_bbox = bbox;
}


CGRect   CGPathComputeBoundingBox( CGPathRef path);

// TODO: compute dynamically if not set
static inline CGRect   CGPathGetBoundingBox( CGPathRef path)
{
   if( ! path)
      return( CGRectNull);

   if( CGRectIsNull( path->_bbox))
      path->_bbox = CGPathComputeBoundingBox( path);
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

   mulle_buffer_add_byte( &path->_commands, CGPathMoveCommand);
   _mulle_floatarray_guarantee( &path->_floats, 2);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.x);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.y);
}


static inline void  CGPathAddLineToPoint( CGPathRef path,
                                          CGPoint point)
{
   if( ! path)
      return;

   mulle_buffer_add_byte( &path->_commands, CGPathLineCommand);
   _mulle_floatarray_guarantee( &path->_floats, 2);
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

   mulle_buffer_add_byte( &path->_commands, CGPathBezierCommand);
   _mulle_floatarray_guarantee( &path->_floats, 6);
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

   mulle_buffer_add_byte( &path->_commands, CGPathQuadCommand);
   _mulle_floatarray_guarantee( &path->_floats, 4);
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

   mulle_buffer_add_byte( &path->_commands, CGPathArcCommand);
   _mulle_floatarray_guarantee( &path->_floats, 5);
   _mulle_floatarray_add_guaranteed( &path->_floats, control1.x);
   _mulle_floatarray_add_guaranteed( &path->_floats, control1.y);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.x);
   _mulle_floatarray_add_guaranteed( &path->_floats, point.y);
   _mulle_floatarray_add_guaranteed( &path->_floats, radius);
}


static inline void  CGPathAddWinding( CGPathRef path, int value)
{
   float   v;

   if( ! path)
      return;

   assert( value == NVG_HOLE || value == NVG_SOLID);
   v = (float) value;
   mulle_buffer_add_byte( &path->_commands, CGPathWindingCommand);
   _mulle_floatarray_add( &path->_floats, v);
}


static inline void  CGPathCloseSubpath( CGMutablePathRef path)
{
   if( ! path)
      return;

   mulle_buffer_add_byte( &path->_commands, CGPathCloseSubpathCommand);
}



// alternative API: kind of useful if you want to switch via CGPath
// and nanovg via a pointer
static inline void  CGPathMoveTo( CGPathRef path, float x, float y)
{
   CGPathMoveToPoint( path, CGPointMake( x, y));
}


static inline void  CGPathAddLineTo( CGPathRef path,
                                     float x, float y)
{
   CGPathAddLineToPoint( path, CGPointMake( x, y));
}


static inline void  CGPathAddCurveTo( CGPathRef path,
                                      float c1x, float c1y,
                                      float c2x, float c2y,
                                      float x, float y)
{
   CGPathAddCurveToPoint( path, CGPointMake( c1x, c1y),
                                CGPointMake( c2x, c2y),
                                CGPointMake( x, y));
}


static inline void  CGPathAddQuadTo( CGPathRef path,
                                      float cx, float cy,
                                      float x, float y)
{
   CGPathAddQuadToPoint( path, CGPointMake( cx, cy),
                               CGPointMake( x, y));
}


static inline void  CGPathAddArcTo( CGPathRef path,
                                    float cx, float cy,
                                    float x, float y,
                                    float r)
{
   CGPathAddArcToPoint( path, CGPointMake( cx, cy),
                              CGPointMake( x, y),
                              r);
}


#endif

//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifndef cgpath_h__
#define cgpath_h__

#include "include.h"


// pure C file, can't use NS_ENUM
enum CGPathCommand
{
   CGPathMoveToPointCommand,
   CGPathAddLineCommand,
   CGPathBezierCommand,
   CGPathCloseSubpathCommand
};

typedef uintptr_t  CGPathCommand;

//
// this is always mutable, but CGMutablePathRef is kept in the API for
// somewhat better compatiblity
//
typedef struct CGPath
{
  struct mulle_buffer        _commands;
  struct mulle_structarray   _floats;
  unsigned char              _initialStorage[ 8];
} CGPath;


typedef struct CGPath   *CGPathRef;
typedef CGPathRef        CGMutablePathRef;


// mulle additions
struct CGPath     *CGPathCreate( struct mulle_allocator *allocator);
void   _CGPathInit( struct CGPath *path, struct mulle_allocator *allocator);
void   _CGPathDone( struct CGPath *path);
void   CGPathDestroy( struct CGPath *path);


//
// standard API was to weird...
//
static void inline  CGPathMoveToPoint( CGPath *path,
                                       CGPoint point)
{
   if( ! path)
      return;

   mulle_buffer_add_byte( &path->_commands, CGPathMoveToPointCommand);
   _mulle_structarray_add( &path->_floats, &point.x);
   _mulle_structarray_add( &path->_floats, &point.y);
}


static void inline  CGPathAddLineToPoint( CGMutablePathRef path,
                                          CGPoint point)
{
   if( ! path)
      return;

   mulle_buffer_add_byte( &path->_commands, CGPathAddLineCommand);
   _mulle_structarray_add( &path->_floats, &point.x);
   _mulle_structarray_add( &path->_floats, &point.y);
}



static void inline  CGPathAddCurveToPoint( CGMutablePathRef path,
                                           CGPoint control1,
                                           CGPoint control2,                                                                                  
                                           CGPoint point)
{
   if( ! path)
      return;

   mulle_buffer_add_byte( &path->_commands, CGPathBezierCommand);
   _mulle_structarray_add( &path->_floats, &control1.x);
   _mulle_structarray_add( &path->_floats, &control1.y);
   _mulle_structarray_add( &path->_floats, &control2.x);
   _mulle_structarray_add( &path->_floats, &control2.y);
   _mulle_structarray_add( &path->_floats, &point.x);
   _mulle_structarray_add( &path->_floats, &point.y);
}



static void inline  CGPathCloseSubpath( CGMutablePathRef path)
{
   if( ! path)
      return;

   mulle_buffer_add_byte( &path->_commands, CGPathCloseSubpathCommand);
}


#endif

//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifndef cgpath_h__
#define cgpath_h__

#include "include.h"


enum CGPathCommand
{
   CGPathMoveToPointCommand,
   CGPathAddLineCommand,
   CGPathBezierCommand,
   CGPathCloseSubpathCommand
};


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


// standard API...
static void inline  CGPathMoveToPoint( CGMutablePathRef path,
                                       const CGAffineTransform *m,
                                       CGFloat x,
                                       CGFloat y)
{
   if( ! path)
      return;
   assert( ! m);

   mulle_buffer_add_byte( &path->_commands, CGPathMoveToPointCommand);
   _mulle_structarray_add( &path->_floats, &x);
   _mulle_structarray_add( &path->_floats, &y);
}


static void inline  CGPathAddLineToPoint( CGMutablePathRef path,
                                          const CGAffineTransform *m,
                                          CGFloat x,
                                          CGFloat y)
{
   if( ! path)
      return;
   assert( ! m);

   mulle_buffer_add_byte( &path->_commands, CGPathAddLineCommand);
   _mulle_structarray_add( &path->_floats, &x);
   _mulle_structarray_add( &path->_floats, &y);
}



static void inline  CGPathBezierToPoint( CGMutablePathRef path,
                                         const CGAffineTransform *m,
                                         CGFloat x1,
                                         CGFloat y1,
                                         CGFloat x2,
                                         CGFloat y2,                                                                                  
                                         CGFloat x,
                                         CGFloat y)
{
   if( ! path)
      return;
   assert( ! m);

   mulle_buffer_add_byte( &path->_commands, CGPathBezierCommand);
   _mulle_structarray_add( &path->_floats, &x1);
   _mulle_structarray_add( &path->_floats, &y1);
   _mulle_structarray_add( &path->_floats, &x2);
   _mulle_structarray_add( &path->_floats, &y2);
   _mulle_structarray_add( &path->_floats, &x);
   _mulle_structarray_add( &path->_floats, &y);
}



static void inline  CGPathCloseSubpath( CGMutablePathRef path)
{
   if( ! path)
      return;

   mulle_buffer_add_byte( &path->_commands, CGPathCloseSubpathCommand);
}


#endif

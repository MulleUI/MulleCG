//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#include "CGPath.h"

#include "include-private.h"

void   _CGPathInit( struct CGPath *path, struct mulle_allocator *allocator)
{
   path->_bbox = CGRectNull;
   _mulle_floatarray_init( &path->_floats, 32, allocator);
}


void   _CGPathInitWithCapacity( struct CGPath *path,
                                unsigned int n,
                                struct mulle_allocator *allocator)
{
   path->_bbox = CGRectNull;
   _mulle_floatarray_init( &path->_floats, n, allocator);
}


struct CGPath   *CGPathCreate( struct mulle_allocator *allocator)
{
   CGMutablePathRef   path;

   path = mulle_allocator_malloc( allocator, sizeof( struct CGPath));
   _CGPathInit( path, allocator);
   return( path);
}


struct CGPath   *CGPathCopy( struct CGPath *path, struct mulle_allocator *allocator)
{
   struct CGPath   *copy;

   if( ! path)
      return( path);

   copy = mulle_allocator_malloc( allocator, sizeof( struct CGPath));
   _CGPathInitWithCapacity( copy, mulle_floatarray_get_count( &path->_floats), allocator);
   copy->_bbox = path->_bbox;
   mulle_floatarray_copy( &copy->_floats, &path->_floats);
   return( copy);
}


void   _CGPathDone( struct CGPath *path)
{
   _mulle_floatarray_done( &path->_floats);
}


void CGPathDestroy( struct CGPath *path)
{
   struct mulle_allocator *allocator;

   if( ! path)
      return;

   allocator = _mulle_floatarray_get_allocator( &path->_floats);
   _CGPathDone( path);
   mulle_allocator_free( allocator, path);
}


CGRect   CGPathComputeCoarseBounds( CGPathRef path)
{
   unsigned int    n;
   float           *f;
   float           *sentinel;
   float           a0;
   float           a1;
   float           dir;
   float           tmp;
   float           radius;
   CGPoint         point;
   CGRect          bbox;
   CACircle        c;

   bbox     = CGRectNull; // sic!
   n        = _mulle_floatarray_get_count( &path->_floats);
   f        = _mulle_floatarray_get_floats( &path->_floats);
   sentinel = &f[ n];

   while( f < sentinel)
   {
      switch( (int) *f++)
      {
      case CGPathMoveCommand:
         point.x = *f++;
         point.y = *f++;
         bbox    = CGRectEnclosePoint( bbox, point);
         break;

      case CGPathLineCommand:
         point.x = *f++;
         point.y = *f++;
         bbox    = CGRectEnclosePoint( bbox, point);
         break;

         // TODO: this is probably OK for coarse
         // https://stackoverflow.com/questions/2587751/an-algorithm-to-find-bounding-box-of-closed-bezier-curves/2588205#2588205
      case CGPathBezierCommand:
         point.x = *f++;
         point.y = *f++;
         bbox    = CGRectEnclosePoint( bbox, point);
         point.x = *f++;
         point.y = *f++;
         bbox    = CGRectEnclosePoint( bbox, point);
         point.x = *f++;
         point.y = *f++;
         bbox    = CGRectEnclosePoint( bbox, point);
         break;

         // TODO: this is maybe crap, cubic is likely different
      case CGPathQuadCommand :
         point.x = *f++;
         point.y = *f++;
         bbox    = CGRectEnclosePoint( bbox, point);
         point.x = *f++;
         point.y = *f++;
         bbox    = CGRectEnclosePoint( bbox, point);
         break;

         // TODO: this is total crap (radius is ignored)
      case CGPathArcToCommand :
         point.x = *f++;
         point.y = *f++;
         bbox    = CGRectEnclosePoint( bbox, point);
         point.x = *f++;
         point.y = *f++;
         bbox    = CGRectEnclosePoint( bbox, point);
         (void)    *f++;
         break;

         // TODO: this is crap angles are ignored
      case CGPathArcCommand :
         point.x = *f++;
         point.y = *f++;
         radius  = *f++;
         a0      = *f++;
         a1      = *f++;
         dir     = *f++;
         if( dir == (float) NVG_CCW)
         {
            tmp = a0;
            a0  = a1;
            a1  = tmp;
         }
         c       = CACircleMake( point, radius);
         bbox    = CGRectUnion( bbox, CACircleOuterRectOfSector( c, a0, a1));
         break;

      case CGPathWindingCommand :
         (void)    *f++;
         break;

      case CGPathCloseSubpathCommand :
         break;
      }
   }
   return( bbox);
}


CGRect   CGPathComputeBounds( CGPathRef path)
{
   if( ! path)
      return( CGRectNull);

   if( ! CGRectIsNull( path->_bbox))
      return( path->_bbox);

   path->_bbox = CGPathComputeCoarseBounds( path);
   return( path->_bbox);
}

//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"

struct CGPath;


typedef NS_ENUM( NSUInteger, CGRelation)
{
   CGInside,
   CGCover,
   CGOutside,
   CGOverlap
};


static inline CGRect
   CGRectMakeFillRect( CGRect rect, CGFloat strokeWidth, CGRelation relation)
{
   switch( relation)
   {
   case CGInside  :
      rect.origin.x    += strokeWidth / 2.0;
      rect.origin.y    += strokeWidth / 2.0;
      rect.size.width  -= strokeWidth;
      rect.size.height -= strokeWidth;
      break;

   case CGCover   :
      rect.origin.x    -= strokeWidth / 2.0;
      rect.origin.y    -= strokeWidth / 2.0;
      rect.size.width  += strokeWidth;
      rect.size.height += strokeWidth;
      break;

   // useless
   case CGOutside :
      rect.origin.x    -= strokeWidth;
      rect.origin.y    -= strokeWidth;
      rect.size.width  += strokeWidth * 2.0;
      rect.size.height += strokeWidth * 2.0;
   }
   return( rect);
}


static inline CGRect
   CGRectMakeStrokeRect( CGRect rect, CGFloat strokeWidth, CGRelation relation)
{
   switch( relation)
   {
   case CGInside  :
   case CGCover   :
      rect.origin.x    += strokeWidth / 2.0;
      rect.origin.y    += strokeWidth / 2.0;
      rect.size.width  -= strokeWidth;
      rect.size.height -= strokeWidth;
      break;

   case CGOutside   :
      rect.origin.x    -= strokeWidth / 2.0;
      rect.origin.y    -= strokeWidth / 2.0;
      rect.size.width  += strokeWidth;
      rect.size.height += strokeWidth;
      break;
   }
   return( rect);
}


static inline CGFloat  CGRectGetStrokeMinX( CGRect rect, CGFloat strokeWidth)
{
   return( CGRectGetMinX( rect) + strokeWidth / 2.0);
}


static inline CGFloat  CGRectGetStrokeMaxX( CGRect rect, CGFloat strokeWidth)
{
   return( CGRectGetMaxX( rect) - strokeWidth / 2.0);
}


static inline CGFloat  CGRectGetStrokeMinY( CGRect rect, CGFloat strokeWidth)
{
   return( CGRectGetMinY( rect) + strokeWidth / 2.0);
}


static inline CGFloat  CGRectGetStrokeMaxY( CGRect rect, CGFloat strokeWidth)
{
   return( CGRectGetMaxY( rect) - strokeWidth / 2.0);
}




@interface CGContext( Drawing) <UIGraphicsDrawing>

// this is not part of UIGraphicsDrawing
- (void) drawIcon:(mulle_utf32_t) icon
          atPoint:(CGPoint) rect;
@end


static inline void  CGContextDrawText( CGContext *self, 
                                       CGFloat x, 
                                       CGFloat y, 
                                       char *s, 
                                       CGFloat fontSize, 
                                       CGColor color)
{
   [self drawAtPoint:CGPointMake( x, y)
      textUTF8String:s
  fontNameUTF8String:NULL
            fontSize:fontSize
            hexColor:CGHexColorMakeWithColor( color)];
}


static inline void   CGContextDrawIconInRect( CGContext *self,
                                              mulle_utf32_t icon,
                                              CGRect rect)
{
   [self drawIcon:icon
          atPoint:CGRectGetCenterPoint( rect)];
}


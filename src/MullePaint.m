//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "MullePaint.h"

#import "import-private.h"

#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

#include "CGImage.h"


//
// gradients in nanovg are somewhat ephemeral, you create them on the fly and
// you don't have to dispose of them (apparently)
//
@implementation MullePaint


//
// the paint is valid for the NVGcontext only, but the nvg context is
// not kept by the paint, and the nvgContext doesnt keep the paint
//
- (instancetype) initBoxGradientWithRect:(CGRect) rect
                            cornerRadius:(CGFloat) cornerRadius
                                 feather:(CGFloat) feather
                              innerColor:(CGColor) innerColor
                              outerColor:(CGColor) outerColor
                                 context:(CGContext *) context
{
   // todo move to CGContext
   _paint = nvgBoxGradient( CGContextGetNVGContext( context),
                            rect.origin.x,
                            rect.origin.y,
                            rect.size.width,
                            rect.size.height,
                            cornerRadius,
                            feather,
                            innerColor,
                            outerColor);
   _context = context;
   return( self);
}


+ (instancetype) boxGradientWithRect:(CGRect) point
                        cornerRadius:(CGFloat) cornerRadius
                             feather:(CGFloat) feather
                          innerColor:(CGColor) innerColor
                          outerColor:(CGColor) outerColor
                             context:(CGContext *) context
{
   return( [[[self alloc] initBoxGradientWithRect:point
                                     cornerRadius:cornerRadius
                                          feather:feather
                                       innerColor:innerColor
                                       outerColor:outerColor
                                          context:context] autorelease]);
}



//
// the paint is valid for the NVGcontext only, but the nvg context is
// not kept by the paint, and the nvgContext doesnt keep the paint
//
- (instancetype) initRadialGradientWithCenterPoint:(CGPoint) point
                                       innerRadius:(CGFloat) innerRadius
                                       outerRadius:(CGFloat) outerRadius
                                        innerColor:(CGColor) innerColor
                                        outerColor:(CGColor) outerColor
                                          context:(CGContext *) context
{
   // todo move to CGContext
   _paint = nvgRadialGradient( CGContextGetNVGContext( context),
                               point.x,
                               point.y,
                               innerRadius,
                               outerRadius,
                               innerColor,
                               outerColor);
   _context = context;
   return( self);
}


+ (instancetype) radialGradientCenterPoint:(CGPoint) point
                               innerRadius:(CGFloat) innerRadius
                               outerRadius:(CGFloat) outerRadius
                                innerColor:(CGColor) innerColor
                                outerColor:(CGColor) outerColor
                                   context:(CGContext *) context
{
   return( [[[self alloc] initRadialGradientWithCenterPoint:point
                                                innerRadius:innerRadius
                                                outerRadius:outerRadius
                                                 innerColor:innerColor
                                                 outerColor:outerColor
                                                    context:context] autorelease]);
}


//
// the paint is valid for the NVGcontext only, but the nvg context is
// not kept by the paint, and the nvgContext doesnt keep the paint
//
- (instancetype) initLinearGradientWithRect:(CGRect) rect
                                 innerColor:(CGColor) innerColor
                                 outerColor:(CGColor) outerColor
                                    context:(CGContext *) context
{
   // todo move to CGContext
   _paint = nvgLinearGradient( CGContextGetNVGContext( context),
                               CGRectGetMinX( rect),
                               CGRectGetMinY( rect),
                               CGRectGetMaxX( rect),
                               CGRectGetMaxY( rect),
                               innerColor,
                               outerColor);
   _context = context;
   return( self);
}


+ (instancetype) linearGradientWithRect:(CGRect) rect
                             innerColor:(CGColor) innerColor
                             outerColor:(CGColor) outerColor
                                context:(CGContext *) context
{
   return( [[[self alloc] initLinearGradientWithRect:rect
                                          innerColor:innerColor
                                          outerColor:outerColor
                                             context:context] autorelease]);
}



- (instancetype) initPatternWithImage:(CGImage *) image
                                 rect:(CGRect) rect
                                angle:(CGFloat) angle
                                alpha:(CGFloat) alpha
                              context:(CGContext *) context
{
   int   imageID;

   image = [image cgImageWithContext:context
                          imageFlags:[image imageFlags]];

   if( image)
   {
      [self release];
      return( nil);
   }
//   CGSize    size;
//
//   size = [image size];
   imageID = [image imageID];
   if( imageID == -1)
   {
      assert( 0);
      [self release];
      return( nil);
   }
   _paint  = nvgImagePattern( CGContextGetNVGContext( context),
                             CGRectGetMinX( rect),
                             CGRectGetMinY( rect),
                             CGRectGetMaxX( rect),
                             CGRectGetMaxY( rect),
       	                    angle,
                             imageID,
                             alpha);

   assert( _paint.image == imageID);
   _context = context;
   _image   = [image retain]; // retain for _paint.image
   return( self);
}


+ (instancetype) patternWithImage:(CGImage *) image
                             rect:(CGRect) rect
                            angle:(CGFloat) angle
                            alpha:(CGFloat) alpha
                          context:(CGContext *) context;
{
   return( [[[self alloc] initPatternWithImage:image
                                          rect:rect
                                         angle:angle
                                         alpha:alpha
                                       context:context] autorelease]);
}


- (NSInteger) nvgImageWithContext:(CGContext *) context
{
   if( context == _context)
      return( _paint.image);
   return( -1);
}


- (CGColor) innerColor
{
   return( _paint.innerColor);
}


- (CGColor) outerColor
{
   return( _paint.outerColor);
}


- (CGFloat) radius
{
   return( _paint.radius);
}


- (CGFloat) feather
{
   return( _paint.feather);
}


- (struct NVGpaint) nvgPaint
{
   return( _paint);
}

@end

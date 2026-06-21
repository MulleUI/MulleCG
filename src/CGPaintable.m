//
// Copyright (c) 2022 Nat!, Mulle kybernetiK
//
#import "CGPaintable.h"
#import "CGContext+Drawing.h"
#import "CGGradient.h"
#import "CGGradient+Private.h"
#import "CGImage.h"
#import "CGImagePaint.h"
#import "CGBlendedPaint.h"

#import "import-private.h"


@implementation  CGPaintable


- (void) fillWithBounds:(CGRect) bounds
                options:(struct CGFillOptions *) options
                context:(CGContext *) context
{
   MULLE_C_UNUSED( bounds);
   MULLE_C_UNUSED( options);
   MULLE_C_UNUSED( context);
   // subclasses must override
   MULLE_OBJC_SUBCLASS_REQUIRES_IMPLEMENTATION;
}


- (void) strokeWithBounds:(CGRect) bounds
              strokeWidth:(CGFloat) strokeWidth
                  options:(struct CGStrokeOptions *) options
                  context:(CGContext *) context
{
   MULLE_C_UNUSED( bounds);
   MULLE_C_UNUSED( strokeWidth);
   MULLE_C_UNUSED( options);
   MULLE_C_UNUSED( context);
   // subclasses must override
   MULLE_OBJC_SUBCLASS_REQUIRES_IMPLEMENTATION;
}


- (CGImage *) image
{
   return( nil);
}


- (CGImage *) otherImage
{
   return( nil);
}


@end


@implementation CGPaint( CGPaintable)
@end


void   CGContextFillPaintableOptions( CGContext *context,
                                      id <CGPaintable> paint,
                                      CGRect bounds,
                                      CGFillOptions *options)
{
   static CGFillOptions   CGDefaultFillOptions_static = CGFillOptionsDefault;

   if( options)
      bounds = CGRectMakeFillRect( bounds, options->strokeWidth, options->relation);
   else
      options = &CGDefaultFillOptions_static;

   [paint fillWithBounds:bounds
                 options:options
                 context:context];
}


void   CGContextStrokePaintableOptions( CGContext *context,
                                        id <CGPaintable> paint,
                                        CGRect  bounds,
                                        CGFloat strokeWidth,
                                        CGStrokeOptions *options)
{
   static CGStrokeOptions   CGDefaultStrokeOptions_static = CGStrokeOptionsDefault;

   assert( strokeWidth > 0.0f);

   options  = options ? options : &CGDefaultStrokeOptions_static;
   bounds   = CGRectMakeStrokeRect( bounds, strokeWidth, options->relation);

   [paint strokeWithBounds:bounds
               strokeWidth:strokeWidth
                   options:options
                   context:context];
}

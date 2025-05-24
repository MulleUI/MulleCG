//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGPaint+nanovg.h"

#import "import-private.h"

#import "CGContext.h"
#import "CGContext+Drawing.h"

#import "CGGradient.h"
#import "CGImage.h"
#import "CGPaint+Private.h"
#import "CGTypes.h"


// why is this good ?
// #define NIL_PAINT_DRAWS_BLACK


@interface CGPaint( nanovg_Subclasses)

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                   paintOptions:(struct CGPaintOptions *) options
                        context:(CGContext *) context;

@end


@implementation CGPaint( nanovg)

#ifndef NDEBUG
static void   assertImageInNVGcontext( CGImage *self, NVGcontext *vg)
{
   CGContext   *otherContext;
   NVGcontext  *otherVG;

   if( ! self)
      return;

   otherContext = [self context];
   // circumvent otherContext assert with underscpre function, because we want
   // our more descriptive text
   otherVG      = _CGContextGetNVGContext( otherContext);
   assert( vg == otherVG && "paint image should belong to same context");
}


static void   assertPaintInNVGcontext( CGPaint *self, NVGcontext *vg)
{
   assertImageInNVGcontext( [self image], vg);
   assertImageInNVGcontext( [self otherImage], vg);
}
#else
# define assertImageInNVGcontext( self, vg)
# define assertPaintInNVGcontext( self, vg)
#endif




void   CGContextFillPaintWithOptions( CGContext *context,
                                      CGPaint *paint,
                                      CGRect  bounds,
                                      CGFillOptions *options)
{
   static CGFillOptions   CGDefaultFillOptions_static =  CGFillOptionsDefault;
   NVGpaint               nvgPaint;

   assertPaintInNVGcontext( paint, CGContextGetNVGContext( context));

   if( options)
      bounds = CGRectMakeFillRect( bounds, options->fillStrokeWidth, options->relation);
   else
      options = &CGDefaultFillOptions_static;

   nvgPaint = [paint NVGpaintWithBounds:bounds
                           paintOptions:&options->paint
                                context:context];
   nvgFillPaint( CGContextGetNVGContext( context), nvgPaint);
}


void   CGContextStrokePaintWithOptions( CGContext *context,
                                        CGPaint *paint,
                                        CGRect  bounds,
                                        CGFloat strokeWidth,
                                        CGStrokeOptions *options)
{
   static CGStrokeOptions   CGDefaultStrokeOptions_static = CGStrokeOptionsDefault;
   NVGpaint                 nvgPaint;


   assertPaintInNVGcontext( paint, CGContextGetNVGContext( context));
   assert( strokeWidth > 0.0f);

   options  = options ? options : &CGDefaultStrokeOptions_static;
   bounds   = CGRectMakeStrokeRect( bounds, strokeWidth, options->relation);
   nvgPaint = [paint NVGpaintWithBounds:bounds
                           paintOptions:&options->paint
                                context:context];

   nvgStrokePaint( CGContextGetNVGContext( context), nvgPaint);
}

@end



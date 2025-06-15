//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "CGPaint.h"

#import "import-private.h"

#import "CGTypes.h"
#import "CGContext+Drawing.h"
#import "CGPaint+Drawing.h"
#import "CGContext+CGImage.h"
#import "CGImage.h"


@implementation CGPaint( CGPaintable)  

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                   paintOptions:(struct CGPaintOptions *) options
                        context:(CGContext *) context
{
   // subclasses do this
   abort();
   return( (NVGpaint){ 0});
} 
                       
@end



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


static void   assertPaintableInNVGcontext( id <CGPaintable> self, NVGcontext *vg)
{
   assert( [(NSObject *) self conformsToProtocol:@protocol( CGPaintable)]);

   assertImageInNVGcontext( [self image], vg);
   assertImageInNVGcontext( [self otherImage], vg);
}
#else
# define assertImageInNVGcontext( self, vg)
# define assertPaintInNVGcontext( self, vg)
#endif



void   CGContextFillPaintableOptions( CGContext *context,
                                      id <CGPaintable> paint,
                                      CGRect  bounds,
                                      CGFillOptions *options)
{
   static CGFillOptions   CGDefaultFillOptions_static = CGFillOptionsDefault;
   NVGpaint               nvgPaint;

   assertPaintableInNVGcontext( paint, CGContextGetNVGContext( context));

   if( options)
      bounds = CGRectMakeFillRect( bounds, options->strokeWidth, options->relation);
   else
      options = &CGDefaultFillOptions_static;

   nvgPaint = [paint NVGpaintWithBounds:bounds
                           paintOptions:&options->paint
                                context:context];
   nvgFillPaint( CGContextGetNVGContext( context), nvgPaint);
}


void   CGContextStrokePaintableOptions( CGContext *context,
                                        id <CGPaintable> paint,
                                        CGRect  bounds,
                                        CGFloat strokeWidth,
                                        CGStrokeOptions *options)
{
   static CGStrokeOptions   CGDefaultStrokeOptions_static = CGStrokeOptionsDefault;
   NVGpaint                 nvgPaint;

   assertPaintableInNVGcontext( paint, CGContextGetNVGContext( context));
   assert( strokeWidth > 0.0f);

   options  = options ? options : &CGDefaultStrokeOptions_static;
   bounds   = CGRectMakeStrokeRect( bounds, strokeWidth, options->relation);
   nvgPaint = [paint NVGpaintWithBounds:bounds
                           paintOptions:&options->paint
                                context:context];

   nvgStrokePaint( CGContextGetNVGContext( context), nvgPaint);
}


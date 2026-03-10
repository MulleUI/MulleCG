#import "CGPaintable.h"

#import "import-private.h"

#import "CGContext.h"
#import "CGContext+Drawing.h"
#import "CGContext+CGImage.h"
#import "CGImage.h"
#import "nanowrap.h"




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
# define assertPaintableInNVGcontext( self, vg)
#endif



PROTOCOLCLASS_IMPLEMENTATION( CGPaintable)


- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                   paintOptions:(struct CGPaintOptions *) options
                        context:(CGContext *) context
{
   // subclasses do this
   MULLE_OBJC_SUBCLASS_REQUIRES_IMPLEMENTATION;
   return( (NVGpaint){ 0});
}


- (void) fillWithBounds:(CGRect) bounds
                options:(struct CGFillOptions *) options
                context:(CGContext *) context
{
   NVGpaint   nvgPaint;

   assertPaintableInNVGcontext( self, CGContextGetNVGContext( context));

   nvgPaint = [self NVGpaintWithBounds:bounds
                          paintOptions:&options->paint
                               context:context];
   mvgFillPaint( CGContextGetNVGContext( context), nvgPaint);
   CGContextFill( context);
}


- (void) strokeWithBounds:(CGRect) bounds
              strokeWidth:(CGFloat) strokeWidth
                  options:(struct CGStrokeOptions *) options
                  context:(CGContext *) context
{
   NVGpaint   nvgPaint;

   assertPaintableInNVGcontext( self, CGContextGetNVGContext( context));
   assert( strokeWidth > 0.0f);

   nvgPaint = [self NVGpaintWithBounds:bounds
                          paintOptions:&options->paint
                               context:context];
   mvgStrokePaint( CGContextGetNVGContext( context), nvgPaint);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}


- (CGImage *) image
{
   return( nil);
}


- (CGImage *) otherImage
{
   return( nil);
}


PROTOCOLCLASS_END()


// get CGPaintable as protocolclass
@implementation CGPaint( CGPaintable)  
@end


void   CGContextFillPaintableOptions( CGContext *context,
                                      id <CGPaintable> paint,
                                      CGRect bounds,
                                      CGFillOptions *options)
{
   static CGFillOptions   CGDefaultFillOptions_static = CGFillOptionsDefault;

   assertPaintableInNVGcontext( paint, CGContextGetNVGContext( context));

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

   assertPaintableInNVGcontext( paint, CGContextGetNVGContext( context));
   assert( strokeWidth > 0.0f);

   options  = options ? options : &CGDefaultStrokeOptions_static;
   bounds   = CGRectMakeStrokeRect( bounds, strokeWidth, options->relation);

   [paint strokeWithBounds:bounds
               strokeWidth:strokeWidth
                   options:options
                   context:context];
}


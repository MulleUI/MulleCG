#import "import.h"

#import "CGTypes.h"

#import "CGPaint.h"


@class CGContext;
@class CGImage;


//
// the CGPaintable protocolclass defines fillWithBounds: and strokeWithBounds:
// later on, we will have UIControlPaint or somesuch which is actually a
// a combination of strokes and fills, to create a fill, which is only
// possible if we make these methods overridable
//
PROTOCOLCLASS_INTERFACE0( CGPaintable)

@optional
// will call NVGpaintWithBounds:... and then fill
- (void) fillWithBounds:(CGRect) rect
                options:(struct CGFillOptions *) options
                context:(CGContext *) context;

// will call NVGpaintWithBounds:... and then stroke
- (void) strokeWithBounds:(CGRect) bounds
              strokeWidth:(CGFloat) strokeWidth
                  options:(struct CGStrokeOptions *) options
                  context:(CGContext *) context;

//
// either override fillWithBounds:... and strokeWithBounds:...
// or use the default implementations and implement NVGpaintWithBounds:...
// On its own this will raise
- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                   paintOptions:(struct CGPaintOptions *) options
                        context:(CGContext *) context;

// default: returns nil (which is fine)
- (CGImage *) image;
- (CGImage *) otherImage;

PROTOCOLCLASS_END()


@interface CGPaint( CGPaintable)  < CGPaintable>
@end




void   CGContextFillPaintableOptions( CGContext *context,
                                      id <CGPaintable> paint,
                                      CGRect  bounds,
                                      CGFillOptions *options);

void   CGContextStrokePaintableOptions( CGContext *context,
                                        id <CGPaintable> paint,
                                        CGRect  bounds,
                                        CGFloat strokeWidth,
                                        CGStrokeOptions *options);



//
// paint often carry the "rect" within them, so this is the easy way...
//
static inline void   CGContextFillPaintable( CGContext *context, id <CGPaintable> paint)
{
   CGContextFillPaintableOptions( context,
                                  paint,
                                  CGRectMake( -INFINITY, -INFINITY, INFINITY, INFINITY),
                                  NULL);
}


static inline void   CGContextStrokePaintable( CGContext *context, id <CGPaintable> paint, CGFloat strokeWidth)
{
   CGContextStrokePaintableOptions( context,
                                    paint,
                                    CGRectMake( -INFINITY, -INFINITY, INFINITY, INFINITY),
                                    strokeWidth,
                                    NULL);
}


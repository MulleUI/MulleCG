//
// main-border-compare.m
// Elliptical corner bulge demo: horizontal vs vertical stretch
//
#define _GNU_SOURCE

#import "import-private.h"

#ifndef M_PI
# define M_PI 3.14159265358979323846
#endif
#ifndef M_PI_2
# define M_PI_2 (M_PI / 2.0)
#endif

#define KAPPA  0.5522847493f


// Elliptical corners with independent rx/ry stretch
static void   ellipticalRoundedRect( CGContext *context, CGFloat x, CGFloat y,
                                     CGFloat w, CGFloat h, CGFloat r,
                                     CGFloat hBulge, CGFloat vBulge)
{
   CGFloat   rx = r * (1.0 + hBulge);  // horizontal stretch
   CGFloat   ry = r * (1.0 + vBulge);  // vertical stretch
   CGFloat   kx, ky;

   if( rx > w * 0.5) rx = w * 0.5;
   if( ry > h * 0.5) ry = h * 0.5;
   kx = rx * KAPPA;
   ky = ry * KAPPA;

   CGContextMoveTo( context, CGPointMake( x + rx, y));

   // Top edge
   CGContextLineTo( context, CGPointMake( x + w - rx, y));

   // Top-right corner
   CGContextBezierTo( context,
                      CGPointMake( x + w - rx + kx, y),
                      CGPointMake( x + w, y + ry - ky),
                      CGPointMake( x + w, y + ry));

   // Right edge
   CGContextLineTo( context, CGPointMake( x + w, y + h - ry));

   // Bottom-right corner
   CGContextBezierTo( context,
                      CGPointMake( x + w, y + h - ry + ky),
                      CGPointMake( x + w - rx + kx, y + h),
                      CGPointMake( x + w - rx, y + h));

   // Bottom edge
   CGContextLineTo( context, CGPointMake( x + rx, y + h));

   // Bottom-left corner
   CGContextBezierTo( context,
                      CGPointMake( x + rx - kx, y + h),
                      CGPointMake( x, y + h - ry + ky),
                      CGPointMake( x, y + h - ry));

   // Left edge
   CGContextLineTo( context, CGPointMake( x, y + ry));

   // Top-left corner
   CGContextBezierTo( context,
                      CGPointMake( x, y + ry - ky),
                      CGPointMake( x + rx - kx, y),
                      CGPointMake( x + rx, y));

   CGContextClosePath( context);
}


// Elliptical corners + quad bulge on top/bottom edges
static void   ellipticalBulgedRect( CGContext *context, CGFloat x, CGFloat y,
                                    CGFloat w, CGFloat h, CGFloat r,
                                    CGFloat hBulge, CGFloat vBulge, CGFloat edgeBulge)
{
   CGFloat   rx = r * (1.0 + hBulge);
   CGFloat   ry = r * (1.0 + vBulge);
   CGFloat   kx, ky;
   CGFloat   minDim = w < h ? w : h;
   CGFloat   topBottomOffset = minDim * 0.5 * edgeBulge;

   if( rx > w * 0.5) rx = w * 0.5;
   if( ry > h * 0.5) ry = h * 0.5;
   kx = rx * KAPPA;
   ky = ry * KAPPA;

   CGContextMoveTo( context, CGPointMake( x + rx, y));

   // Top edge: quad bulge outward (upward)
   CGContextQuadTo( context, CGPointMake( x + w * 0.5, y - topBottomOffset),
                    CGPointMake( x + w - rx, y));

   // Top-right corner
   CGContextBezierTo( context,
                      CGPointMake( x + w - rx + kx, y),
                      CGPointMake( x + w, y + ry - ky),
                      CGPointMake( x + w, y + ry));

   // Right edge: straight
   CGContextLineTo( context, CGPointMake( x + w, y + h - ry));

   // Bottom-right corner
   CGContextBezierTo( context,
                      CGPointMake( x + w, y + h - ry + ky),
                      CGPointMake( x + w - rx + kx, y + h),
                      CGPointMake( x + w - rx, y + h));

   // Bottom edge: quad bulge outward (downward)
   CGContextQuadTo( context, CGPointMake( x + w * 0.5, y + h + topBottomOffset),
                    CGPointMake( x + rx, y + h));

   // Bottom-left corner
   CGContextBezierTo( context,
                      CGPointMake( x + rx - kx, y + h),
                      CGPointMake( x, y + h - ry + ky),
                      CGPointMake( x, y + h - ry));

   // Left edge: straight
   CGContextLineTo( context, CGPointMake( x, y + ry));

   // Top-left corner
   CGContextBezierTo( context,
                      CGPointMake( x, y + ry - ky),
                      CGPointMake( x + rx - kx, y),
                      CGPointMake( x + rx, y));

   CGContextClosePath( context);
}


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   static double   startTime = 0.0;
   double          now;
   CGRect          canvas = [layer canvas];
   CGRect          rect;
   CGFloat         radius = 20.0;
   CGFloat         bulge;
   CGFloat         y;
   CGColor         fillColor = CGColorMakeWithRGBA( 0.75, 0.35, 0.25, 1.0);

   now = mulle_absolutetime_now();
   if( startTime == 0.0)
      startTime = now;

   // Oscillate bulge from 0.0 to 0.4 over ~4 seconds
   bulge = (1.0 + sin( (now - startTime) * 1.5)) * 0.2;

   // White background
   CGContextBeginPath( context);
   CGContextRect( context, canvas);
   CGContextFillColor( context, CGColorMakeWithRGBA( 1.0, 1.0, 1.0, 1.0));
   CGContextFill( context);

   // Row 1: Horizontal bulge (corners wider)
   y = 30;
   rect = CGRectMake( 60, y, 280, 60);
   CGContextBeginPath( context);
   ellipticalRoundedRect( context, rect.origin.x, rect.origin.y,
                          rect.size.width, rect.size.height, radius, bulge, 0.0);
   CGContextFillColor( context, fillColor);
   CGContextFill( context);
   CGContextStrokeColor( context, CGColorMakeWithRGBA( 0.15, 0.15, 0.15, 1.0));
   CGContextStrokeWidth( context, 2.0);
   CGContextStroke( context);

   // Row 2: Vertical bulge (corners taller)
   y = 120;
   rect = CGRectMake( 60, y, 280, 60);
   CGContextBeginPath( context);
   ellipticalRoundedRect( context, rect.origin.x, rect.origin.y,
                          rect.size.width, rect.size.height, radius, 0.0, bulge);
   CGContextFillColor( context, fillColor);
   CGContextFill( context);
   CGContextStrokeColor( context, CGColorMakeWithRGBA( 0.15, 0.15, 0.15, 1.0));
   CGContextStrokeWidth( context, 2.0);
   CGContextStroke( context);

   // Row 3: Both (corners wider AND taller)
   y = 210;
   rect = CGRectMake( 60, y, 280, 60);
   CGContextBeginPath( context);
   ellipticalRoundedRect( context, rect.origin.x, rect.origin.y,
                          rect.size.width, rect.size.height, radius, bulge, bulge);
   CGContextFillColor( context, fillColor);
   CGContextFill( context);
   CGContextStrokeColor( context, CGColorMakeWithRGBA( 0.15, 0.15, 0.15, 1.0));
   CGContextStrokeWidth( context, 2.0);
   CGContextStroke( context);

   // Row 4: Elliptical corners + quad bulge on top/bottom
   y = 300;
   rect = CGRectMake( 60, y, 280, 60);
   CGContextBeginPath( context);
   ellipticalBulgedRect( context, rect.origin.x, rect.origin.y,
                         rect.size.width, rect.size.height, radius, bulge, 0.0, bulge);
   CGContextFillColor( context, fillColor);
   CGContextFill( context);
   CGContextStrokeColor( context, CGColorMakeWithRGBA( 0.15, 0.15, 0.15, 1.0));
   CGContextStrokeWidth( context, 2.0);
   CGContextStroke( context);

   return( YES);
}


int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 400, 400),
                                           NULL,
                                           30.0f));
}

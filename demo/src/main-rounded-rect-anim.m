#define _GNU_SOURCE
#import "import-private.h"

static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect    canvas;
   CGRect    rect;
   CGFloat   t;
   CGFloat   h;
   CGFloat   cornerRadius = 20.0f;

   canvas = [layer canvas];
   t      = CGContextGetBackAndForthAnimationFactor( context, 120.f * 5.0);
   h      = t * 100.0f;

   rect = CGRectMake( CGRectGetMidX( canvas) - 50,
                      CGRectGetMidY( canvas) - h / 2.0f,
                      100, h);

   CGContextBeginPath( context);
   CGContextRoundedRect( context, rect, cornerRadius);
   CGContextFillColor( context, CGColorMakeDodgerBlue());
   CGContextFill( context);

   CGContextBeginPath( context);
   CGContextRoundedRect( context, rect, cornerRadius);
   CGContextStrokeColor( context, CGColorMakeWhite());
   CGContextStrokeWidth( context, 1.0);
   CGContextStroke( context);

   return( YES);
}

int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 400, 300),
                                           NULL,
                                           60.0f));
}

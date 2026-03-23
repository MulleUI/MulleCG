#import "import-private.h"
static BOOL   drawStuff1( CGGraphicsLayer *layer, CGContext *context);
static BOOL   drawStuff2( CGGraphicsLayer *layer, CGContext *context);
static void    flipDraw( CGGraphicsLayer *layer, CGContext *context)
{
   NSUInteger                      frames;
   CGGraphicsLayerDrawCallback_t   *callback;

   frames = [context numberOfFrames];
   if( (frames % (100 * 3)) == 299)
   {
      callback = ([layer drawCallback] == drawStuff1) ? drawStuff2 : drawStuff1;
      [layer setDrawCallback:callback];
   }
}
static BOOL   drawStuff1( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect              canvas;
   canvas               = [layer canvas];
   canvas.size.height  /= 3.0;

   // red stripe
   CGContextBeginPath( context);
   CGContextRect( context, CGRectMake( canvas.origin.x, canvas.origin.y, canvas.size.width, canvas.size.height));
   CGContextFillColor( context, CGColorMakeWithRGBA( 0.0, 0.95, 0.0, 1.0));
   CGContextFill( context);

   // white stripe
   CGContextBeginPath( context);
   CGContextRect( context, CGRectMake( canvas.origin.x, canvas.origin.y + canvas.size.height * 1, canvas.size.width, canvas.size.height));
   CGContextFillColor( context, CGColorMakeWithRGBA( 0.0, 0.66, 0.0, 1.0));
   CGContextFill( context);

   // blue stripe
   CGContextBeginPath( context);
   CGContextRect( context, CGRectMake( canvas.origin.x, canvas.origin.y + canvas.size.height * 2, canvas.size.width, canvas.size.height));
   CGContextFillColor( context, CGColorMakeWithRGBA( 0.0, 0.3, 0.0, 1.0));
   CGContextFill( context);

   flipDraw( layer, context);
   return( YES);
}
static BOOL   drawStuff2( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect              canvas;
   NSUInteger          i;
   canvas               = [layer canvas];
   canvas.size.height  /= 5.0;

   for( i = 0; i < 5; i++)
   {
      CGContextBeginPath( context);
      CGContextRect( context, CGRectMake( canvas.origin.x, canvas.origin.y + canvas.size.height * i, canvas.size.width, canvas.size.height));
      CGContextFillColor( context, CGColorMakeWithRGBA( 0.0, 1.0 - i / 5.0, 0.0, 1.0));
      CGContextFill( context);
   }

   flipDraw( layer, context);
   return( YES);
}
int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff1,
                                           CGSizeMake( 200, 200),
                                           NULL, 
                                           100.f));     
}

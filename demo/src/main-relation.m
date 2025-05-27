#define _GNU_SOURCE

#import "import-private.h"

#define COLS  2
#define ROWS  2

static CGRelation relations[4] = { CGCover, CGInside, CGOutside, CGOverlap };
static char *relationLabels[4] = { "CGCover", "CGInside", "CGOutside", "CGOverlap" };


static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect       canvas;
   CGRect       rect;
   CGRect       rects[ ROWS][ COLS];
   CGFloat      strokeWidth;
   CGRect       bounds;
   CGRect       area;
   char         *label;

   CGColor      fillColor   = CGColorMake( 0.8, 0.4, 0.4, 1.0); // Light red fill
   CGColor      strokeColor = CGColorMake( 0.2, 0.6, 0.8, 0.5); // Blue stroke with 0.5 alpha
   CGRect       space;
   BOOL         relativeToFill;

   canvas = [layer canvas];
   canvas = CGRectInset( canvas, 10.0, 10.0); // Add some padding

   relativeToFill = [context numberOfFrames] & 1;

   CGRectPartitionIntoRowsAndColumns( canvas, CGSizeMake( 10, 10), ROWS, COLS, (CGRect *) rects);

   strokeWidth = CGRectGetWidth( rects[0][0]) / 8.0;
   if (strokeWidth > CGRectGetHeight( rects[0][0]) / 8.0)
       strokeWidth = CGRectGetHeight( rects[0][0]) / 8.0;

   for( NSUInteger j = 0; j < ROWS; j++)
   {
      for( NSUInteger i = 0; i < COLS; i++)
      {
         rect = CGRectIntegral( rects[ j][ i]);
         CGContextStrokeRectWithColor( context, rect, 1.0, CGColorMake( 1.0, 1.0, 0.0, 1.0)); // orange hairline

         rect = CGRectInset( rect, strokeWidth, strokeWidth);
         // Draw a background rect to show the original cell boundaries
         CGContextStrokeRectWithColor( context, rect, 1.0, CGColorMake(0.0, 1.0, 0.0, 1.0)); // Dark gray border

         CGRelation currentRelation = relations[ j * COLS + i];

         // Calculate and draw the filled rectangle
         CGRect fillTargetRect = CGRectMakeFillRect( rect, strokeWidth, relativeToFill ? currentRelation : CGOverlap);
         CGContextFillRectWithColor( context, fillTargetRect, fillColor);

         // Calculate and draw the stroked rectangle
         CGRect strokeTargetRect = CGRectMakeStrokeRect( rect, strokeWidth, relativeToFill ? CGOverlap : currentRelation);
         CGContextStrokeRectWithColor( context, strokeTargetRect, strokeWidth, strokeColor);

         // Add text label
         label = relationLabels[ j * COLS + i];

         CGContextTextColor( context, CGColorMakeBlack());
         CGContextTextBackgroundColor( context, fillColor);
         CGContextFontSize( context, 12.0f);
         CGContextTextInRect( context, label, (size_t) -1, CGRectInset( rect, 5, 10), CGContentModeBottom, 0);
      }
   }

   label = relativeToFill ? "relativeToFill" : "relativeToStroke";

   CGContextFontFace( context, "sans");
   CGContextFontSize( context, 14.0f);

   bounds = CGContextTextVisualBounds( context, CGPointZero, label, (size_t) -1);
   area   = CGRectExtrude( bounds, 4, 4);
   area   = CGRectCenterInRect( area, canvas);
   CGContextFillRoundedRectWithColor( context, area, 3.0f, CGColorMake( 1.0, 1.0, 1.0, 0.5));

   CGContextTextColor( context, CGColorMakeBlack());
   CGContextTextBackgroundColor( context, CGColorMakeGray());
   CGContextTextInRect( context, label, (size_t) -1, bounds, CGContentModeBottom, 0);

   return( YES);
}


int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;

   app = [UIApplication sharedInstance];

   window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 400, 400)];
   [window setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];
   [window setBackgroundColor:CGColorMakeBlack()];
   [window setFrameRateHz:0.5];
   [app addWindow:window];

   return( [app runApp]);
}

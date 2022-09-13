#import <MulleCG/MulleCG.h>



void   print_color( CGColor color)
{
   CGFloat   components[ 4];

   printf( "RGB: 0x%02x%02x%02x",
               (int) round( color.r * 255),
               (int) round( color.g * 255),
               (int) round( color.b * 255));

   CGColorGetHSLAComponents( color, components);
   printf( "  HSL: (%d°, %d%%, %d%%)",
               (int) round( components[ 0] * 360.0),
               (int) round( components[ 1] * 100.0),
               (int) round( components[ 2] * 100.0));

   // online tools love to give degrees and percent for this...
   CGColorGetHSVAComponents( color, components);
   printf( "  HSB: (%d°, %d%%, %d%%)",
               (int) round( components[ 0] * 360.0),
               (int) round( components[ 1] * 100.0),
               (int) round( components[ 2] * 100.0));

   printf( "\n");
}


//
// This is correct for each color components
//
int   main( int argc, char *argv[])
{
   NSUInteger   r, g, b;

   for( r = 0; r <= 3; r++)
      for( g = 0; g <= 3; g++)
         for( b = 0; b <= 3; b++)
         {
            print_color( CGColorMakeWithRGB( r / 3.0, g / 3.0, b / 3.0));
         }
   return( 0);
}

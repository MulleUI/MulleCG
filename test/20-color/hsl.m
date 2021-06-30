#import <MulleCG/MulleCG.h>



void   print_color( CGColorRef color)
{
   CGFloat   components[ 4];

   printf( "RGB: 0x%02x%02x%02x",
               (int) round( color.r * 255),
               (int) round( color.g * 255),
               (int) round( color.b * 255));

   MulleColorGetHSLAComponents( color, components);
   printf( "  HSL: (%d°, %d%%, %d%%)",
               (int) round( components[ 0] * 360.0),
               (int) round( components[ 1] * 100.0),
               (int) round( components[ 2] * 100.0));

   // online tools love to give degrees and percent for this...
   MulleColorGetHSVAComponents( color, components);
   printf( "  HSB: (%d°, %d%%, %d%%)",
               (int) round( components[ 0] * 360.0),
               (int) round( components[ 1] * 100.0),
               (int) round( components[ 2] * 100.0));

   printf( "\n");
}


//
// Many values with zero luminance or zero saturation or 1.0 luminance
// map to white/black
//
int   main( int argc, char *argv[])
{
   NSUInteger   h, s, l;

   for( h = 0; h <= 3; h++)
      for( s = 0; s <= 3; s++)
         for( l = 0; l <= 3; l++)
         {
            print_color( MulleColorMakeHSL( h / 3.0, s / 3.0, l / 3.0));
         }
   return( 0);
}

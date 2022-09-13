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



int   main( int argc, char *argv[])
{
   NSUInteger   h, s, b;

   for( h = 0; h <= 3; h++)
      for( s = 0; s <= 3; s++)
         for( b = 0; b <= 3; b++)
         {
            print_color( CGColorMakeWithHSB( h / 3.0, s / 3.0, b / 3.0));
         }
   return( 0);
}

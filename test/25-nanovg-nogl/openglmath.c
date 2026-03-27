#include <stdio.h>




//                                        0,0
//                                         .----------------.
//   -1/1                                  |                |
//     .--------.                          |                |
//     | OpenGL |                          |                |
//     |        |                          |                |
//     |        |                          |                |
//     '--------'                          '----------------'
//            2/-2                                       640,400
//
//    OpenGL coordinates as a canvas.      The framebuffer is 640x400 pixels
//    The height is actually negative,
//    as we are drawing top (1.0) to  
//    bottom(-1.0)                    
//
//    The transformation for any OpenGL point to the framebuffer is:
//                                                                  
//    sx = 640.0 * (x + 1.0) / 2.0;                                 
//    sy = 400.0 * (-y + 1.0) / 2.0;                                
//                                                                  
//    and back                                                      
//                                                                  
//    ox = (sx * 2 / 640.0) - 1.0;                                  
//    oy = -(sy * 2 / 400.0) + 1.0;                                 
//
//    If we need to place OpenGL calls into a portion of the framebuffer, 
//    we have:                                                            
//
//    0,0
//     .----------------.
//     | 100,150        |
//     |    .-----.     |
//     |    |     |     |
//     |    '-----'     |
//     |       200,50   |
//     '----------------'
//                   640,400
//
//    sx=100.0+(200.0)*(x+1.0)/2.0
//    sy=150.0+(50.0)*(-y+1.0)/2.0
//
//   Reversemapping a pixel from the framebuffer portion to OpenGL
//
//   ox = ((sx - 100) * 2 / 200.0) - 1.0; 
//   oy = -((sy - 150) * 2 / 50.0) + 1.0; 





#define W     640
#define H     400

#define P_X   100
#define P_Y   150
#define P_W   200
#define P_H   50


int   main( int argc, char *argv[])
{
   float  x, y;
   float  sx, sy;
   float  ox, oy;

   for( x = -1.0; x <= 1.01; x += 1.0)
      for( y = -1.0; y <= 1.01; y += 1.0)
      {
         sx = W * (x + 1.0) / 2.0;   // sx * 2 / 640.0 - 10
         sy = H * (-y + 1.0) / 2.0; 
         ox = (sx * 2 / W) - 1.0; 
         oy = -(sy * 2 / H) + 1.0; 

         printf( "%.1f/%.1f -> %.1f/%.1f -> %.1f/%.1f\n", x, y, sx, sy, ox, oy);
      }

   printf( "\n");

   for( x = -1.0; x <= 1.01; x += 1.0)
      for( y = -1.0; y <= 1.01; y += 1.0)
      {
         sx = P_X + P_W * (x + 1.0) / 2.0;   // sx * 2 / 640.0 - 10
         sy = P_Y + P_H * (-y + 1.0) / 2.0; 
         ox = ((sx - P_X) * 2 / P_W) - 1.0; 
         oy = -((sy - P_Y)  * 2 / P_H) + 1.0; 

         printf( "%.1f/%.1f -> %.1f/%.1f -> %.1f/%.1f\n", x, y, sx, sy, ox, oy);
      }      

   return( 0);
}

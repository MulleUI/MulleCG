

#define R   0xFF, 0x00, 0x00, 0xFF
#define G   0x00, 0xFF, 0x00, 0xFF
#define B   0x00, 0x00, 0xFF, 0xFF
#define Y   0xFF, 0xFF, 0x00, 0xFF
#define W   0xFF, 0xFF, 0xFF, 0xFF
#define _   0x00, 0x00, 0x00, 0xFF


static unsigned char    bitmap2[ 4 * 32 * 32] =
{
   W, _, W, _,  W, _, W, _,  W, _, W, _,  W, _, W, _,  W, _, W, _,  W, _, W, _,  W, _, W, _,  W, _, W, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,

   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, _, _,  _, _, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, _, _,  _, _, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, _, _,  _, _, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, _, _,  _, _, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,

   W, B, B, B,  B, B, B, B,  R, R, R, R,  _, _, _, _,  _, _, _, _,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, _, _, _,  _, _, _, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, _, _,  _, _, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, _,  _, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,

   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, W,
   W, B, B, B,  B, B, B, B,  R, R, R, R,  R, R, R, R,  Y, Y, Y, Y,  Y, Y, Y, Y,  G, G, G, G,  G, G, G, _,
   _, W, _, W,  _, W, _, W,  _, W, _, W,  _, W, _, W,  _, W, _, W,  _, W, _, W,  _, W, _, W,  _, W, _, W
};

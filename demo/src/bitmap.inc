#define R   0xFF, 0x00, 0x00, 0xFF
#define G   0x00, 0xFF, 0x00, 0xFF
#define B   0x00, 0x00, 0xFF, 0xFF
#define Y   0xFF, 0xFF, 0x00, 0xFF
#define W   0xFF, 0xFF, 0xFF, 0xFF
#define _   0x00, 0x00, 0x00, 0xFF

static unsigned char    bitmap[4 * 8 * 8] =
{
   B, B, B, B,  R, R, R, R,
   B, B, B, B,  R, R, R, R,
   B, B, _, _,  R, R, R, R,
   B, B, _, _,  _, R, R, R,

   Y, Y, Y, _,  _, _, G, G,
   Y, Y, Y, Y,  _, _, G, G,
   Y, Y, Y, Y,  G, G, G, G,
   Y, Y, Y, Y,  G, G, G, G
};


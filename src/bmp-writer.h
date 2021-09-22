#ifndef bmp_writer_h__
#define bmp_writer_h__
//
// Low level debug code, not to be placed in MulleUIImage
// (Maybe own library)
//
int   bmp_rgb32_write_file( char *filename,
                            void *image,                // rgba image bytes
                            unsigned int width,         // in pixels
                            unsigned int height,        // in pixels
                            int stridebytes);           // usually width * 4


int   bmp_grayscale_write_file( char *filename,
                                void *image,         // grayscale image bytes
                                unsigned int width,  // in pixels
                                unsigned int height, // in pixels
                                int stridebytes);    // usually same as width


//
// dumps to /tmp/bitmap-0000.bmp
//
int    mulle_rgba_dump( void *image,
                        unsigned int width,         // in pixels
                        unsigned int height);       // usually width * 4

#endif 

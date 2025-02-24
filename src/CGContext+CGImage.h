//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
// prefer a local CGContext over one in import.h
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"

@class CGImage;


@interface CGContext( CGImage)

- (CGImage *) imageWithRGBABytes:(void *) bytes
                      bitmapSize:(CGPixelSize) bitmapSize
                    textureFlags:(NSUInteger) textureFlags
                     resourceKey:(MulleUIResourceStorageKey_t) resourceKey;

- (CGImage *) imageWithBitmap:(struct CGBitmap) bitmap
                 textureFlags:(NSUInteger) textureFlags
                  resourceKey:(MulleUIResourceStorageKey_t) resourceKey;

- (CGImage *) imageWithContentsOfFileCString:(char *) filename
                                textureFlags:(NSUInteger) textureFlags
                                 resourceKey:(MulleUIResourceStorageKey_t) resourceKey;

// data can be discarded after init
- (CGImage *) imageWithFileCData:(struct mulle_data) fileCData
                    textureFlags:(NSUInteger) textureFlags
                     resourceKey:(MulleUIResourceStorageKey_t) resourceKey;


@end

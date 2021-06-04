#import "CGDrawable.h"

#import "CGContext.h" // needed for protocol

//
//                             .------------.
//                             | CGDrawable |
//                             '------------'
//  .---------.                       |
//  | CGImage |----------.            |
//  '---------'          |            |
//       |               |            |
//       |               |            |
//       |               |            |
//       |               v            |
//       |     .------------------.   |
//       |     | CGBitmapDrawable |<--'
//       |     '------------------'
//       |
//       v
//  .---------.
//  | CGLayer |
//  '---------'
//


//
// This is a wrapper for all the nanovg image functionality.
// Such an image lives in the graphics context. The image bytes are not
// accessible. The image dies functionally at the very least, when the
// context dies (or when it gets finalized). You can not share it with another
// context. If you want to do more, use UIImage. You can only create it
// during rendering! It's trickym you are generally better off with UIImage
// for imgae management.
//
// Textures (images) in NVG can be created with different flags, for example
// REPEAT_X and REPEAT_Y. When we are asking the CGContext for a textureID
// for an image this will create such a NVG texture. As the context cashes the
// textureID for each MulleImage it's simplest to store the imageFlags here
// (readonly) and to clone MulleImages for different flags. The actual image
// data can be shared w/o a problem. The default is 0:

@interface CGImage : NSObject <CGBitmapDrawable, CGContextResource>
{
   int  _textureID;
}
@property( readonly, assign) CGContext   *context;
@property( readonly, assign) NSUInteger  imageFlags;  // rename sometime

- (instancetype) initWithTextureID:(int) textureID
                        imageFlags:(NSUInteger) imageFlags
                           context:(CGContext *) context;

//
// if imageflags or context don't match, this will return -1 
// UIImage can derive multiple CGImages from itself.
//                           
- (int) textureIDWithContext:(CGContext *) context
                  imageFlags:(NSUInteger) imageFlags;

// these methods are germane to CGImage, subclasses may not support this
// I wanted to avoid inserting another class here
- (instancetype) initWithContentsOfFileCString:(char *) filename
                                    imageFlags:(NSUInteger) imageFlags
                                       context:(CGContext *) context;

- (instancetype) initWithFileCData:(struct mulle_data) fileCData
                        imageFlags:(NSUInteger) imageFlags
                           context:(CGContext *) context;

- (instancetype) initWithRGBABytes:(void *) bytes
                        bitmapSize:(struct CGBitmapSize) bitmapSize
                        imageFlags:(NSUInteger) imageFlags
                           context:(CGContext *) context;

- (struct CGBitmapSize) bitmapSize;  // just integer value of size
- (void) setBytes:(void *) bytes;

@end

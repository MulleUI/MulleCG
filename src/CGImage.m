#import "CGImage.h"

#import "CGContext.h"



@implementation CGImage

- (instancetype) initWithTextureID:(int) textureID
                        imageFlags:(NSUInteger) imageFlags
                           context:(CGContext *) context
{
   if( ! textureID)
   {
      [self release];
      return( nil);
   }


   _imageFlags = imageFlags;
   _context    = context;
   _textureID  = textureID;

   [_context addToResources:self];

   return( self);
}


- (void) contextDidRemoveObject:(CGContext *) context
{
   if( _textureID)
   {
      [context deleteTextureID:_textureID]; 
   }
   _context = nil;
}


- (void) finalize
{
   // this will call contextDidRemoveObject: eventually
   [_context removeFromResources:self];

   [super finalize];
}


- (int) textureIDWithContext:(CGContext *) context
                  imageFlags:(NSUInteger) imageFlags
{
   if( context == _context && imageFlags == _imageFlags)
      return( _textureID);
   return( -1);
}


- (struct CGBitmapInfo) bitmapInfo
{
   return( CGBitmapInfoMake( [self bitmapSize],
                             CGBitmapEncodingRGBABytes));
}


- (struct CGBitmapSize) bitmapSize  // just integer value of size
{
   int  w;
   int  h;

   nvgImageSize( CGContextGetNVGContext( _context), _textureID, &w, &h);
   return( CGBitmapSizeMake( w, h));
}


// this i
- (instancetype) initWithContentsOfFileCString:(char *) filename
                                    imageFlags:(NSUInteger) imageFlags
                                       context:(CGContext *) context
{
   int   textureID;

   assert( [context isActive]);

   textureID = nvgCreateImage( CGContextGetNVGContext( context),
                               filename,
                               imageFlags & 0x3F);
   return( [self initWithTextureID:textureID
                        imageFlags:imageFlags
                           context:context]);
}


- (instancetype) initWithFileCData:(struct mulle_data) fileCData
                        imageFlags:(NSUInteger) imageFlags
                           context:(CGContext *) context
{
   int   textureID;

   assert( [context isActive]);

   textureID = nvgCreateImageMem( CGContextGetNVGContext( context),
                                  imageFlags & 0x3F,
                                  fileCData.bytes,
                                  (int) fileCData.length);
   return( [self initWithTextureID:textureID
                        imageFlags:imageFlags
                           context:context]);
}


- (instancetype) initWithRGBABytes:(void *) bytes
                        bitmapSize:(struct CGBitmapSize) bitmapSize
                        imageFlags:(NSUInteger) imageFlags
                           context:(CGContext *) context
{
   int   textureID;

   assert( bytes);
   assert( bitmapSize.width >= 1);
   assert( bitmapSize.height >= 1);

   assert( [context isActive]);

   textureID = nvgCreateImageRGBA( CGContextGetNVGContext( context),
                                   bitmapSize.width,
                                   bitmapSize.height,
                                   imageFlags & 0x3F,
                                   bytes);
   return( [self initWithTextureID:textureID
                        imageFlags:imageFlags
                           context:context]);
}


- (void) setBytes:(void *) bytes
{
   assert( [_context isActive]);

   nvgUpdateImage( CGContextGetNVGContext( _context),
                   _textureID,
                   bytes);
}

@end

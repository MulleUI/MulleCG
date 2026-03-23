//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#import "import.h"
#import "CGContext+CGFramebuffer.h"

// non-GPU framebuffer size helpers for use by GPU backend implementations
static inline CGPixelSize
   _CGContextBitmapSizeOfLayerFramebuffer( CGContext *self,
                                           struct CGContextFramebuffer fb)
{
   assert( fb.type == CGContextLayerFramebuffer
           || fb.type == CGContextLayerMultiSampleFramebuffer);
   return( [(CGFramebuffer *) fb.handle bitmapSize]);
}

static inline CGPixelSize
   _CGContextBitmapSizeOfDefaultFramebuffer( CGContext *self,
                                             struct CGContextFramebuffer fb)
{
   struct CGFrameInfo   info;

   assert( fb.type == CGContextDefaultFramebuffer
           || fb.type == CGContextDefaultMultiSampleFramebuffer);
   [self getCurrentFrameInfo:&info];
   return( CGFrameInfoGetFramebufferSize( &info));
}

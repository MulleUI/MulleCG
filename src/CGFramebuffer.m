//
//  CGFramebuffer.m
//  MulleCG
//
//  Copyright (c) 2025 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#import "CGFramebuffer.h"

#import "CGContext.h"
#import "CGContext+CGFramebuffer.h"
#import "CGContext+DebugPrivate.h"
#import "CGContext+Drawing.h"
#import "CGContext+Render.h"
#import "CGImage+DebugPrivate.h"

#import "import-private.h"


@implementation CGFramebuffer

+ (instancetype) framebufferWithBitmapSize:(CGPixelSize) bitmapSize
                              textureFlags:(NSUInteger) textureFlags
                            nameUTF8String:(char *) nameUTF8String
                                   context:(CGContext *) context {
    CGFramebuffer *obj;

    obj = [self alloc];
    obj = [obj initWithBitmapSize:bitmapSize
                     textureFlags:textureFlags
                   nameUTF8String:nameUTF8String
                          context:context];
    obj = [obj autorelease];
    return(obj);
}


+ (instancetype) framebufferWithBitmapSize:(CGPixelSize) bitmapSize
                             textureFlags:(NSUInteger) textureFlags
                                  context:(CGContext *) context {
    CGFramebuffer *obj;

    obj = [self alloc];
    obj = [obj initWithBitmapSize:bitmapSize
                     textureFlags:textureFlags
                   nameUTF8String:NULL
                          context:context];
    obj = [obj autorelease];
    return(obj);
}


- (instancetype) initWithImage:(CGImage *) image
                  textureFlags:(NSUInteger) textureFlags
                nameUTF8String:(char *) nameUTF8String
                       context:(CGContext *) context
{
   MULLE_C_UNUSED( image);
   MULLE_C_UNUSED( textureFlags);
   MULLE_C_UNUSED( nameUTF8String);
   MULLE_C_UNUSED( context);
   // implemented by nanovg backend
   return( nil);
}


- (instancetype) initWithContentsOfFileUTF8String:(char *) filename
                                  textureFlags:(NSUInteger) textureFlags
                                nameUTF8String:(char *) nameUTF8String
                                       context:(CGContext *) context
{
   MULLE_C_UNUSED( filename);
   MULLE_C_UNUSED( textureFlags);
   MULLE_C_UNUSED( nameUTF8String);
   MULLE_C_UNUSED( context);
   abort();
   return( nil);
}


- (instancetype) initWithFileCData:(struct mulle_data) fileCData
                      textureFlags:(NSUInteger) textureFlags
                    nameUTF8String:(char *) nameUTF8String
                           context:(CGContext *) context
{
   MULLE_C_UNUSED( fileCData);
   MULLE_C_UNUSED( textureFlags);
   MULLE_C_UNUSED( nameUTF8String);
   MULLE_C_UNUSED( context);
   abort();
   return( nil);
}


- (instancetype) initWithRGBABytes:(void *) bytes
                        bitmapSize:(CGPixelSize) bitmapSize
                      textureFlags:(NSUInteger) textureFlags
                    nameUTF8String:(char *) nameUTF8String
                           context:(CGContext *) context
{
   MULLE_C_UNUSED( bytes);
   MULLE_C_UNUSED( bitmapSize);
   MULLE_C_UNUSED( textureFlags);
   MULLE_C_UNUSED( nameUTF8String);
   MULLE_C_UNUSED( context);
   abort();
   return( nil);
}


#ifdef DEBUG
- (void) dealloc
{
   assert( ! _gpuFramebuffer);
   CGImageLog( "framebuffer deallocs");
   [super dealloc];
}
#endif   
   

//
// so technically we return a CGFramebuffer its actually considered as
// read only, due to us also supporting mutableCopy. I.e. the receivers
// expectation must be to receive a CGImage
//
- (id) copy  
{
   CGFramebuffer   *framebuffer;
   Class           cls;

   cls         = [self class];
   framebuffer = [cls alloc];
   framebuffer = [framebuffer initWithImage:self
                               textureFlags:self->_textureFlags
                             nameUTF8String:NULL
                                    context:self->_context];
   // framebuffer = [framebuffer autorelease]; ???
   return( framebuffer);
}


- (void) didRemoveFromContext:(CGContext *) context
{
   if( _gpuFramebuffer && _context == context)
   {
      CGImageLog( "delete framebuffer %p", _gpuFramebuffer);
      // assert( [self state] & UIGraphicsContextActive);
      [context deleteGPUFramebuffer:_gpuFramebuffer];
      _gpuFramebuffer         = NULL;
      _initializedFramebuffer = NO;
   }

   [super didRemoveFromContext:context];
}


//
// as we share the GPU we use this scheme, its cheaper as the object is
// not evicted from autoreleasepools
//
- (MulleObjCTAOStrategy) mulleTAOStrategy
{
   return( MulleObjCTAOReceiverPerformsFinalize);
}


- (struct CGBitmap) RGBABytesBitmap:(struct mulle_allocator *) allocator
{
   return( [_context RGBABytesBitmapOfImage:self
                                  allocator:allocator]);
}


- (void) _willEndFBRender:(struct CGFramebufferRenderInfo *) memo
{
}


- (char *) colorizerPrefixUTF8String
{
   char        *s;
   char        *result;
   uintptr_t   hash;
   int         color;

   s = _nameUTF8String; // is readonly !
   if( s)
      hash = _mulle_string_hash( s);
   else
      hash  = mulle_pointer_hash( self);

   color  = (hash % (200 - 42)) + 42;
   mulle_asprintf( &result, "\033[38;5;%dm", color);;

   return( MulleObjCAutoreleaseAllocation( result, NULL));
}


/*
 * In a shared OpenGL context situation, you cannot create a framebuffer in one
 * context and then later delete it in the other. Framebuffer objects (FBOs)
 * cannot be shared between OpenGL contexts the way that vertex buffer objects
 * (VBOs), textures, and other objects can be.
 *
 * If you want to use the rendered result from one context in another context,
 * you can use a Pixel Buffer Object (PBO) to gain performant access to the
 * rendered picture, send it over to the other context through shared memory,
 * and upload it into a texture there (again through pixel buffer object).
 * PBOs are buffer objects and are shared across OpenGL contexts.
 *
 */
// so when we do a "shareWithContext" we only share the underlying texture
// - (id) shareWithContext:(id) otherContext
// {
//    [super shareWithContext:otherContext];
// }


- (CGImage *) resolvedImage
{
   if( ! _resolvedImage)
   {
      if( ! [self isMultiSample])
         return( self);

      _resolvedImage = [[_context resolveMultiSampleImage:self] retain];
   }
   return( _resolvedImage);
}


@end


@implementation CGFramebuffer( CGLayerRender)

// TODO: render with MSAA then resolve to regular texture ?
//
// That's what Cody says.
//
// // Create MSAA and regular FBOs
// glGenFramebuffers(1, &msaaFBO);
// glGenFramebuffers(1, &regularFBO);
// 
// // Create MSAA texture
// glGenTextures(1, &msaaTexture);
// glBindTexture(GL_TEXTURE_2D_MULTISAMPLE, msaaTexture);
// glTexImage2DMultisample(GL_TEXTURE_2D_MULTISAMPLE, samples, GL_RGBA8, width, height, GL_TRUE);
// 
// // Create regular texture
// glGenTextures(1, &regularTexture);
// glBindTexture(GL_TEXTURE_2D, regularTexture);
// glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
// 
// // Attach textures to FBOs
// glBindFramebuffer(GL_FRAMEBUFFER, msaaFBO);
// glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D_MULTISAMPLE, msaaTexture, 0);
// 
// glBindFramebuffer(GL_FRAMEBUFFER, regularFBO);
// glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, regularTexture, 0);
// 
// // Resolve MSAA to regular texture
// glBindFramebuffer(GL_READ_FRAMEBUFFER, msaaFBO);
// glBindFramebuffer(GL_DRAW_FRAMEBUFFER, regularFBO);
// glBlitFramebuffer(0, 0, width, height, 0, 0, width, height, GL_COLOR_BUFFER_BIT, GL_NEAREST);
//


+ (instancetype) framebufferWithBitmapSize:(CGPixelSize) size
                           backgroundColor:(CGColor) color
                              drawFunction:(void (*)( CGContext *context, CGSize size, void *userinfo)) drawFunction
                                  userInfo:(void *) userInfo
                            nameUTF8String:(char *) nameUTF8String
                                   context:(CGContext *) context
{
   CGFramebuffer                    *cgLayer;
   struct CGFramebufferRenderInfo   memo;

   assert( CGContextIsActiveInCurrentThread( context));

   if( size.width == 0 || size.height == 0)
      return( nil);

   cgLayer = [self framebufferWithBitmapSize:size
                                textureFlags:0
                              nameUTF8String:nameUTF8String
                                     context:context];
   [cgLayer beginFBRenderWithBackgroundColor:color
                            devicePixelRatio:1.0
                             layerRenderInfo:&memo];
   if( drawFunction)
      (*drawFunction)( context, CGSizeMakeWithPixelSize( size), userInfo);
   [cgLayer endFBRender:&memo];

   return( cgLayer);
}


- (void) _beginFBRender:(struct CGFramebufferRenderInfo *) memo
{
   assert( memo);

   [_resolvedImage autorelease];
   _resolvedImage = nil;

   [_context flushRender];
   [_context getCurrentFrameInfo:&memo->frameInfo];
   memo->framebuffer = [_context bindFramebuffer:CGContextFramebufferMakeWithFramebuffer( self)];
}


- (void) _endFBRender:(struct CGFramebufferRenderInfo *) memo
{
   assert( memo);

   [_context flushRender];
   [_context bindFramebuffer:memo->framebuffer];
   [_context changeRender:&memo->frameInfo];
}


- (void) _didBeginFBRenderWithBitmapSize:(CGPixelSize) bitmapSize
                        devicePixelRatio:(CGFloat) ratio
{
   MULLE_C_UNUSED( bitmapSize);
   MULLE_C_UNUSED( ratio);
   // hack for nanovg category
}


@end


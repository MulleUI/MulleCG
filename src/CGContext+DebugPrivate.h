//
//  CGContext+DebugPrivate.h
//  MulleCG
//
//  Copyright (c) 2023 Nat! - Mulle kybernetiK.
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
enum
{
   CGContextDebug                 = 0x000001,
   CGContextDebugVerbose          = 0x001000,

   CGContextDebugRender           = 0x000008,  // like UIWindowDebugRender
   CGContextDebugRenderVerbose    = 0x008000,

   CGContextDebugTraceDrawCalls   = UIGraphicsContextTraceDrawCalls,
   CGContextDebugDumpFrameToFile  = 0x08000000  // same bit as UIWindow
};


@interface NSObject ( CGContext)

- (BOOL) __isCGContext     MULLE_OBJC_THREADSAFE_METHOD;

@end



#if ! defined( CG_CONTEXT_LOG_DISABLED)

#define CGContextLog( format, ...)                                          \
do                                                                          \
{                                                                           \
   assert( [self __isCGContext]);                                           \
   if( self->_debuggingFlags & CGContextDebug)                              \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#define CGContextLogVerbose( format, ...)                                   \
do                                                                          \
{                                                                           \
   assert( [self __isCGContext]);                                           \
   if( self->_debuggingFlags & CGContextDebugVerbose)                       \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)


#define _CGContextRenderLog( self, format, ...)                             \
do                                                                          \
{                                                                           \
   assert( [self __isCGContext]);                                           \
   if( [self debuggingFlags] & CGContextDebugRender)                        \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#define CGContextRenderLog( format, ...)                                    \
do                                                                          \
{                                                                           \
   assert( [self __isCGContext]);                                           \
   if( self->_debuggingFlags & CGContextDebugRender)                        \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#define CGContextRenderLogVerbose( format, ...)                             \
do                                                                          \
{                                                                           \
   assert( [self __isCGContext]);                                           \
   if( self->_debuggingFlags & CGContextDebugRenderVerbose)                 \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#else

#define CGContextLog( format, ...)                  do {} while( 0)
#define CGContextLogVerbose( format, ...)           do {} while( 0)
#define _CGContextRenderLog( self, format, ...)     do {} while( 0)
#define CGContextRenderLog( format, ...)            do {} while( 0)
#define CGContextRenderLogVerbose( format, ...)     do {} while( 0)

#endif



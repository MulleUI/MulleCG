//
//  CGImage+DebugPrivate.h
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
   CGImageDebug        = 0x001,
   CGImageDebugVerbose = 0x001000
};


@interface NSObject ( CGImage)

- (BOOL) __isCGImage       MULLE_OBJC_THREADSAFE_METHOD;

@end

//
// since CGImages have been the greatest source of problems
// when developing MulleUI, we have two special log formats _CGImageLog
// which you can use in methods of a different class than GCImage, yet
// enjoy the specifity of CGImageDebuggingFlags to get log verbosity slim
//
#if ! defined( CG_IMAGE_LOG_DISABLED)

#define _CGImageLog( self, format, ...)                                     \
do                                                                          \
{                                                                           \
   assert( ! self || [self __isCGImage]);                                   \
   if( [self debuggingFlags] & CGImageDebug)                                \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#define CGImageLog( format, ...)                                            \
do                                                                          \
{                                                                           \
   assert( [self __isCGImage]);                                             \
   if( self->_debuggingFlags & CGImageDebug)                                \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#define _CGImageLogVerbose( self, format, ...)                              \
do                                                                          \
{                                                                           \
   assert( ! self || [self __isCGImage]);                                   \
   if( [self debuggingFlags] & CGImageDebugVerbose)                         \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)


#define CGImageLogVerbose( format, ...)                                     \
do                                                                          \
{                                                                           \
   assert( [self __isCGImage]);                                             \
   if( self->_debuggingFlags & CGImageDebugVerbose)                         \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#else

#define _CGImageLog( image, format, ...)          do {} while( 0)
#define CGImageLog( format, ...)                  do {} while( 0)
#define _CGImageLogVerbose( format, ...)          do {} while( 0)
#define CGImageLogVerbose( format, ...)           do {} while( 0)

#endif



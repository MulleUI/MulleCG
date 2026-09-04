//
//  CGLayoutContext.h
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
#ifdef __has_include
# if __has_include( "CGContextBase.h")
#  import "CGContextBase.h"
# endif
#endif

#import "import.h"
#include "CGFontFunctionTable.h"

// TODO: need to map NANOVG aligns to our own UI enum

@class CGFont;

@interface CGLayoutContext : CGContextBase < UILayoutContext>
{
   void                          *_fontContext;     // nanovg (or other) font context; may equal _cgBackend.context
   struct CGFontFunctionTable    _fontFunctions;    // function table for font operations
   struct mulle_map              _fontMap;
   BOOL                          _ownsFontContext;  // YES if we created _fontContext (standalone case)
   BOOL                          _hasLoadedFont;
   char                          *_defaultFontName; // will be "sans" will not be freed
}

- (BOOL) hasLoadedFont;

- (CGFloat) fontSizeThatFitsIntoSize:(CGSize) size;
- (BOOL) useFontWithNameUTF8String:(char *) name;

- (struct CGTextMetrics) visualTextMetrics;

@property( assign, getter=isTracingDrawCalls) BOOL   traceDrawCalls MULLE_OBJC_THREADSAFE_METHOD;

@end



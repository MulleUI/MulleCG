//
//  CGNullContext.h
//  MulleCG
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
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
# if __has_include( "CGLayoutContext.h")
#  import "CGLayoutContext.h"
# endif
#endif

#import "import.h"

#include "CGBackend.h"


//
// CGNullContext - a graphics context that draws nothing.
//
// It is the no-backend sibling of CGContext. Where CGContext augments
// CGLayoutContext with real GPU rendering (filled in by a backend like
// MulleCGNanovgGL), CGNullContext augments it with *no-op* rendering: every
// GPU/drawing operation does nothing and touches no OpenGL/Metal/Vulkan
// backend. This makes it safe when there is no current GPU context at all
// (headless, or a window created with UIWindowStyleNoDrawing).
//
// Crucially it still inherits the full text/layout machinery of
// CGLayoutContext, so view layout and hit-testing keep working: a backend that
// augments CGLayoutContext with a font context (e.g. nanovg's font-only
// FreeType context) gives CGNullContext real text measurement for free. If no
// backend is present at all, layout degrades gracefully -- "no backend, no
// backend".
//
// Like CGContext, this class does not formally declare <UIGraphicsContext> in
// its header; it merely implements the methods. Formal conformance is added
// later, in the window layer (MulleUIOS), where the protocol is visible.
//
@interface CGNullContext : CGLayoutContext < UIGraphicsDrawing>
{
   //
   // MUST be the first ivar, at the same layout offset that CGContext places
   // its own _cgBackend. The C accessors CGContextFN()/CGContextVG() reach the
   // backend via a @defs(CGContext) cast, i.e. purely by offset, so a
   // CGNullContext instance must have a real struct CGBackend here. Its
   // .functions vtable is filled with no-op/trace stubs
   // (CGNullContextFunctionTable) instead of GPU calls, so drawing primitives
   // resolve to safe no-ops rather than crashing on NULL function pointers.
   //
   struct CGBackend      _cgBackend;

   struct UIInputState   _inputState;
   NSUInteger            _framebufferBits;
   NSUInteger            _numberOfFrames;
   UIGraphicsBackend     _backend;
   BOOL                  _rendersOffScreen;
   BOOL                  _initializedFramebuffer;
}

// designated (mirrors CGContext), shareID/options are ignored
- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context
                            nameUTF8String:(char *) nameUTF8String
                                   shareID:(NSUInteger) shareID
                                   options:(UIGraphicsOptions) options;

- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context
                                   shareID:(NSUInteger) shareID
                                   options:(UIGraphicsOptions) options;

@end

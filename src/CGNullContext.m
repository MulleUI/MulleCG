//
//  CGNullContext.m
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
#import "CGNullContext.h"

#import "import-private.h"

// for the <CGRenderObject> protocol and -renderInContext: declaration;
// the traversal is identical to CGContext's -renderObjects:
#import "CGContext+Render.h"

// the no-op/trace drawing vtable installed into _cgBackend.functions
#include "CGFunctionTable+null.h"

#include <stdio.h>


//
// There shall be no GPU calls anywhere in this file. Every drawing and render
// operation is a deliberate no-op.
//
@implementation CGNullContext

//
// Designated initializer. Mirrors CGContext's 4-arg init, but never creates a
// GPU backend. The backend is forced to None. The super (CGLayoutContext) init
// still sets up the font/layout machinery (via -_initFontBackend), so text
// measurement and view layout keep working.
//
- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context
                            nameUTF8String:(char *) nameUTF8String
                                   shareID:(NSUInteger) shareID
                                   options:(UIGraphicsOptions) options
{
   // shareID and options are meaningless without a GPU backend
   MULLE_C_UNUSED( shareID);
   MULLE_C_UNUSED( options);

   _backend = UIGraphicsBackendNone;

   //
   // Install a real (but no-op / trace) drawing vtable. The C drawing
   // accessors CGContextFN(self)->foo(...) reach this via the _cgBackend ivar
   // (first ivar, same offset as CGContext), so drawing primitives resolve to
   // safe no-ops instead of NULL function pointers. There is no backend
   // context, so _cgBackend.context stays NULL.
   //
   _cgBackend.functions = CGNullContextFunctionTable;

   self = [self initWithOSGraphicsContext:os_context
                           nameUTF8String:nameUTF8String];

   //
   // The super init (CGLayoutContext) set up _fontFunctions from the real
   // (nanovg) font backend for measurement. Text *drawing* through a font-only
   // context asserts, so replace just those drawing slots with no-ops. Layout
   // and measurement keep using the real functions.
   //
   if( self)
      CGNullContextPatchFontFunctionTable( &self->_fontFunctions);

   return( self);
}


- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context
                                   shareID:(NSUInteger) shareID
                                   options:(UIGraphicsOptions) options
{
   return( [self initWithOSGraphicsContext:os_context
                            nameUTF8String:NULL
                                   shareID:shareID
                                   options:options]);
}


#pragma mark - identity / state

- (UIGraphicsBackend) backend
{
   return( UIGraphicsBackendNone);
}


- (char *) backendUTF8String
{
   return( "none");
}


//
// Enable/disable CGContext-level call tracing for the null backend. Mirrors
// CGContext's -setTraceFile: (which the nanovg backend routes to nvgTrace).
// Here it drives the null function table's trace facility, so drawing calls
// are logged as CGContext operations. Returns the previous trace file.
//
- (FILE *) setTraceFile:(FILE *) file
{
   return( CGNullContextFunctionTableSetTraceFile( file));
}


+ (BOOL) supportsAntiAliasing
{
   return( NO);
}


- (NSUInteger) framebufferBits
{
   return( _framebufferBits);
}

- (void) setFramebufferBits:(NSUInteger) bits
{
   _framebufferBits = bits;
}


- (BOOL) rendersOffScreen
{
   return( _rendersOffScreen);
}

- (void) setRendersOffScreen:(BOOL) flag
{
   _rendersOffScreen = flag;
}


- (BOOL) isInitializedFramebuffer
{
   return( _initializedFramebuffer);
}

- (void) setInitializedFramebuffer:(BOOL) flag
{
   _initializedFramebuffer = flag;
}


- (NSUInteger) numberOfFrames
{
   return( _numberOfFrames);
}

- (void) setNumberOfFrames:(NSUInteger) n
{
   _numberOfFrames = n;
}


#pragma mark - input state (queried by demos/widgets)

- (struct UIInputState) inputState
{
   return( _inputState);
}

- (void) setInputState:(struct UIInputState) state
{
   _inputState = state;
}

- (CGPoint) mouseLocation
{
   return( _inputState.locationInWindow);
}

- (NSUInteger) keyModifiers
{
   return( _inputState.keyModifiers);
}

- (NSUInteger) buttonStates
{
   return( _inputState.buttonStates);
}

- (struct UIKeyStates) keyStates
{
   return( _inputState.keyStates);
}


#pragma mark - render lifecycle (all no-op, just bookkeeping)

- (void) beginRender:(struct CGFrameInfo *) info
{
   // keep frame bookkeeping consistent, but touch no GPU backend
}

- (void) resumeRender
{
}

- (void) suspendRender
{
}

- (void) _endRender
{
   _numberOfFrames++;
}

- (void) endRender
{
   // balances -beginRender:; -_endRender advances the frame counter
   [self _endRender];
}

- (void) reset
{
}

- (void) barrier
{
}

- (void) renderObjects:(struct mulle_pointerarray *) array
{
   id <CGRenderObject>   obj;

   //
   // "If there is no backend, there is no backend" -- but we still call all
   // the proper methods. The traversal is identical to CGContext: every render
   // object gets -renderInContext:, so layers run their full -drawInContext:
   // logic (layout, geometry, hit-test rects, text). Only the leaf drawing
   // primitives below are no-ops, because there is no GPU to push pixels to.
   //
   mulle_pointerarray_for( array, obj)
   {
      // -renderInContext: is typed for CGContext *, but the layers use the
      // context duck-typed as id <UIGraphicsContext>. CGNullContext is a
      // CGLayoutContext, not a CGContext, so cast through id.
      [obj renderInContext:(CGContext *) (id) self];
   }
}


#pragma mark - framebuffer (no framebuffer exists)

- (BOOL) needsFramebufferClear
{
   return( NO);
}

- (void) clearFramebufferNoColor
{
}

- (void) clearFramebufferWithHexColor:(NSUInteger) color
{
}

- (id) acquireRenderedFramebuffer
{
   return( nil);
}

- (BOOL) recycleAcquiredRenderedFramebuffer:(id) layer
{
   return( NO);
}

- (struct CGBitmap) readFramebufferBitmap:(CGPixelRect) rect
                    framebufferBitmapType:(CGFramebufferBitmapType) type
                                allocator:(struct mulle_allocator *) allocator
{
   struct CGBitmap   bitmap = { 0 };

   return( bitmap);
}

- (struct CGBitmap) framebufferBitmap
{
   struct CGBitmap   bitmap = { 0 };

   return( bitmap);
}


#pragma mark - drawing (all no-op)

- (void) setCompositionMode:(UIGraphicsCompositionMode) mode
{
}

- (void) drawBitmap:(struct CGBitmap) fb
{
}

- (void) drawRect:(CGRect) rect
            image:(id) image
            scale:(BOOL) scale
{
}


#pragma mark - UIGraphicsDrawing (all no-op)

- (void) fillRect:(CGRect) rect
         hexColor:(NSUInteger) color
{
}

- (void) blitRect:(CGRect) rect
            image:(id) image
            scale:(BOOL) scale
{
}

- (void) fillRect:(CGRect) rect
           bitmap:(struct CGBitmap) fb
            scale:(BOOL) scale
{
}

- (void) strokeRect:(CGRect) rect
        strokeWidth:(CGFloat) strokeWidth
           hexColor:(NSUInteger) color
{
}

- (void) fillCircle:(CACircle) circle
           hexColor:(NSUInteger) color
{
}

- (void) strokeCircle:(CACircle) circle
          strokeWidth:(CGFloat) width
             hexColor:(NSUInteger) color
{
}

- (void) fillPoint:(CGPoint) point
         pointSize:(CGFloat) size
          hexColor:(NSUInteger) color
{
}

- (void) strokeLineFromPoint:(CGPoint) from
                     toPoint:(CGPoint) to
                 strokeWidth:(CGFloat) strokeWidth
                    hexColor:(NSUInteger) color
{
}

- (void) fillPath:(struct CGPath *) path
         hexColor:(NSUInteger) color
{
}

- (void) strokePath:(struct CGPath *) path
        strokeWidth:(CGFloat) strokeWidth
           hexColor:(NSUInteger) color
{
}

- (void) drawAtPoint:(CGPoint) position
      textUTF8String:(char *) s
  fontNameUTF8String:(char *) fontNameUTF8String
            fontSize:(CGFloat) fontSize
            hexColor:(NSUInteger) color
{
}

- (void) drawIcon:(mulle_utf32_t) icon
          atPoint:(CGPoint) point
{
}

@end

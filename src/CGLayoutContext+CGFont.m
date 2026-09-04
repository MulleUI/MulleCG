//
//  CGLayoutContext+CGFont.m
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
#import "CGLayoutContext+CGFont.h"

#import "import-private.h"

#import "CGFont.h"

#include <assert.h>


@implementation CGLayoutContext ( CGFont)

static struct mulle_container_keyvaluecallback   c_string_to_object_callback;

+ (void) load
{
   c_string_to_object_callback = (struct mulle_container_keyvaluecallback)
   {
      .keycallback   = mulle_container_keycallback_copied_cstring,
      .valuecallback = MulleObjCContainerRetainValueCallback
   };
}


- (void) _initFontCache
{
   _mulle_map_init( &_fontMap,
                    8,
                    &c_string_to_object_callback,
                    MulleObjCInstanceGetAllocator( self));
}


- (void) _doneFontCache
{
   _mulle_map_done( &_fontMap);
}


- (void) _resetFontCache
{
   mulle_map_reset( &_fontMap);
}


- (void) mulleGainAccessToFontsWithUniquingSet:(struct mulle_pointerset *) uniquing
{
   char    *name;
   CGFont  *font;

   mulle_map_for( &_fontMap, name, font)
   {
      if( mulle_pointerset_insert( uniquing, self))
         [font mulleGainAccessWithUniquingSet:uniquing];
   }
}


- (void) mulleRelinquishAccessToFontsWithUniquingSet:(struct mulle_pointerset *) uniquing
{
   char    *name;
   CGFont  *font;

   mulle_map_for( &_fontMap, name, font)
   {
      if( mulle_pointerset_insert( uniquing, self))
         [font mulleRelinquishAccessWithUniquingSet:uniquing];
   }
}


- (CGFont *) fallbackFont
{
   return( nil);  // overridden by nanovg backend
}


- (CGFont *) fontWithNameUTF8String:(char *) s
{
   return( nil);  // overridden by nanovg backend
}

- (CGFont *) defaultFont
{
   return( [self fontWithNameUTF8String:NULL]);
}


- (void *) internalFontHandleOfFont:(CGFont *) font
{
   return( NULL);  // overridden by nanovg backend
}


- (void *) internalFontHandle
{
   return( NULL);  // overridden by nanovg backend
}

@end

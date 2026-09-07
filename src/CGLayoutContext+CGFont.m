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
#import "CGSystemFont.h"

#include <assert.h>
#include <stdio.h>


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


//
// Dispatch font creation through the backend font function table. Prefers the
// face-index entry (for .ttc/.otc collections); backends without it fall
// back to the plain entry, which loads the first face only.
//
static CGFontID   _fontFunctionsCreateFontMem( CGLayoutContext *self,
                                               char *name,
                                               void *data,
                                               size_t length,
                                               BOOL freeData,
                                               NSUInteger faceIndex)
{
   struct CGFontFunctionTable   *functions;

   functions = &self->_fontFunctions;
   if( functions->createFontMemAtIndex)
      return( (*functions->createFontMemAtIndex)( self->_fontContext, name, data, length, freeData, faceIndex));
   if( functions->createFontMem)
      return( (*functions->createFontMem)( self->_fontContext, name, data, length, freeData));
   return( -1);
}


- (CGFont *) fontWithCData:(struct mulle_data) data
        fontNameUTF8String:(char *) name
                 faceIndex:(NSUInteger) faceIndex
{
   CGFont    *font;
   CGFontID  fontID;

   assert( name);

   font = mulle_map_get( &_fontMap, name);
   if( font)
      return( font);

   fontID = _fontFunctionsCreateFontMem( self, name, data.bytes, data.length, NO, faceIndex);
   if( fontID == -1)
      return( nil);

   font = [CGFont fontWithNameUTF8String:name
                                  fontID:fontID];
   mulle_map_insert( &_fontMap, name, font);
   return( font);
}


- (CGFont *) fontWithContentsOfFileWithFileRepresentationString:(char *) filename
                                             fontNameUTF8String:(char *) name
                                                      faceIndex:(NSUInteger) faceIndex
{
   CGFont    *font;
   CGFontID  fontID;
   void      *data;
   size_t    length;
   FILE      *fp;
   long      size;

   assert( filename);
   assert( name);

   font = mulle_map_get( &_fontMap, name);
   if( font)
      return( font);

   fp = fopen( filename, "rb");
   if( ! fp)
      return( nil);
   if( fseek( fp, 0, SEEK_END) != 0)
   {
      fclose( fp);
      return( nil);
   }
   size = ftell( fp);
   if( size <= 0)
   {
      fclose( fp);
      return( nil);
   }
   if( fseek( fp, 0, SEEK_SET) != 0)
   {
      fclose( fp);
      return( nil);
   }

   length = (size_t) size;
   data   = mulle_malloc( length);
   if( fread( data, 1, length, fp) != length)
   {
      mulle_free( data);
      fclose( fp);
      return( nil);
   }
   fclose( fp);

   //
   // Ownership of `data` transfers to the backend (freeData == YES); on
   // failure the backend releases it itself, matching fontstash semantics.
   //
   fontID = _fontFunctionsCreateFontMem( self, name, data, length, YES, faceIndex);
   if( fontID == -1)
      return( nil);

   font = [CGFont fontWithNameUTF8String:name
                                  fontID:fontID];
   mulle_map_insert( &_fontMap, name, font);
   return( font);
}


- (CGFont *) fontWithSystemFontDescriptor:(struct CGSystemFontDescriptor *) descriptor
{
   if( ! descriptor || ! descriptor->pathUTF8String)
      return( nil);

   return( [self fontWithContentsOfFileWithFileRepresentationString:descriptor->pathUTF8String
                                                fontNameUTF8String:descriptor->familyUTF8String
                                                         faceIndex:descriptor->faceIndex]);
}

@end

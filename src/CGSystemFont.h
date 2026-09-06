//
//  CGSystemFont.h
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
#ifndef cgsystemfont_h__
#define cgsystemfont_h__

#include "CGTypes.h"

//
// CGSystemFont — unified, cross-platform discovery of installed OS fonts.
//
// This is a pure discovery layer. It does NOT render and it does NOT load a
// font into a CGContext. It answers two questions:
//
//    (a) "which fonts are installed?"    -> CGSystemFontEnumerate
//    (b) "where is family X on disk?"     -> CGSystemFontResolve
//
// Both hand back CGSystemFontDescriptor(s) whose `pathUTF8String` you feed to
// the existing loaders, e.g.
//
//    -[CGLayoutContext fontWithContentsOfFileWithFileRepresentationString:
//                                                       fontNameUTF8String:]
//
// A concrete OS backend (fontconfig, Core Text, DirectWrite, Android NDK)
// fills these in. When no backend is compiled in, the functions behave as if
// no system fonts exist (enumerate returns 0, resolve returns NO); shipping
// your own fonts remains the fallback.
//

//
// Normalized weight. Matches the OpenType usWeightClass 100..900 scale, so it
// is platform independent. 0 means "unknown".
//
enum
{
   CGSystemFontWeightUnknown    = 0,
   CGSystemFontWeightThin       = 100,
   CGSystemFontWeightExtraLight = 200,
   CGSystemFontWeightLight      = 300,
   CGSystemFontWeightRegular    = 400,
   CGSystemFontWeightMedium     = 500,
   CGSystemFontWeightSemiBold   = 600,
   CGSystemFontWeightBold       = 700,
   CGSystemFontWeightExtraBold  = 800,
   CGSystemFontWeightBlack      = 900
};


//
// One installed face. All strings are UTF8, owned by the descriptor and freed
// by CGSystemFontDescriptorsFree(). `pathUTF8String` is an absolute path to a
// .ttf/.otf/.ttc/.otc file. For a collection file (.ttc/.otc) `faceIndex` is
// the index of this face inside it, otherwise 0.
//
struct CGSystemFontDescriptor
{
   char         *familyUTF8String;   // e.g. "DejaVu Sans"   (never NULL)
   char         *styleUTF8String;    // e.g. "Bold Italic"   (may be NULL)
   char         *pathUTF8String;     // absolute file path   (never NULL)
   NSUInteger   faceIndex;           // face in a .ttc/.otc, else 0
   NSInteger    weight;              // CGSystemFontWeight..., 0 if unknown
   BOOL         italic;
};


//
// A query for CGSystemFontResolve(). Only familyUTF8String is required; set
// weight to 0 and italic to NO to mean "don't care".
//
struct CGSystemFontQuery
{
   char         *familyUTF8String;   // required
   NSInteger    weight;              // 0 == any
   BOOL         italic;
};


//
// YES if a real OS backend is compiled in for this platform. When NO, the
// enumerate/resolve calls are no-ops (0 results / NO). Useful to decide
// whether to fall back to shipped fonts.
//
MULLE_CG_GLOBAL
BOOL   CGSystemFontIsAvailable( void);


//
// Name of the active backend for diagnostics, e.g. "fontconfig", "coretext",
// "directwrite", "android" or "none". Never NULL.
//
MULLE_CG_GLOBAL
char   *CGSystemFontBackendUTF8String( void);


//
// Enumerate installed faces. Allocates an array of `*count` descriptors and
// stores it in `*descriptors`. Returns the number of descriptors (also stored
// in *count), 0 if none / no backend. Free the result with
// CGSystemFontDescriptorsFree( descriptors, count).
//
// This does file I/O and can be slow-ish; call it off the render path.
//
MULLE_CG_GLOBAL
NSUInteger   CGSystemFontEnumerate( struct CGSystemFontDescriptor **descriptors,
                                    NSUInteger *count);


//
// Resolve a family (optionally weight/italic) to a single best-matching face.
// Fills `*descriptor` and returns YES on success. On success free the single
// descriptor's owned strings with CGSystemFontDescriptorDone( descriptor).
// Returns NO if nothing matched / no backend.
//
// A good backend (e.g. fontconfig) applies fallback substitution, so this
// tends to always succeed if any font exists.
//
MULLE_CG_GLOBAL
BOOL   CGSystemFontResolve( struct CGSystemFontQuery *query,
                            struct CGSystemFontDescriptor *descriptor);


//
// Release the strings owned by a single descriptor obtained from
// CGSystemFontResolve(). Does not free the descriptor struct itself.
//
MULLE_CG_GLOBAL
void   CGSystemFontDescriptorDone( struct CGSystemFontDescriptor *descriptor);


//
// Free an array of descriptors obtained from CGSystemFontEnumerate(), including
// the array itself. Safe to call with NULL.
//
MULLE_CG_GLOBAL
void   CGSystemFontDescriptorsFree( struct CGSystemFontDescriptor *descriptors,
                                    NSUInteger count);

#endif

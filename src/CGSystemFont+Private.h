//
//  CGSystemFont+Private.h
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
#ifndef cgsystemfont_private_h__
#define cgsystemfont_private_h__

#include "CGSystemFont.h"

//
// Backend vtable. A platform backend (fontconfig, coretext, ...) fills one of
// these and registers it with CGSystemFontRegisterBackend(). The public
// CGSystemFont* functions dispatch through the registered backend. If none is
// registered the public API is a no-op ("none" backend).
//
// enumerate: allocate `*descriptors` (mulle_malloc) and return the count.
// resolve:   fill `descriptor`, return YES on match.
//
// Backends allocate all descriptor strings and the array with mulle_malloc /
// mulle_strdup so the dispatcher can free them uniformly with mulle_free.
//
struct CGSystemFontBackend
{
   char         *nameUTF8String;
   NSUInteger   (*enumerate)( struct CGSystemFontDescriptor **descriptors,
                              NSUInteger *count);
   BOOL         (*resolve)( struct CGSystemFontQuery *query,
                            struct CGSystemFontDescriptor *descriptor);
};


//
// Register the platform backend. Called from a backend's constructor/+load.
// Last registration wins; a NULL argument is ignored.
//
MULLE_CG_GLOBAL
void   CGSystemFontRegisterBackend( struct CGSystemFontBackend *backend);

#endif

//
//  CGContext+Shader.h
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
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


// In OpenGL a shader (vertex/fragment) is part of a "program",
// this is really what CGShaderID is..

@interface CGContext( Shader)

// preferred interface. register sources globally and useShaders by
// their name  (if unknown returns 0)
- (CGShaderID) useShaderWithNameUTF8String:(char *) name;

// manually managing shaders might not be useful on a per-frame basis
- (void) deleteShaderWithNameUTF8String:(char *) name;
- (void) deleteShaders;

// inconvenient interface (shaders will still be registered by name)
// if compile/link didn't work you get 0 as an error
- (CGShaderID) compileShaderWithShaderSources:(struct CGShaderUTF8Sources *) source;
- (CGShaderID) compileShaderWithNameUTF8String:(char *) name;

// will compile on demand
- (CGShaderID) shaderWithNameUTF8String:(char *) name;
// will not compile on demand
- (CGShaderID) _shaderWithNameUTF8String:(char *) name;
- (void) useShader:(CGShaderID) shaderID;
- (void) deleteShader:(CGShaderID) shaderID;



//
//
+ (void) registerShaderSources:(struct CGShaderUTF8Sources *) sources;
+ (void) registerShaderSources:(struct CGShaderUTF8Sources *) sources
             forNameUTF8String:(char *) nameUTF8String;

- (struct CGShaderUTF8Sources *)
   registeredShaderSourcesForNameUTF8String:(char *) nameUTF8String;
@end


@interface CGContext( Future) < MulleObjCFuture>

- (char *) shaderHeaderUTF8String;

- (CGShaderID) _compileShaderWithShaderSources:(struct CGShaderUTF8Sources *) source;

- (void) _useShader:(CGShaderID) shaderID;

- (void) _deleteShader:(CGShaderID) shaderID;

- (char *) shaderHeaderUTF8String;

@end

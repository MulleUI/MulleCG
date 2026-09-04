//
//  CGContext+ImageEffect.h
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
// CGContext+ImageEffect.h
// MulleCG
//
// Render an image through a custom shader into a new image.
// Implementation provided by MulleCGNanovgGL.
//
#import "import.h"


typedef void   CGShaderSetupCallback( CGShaderID shader, void *userInfo);


enum CGUniformType
{
   CGUniformTypeFloat,
   CGUniformTypeVec2,
   CGUniformTypeVec4,
   CGUniformTypeInt
};


struct CGUniform
{
   char                  *name;
   enum CGUniformType    type;
   union
   {
      float   floatValue;
      float   vec2[2];
      float   vec4[4];
      int     intValue;
   };
};


@interface CGContext( ImageEffectFuture) < MulleObjCFuture>

- (CGImage *) imageByRenderingImage:(CGImage *) image
                         withShader:(CGShaderID) shader
                           uniforms:(struct CGUniform *) uniforms
                              count:(NSUInteger) count;

- (CGImage *) imageByRenderingImage:(CGImage *) image
                         withShader:(CGShaderID) shader
                      setupCallback:(CGShaderSetupCallback *) setup
                           userInfo:(void *) info;

@end

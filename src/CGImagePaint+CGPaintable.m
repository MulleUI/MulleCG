//
//  CGImagePaint+CGPaintable.m
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
#import "CGImagePaint.h"
#import "CGPaintable.h"
#import "CGContext+Drawing.h"
#import "CGContext+ImageEffect.h"
#import "CGContext+Shader.h"
#import "CGImage.h"

#import "import-private.h"


static char   s_desatVertexSource[] =
   "attribute vec3 vert;\n"
   "varying vec2 fragTexCoord;\n"
   "void main() {\n"
   //
   // Flip V: nvgluCreateFramebuffer forces NVG_IMAGE_FLIPY on the output
   // texture.  Nanovg will invert V when drawing it later, so we must
   // write pixels upside-down into the FBO to end up right-side-up.
   //
   "   fragTexCoord = vec2( (vert.x * 0.5) + 0.5, 0.5 - (vert.y * 0.5));\n"
   "   gl_Position  = vec4( vert, 1);\n"
   "}\n";

static char   s_desatFragmentSource[] =
   "precision mediump float;\n"
   "uniform sampler2D u_tex0;\n"
   "uniform float     u_saturation;\n"
   "uniform float     u_brightness;\n"
   "varying vec2      fragTexCoord;\n"
   "void main() {\n"
   "   vec4  color = texture2D( u_tex0, fragTexCoord);\n"
   "   float gray  = dot( color.rgb, vec3( 0.299, 0.587, 0.114));\n"
   "   color.rgb   = mix( vec3( gray), color.rgb, u_saturation) + u_brightness;\n"
   "   gl_FragColor = color;\n"
   "}\n";

static struct CGShaderUTF8Sources   s_desatShaderSources =
{
   "CGImagePaint_desaturate",
   s_desatVertexSource,
   s_desatFragmentSource,
   NULL,
   NULL
};


@implementation CGImagePaint( CGPaintable)

- (CGImage *) processedImage
{
   CGImage            *image;
   CGContext          *context;
   CGShaderID         shader;
   struct CGUniform   uniforms[2];

   image = [[self image] resolvedImage];

   if( _saturation == 1.0 && _brightness == 0.0)
      return( image);

   if( _processedImage)
      return( _processedImage);

   context = [image context];

   shader = [context compileShaderWithShaderSources:&s_desatShaderSources];
   if( ! shader)
      return( image);

   uniforms[0].name       = "u_saturation";
   uniforms[0].type       = CGUniformTypeFloat;
   uniforms[0].floatValue = (float) _saturation;
   uniforms[1].name       = "u_brightness";
   uniforms[1].type       = CGUniformTypeFloat;
   uniforms[1].floatValue = (float) _brightness;

   _processedImage = [[context imageByRenderingImage:image
                                          withShader:shader
                                            uniforms:uniforms
                                               count:2] retain];
   return( _processedImage ? _processedImage : image);
}


- (void) fillWithBounds:(CGRect) rect
                options:(struct CGFillOptions *) options
                context:(CGContext *) context
{
   CGImage       *image;
   CGTextureID   textureID;

   assert( options);

   if( ! context)
      return;

   image     = [self processedImage];
   textureID = [image textureID];
   if( textureID == CGTextureIDInvalid)
      return;

   CGContextSetFillImagePattern( context, textureID, rect,
                                 options->paint.rotation + [self rotation],
                                 options->paint.alpha * [self alpha]);
   CGContextFill( context);
}


- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
                  options:(struct CGStrokeOptions *) options
                  context:(CGContext *) context
{
   CGImage       *image;
   CGTextureID   textureID;

   assert( options);
   assert( strokeWidth > 0.0f);

   if( ! context)
      return;

   image     = [self processedImage];
   textureID = [image textureID];
   if( textureID == CGTextureIDInvalid)
      return;

   CGContextSetStrokeImagePattern( context, textureID, rect,
                                   options->paint.rotation + [self rotation],
                                   options->paint.alpha * [self alpha]);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}

@end

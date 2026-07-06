//
// Copyright (c) Nat!, Mulle kybernetiK
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

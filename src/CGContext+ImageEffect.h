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

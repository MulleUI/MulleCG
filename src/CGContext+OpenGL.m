//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
#import "CGContext+OpenGL.h"

#import "import-private.h"



@implementation CGContext ( OpenGL)

static void   checkCompileErrors( GLuint shader, char *type, char *name)
{
   GLint   success;
   GLchar   infoLog[ 1024];

   glGetShaderiv( shader, GL_COMPILE_STATUS, &success);
   if( ! success)
   {
       glGetShaderInfoLog( shader, 1024, NULL, infoLog);
       fprintf( stderr, "%s %s compile error: %s\n", name, type, infoLog);
   }
}

static void   checkLinkErrors( GLuint shader, char *name)
{
   GLint   success;
   GLchar   infoLog[ 1024];

   glGetProgramiv( shader, GL_LINK_STATUS, &success);
   if( ! success)
   {
       glGetShaderInfoLog( shader, 1024, NULL, infoLog);
       fprintf( stderr, "%s link error: %s\n", name, infoLog);
   }
}

//
// TODO: remember under name as resource somehow
//
- (NSUInteger) compileVertexShader:(char *) vertexShaderCode
                    fragmentShader:(char *) fragmentShaderCode
                    nameUTF8String:(char *) name
{
   GLuint   vertex;
   GLuint   fragment;
   GLuint   shaderID;

   vertex = glCreateShader( GL_VERTEX_SHADER);
   glShaderSource( vertex, 1, (const GLchar *const *) &vertexShaderCode, NULL);
   glCompileShader( vertex);
   checkCompileErrors( vertex, "vertex", name);

   fragment = glCreateShader( GL_FRAGMENT_SHADER);
   glShaderSource( fragment, 1, (const GLchar *const *) &fragmentShaderCode, NULL);
   glCompileShader( fragment);
   checkCompileErrors( fragment, "fragment", name);

   shaderID = glCreateProgram();
   glAttachShader( shaderID, vertex);
   glAttachShader( shaderID, fragment);
   glLinkProgram( shaderID);
   checkLinkErrors( shaderID, name);

   return( shaderID);
}


- (void) useShader:(GLuint) shaderID
{
   glUseProgram( shaderID); 
}
 
@end

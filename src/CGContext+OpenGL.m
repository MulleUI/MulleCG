//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
#import "CGContext+OpenGL.h"

#import "import-private.h"

#include <ctype.h>


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
   GLchar  infoLog[ 1024];

   glGetProgramiv( shader, GL_LINK_STATUS, &success);
   if( ! success)
   {
       glGetShaderInfoLog( shader, 1024, NULL, infoLog);
       fprintf( stderr, "%s link error: %s\n", name, infoLog);
   }
}


static int  has_version_header( char *s)
{
   while( isblank( *s))
      ++s;
   if( *s != '#')
      return( 0);
   ++s;

   while( isblank( *s))
      ++s;
   if( ! strncmp( s, "version", 7))
   {
      s += 7;
      if( isblank( *s))
         return( 1);
   }
   return( 0);   
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
   char     *sources[ 2];
   
   vertex = glCreateShader( GL_VERTEX_SHADER);

   // put a "proper" version header on top of the shader, if there is none
   // will be like nanovg shader version
   sources[ 0] = has_version_header( vertexShaderCode) ? "" : [self shaderHeaderUTF8String];
   sources[ 1] = vertexShaderCode;
   glShaderSource( vertex, 2, (const GLchar *const *) sources, NULL);
   glCompileShader( vertex);
   checkCompileErrors( vertex, "vertex", name);

   // put a "proper" version header on top of the shader, if there is none
   // will be like nanovg shader version
   sources[ 0] = has_version_header( fragmentShaderCode) ? "" : [self shaderHeaderUTF8String];
   sources[ 1] = fragmentShaderCode;

   fragment = glCreateShader( GL_FRAGMENT_SHADER);
   glShaderSource( fragment, 2, (const GLchar *const *) sources, NULL);
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

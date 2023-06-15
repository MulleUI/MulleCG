//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGContext+Shader.h"

#import "import-private.h"

#import "CGContext+OpenGL.h"

#include <ctype.h>


@implementation CGContext ( Shader)


static char  *CGShaderTypeUTF8String( int type)
{
   switch( type)
   {
   case GL_VERTEX_SHADER   : return( "vertex");
   case GL_FRAGMENT_SHADER : return( "fragment");
   default                 : return( "geometry");
   }
}


static void   parse_uniforms_into_assoc( char *s, struct mulle_assoc *assoc)
{
   char   *start;
   char   *token;
   char   *name;
   char   *type;

   start = s;
   while( *s != '\0')
   {
      token = strtok_r( start, "\r\n\t ", &s);
      start = NULL;
      if( ! token)
         break;

      if( ! strcmp( token, "uniform"))
      {
         type = strtok_r( start, "\r\n\t ", &s);
         name = strtok_r( start, "\r\n\t; ", &s);
         mulle_assoc_set( assoc, name, type);
      }
   }
}


void   CGShaderUTF8SourcesParseUniforms( struct CGShaderUTF8Sources *sources,
                                         struct mulle_assoc *assoc)
{
   char   *s;
   char   tmp[ 512];

   if( ! sources)
      return;

   mulle_buffer_do_flexible( buffer, tmp, sizeof( tmp))
   {
      if( sources->vertexSource)
      {
         mulle_buffer_add_string( buffer, sources->vertexSource);
         s = mulle_buffer_get_string( buffer);
         parse_uniforms_into_assoc( s, assoc);
      }

      if( sources->fragmentSource)
      {
         mulle_buffer_reset( buffer);
         mulle_buffer_add_string( buffer, sources->fragmentSource);
         s = mulle_buffer_get_string( buffer);
         parse_uniforms_into_assoc( s, assoc);
      }

      if( sources->geometrySource)
      {
         mulle_buffer_reset( buffer);
         mulle_buffer_add_string( buffer, sources->geometrySource);
         s = mulle_buffer_get_string( buffer);
         parse_uniforms_into_assoc( s, assoc);
      }
   }
}



static char   *parse_source_version( char *s)
{
   char   *start;
   char   *token;
   int    state;

   start = s;
   state = 0;
   while( *s != '\0')
   {
      token = strtok_r( start, ":\r\n\t ", &s);
      start = NULL;
      if( ! token)
         break;

      switch( state)
      {
      case 0 :
         state = ! strcmp( token, "//") ? 1 : 0;
         continue;

      case 1 :
         state = ! strcmp( token, "shader-version") ? 2 : 0;
         continue;

      case 2 :
         if( isalnum( *token))
            return( token);
         state = 0;
      }
   }
   return( NULL);
}


char  *CGShaderGetSourceVersion( char *source)
{
   char   *s;
   char   tmp[ 512];
   char   *version;
   char   *dup;

   if( ! source)
      return( NULL);

   mulle_buffer_do_flexible( buffer, tmp, sizeof( tmp))
   {
      mulle_buffer_add_string( buffer, source);
      s       = mulle_buffer_get_string( buffer);
      version = parse_source_version( s);
   }
   if( ! version)
      return( "???");
   dup = mulle_strdup( version);
   return( MulleObjCAutoreleaseAllocation( dup, NULL));
}


static BOOL   checkCompileErrors( GLuint shader, int type, char *name)
{
   GLint   success;
   GLint   logSize;

   glGetShaderiv( shader, GL_COMPILE_STATUS, &success);
   if( success != GL_TRUE)
   {
      logSize = 0;
      glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logSize);
      mulle_flexbuffer_do( tmp, 256, logSize < 16 ? 16 : logSize)
      {
         strcpy( tmp, "???");
         glGetShaderInfoLog( shader, logSize, NULL, tmp);
         fprintf( stderr, "%s shader \"%s\" compile error: %s\n",
                          name,
                          CGShaderTypeUTF8String( type),
                          tmp);
         return( NO);
      }
   }
   return( YES);
}


static BOOL   checkLinkErrors( GLuint shader, char *name)
{
   GLint   success;
   GLint   logSize;

   glGetProgramiv( shader, GL_LINK_STATUS, &success);
   if( success != GL_TRUE)
   {
      logSize = 0;
      glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logSize);
      mulle_flexbuffer_do( tmp, 256, logSize < 16 ? 16 : logSize)
      {
         strcpy( tmp, "???");
         glGetShaderInfoLog( shader, logSize, NULL, tmp);
         fprintf( stderr, "shader \"%s\" link error: %s\n", name, tmp);
      }
      return( NO);
   }
   return( YES);
}


static int   has_version_header( char *s)
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


- (char *) shaderHeaderUTF8String
{
#ifdef NANOVG_GL3_IMPLEMENTATION
   return( "#version 150 core\n");
#endif
#ifdef NANOVG_GLES2_IMPLEMENTATION
   return( "#version 100\n");
#endif
#ifdef NANOVG_GLES3_IMPLEMENTATION
   return( "#version 300 es\n");
#endif
   return( "");
}


static GLuint   CGContextCompileShader( CGContext *self, char *source, int type, char *name)
{
   char     *headerAndSource[ 2];
   GLuint   shader;

   assert( self);
   assert( source);
   assert( name);

      // put a "proper" version header on top of the shader, if there is none
      // will be like nanovg shader version
   headerAndSource[ 0] = has_version_header( source) ? "" : [self shaderHeaderUTF8String];
   headerAndSource[ 1] = source;

   shader = glCreateShader( type);
   CGContextCheckBackendError( self, "after glCreateShader");

   glShaderSource( shader, 2, (const GLchar *const *) headerAndSource, NULL);
   CGContextCheckBackendError( self, "after glShaderSource");

   if( self->_debugEnabled)
      MulleUICLog( "Compiling %s shader \"%s\" version: %s",
                  CGShaderTypeUTF8String( type),
                  name,
                  CGShaderGetSourceVersion( source));
   glCompileShader( shader);
   CGContextCheckBackendError( self, "after glCompileShader");
   if( ! checkCompileErrors( shader, type, name))
   {
      errno = EFAULT;
      return( 0);
   }
   return( shader);
}

//
// OpenGL 4.5 implementations are guaranteed to support version 4.50 of the
// OpenGL Shading Language. All references to sections of that specification
// refer to that version. The latest supported version of the shading language
// may be queried as described in section 22.2. The core profile of OpenGL 4.5
// is also guaranteed to support all previous versions of the OpenGL Shading
// Language back to version 1.40.
//
// https://stackoverflow.com/questions/27407774/get-supported-glsl-versions
//
// GL version                     GLSL version
// 2.0                            1.10
// 2.1                            1.20
// 3.0                            1.30
// 3.1                            1.40
// 3.2                            1.50
// 3.3                            3.30
// 4.0                            4.00
// 4.1                            4.10
// 4.2                            4.20
// 4.3                            4.30
// 4.4                            4.40
// 4.5                            4.50
//
//
// GLES version                  GLSL version
// 2.0                            1.00 ES
// 3.0                            3.00 ES
// 3.1                            3.10 ES
//
// TODO: remember under name as resource somehow
//
// OpenGL ES 3.1 implementations are guaranteed to support versions 3.10, 3.00
// and 1.00 of the OpenGL ES Shading Language.
//
// OpenGL 4.5 implementations are guaranteed to support versions 1.00, 3.00,
// and 3.10 of the OpenGL ES Shading Language.
//
- (CGShaderID) compileShaderWithShaderSources:(struct CGShaderUTF8Sources *) sources
{
   GLuint   vertex;
   GLuint   fragment;
   GLuint   geometry;
   GLuint   shader;

   assert( sources);
   assert( sources->name);
   assert( sources->name[ 0]);

   vertex   = 0;
   fragment = 0;
   geometry = 0;

   if( _debugEnabled)
      MulleUICLog( "Default shader language version: %s", glGetString(GL_SHADING_LANGUAGE_VERSION));

   if( sources->vertexSource)
   {
      vertex = CGContextCompileShader( self,
                                       sources->vertexSource,
                                       GL_VERTEX_SHADER,
                                       sources->name);
      if( ! vertex)
         return( 0);
   }

   if( sources->fragmentSource)
   {
      fragment = CGContextCompileShader( self,
                                         sources->fragmentSource,
                                         GL_FRAGMENT_SHADER,
                                         sources->name);
      if( ! fragment)
         return( 0);
   }

   if( sources->geometrySource)
   {
#ifdef GL_GEOMETRY_SHADER
      geometry = CGContextCompileShader( self,
                                         sources->geometrySource,
                                         GL_FRAGMENT_SHADER,
                                         sources->name);
      if( ! geometry)
         return( 0);
#else
      fprintf( stderr, "Geometry shaders are not supported by backend\n");
      errno = EDOM;
      return( 0);
#endif
   }

   shader = glCreateProgram();
   if( ! shader)
   {
      fprintf( stderr, "Could not create a shader \"%s\" program (no backend support ?)\n", sources->name);
      errno = EDOM;
      return( 0);
   }

   // According to the OpenGL documentation, calling glAttachShader() with
   // a parameter of 0 will generate an GL_INVALID_VALUE error
   if( vertex)
      glAttachShader( shader, vertex);
   if( geometry)
      glAttachShader( shader, geometry);
   if( fragment)
      glAttachShader( shader, fragment);

   CGContextCheckBackendError( self, "after glAttachShader");

   // NOTE: you could have multiple fragment shaders (only one has a main)
   //       function and link them together, but OpenGLES precludes this
   // https://stackoverflow.com/questions/2344265/can-you-have-multiple-pixel-fragment-shaders-in-the-same-program
   glLinkProgram( shader);
   CGContextCheckBackendError( self, "after glLinkProgram");
   if( ! checkLinkErrors( shader, sources->name))
   {
      glDeleteProgram( shader);
      CGContextCheckBackendError( self, "after glDeleteProgram");
      errno  = EINVAL;
      shader = 0;
   }

   // According to the OpenGL documentation, calling glDeleteShader() with
   // a parameter of 0 has no effect
   if( geometry)
      glDetachShader( shader, geometry);
   if( fragment)
      glDetachShader( shader, fragment);
   if( vertex)
      glDetachShader( shader, vertex);

   CGContextCheckBackendError( self, "after glDetachShader");

   glDeleteShader( geometry);
   CGContextCheckBackendError( self, "after glDeleteShader");
   glDeleteShader( fragment);
   CGContextCheckBackendError( self, "after glDeleteShader");
   glDeleteShader( vertex);
   CGContextCheckBackendError( self, "after glDeleteShader");

   if( shader)
      mulle_map_insert( &_shaderMap, sources->name, (void *) (uintptr_t) shader);
   return( (CGShaderID) shader);
}


- (void) useShader:(CGShaderID) shaderID
{
   assert( shaderID);
   glUseProgram( (GLuint) (uintptr_t) shaderID);
   CGContextCheckBackendError( self, "after glUseProgram");

   _activeShader = shaderID;
}


- (CGShaderID) compileShaderWithNameUTF8String:(char *) name
{
   struct CGShaderUTF8Sources   *sources;

   assert( ! mulle_map_get( &_shaderMap, name));

   sources = [self registeredShaderSourcesForNameUTF8String:name];
   if( ! sources)
   {
      fprintf( stderr, "need a shader \"%s\" to be registered ahead of use\n", name);
      abort();
   }
   return( [self compileShaderWithShaderSources:sources]);
}


- (CGShaderID) _shaderWithNameUTF8String:(char *) name
{
   return( (CGShaderID) mulle_map_get( &_shaderMap, name));
}


- (CGShaderID) shaderWithNameUTF8String:(char *) name
{
   CGShaderID   shaderID;

   shaderID = (CGShaderID) mulle_map_get( &_shaderMap, name);
   if( ! shaderID)
      shaderID = [self compileShaderWithNameUTF8String:name];
   return( shaderID);
}


- (CGShaderID) useShaderWithNameUTF8String:(char *) name
{
   CGShaderID   shaderID;

   shaderID = [self shaderWithNameUTF8String:name];
   if( ! shaderID)
      return( 0);
   [self useShader:shaderID];
   return( shaderID);
}


- (void) deleteShader:(CGShaderID) shaderID
{
   void  *name;
   void  *mappedID;

   mulle_map_for( &_shaderMap, name, mappedID)
   {
      if( mappedID == (void *) shaderID)
         break;
   }
   if( ! name)
      abort();

   [self deleteShaderWithNameUTF8String:name];
}


- (void) deleteShaderWithNameUTF8String:(char *) name
{
   void   *shaderID;

   shaderID = mulle_map_get( &_shaderMap, name);
   assert( shaderID);
   if( _debugEnabled & 0x2)
      MulleUILog( "release shader \"%s\"", (NSInteger) name);
   glDeleteProgram( (GLuint) (uintptr_t) shaderID);
   CGContextCheckBackendError( self, "after glDeleteProgram");
   mulle_map_remove( &_shaderMap, name);
}


- (void) deleteShaders
{
   void   *name;
   void   *shaderID;

   mulle_map_for( &_shaderMap, name, shaderID)
   {
      if( _debugEnabled & 0x2)
         MulleUILog( "release shader \"%s\"", name);
      glDeleteProgram( (GLuint) (uintptr_t) shaderID);
      CGContextCheckBackendError( self, "after glDeleteProgram");
   }

   mulle_map_reset( &_shaderMap);
}

@end

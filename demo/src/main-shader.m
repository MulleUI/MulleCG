#define GLFW_INCLUDE_ES3

#import "import.h"

#import "import-private.h"

#define DRAW_TEXTURE


static char   vertexShaderSource[] =
#include "rect.vert.inc"
;

static char   fragmentShaderSource[] =
#include "blur.frag.inc"
;


#include "bitmap2.inc"


static struct CGShaderUTF8Sources   monochromeShaderSources =
{
   "blur",
   vertexShaderSource,
   fragmentShaderSource,
   NULL,
   NULL
};


@interface DemoLayer : CAOpenGLLayer
{
   GLuint      _VBO;
   GLuint      _VAO;
   CGShaderID  _shaderProgram;
}
@end


@implementation DemoLayer

- (void) initShaderProgramWithContext:(CGContext *) context
{
   _shaderProgram = [context compileShaderWithShaderSources:&monochromeShaderSources];
   CGContextCheckBackendError( context, "after compileShaderWithShaderSources");
   assert( _shaderProgram);
}


- (void) initVertexBufferWithContext:(CGContext *) context
{
    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------
    static float vertices[] = {
         0.75f, -0.75f, 0.0f,  // bottom right
        -0.75f, -0.75f, 0.0f,  // bottom left
          0.0f,  0.75f, 0.0f   // top
    };

   glGenVertexArrays( 1, &_VAO);
   CGContextCheckBackendError( context, "after glGenVertexArrays");
    // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
   glBindVertexArray( _VAO);
   CGContextCheckBackendError( context, "after glBindVertexArray");

   glGenBuffers( 1, &_VBO);
   CGContextCheckBackendError( context, "after glGenBuffers");
   glBindBuffer( GL_ARRAY_BUFFER, _VBO);
   CGContextCheckBackendError( context, "after glBindBuffer");
   glBufferData( GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
   CGContextCheckBackendError( context, "after glBufferData");

   glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
   CGContextCheckBackendError( context, "after glVertexAttribPointer");
   glEnableVertexAttribArray(0);
   CGContextCheckBackendError( context, "after glEnableVertexAttribArray");

   // You can unbind the VAO afterwards so other VAO calls won't accidentally
   // modify this _VAO, but this rarely happens. Modifying other
   // VAOs requires a call to glBindVertexArray anyways so we generally
   // don't unbind VAOs (nor VBOs) when it's not directly necessary.
   // glBindVertexArray(0);
}


static MulleUIResourceStorageKeyDefine( test_image);


- (void) drawOpenGLInContext:(CGContext *) context
{
   float     timeValue;
   float     greenValue;
   GLint     texLoc;
   GLfloat   rgba[ 4];
   CGImage   *image;

   if( ! _VAO)
      [self initVertexBufferWithContext:context];
   if( ! _shaderProgram)
      [self initShaderProgramWithContext:context];

   glBindVertexArray(_VAO);
   CGContextCheckBackendError( context, "after glBindVertexArray");
   [context useShader:_shaderProgram];

#ifdef DRAW_TEXTURE
   image = [context imageWithRGBABytes:bitmap2
                            bitmapSize:CGPixelSizeMake( 32, 32)
                          textureFlags:0
                        nameUTF8String:NULL
                           resourceKey:MulleUIResourceStorageKey( test_image)];
   assert( image);
   [context bindImage:image
        toTextureUnit:0];

//  update shader uniform
//   timeValue  = glfwGetTime();
//   greenValue = sin(timeValue) / 2.0f + 0.5f;

//   vertexColorLocation = glGetUniformLocation(_shaderProgram, "ourColor");
//
//   rgba[ 0] = 0.0;
//   rgba[ 1] = greenValue;
//   rgba[ 2] = 0.0;
//   rgba[ 3] = 1.0;
//
//   // MEMO: glUniform4f does not work !!!
   texLoc = glGetUniformLocation( (GLuint) _shaderProgram, "u_tex0");
   // if we assert here, the shader has some glitch and the uniform was
   // optimized away
   if( texLoc == -1)
   {
      fprintf( stderr, "An expected shader uniform has been optimized away (indicating a shader version, OpenGL version mismatch most likely).");
      exit( 1);
   }
   glUniform1i( texLoc, 0);
#endif

   // render the triangle
   glDrawArrays(GL_TRIANGLES, 0, 3);
}


- (void) finalize
{
   if( _VAO)
      glDeleteVertexArrays( 1, &_VAO);
   if( _VBO)
      glDeleteBuffers( 1, &_VBO);
   // [self deleteShader:_shaderProgram];

   [super finalize];
}

@end


static void   usage( void)
{
   fprintf( stderr, "\n"
"Usage:\n"
"   shader [options]\n"
"\n"
"Options:\n"
"   -a      : disable default antialias (nvg/glfw)\n"
"   -d      : support deprecated OpenGL\n"
"   -f      : force edge antialias (nvg)\n"
"   -r      : not retained\n"
"\n");
   exit( 1);
}


int   main( int argc, char *argv[])
{
   UIWindow          *window;
   UIApplication     *app;
   CGGraphicsLayer   *layer;
   NSUInteger        styleMask;
   int               i;

   styleMask = UIWindowStyleMaskDefault;

   /*
    * window and app
    */
   for( i = 1; i < argc; i++)
   {
      if( argv[ i][ 0] != '-')
         break;

      switch( argv[ i][ 1])
      {
      case 'a' :
         styleMask &= ~UIWindowStyleAntiAlias;
         break;

      case 'd' :
         styleMask |= UIWindowOpenGLDeprecated;
         break;

      case 'f' :
         styleMask |= UIWindowStyleForceEdgeAntiAlias;
         break;

      case 'r' :
         styleMask &= ~UIWindowStyleRetained;
         break;

      default :
         usage();
      }
   }

   if( i != argc)
      usage();

   app = [UIApplication sharedInstance];
   @autoreleasepool
   {
      [CGContext setDebuggingFlags:YES];
      layer  = [DemoLayer layerWithFrame:CGRectMake( 20, 20, 600, 340)];
      window = [UIWindow windowWithLayer:layer
                         titleUTF8String:"Demo"
                               styleMask:styleMask];

      assert( window);
      [window setBackgroundColor:CGColorMakeGray()];
      [window setFrameRateHz:1.0];
      [app addWindow:window];
   }
   return( [app runApp]);
}





//
//                           ,╓≤æKª╨╙╙▓█D"╙╙╙*╨¥W▄╓,
//                      ╓▄ª╙└╧▓        █           ⁿ▓▓ª╦w
//                  ╓#╜^*█⌐   `╕       █           ╓▌    `╙%w
//               ╓ΦΓ      █    ╙⌐     ,█,,,Φ      ╓▌         ╙¥▄
//            ,▄▀ █▄       █µ,╓╝,╓≤╗≡≡ª╨╨╨¥≡∞╗w╓,ª█,  ,       ]▄▀V,
//          ,Φ└   ║"▀▄     ,▄▀╨"                 "╙¥▓▓       ▄▀  º▄¥,
//        ,#▌Φ▓▄╓  Φ `█Q▄M╙                           ╙¥▄ ,▄▀ ╙▄⌐`  `Φ
//       ▄▀   `V,"▀▀¼╓╩└                                 ╙¥▓╗ ,       ╙▄
//      Φ       `¥═▄▀                            ╒          ▀▄          ▓
//    .▓         ╓▓]V▄H       ▓                 ,Å            ▀,         ▀
//    █      ,-ª▓╛  `██▀½      "▄  ,╓╓╓╓;╓▄▄▄▄╗▄█,             ╙▄         ▀
//   █  `██▄   ▓. - Φ█═.~     ,≤█▄▀-      `   █└"▀▀▀▀▄╓╓╓╓       ▌    ██▄, █
//  ║⌐  " ▀   ▓╨⌐   }▀`      ,█  `           █      .█▀▄▄███▄     ▌  ` ▀    ▌
//  ▌        ▐M A   '┴      ▌                ▀        ╙█▌████▌    ╙▄        ║⌐
// ║⌐        █⌐'║▄ Γr2«    ║▀                 ▄▄▄      ╙▌▄███      █         ▌
// █]     ,▄▐H  ██████═ª  ╓` ▄█▀▀▀▀█▄        ████     ╓███` `╙╙║█  ▐H        █
// █ "% ,▄▀ ║░╠K█═╣███^   ╛╓█▀      ▐█         ,╓╓═ª╙└   █      ╙█▄▐▌▓######▌╫
// █║▄▄▄█▄▄▄║H:  "╙▀███▄╓▄,█▌╓▄,,▄∩  ██p$ΦΦ▀▀▀▀▀ΦΦΦR≡≥▄╓ ║▄       ╙j▌` ▄▀╙╗ `╫
// █"      ╙▐H-═M ▄███████¥█H "^╙    '█, ,«^``     `     ║▌        ▐M▄▀    "Φ█
// ║        !█▄▄████≤═^`╓█ █▌╓▀╦▄▀█   ╙█⌐               ╓█▌        ▓ `       █
//  ▌      ,▄██╫██ ▄█═╜" █▌▐█╣Hj⌐ █    █▌╙¥w,           ██▄       ╓▌        ▐M
//  ╢"▄▄#▀▀╙╟█Ü███▀`▀█  ║██J█▄▌jH █    ██    ╙▀W▄;    ,██  `╙w,   █▄     ,╓ █
//   █╙     ▐███▌▀█w ▀█ ╠██████j▌║█▌   ▀██▄       `╙▓██▀w,     ╙╗█'`"▀█▀╙"`║`
//   ╙▌     Φ████████▄██ ███████████    ═██▀W▄,   ╓█▀└         ╓▀ "    ╙▄ ╓▀
//    ╙▄     ╙▀███╙█▄▐██▄,╙▀█████▄▀▄▀▄   ,█M╗ ▀▄██▀╙""*ⁿ═─≈-,,▄▌,        ▄▀
//     `▌╙µ,▄Φ▀x███▄██████████▀V███▀╙└ ,▄#▌████▀`"*«,      .█▀▄▀▄,      ▄╛
//       ▀Ö█  ;▓████████▄▄█▀▄╙W "V▄██▀▀│▄███▀└ ▀╦     "*═╥▄▀ ║,  ║▀▄  ,▓
//        ╙W▀ '█████╨▀▀█████████   "▀▀████└      ╙▄   ,▄▀'   `▀▀╣H ▐▀▄▀
//          ╙▄  ▀▀Γ╓▌  ▄▀ⁿ`╙▀███      ██▌         ╓█R▀▄A█        ▀▀▄▀
//            ╙W,Φ╙  ║█        ▄╙╙ª%≡╦██≤≤╗╗≡≡╜▀▀   ╣▌   █╕     ,▄▀
//              `▀▄M█┘        ║▀▌   ╫"    *Φ▄  █       Φ` ▀▌, ▄M╙
//                 "▀╦,       M ╙▌  ▀       `█W▐▌       wæQ▄▀╙
//                     ╙▀W╥,╓╣   ╙█║        ╫M  █    ,╓▄╝╙`
//                          ╙╙▀%▄▄▄▌,≤▄_▄≡,▐▓▓▄▄#ª▀"`


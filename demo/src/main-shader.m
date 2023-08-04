#import "import.h"

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
   GLuint      VBO;
   GLuint      VAO;
   CGShaderID  shaderProgram;
}
@end


@implementation DemoLayer

- (void) initShaderProgramWithContext:(CGContext *) context
{
   shaderProgram = [context compileShaderWithShaderSources:&monochromeShaderSources];
   CGContextCheckBackendError( context, "after compileShaderWithShaderSources");
   assert( shaderProgram);
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

   glGenVertexArrays( 1, &VAO);
   CGContextCheckBackendError( context, "after glGenVertexArrays");
    // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
   glBindVertexArray( VAO);
   CGContextCheckBackendError( context, "after glBindVertexArray");

   glGenBuffers( 1, &VBO);
   CGContextCheckBackendError( context, "after glGenBuffers");
   glBindBuffer( GL_ARRAY_BUFFER, VBO);
   CGContextCheckBackendError( context, "after glBindBuffer");
   glBufferData( GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
   CGContextCheckBackendError( context, "after glBufferData");

   glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
   CGContextCheckBackendError( context, "after glVertexAttribPointer");
   glEnableVertexAttribArray(0);
   CGContextCheckBackendError( context, "after glEnableVertexAttribArray");

    // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
    // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
    // glBindVertexArray(0);
}


static MulleUIResourceStorageDefineKey( test_image);

- (CGImage *) testImageWithContext:(CGContext *) context
{
   CGImage   *image;

   image = [context resourceForKey:MulleUIResourceStorageKey( test_image)];
   if( ! image)
   {
      image = [[[CGImage alloc] initWithRGBABytes:bitmap2
                                       bitmapSize:MulleIntegerSizeMake( 32, 32)
                                     textureFlags:0  // NVG_IMAGE_REPEATX
                                          context:context] autorelease];
      // though the image will be already known as a resource by the context
      // we want to conveniently recover it "by name" also, and keep it
      // retained there
      [context setResource:image
                    forKey:MulleUIResourceStorageKey( test_image)];
   }
   return( image);
}


- (void) drawOpenGLWithContext:(CGContext *) context
{
   float     timeValue;
   float     greenValue;
   GLint     texLoc;
   GLfloat   rgba[ 4];
   CGImage   *image;

   if( ! VAO)
      [self initVertexBufferWithContext:context];
   if( ! shaderProgram)
      [self initShaderProgramWithContext:context];

   glBindVertexArray(VAO);
   CGContextCheckBackendError( context, "after glBindVertexArray");
   [context useShader:shaderProgram];

#ifdef DRAW_TEXTURE
   image = [self testImageWithContext:context];
   assert( image);
   [context bindImage:image
        toTextureUnit:0];

//  update shader uniform
//   timeValue  = glfwGetTime();
//   greenValue = sin(timeValue) / 2.0f + 0.5f;

//   vertexColorLocation = glGetUniformLocation(shaderProgram, "ourColor");
//
//   rgba[ 0] = 0.0;
//   rgba[ 1] = greenValue;
//   rgba[ 2] = 0.0;
//   rgba[ 3] = 1.0;
//
//   // MEMO: glUniform4f does not work !!!
   texLoc = glGetUniformLocation( (GLuint) shaderProgram, "u_tex0");
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
   glDeleteVertexArrays( 1, &VAO);
   glDeleteBuffers( 1, &VBO);
   // [self deleteShader:shaderProgram];

   [super finalize];
}

@end


int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
   CALayer         *layer;

   app = [UIApplication sharedInstance];
   {
      [CGContext setDebugEnabled:YES];
      layer  = [DemoLayer layerWithFrame:CGRectMake( 10, 10, 620, 380)];
      window = [UIWindow windowWithLayer:layer
                         titleUTF8String:NULL];
      [window setFrameRateHz:30.0];
      [app addWindow:window];
   }
   return( [app run]);
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


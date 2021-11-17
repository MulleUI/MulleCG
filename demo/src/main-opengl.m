#import <MulleUICore/MulleUICore.h>

#import <string.h>


//
// what does this demo ? It shows the UIWindow render callbacks, and how
// you can place OpenGL behind or in front of the scene. Consequently this
// demo rather belongs in MulleUICore
//
void  drawOpenGL1( UIWindow *window, CGContext *context, struct CGFrameInfo *info)
{
   glColor3f( 0.0f, 0.0f, 1.0f ); // blue color

   glBegin( GL_LINE_LOOP );
      glVertex3f( -0.5f, 0.0f, 0.0f );
      glVertex3f( 0.0f, -0.5f, 0.0f );
      glVertex3f( 0.5f, 0.0f, 0.0f );
      glVertex3f( 0.0f, 0.5f, 0.0f );
   glEnd();

   glFlush();   
}


void  drawOpenGL2( UIWindow *window, CGContext *context, struct CGFrameInfo *info)
{
   glColor3f( 1.0f, 1.0f, 0.0f ); // yellow color

   glBegin( GL_LINE_LOOP );
      glVertex3f( -0.45f, 0.0f, 0.0f );
      glVertex3f( 0.0f, -0.45f, 0.0f );
      glVertex3f( 0.45f, 0.0f, 0.0f );
      glVertex3f( 0.0f, 0.45f, 0.0f );
   glEnd();

   glFlush();   
}

void  drawOpenGL3( UIWindow *window, CGContext *context, struct CGFrameInfo *info)
{
   glColor3f( 1.0f, 0.0f, 1.0f ); // magenta color

   glBegin( GL_LINE_LOOP );
      glVertex3f( -0.40f, 0.0f, 0.0f );
      glVertex3f( 0.0f, -0.40f, 0.0f );
      glVertex3f( 0.40f, 0.0f, 0.0f );
      glVertex3f( 0.0f, 0.40f, 0.0f );
   glEnd();

   glFlush();   
}


void   setupScene( UIWindow *window)
{
   UIView   *view;
   UIView   *contentPlane;
   CGRect   rect;
   CGRect   frame;

   contentPlane     = [window contentPlane];
   rect             = [contentPlane contentRect];
   rect             = CGRectInset( rect, 40, 40);

   frame            = rect;
   frame.size.width = rect.size.width / 2.0 - 40.0;

   view = [UIView viewWithFrame:frame];
   [view setBackgroundColor:[UIColor redColor]];
   [contentPlane addSubview:view];

   frame.origin.x = CGRectGetMaxX( rect) - frame.size.width;  
   view = [UIView viewWithFrame:frame];
   [view setBackgroundColor:[UIColor greenColor]];
   [contentPlane addSubview:view];
}


int   main( int argc, char *argv[])
{
   UIWindow       *window;
   UIApplication  *app;
   /*
    * window and app
    */
   app    = [UIApplication sharedInstance];
   window = [UIWindow windowWithFrame:CGRectMake( 0.0f, 0.0f, 640.0f, 400.0f)];
   [window setBackgroundColor:CGColorMakeRGBA( 0.0, 0.0, 0.0, 1.0)];
   [app addWindow:window];

   setupScene( window);
   [window setWillRenderCallback:drawOpenGL1];
   [window setWillEndRenderCallback:drawOpenGL2];  
   [window setDidRenderCallback:drawOpenGL3];  
   [window renderLoop];

   [app terminate];
   return( 0);
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


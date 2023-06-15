#version 300 es
// shader-version: 1.0.4

precision mediump float;


uniform sampler2D u_tex0;
in vec2  fragTexCoord;
out vec4 finalColor;


void main()
{
   vec4 color       = texture( u_tex0, fragTexCoord);
   float luminosity = dot( color.rgb, vec3(0.2126, 0.7152, 0.0722));
   finalColor       = vec4( vec3( luminosity), 1.0);
}

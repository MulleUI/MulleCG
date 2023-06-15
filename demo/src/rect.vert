#version 300 es
// shader-version: 1.0.5

precision mediump float;

in vec3 vert;
out vec2 fragTexCoord;

void main()
{
    // Map the vertex position from NDC (-1 to 1) to texture coordinates (0 to 1)
    fragTexCoord = (vert.xy * 0.5) + 0.5;
    gl_Position = vec4(vert, 1);
}

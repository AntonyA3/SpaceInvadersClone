#version 320 es

layout (location = 0) in vec3 vposition;
layout (location = 1) in vec4 vcolor;
layout (location = 2) in vec2 vtexCoord;

uniform mat4 uProjectionViewMatrix;

out vec4 fcolor;
out vec2 ftexCoord;

void main()
{
    fcolor = vcolor;
    ftexCoord = vtexCoord;
    gl_Position = uProjectionViewMatrix * vec4(vposition, 1.0);
} 

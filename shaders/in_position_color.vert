
#version 320 es

layout (location = 0) in vec3 vposition;
layout (location = 1) in vec4 vcolor;

uniform mat4 uProjectionViewMatrix;

out vec4 fcolor;

void main()
{
    fcolor = vcolor;
    gl_Position = uProjectionViewMatrix * vec4(vposition, 1.0);
} 

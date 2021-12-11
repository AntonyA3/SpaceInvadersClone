#version 320 es

layout (location = 0) in vec3 vposition;
layout (location = 1) in vec3 iposition;
layout (location = 2) in vec4 icolor;

uniform mat4 uProjectionViewMatrix;
uniform float uTime;
out vec4 fcolor;

void main()
{
    fcolor = icolor;
    vec3 position = vposition + iposition;
    position.z += 50.0 * -uTime;
    position.z = -mod(position.z, 50.0);

    gl_Position = uProjectionViewMatrix * vec4(position, 1.0);
} 

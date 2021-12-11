#version 320 es
precision mediump float;

in vec4 fcolor;
in vec2 ftexCoord;

uniform sampler2D uTexture;

out vec4 color;

void main(){
    color = fcolor * texture(uTexture, ftexCoord);
}
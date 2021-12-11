#include "GlShaderFunctions.hpp"


GLuint GlShaderFunctions::makeShader(GLuint type, const char* src){
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &src, NULL);
    glCompileShader(shader);
    return shader;
}




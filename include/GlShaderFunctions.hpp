#include "GL/glew.h"

namespace GlShaderFunctions{
    GLuint makeShader(GLuint type, const char* src);
    bool createShaderFromFiles(const char *vertexShaderPath, const char *fragmentShaderPath, GLuint *program);

}
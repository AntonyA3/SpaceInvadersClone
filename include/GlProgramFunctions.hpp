#include <string>
#include <iostream>
#include "GL/glew.h"
namespace GlProgramFunctions{
    void debugProgram(GLuint program, std::string successMsg, std::string failMsg);
    GLuint makeProgram(GLuint vertexShader, GLuint fragmentShader);
}
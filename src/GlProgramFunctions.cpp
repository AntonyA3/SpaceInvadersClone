#include "GlProgramFunctions.hpp"

void GlProgramFunctions::debugProgram(GLuint program, std::string successMsg, std::string failMsg){
    int status;
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if(status == GL_TRUE){
        std::cout << successMsg << std::endl;
    }else{
        std::cout << failMsg << std::endl;
    }
}

GLuint GlProgramFunctions::makeProgram(GLuint vertexShader, GLuint fragmentShader){
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    glLinkProgram(program);
    return program;
}
#ifndef STARFIELDEFFECT_HPP
#define STARFIELDEFFECT_HPP
#include <vector>
#include "glm/vec2.hpp"
#include "glm/mat4x4.hpp"
#include "glm/gtx/transform.hpp"
#include <random>
#include "GL/glew.h"
#include <iostream>


struct StarFieldEffect{
    bool active;
    int particleCount;
    float time;
    glm::mat4x4 projectionViewMatrix;
    std::vector<float> positionsColor = std::vector<float>();
    
    GLuint starVertexBuffer;
    GLuint starIndexBuffer;
    GLuint vertexArray;
    GLuint instanceVertexBuffer;
    GLuint projectionViewMatrixLoc;

    GLuint program;
    StarFieldEffect();
    void init();
};
#endif
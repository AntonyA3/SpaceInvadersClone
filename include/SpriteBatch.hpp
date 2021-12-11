#ifndef SPRITEBATCH_HPP
#define SPRITEBATCH_HPP
#include <vector>
#include <GL/glew.h>
#include "Texture.hpp"
struct SpriteBatch
{    
    SpriteBatch();

    std::vector<float> verticies = std::vector<float>();
    std::vector<unsigned int> indicies = std::vector<unsigned int>();
    int indexOffset = 0;

    GLuint vertexBuffer;
    GLuint indexBuffer;
    Texture texture;
    GLuint program;
    GLuint projectionViewMatrixLoc;
    GLuint uniformTextureLoc;

};

#endif
#ifndef DEFENDERS_HPP
#define DEFENDERS_HPP
#include "glm/vec2.hpp"
struct Defenders
{   
    static int const WIDTH = 24;
    static int const HEIGHT = 16;
    unsigned int bitmap[24 * 16];
    void init();
};
#endif
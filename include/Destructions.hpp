#ifndef DESTRUCTIONS_HPP
#define DESTRUCTIONS_HPP
#include "glm/vec2.hpp"
struct Destructions
{
    static int const COUNT = 11;
    int activeCount = 0;
    float timeRemaining[COUNT];
    glm::vec2 positions[COUNT];
};
#endif
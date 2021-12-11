#include "StarFieldEffect.hpp"


StarFieldEffect::StarFieldEffect(){ }

void StarFieldEffect::init(){
    this->time = 0;
    this->active = true;
    float verticies[72] = {
    //left
    -1.0f, -1.0f, 1.0f,
    -1.0f, 1.0f, 1.0f,
    -1.0f, 1.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,
    //top
    -1.0f, 1.0f, -1.0f,
    -1.0f, 1.0f, 1.0f,
    1.0f, 1.0f, 1.0f,
    1.0f, 1.0f, -1.0f,
    //front    
    -1.0f, -1.0f, -1.0f,
    -1.0f, 1.0f, -1.0f,
    1.0f, 1.0f, -1.0f,
    1.0f, -1.0f, -1.0f,
    //bottom
    -1.0f, -1.0f, 1.0f,
    -1.0f, -1.0f, -1.0f,
    1.0f, -1.0f, -1.0f,
    1.0f, -1.0f, 1.0f,
    //right
    1.0f, -1.0f, -1.0f,
    1.0f, 1.0f, -1.0f,
    1.0f, 1.0f, 1.0f,
    1.0f, -1.0f, 1.0f,
    //back
    1.0f, -1.0f, 1.0f,
    1.0f, 1.0f, 1.0f,
    -1.0f, 1.0f, 1.0f,
    -1.0f, -1.0f, 1.0f
};

unsigned int indicies[36] = {
    0, 1, 2,        0, 2, 3,
    4, 5, 6,        4, 6, 7,
    8, 9, 10,       8, 10, 11,
    12, 13, 14,     12, 14, 15,
    16, 17, 18,     16, 18, 19,
    20, 21, 22,     20, 22, 23
};
    projectionViewMatrix = glm::perspective(90, 1, 1, 100);
    particleCount = 50;
    for(int i = 0; i < this->particleCount ; i++){
        positionsColor.push_back(rand() % 500 -250);
        positionsColor.push_back(rand() % 500 -250);
        positionsColor.push_back((rand() % 100) *-1);

        positionsColor.push_back(1.f);
        positionsColor.push_back(1.0f);
        positionsColor.push_back(1.0f);
        positionsColor.push_back(1.0f);
    }
    
    std::cout << "part 1 starfield created" << std::endl;
    //generate the star model
    

    glGenVertexArrays(1, &this->vertexArray);
    glGenBuffers(1, &starVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, starVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 72, verticies, GL_STATIC_DRAW);
    std::cout << "star vertex buffer created" << std::endl;

    std::cout << "star vertex created" << std::endl;

    glGenBuffers(1, &starIndexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, starIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(unsigned int) * 36, indicies, GL_STATIC_DRAW);
    std::cout << "star index created" << std::endl;

    std::cout << "p star model created" << std::endl;

    //generate the instance mocel
    glGenBuffers(1, &instanceVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, instanceVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, 100 * 3 * sizeof(float), &positionsColor.at(0), GL_STATIC_DRAW);

    std::cout << "part 2 star field created" << std::endl;
    
}
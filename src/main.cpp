#include <iostream>
extern "C"
{
    #include <lualib.h>
    #include <lauxlib.h>
    #include <lua.h>   
    #include "luaconf.h" 
}
#include <stdlib.h>
#include <math.h>
#include "glm/vec2.hpp"
#include "glm/vec3.hpp"
#include "glm/mat4x4.hpp"
#include "glm/gtx/transform.hpp"
#include "Rect.hpp"
#include "InputKey.hpp"
#include "MouseButton.hpp"
#include "SpriteBatch.hpp"
#include "Viewport.hpp"
#include "Texture.hpp"
#include "Defenders.hpp"
#include "Destructions.hpp"
#include "StarFieldEffect.hpp"
#include "GlProgramFunctions.hpp"
#include "GlShaderFunctions.hpp"

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <GL/glew.h>
#include <random>
#include <fstream>
#include <sstream>
#include <string>


#define DEFAULT_WINDOW_WIDTH 224 * 2
#define DEFAULT_WINDOW_HEIGHT 224 * 2
#define APPLICATION_TITLE "Space Invaders Clone"

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

//Gloabals
SpriteBatch spriteBatch = SpriteBatch();
StarFieldEffect starFieldEffect = StarFieldEffect();

GLFWwindow *window;
Defenders defenders[4];
InputKey leftKey = InputKey(GLFW_KEY_A);
InputKey rightKey = InputKey(GLFW_KEY_D);
InputKey upKey = InputKey(GLFW_KEY_W);
InputKey downKey = InputKey(GLFW_KEY_S);
InputKey spaceKey = InputKey(GLFW_KEY_SPACE);
InputKey escKey = InputKey(GLFW_KEY_ESCAPE);
MouseButton leftButton = MouseButton(GLFW_MOUSE_BUTTON_1);

namespace GameTime
{
    float time = 0;
    float deltaTime = 1/60.0f;
}

struct {
    GLuint texture;
    int width;
    int height;
}atlas;

struct{
    unsigned int bitmap[8 * 8];
    int width;
    int height;
}destructionBitmap;


void rectToVertexPosition(Rect rect, glm::vec2 *verticies){
    verticies[0] = glm::vec2(rect.x, rect.y + rect.h);
    verticies[1] = glm::vec2(rect.x, rect.y);
    verticies[2] = glm::vec2(rect.x + rect.w, rect.y);
    verticies[3] = glm::vec2(rect.x +rect.w, rect.y + rect.h);
}


void updateInput(GLFWwindow *window, InputKey *keyInput){
    switch (keyInput->state)
    {
    case INPUT_KEY_STATE_PRESSED:
        if(glfwGetKey(window, keyInput->key) == GLFW_PRESS){
            keyInput->state = INPUT_KEY_STATE_DOWN;
        }else if(glfwGetKey(window, keyInput->key) == GLFW_RELEASE){
            keyInput->state = INPUT_KEY_STATE_RELEASED;
        }
        break;
    case INPUT_KEY_STATE_DOWN:
        if(glfwGetKey(window, keyInput->key) == GLFW_PRESS){
            keyInput->state = INPUT_KEY_STATE_DOWN;

        }else if(glfwGetKey(window, keyInput->key) == GLFW_RELEASE){
            keyInput->state = INPUT_KEY_STATE_RELEASED;
        }
        break;
    case INPUT_KEY_STATE_RELEASED:
        if(glfwGetKey(window, keyInput->key) == GLFW_PRESS){
            keyInput->state = INPUT_KEY_STATE_PRESSED;
        }else if(glfwGetKey(window, keyInput->key) == GLFW_RELEASE){
            keyInput->state = INPUT_KEY_STATE_UP;
        }
        break;
    case INPUT_KEY_STATE_UP:
        if(glfwGetKey(window, keyInput->key) == GLFW_PRESS){
            keyInput->state = INPUT_KEY_STATE_PRESSED;
        }else if(glfwGetKey(window, keyInput->key) == GLFW_RELEASE){
            keyInput->state = INPUT_KEY_STATE_UP;
        }
        break;
    
    default:
        break;
    }      
}

void updateInput(GLFWwindow *window, MouseButton *mouseButton){
    switch (mouseButton->state)
    {
    case MOUSE_BUTTON_STATE_PRESSED:
        if(glfwGetMouseButton(window, mouseButton->button) == GLFW_PRESS){
            mouseButton->state = INPUT_KEY_STATE_DOWN;
        }else if(glfwGetMouseButton(window, mouseButton->button) == GLFW_RELEASE){
            mouseButton->state = INPUT_KEY_STATE_RELEASED;
        }
        break;
    case MOUSE_BUTTON_STATE_DOWN:
        if(glfwGetMouseButton(window, mouseButton->button) == GLFW_PRESS){
            mouseButton->state = INPUT_KEY_STATE_DOWN;

        }else if(glfwGetMouseButton(window, mouseButton->button) == GLFW_RELEASE){
            mouseButton->state = INPUT_KEY_STATE_RELEASED;
        }
        break;
    case MOUSE_BUTTON_STATE_RELEASED:
        if(glfwGetMouseButton(window, mouseButton->button) == GLFW_PRESS){
            mouseButton->state = INPUT_KEY_STATE_PRESSED;
        }else if(glfwGetMouseButton(window, mouseButton->button) == GLFW_RELEASE){
            mouseButton->state = INPUT_KEY_STATE_UP;
        }
        break;
    case MOUSE_BUTTON_STATE_UP:
        if(glfwGetMouseButton(window, mouseButton->button) == GLFW_PRESS){
            mouseButton->state = INPUT_KEY_STATE_PRESSED;
        }else if(glfwGetMouseButton(window, mouseButton->button) == GLFW_RELEASE){
            mouseButton->state = INPUT_KEY_STATE_UP;
        }
        break;
    default:
        break;
    }      
}

void pollInput(MouseButton *mouseButton){
    if(mouseButton->state == MOUSE_BUTTON_STATE_PRESSED){
        mouseButton->state = MOUSE_BUTTON_STATE_DOWN;
    }
    if(mouseButton->state == MOUSE_BUTTON_STATE_RELEASED){
        mouseButton->state = MOUSE_BUTTON_STATE_UP;
    }
}

void pollInput(InputKey *keyInput){
    if(keyInput->state == INPUT_KEY_STATE_PRESSED){
        keyInput->state = INPUT_KEY_STATE_DOWN;
    }
    if(keyInput->state == INPUT_KEY_STATE_RELEASED){
        keyInput->state = INPUT_KEY_STATE_UP;
    }
}

void srcRectToTextureCoordinates(glm::vec2 *texCoords, Rect srcRect, float width, float height){           
    //Rect Point to Texture Coordinates
    float widthDiv = 1 / width;
    float heightDiv = 1 / height;
    
    float left = srcRect.x * widthDiv;
    float right = (srcRect.x + srcRect.w) * widthDiv;

    float top = srcRect.y * heightDiv;
    float bottom = (srcRect.y + srcRect.h) * heightDiv;

    texCoords[0] = glm::vec2(left, bottom);
    texCoords[1] = glm::vec2(left, top);
    texCoords[2] = glm::vec2(right, top);
    texCoords[3] = glm::vec2(right, bottom);
}

void appendRectIndicies(std::vector<unsigned int> *indexArray, int *indexOffset){
    int offset = *indexOffset;
    indexArray->push_back(offset);
    indexArray->push_back(offset + 1);
    indexArray->push_back(offset + 2);
    indexArray->push_back(offset);
    indexArray->push_back(offset + 2);
    indexArray->push_back(offset + 3);
    *indexOffset += 4;
}

void appendRectIndicies(std::vector<unsigned int> *indexArray){
    int offset = 0;
    appendRectIndicies(indexArray, &offset);
}

void appendColor(std::vector<float> *vertexArray, glm::vec4 color){
    vertexArray->push_back(color.r);
    vertexArray->push_back(color.g);
    vertexArray->push_back(color.b);
    vertexArray->push_back(color.a);
}

void appendSpriteVerticies(std::vector<float> *vertexArray, glm::vec2 *positionArray,  glm::vec4 color, glm::vec2 *textureCoordinates){
    for(int i = 0; i < 4; i++){
        vertexArray->push_back(positionArray[i].x);
        vertexArray->push_back(positionArray[i].y);
        vertexArray->push_back(0.0f);
        
        //Add color to each vertex
        appendColor(vertexArray, color);
        
        //add texture coordinate to each verticies
        vertexArray->push_back(textureCoordinates[i].x);
        vertexArray->push_back(textureCoordinates[i].y);
    }
}

void bitmapSubtract(
    unsigned int *bitmap, glm::vec2 bitmapPos, int bitmapWidth, int bitmapHeight,
    Rect subRect
){
    int minX = subRect.x - bitmapPos.x;
    int maxX = (subRect.x + subRect.w) - bitmapPos.x;
    int minY = subRect.y - bitmapPos.y;
    int maxY = (subRect.y + subRect.h) - bitmapPos.y; 

    for(int y = fminf(bitmapHeight - 1, maxY); y >= fmaxf(0, minY); y--){
        for(int x = fmaxf(0, minX); x <= fminf(bitmapWidth - 1, maxX); x++){
            int index = y * 24 + x;
            bitmap[index] = 0;
        }
    }
}

void addSprite(SpriteBatch *spriteBatch, Rect drawArea, Rect srcArea, glm::vec4 color){
    glm::vec2 verticies[4];
    //Rect from in game player rect
    rectToVertexPosition(drawArea , verticies);            
    //Inputs: srcRect, width, height
    //Output textureCoordinate
    glm::vec2 textureCoordinates[4];
    srcRectToTextureCoordinates(textureCoordinates,
        srcArea,
        (float)spriteBatch->texture.width,
        (float)spriteBatch->texture.height
    );

    //Add verticies to flat batch
    appendSpriteVerticies(&spriteBatch->verticies, verticies, color, textureCoordinates);    
    appendRectIndicies(&spriteBatch->indicies, &spriteBatch->indexOffset);
}

void bitmapSubtract(
    unsigned int *bitmap, glm::vec2 bitmapPos, int bitmapWidth, int bitmapHeight,
    unsigned int *submap, glm::vec2 subPos, int subWidth, int subHeight
){
    for(int y = 0; y < subHeight; y++){
        for(int x = 0; x < subWidth; x++){
            int bitX = (subPos.x + x) - bitmapPos.x;
            int bitY = (subPos.y + y) - bitmapPos.y;

            if(bitX >= 0 && bitX < bitmapWidth && bitY >= 0 && bitY < bitmapHeight){
                if(submap[y * subWidth + x] > 0){
                    bitmap[bitY * bitmapWidth + bitX] = 0;
                }
            }
        }
    }
}



std::string stringFromFile(const char* path){
    std::string line;
    std::string cppPath = std::string(path);
    std::ifstream textFile(cppPath);

    if(textFile.is_open()){
        std::stringstream ss;
        while (std::getline(textFile, line)){
            ss << line << '\n';
        }    
        textFile.close();   
        return ss.str();        
    }   
}

static int cpp_get_left_key_state(lua_State* luaState){
    lua_pushinteger(luaState, leftKey.state);
    return 1;
}


static int cpp_get_right_key_state(lua_State* luaState){
    lua_pushinteger(luaState, rightKey.state);
    return 1;
}

static int cpp_get_up_key_state(lua_State* luaState){
     lua_pushinteger(luaState, upKey.state);
    return 1;
}

static int cpp_get_down_key_state(lua_State* luaState){
    lua_pushinteger(luaState, downKey.state);
    return 1;
}

static int cpp_get_space_key_state(lua_State* luaState){
    lua_pushinteger(luaState, spaceKey.state);
    return 1;
}
static int cpp_get_left_mouse_state(lua_State* luaState){
    lua_pushinteger(luaState, leftButton.state);
    return 1;
}
static int cpp_get_esc_key_state(lua_State* luaState){
    lua_pushinteger(luaState, escKey.state);
    return 1;
}

static int cpp_get_delta_time(lua_State* luaState){
    lua_pushnumber(luaState, GameTime::deltaTime);
    return 1;

}

static int cpp_addSprite(lua_State* luaState){
    Rect drawArea;
    Rect srcArea;
    glm::vec4 color;

    //Index 1: table stack id;
    //Index 2: item id;
    lua_geti(luaState, 1, 1);
    float x = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    lua_geti(luaState, 1, 2);
    float y = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    lua_geti(luaState, 1, 3);
    float w = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    lua_geti(luaState, 1, 4);
    float h = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    drawArea = Rect(x, y, w, h);

    lua_geti(luaState, 2, 1);
    x = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    lua_geti(luaState, 2, 2);
    y = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    lua_geti(luaState, 2, 3);
    w = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    lua_geti(luaState, 2, 4);
    h = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    srcArea = Rect(x, y, w, h);


    lua_geti(luaState, 3, 1);
    float r = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    lua_geti(luaState, 3, 2);
    float g = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    lua_geti(luaState, 3, 3);
    float b = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    lua_geti(luaState, 3, 4);
    float a = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);
    color = glm::vec4(r, g, b, a);

    addSprite(&spriteBatch, drawArea, srcArea, color);
}

static int cpp_get_cursor_clicked(lua_State* luaState){
    lua_pushboolean(luaState, glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_1) == GLFW_PRESS);
    return 1;
}

static int cpp_get_cursor_position(lua_State* luaState){
    double x;
    double y;
    glfwGetCursorPos(window, &x, &y);
    lua_pushnumber(luaState, (float)x * 0.5);
    lua_pushnumber(luaState, (float)y * 0.5);
    return 2;
}

bool rectVsBitmap(Rect rect, glm::vec2 bitmapPos, unsigned int *bitmap, int width, int height, int *hitY){
    int minX = rect.x - bitmapPos.x;
    int maxX = (rect.x + rect.w)- bitmapPos.x;
    int minY = rect.y - bitmapPos.y;
    int maxY = (rect.y + rect.h) - bitmapPos.y;
    bool hit = false;

    int startY;
    int endY;
    int stepY;
    for(int y = fminf(height - 1, maxY); y >= fmaxf(0, minY); y--){
        for(int x = fmaxf(0, minX); x <= fminf(width - 1, maxX); x++){
            int index = y * width + x;
            if(bitmap[index] >0 ){
                if(!hit){

                    *hitY = bitmapPos.y + y;
                }
                return true;
            }
            
        }
    }
    return false;
}

bool rectVsBitmapDown(Rect rect, glm::vec2 bitmapPos, unsigned int *bitmap, int width, int height, int *hitY){
    int minX = rect.x - bitmapPos.x;
    int maxX = (rect.x + rect.w)- bitmapPos.x;
    int minY = rect.y - bitmapPos.y;
    int maxY = (rect.y + rect.h) - bitmapPos.y;
    bool hit = false;

  
    for(int y = fmaxf(0, minY); y <= fminf(height - 1, maxY); y++){
        for(int x = fmaxf(0, minX); x <= fminf(width - 1, maxX); x++){
            int index = y * 24 + x;
            if(bitmap[index] != 0){
                if(!hit){
                    *hitY = bitmapPos.y + y;
                }
                return true;
            }
        }
    }
    return false;
}


static int cpp_bullet_vs_defender(lua_State* luaState){
    int defenderId = lua_tointeger(luaState, 1);
    //rect
    lua_geti(luaState, 2, 1);
    float x = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    lua_geti(luaState, 2, 2);
    float y = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    lua_geti(luaState, 2, 3);
    float w = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    lua_geti(luaState, 2, 4);
    float h = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    //position
    float posx = lua_tonumber(luaState, 3);
    float posy = lua_tonumber(luaState, 4);

    Rect bulletRect = Rect(x, y, w, h);
    int hitY;

    bool down = lua_toboolean(luaState, 5);
   
    bool hit;
    if (down){
        hit = rectVsBitmapDown(
            bulletRect,
            glm::vec2(posx, posy), 
            defenders[defenderId].bitmap, defenders->WIDTH, defenders->HEIGHT, &hitY
        );
    }

    
    lua_pushboolean(luaState, hit);
    lua_pushinteger(luaState, hitY);
    return 2;
}





static int cpp_edit_defender_texture(lua_State* luaState){

    glBindTexture(GL_TEXTURE_2D, atlas.texture);
    for(int i = 0; i < 4; i++){
        Rect srcRect = Rect(0, 16, 24, 16);
        glTexSubImage2D(
            GL_TEXTURE_2D, 0,
            srcRect.x + 24 * i, srcRect.y, srcRect.w, srcRect.h,
            GL_RGBA, GL_UNSIGNED_BYTE, defenders[i].bitmap
        );
    }
    return 0; 
}

static int cpp_init_defenders(lua_State* luaState){
    //copies 4 bitmap areas into the texture
    int width;
    int height;
    int comp;
    
    unsigned char *defenderBitmap = stbi_load("./textures/defender.png", &width, &height, &comp, STBI_rgb_alpha);
    Rect srcRect = Rect(0, 16, width, height);
    //print defender bitma
   
    glBindTexture(GL_TEXTURE_2D, atlas.texture);
    for(int i = 0; i < 4; i++){
        for(int j = 0; j <height; j++){
            for(int k = 0; k<width; k++){
                int index = k + width * j;
                if(defenderBitmap[index * 4] > 0){
                    defenders[i].bitmap[index] = 256*256*256*256- 1;
                }else{
                    defenders[i].bitmap[index] = 0;
                }
            }
        }
        glTexSubImage2D(
            GL_TEXTURE_2D, 0,
            srcRect.x + 24 * i, srcRect.y, srcRect.w, srcRect.h,
            GL_RGBA, GL_UNSIGNED_BYTE, defenderBitmap
        );
    }
    stbi_image_free(defenderBitmap);

    return 0;   
}

static int cpp_not_starfield_active(lua_State* luaState){
    starFieldEffect.active = !starFieldEffect.active;
    return 0;
}

static int cpp_destroy_defender_rect(lua_State* luaState){
    int defenderId = lua_tointeger(luaState, 1);
    float posx = lua_tonumber(luaState, 2);
    float posy = lua_tonumber(luaState, 3);

    //rect
    lua_geti(luaState, 4, 1);
    float rx = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    lua_geti(luaState, 4, 2);
    float ry = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    lua_geti(luaState, 4, 3);
    float w = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);

    lua_geti(luaState, 4, 4);
    float h = lua_tonumber(luaState, -1);
    lua_pop(luaState, 1);
    

    Rect rect = Rect(rx, ry, w, h);


    bitmapSubtract(defenders[defenderId].bitmap, glm::vec2(posx, posy), defenders->WIDTH, defenders->HEIGHT,
        rect
    );
}

static int cpp_destroy_defender(lua_State* luaState){
    int defenderId = lua_tointeger(luaState, 1);
    float x = lua_tonumber(luaState, 2);
    float y = lua_tonumber(luaState, 3);
    float posx = lua_tonumber(luaState, 4);
    float posy = lua_tonumber(luaState, 5);
    bitmapSubtract(defenders[defenderId].bitmap, glm::vec2(posx, posy), defenders->WIDTH, defenders->HEIGHT,
       destructionBitmap.bitmap, glm::vec2(x,y),destructionBitmap.width, destructionBitmap.height
    );
    return 0;
}




void debugShader(GLuint shader,std::string successMsg, std::string failMsg){
    int status;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if(status == GL_TRUE){
        std::cout << successMsg << std::endl;
    }else if (status == GL_FALSE){
        char buffer[1000];
        int length;
        glGetShaderInfoLog(shader, 1000, &length, buffer);  
        std::cout << failMsg << std::endl;
    }
}




void deleteShaders(GLuint vertexShader, GLuint fragmentShader){
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
}




void rectTexCoords(glm::vec2 *texCoord){
    texCoord[0] = glm::vec2 (0.0, 1.0);
    texCoord[1] = glm::vec2 (0.0, 0.0);
    texCoord[2] = glm::vec2 (1.0, 0.0);
    texCoord[3] = glm::vec2 (1.0, 1.0);
}
    

bool createShaderFromFiles(const char *vertexShaderPath, const char *fragmentShaderPath, GLuint *program){
    //Create Shader Program
    GLuint vertexShader;
    GLuint fragmentShader;
    //GLuint program;

    std::string vertexString = stringFromFile(vertexShaderPath);
    const char* vertexText = vertexString.c_str();
    
    vertexShader = GlShaderFunctions::makeShader(GL_VERTEX_SHADER, vertexText);    
    debugShader(vertexShader, "Vertex Shader Successful","Vertex Shader Failed");


    std::string fragmentString = stringFromFile(fragmentShaderPath);
    const char* fragmentText = fragmentString.c_str();

    fragmentShader = GlShaderFunctions::makeShader(GL_FRAGMENT_SHADER, fragmentText);
    debugShader(fragmentShader, "Fragment Shader Successful", "Fragment Shader Failed");

    *program = GlProgramFunctions::makeProgram(vertexShader, fragmentShader);
    GlProgramFunctions::debugProgram(*program, "Flat Program Created", "Flat Program Failed");

    deleteShaders(vertexShader, fragmentShader);
    return true;
    
}

void luaDoFiles(lua_State *luaVM){
    luaL_dofile(luaVM, "./lua/aliens.lua");
    luaL_dofile(luaVM, "./lua/game_state.lua");
    luaL_dofile(luaVM, "./lua/key_state.lua");
    luaL_dofile(luaVM, "./lua/main.lua");
    luaL_dofile(luaVM, "./lua/player.lua");
    luaL_dofile(luaVM, "./lua/space_invaders.lua");
}


void luaRegisterFunctions(lua_State *luaVM){
    lua_register(luaVM, "cpp_addSprite", cpp_addSprite);
    lua_register(luaVM, "cpp_not_starfield_active", cpp_not_starfield_active);
    lua_register(luaVM, "cpp_get_left_mouse_state", cpp_get_left_mouse_state);
    lua_register(luaVM, "cpp_get_left_key_state", cpp_get_left_key_state);
    lua_register(luaVM, "cpp_get_right_key_state", cpp_get_right_key_state);
    lua_register(luaVM, "cpp_get_up_key_state", cpp_get_up_key_state);
    lua_register(luaVM, "cpp_get_down_key_state", cpp_get_down_key_state);
    lua_register(luaVM, "cpp_get_space_key_state", cpp_get_space_key_state);
    lua_register(luaVM, "cpp_get_esc_key_state", cpp_get_esc_key_state);
    lua_register(luaVM, "cpp_get_delta_time", cpp_get_delta_time);
    lua_register(luaVM, "cpp_get_cursor_position", cpp_get_cursor_position);
    lua_register(luaVM, "cpp_init_defenders", cpp_init_defenders);
    lua_register(luaVM, "cpp_bullet_vs_defender", cpp_bullet_vs_defender);
    lua_register(luaVM, "cpp_destroy_defender", cpp_destroy_defender);
    lua_register(luaVM, "cpp_destroy_defender_rect", cpp_destroy_defender_rect);
    lua_register(luaVM, "cpp_edit_defender_texture", cpp_edit_defender_texture);
    lua_register(luaVM, "cpp_get_cursor_clicked", cpp_get_cursor_clicked);
}

int main(int argc, char const *argv[])
{

    
    glm::mat4x4 projectionViewMatrix;
    GLuint spriteShaderProgram;
    
    if (!glfwInit()){
        return -1;
    } 

    window = glfwCreateWindow(DEFAULT_WINDOW_WIDTH, DEFAULT_WINDOW_HEIGHT, APPLICATION_TITLE, NULL, NULL);
    if (!window)
    {
        glfwTerminate();
        return -1;
    }
    glfwMakeContextCurrent(window);
    glfwWindowHint(GLFW_REFRESH_RATE, 60);

    if (glewInit() != GLEW_OK) {
        fprintf(stderr, "Failed to setup GLEW\n");
        exit(1);
    } 



    if(!createShaderFromFiles("./shaders/in_position_color_texcoord.vert", "./shaders/out_color_texture.frag", &spriteShaderProgram)){
        exit(1);
    }

    starFieldEffect.init();
    {
        GLuint program;
        if(!createShaderFromFiles("./shaders/star_effect.vert", "./shaders/out_color.frag", &program)){
            exit(1);
        }    
        starFieldEffect.program = program;
        starFieldEffect.projectionViewMatrixLoc = glGetUniformLocation(starFieldEffect.program, "uProjectionViewMatrix");
    }

    //initialise game texture atlas

    {
        int comp;
        unsigned char *image = stbi_load("./textures/game_atlas.png", &atlas.width, &atlas.height, &comp, STBI_rgb_alpha);
        glGenTextures(1, &atlas.texture);
        glBindTexture(GL_TEXTURE_2D, atlas.texture);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, atlas.width, atlas.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        stbi_image_free(image);
    }

    //init destruction bitmap
    {
        int comp;
        int width;
        int height;
    
        unsigned char *image= stbi_load("./textures/destruction.png", &width, &height, &comp, STBI_rgb_alpha);

        memcpy(destructionBitmap.bitmap, image, width * height * sizeof(unsigned int));
        stbi_image_free(image);
        destructionBitmap.width= width;
        destructionBitmap.height = height;

    }    
    //Initialise Sprite Batch Buffers
    
    
    glGenBuffers(1, &spriteBatch.vertexBuffer); 
    glGenBuffers(1, &spriteBatch.indexBuffer); 
    spriteBatch.texture.texture = atlas.texture;
    spriteBatch.texture.height = atlas.height;
    spriteBatch.texture.width = atlas.width;
    spriteBatch.program = spriteShaderProgram;
    spriteBatch.projectionViewMatrixLoc = glGetUniformLocation(spriteBatch.program, "uProjectionViewMatrix");
    spriteBatch.uniformTextureLoc = glGetUniformLocation(spriteBatch.program, "uTexture");


    //Initialise starfield

     //This is to initialise Lua
    lua_State* luaVM = luaL_newstate();

    if (NULL == luaVM)
    {
        printf("Error Initializing lua\n");
        return -1;
    }

    // Do stuff with lua code.
    luaL_openlibs(luaVM);
    luaopen_base(luaVM);
    luaopen_io(luaVM);
    luaopen_string(luaVM);
    luaopen_math(luaVM);
    luaopen_package(luaVM);
    luaopen_table(luaVM);
     

    
    luaRegisterFunctions(luaVM);
    luaDoFiles(luaVM);

    //Lua Init
    lua_getglobal(luaVM, "init");
    if(lua_pcall(luaVM, 0, 0, 0) != 0){
        std::cout << "error running:  function init\n " << lua_tostring(luaVM, -1) << std::endl;
    }

    

    while (!glfwWindowShouldClose(window)){
        starFieldEffect.time += GameTime::deltaTime;

        //Clear screen
        glClearColor(0, 0, 0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glEnable(GL_BLEND);

        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        //Generate the orthoGraphic matrix
        projectionViewMatrix = glm::ortho<float>(0.0f, 224.0f, 224.0f, 0.0f, 0.0f, -100.0f);
       

        //update input
        updateInput(window, &leftKey);
        updateInput(window, &rightKey);
        updateInput(window, &upKey);
        updateInput(window, &downKey);
        updateInput(window, &spaceKey);
        updateInput(window, &escKey);
        updateInput(window, &leftButton);
        luaRegisterFunctions(luaVM);

        //Lua Update
        lua_getglobal(luaVM, "update");
        if(lua_pcall(luaVM, 0, 0, 0) != 0){
            std::cout <<  "error running:  function update\n" << lua_tostring(luaVM, -1) << std::endl;
        }
        
        //Draw StafField
        if (starFieldEffect.active){          
            glBindVertexArray(starFieldEffect.vertexArray);
            glBindBuffer(GL_ARRAY_BUFFER, starFieldEffect.starVertexBuffer);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, starFieldEffect.starIndexBuffer);
            glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (GLvoid*)0);
            glEnableVertexAttribArray(0);
            
            glBindBuffer(GL_ARRAY_BUFFER, starFieldEffect.instanceVertexBuffer);
            
            glEnableVertexAttribArray(1);
            glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 7* sizeof(GLfloat), (GLvoid*)0);
            glVertexAttribDivisor(1, 1); 

            glEnableVertexAttribArray(2);
            glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, 7 *sizeof(GLfloat), (GLvoid*)(3 * sizeof(float)));
            glVertexAttribDivisor(2, 1); 
         
            glUseProgram(starFieldEffect.program);
            glm::mat4x4 matrix = glm::perspective<float>(179.1f,1.0f,1.0f,100.0f);
            glUniform1f(glGetUniformLocation(starFieldEffect.program, "uTime"), GameTime::time);
            glUniformMatrix4fv(glGetUniformLocation(starFieldEffect.program, "uProjectionViewMatrix"), 1, GL_FALSE, (float*)&matrix[0][0]);
            glDrawElementsInstanced(GL_TRIANGLES, 36, GL_UNSIGNED_INT, 0, starFieldEffect.particleCount - 10);
            glBindBuffer(GL_ARRAY_BUFFER, 0);
            glBindVertexArray(0);
        }
        
    
        if(spriteBatch.indicies.size() != 0 ){
            //Update The Buffer Data
            glBindBuffer(GL_ARRAY_BUFFER, spriteBatch.vertexBuffer);
            glBufferData(GL_ARRAY_BUFFER, spriteBatch.verticies.size() * sizeof(float), &spriteBatch.verticies.at(0), GL_DYNAMIC_DRAW);

            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, spriteBatch.indexBuffer);
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, spriteBatch.indicies.size() * sizeof(unsigned int), &spriteBatch.indicies.at(0), GL_DYNAMIC_DRAW);
            
            //attach texture
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, atlas.texture);
            glUniform1i(spriteBatch.uniformTextureLoc, 0);
            
            //attach position
            glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 9 * sizeof(float), (void*)0);
            glEnableVertexAttribArray(0);
            //attach color
            glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, 9 * sizeof(float), (void*)(sizeof(float) * 3));
            glEnableVertexAttribArray(1);
            //attach texCoord
            glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 9 * sizeof(float), (void*)(sizeof(float) * 7));
            glEnableVertexAttribArray(2);
            //use sprite program
            glUseProgram(spriteBatch.program);
            
            //attach position
            //attach matrix
            glUniformMatrix4fv(spriteBatch.projectionViewMatrixLoc, 1, GL_FALSE, (float*)&projectionViewMatrix[0][0]);
            
            //Draw
            glDrawElements(GL_TRIANGLES, spriteBatch.indicies.size(), GL_UNSIGNED_INT, 0);
        }

        //Sprite Batch Clear
        spriteBatch.verticies.clear();
        spriteBatch.indicies.clear();
        spriteBatch.indexOffset = 0;
        
        
        glfwPollEvents();
        glfwSwapBuffers(window);
        glfwSwapInterval(1);
        float newTime = glfwGetTime();
        
        GameTime::deltaTime = glfwGetTime() - GameTime::time;
        GameTime::time = newTime;
    }
    lua_close(luaVM);
    glfwDestroyWindow(window);
    glfwTerminate();    
    
    return 0;
}

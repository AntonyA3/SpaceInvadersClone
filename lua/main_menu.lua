

package.loaded["./lua/rect_contains_point"] = nil
local rect_contains_point = require("./lua/rect_contains_point")

package.loaded["./lua/button"] = nil
local Button = require("./lua/button")

local MainMenu = {}

function MainMenu:create()
    local mainMenu = {}
    
    setmetatable(mainMenu, self) 
    self.__index = self  
    mainMenu.started = false

    mainMenu.playButton = Button:create({x=120, y=144}, "play")
    mainMenu.helpButton = Button:create({x=120,y=144 + 16}, "help")
    mainMenu.creditButton = Button:create({x=120,y=144 + 32}, "credit")
  
    return mainMenu
end

return MainMenu
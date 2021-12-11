package.loaded["./lua/player"] = nil
package.loaded["./lua/aliens"] = nil
package.loaded["./lua/mothership"] = nil
package.loaded["./lua/defenders"] = nil
package.loaded["./lua/alienWeapons"] = nil
package.loaded["./lua/main_menu"] = nil

local Player = require("./lua/player")
local Aliens = require("./lua/aliens")
local Mothership = require("./lua/mothership")
local Defenders = require("./lua/defenders")
local MainMenu = require("./lua/main_menu")

package.loaded["./lua/button"] = nil
local Button = require("./lua/button")

local SpaceInvaders = {}

function SpaceInvaders:create()
    local spaceInvaders = {}
    setmetatable(spaceInvaders, self)
    self.__index = self
    
    spaceInvaders.player = Player:create()
    spaceInvaders.aliens = Aliens:create()
    spaceInvaders.mothership = Mothership:create()
    spaceInvaders.defenders = Defenders:create()
    spaceInvaders.mainMenu = MainMenu:create()
    spaceInvaders.whiteTexSrc = {40, 8, 8, 8}
    spaceInvaders.playing = {
        paused = "un paused",
        state = "player vs aliens",
        gameOverMenu ={
            displayDelay = 2,
            displayDelayRemaining = 2,
            playAgainButton = Button:create({x=80,y=136}, "play again"),
            mainMenuButton = Button:create({x=80,y=144+16}, "main menu"),
        },
        levelWon = {
            winningRemaining = 2,
            winningDuration = 2 
        }
    }

    spaceInvaders.creditScreen = {
        backbutton = Button:create({x=0, y=0}, "<back")
    }

    spaceInvaders.helpScreen = {
        animation = {
            alienFrames = {
                frame = 0,
                frameDuration = 0.5,
                frameRemaining = 0.5
            }
        },
        backbutton = Button:create({x=0, y=0}, "<back")
    }

    spaceInvaders.pausedMenu = {
        flickerTime = 0.5,
        resetButton = Button:create({x=120,y=144-32 }, "reset"),
        helpButton = Button:create({x=120,y=144-16}, "help"),
        mainMenuButton = Button:create({x=120,y=144}, "main menu")
    }
    spaceInvaders.score = 0
    spaceInvaders.level = 0
    spaceInvaders.highscore = 0
    spaceInvaders.cursor = {x=10, y=10}
    spaceInvaders.state = "main menu"

    return spaceInvaders
end
return SpaceInvaders


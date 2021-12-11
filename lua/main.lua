
package.loaded["./lua/draw_text"] = nil
local draw_text = require("./lua/draw_text")

package.loaded["./lua/rect_contains_point"] = nil
local rect_contains_point = require("./lua/rect_contains_point")

package.loaded["./lua/rect_intersects_rect"] = nil
local rect_intersects_rect = require("./lua/rect_intersects_rect")

package.loaded["./lua/button_controller"] = nil
local ButtonController = require("./lua/button_controller")

package.loaded["./lua/space_invaders"] = nil
local SpaceInvaders = require("./lua/space_invaders")

package.loaded["./lua/playing_controller"] = nil
local PlayingController = require("./lua/playing_controller")


spaceInvaders = SpaceInvaders:create()

local credit_screen = function(game, creditScreen)
    
    --do back Button
    
    local backbutton = creditScreen.backbutton
    ButtonController.update(backbutton)
  
    if backbutton.state == "pressed" then
        spaceInvaders.state = "main menu"
    end
    
    ButtonController.draw(backbutton)
    draw_text("a space invaders clone", {x=0,y=16})
    draw_text("by antonya3", {x=0, y=32})

    --clean up
    if spaceInvaders.state ~="credits" then
        backbutton.state = "idle"
    end
end


local  function draw_help_screen(spaceInvaders, helpScreen)
    local alienAnim = spaceInvaders.helpScreen.animation.alienFrames

    draw_text("10", {x=44,y=68})
    draw_text("20", {x=82,y=68})
    draw_text("30", {x=130,y=68})
    draw_text("??", {x=174,y=68})

    
    draw_text("a key to move left",{x=24,y=148-32})
    draw_text("d key to move right",{x=24,y=148-24})
    ButtonController.draw(spaceInvaders.helpScreen.backbutton)

    draw_text("press space to fire", {x=24,y=148})


    
    --skull like
    cpp_addSprite({44, 80, 16, 8},{24, 8 * alienAnim.frame, 16, 8} , {1,0,0,1})
    --clawlike
    cpp_addSprite( {80, 80, 16, 8},{8, 8 * alienAnim.frame, 16, 8}, {0,1,0,1})
   
    --squiggy
    cpp_addSprite({132 , 80, 8, 8} ,{0, 8 * alienAnim.frame, 8, 8}  , {0,0,1,1})

    --add mothership 
    cpp_addSprite({174, 80, 16, 8}, {40,0,16,8} ,  {1,0,1,1})
end
local function help_screen_from_paused(spaceInvaders, helpScreen)

    local backbutton = helpScreen.backbutton 
    ButtonController.changePosition(backbutton, {x=24,y=32})
    ButtonController.update(backbutton)

    local animation = helpScreen.animation
    local alienAnim = animation.alienFrames
    alienAnim.frameRemaining = alienAnim.frameRemaining - cpp_get_delta_time()
    if alienAnim.frameRemaining <= 0 then
        alienAnim.frameRemaining = alienAnim.frameRemaining + alienAnim.frameDuration
        if alienAnim.frame == 0 then
            alienAnim.frame = 1
        elseif alienAnim.frame == 1 then
            alienAnim.frame = 0
        end
    end



if backbutton.state == "pressed" then
    spaceInvaders.playing.paused = "paused"
elseif cpp_get_esc_key_state() == 1 then
    spaceInvaders.playing.paused = "un paused"
end

--clean up
    if spaceInvaders.playing.paused ~= "paused and help" then
        backbutton.state = "idle"
    end
end

local function help_screen(spaceInvaders, helpScreen)
--draw3 aliens
-- add squidy
--helpScreen.frame
local backbutton = helpScreen.backbutton
ButtonController.changePosition(backbutton,{x=0, y=0})
ButtonController.update(backbutton)

local animation = helpScreen.animation
local alienAnim = animation.alienFrames
alienAnim.frameRemaining = alienAnim.frameRemaining - cpp_get_delta_time()
if alienAnim.frameRemaining <= 0 then
    alienAnim.frameRemaining = alienAnim.frameRemaining + alienAnim.frameDuration
    if alienAnim.frame == 0 then
        alienAnim.frame = 1
    elseif alienAnim.frame == 1 then
        alienAnim.frame = 0
    end
end



if backbutton.state == "pressed" then
    spaceInvaders.state = "main menu"
end
    draw_help_screen(spaceInvaders,helpScreen)

    --clean up
    if spaceInvaders.state ~= "help" then
        backbutton.state = "idle"
    end
end

local playing = function(spaceInvaders, playing) 
    local deltatime = cpp_get_delta_time()
    local player = spaceInvaders.player
    local aliens = spaceInvaders.aliens
    local mothership = spaceInvaders.mothership
    local defenders = spaceInvaders.defenders
    
    
    if playing.paused == "un paused" then
 
        PlayingController.play(spaceInvaders, spaceInvaders.playing) 
        if cpp_get_esc_key_state() == 1 then --pressed
            playing.paused = "paused"
        end
    elseif playing.paused == "paused and help" then

        help_screen_from_paused(spaceInvaders,spaceInvaders.helpScreen)
    elseif playing.paused == "paused" then

        local pausedMenu = spaceInvaders.pausedMenu
        local resetButton = pausedMenu.resetButton
        local helpButton = pausedMenu.helpButton
        local mainMenuButton = pausedMenu.mainMenuButton

        ButtonController.update(resetButton)
        ButtonController.update(helpButton)
        ButtonController.update(mainMenuButton)
        if resetButton.state == "pressed" then
            playing.paused = "un paused"
            playing.state = "reset game"
        end

        if helpButton.state == "pressed" then
            playing.paused = "paused and help"
        end

        if mainMenuButton.state == "pressed" then
            spaceInvaders.state = "main menu"
            playing.state = "reset game"
            playing.paused = "un paused"
        end

        if playing.paused ~= "paused" then
            --clean up

            helpButton.state ="idle"
            resetButton.state = "idle"
            mainMenuButton.state = "idle"
        end

        if cpp_get_esc_key_state() == 1 then --pressed
            playing.paused = "un paused"
        end
    end

    if spaceInvaders.state == "playing" then
        cpp_addSprite({0,0,244,244},spaceInvaders.whiteTexSrc,{0,0,0,0.95})

    end
    --draw player
    cpp_addSprite({player.position.x, player.position.y,24,8}, {8*16, 8 * player.frame,24,8}, {1.0, 1.0, 1.0, 1.0} )
   
    --draw player bullet
    if player.weapon.active then
        cpp_addSprite(player:getWeaponRect(),spaceInvaders.whiteTexSrc,{0,1,0,1})
    end
    --draw randombullets
    for i= 1, #spaceInvaders.aliens.weapon.randomBullets, 1 do

        local bullet = spaceInvaders.aliens.weapon.randomBullets[i]
        if bullet.active then
            cpp_addSprite({bullet.position.x, bullet.position.y, 2, 8}, {0, 0, 16, 16}, {1.0, 1.0, 1.0, 1.0})
        end
    end

    --draw alien bullets
    if spaceInvaders.aliens.weapon.fireBackBullet.active then
        local bullet = spaceInvaders.aliens.weapon.fireBackBullet
        cpp_addSprite({bullet.position.x, bullet.position.y, 2, 8}, {0, 0, 16, 16}, {1.0, 1.0, 1.0, 1.0})

    end

    --draw lives
    if true then
        sx = 168 + 8 * player.lives
        sy = 0
        sw = 8 
        sh = 8
        cpp_addSprite({8,224-16,8,8}, {sx, sy, sw, sh}, {1.0, 1.0, 1.0, 1.0})
    end
    --draw lives icons
    for i=1, player.lives, 1 do
        sx = 128 
        sy = 0
        sw = 24
        sh = 8
        cpp_addSprite({12 + i * 16,224-16,4+ 24 * 3/4,8 * 3/4}, {sx, sy, sw, sh}, {1.0, 1.0, 1.0, 1.0})
    end
    --draw score
    draw_text("score", {x=32, y=8} )
    draw_text("highscore", {x=128, y=8} )


   
    --draw score
    local text = spaceInvaders.score
    while string.len(text) < 4 do
        text = "0" .. text 
    end
    draw_text(text, {x=32, y=16})
   

    --draw highscore
    local text = spaceInvaders.highscore
    while string.len(text) < 4 do
        text = "0" .. text 
    end
    draw_text(text, {x=128, y=16})

    --draw defenders
    for k, v in pairs(defenders.group) do
        local defender = defenders.group[k]
        cpp_addSprite({defender.position.x, defender.position.y, 24, 16} , {24 * (k -1), 16, 24, 16} , {1.0, 1.0, 1.0, 1.0} )
    end

    

    
    --draw aliens   
    for row,_ in pairs(aliens.group) do
        for column,_ in pairs(aliens.group[row]) do
            local alien = aliens.group[row][column]

            if alien.life.state ~= "dead" then
                local srcRect = {
                    aliens.srcRects[row][1],
                    aliens.srcRects[row][2],
                    aliens.srcRects[row][3],
                    aliens.srcRects[row][4]

                }
                --aliens.animate.frame = 1
                srcRect[1] = srcRect[1] + aliens.animate.frame * aliens.animate.offset.x
                srcRect[2] = srcRect[2] + aliens.animate.frame * aliens.animate.offset.y
                cpp_addSprite(
                    {aliens.group[row][column].position.x, aliens.group[row][column].position.y, 
                        aliens.srcRects[row][3], aliens.srcRects[row][4]
                    }, 
                    srcRect, 
                    aliens.group[row][column].color
                )
            end
        end
    end
    

    if playing.state == "game over" then  
        if playing.gameOverMenu.displayDelayRemaining <= 0 then
            draw_text("game over", {x=80,y=48})
            ButtonController.draw(playing.gameOverMenu.playAgainButton)
            ButtonController.draw(playing.gameOverMenu.mainMenuButton)
        end
    end
    if playing.paused == "paused" and playing.state ~= "game over" then
        local pausedMenu = spaceInvaders.pausedMenu
        local resetButton = pausedMenu.resetButton
        local helpButton = pausedMenu.helpButton
        local mainMenuButton = pausedMenu.mainMenuButton
        draw_text("paused", {x=64,y=64})
        
        ButtonController.draw(resetButton)
        ButtonController.draw(helpButton)
        ButtonController.draw(mainMenuButton)
       
    elseif playing.paused == "paused and help" then
        
        cpp_addSprite({16,32,224-32,224-64}, spaceInvaders.whiteTexSrc, {0,0,0, 0.9})
        draw_help_screen(spaceInvaders, spaceInvaders.helpScreen)
       
    end
    --draw mothership
    if mothership.state == "active" then
        cpp_addSprite({mothership.position.x, mothership.position.y,16,8}, {40,0,16,8}, {1,0,1,1})
    end
end

local main_menu = function(game, mainMenu)
    local playButton = mainMenu.playButton
    local helpButton = mainMenu.helpButton
    local creditButton = mainMenu.creditButton
  
    --play_button(game,playButton)
    ButtonController.update(playButton)
    ButtonController.update(helpButton)
    ButtonController.update(creditButton)

    if creditButton.state == "pressed" then
        spaceInvaders.state = "credits"        
    end

    if helpButton.state == "pressed" then
        spaceInvaders.state = "help"
    end

    if playButton.state == "pressed" then
        spaceInvaders.state = "playing"
    end

    ButtonController.draw(playButton)
    ButtonController.draw(helpButton)
    ButtonController.draw(creditButton)

    --clean up on leave
    if spaceInvaders.state ~="main menu" then
        mainMenu.started = true

        local buttons = {playButton, helpButton,creditButton}
        for i, v in pairs(buttons) do
            v.state = "idle"
        end
    end

end

function init()
    spaceInvaders.state = "main menu"
end

function update()   
    if spaceInvaders.playing.state == "game over" then
        spaceInvaders.playing.paused = "un paused"
    end
    if spaceInvaders.state == "main menu" then
        main_menu(spaceInvaders, spaceInvaders.mainMenu)
    elseif spaceInvaders.state == "playing" then
        playing(spaceInvaders, spaceInvaders.playing)
    elseif spaceInvaders.state== "help" then
        help_screen(spaceInvaders, spaceInvaders.helpScreen)
    elseif spaceInvaders.state == "credits" then
        credit_screen(spaceInvaders, spaceInvaders.creditScreen)
    end    
end

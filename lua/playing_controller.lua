
package.loaded["./lua/alien_controller"] = nil
local AlienController = require("./lua/alien_controller")

local rect_contains_point = require ("./lua/rect_contains_point")
local rect_intersects_rect = require("./lua/rect_intersects_rect")

local draw_text = require("./lua/draw_text")

package.loaded["./lua/button_controller"] = nil
local ButtonController = require("./lua/button_controller")

local function  reset_game(spaceInvaders,playing)
    --reset aliens
    local aliens = spaceInvaders.aliens
    aliens.weapon.fireBackBullet.active = false
    for i, v in pairs(aliens.weapon.randomBullets) do
        v.active = false
    end
    
    aliens.move.state = "move down"
    aliens.move.moveDown = {
        row = 5,
        tickRemaining = 0.5,
        tickTime = 0.5,
        nextState = "move right"
    }


    aliens.animate={
        frame = 0,
        offset = {x=0, y=8},
        nextFrameTime = 0.5,
        frameDuration = 0.5
    }
    
    for row=1, aliens.rowCount, 1 do
        for column=1, aliens.columnCount, 1 do
            local offsetX= 0
            if row == 1 then
                offsetX = 4
            end
            local x = 10 + 16 * column + offsetX
            local y = aliens.startY + 16 * row
            aliens.group[row][column].position= {x=x, y=y}
            aliens.group[row][column].life={
                state="alive"
            }
            
        end
    end
    --re init defenders
    cpp_init_defenders()

    --reset mothership
    local mothership = spaceInvaders.mothership
    mothership.position = {x=0, y=0}
    mothership.state = "hiding"
    mothership.hiding.timeRemaining = mothership.hiding.duration

    --re init score
    spaceInvaders.score = 0

    --re init player
    local player = spaceInvaders.player
    player.position.x = 43
    player.position.y = 192
    player.weapon = {position={x=0, y=0}, active=false}
    player.lives = 3
    player.frame = 0
    player.animation ={
        lifelost = {
            frameDuration= 0.4,
            frameRemaining = 0.4
        }
    }


    --reset level
    spaceInvaders.level = 0


    --go back to playing
    spaceInvaders.playing.state = "player vs aliens"
end

local function next_level(spaceInvaders, playing)

    spaceInvaders.level = spaceInvaders.level + 1
    --regenerate aliens
    for row, _ in pairs(spaceInvaders.aliens.group) do
        for column, _ in pairs(spaceInvaders.aliens.group[row]) do
            spaceInvaders.aliens.group[row][column].life.state = "alive"
            local offsetX= 0
            if row == 1 then
                offsetX = 4
            end
            local x = 10 + 16 * column + offsetX
            local y = aliens.startY + 16 * row
            spaceInvaders.aliens.group[row][column].position = {x=x, y=y + 16 * spaceInvaders.level}
        end
    end
    --destroy alien bullets
    for i, v in pairs (spaceInvaders.aliens:getAllBullets()) do
        v.active = false
    end

    playing.state = "player vs aliens"
end

local function game_over(spaceInvaders, playing)
    
    local player = spaceInvaders.player
    local lifelost = player.animation.lifelost
    local aliens = spaceInvaders.aliens
    local gameOverMenu = playing.gameOverMenu
    if player.frame < 6 then
        lifelost.frameRemaining = lifelost.frameRemaining - cpp_get_delta_time()
        if lifelost.frameRemaining <= 0 then
            lifelost.frameRemaining = lifelost.frameRemaining + lifelost.frameDuration
            player.frame = player.frame + 1
        end 
    end
    if gameOverMenu.displayDelayRemaining > 0 then
        gameOverMenu.displayDelayRemaining  = gameOverMenu.displayDelayRemaining - cpp_get_delta_time()
    end


    if gameOverMenu.displayDelayRemaining <= 0 then
        ButtonController.update(gameOverMenu.playAgainButton)
        ButtonController.update(gameOverMenu.mainMenuButton)
        if spaceInvaders.score >spaceInvaders.highscore then
            spaceInvaders.highscore = spaceInvaders.score
        end
        if gameOverMenu.playAgainButton.state == "pressed" then
            spaceInvaders.playing.state = "reset game"
        elseif gameOverMenu.mainMenuButton.state == "pressed" then
            spaceInvaders.state = "main menu"
            spaceInvaders.playing.state = "reset game"

        end
        --clean up

        if spaceInvaders.state ~= "playing" or spaceInvaders.playing.state ~= "game over" then
            gameOverMenu.playAgainButton.state = "idle"
            gameOverMenu.mainMenuButton.state = "idle" 
        end
    end

    --clean up
end

local function level_won(spaceInvaders, playing)

    local levelWon = playing.levelWon
    levelWon.winningRemaining = levelWon.winningRemaining - cpp_get_delta_time()
    if levelWon.winningRemaining > 0 then
        draw_text("winner", {x=144-64+8,y=144-64})
    else 
        levelWon.winningRemaining = levelWon.winningDuration
        playing.state = "next level"
    end

    --destroy alien bullets
    for i, v in pairs (spaceInvaders.aliens:getAllBullets()) do
        v.active = false
    end
    
end

local function player_lost_life(spaceInvaders,playing)
    local player = spaceInvaders.player
    local lifelost = player.animation.lifelost
    local aliens = spaceInvaders.aliens
    if player.frame < 4 then
        lifelost.frameRemaining = lifelost.frameRemaining - cpp_get_delta_time()
        if lifelost.frameRemaining <= 0 then
            lifelost.frameRemaining = lifelost.frameRemaining + lifelost.frameDuration
            player.frame = player.frame + 1
        end
    else
        playing.state = "player vs aliens"
        player.frame = 0

        --deactivate alien bullets
        local alienBullets = aliens:getAllBullets()
        for i, bullet in pairs(alienBullets) do
            bullet.active = false
        end
    end
end

local function player_vs_aliens(spaceInvaders, playing)
    local deltatime = cpp_get_delta_time()
    local player = spaceInvaders.player
    local aliens = spaceInvaders.aliens
    local mothership = spaceInvaders.mothership
    local defenders = spaceInvaders.defenders
    
    
    --move player
    if cpp_get_left_key_state() == 3 then
        player.position.x = player.position.x - player.speed * deltatime
    end

    if cpp_get_right_key_state() == 3 then
        player.position.x = player.position.x + player.speed * deltatime
    end


    if player.weapon.active == false then
        if cpp_get_space_key_state() == 1 then
            local playerWeapon = player.weapon
            playerWeapon.active = true
            playerWeapon.position.x = player.position.x + 10.5
            playerWeapon.position.y = player.position.y - 8

        end
    end

    --hit left wall
    if player.position.x <= 0 then
        player.position.x = 0
    end

    --hit right wall
    if player.position.x >= 224 - 24 then
        player.position.x = 224 - 24
    end
    if player.weapon.active then 
        player.weapon.position.y = player.weapon.position.y - 200 * cpp_get_delta_time()

        if player.weapon.position.y < -2 then
            player.weapon.active = false
        end
    end

    --Player Done
    AlienController.move(spaceInvaders, spaceInvaders.aliens)
    
    --allows the aliens to fire the bullet back
    

    if aliens.weapon.fireBackBullet.active == false then
        --if player bullet is nearby then
        local bullet = aliens.weapon.fireBackBullet
        for column = 1, aliens.columnCount, 1 do
            for row = aliens.rowCount, 1, -1 do 
                if player.weapon.active then
                    local alien = aliens.group[row][column]    
                    if alien.life.state == "alive" then
                        local dy = player.weapon.position.y - alien.position.y
                        local dx = player.weapon.position.x - alien.position.x
                        if dy < 50 and dx > 0 and dx< 16 then
                            bullet.active = true
                            bullet.position = {x= alien.position.x+6, y= alien.position.y}
                            break
                        end
                    end
                end
            end
        end
    end


    --allows the alien rows to fire randomly
    for id, bullet in pairs(aliens.weapon.randomBullets) do
        if bullet.active == false then
            bullet.resetTime = bullet.resetTime - cpp_get_delta_time()
            if bullet.resetTime<=0 then
                bullet.resetTime = bullet.resetTime + 2
                -- get available aliens
                local availableAliens = {}
                for column = 1, aliens.columnCount, 1 do
                    for row = aliens.rowCount, 1, -1 do 
                        local alien = aliens.group[row][column]    
                        if alien.life.state == "alive" then
                            table.insert(availableAliens, alien)
                            break
                        end
                    end
                end
                local alienChosen = availableAliens[math.floor(math.random() * #availableAliens) + 1]
                bullet.active = true
                bullet.position = {x=alienChosen.position.x, y= alienChosen.position.y}
            end
        elseif bullet.active then
           bullet.position.y = bullet.position.y + spaceInvaders.aliens.bulletSpeed * cpp_get_delta_time()

            if bullet.position.y > 224 + 16 then
                bullet.active = false
            end
        end
    end

    --fire alien bullet down
    if aliens.weapon.fireBackBullet.active then
        aliens.weapon.fireBackBullet.position.y = aliens.weapon.fireBackBullet.position.y + spaceInvaders.aliens.bulletSpeed * cpp_get_delta_time()
        if aliens.weapon.fireBackBullet.position.y > 224 + 16 then
            aliens.weapon.fireBackBullet.active = false
        end
    end

    --update alien animation
    aliens.animate.nextFrameTime = aliens.animate.nextFrameTime - cpp_get_delta_time()
    if aliens.animate.nextFrameTime <= 0 then
        local frame = aliens.animate.frame
        if frame == 1 then
            aliens.animate.frame = 0
        elseif frame == 0 then
            aliens.animate.frame = 1
        end   
        aliens.animate.nextFrameTime = aliens.animate.nextFrameTime + aliens.animate.frameDuration
    end
    
    --update the mothership
    if mothership.state == "active" then
        mothership.position.x = mothership.position.x + mothership.speed * cpp_get_delta_time()
        if mothership.position.x > 224 + 24 then
            mothership.state = "hiding"
            mothership.hiding.timeRemaining = mothership.hiding.duration
        end
    elseif mothership.state == "hiding" then

        mothership.hiding.timeRemaining = mothership.hiding.timeRemaining - cpp_get_delta_time()
        
        if mothership.hiding.timeRemaining <= 0 then
            mothership.state = "active"
            mothership.position.x = -24
        end
        
    elseif mothership.state == "dead" then
        mothership.state = "hiding"
        mothership.hiding.timeRemaining = mothership.hiding.duration
    end
    --collision


    
    do
        local bullets ={}
        for i,v in pairs(aliens:getAllBullets()) do
            table.insert(bullets,v)
        end
        table.insert(bullets, player.weapon)


        local defenderChanged = false
        
        for defenderId = 1, #spaceInvaders.defenders.group, 1 do
            --aliens vs defender
            for row, _ in pairs(spaceInvaders.aliens.group) do
                for column, _ in pairs(spaceInvaders.aliens.group[row]) do
                    if rect_intersects_rect(defenders:getRectAt(defenderId), aliens:getRectAt(row, column)) then
                        cpp_destroy_defender_rect(defenderId - 1,
                        defenders.group[defenderId].position.x,
                        defenders.group[defenderId].position.y,
                        aliens:getRectAt(row,column)
                    )
                    end
                end
            end
            --bullet hits defender

            for bulletId = 1, #bullets, 1 do
                local bullet = bullets[bulletId]
                if bullet.active then
                    local bulletRect = {bullet.position.x, bullet.position.y, 2, 8}
                    if bullet == player.weapon then
                        bulletRect = player:getWeaponRect()
                    end
                    if rect_intersects_rect(defenders:getRectAt(defenderId), bulletRect) then
                        local down = true
                        
                        hit, y = cpp_bullet_vs_defender(
                            defenderId - 1, 
                            bulletRect, 
                            defenders.group[defenderId].position.x,
                            defenders.group[defenderId].position.y,
                            down
                        )
                        
                        if hit then                            
                            offset = -2

                            if bullet == player.weapon then
                                offset = -4
                            end
                            bullet.active = false
                            defenderChanged = true
                        
                            cpp_destroy_defender(defenderId - 1, bullet.position.x -4, y + offset,  
                                defenders.group[defenderId].position.x,
                                defenders.group[defenderId].position.y
                            )
                        end
                    end
                end
            end
        end

        if defenderChanged then
            cpp_edit_defender_texture()
        end 
    end

    if player.weapon.active then 
        --bullet hit mothership
        if rect_intersects_rect(mothership:getRect(),player:getWeaponRect() ) then
            mothership.state = "dead"
            player.weapon.active = false

        end

        

        --bullet hit aliens
        for row,_ in pairs(aliens.group) do
            for column,_ in pairs(aliens.group[row]) do
                if player.weapon.active then
                    local alien = aliens.group[row][column]
                    if alien.life.state == "alive" then
                        local alienRect = aliens:getRectAt(row, column)
                        if rect_intersects_rect(alienRect, player:getWeaponRect()) then
                            alien.life.state = "dead"
                            player.weapon.active = false

                            if row == 1 then
                                spaceInvaders.score = spaceInvaders.score + 30
                            elseif row == 2 or row == 3 then
                                spaceInvaders.score = spaceInvaders.score + 20
                            elseif row == 4 or row == 5 then
                                spaceInvaders.score= spaceInvaders.score + 10
                            end                                    
                        end
                    end
                end
            end
        end
    end

    
    
    --life lost when alien bullet hits player
    --destroy bullet as well
    do
        local randomBullets = aliens.weapon.randomBullets
        local fireBack = aliens.weapon.fireBackBullet
        local alienBullets ={}
        table.insert(alienBullets, fireBack)
        for i, v in pairs(randomBullets) do
            table.insert(alienBullets, v)
        end
  
        for i = 1,#alienBullets do
            if alienBullets[i].active then
                if rect_intersects_rect(player:getRect(), {alienBullets[i].position.x, alienBullets[i].position.y, 2, 8})then
                    alienBullets[i].active = false
                    player.lives = player.lives - 1
                    playing.state = "player lost life"
                    break
                end
            end
        end           
    end
    
    --check if game over    aliens vs player
    for row,_ in pairs(aliens.group) do
        for column,_ in pairs(aliens.group[row]) do
            alienRect = aliens:getRectAt(row, column)
            if rect_intersects_rect(alienRect, player:getRect()) then
                playing.state = "game over"
            end
        end
    end


    --temp[ Win as soon as press space]


    --check if level won
    do
        won = true
        for row,_ in pairs(aliens.group) do
            for column,_ in pairs(aliens.group[row]) do
                won = won and aliens.group[row][column].life.state == "dead"
            end
        end

        if won then
            playing.state = "level won"
        end
    end

    if player.lives <= 0 then
        playing.state = "game over"    
    end
end

local play = function(spaceInvaders, playing)
    
    if playing.state == "player vs aliens" then
        player_vs_aliens(spaceInvaders, playing)
    elseif playing.state == "player lost life" then
        player_lost_life(spaceInvaders, playing)
    elseif playing.state == "game over" then
        game_over(spaceInvaders, playing)
    elseif playing.state == "level won" then
        level_won(spaceInvaders, playing)
    elseif playing.state == "reset game" then
        reset_game(spaceInvaders, playing)
    elseif playing.state == "next level" then
        next_level(spaceInvaders, playing) 
    end
end

local PlayingController = {
    play = play
}

return PlayingController
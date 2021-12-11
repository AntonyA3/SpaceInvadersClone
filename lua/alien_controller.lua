



local move_left_func = function(spaceInvaders, aliens)
    local moveLeft =aliens.move.moveLeft
    local deltatime = cpp_get_delta_time()
    moveLeft.tickRemaining = moveLeft.tickRemaining - deltatime
    local complete = false
    if moveLeft.tickRemaining <= 0 then
        local alien = aliens.group[ moveLeft.row][ moveLeft.column]
        alien.position.x = alien.position.x - 4
        moveLeft.tickRemaining = moveLeft.tickRemaining + 0.016
        repeat
            moveLeft.column = moveLeft.column + 1
            if moveLeft.column > aliens.columnCount then
                moveLeft.column = 1
                moveLeft.row = moveLeft.row - 1
                if moveLeft.row == 0 then
                    moveLeft.row = 5
                    complete = true
                end
            end
        until aliens.group[moveLeft.row][moveLeft.column].life.state == "alive"
    end
    
    if complete then
        --move down
        local foundLeft, leftPoint = aliens:minX();
        if foundLeft then 
            if  (leftPoint <= 6) then
                aliens.move.state = "move down"
                aliens.move.moveDown.row = 5
                aliens.move.moveDown.tickRemaining = 0.5
                aliens.move.moveDown.nextState = "move right"
            end
        end   
    end
end

local move_right_func = function(spaceInvaders, aliens)
    local moveRight = aliens.move.moveRight
    
    local deltatime = cpp_get_delta_time()
    moveRight.tickRemaining = moveRight.tickRemaining - deltatime

    local complete = false
    if moveRight.tickRemaining <= 0 then
        local alien = aliens.group[moveRight.row][moveRight.column]
        alien.position.x = alien.position.x + 4
        moveRight.tickRemaining = moveRight.tickRemaining + moveRight.tickTime
        repeat
            moveRight.column = moveRight.column - 1
            if moveRight.column == 0 then
                moveRight.column = 11
                moveRight.row = moveRight.row - 1
                if moveRight.row == 0 then
                    moveRight.row = 5
                    complete = true
                end
            end
        until aliens.group[moveRight.row][moveRight.column].life.state == "alive"
        
    end

    --move down
    if complete then
        local foundRight, rightPoint = aliens:maxX();
        if foundRight and (rightPoint >= 224) then
            aliens.move.state = "move down"
            aliens.move.moveDown.row = 5
            aliens.move.moveDown.tickRemaining = aliens.move.moveDown.tickTime
            aliens.move.moveDown.nextState = "move left"
        end
    end
end

local move_down_func = function(spaceInvaders, aliens) 
    local moveDown = aliens.move.moveDown
    moveDown.tickRemaining = moveDown.tickRemaining - cpp_get_delta_time()
    if(moveDown.tickRemaining < 0) then

        for column,_ in pairs(aliens.group[moveDown.row]) do
            aliens.group[moveDown.row][column].position.y = aliens.group[moveDown.row][column].position.y + 4
        end        
        moveDown.row = moveDown.row - 1
        moveDown.tickRemaining = moveDown.tickRemaining + moveDown.tickTime
    end
    if moveDown.row == 0 then   
                  
        aliens.move.state = moveDown.nextState
        if moveDown.nextState == "move left" then
            local moveLeft = aliens.move.moveLeft
            moveLeft.row = aliens.rowCount
            moveLeft.column = 1
            moveLeft.tickRemaining = 0.03
            moveLeft.tickTime = 0.03

        elseif moveDown.nextState == "move right" then
            local moveRight = aliens.move.moveRight
            moveRight.row = aliens.rowCount
            moveRight.column = aliens.columnCount
            moveRight.tickRemaining = 0.03
            moveRight.tickTime = 0.03

        end
        
    end
    
end

local function move(spaceInvaders, aliens)
    local moveState = aliens.move.state
    
    if moveState == "move left" then
        move_left_func(spaceInvaders, aliens)
    elseif moveState == "move right" then
        move_right_func(spaceInvaders, aliens)
    elseif moveState == "move down" then
        move_down_func(spaceInvaders, aliens)
    end
end

local AlienController = {
    move = move
}

return AlienController
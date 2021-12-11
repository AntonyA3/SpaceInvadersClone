local Aliens = {}

function Aliens:create()
    local aliens = {}
    
    setmetatable(aliens, self) 
    self.__index = self  
    
    aliens.rowCount = 5
    aliens.startY = 40
    aliens.columnCount = 11
    aliens.bulletSpeed = 100
    aliens.weapon = {
     
        fireBackBullet = {
            position={x=0, y=0}, 
            active=false
        },
        randomBullets = {
            {
                position={x=0, y=0}, 
                active=false, 
                resetTime= 5.3
            },
            {
                position={x=0, y=0}, 
                active=false, 
                resetTime=4.24
            },
            {
                position={x=0, y=0}, 
                active=false, 
                resetTime=3.25
            }
            
        }
    }
    
    aliens.move = {
        state = "move down",
        moveRight = {
            row = 1,
            column = 1,
            tickRemaining = 0.03,
            tickTime = 0.03
        },
        moveLeft = {
            row = 1,
            column = 1,
            tickRemaining = 0.03,
            tickTime = 0.03
        },
        moveDown = {
            row = 5,
            tickRemaining = 0.5,
            tickTime = 0.5,
            nextState = "move right"
        }

    }

    aliens.srcRects = {
        {0, 0, 8, 8},
        {8, 0, 16, 8},
        {8, 0, 16, 8},
        {24, 0, 16, 8},
        {24, 0, 16, 8}
    }

    aliens.animate={
        frame = 0,
        offset = {x=0, y=8},
        nextFrameTime = 0.5,
        frameDuration = 0.5
    }
    
    aliens.group = {}
    for row=1, aliens.rowCount, 1 do
        aliens.group[row] = {}
        for column=1, aliens.columnCount, 1 do
            local offsetX= 0
            local color = {0,0,1,1}
            if row == 1 then
                offsetX = 4
            end

            if row == 2 or row == 3 then
                color = {0,1,0,1}
            end

            if row == 4 or row == 5 then
                color = {1,0,0, 1}
            end

            local x = 10 + 16 * column + offsetX
            local y = aliens.startY + 16 * row
            aliens.group[row][column] = {
                position={x=x, y=y},
                color=color,
                life={
                    state="alive"
                }
            }
        end
    end
    
    return aliens
end

function Aliens:getAllBullets()
    local bullets = {}
    table.insert(bullets,self.weapon.fireBackBullet)
    for i,v in pairs(self.weapon.randomBullets)do
        table.insert(bullets, v)
    end
    return bullets
end

function Aliens:minX()     
    for column=1, self.columnCount, 1 do
        for row=1, self.rowCount, 1 do
            if self.group[row][column].life.state == "alive" then
                local x = self.group[row][column].position.x
                if row == 1 then
                    x = x - 4
                end
                return true, x
            end
        end    
    end 
    return false, 0    
end


function Aliens:getRectAt(row, column)
    local position = self.group[row][column].position
    if row== 1 then
        return {position.x,position.y,8, 8}
    end
    return {position.x + 1,position.y, 14, 8}
end

function Aliens:maxX()
    for column=self.columnCount, 1, -1 do
        for row=1, self.rowCount, 1 do
            if self.group[row][column].life.state == "alive" then
                local x = self.group[row][column].position.x + 16
                if row==1 then
                    x = x -4
                end
                return true, x
            end
        end 
    end 
    return false, 0
end


function Aliens:init()
    for row=1, self.rowCount, 1 do
        self.group[row] = {}
        for column=1, self.columnCount, 1 do
            local offsetX= 0
            local color = {0,0,1,1}
            if row == 1 then
                offsetX = 4
            end

            if row == 2 or row == 3 then
                color = {0,1,0,1}
            end

            if row == 4 or row == 5 then
                color = {1,0,0,1}
            end

            local x = 10 + 16 * column + offsetX
            local y = 10 + 16 * row
            self.group[row][column] = {
                position={x=x, y=y},
                color=color
            }
        end
    end 
end

return Aliens
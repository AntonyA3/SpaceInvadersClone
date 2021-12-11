local Player = {position={x=22, y=10}}

function Player:create()
    local player = {}
    setmetatable(player, self) 
    self.__index = self 
    player.position.x = 43
    player.position.y = 192
    player.weapon = {position={x=0, y=0}, active=false}
    player.speed = 120
    player.lives = 3
    player.frame = 0
    player.srcRect = {8*16, 0 ,24,8}
    player.animation ={
        lifelost = {
            frameDuration= 0.4,
            frameRemaining = 0.4
        }
    }
    return player
end

function  Player:getRect()
    return {self.position.x,self.position.y+4, 24,4}
end
function Player:getWeaponRect()
    return {self.weapon.position.x, self.weapon.position.y, 2, 8}
end

return Player
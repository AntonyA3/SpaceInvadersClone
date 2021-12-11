local Mothership = {}


function Mothership:create()
    local mothership = {}

    setmetatable(mothership, self) 
    self.__index = self  
    self.position = {x=0, y=32}
    self.state = "hiding"
    self.speed = 60
    self.hiding = {
        duration = 10,
        timeRemaining = 10
    }
    return mothership
end

function Mothership:getRect()
    return {self.position.x, self.position.y, 16, 8}
end

return Mothership
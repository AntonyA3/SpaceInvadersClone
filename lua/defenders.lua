
local Defenders = {}

function Defenders:create()
    local defenders = {}    
    
    setmetatable(defenders, self) 
    self.__index = self  
    
    defenders.group = {}

    for i=1, 4, 1 do
        defenders.group[i]= {
            position={x=29 + 48 * (i - 1), y=168}
        }
    end

    cpp_init_defenders()
    return defenders
end

function Defenders:getRectAt(i)
    local position = self.group[i].position
    return {position.x, position.y, 22, 16}
end

return Defenders
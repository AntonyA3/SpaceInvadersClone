local Button = {}

function Button:create(position, text)
    local button = {}

    setmetatable(button, self) 
    self.__index = self  

    button.position = {x=position.x, y=position.y}
    --button.rect = {position.x, position.y, 8 * string.len(text), 8}
    button.text = text
    button.colorRect = {
        rect = {0, 0, 16, 16},
        color = {1, 0, 0, 1}
    }
    button.state = "idle"
    return button
end

function Button:getRect()
    return {self.position.x, self.position.y, 8 * string.len(self.text), 8}
end

return Button
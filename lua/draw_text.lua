


local draw_text = function(text, position,color) 
    
    local textColor = {1.0, 1.0, 1.0, 1.0}
    
    if color ~= nil then
        textColor = color
    end
    
    for i=1, string.len(text), 1 do
        local charType = "letter"
        local character = string.sub(text, i, i)
        if string.byte(character) == string.byte("<") then
            charType = "open tri brack"
         
        elseif string.byte(character) == string.byte(" ") then
            charType = "space"
        elseif string.byte(character) - string.byte("0") < 10 then
            charType = "number"
        elseif string.byte(character) == string.byte('?') then
            charType = "question mark"
        end

         

        if charType == "letter" then
            local diff = string.byte(character) - string.byte("a")
            local row = math.floor(diff / 8)
            local column = diff - 8 * row
            local sx = column * 16
            local sy = 32 + row * 16
            local sw = 16
            local sh = 16
            
            cpp_addSprite({(i - 1) * 8 + position.x, position.y, 8, 8}, {sx, sy, sw, sh},textColor)
        
        elseif charType == "number" then

            local diff = string.byte(character) - string.byte("0")
            local sx = (9 * 16 + 24) + diff * 8 
            local sy = 0 
            local sw = 8
            local sh = 8 
            cpp_addSprite({(i - 1) * 8 + position.x, position.y, 8, 8}, {sx, sy, sw, sh}, textColor)
        elseif charType == "question mark" then
            local sx = 64
            local sy = 80 
            local sw = 16
            local sh = 16
            cpp_addSprite({(i - 1) * 8 + position.x, position.y, 8, 8}, {sx, sy, sw, sh}, textColor) 
        elseif charType == "open tri brack" then
            local sx = 32
            local sy = 80 
            local sw = 16
            local sh = 16
            cpp_addSprite({(i - 1) * 8 + position.x, position.y, 8, 8}, {sx, sy, sw, sh}, textColor) 
        end
    end
end

return draw_text

package.loaded["./lua/draw_text"] = nil
local draw_text = require("./lua/draw_text")

package.loaded["./lua/rect_contains_point"] = nil
local rect_contains_point = require("./lua/rect_contains_point")

package.loaded["./lua/button"] = nil
local Button = require("./lua/button")


local draw = function(button)
    if button.state == "hovered" then
        draw_text(button.text, button.position, {0,1,0,1})
    else
        draw_text(button.text,  button.position)

    end
end



local update = function(button) 
    if button.state == "idle" then
        local x, y = cpp_get_cursor_position()
        if rect_contains_point(button:getRect(), x, y) then
            button.state = "hovered"
        end
    elseif button.state == "hovered" then
        local x, y = cpp_get_cursor_position()
        if rect_contains_point(button:getRect() , x, y) == false then
            button.state = "idle"
        else 
            if cpp_get_left_mouse_state() == 1 then
                button.state = "pressed"
            end
        end
    elseif button.state == "pressed" then
    end
end


local changePosition = function(button,position)
    button.position = position
end

local Button = {update=update, draw=draw, 
    changePosition=changePosition
}

return Button
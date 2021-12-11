

local rect_intersects_rect = function(rect1, rect2)
    local xPassed = (math.max(rect1[1] + rect1[3], rect2[1] + rect2[3]) - math.min(rect1[1], rect2[1])) <= (rect1[3] + rect2[3])
    local yPassed = (math.max(rect1[2] + rect1[4], rect2[2] + rect2[4]) - math.min(rect1[2], rect2[2])) <= (rect1[4] + rect2[4])
    return xPassed and yPassed
end
return rect_intersects_rect
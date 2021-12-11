local rect_contains_point = function(rect,x, y)
    if (x > rect[1] and x <= (rect[1] + rect[3]) and y > rect[2] and y <= (rect[2] + rect[4])) then
        return true;
    end
    return false;
end
return rect_contains_point
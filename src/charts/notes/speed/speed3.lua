local speed = game.notes.speed

---@class speed3:enemy
local speed3 = {}
speed3.__index = speed3

-- Inherits
setmetatable(speed3, speed)

function speed3:new(line)
    local new = setmetatable(speed:new("basic1", line), self)
    
    return new
end

function speed3:destroy()
    speed.destroy(self)
end

return speed3
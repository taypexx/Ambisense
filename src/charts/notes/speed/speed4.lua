local speed = game.notes.speed

---@class speed4:enemy
local speed4 = {}
speed4.__index = speed4

-- Inherits
setmetatable(speed4, speed)

function speed4:new(line)
    local new = setmetatable(speed:new("basic1", line), self)
    
    return new
end

function speed4:destroy()
    speed.destroy(self)
end

return speed4
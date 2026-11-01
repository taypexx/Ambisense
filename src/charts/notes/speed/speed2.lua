local speed = game.notes.speed

---@class speed2:enemy
local speed2 = {}
speed2.__index = speed2

-- Inherits
setmetatable(speed2, speed)

function speed2:new(line)
    local new = setmetatable(speed:new("basic1", line), self)
    
    return new
end

function speed2:destroy()
    speed.destroy(self)
end

return speed2
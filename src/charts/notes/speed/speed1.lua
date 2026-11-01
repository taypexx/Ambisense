local speed = game.notes.speed

---@class speed1:speed
local speed1 = {}
speed1.__index = speed1

-- Inherits
setmetatable(speed1, speed)

function speed1:new(line)
    local new = setmetatable(speed:new("basic1", line), self)
    
    return new
end

function speed1:destroy()
    speed.destroy(self)
end

return speed1
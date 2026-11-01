local enemy = game.notes.enemy

---@class heal:enemy
local heal = {
    duration = 2
}
heal.__index = heal

-- Inherits
setmetatable(heal, enemy)

function heal:new(line, long, long_end)
    local new = setmetatable(enemy:new("heal", self.duration, line, long, long_end), self)
    
    return new
end

function heal:destroy()
    enemy.destroy(self)
end

return heal
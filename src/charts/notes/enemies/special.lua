local enemy = game.notes.enemy

---@class special:enemy
local special = {
    duration = 1.5
}
special.__index = special

-- Inherits
setmetatable(special, enemy)

function special:new(line, long, long_end)
    local new = setmetatable(enemy:new("special", self.duration, line, long, long_end), self)
    
    return new
end

function special:destroy()
    enemy.destroy(self)
end

return special
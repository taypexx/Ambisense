local enemy = game.notes.enemy

---@class normal2:enemy
local normal2 = {
    duration = 2
}
normal2.__index = normal2

-- Inherits
setmetatable(normal2, enemy)

function normal2:new(line, long, long_end)
    local new = setmetatable(enemy:new("normal2", self.duration, line, long, long_end), self)
    
    return new
end

function normal2:destroy()
    enemy.destroy(self)
end

return normal2
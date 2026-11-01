local enemy = game.notes.enemy

---@class normal1:enemy
local normal1 = {
    duration = 2
}
normal1.__index = normal1

-- Inherits
setmetatable(normal1, enemy)

function normal1:new(line, long, long_end)
    local new = setmetatable(enemy:new("normal1", self.duration, line, long, long_end), self)
    
    return new
end

function normal1:destroy()
    enemy.destroy(self)
end

return normal1
local enemy = game.notes.enemy

---@class heavy1:enemy
local heavy1 = {
    duration = 2
}
heavy1.__index = heavy1

-- Inherits
setmetatable(heavy1, enemy)

function heavy1:new(line, long, long_end)
    local new = setmetatable(enemy:new("heavy1", self.duration, line, long, long_end), self)
    
    return new
end

function heavy1:destroy()
    enemy.destroy(self)
end

return heavy1
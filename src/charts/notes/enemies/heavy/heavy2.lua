local enemy = game.notes.enemy

---@class heavy2:enemy
local heavy2 = {
    duration = 2
}
heavy2.__index = heavy2

-- Inherits
setmetatable(heavy2, enemy)

function heavy2:new(line, long, long_end)
    local new = setmetatable(enemy:new("heavy2", self.duration, line, long, long_end), self)
    
    return new
end

function heavy2:destroy()
    enemy.destroy(self)
end

return heavy2
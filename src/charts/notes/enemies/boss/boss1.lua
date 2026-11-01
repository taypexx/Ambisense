local enemy = game.notes.enemy

---@class boss1:enemy
local boss1 = {
    duration = 1.8
}
boss1.__index = boss1

-- Inherits
setmetatable(boss1, enemy)

function boss1:new(line, long, long_end)
    local new = setmetatable(enemy:new("boss1", self.duration, line, long, long_end), self)
    
    return new
end

function boss1:destroy()
    enemy.destroy(self)
end

return boss1
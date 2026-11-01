local enemy = game.notes.enemy

---@class boss2:enemy
local boss2 = {
    duration = 1.8
}
boss2.__index = boss2

-- Inherits
setmetatable(boss2, enemy)

function boss2:new(line, long, long_end)
    local new = setmetatable(enemy:new("boss2", self.duration, line, long, long_end), self)
    
    return new
end

function boss2:destroy()
    enemy.destroy(self)
end

return boss2
local enemy = game.notes.enemy

---@class boss3:enemy
local boss3 = {
    duration = 1.8
}
boss3.__index = boss3

-- Inherits
setmetatable(boss3, enemy)

function boss3:new(line, long, long_end)
    local new = setmetatable(enemy:new("boss3", self.duration, line, long, long_end), self)
    
    return new
end

function boss3:destroy()
    enemy.destroy(self)
end

return boss3
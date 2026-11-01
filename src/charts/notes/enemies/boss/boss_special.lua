local enemy = game.notes.enemy

---@class boss_special:enemy
local boss_special = {
    duration = 1.3
}
boss_special.__index = boss_special

-- Inherits
setmetatable(boss_special, enemy)

function boss_special:new(line, long, long_end)
    local new = setmetatable(enemy:new("boss_special", self.duration, line, long, long_end), self)
    
    return new
end

function boss_special:destroy()
    enemy.destroy(self)
end

return boss_special
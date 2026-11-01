local enemy = game.notes.enemy

---@class boss4:enemy
local boss4 = {
    duration = 1.8
}
boss4.__index = boss4

-- Inherits
setmetatable(boss4, enemy)

function boss4:new(line, long, long_end)
    local new = setmetatable(enemy:new("boss4", self.duration, line, long, long_end), self)
    
    return new
end

function boss4:destroy()
    enemy.destroy(self)
end

return boss4
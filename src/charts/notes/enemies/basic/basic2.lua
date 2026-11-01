local enemy = game.notes.enemy

---@class basic2:enemy
local basic2 = {
    duration = 2.5
}
basic2.__index = basic2

-- Inherits
setmetatable(basic2, enemy)

function basic2:new(line, long, long_end)
    local new = setmetatable(enemy:new("basic2", self.duration, line, long, long_end), self)
    
    return new
end

function basic2:destroy()
    enemy.destroy(self)
end

return basic2
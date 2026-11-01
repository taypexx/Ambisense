local enemy = game.notes.enemy

---@class basic1:enemy
local basic1 = {
    duration = 2.5
}
basic1.__index = basic1

-- Inherits
setmetatable(basic1, enemy)

function basic1:new(line, long, long_end)
    local new = setmetatable(enemy:new("basic1", self.duration, line, long, long_end), self)
    
    return new
end

function basic1:destroy()
    enemy.destroy(self)
end

return basic1
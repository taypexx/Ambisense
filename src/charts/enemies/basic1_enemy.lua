local enemy = game.enemies.enemy

---@class basic1_enemy:enemy
local basic1_enemy = {}
basic1_enemy.__index = basic1_enemy

-- Inherits
setmetatable(basic1_enemy, enemy)

function basic1_enemy:new()
    local new = setmetatable(enemy:new(), self)
    
    return new
end

function basic1_enemy:destroy()
    enemy.destroy(self)
end

return basic1_enemy
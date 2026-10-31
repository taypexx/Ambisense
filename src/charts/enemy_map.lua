local utils = game.utils
local object = game.object

local BMS_CHARS = {
    "0","1","2","3","4","5","6","7","8","9",
    "A","B","C","D","E","F","G","H","I","J",
    "K","L","M","N","O","P","Q","R","S","T",
    "U","V","W","X","Y","Z"
}
local BMS_IDS = {}
for i = 1,#BMS_CHARS do
    for j = 1,#BMS_CHARS do
        table.insert(BMS_IDS, BMS_CHARS[i]..BMS_CHARS[j])
    end
end

local BMS_LINES = {
    "16", -- Left
    "11", -- Top
    "12", -- Right
    "13", -- Bottom
    "14", -- Misc1
    "15", -- Misc2
    "18", -- Misc3
    "19", -- Misc4
}

local ENEMY_IDS = {
    ["02"] = game.enemies.basic1_enemy,
}

---@class enemy_map:object
---@field initial_speed integer Initial speed of the map.
---@field enemies table<number,integer> Dictionary of enemies where key is the timestamp in seconds and value is the value is the enemy ID.
local enemy_map = {
    initial_speed = nil,
    enemies = nil,
}
enemy_map.__index = enemy_map
enemy_map.__newindex = utils.readonly_func({"initial_speed", "enemies"})

-- Inherits
setmetatable(enemy_map, object)

function enemy_map:new(initial_speed, bms_main)
    local new = setmetatable(object:new(), self)
    new.initial_speed = initial_speed or 1
    new.enemies = {}

    -- Parsing the bms data.

    return new
end

function enemy_map:destroy()
    object.destroy(self)
end

return enemy_map
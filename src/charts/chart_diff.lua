local utils = game.utils
local object = game.object

---@class chart_diff:object
---@field chart chart Chart object that this difficulty belongs to. 
---@field charter string Name of the designer who created the map.
---@field difficulty integer Difficulty rating.
---@field stage_map map Map to load the enemies on.
---@field enemy_map enemy_map BMS map with enemies.
local chart_diff = {
    chart = nil,
    charter = nil,
    difficulty = nil,
    stage_map = nil,
    enemy_map = nil
}
chart_diff.__index = chart_diff
chart_diff.__newindex = utils.readonly_func({"chart", "chart_designer", "difficulty", "stage_map", "enemy_map"})

-- Inherits
setmetatable(chart_diff, object)

function chart_diff:new(diff_info)
    local new = setmetatable(object:new(), self)
    for k,v in pairs(diff_info) do
        new[k] = v
    end

    return new
end

function chart_diff:destroy()
    object.destroy(self)
end

return chart_diff
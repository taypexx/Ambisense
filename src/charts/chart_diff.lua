local utils = game.utils
local object = game.object

---@class chart_diff:object
---@field chart chart Chart object that this difficulty belongs to. 
---@field bms_data bms_data BMS data for this difficulty.
---@field charter string Name of the designer who created the map.
---@field difficulty integer Difficulty rating.
---@field rank integer Rank of the difficulty (0 = Easy, 1 = Normal, 2 = Hard, 3 = Expert).
---@field note_map note_map BMS map with notes.
local chart_diff = {
    chart = nil,
    bms_data = nil,
    charter = nil,
    difficulty = nil,
    rank = nil,
    note_map = nil
}
chart_diff.__index = chart_diff
chart_diff.__newindex = utils.readonly_func({"chart", "bms_data", "chart_designer", "difficulty", "stage_map", "note_map"})

-- Inherits
setmetatable(chart_diff, object)

function chart_diff:new(chart, bms_data)
    if not chart then game.error("Cannot create a chart_diff: chart was not provided.") return end
    if not bms_data then game.error("Cannot create a chart_diff: bms_data was not provided.") return end

    local new = setmetatable(object:new(), self)
    new.chart = chart
    new.bms_data = bms_data
    new.charter = bms_data.header.charter
    new.difficulty = bms_data.header.difficulty
    new.rank = bms_data.header.rank

    new.note_map = game.charts.note_map:new(bms_data.header.speed, bms_data.header.bpm, bms_data.main)

    return new
end

function chart_diff:destroy()
    if self.note_map then
        self.note_map:destroy()
    end
    object.destroy(self)
end

return chart_diff
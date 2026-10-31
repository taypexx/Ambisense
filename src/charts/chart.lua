local utils = game.utils
local object = game.object

---@class chart:object
---@field name string Name of the chart.
---@field artist string Author of the chart's music.
---@field difficulties table<integer,chart_diff> Dictionary of all chart difficulties where key is the difficulty index and value is the chart_diff.
---@field demo audio Preview audio of the chart.
---@field music audio Music of the chart to be played in game.
local chart = {
    name = nil,
    artist = nil,
    difficulties = nil,
    demo = nil,
    music = nil,
}
chart.__index = chart
chart.__newindex = utils.readonly_func({"name", "artist", "difficulties", "demo", "music"})

-- Inherits
setmetatable(chart, object)

--- Creates a new chart.
---@param file_name string File name of the chart relative to assets/charts.
---@return chart|nil chart Newly created chart.
function chart:new(file_name)
    if not file_name then game.error("Cannot create a chart: file_name was not provided.") return end
    if not utils.ends_with(file_name, ".zip") then game.error("Cannot create a chart: file is not a zip.") return end

    local new = setmetatable(object:new(), self)


    return new
end

function chart:destroy()
    
end

return chart
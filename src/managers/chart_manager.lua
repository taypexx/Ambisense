---@class chart_manager
---@field loaded table<integer,chart> Dictionary of all loaded charts where key is the chart's UID and value is the chart. Can be indexed by chart name as well.
local chart_manager = {
    chart_paths = {"assets/charts", "custom_charts"},
    last_uid = 0,
    loaded = setmetatable({}, {__index = function(t,k)
        for uid,chart in pairs(t) do
            if chart and (k == uid or k == chart.name) then
                return chart
            end
        end
    end}),
}
chart_manager.__index = chart_manager

--- Gets the chart by its key/name.
---@param key any
---@return chart|nil
function chart_manager:get(key)
    return self.loaded[key]
end

--- Loads all charts into the memory.
function chart_manager:load_charts()
    for _,charts_path in ipairs(self.chart_paths) do
        if love.filesystem.getInfo(charts_path) then
            for _,item in ipairs(love.filesystem.getDirectoryItems(charts_path)) do
                local path = string.format("%s/%s", charts_path, item)
                local new_uid = self.last_uid + 1
                local chart = game.charts.chart:new(new_uid, path)
                if chart then
                    self.last_uid = new_uid
                    self.loaded[chart.uid] = chart
                    game.log(string.format("Loaded chart: %s (UID: %d)", chart.name, chart.uid))
                end
            end
        end
    end
end

return chart_manager
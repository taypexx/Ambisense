---@class audio_handler
---@field temp_sources table<love.Source> All currently playing temporary sources.
local audio_handler = {
    temp_sources = {}
}
audio_handler.__index = audio_handler

function audio_handler:add_temp(source)
    if not source then game.error("Cannot add temporary source: source was not provided.") return end
    if game.utils.table_find(self.temp_sources, source) then game.error("Cannot add temporary source: source already added.") return end

    table.insert(self.temp_sources, source)
end

function audio_handler:update()
    -- Destroy stopped audio.
    for i,source in pairs(self.temp_sources) do
        if not source:isPlaying() then
            table.remove(self.temp_sources, i)
            source:release()
        end
    end
end

return audio_handler
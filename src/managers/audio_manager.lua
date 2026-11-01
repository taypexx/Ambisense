local asset_handler = game.asset_handler
local audio_group = game.audio.group
local settings = game.settings

---@class audio_manager
local audio_manager = {
    groups = {
        music = audio_group:new("music"),
        sfx = audio_group:new("sfx"),
        voice = audio_group:new("voice"),
        hitsounds = audio_group:new("hitsounds"),
    }
}
audio_manager.__index = audio_manager

function audio_manager:add(group_name, audio)
    local group = self.groups[group_name]
    if not group then game.error(string.format("Audio group \"%s\" does not exist.", group_name)) return end

    group:add(audio)
end

function audio_manager:set_volume(group_name, volume)
    local group = self.groups[group_name]
    if not group then game.error(string.format("Audio group \"%s\" does not exist.", group_name)) return end
    
    group:set_volume(volume)
end

function audio_manager:init()
    for category, volume in pairs(settings.current.audio) do
        category = string.sub(category, 1, -8)
        if self.groups[category] then
            self.groups[category]:set_volume(volume) 
        end
    end

    for category, audios in pairs(asset_handler.audios) do
        for _, audio in pairs(audios) do
            self:add(category, audio) 
        end
    end
end

return audio_manager
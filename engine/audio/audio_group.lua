local object = game.object
local utils = game.utils

local MIN_VOLUME = 0
local MAX_VOLUME = 100

---@class audio_group:object
---@field name string Name of the audio group.
---@field audios table<audio> Table of audio objects in the group.
---@field volume number Volume of the audio group. 0 - fully muted, 100 - full volume.
local audio_group = {
    name = nil,
    volume = nil,
    audios = nil
}
audio_group.__index = audio_group
audio_group.__newindex = utils.get_readonly_func({"name"})

-- Inherits
setmetatable(audio_group, object)

--- Sets the volume of all audios in the group.
---@param volume number Volume to set. 0 - fully muted, 100 - full volume.
function audio_group:set_volume(volume)
    if not volume then game.error("Cannot set volume for audio group: volume was not provided.") return end

    self.volume = utils.clamp(volume, MIN_VOLUME, MAX_VOLUME)
    for _, audio in pairs(self.audios) do
        audio:set_volume(self.volume)
    end
end

--- Adds an audio to the group.
---@param audio audio Audio to add to the group.
function audio_group:add(audio)
    if not audio then game.error("Cannot add audio to the group: audio was not provided.") return end
    if utils.table_find(self.audios, audio) then game.log("Cannot add audio to the group: audio is already in the group.", 1) return end

    table.insert(self.audios, audio)
    audio.group = self
    audio:set_volume(self.volume)
end

--- Removes the audio from the group.
---@param audio audio Audio to remove from the group.
function audio_group:remove(audio)
    if not audio then game.error("Cannot remove audio from the group: audio was not provided.") return end

    local i = utils.table_find(self.audios, audio)
    if not i then game.log("Cannot remove audio from the group: audio is not in the group.", 1) return end

    table.remove(self.audios, i)
    audio.group = nil
end

--- Creates a new audio group.
---@param name string Name of the audio group.
---@param volume number|nil Initial volume of the audio group. 0 - fully muted, 100 - full volume. Default is 50.
---@param audios table<audio>|nil Initial audios to add to the group.
---@return audio_group|nil
function audio_group:new(name, volume, audios)
    if not name then game.error("Cannot create a new audio group: name was not provided.") return end

    local new = setmetatable(object:new(), self)
    new.name = name
    new.volume = utils.clamp(volume or 50, MIN_VOLUME, MAX_VOLUME)
    new.audios = {}

    if audios then
        for _,audio in pairs(audios) do
            new:add(audio)
        end
    end

    return new
end

--- Destroys the audio group.
function audio_group:destroy()
    object.destroy(self)
end

return audio_group
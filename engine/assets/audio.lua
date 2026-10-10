local object = game.types.object
local utils = game.utils

local MIN_VOLUME = 0
local MAX_VOLUME = 100

---@class audio:object
---@field name string Name of the audio.
---@field volume number Volume of the audio. 0 - fully muted, 100 - full volume.
---@field source love.Source Source of the audio.
---@field short boolean Whether the audio is short or not.
---@field group audio_group|nil Audio group of the audio. 
local audio = {
    name = nil,
    volume = nil,
    source = nil,
    short = nil,
    group = nil
}
audio.__index = audio
audio.__newindex = utils.get_readonly_func({"name"})

-- Inherits
setmetatable(audio, object)

--- Plays the audio.
---@param from_start boolean|nil If true plays the audio from the start. Default is true.
function audio:play(from_start)
    if from_start == nil then from_start = true end
    
    if self.short then
        local clone = self.source:clone()
        clone:seek(0)
        clone:play()
        game.audio_handler:add_temp(clone)
    else
        if from_start then
            self.source:seek(0)
        end
        self.source:play()
    end
end

--- Pauses the audio.
function audio:pause()
    self.source:pause()
end

--- Sets the volume of the audio.
---@param volume number Volume of the audio. 0 - fully muted, 100 - full volume.
function audio:set_volume(volume)
    if not volume then game.error("Cannot set the volume of the audio: volume was not provided.") return end
    if self.group and self.group.volume ~= volume then game.log("Cannot set the volume of the audio: Audio is in the group.", 1) return end

    volume = utils.clamp(volume, MIN_VOLUME, MAX_VOLUME)
    self.volume = volume
    self.source:setVolume(volume/100)
end

--- Creates a new audio.
---@param file_path string Path of the audio file.
---@param short boolean|nil Is the audio file short or not. Short audios will be static, longer audios are streamed. Default is true.
---@param volume number|nil Initial volume of the audio. 0 - fully muted, 100 - full volume. Default is 50.
---@param loop boolean|nil If true loops the audio when it ends. Default is false.
---@param group audio_group|nil Initial audio group to assign this audio to.
function audio:new(file_path, short, volume, loop, group)
    if not file_path then game.error("Cannot create a new audio: file_path was not provided.") return end
    if not love.filesystem.getInfo(file_path) then game.error("Cannot create a new audio: file_path is incorrect.") return end

    if short == nil then short = true end
    local source = love.audio.newSource(file_path, (short and "static") or "stream")
    if not source then game.error("Cannot create a new audio: Audio is incorrect.") return end

    local new = setmetatable(object:new(), self)
    new.name = utils.get_file_name(file_path)
    new.volume = utils.clamp(volume or 50, MIN_VOLUME, MAX_VOLUME)
    new.source = source
    new.source:setLooping(loop or false)
    new.short = short

    if group then
        group:add(new)
    end

    return new
end

--- Destroys the audio and its source.
function audio:destroy()
    if self.source then
        self.source:release()
    end
    object.destroy(self)
end

return audio
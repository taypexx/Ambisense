local const = game.const
local utils = game.utils
local map_component = game.world.map_component
local scene_manager = game.scene_manager
local asset_handler = game.asset_handler

local NOTE_OFFSET = 500
local OFFSET_BUFFER = 50

---@class note:map_component
---@field name string Name of the note type.
---@field note_id string BMS ID of the note.
---@field hitsound audio Hitsound of the note.
---@field duration number Amount of seconds between the note spawn and perfect hit.
---@field auto_hit boolean Whether the note is hit automatically.
---@field line integer Line of the note (1,2,3,4 - left, top, right, bottom).
---@field long boolean Whether the note is long (hold).
---@field long_end boolean Whether the note is the end of the other long note.
---@field left number How much time left until the perfect hit.
---@field was_hit boolean True if the note was hit, otherwise false.
local note = {
    name = nil,
    note_id = nil,
    hitsound = nil,
    duration = nil,
    auto_hit = nil,

    line = nil,
    long = nil,
    long_end = nil,

    left = nil,
    was_hit = nil,
    -- judgement based on hit dt
}
note.__index = note

-- Inherits
setmetatable(note, map_component)

function note:hit(dt)
    if not self.long_end and self.hitsound then
        self.hitsound:play()
    end
    self.was_hit = true
end

function note:draw()
    if not self:is_drawing() then return end
    map_component.draw(self)
end

function note:is_drawing()
    return not self.long_end and map_component.is_drawing(self)
end

function note:update(dt)
    self.left = self.left - dt

    -- Update position only if wasn't hit
    if not self.was_hit then
        local x,y = self.x, self.y
    
        if self.line == 1 then
            x = -NOTE_OFFSET / self.duration * self.left - OFFSET_BUFFER
        elseif self.line == 2 then
            y = -NOTE_OFFSET / self.duration * self.left - OFFSET_BUFFER
        elseif self.line == 3 then
            x = NOTE_OFFSET / self.duration * self.left + OFFSET_BUFFER
        elseif self.line == 4 then
            y = NOTE_OFFSET / self.duration * self.left + OFFSET_BUFFER
        end

        self.x = x
        self.y = y
    end
end

function note:new(name, duration, line, long, long_end, auto_hit)
    local note_id = utils.table_find_k(const.note_ids, name)
    if not note_id then game.error(string.format("Failed to create a new note: No note_id exist for the note type \"%s\".", name)) return end

    local hitsound = asset_handler.audios.hitsounds[name]

    local map = scene_manager.controllers["chart"].map
    local x,y = 0,0
    local w,h = const.tile_size, const.tile_size

    local new = setmetatable(map_component:new(map, 2000, x, y, w, h), self)
    new.name = name
    new.note_id = note_id
    new.hitsound = hitsound
    new.duration = duration

    if auto_hit == nil then auto_hit = true end
    new.auto_hit = auto_hit

    new.line = line
    new.long = long or false
    new.long_end = (long and long_end) or false

    new.left = duration
    new.was_hit = false

    return new
end

function note:destroy()
    map_component.destroy(self)
end

return note
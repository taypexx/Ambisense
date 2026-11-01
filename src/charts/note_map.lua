local utils = game.utils
local object = game.object

---@class note_map:object
---@field initial_speed integer Initial speed of the map (1,2,3,4).
---@field notes table<integer, table<number, string>> Dictionary of notes where key is the line and value is the timestamp/note_id table.
local note_map = {
    initial_speed = nil,
    notes = nil,
}
note_map.__index = note_map
note_map.__newindex = utils.readonly_func({"initial_speed", "notes"})

-- Inherits
setmetatable(note_map, object)

function note_map:new(initial_speed, initial_bpm, bms_main)
    local new = setmetatable(object:new(), self)
    new.initial_speed = initial_speed or 1
    new.notes = {}

    -- Parsing the bms main field.
    local beat_length = 60 / initial_bpm
    for measure, lines in pairs(bms_main) do
        local measure_timestamp = measure*4 * beat_length
        for line_id, notes in pairs(lines) do
            if not new.notes[line_id] then
                new.notes[line_id] = {}
            end
            local note_gap = beat_length*4 / #notes
            for i, note_id in pairs(notes) do
                if note_id then
                    local timestamp = measure_timestamp + note_gap*(i-1)
                    new.notes[line_id][timestamp] = note_id
                end
            end
        end
    end

    return new
end

function note_map:destroy()
    object.destroy(self)
end

return note_map
local note = game.notes.note

---@class vignette_start:note
local vignette_start = {
    duration = 0
}
vignette_start.__index = vignette_start

-- Inherits
setmetatable(vignette_start, note)

function vignette_start:new(line, long, long_end)
    local new = setmetatable(note:new("basic1", self.duration, line, long, long_end), self)
    
    return new
end

function vignette_start:destroy()
    note.destroy(self)
end

return vignette_start
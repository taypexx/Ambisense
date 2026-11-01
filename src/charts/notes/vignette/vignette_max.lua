local note = game.notes.note

---@class vignette_max:note
local vignette_max = {
    duration = 0
}
vignette_max.__index = vignette_max

-- Inherits
setmetatable(vignette_max, note)

function vignette_max:new(line, long, long_end)
    local new = setmetatable(note:new("basic1", self.duration, line, long, long_end), self)
    
    return new
end

function vignette_max:destroy()
    note.destroy(self)
end

return vignette_max
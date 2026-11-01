local note = game.notes.note

---@class speed:note
local speed = {
    duration = 0
}
speed.__index = speed

-- Inherits
setmetatable(speed, note)

function speed:new(name, line)
    local new = setmetatable(note:new(name, self.duration, line), self)
    
    return new
end

function speed:destroy()
    note.destroy(self)
end

return speed
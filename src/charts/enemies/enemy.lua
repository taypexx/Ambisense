local object = game.object

---@class enemy:object
---@field bms_id string BMS ID of the note.
---@field long boolean Whether the note is long (hold).
---@field direction integer Direction of the note (1,2,3,4 - left, top, right, bottom)
local enemy = {
    bms_id = nil,
    long = nil,
}
enemy.__index = enemy

setmetatable(enemy, object)

function enemy:new()
    local new = setmetatable(object:new(), self)

    return new
end

function enemy:destroy()
    object.destroy(self)
end

return enemy
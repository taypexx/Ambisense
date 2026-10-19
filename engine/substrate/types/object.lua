local utils = game.utils
local object_handler = game.object_handler

---@class object
---@field object_id integer Unique ID of the object.
local object = {
    object_id = nil
}
object.__index = object
object.__newindex = utils.readonly_func({"object_id"})

--- Creates a new object and registers itself in the object_handler.
---@return object
function object:new()
    local new = setmetatable({}, self)
    object_handler:register(new)
    return new
end

--- Destroys the object. Same as 'game.object_handler:destroy(object)'
function object:destroy()
    object_handler:destroy(self)
end

return object
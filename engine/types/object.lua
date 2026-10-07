---@class object
local object = {
    object_id = nil
}
object.__index = object
object.__newindex = game.utils.get_readonly_func({"object_id"})

--- Creates a new object and registers itself in the object_handler.
---@return object
function object:new()
    local new = setmetatable({}, self)
    game.object_handler:register(new)

    return new
end

--- Same as 'game.object_handler:destroy(object)'
function object:destroy()
    game.object_handler:destroy(self)
end

return object
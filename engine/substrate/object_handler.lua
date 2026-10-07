---@class object_handler
local object_handler = {
    last_id = 0,
    objects = {
        __mode = "v" -- Weak values so that they can be destroyed
    }
}
object_handler.__index = object_handler

--- Registers the new object instance by assigning it an ID and saving its reference inside this handler instance.
--- For internal use only.
---@param object object Object to register.
function object_handler:register(object)
    if object.object_id ~= nil then return end

    self.last_id = self.last_id + 1
    object.object_id = self.last_id

    self.objects[object.object_id] = object
    game.log("Created a new object, ID: "..object.object_id)
end

--- Completly destroys the given object. 
--- For internal use only.
---@param object object Object to destroy.
function object_handler:destroy(object)
    local id = object.object_id
    self.objects[id] = nil
    collectgarbage("collect")
    game.log(string.format("Object %i was destroyed. Is nil: %s", id, tostring(object==nil)))
end

return object_handler
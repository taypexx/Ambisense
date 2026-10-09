local object = game.types.object

---@class event_handle:object
---@field event event The event this handle is attached to.
---@field func function Function that will be called once the event fires.
---@field is_once boolean Will this connection be destroyed once the event fires.
---@field before_args table A table of arguments that will be passed to the function when it fires.
local event_handle = {
    event = nil,
    func = nil,
    is_once = nil,
    before_args = nil
}
event_handle.__index = event_handle

-- Inherits
setmetatable(event_handle, object)

--- Calls the handle function and provides arguments to it.
---@param ... any
function event_handle:fire(...)
    if self.before_args and #self.before_args > 0 then
        self.func(unpack(self.before_args),...)
    else
        self.func(...)
    end

    if self.is_once then
        self:destroy()
    end
end

--- Creates a new event handle.
---@param event event The event this handle will be attached to.
---@param func function Function that will be called once the event fires.
---@param is_once boolean|nil Will this connection be destroyed once the event fires.
---@param ... any Arguments that will be passed to the function when it fires.
---@return event_handle|nil
function event_handle:new(event, func, is_once, ...)
    if not event then game.error("Cannot create an event_handle: event is not provided.") return end
    if not func then game.error("Cannot create an event_handle: func is not provided.") return end

    local new = setmetatable(object:new(), self)
    new.event = event
    new.func = func
    new.is_once = is_once or false
    
    if select("#",...) > 0 then
        new.before_args = {...}
    end

    return new
end

--- Destroys the handle and removes itself from the event handles.
function event_handle:destroy()
    local i = game.utils.table_find(self.event.handles, self)
    if i then
        table.remove(self.event.handles, self)
    end
    object.destroy(self)
end

return event_handle
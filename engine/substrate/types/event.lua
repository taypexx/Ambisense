local object = game.object
local event_handle = game.event_handle

---@class event:object
---@field handles table<event_handle> A table of functions to be called when the event gets fired.
local event = {
    handles = {}
}
event.__index = event

-- Inherits
setmetatable(event, object)

--- Fires the event and calls all its handle functions.
--- @param ... any|nil Arguments to be provided to the handles.
function event:fire(...)
    for _,handle in pairs(self.handles) do
        handle:fire(...)
    end
end

--- Subscribes the function to the event.
--- Once it gets fired, it gets immediately unsubscribed.
---@param func function A function to subcribe.
---@param ... any Arguments to provide before the event arguments.
---@return event_handle
function event:sub_once(func, ...)
    local handle = event_handle:new(self, func, true, ...)
    table.insert(self.handles, handle)
    return handle
end

--- Subcribes the function to the event.
--- Will be called every time the event fires.
---@param func function A function to subcribe.
---@param ... any Arguments to provide before the event arguments.
---@return event_handle
function event:sub(func, ...)
    local handle = event_handle:new(self, func, false, ...)
    table.insert(self.handles, handle)
    return handle
end

--- Creates a new event.
---@return event
function event:new()
    local new = setmetatable(object:new(), self)
    new.handles = {}
    
    return new
end

return event
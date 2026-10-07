---@class event
---@field funcs table A table of functions to be called when the event gets fired.
---@field once_funcs table A table of functions that will be unsubscribed once they are called.
local event = {
    funcs = nil,
    once_funcs = nil
}
event.__index = event

--- Fires the event and calls all its functions.
--- @param ... any|nil Arguments to be provided to the functions.
function event:fire(...)
    for _,func in ipairs(self.funcs) do
        local once_i = game.utils.table_find(self.once_funcs, func)
        if once_i then
            table.remove(self.once_funcs, once_i)
            self:unsub(func)
        end
        func(...)
    end
end

--- Subscribes the function to the event.
--- Once it gets fired, it gets immediately unsubscribed.
---@param func function
function event:sub_once(func)
    table.insert(self.once_funcs, func)
    self:sub(func)
end

--- Subcribes the function to the event.
--- Will be called every time the event fires.
---@param func function A function to subcribe.
function event:sub(func)
    table.insert(self.funcs, func)
end

--- Unsubcribes the function from the event.
--- Returns true if the given function was subscribed, false if not.
--- The function won't be called after that.
---@param func function A function to subcribe.
---@return boolean
function event:unsub(func)
    local i = game.utils.table_find(self.funcs, func)
    local found = i~=nil
    if found then
        table.remove(self.funcs, i)
    end

    return found
end

--- Creates a new event.
---@return event
function event:new()
    local new = setmetatable({
        funcs = {},
        once_funcs = {}
    }, self)
    
    return new
end

return event
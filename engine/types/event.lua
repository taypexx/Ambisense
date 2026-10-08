---@class event:object
---@field funcs table<function> A table of functions to be called when the event gets fired.
---@field once_funcs table<function> A table of functions that will be unsubscribed once they are called.
---@field before_args table<function,table> A dictionary with keys being subscribed functions and values being tables containing their additional argumnents that get passed before the event arguments.
local event = {
    funcs = nil,
    once_funcs = nil,
    before_args = nil
}
event.__index = event

--- Fires the event and calls all its functions.
--- @param ... any|nil Arguments to be provided to the functions.
function event:fire(...)
    for _,func in pairs(self.funcs) do
        local once_i = game.utils.table_find(self.once_funcs, func)
        if once_i then
            table.remove(self.once_funcs, once_i)
            self:unsub(func)
        end
        
        local before_args = self.before_args[func]
        if before_args then
            func(unpack(before_args),...)
        else
            func(...)
        end
    end
end

--- Subscribes the function to the event.
--- Once it gets fired, it gets immediately unsubscribed.
---@param func function A function to subcribe.
---@param ... any Arguments to provide before the event arguments.
function event:sub_once(func, ...)
    table.insert(self.once_funcs, func)
    self:sub(func, ...)
end

--- Subcribes the function to the event.
--- Will be called every time the event fires.
---@param func function A function to subcribe.
---@param ... any Arguments to provide before the event arguments.
function event:sub(func, ...)
    table.insert(self.funcs, func)
    if select("#", ...) > 0 then
        self.before_args[func] = {...}
    end
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
        if self.before_args[func] then
            self.before_args[func] = nil
        end
    end

    return found
end

--- Creates a new event.
---@return event
function event:new()
    local new = setmetatable({
        funcs = {},
        once_funcs = {},
        before_args = {}
    }, self)
    
    return new
end

return event
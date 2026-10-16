local object = game.types.object
local utils = game.utils

---@class tween_task:object
---@field table table Table containing a number value.
---@field key any Key of the value.
---@field value_start number The value to start with.
---@field value_end number The end value to reach.
---@field time_start number Start time of the tween.
---@field time_end number End time of the tween.
---@field end_func function Function to execute after the tween completion.
local tween_task = {
    table = nil,
    key = nil,
    value_start = nil,
    value_end = nil,
    time_start = nil,
    time_end = nil,
    func = nil,
    end_func = nil
}
tween_task.__index = tween_task

-- Inherits
setmetatable(tween_task, object)

--- Updates the value of the table.
function tween_task:update()
    if not self.table[self.key] then self:destroy() end

    if love.timer.getTime() < self.time_end then
        self.table[self.key] = self.func(self.value_start, self.value_end, self.time_start, self.time_end)
    else
        self.table[self.key] = self.value_end
        if self.end_func then
            self.end_func()
        end
        self:destroy()
    end
end

--- Creates a new tween task.
---@param t table Table containing a number value.
---@param key any Key of the value.
---@param value number The end value to reach.
---@param duration number Duration of the tween in seconds.
---@param func function Function to use for tweening. Must accept 4 values as arguments: value_start, value_end, time_start and time_end. Returns the tweened number.
---@param end_func function|nil Function to execute after the tween completion.
---@return tween_task|nil
function tween_task:new(t, key, value, duration, func, end_func)
    if not (t and key and value and duration and func) then game.error("Cannot create a new tween task: One of the parameters was not provided.") return end
    if type(t[key]) ~= "number" then game.error("Cannot create a new tween task: table value is not a number.") return end

    local new = setmetatable(object:new(), tween_task)
    new.table = t
    new.key = key
    new.value_start = t[key]
    new.value_end = value
    new.time_start = love.timer.getTime()
    new.time_end = new.time_start + duration
    new.func = func
    new.end_func = end_func

    return new
end

--- Destroys the tween tasks and removes itself from the tween tasks.
function tween_task:destroy()
    local i = utils.table_find(game.tween.tasks, self)
    if i then
        table.remove(game.tween.tasks, i)
    end
    object.destroy(self)
end

return tween_task
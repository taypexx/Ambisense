local utils = game.utils

---@class tween
---@field tasks table<tween_task> All tasks in progress.
---@field funcs table<string,function> Tweening functions table where key is the name of the function and value is the function itself.
local tween = {
    tasks = {},
    funcs = {
        ["linear"] = function (v1, v2, t1, t2)
            return v1 + (v2 - v1) / (t2 - t1) * (love.timer.getTime() - t1)
        end,
        ["sine"] = function (v1, v2, t1, t2)
            return v1 + (v2 - v1) * math.sin(math.pi/2 / (t2 - t1) * (love.timer.getTime() - t1))
        end
    }
}
tween.__index = tween
tween.__newindex = utils.readonly_func({"tasks", "funcs"})

--- Tweens the number value in the table.
---@param t table Table containing a number value.
---@param key any Key of the value.
---@param value number The end value to reach.
---@param duration number Duration of the tween in seconds.
---@param easing string|nil Easing name.
---@param end_func function|nil Function to execute after the tween completion.
function tween:start(t, key, value, duration, easing, end_func)
    if not (t and key and value and duration) then game.error("Cannot tween: One of the parameters was not provided.") return end

    local func = (easing and self.funcs[easing]) or self.funcs["linear"]
    local task = game.tween_task:new(t, key, value, duration, func, end_func)
    table.insert(self.tasks, task)
end

--- Updates all current tween tasks.
function tween:update()
    for _,tween_task in pairs(self.tasks) do
        tween_task:update()
    end
end

return tween
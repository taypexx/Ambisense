local event = require("engine.types.event")

---@class mouse
---@field current_cursor cursor The current cursor that is being rendered on the screen.
---@field cursor_visible boolean Visibility of the cursor. True is visible, false is hidden.
---@field on_left_down event Fires when the left mouse button is pressed. Arguments: x:integer - X coordinate of the mouse press. y:integer - Y coordinate of the mouse press.
---@field on_right_down event Fires when the right mouse button is pressed. Arguments: x:integer - X coordinate of the mouse press. y:integer - Y coordinate of the mouse press.
---@field on_left_up event Fires when the left mouse button is released. Arguments: x:integer - X coordinate of the mouse release. y:integer - Y coordinate of the mouse release.
---@field on_right_up event Fires when the right mouse button is released. Arguments: x:integer - X coordinate of the mouse release. y:integer - Y coordinate of the mouse release.
---@field on_wheel_move event Fires when the mouse wheel moves. Arguments: y:integer - The amount of pixels the mouse has scrolled.
local mouse = {
    current_cursor = nil,
    cursor_visible = true,

    getX = love.mouse.getX,
    getY = love.mouse.getY,

    on_left_down = event:new(),
    on_left_up = event:new(),

    on_right_down = event:new(),
    on_right_up = event:new(),

    on_wheel_move = event:new(),
}
mouse.__index = mouse
mouse.__newindex = game.utils.get_readonly_func({"on_left_down", "on_left_up", "on_right_down", "on_right_up", "on_wheel_move"})

function love.mousepressed(x, y, button)
    if button == 1 then
        mouse.on_left_down:fire(x,y)
    elseif button == 2  then
        mouse.on_right_down:fire(x,y)
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        mouse.on_left_up:fire(x,y)
    elseif button == 2  then
        mouse.on_right_up:fire(x,y)
    end
end

function love.wheelmoved(x, y)
    mouse.on_wheel_move:fire(y)
end

return mouse
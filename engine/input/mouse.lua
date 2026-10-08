local event = game.types.event

---@class mouse
---@field cursors table<string,cursor> All cached cursors. Key is the cursor name.
---@field current_cursor cursor The current cursor that is being rendered on the screen.
---@field cursor_visible boolean Visibility of the cursor. True is visible, false is hidden.
---@field current_ui_element ui_element Current UI element that the mouse is pointing at.
---@field on_left_down event Fires when the left mouse button is pressed. Arguments: x:integer| y:integer.
---@field on_right_down event Fires when the right mouse button is pressed. Arguments: x:integer | y:integer.
---@field on_left_up event Fires when the left mouse button is released. Arguments: x:integer | y:integer.
---@field on_right_up event Fires when the right mouse button is released. Arguments: x:integer | y:integer.
---@field on_move event Fires when the mouse moves. Arguments: x:integer | y:integer | dx:integer - how many pixels has the mouse moved horizontally | dy - how many pixels has the mouse moved vertically.
---@field on_wheel_move event Fires when the mouse wheel moves. Arguments: y:integer - The amount of pixels the mouse has scrolled.
local mouse = {
    cursors = {},
    current_cursor = nil,
    cursor_visible = true,

    current_ui_element = nil,

    on_left_down = event:new(),
    on_left_up = event:new(),

    on_right_down = event:new(),
    on_right_up = event:new(),

    on_move = event:new(),
    on_wheel_move = event:new()
}
mouse.__index = mouse
mouse.__newindex = game.utils.get_readonly_func({"on_left_down", "on_left_up", "on_right_down", "on_right_up", "on_wheel_move"})

function mouse:getX() return love.mouse.getX() end
function mouse:getY() return love.mouse.getY() end

--- Finds the cursor by its name and sets it as the current one.
---@param name string Name of the cursor.
function mouse:set_cursor(name)
    local cursor = self.cursors[name]

    if not cursor then game.error(string.format("Cannot set the cursor: cursor %s not found.", name)) return end
    self.current_cursor = cursor
end

--- Loads all cursors from assets/sprites/cursors
function mouse:load_cursors()
    for _,cursor in pairs(self.cursors) do
        cursor:destroy()
    end

    self.cursors = {}

    for _,cursor_file_name in pairs(love.filesystem.getDirectoryItems("assets/sprites/cursors")) do
        local cursor = game.input.cursor:new(cursor_file_name)
        if cursor then
            self.cursors[cursor.name] = cursor
        end
    end
end

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

function love.mousemoved(x,y,dx,dy)
    mouse.on_move:fire(x,y,dx,dy)
end

function love.wheelmoved(x, y)
    mouse.on_wheel_move:fire(y)
end

return mouse
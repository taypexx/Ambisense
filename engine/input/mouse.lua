local event = game.event
local utils = game.utils
local asset_handler = game.asset_handler
local camera = game.world.camera

---@class mouse
---@field cursors table<string,cursor> All cached cursors. Key is the cursor name.
---@field current_cursor cursor The current cursor that is being rendered on the screen.
---@field cursor_visible boolean Visibility of the cursor. True is visible, false is hidden.
---@field current_component scene_component Current scene component that the mouse is pointing at.
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

    current_component = nil,

    on_left_down = event:new(),
    on_left_up = event:new(),

    on_right_down = event:new(),
    on_right_up = event:new(),

    on_move = event:new(),
    on_wheel_move = event:new()
}
mouse.__index = mouse
mouse.__newindex = utils.readonly_func({"on_left_down", "on_left_up", "on_right_down", "on_right_up", "on_wheel_move"})

--- Gets the current world coordinates at the mouse position.
---@return number wx
---@return number wy
function mouse:get_world_pos()
    return camera:get_world_pos(self:get_pos())
end

--- Gets the current screen positon of the mouse in pixels.
---@return number X
---@return number Y
function mouse:get_pos() 
    return love.mouse.getX(), love.mouse.getY()
end

--- Finds the cursor by its name and sets it as the current one.
---@param name string Name of the cursor.
function mouse:set_cursor(name)
    local cursor = self.cursors[name]

    if not cursor then game.error(string.format("Cannot set the cursor: cursor %s not found.", name)) return end
    self.current_cursor = cursor
end

--- Loads all cursors from assets/sprites/cursors
function mouse:load_cursors()
    if not asset_handler.sprites.cursors then game.error("Cannot load cursors: Cursor sprites are not loaded.") return end

    for _,cursor in pairs(self.cursors) do
        cursor:destroy()
    end
    self.cursors = {}

    for _,sprite in pairs(asset_handler.sprites.cursors) do
        local cursor = game.input.cursor:new(sprite)
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
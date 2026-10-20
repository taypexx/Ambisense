local utils = game.utils
local event = game.event
local mouse = game.input.mouse

---@class scene_handler
---@field last_id integer The ID of the last created scene.
---@field scenes table<integer,scene> A dictionary of scenes where ID is the key. Scenes can also be indexed by their name.
---@field currentScene scene|nil Current scene that is being rendered on screen.
---@field on_scene_switched event Fires when the current scene switches. Arguments: new_scene, old_scene - self explanatory.
local scene_handler = {
    last_id = 0,
    currentScene = nil,
    scenes = setmetatable({}, {__index = function(t,k)
        for id,scene in pairs(t) do
            if scene and (k == id or k == scene.name) then
                return scene
            end
        end
    end}),

    on_scene_switched = event:new()
}
scene_handler.__index = scene_handler

--- Gets the top most component at the given position or nil if there are none.
---@param x integer X coordinate to look for the component.
---@param y integer Y coordinate to look for the component.
---@return scene_component|nil
function scene_handler:get_top_component(x,y)
    if not self.currentScene then return end

    return utils.iterate(self.currentScene.components, true, function (layer, components)
        for _,component in pairs(components) do
            if component.x and component:does_overlap(x,y) then
                return component
            end
        end
    end)
end

--- Fires element enter/leave events based on the current mouse position.
function scene_handler:process_mouse_position(x,y,dx,dy)
    local elem = self:get_top_component(x,y)
    local prev_elem = self:get_top_component(x-dx,y-dy)
    if elem == prev_elem then return end

    if elem then
        mouse.current_component = elem
        if elem.on_mouse_enter then
           elem.on_mouse_enter:fire() 
        end
    else
        mouse.current_component = nil
    end
    if prev_elem and prev_elem.on_mouse_leave then
        prev_elem.on_mouse_leave:fire()
    end
end

--- Fires on_mouse_down event on elements based on their position.
function scene_handler:process_mouse_down(x,y)
    local elem = self:get_top_component(x,y)
    if not (elem and elem.on_mouse_down) then return end
    elem.on_mouse_down:fire(x,y)
end

--- Fires on_mouse_up event on elements based on their position.
function scene_handler:process_mouse_up(x,y)
    local elem = self:get_top_component(x,y)
    if not (elem and elem.on_mouse_up) then return end
    elem.on_mouse_up:fire(x,y)
end

--- Switches the current scene to the given one and changes their active values.
--- After switching the game will start rendering it.
---@param scene scene|nil
function scene_handler:switch_scene(scene)
    local old_scene = self.currentScene
    if old_scene then
        old_scene.active = false
        old_scene.on_unload:fire()
    end

    self.currentScene = scene
    
    if scene then
        scene.active = true
        scene.on_load:fire()
    end

    self.on_scene_switched:fire(scene, old_scene)
end

--- Registers a new scene.
--- For internal use only.
---@param scene scene Scene to register.
function scene_handler:register_scene(scene)
    if not scene then game.error("Cannot register a new scene: Scene was not provided.") return end
    if scene.scene_id ~= nil then game.error("Cannot register a new scene: scene_id is already assigned.") return end

    self.last_id = self.last_id + 1
    scene.scene_id = self.last_id

    self.scenes[scene.scene_id] = scene

    game.log("Registered a new scene, scene_id: "..scene.scene_id)
end

--- Draws the current scene.
function scene_handler:draw()
    -- Draw the scene components
    if self.currentScene then
        utils.iterate(self.currentScene.components, false, function (layer, components)
            for _,component in pairs(components) do
                component:draw()
            end
        end)
    else
        love.graphics.print("Loading...", love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    end

    -- Draw the cursor
    local cursor = mouse.current_cursor
    if love.window.hasMouseFocus() and cursor and mouse.cursor_visible then
        love.graphics.draw(cursor.sprite.image, mouse:get_pos())
    end
end

-- Initializes graphics.
function scene_handler:init()
    -- Mouse and cursor setup
    love.mouse.setVisible(false)

    mouse:load_cursors()
    mouse:set_cursor("default")

    mouse.on_move:sub(self.process_mouse_position, self)
    mouse.on_left_down:sub(self.process_mouse_down, self)
    mouse.on_left_up:sub(self.process_mouse_up, self)
end

return scene_handler
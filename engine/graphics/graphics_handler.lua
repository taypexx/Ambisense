local utils = game.utils

---@class graphics_handler
---@field last_id integer The ID of the last created scene.
---@field scenes table<integer,scene> A dictionary of scenes where ID is the key.
---@field scenesByName table<string,scene> A dictionary of scenes where name is the key.
---@field currentScene scene|nil Current scene that is being rendered on screen.
local graphics_handler = {
    last_id = 0,
    scenes = {},
    scenesByName = {},
    currentScene = nil
}
graphics_handler.__index = graphics_handler

--- Gets the top most component at the given position or nil if there are none.
---@param x integer X coordinate to look for the component.
---@param y integer Y coordinate to look for the component.
---@return scene_component|nil
function graphics_handler:get_top_component(x,y)
    if not self.currentScene then return end

    return utils.iterate(self.currentScene.components, true, function (layer, components)
        for _,component in pairs(components) do
            if component:does_overlap(x,y) then
                return component
            end
        end
    end)
end

--- Fires element enter/leave events based on the current mouse position.
function graphics_handler:process_mouse_position(x,y,dx,dy)
    local elem = self:get_top_component(x,y)
    local prev_elem = self:get_top_component(x-dx,y-dy)
    if elem == prev_elem then return end

    if elem and elem.on_mouse_enter then
        game.mouse.current_component = elem
        elem.on_mouse_enter:fire()
    elseif elem == nil then
        game.mouse.current_component = nil
    end
    if prev_elem and prev_elem.on_mouse_leave then
        prev_elem.on_mouse_leave:fire()
    end
end

--- Fires on_mouse_down event on elements based on their position.
function graphics_handler:process_mouse_down(x,y)
    local elem = self:get_top_component(x,y)
    if not (elem and elem.on_mouse_down) then return end
    elem.on_mouse_down:fire(x,y)
end

--- Fires on_mouse_up event on elements based on their position.
function graphics_handler:process_mouse_up(x,y)
    local elem = self:get_top_component(x,y)
    if not (elem and elem.on_mouse_up) then return end
    elem.on_mouse_up:fire(x,y)
end

--- Switches the current scene to the given one.
--- After switching the game will start rendering it.
---@param scene scene|nil
function graphics_handler:switch_scene(scene)
    self.currentScene = scene
end

--- Registers a new scene.
--- For internal use only.
---@param scene scene Scene to register.
function graphics_handler:register_scene(scene)
    if not scene then game.error("Cannot register a new scene: Scene was not provided.") return end
    if scene.scene_id ~= nil then game.error("Cannot register a new scene: scene_id is already assigned.") return end

    self.last_id = self.last_id + 1
    scene.scene_id = self.last_id

    self.scenes[scene.scene_id] = scene
    self.scenesByName[scene.name] = scene

    game.log("Registered a new scene, scene_id: "..scene.scene_id)
end

local pop = false
--- Draws the current scene.
function graphics_handler:draw()
    -- Draw the scene components
    if self.currentScene then
        -- Apply camera for the 0-999 layer components (map and its objects)
        pop = false
        love.graphics.push()
        love.graphics.translate(game.world.camera.x, game.world.camera.y)
        love.graphics.scale(game.world.camera.scale, game.world.camera.scale)

        utils.iterate(self.currentScene.components, false, function (layer, components)
            -- Return to normal screen pixel coordinates when drawing interface on layers 1000+.
            if not pop and layer >= 1000 then
                love.graphics.pop()
                pop = true
            end

            for _,component in pairs(components) do
                component:draw()
            end
        end)

        if not pop then love.graphics.pop() end
    else
        love.graphics.print("Loading...", love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    end

    -- Draw the cursor
    local mouse = game.mouse
    local cursor = mouse.current_cursor
    if love.window.hasMouseFocus() and cursor and mouse.cursor_visible then
        love.graphics.draw(cursor.sprite.image, mouse:getX(), mouse:getY())
    end
end

function graphics_handler:init()
    -- Mouse and cursor setup
    love.mouse.setVisible(false)
    
    local mouse = game.mouse
    mouse:load_cursors()
    mouse:set_cursor("default")

    mouse.on_move:sub(self.process_mouse_position, self)
    mouse.on_left_down:sub(self.process_mouse_down, self)
    mouse.on_left_up:sub(self.process_mouse_up, self)
end

return graphics_handler
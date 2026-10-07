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

--- Draws the current scene.
function graphics_handler:draw()
    -- Draw the scene components first
    if self.currentScene then
        for layer,components in pairs(self.currentScene.components) do
            for _,component in pairs(components) do
                component:draw()
            end
        end
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
    -- Cursor setup
    love.mouse.setVisible(false)
    game.mouse:load_cursors()
    game.mouse:set_cursor("default")
end

return graphics_handler
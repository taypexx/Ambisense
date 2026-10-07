---@class graphics_handler
---@field last_id integer The ID of the last created scene.
---@field scenes table A dictionary of scenes where ID (integer) is the key.
---@field scenesByName table A dictionary of scenes where name (string) is the key.
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

    game.log("Registered a new scene, ID: "..scene.scene_id)
end

--- Draws the current scene.
function graphics_handler:draw()
    if self.currentScene then
        for _,component in ipairs(self.currentScene.components) do
            component:draw()
        end
    else
        love.graphics.print("Loading...", love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    end
end

return graphics_handler
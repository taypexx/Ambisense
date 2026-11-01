local scene_handler = game.scene.handler

---@class scene_manager
---@field current scene_controller Current scene controller. Scene may be still loading, check scene_manager.loaded.
---@field loaded boolean Whether the current scene has finished loading.
---@field scene_controllers table<string,scene_controller> Dictionary of all scene controllers where key is the scene name and value is the controller.
local scene_manager = {
    current = nil,
    loaded = false,
    controllers = {},
}
scene_manager.__index = scene_manager

--- Switches the current scene and passes argument to the controller.
---@param scene_name string Name of the scene to switch to.
---@param ... any|nil Arguments to pass to the loading function of the scene controller.
function scene_manager:switch(scene_name, ...)
    if scene_name == "loading" then game.error("Cannot switch to the loading scene.") return end

    local controller = self.controllers[scene_name]
    if not controller then game.error("Unknown scene "..scene_name) return end

    if self.current and self.current.unload then
        self.current:unload()
    end

    self.current = controller
    
    if controller.load then
        self.loaded = false

        self.controllers.loading:load(controller)
        scene_handler:switch_scene(self.controllers.loading.scene)
        
        controller:load(...)
        self.loaded = true
    end
    scene_handler:switch_scene(controller.scene)
end

function scene_manager:init()
    self.controllers = {
        loading = require("src.scenes.loading_scene"):new(),
        chart = require("src.scenes.chart_scene"):new()
    }
end

return scene_manager
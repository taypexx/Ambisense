local utils = game.utils
local object = game.object
local scene = game.scene.scene

---@class scene_controller:object
---@field name string Same as scene_controller.scene.name.
---@field scene scene Scene of the controller.
local scene_controller = {
    name = nil,
    scene = nil,
}
scene_controller.__index = scene_controller
scene_controller.__newindex = utils.readonly_func({"name", "scene"})

-- Inherits
setmetatable(scene_controller, object)

--- Creates a new scene controller.
---@param scene_name string Name of the scene to create.
function scene_controller:new(scene_name)
    local new = setmetatable(object:new(), self)
    new.name = scene_name
    new.scene = scene:new(scene_name)

    return new
end

function scene_controller:destroy()
    if self.scene then
        self.scene:destroy()
    end
    object.destroy(self)
end

return scene_controller
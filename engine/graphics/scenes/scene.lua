local object = require("engine.types.object")

---@class scene
---@field scene_id integer Unique ID of the scene.
---@field name string Unique name of the scene.
---@field components table A table of all scene_components of the scene.
local scene = {
    scene_id = nil,
    name = nil,
    components = nil
}
scene.__index = scene
scene.__newindex = game.utils.get_readonly_func({"scene_id", "name"})

-- Inherits
setmetatable(scene, object)

--- Creates a new scene.
---@param name string|nil Name of the scene.
---@return scene|nil
function scene:new(name)
    if game.graphics_handler.scenesByName[name] then
        game.error("Cannot create new scene: Scene with the same name already exists!")
        return
    end

    local new = setmetatable(object:new(), self)
    new.name = name or "scene"
    new.components = {}
    
    game.graphics_handler:register_scene(new)
    return new
end

return scene
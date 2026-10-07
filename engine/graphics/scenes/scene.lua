local object = require("engine.types.object")

---@class scene
local scene = {
    scene_id = nil,
    name = nil
}
scene.__index = scene
scene.__newindex = game.utils.get_readonly_func({"scene_id", "name"})

-- Inherits
setmetatable(scene, { __index = object })

--- Creates a new scene.
---@param name string Name of the scene.
---@return scene
function scene:new(name)
    local new = setmetatable(object.new(self), self)
    new.name = name or "Scene"
    
    game.graphics:registerScene(new)
    return new
end

return scene
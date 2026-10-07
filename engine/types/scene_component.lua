local object = require("engine.types.object")

---@class scene_component
---@field scene scene Scene of the component.
local scene_component = {
    scene = nil
}
scene_component.__index = scene_component
scene_component.__newindex = game.utils.get_readonly_func({"scene"})

-- Inherits
setmetatable(scene_component, object)

--- Creates a new scene component.
---@param scene scene Scene to add this component to.
---@return scene_component|nil
function scene_component:new(scene)
    if not scene then game.error("Cannot create a new scene component: scene was not provided.") return end

    local new = setmetatable(object:new(), self)
    new.scene = scene
    scene:add_component(new)

    return new
end

return scene_component
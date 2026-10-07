local object = require("engine.types.object")

---@class scene_component
local scene_component = {}
scene_component.__index = scene_component

-- Inherits
setmetatable(scene_component, object)

--- Creates a new scene component.
---@return scene_component
function scene_component:new()
    local new = setmetatable(object:new(), self)
    
    return new
end

return scene_component
local scene_controller = game.scene_controller

---@class chart_scene:scene_controller
local chart_scene = {}
chart_scene.__index = chart_scene

-- Inherits
setmetatable(chart_scene, scene_controller)

function chart_scene:init()
    
end

function chart_scene:loading(other_scene)
    
end

function chart_scene:unloading()
    
end

function chart_scene:new()
    local new = setmetatable(scene_controller:new("chart"), self)
    new:init()

    return new
end

return chart_scene
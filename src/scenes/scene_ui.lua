local utils = game.utils
local object = game.object

---@class scene_ui:object
---@field scene scene Scene of the UI.
---@field controller scene_controller Controller that holds the UI.
local scene_ui = {
    scene = nil,
    controller = nil,
}
scene_ui.__index = scene_ui
scene_ui.__newindex = utils.readonly_func({"controller"})

-- Inherits
setmetatable(scene_ui, object)

function scene_ui:update(dt)
end

function scene_ui:load()
end

function scene_ui:unload()
end

function scene_ui:init()
end

--- Creates a holder for scene UI.
---@return scene_ui|nil
function scene_ui:new()
    local new = setmetatable(object:new(), self)
    return new
end

return scene_ui
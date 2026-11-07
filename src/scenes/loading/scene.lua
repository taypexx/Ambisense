local scene_controller = game.scene_controller

---@class loading_scene:scene_controller
---@field ui loading_ui
---@field loading_texts table<string,string>
---@field tips table<string>
---@field elements table<string,ui_element>
local loading_scene = {
    elements = {},
    loading_texts = {
        default = " Loading...",
        chart = " Loading the chart..."
    },
    tips = {
        "Tip text 1",
        "Tip text 2",
        "Tip text 3"
    }
}
loading_scene.__index = loading_scene

-- Inherits
setmetatable(loading_scene, scene_controller)

function loading_scene:update(dt)
    self.ui:update(dt)
end

function loading_scene:load(other_scene)
    local loading_text = (other_scene and self.loading_texts[other_scene.name]) or self.loading_texts.default
    local tip_text = self.tips[math.random(1,#self.tips)]

    self.ui:load(loading_text, tip_text)
end

function loading_scene:unload()
    self.ui:unload()
end

function loading_scene:init()
    self.ui:init()
end

function loading_scene:new()
    local new = setmetatable(scene_controller:new("loading"), self)
    return new
end

return loading_scene
local scene_controller = game.scene_controller
local ui = game.scene.ui

local font = game.asset_handler:get_font("pixeloid", 28)
local font_bold = game.asset_handler:get_font("pixeloid_bold", 32)

---@class loading_scene:scene_controller
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

function loading_scene:load(other_scene)
    local loading_text = (other_scene and self.loading_texts[other_scene.name]) or self.loading_texts.default
    self.elements.loading_text.text = loading_text

    self.elements.tip_text.text = self.tips[math.random(1,#self.tips)]

    -- TODO: Add jumping enemies at the bottom of the screen while loading
end

function loading_scene:unload()
    
end

function loading_scene:init()
    self.elements = {
        loading_text = ui.text_label:new(
            self.scene, font_bold,
            self.loading_texts.default,
            {1, 1, 1, 1}, {0, 0, 0, 0}, "center", 1010,
            0.3, 0.45,
            0.4, 0.1
        ),
        tip_text = ui.text_label:new(
            self.scene, font,
            "Tip",
            {0.8, 0.8, 0.8, 1}, {0, 0, 0, 0}, "center", 1010,
            0.1, 0.55,
            0.8, 0.1
        )
    }
end

function loading_scene:new()
    local new = setmetatable(scene_controller:new("loading"), self)
    new:init()

    return new
end

return loading_scene
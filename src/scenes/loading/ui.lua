local scene_ui = game.scene_ui

local ui_element = game.scene.ui.element
local text_label = game.scene.ui.text_label
local image_label = game.scene.ui.image_label

local font = game.asset_handler.fonts.pixeloid
local font_bold = game.asset_handler.fonts.pixeloid_bold

---@class loading_ui:scene_ui
local loading_ui = {}
loading_ui.__index = loading_ui

-- Inherits
setmetatable(loading_ui, scene_ui)

function loading_ui:update(dt)
end

function loading_ui:load(loading_text, tip_text)
    self.loading_text.text = loading_text
    self.tip_text.text = tip_text

    -- TODO: Add jumping enemies at the bottom of the screen while loading
end

function loading_ui:unload()
end

function loading_ui:init()
    self.loading_text = text_label:new(
        self.scene, 1010, font_bold,
        "...", "center",
        {1, 1, 1, 1}, {0, 0, 0, 0},
        0.3, 0.45,
        0.4, 0.1
    )
    self.tip_text = text_label:new(
        self.scene, 1010, font,
        "Tip", "center",
        {0.8, 0.8, 0.8, 1}, {0, 0, 0, 0},
        0.1, 0.55,
        0.8, 0.1
    )
end

function loading_ui:new()
    local new = setmetatable(scene_ui:new(), self)
    return new
end

return loading_ui
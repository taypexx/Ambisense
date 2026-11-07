local scene_ui = game.scene_ui

local ui_element = game.scene.ui.element
local text_label = game.scene.ui.text_label
local image_label = game.scene.ui.image_label

local font = game.asset_handler.fonts.pixeloid
local font_bold = game.asset_handler.fonts.pixeloid_bold

---@class chart_ui:scene_ui
local chart_ui = {}
chart_ui.__index = chart_ui

-- Inherits
setmetatable(chart_ui, scene_ui)

function chart_ui:update(dt)
end

function chart_ui:load()
    local chart = self.controller.current_chart
    
    self.cover_image.sprite = chart.cover
    self.info_text.text = chart.name
end

function chart_ui:unload()
end

function chart_ui:init()
    self.info_frame = ui_element:new(self.scene, 5000,
        0.7, 0,
        0.3, 0.2,
        {0,0,0,0.5}
    )
    self.combo_frame = ui_element:new(self.scene, 5000,
        0.4, 0,
        0.2, 0.2,
        {0,0,0,0.5}
    )
    self.stats_frame = ui_element:new(self.scene, 5000,
        0, 0,
        0.2, 0.2,
        {0,0,0,0.5}
    )

    self.cover_image = image_label:new(self.info_frame, 5001,
        nil, "fit",
        0.65, 0,
        0.3, 1
    )
    self.info_text = text_label:new(self.info_frame, 5001, font_bold,
        "Chart", "left",
        {1,1,1,1},
        {0,0,0,0},
        0.05, 0.05,
        0.55, 0.3
    )
    self.info_text2 = nil

    self.combo_text = nil
    self.combo_count = nil

    self.stats_text = nil

    require("src.debug_menu")(self.scene)
end

function chart_ui:new()
    local new = setmetatable(scene_ui:new(), self)
    return new
end

return chart_ui
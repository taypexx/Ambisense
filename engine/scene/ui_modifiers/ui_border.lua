local utils = game.utils
local ui_modifier = game.scene.ui_modifiers.ui_modifier

---@class ui_border:ui_modifier
---@field ui_element ui_element UI element that this border will apply to.
---@field thickness integer Thickness of the border in pixels. Default is 1.
---@field color table<number> Сolor of the border. Table of type {r,g,b} where r,g and b are numbers from 0 to 1. Default is {0,0,0}
---@field opacity number Opacity where 0 - invisible, 1 - fully visible. Default is 1.
local ui_border = {
    ui_element = nil,
    thickness = nil,
    out = nil,
    color = nil,
    opacity = nil
}
ui_border.__index = ui_border

-- Inherits
setmetatable(ui_border, ui_modifier)

--- Draws the border around the UI element.
function ui_border:draw()
    local ox,oy = self.ui_element:get_position()
    local ow,oh = self.ui_element:get_size()

    utils.set_color(self.color, self.opacity)
    if self.out then
        love.graphics.rectangle("fill", ox - self.thickness, oy - self.thickness, ow + self.thickness * 2, self.thickness)
        love.graphics.rectangle("fill", ox - self.thickness, oy + oh, ow + self.thickness * 2, self.thickness)

        love.graphics.rectangle("fill", ox - self.thickness, oy, self.thickness, oh)
        love.graphics.rectangle("fill", ox + ow, oy, self.thickness, oh)
    else
        love.graphics.rectangle("fill", ox, oy, ow, self.thickness)
        love.graphics.rectangle("fill", ox, oy + oh - self.thickness, ow, self.thickness)

        love.graphics.rectangle("fill", ox, oy + self.thickness, self.thickness, oh - self.thickness * 2)
        love.graphics.rectangle("fill", ox + ow - self.thickness, oy + self.thickness, self.thickness, oh  - self.thickness * 2)
    end
    utils.reset_color()
end

--- Creates a new UI border.
---@param ui_element ui_element UI element to add this modifier to.
---@param thickness integer|nil Thickness of the border in pixels. Default is 1.
---@param out boolean|nil Border render mode. If true, renders the border outside of the UI element, otherwise renders inside. True by default.
---@param color table<number>|nil Сolor of the border. Table of type {r,g,b} where r,g and b are numbers from 0 to 1. Default is {0,0,0}
---@param opacity number|nil Opacity where 0 - invisible, 1 - fully visible. Default is 1.
---@return ui_border|nil
function ui_border:new(ui_element, thickness, out, color, opacity)
    if not ui_element then game.error("Cannot create a new UI border: ui_element was not provided.") return end
    if out == nil then out = true end

    local new = setmetatable(ui_modifier:new(ui_element), ui_border)
    new.thickness = thickness or 1
    new.out = out
    new.color = color or {0,0,0}
    new.opacity = opacity or 1

    return new
end

function ui_border:destroy()
    ui_modifier.destroy(self)
end

return ui_border
local ui_element = game.scene.ui.ui_element
local utils = game.utils

---@class text_label:ui_element
---@field font love.font The font of the text label.
---@field text string Text of the label.
---@field text_color table<number> Color of the text. Table of type {r,g,b,a} where r,g,b and a are numbers from 0 to 1.
---@field text_align string Alignment of the text. More info: https://www.love2d.org/wiki/AlignMode.
local text_label = {
    font = nil,
    text = nil,
    text_color = nil,
    text_align = nil
}
text_label.__index = text_label

-- Inherits
setmetatable(text_label, ui_element)

--- Draws the text label.
function text_label:draw()
    if not self:is_drawing() then return end

    -- Draw the base
    ui_element.draw(self)

    -- Draw the text
    if self.font then
        love.graphics.setFont(self.font)
    end
    love.graphics.setColor(self.text_color)

    local x,y = self:get_position()
    local width,height = self:get_size()

    love.graphics.printf(self.text, x, y, width, self.text_align)
    utils.reset_color()
end

--- Creates a new text label.
---@param parent ui_element|scene Parent of the text label.
---@param font love.font The font of the text label.
---@param text string|nil Text of the label. Default is "Text".
---@param text_color table<number>|nil Color of the text. Table of type {r,g,b,a} where r,g,b and a are numbers from 0 to 1. Default is {0,0,0,1}.
---@param color table<number>|nil Color of the label. Table of type {r,g,b,a} where r,g,b and a are numbers from 0 to 1. Default is {1,1,1,1}.
---@param text_align string|nil Alignment of the text. More info: https://www.love2d.org/wiki/AlignMode. Default is "center".
---@param layer integer|nil Initial layer to draw the component on. Should be 1000 or higher. Default is 1000.
---@param x number|nil X position on the screen from 0 to 1. Default is 0.
---@param y number|nil Y position on the screen where 0 to 1. Default is 0.
---@param width number|nil Width from 0 to 1. Default is 0.5.
---@param height number|nil Height from 0 to 1. Default is 0.5.
---@return text_label|nil
function text_label:new(parent, font, text, text_color, color, text_align, layer, x, y, width, height)
    if not parent then game.error("Cannot create a new text label: parent was not provided.") return end

    local new = setmetatable(ui_element:new(parent, layer, x, y, width, height, color), self)
    new.font = font
    new.text = text or "Text"
    new.text_color = text_color or {0,0,0,1}
    new.text_align = text_align or "center"

    return new
end

--- Destroys the text label.
function text_label:destroy()
    ui_element.destroy(self)
end

return text_label
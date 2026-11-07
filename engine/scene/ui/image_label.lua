local utils = game.utils
local ui_element = game.scene.ui.element

local DRAW_MODES = {"fill", "fit"}

---@class image_label:ui_element
---@field sprite sprite The sprite of the image label.
local image_label = {
    sprite = nil,
    draw_mode = nil
}
image_label.__index = image_label

-- Inherits
setmetatable(image_label, ui_element)

--- Draws the sprite of the image label according to its draw mode.
function image_label:draw()
    if not self:is_drawing() then return end

    if self.sprite then
        local x,y = self:get_position()
        local w,h = self:get_size()

        local sw,sh = self.sprite.width, self.sprite.height
        love.graphics.setColor(self.color)

        if self.draw_mode == "fill" then
            local sx,sy = w/sw, h/sh
            love.graphics.draw(self.sprite.image, x, y, 0, sx, sy)
        elseif self.draw_mode == "fit" then
            local scale = math.min(w/sw, h/sh)
            love.graphics.draw(self.sprite.image, x + (w-sw*scale)/2, y + (h-sh*scale)/2, 0, scale, scale)
        end

        utils.reset_color()
    else
        ui_element.draw(self)
    end
end

--- Creates a new image label.
---@param parent ui_element|scene Parent of the image label.
---@param layer integer|nil Initial layer to draw the component on. Should be 1000 or higher. Default is 1000.
---@param sprite love.image|nil The sprite of the image label.
---@param draw_mode string|nil Draw mode of the image label. See DRAW_MODES for all values. Default is "fill".
---@param color table<number>|nil Color of the image label. Table of type {r,g,b,a} where r,g,b and a are numbers from 0 to 1. Default is {1,1,1,1}.
---@param x number|nil X position on the screen from 0 to 1. Default is 0.
---@param y number|nil Y position on the screen where 0 to 1. Default is 0.
---@param width number|nil Width from 0 to 1. Default is 0.5.
---@param height number|nil Height from 0 to 1. Default is 0.5.
---@return image_label|nil
function image_label:new(parent, layer, sprite, draw_mode, x, y, width, height, color)
    if not parent then game.error("Cannot create a new image label: parent was not provided.") return end
    if draw_mode and not utils.table_find(DRAW_MODES, draw_mode) then game.error("Cannot create a new image label: Unknown draw mode.") return end

    local new = setmetatable(ui_element:new(parent, layer, x, y, width, height, color), self)
    new.sprite = sprite
    new.draw_mode = draw_mode or "fill"
    
    return new
end

function image_label:destroy()
    ui_element.destroy(self)
end

return image_label
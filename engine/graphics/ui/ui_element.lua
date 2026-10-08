local scene_component = game.scenes.scene_component
local event = game.event
local utils = game.utils

---@class ui_element:scene_component
---@field x number X position inside the parent where 0 - the left most pixel, 1 - the right most pixel, 0.5 - center.
---@field y number Y position inside the parent where 0 - the top most pixel, 1 - the bottom most pixel, 0.5 - center.
---@field width number Width where 0 covers 0% of the parent's width, 1 covers 100% of the parent's width.
---@field active boolean True if the element is visible and can be interacted, otherwise false.
---@field transparency number Transparency where 0 - fully visible, 1 - fully transparent,
---@field height number Height where 0 covers 0% of the parent's height, 1 covers 100% of the parent's height.
---@field parent ui_element|scene|nil Parent UI element. To change use ui_element:set_parent().
---@field children table<ui_element> Children UI elements.
---@field mouse_overlap boolean True if the mouse is on the element, false if the mouse is outside.
---@field on_mouse_enter event Fires when the mouse enters the element.
---@field on_mouse_leave event Fires when the mouse leaves the element.
local ui_element = {
    x = nil,
    y = nil,

    width = nil,
    height = nil,

    active = nil,
    transparency = nil,

    parent = nil,
    children = nil,

    mouse_overlap = nil,
    on_mouse_enter = nil,
    on_mouse_leave = nil,
    on_mouse_down = nil,
    on_mouse_up = nil
}
ui_element.__index = ui_element
ui_element.__newindex = utils.get_readonly_func({"on_mouse_enter", "on_mouse_leave"})

-- Inherits
setmetatable(ui_element, scene_component)

--- Base method that needs to be replaced by inheriting classes.
function ui_element:draw()
    if not self.active then return end

    local x,y = self:get_position()
    local width,height = self:get_size()

    utils.apply_transparency(self.transparency)
    love.graphics.rectangle("fill", x, y, width, height)
    utils.reset_color()
end

--- Tells whether the given position overlaps with the element.
---@param x integer X position to check.
---@param y integer Y position to check.
---@return boolean
function ui_element:does_overlap(x,y)
    local ox,oy = self:get_position()
    local width,height = self:get_size()

    return x >= ox and x <= ox + width and y >= oy and y <= oy + height
end

--- Sets the pixel position of the element. To change position relative to the parent change ui_element.x and ui_element.y.
---@param x integer New width in pixels.
---@param y integer New height in pixels.
function ui_element:set_position(x,y)
    local ox,oy = self:get_position()
    local ow,oh = self:get_size()
    self.x = x / (ox + ow)
    self.y = y / (oy + oh)
end

--- Sets the pixel size of the element. To change size relative to the parent change ui_element.width and ui_element.height.
---@param width integer New width in pixels.
---@param height integer New height in pixels.
function ui_element:set_size(width, height)
    local ow,oh = self:get_size()
    self.width = width / ow * self.width
    self.height = height / oh * self.height
end

--- Gets the pixel position to render the element.
---@return integer,integer
function ui_element:get_position()
    local x = 0
    local y = 0

    if self.parent then
        local px,py
        local pw,ph
        if self.parent.parent then
            px,py = self.parent:get_position()
            pw,ph = self.parent:get_size()
        else
            px,py = 0,0
            pw,ph = love.graphics.getPixelWidth(),love.graphics.getPixelHeight()
        end
        x = px + pw * self.x
        y = py + ph * self.y
    end
    return x,y
end

--- Gets the pixel size to render the element.
---@return integer,integer
function ui_element:get_size()
    local w = 0
    local h = 0

    if self.parent then
        local pw,ph
        if self.parent.parent then
            pw,ph = self.parent:get_size()
        else
            pw,ph = love.graphics.getPixelWidth(),love.graphics.getPixelHeight()
        end
        w = pw * self.width
        h = ph * self.height
    end
    return w,h
end

--- Sets the parent of the UI element.
---@param parent ui_element|scene|nil New parent. This element will not render new parent is nil.
function ui_element:set_parent(parent)
    local prev_parent = self.parent
    if prev_parent == parent then return end

    if prev_parent and prev_parent.children then
        local prev_child_i = utils.table_find(prev_parent.children, self)
        if prev_child_i then
            table.remove(prev_parent.children, prev_child_i)
        end
    end

    self.parent = parent
    if parent and parent.children then
        table.insert(parent.children, self)
    end
end

--- Creates a new UI element.
---@param scene scene Scene to add this element to.
---@param layer integer|nil Initial layer to draw the component on. Should be 1000 or higher. Default is 1000.
---@param x number|nil X position on the screen from 0 to 1. Default is 0.
---@param y number|nil Y position on the screen where 0 to 1. Default is 0.
---@param width number|nil Width from 0 to 1. Default is 0.5.
---@param height number|nil Height from 0 to 1. Default is 0.5.
---@param parent ui_element|scene|nil Initial parent of the UI element.
---@return ui_element|nil
function ui_element:new(scene, layer, x, y, width, height, parent)
    if not scene then game.error("Cannot create a new UI element: scene was not provided.") return end

    local new = setmetatable(scene_component:new(scene,layer or 1000), self)

    new.x = (x and utils.clamp(x, 0, 1)) or 0
    new.y = (y and utils.clamp(y, 0, 1)) or 0

    new.width = (width and utils.clamp(width, 0, 1)) or 0.5
    new.height = (height and utils.clamp(height, 0, 1)) or 0.5

    new.active = true
    new.transparency = 0.5

    new.mouse_overlap = false
    new.on_mouse_enter = event:new()
    new.on_mouse_leave = event:new()
    new.on_mouse_down = event:new()
    new.on_mouse_up = event:new()

    new:set_parent(parent)
    new.children = {}

    return new
end

--- Destroys the UI element.
function ui_element:destroy()
    scene_component.destroy(self)
end

return ui_element
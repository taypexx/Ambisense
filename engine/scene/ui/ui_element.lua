local event = game.event
local utils = game.utils
local scene_component = game.scene.scene_component

local MIN_COMP_LAYER = 1000
local MAX_COMP_LAYER = 9999

---@class ui_element:scene_component
---@field x number X position inside the parent where 0 - the left most pixel, 1 - the right most pixel, 0.5 - center.
---@field y number Y position inside the parent where 0 - the top most pixel, 1 - the bottom most pixel, 0.5 - center.
---@field width number Width where 0 covers 0% of the parent's width, 1 covers 100% of the parent's width.
---@field active boolean True if the element is visible and can be interacted, otherwise false.
---@field color table<number> Сolor of the element. Table of type {r,g,b,a}.
---@field height number Height where 0 covers 0% of the parent's height, 1 covers 100% of the parent's height.
---@field parent ui_element|scene|nil Parent UI element. To change use ui_element:set_parent().
---@field children table<ui_element> Children UI elements.
---@field on_mouse_enter event Fires when the mouse enters the element.
---@field on_mouse_leave event Fires when the mouse leaves the element.
local ui_element = {
    x = nil,
    y = nil,

    width = nil,
    height = nil,

    active = nil,
    color = nil,

    parent = nil,
    children = nil,
    modifiers = nil,

    on_mouse_enter = nil,
    on_mouse_leave = nil,
    on_mouse_down = nil,
    on_mouse_up = nil
}
ui_element.__index = ui_element
ui_element.__newindex = utils.readonly_func({"on_mouse_enter", "on_mouse_leave", "on_mouse_down", "on_mouse_up"})

-- Inherits
setmetatable(ui_element, scene_component)

--- Base method that needs to be replaced by inheriting classes.
function ui_element:draw()
    if not self:is_drawing() then return end

    local x,y = self:get_position()
    local width,height = self:get_size()

    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", x, y, width, height)
    utils.reset_color()

    for _,modifier in pairs(self.modifiers) do
        modifier:draw()
    end
end

--- Tells whether the element is being drawn.
---@return boolean is_drawing True if the element is being drawn, otherwise false.
function ui_element:is_drawing()
    if self.parent and self.parent.parent then
        return self.active and self.parent:is_drawing()
    end
    return self.active
end

--- Attaches the modifier to the UI element.
---@param modifier ui_modifier UI modifier to attach.
function ui_element:attach_modifier(modifier)
    if utils.table_find(self.modifiers, modifier) then game.error("Cannot attach a UI modifier to the UI element: Modifier is already attached.") return end
    table.insert(self.modifiers, modifier)
end

--- Detaches the modifier to the UI element.
---@param modifier ui_modifier UI modifier to detach.
function ui_element:detach_modifier(modifier)
    local i = utils.table_find(self.modifiers, modifier)
    if not i then game.error("Cannot detach a UI modifier to the UI element: Modifier is not attached.") return end
    table.remove(self.modifiers, i)
end

--- Sets the pixel position of the element. To change position relative to the parent change ui_element.x and ui_element.y.
---@param x integer New X position in pixels.
---@param y integer New Y position in pixels.
function ui_element:set_position(x,y)
    x = x or 0
    y = y or 0

    local pw,ph = self:get_parent_size()
    self.x = x / pw
    self.y = y / ph
end

--- Sets the pixel size of the element. To change size relative to the parent change ui_element.width and ui_element.height.
---@param width integer New width in pixels.
---@param height integer New height in pixels.
function ui_element:set_size(width, height)
    width = width or 0
    height = height or 0

    local ow,oh = self:get_size()
    self.width = width / ow * self.width
    self.height = height / oh * self.height
end

--- Gets the pixel position to draw the element.
---@return integer,integer
function ui_element:get_position()
    local x = 0
    local y = 0

    if self.parent then
        local px,py = self:get_parent_position()
        local pw,ph = self:get_parent_size()
        
        x = px + pw * self.x
        y = py + ph * self.y
    end
    return x,y
end

--- Gets the pixel size to draw the element.
---@return integer,integer
function ui_element:get_size()
    local w = 0
    local h = 0

    if self.parent then
        local pw,ph = self:get_parent_size()
        w = pw * self.width
        h = ph * self.height
    end
    return w,h
end

--- Gets the parent position in pixels.
---@return integer,integer
function ui_element:get_parent_position()
    local px,py
    if self.parent and self.parent.parent then
        px,py = self.parent:get_position()
    else
        px,py = 0,0
    end
    return px,py
end

--- Gets the parent size in pixels.
---@return integer,integer
function ui_element:get_parent_size()
    local pw,ph
    if self.parent.parent then
        pw,ph = self.parent:get_size()
    else
        pw,ph = love.graphics.getPixelWidth(),love.graphics.getPixelHeight()
    end
    return pw,ph
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
---@param parent ui_element|scene Initial parent of the UI element.
---@param layer integer|nil Initial layer to draw the component on. Should be in range 1000~9999. Default is 1000.
---@param x number|nil X position inside the parent from 0 to 1. Default is 0.
---@param y number|nil Y position inside the parent 0 to 1. Default is 0.
---@param width number|nil Width from 0 to 1. Default is 0.5.
---@param height number|nil Height from 0 to 1. Default is 0.5.
---@param color table<number> Сolor of the element. Table of type {r,g,b,a} where r,g,b and a are numbers from 0 to 1. Default is {1,1,1,1}.
---@return ui_element|nil
function ui_element:new(parent, layer, x, y, width, height, color)
    if not parent then game.error("Cannot create a new UI element: parent was not provided.") return end

    local scene = parent.scene or parent
    if not scene then game.error("Cannot create a new UI element: parent is not a scene or a UI element.") return end

    local new = setmetatable(scene_component:new(scene,utils.clamp(layer or 1000, MIN_COMP_LAYER, MAX_COMP_LAYER)), self)

    new.x = (x and utils.clamp(x, 0, 1)) or 0
    new.y = (y and utils.clamp(y, 0, 1)) or 0

    new.width = (width and utils.clamp(width, 0, 1)) or 0.5
    new.height = (height and utils.clamp(height, 0, 1)) or 0.5

    new.active = true
    new.color = color or {1,1,1,1}

    new.on_mouse_enter = event:new()
    new.on_mouse_leave = event:new()
    new.on_mouse_down = event:new()
    new.on_mouse_up = event:new()

    new:set_parent(parent)
    new.children = {}
    new.modifiers = {}

    return new
end

--- Destroys the UI element.
function ui_element:destroy()
    scene_component.destroy(self)
end

return ui_element
local utils = game.utils
local scene_component = game.graphics.scene_component
local camera = game.world.camera

local MIN_COMP_LAYER = 100
local MAX_COMP_LAYER = 999

---@class map_component:scene_component
---@field visible boolean True if thee component is visible, otherwise false.
---@field cull boolean Whether the component culls. If true will not render outside of the screen.
---@field x number X coordinate of the component in the world space.
---@field y number Y coordinate of the component in the world space.
---@field width number Width of the component in the world space.
---@field height number Height of the component in the world space.
local map_component = {
    map = nil,
    visible = nil,
    cull = nil,
    x = nil,
    y = nil,
    width = nil,
    height = nil
}
map_component.__index = map_component

-- Inherits
setmetatable(map_component, scene_component)

--- Draws the map component.
function map_component:draw()
    if not self:is_drawing() then return end

    local sx,sy = self:get_position()
    local sw,sh = self:get_size()
    love.graphics.rectangle("fill", sx, sy, sw, sh)
end

--- Tells whether the component is being drawn.
---@return boolean is_drawing True if the component is being drawn, otherwise false.
function map_component:is_drawing()
    if not (self.visible and self.scene.active) then
        return false
    elseif self.cull then
        local x,y = self:get_position()
        local w,h = self:get_size()
        local sw,sh = love.graphics.getDimensions()

        return x + w > 0 and x < sw and y + h > 0 and y < sh
    else return true end
end

--- Gets the screen position of the component in pixels. To get the world position check map_component.x and map_component.y.
---@return integer sx Screen X position.
---@return integer sy Screen Y position.
function map_component:get_position()
    return camera:get_screen_pos(self.x, self.y)
end

--- Gets the screen size of the component in pixels. To get the world size check map_component.width and map_component.height.
function map_component:get_size()
    local scale = camera.scale
    return self.width * scale, self.height * scale
end

--- Creates a new map component.
---@param map map Map to add this component to.
---@param layer integer|nil Initial layer to draw the component on. Should be in range 100~999. Default is 100.
---@param x number|nil X coordinate in the world space. Default is 0.
---@param y number|nil Y coordinate in the world space. Default is 0.
---@param width number|nil Width in the world space. Default is 16.
---@param height number|nil Height in the world space. Default is 16.
---@param cull boolean|nil Whether to cull the component. True by default.
function map_component:new(map, layer, x, y, width, height, cull)
    if not map then game.error("Cannot create a new map component: map was not provided.") return end
    if cull == nil then cull = true end

    local new = setmetatable(scene_component:new(map.scene, utils.clamp(layer or 100, MIN_COMP_LAYER, MAX_COMP_LAYER)), self)
    new.visible = true
    new.cull = cull
    new.x = x or 0
    new.y = y or 0
    new.width = width or 16
    new.height = height or 16

    return new
end

--- Destroys the map component.
function map_component:destroy()
    scene_component.destroy(self)
end

return map_component
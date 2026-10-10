local scene_component = game.scenes.scene_component
local utils = game.utils

local MIN_COMP_LAYER = 0
local MAX_COMP_LAYER = 999

---@class map_component:scene_component
---@field x integer X coordinate of the component in the world space.
---@field y integer Y coordinate of the component in the world space.
---@field width number Width of the component in the world space.
---@field height number Height of the component in the world space.
local map_component = {
    map = nil,
    x = nil,
    y = nil,
    width = nil,
    height = nil
}
map_component.__index = map_component

-- Inherits
setmetatable(map_component, scene_component)

---@param scene scene Scene to add this component to.
---@param layer integer|nil Initial layer to draw the component on. Should be in range 0~999. Default is 100.
---@param x number|nil X coordinate in the world space. Default is 0.
---@param y number|nil Y coordinate in the world space. Default is 0.
---@param width number|nil Width in the world space. Default is 16.
---@param height number|nil Height in the world space. Default is 16.
function map_component:new(scene, layer, x, y, width, height)
    if not scene then game.error("Cannot create a new map component: scene was not provided.") return end

    local new = setmetatable(scene_component:new(scene, utils.clamp(layer or 100, MIN_COMP_LAYER, MAX_COMP_LAYER)), self)
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
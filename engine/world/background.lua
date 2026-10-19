local utils = game.utils
local scene_component = game.graphics.scene_component
local camera = game.world.camera

local MIN_COMP_LAYER = 0
local MAX_COMP_LAYER = 98

---@class background:scene_component
---@field map map Original map from where the background was created.
---@field image love.Image Image of the background.
---@field quad love.Quad Quad to draw the background on.
local background = {
    map = nil,
    image = nil,
    quad = nil,
    visible = nil,
    parallax_x = nil,
    parallax_y = nil
}
background.__index = background

-- Inherits
setmetatable(background, scene_component)

--- Draws the background.
function background:draw()
    if not self.visible then return end

    local scale = camera.scale
    self.quad:setViewport(camera.x * self.parallax_x, camera.y * self.parallax_y, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.draw(self.image, self.quad)
end

--- Creates a new background.
---@param image love.Image Image of the background.
---@param map map|nil Map to render this background for.
---@param layer integer|nil Layer to draw the background on. Should be in range 0~98. Default is 0.
---@param parallax_x number|nil Parallax X factor. Default is 1. 
---@param parallax_y number|nil Parallax Y factor. Default is 1. 
---@return background|nil
function background:new(image, map, layer, parallax_x, parallax_y)
    if not image then game.error("Cannot create a new map background: image was not provided.") return end
    image:setWrap("repeat", "repeat")

    local new = setmetatable(scene_component:new(map.scene, utils.clamp(layer or 0, MIN_COMP_LAYER, MAX_COMP_LAYER)), self)
    new.map = map
    new.image = image
    new.quad = love.graphics.newQuad(0, 0, love.graphics.getWidth(), love.graphics.getHeight(), image:getDimensions())
    new.visible = true
    new.parallax_x = parallax_x or 1
    new.parallax_y = parallax_y or 1

    return new
end

--- Destroys the background.
function background:destroy()
    if self.map then
        local i = utils.table_find(self.map.bgs, self)
        if i then
            table.remove(self.map.bgs, i)
        end
    end
    scene_component.destroy(self)
end

return background
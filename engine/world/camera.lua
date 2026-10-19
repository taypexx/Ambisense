local utils = game.utils
local event = game.event
local tween = game.tween

local MODES = {"static","follow"}

---@class camera
---@field x number X coordinate of the camera center in the world space.
---@field y number Y coordinate of the camera center in the world space.
---@field scale number Zoom of the camera where 1 - normal state (100% zoom).
---@field mode string Camera mode. "static" - stays at the same coordiates. "follow" - follows the world component. Works as static if the target is nil.
---@field target map_component|nil Target component to follow. Will not affect the camera if the mode is set to "static".
---@field on_zoom event Fires when camera starts zooming in/out. Arguments: zoom:number - New zoom of the camera.
local camera = {
    x = 0,
    y = 0,
    scale = 1,
    zooming = false,
    mode = "static",
    target = nil,
    on_zoom = event:new()
}
camera.__index = camera
camera.__newindex = utils.readonly_func({"on_zoom"})

--- Converts world coordinates to screen position.
---@param wx number World X coordinate.
---@param wy number World Y coordinate.
---@return integer sx Screen X coordinate.
---@return integer sy Screen Y coordinate.
function camera:get_screen_pos(wx, wy)
    local sw,sh = love.graphics.getPixelDimensions()
    return sw/2 + (wx - self.x)*self.scale, sh/2 + (wy - self.y)*self.scale
end

--- Gets the screen position to world coordinates.
---@param sx integer Screen X coordinate.
---@param sy integer Screen Y coordinate.
---@return number wx World X coordinate.
---@return number wy World Y coordinate.
function camera:get_world_pos(sx, sy)
    local sw,sh = love.graphics.getPixelDimensions()
    return self.x + (sx - sw/2)/self.scale, self.y + (sy - sh/2)/self.scale
end

--- Sets the camera position to the given coordinates. Camera must be in "static" mode.
---@param x number|nil X coordinate of the camera center in the world space. Default is 0.
---@param y number|nil Y coordinate of the camera center in the world space. Default is 0.
function camera:to(x,y)
    if self.mode ~= "static" then return end

    -- TODO: do smooth camera teleport with easing functions (add an option as a parameter)
    self.x = x or 0
    self.y = y or 0
end

--- Zooms the camera
---@param zoom number Zoom of the camera where 1 - normal state (100% zoom).
---@param easing string|nil Easting to apply for zooming.
function camera:zoom(zoom, easing)
    if self.zooming then return end
    if not zoom then game.error("Cannot zoom camera: zoom was not provided.") return end

    local new_scale = utils.clamp(zoom, 0.1, 100)
    self.on_zoom:fire(new_scale)

    if easing then
        self.zooming = true
        tween:start(self, "scale", new_scale, 0.1, easing, function ()
            self.zooming = false
        end)
    else
        self.scale = new_scale
    end
end

--- Updates the camera.
---@param dt number Time since last update in seconds.
function camera:update(dt)
    if self.mode == "follow" and self.target then
        self.x = self.target.x
        self.y = self.target.y
    end
end

--- Sets the camera mode.
---@param mode string Camera mode. "static" - stays at the same coordiates. "follow" - follows the world component. Works as static if the target is nil.
function camera:set_mode(mode)
    if not utils.table_find(MODES, mode) then game.error("Cannot set the camera mode: Unknown camera mode.") return end
    self.mode = mode
end

return camera